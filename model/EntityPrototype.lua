---
-- Description of the module.
-- @module EntityPrototype
--

EntityPrototype = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getEntityPrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getEntityPrototype(object.name))
  end
  base.factory = object
  base.classname = "HMEntityPrototype"
end)

local temperature_limit = 165
-------------------------------------------------------------------------------
-- Return type
--
-- @function [parent=#EntityPrototype] getType
--
-- @return #table
--
function EntityPrototype:getType()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.type
end

-------------------------------------------------------------------------------
-- Return Allowed Effects
--
-- @function [parent=#EntityPrototype] getAllowedEffects
--
-- @return #table
--
function EntityPrototype:getAllowedEffects()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.allowed_effects
end

-------------------------------------------------------------------------------
-- Return ingredient_count
--
-- @function [parent=#EntityPrototype] getIngredientCount
--
-- @return #number
--
function EntityPrototype:getIngredientCount()
  return self.lua_prototype.ingredient_count or 6
end

-------------------------------------------------------------------------------
-- Return energy usage per second
--
-- @function [parent=#EntityPrototype] getEnergyUsage
--
-- @return #number default 0
--
function EntityPrototype:getEnergyUsage()
  if self.lua_prototype ~= nil and self.lua_prototype.energy_usage ~= nil then
    return self.lua_prototype.energy_usage*60
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return extract power of fluid (boiler) in J
--
-- @function [parent=#EntityPrototype] getPowerExtract
--
-- @param #number temperature
-- @param #number heat_capacity
--
-- @return #number default 0
--
function EntityPrototype:getPowerExtract(temperature, heat_capacity)
  if self.lua_prototype ~= nil then
    if temperature == nil then
      temperature = 165
    end
    if temperature < 15 then
      temperature = 25
    end
    if heat_capacity == nil or heat_capacity == 0 then
      heat_capacity = 200
    end
    return (temperature-15)*heat_capacity
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return max energy usage per second
--
-- @function [parent=#EntityPrototype] getMaxEnergyUsage
--
-- @return #number default 0
--
function EntityPrototype:getMaxEnergyUsage()
  if self.lua_prototype ~= nil and self.lua_prototype.max_energy_usage ~= nil then
    return self.lua_prototype.max_energy_usage*60
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return min energy usage per second
--
-- @function [parent=#EntityPrototype] getMinEnergyUsage
--
-- @return #number default 0
--
function EntityPrototype:getMinEnergyUsage()
  local energy_prototype = self:getEnergySource()
  if energy_prototype ~= nil then
    return energy_prototype:getDrain()
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return nominal energy for generator
-- @see https://wiki.factorio.com/Power_production
-- @see https://wiki.factorio.com/Liquids/Hot
-- @see https://wiki.factorio.com/Tutorial:Applied_power_math
--
-- @function [parent=#EntityPrototype] getEnergyConsumption
--
-- @return #number default 0
--
function EntityPrototype:getEnergyConsumption()
  if self.lua_prototype ~= nil then
    local energy_prototype = self:getEnergySource()
    local usage_priority = nil
    if energy_prototype ~= nil then
      usage_priority = energy_prototype:getUsagePriority()
    end
    if usage_priority == "solar" then
      return 0
    end
    if usage_priority == "managed-accumulator" then
      return energy_prototype:getInputFlowLimit()
    end

    local max_energy_usage = self:getMaxEnergyUsage()
    if max_energy_usage > 0 then
      local drain = 0
      if energy_prototype ~= nil then
        drain = energy_prototype:getDrain()
      end
      return drain + self:getMaxEnergyUsage()
    end

    local energy_type = self:getEnergyTypeInput()
    if energy_type == "fluid" then
      local fluid_fuel = self:getFluidFuelPrototype()
      local fuel_value = fluid_fuel:getFuelValue()
      local fluid_usage = self:getFluidUsage()
      local effectivity = self:getEffectivity()
      local maximum_temperature = self:getMaximumTemperature()
      -- une temperature trop basse = burnt
      if fuel_value > 0 and maximum_temperature < temperature_limit then
        return fluid_usage * effectivity * fuel_value
      else
        local heat_capacity = fluid_fuel:getHeatCapacity()
        if self.factory ~= nil and self.factory.temperature ~= nil then
          maximum_temperature = self.factory.temperature
        end
        -- calcul avec un heat minimum de 200
        if heat_capacity < 200 then
          heat_capacity = 200
        end
        local power_extract = self:getPowerExtract(maximum_temperature, heat_capacity)
        -- [boiler.fluid_usage]x[boiler.fluid_usage]x[boiler.target_temperature]-15°c)x[200J/unit/°]
        return fluid_usage * effectivity * power_extract
      end
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return nominal energy for generator
-- @see https://wiki.factorio.com/Power_production
-- @see https://wiki.factorio.com/Liquids/Hot
-- @see https://wiki.factorio.com/Tutorial:Applied_power_math
--
-- @function [parent=#EntityPrototype] getEnergyProduction
--
-- @return #number default 0
--
function EntityPrototype:getEnergyProduction()
  if self.lua_prototype ~= nil then
    local energy_prototype = self:getEnergySource()
    local usage_priority = nil
    if energy_prototype ~= nil then
      usage_priority = energy_prototype:getUsagePriority()
    end
    if usage_priority == "solar" then
      local active_mods = game.active_mods
      if active_mods["base"] ~= "1.0.0" then
        return (self.lua_prototype.max_energy_production or 0)*60
      end
      return (self.lua_prototype.production or 0)*60
    end
    if usage_priority == "secondary-output" or usage_priority == "primary-output" then
      if self:getEnergyTypeInput() == "fluid" then
        local heat_capacity = 200
        local fuel_value = 0
        local fluid_fuel = self:getFluidFuelPrototype()
        if fluid_fuel ~= nil then
          fuel_value = fluid_fuel:getFuelValue()
          heat_capacity = fluid_fuel:getHeatCapacity()
        end

        local fluid_usage = self:getFluidUsage()
        local effectivity = self:getEffectivity()
        local maximum_temperature = self:getMaximumTemperature()
        -- une temperature trop basse = burnt
        if fuel_value > 0 and maximum_temperature < temperature_limit then
          return fluid_usage * effectivity * fuel_value
        else
          -- calcul avec un heat minimum de 200
          if heat_capacity < 200 then
            heat_capacity = 200
          end
          local power_extract = self:getPowerExtract(maximum_temperature, heat_capacity)
          -- [boiler.fluid_usage]x[boiler.fluid_usage]x[boiler.target_temperature]-15°c)x[200J/unit/°]
          return fluid_usage * effectivity * power_extract
        end
      end
    end
    if usage_priority == "managed-accumulator" then
      return energy_prototype:getOutputFlowLimit()
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return base productivity
--
-- @function [parent=#EntityPrototype] getBaseProductivity
--
-- @return #number default 0
--
function EntityPrototype:getBaseProductivity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.base_productivity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return effectivity
--
-- @function [parent=#EntityPrototype] getEffectivity
--
-- @return #number default 1
--
function EntityPrototype:getEffectivity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.effectivity or 1
  end
  return 1
end

-------------------------------------------------------------------------------
-- Return distribution effectivity
--
-- @function [parent=#EntityPrototype] getDistributionEffectivity
--
-- @return #number default 1
--
function EntityPrototype:getDistributionEffectivity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.distribution_effectivity or 1
  end return 1
end

-------------------------------------------------------------------------------
-- Return maximum temperature
--
-- @function [parent=#EntityPrototype] getMaximumTemperature
--
-- @return #number default 0
--
function EntityPrototype:getMaximumTemperature()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.maximum_temperature or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return traget temperature
--
-- @function [parent=#EntityPrototype] getTargetTemperature
--
-- @return #number default 0
--
function EntityPrototype:getTargetTemperature()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.target_temperature or 0
  end
  return 0
end

--------------------------------------------------------------------------------
-- Return fluid capacity (container)
--
-- @function [parent=#EntityPrototype] getFluidCapacity
--
-- @return #number default 0
--
function EntityPrototype:getFluidCapacity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluid_capacity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid usage per tick
--
-- @function [parent=#EntityPrototype] getFluidUsagePerTick
--
-- @return #number default 0
--
function EntityPrototype:getFluidUsagePerTick()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluid_usage_per_tick or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid usage
--
-- @function [parent=#EntityPrototype] getFluidUsage
--
-- @return #number default 0
--
function EntityPrototype:getFluidUsage()
  return self:getFluidUsagePerTick() * 60
end

-------------------------------------------------------------------------------
-- Return fluid usage prototype (for generator)
--
-- @function [parent=#EntityPrototype] getFluidUsagePrototype
--
-- @return #number default 0
--
function EntityPrototype:getFluidUsagePrototype()
  if self.lua_prototype.type == "generator" then
    local fluidboxes = self:getFluidboxPrototypes()
    if fluidboxes ~= nil then
      for _,fluidbox in pairs(fluidboxes) do
        if fluidbox.production_type == "input-output" then
          return FluidPrototype(fluidbox.filter)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Return fluid fuel prototype
--
-- @function [parent=#EntityPrototype] getFluidFuelPrototype
--
-- @return #FluidPrototype
--
function EntityPrototype:getFluidFuelPrototype(current)
  if self:getEnergyTypeInput() == "fluid" then
    if current == true and self.factory ~= nil and self.factory.fuel ~= nil then
      return FluidPrototype(self.factory.fuel)
    else
      if self:getFluidUsage() > 0 then
        local fluidboxes = self:getFluidboxPrototypes()
        if fluidboxes ~= nil then
          for _,fluidbox in pairs(fluidboxes) do
            if fluidbox.production_type == "input-output" or fluidbox.production_type == "input" then
              if fluidbox.filter ~= nil then
                return FluidPrototype(fluidbox.filter)
              else
                local fuels = Player.getFluidFuelPrototypes()
                local first = nil
                for _,fuel in pairs(fuels) do
                  if first == nil or first.fuel_value > fuel.fuel_value then
                    first = fuel
                  end
                end
                return FluidPrototype(first)
              end
            end
          end
        end
      else
        local energy_source = self:getEnergySource()
        if energy_source ~= nil then
          if energy_source:getBurnsFluid() then
            return energy_source:getFuelPrototype()
          else
            local fluidbox = energy_source:getFluidbox()
            return FluidPrototype(fluidbox.filter)
          end
        end
      end
    end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return fluid fuel prototype
--
-- @function [parent=#EntityPrototype] getFluidFuelPrototype
--
-- @return #FluidPrototype
--
function EntityPrototype:getFluidFuelPrototypes()
  local energy_source = self:getEnergySource()
  if energy_source:getType() == "fluid" then
    if not(energy_source:getBurnsFluid()) then
      local fluidboxes = self:getFluidboxPrototypes()
      if fluidboxes ~= nil then
        for _,fluidbox in pairs(fluidboxes) do
          if fluidbox.production_type == "input-output" or fluidbox.production_type == "input" then
            if fluidbox.filter ~= nil then
              return {fluidbox.filter}
            else
              return Player.getFluidFuelPrototypes()
            end
          end
        end
      end
    else
      return Player.getFluidFuelPrototypes()
    end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return fluid consumption
--
-- @function [parent=#EntityPrototype] getFluidConsumption
--
-- @return #number default 0
--
function EntityPrototype:getFluidConsumption()
  if self.lua_prototype ~= nil then
    local fluid_usage = self:getFluidUsage()
    local fluid_fuel = self:getFluidFuelPrototype(true)
      
    -- si l'entity a du fluid usage c'est forcement cette valeur
    if fluid_usage > 0 then
      return fluid_usage
    end
    local energy_type = self:getEnergyTypeInput()
    if energy_type == "fluid" then
      local energy_source = self:getEnergySource()
      local energy_fluid_usage = energy_source:getFluidUsage()
      local fluid_burns = energy_source:getBurnsFluid()
      local energy_consumption = self:getEnergyConsumption()
      local effectivity = self:getEffectivity()
      local maximum_temperature = self:getMaximumTemperature()
      local fuel_value = fluid_fuel:getFuelValue()

      if fluid_burns then
        -- si l'energy a du fluid usage en burns ca devient une limit
        if energy_fluid_usage > 0 then
          return math.min(energy_fluid_usage, energy_consumption / (effectivity * fuel_value))
        else
          return energy_consumption / (effectivity * fuel_value)
        end
      elseif fuel_value > 0 and maximum_temperature < temperature_limit then
        return energy_consumption / (effectivity * fuel_value)
      else
        -- si l'energy a du fluid usage c'est forcement cette valeur
        if energy_fluid_usage > 0 then
          return energy_fluid_usage
        else
          local heat_capacity = fluid_fuel:getHeatCapacity()
          local target_temperature = self:getTargetTemperature()
          local power_extract = self:getPowerExtract(target_temperature, heat_capacity)
          return energy_consumption / (effectivity * power_extract)
        end
      end
      
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid production
--
-- @function [parent=#EntityPrototype] getFluidProduction
--
-- @return #number default 0
--
function EntityPrototype:getFluidProduction()
  local fluidbox = self:getFluidboxPrototype("output")
  if fluidbox ~= nil then
    if self:getType() == "offshore-pump" then
      return self:getPumpingSpeed()
    end
    if self:getType() == "boiler" then
      local effectivity = self:getEffectivity()
      local fluid_prototype = FluidPrototype(fluidbox:getFilter())
      local heat_capacity = fluid_prototype:getHeatCapacity()
      local target_temperature = self:getTargetTemperature()
      local power_extract = self:getPowerExtract(target_temperature, heat_capacity)
      local energy_consumption = self:getEnergyConsumption()
      return energy_consumption / (effectivity * power_extract)
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid production filter
--
-- @function [parent=#EntityPrototype] getFluidProductionFilter
--
-- @return #LuaFluidPrototype
--
function EntityPrototype:getFluidProductionFilter()
  local fluidbox = self:getFluidboxPrototype("output")
  if fluidbox ~= nil then
    return fluidbox:getFilter()
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return fuel
--
-- @function [parent=#EntityPrototype] getFluel
--
-- @return #table
--
function EntityPrototype:getFluel()
  if self.lua_prototype ~= nil then
    local energy_prototype = self:getEnergySource()
    local energy_type = self:getEnergyTypeInput()
    if energy_type == "fluid" then
      local fuel = self:getFluidFuelPrototype(true)
      if fuel ~= nil then
        return {name=fuel:native().name, type="fluid"}
      end
    elseif energy_type == "burner" then
      local fuel = energy_prototype:getFuelPrototype()
      if fuel ~= nil then
        return {name=fuel:native().name, type="item"}
      end
    end
  end
  return nil
end
-------------------------------------------------------------------------------
-- Return module inventory size
--
-- @function [parent=#EntityPrototype] getModuleInventorySize
--
-- @return #number default 0
--
function EntityPrototype:getModuleInventorySize()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.module_inventory_size or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return crafting categories
--
-- @function [parent=#EntityPrototype] getCraftingCategories
--
-- @return #number default 0
--
function EntityPrototype:getCraftingCategories()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.crafting_categories or {}
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return crafting speed
--
-- @function [parent=#EntityPrototype] getCraftingSpeed
--
-- @return #number default 0
--
function EntityPrototype:getCraftingSpeed()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.name == "character" then return Player.getCraftingSpeed() end
    return self.lua_prototype.crafting_speed or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return mining speed
--
-- @function [parent=#EntityPrototype] getMiningSpeed
--
-- @return #number default 0
--
function EntityPrototype:getMiningSpeed()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.mining_speed or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return neighbour bonus
--
-- @function [parent=#EntityPrototype] getNeighbourBonus
--
-- @return #number default 0
--
function EntityPrototype:getNeighbourBonus()
  if self.lua_prototype ~= nil then
    if self.factory == nil then
      return self.lua_prototype.neighbour_bonus or 0
    else
      local bonus = self.lua_prototype.neighbour_bonus or 0
      if self.factory.neighbour_bonus == 2 then
        return bonus
      elseif self.factory.neighbour_bonus == 4 then
        return 2*bonus
      elseif self.factory.neighbour_bonus == 8 then
        return (2+3)*bonus/2
      else
        return 0
      end
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return researching speed
--
-- @function [parent=#EntityPrototype] getSearchingSpeed
--
-- @return #number default 0
--
function EntityPrototype:getResearchingSpeed()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.researching_speed or 1
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return pumping speed
--
-- @function [parent=#EntityPrototype] getPumpingSpeed
--
-- @return #number default 0
--
function EntityPrototype:getPumpingSpeed()
  if self.lua_prototype ~= nil then
    return (self.lua_prototype.pumping_speed or 0)*60 
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return spped factory for recipe
--
-- @function [parent=#EntityPrototype] speedFactory
--
-- @param #table recipe
--
function EntityPrototype:speedFactory(recipe)
  if recipe.name == "steam" then
    -- @see https://wiki.factorio.com/Boiler
    -- info energy 1J=1W
    local fluid_prototype = FluidPrototype("steam")
    local heat_capacity = fluid_prototype:getHeatCapacity()
    local power_extract = self:getPowerExtract(165, heat_capacity)
    local power_usage = self:getEnergyConsumption()
    return power_usage/power_extract
  elseif recipe.type == "resource" then
    -- (mining power - ore mining hardness) * mining speed
    -- @see https://wiki.factorio.com/Mining
    -- hardness removed
    -- @see https://www.factorio.com/blog/post/fff-266
    local recipe_prototype = EntityPrototype(recipe.name)
    local mining_speed = self:getMiningSpeed()
    local mining_time = recipe_prototype:getMineableMiningTime()
    return mining_speed / mining_time
  elseif recipe.type == "fluid" then
    local pumping_speed = self:getPumpingSpeed()
    return pumping_speed
  elseif recipe.type == "technology" then
    local researching_speed = self:getResearchingSpeed()
    return researching_speed
  elseif recipe.type == "energy" then
    return 1
  else
    return self:getCraftingSpeed()
  end
end
-------------------------------------------------------------------------------
-- Return energy type (electric or burner)
--
-- @function [parent=#EntityPrototype] getEnergyType
--
-- @return #string default electric
--
function EntityPrototype:getEnergyType()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.burner_prototype ~= nil then return "burner" end
    if self.lua_prototype.electric_energy_source_prototype ~= nil then return "electric" end
    if self.lua_prototype.heat_energy_source_prototype ~= nil then return "heat" end
    if self.lua_prototype.fluid_energy_source_prototype ~= nil then return "fluid" end
    if self.lua_prototype.void_energy_source_prototype ~= nil then return "void" end
  end
  return "none"
end

-------------------------------------------------------------------------------
-- Return energy type (electric or burner)
--
-- @function [parent=#EntityPrototype] getEnergyType
--
-- @return #string default electric
--
function EntityPrototype:getEnergyTypeInput()
  if self.lua_prototype ~= nil then
    local fluid_usage = self:getFluidUsage()
    if fluid_usage > 0 then
      return "fluid"
    else
      local energy_source = self:getEnergySource()
      if energy_source ~= nil then
        local usage_priority = energy_source:getUsagePriority()
        if usage_priority ~= "secondary-output" and usage_priority ~= "solar" then
          return energy_source:getType()
        end
      end
    end
  end
  return "none"
end

-------------------------------------------------------------------------------
-- Return energy type (electric or burner)
--
-- @function [parent=#EntityPrototype] getEnergyType
--
-- @return #string default electric
--
function EntityPrototype:getEnergyTypeOutput()
  if self.lua_prototype ~= nil then
    if self:getType() == "reactor" then
      return "heat"
    end
    local energy_source = self:getEnergySource()
    if energy_source ~= nil then
      local usage_priority = energy_source:getUsagePriority()
      if usage_priority == "secondary-output" or usage_priority == "managed-accumulator" or usage_priority == "solar" then
        return energy_source:getType()
      end
    end
  end
  return "none"
end

-------------------------------------------------------------------------------
-- Return energy source
--
-- @function [parent=#EntityPrototype] getEnergySource
--
-- @return #EnergySourcePrototype
--
function EntityPrototype:getEnergySource()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.burner_prototype ~= nil then return BurnerPrototype(self.lua_prototype.burner_prototype, self.factory) end
    if self.lua_prototype.electric_energy_source_prototype ~= nil then return ElectricSourcePrototype(self.lua_prototype.electric_energy_source_prototype, self.factory) end
    if self.lua_prototype.heat_energy_source_prototype ~= nil then return HeatSourcePrototype(self.lua_prototype.heat_energy_source_prototype, self.factory) end
    if self.lua_prototype.fluid_energy_source_prototype ~= nil then return FluidSourcePrototype(self.lua_prototype.fluid_energy_source_prototype, self.factory) end
    if self.lua_prototype.void_energy_source_prototype ~= nil then return VoidSourcePrototype(self.lua_prototype.void_energy_source_prototype, self.factory) end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return mineable property hardness
--
-- @function [parent=#EntityPrototype] getMineableHardness
--
-- @return #number default 1
--
function EntityPrototype:getMineableHardness()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.hardness or 1
  end
  return 1
end

-------------------------------------------------------------------------------
-- Return mineable property mining time
--
-- @function [parent=#EntityPrototype] getMineableMiningTime
--
-- @return #number default 0.5
--
function EntityPrototype:getMineableMiningTime()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.mining_time or 0.5
  end
  return 0.5
end

-------------------------------------------------------------------------------
-- Return mineable property required fluid
--
-- @function [parent=#EntityPrototype] getMineableMiningFluidRequired
--
-- @return #string
--
function EntityPrototype:getMineableMiningFluidRequired()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.required_fluid
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return mineable property amount fluid
--
-- @function [parent=#EntityPrototype] getMineableMiningFluidAmount
--
-- @return #string
--
function EntityPrototype:getMineableMiningFluidAmount()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.fluid_amount/10
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return mineable property products
--
-- @function [parent=#EntityPrototype] getMineableMiningProducts
--
-- @return #string
--
function EntityPrototype:getMineableMiningProducts()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.products or {}
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return inventory size
--
-- @function [parent=#EntityPrototype] getInventorySize
--
-- @return #number default 0
--
function EntityPrototype:getInventorySize(index)
  if self.lua_prototype ~= nil then
    return self.lua_prototype.get_inventory_size(index or 1)
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid boxe prototypes
--
-- @function [parent=#EntityPrototype] getFluidboxPrototypes
--
-- @return #number default 0
--
function EntityPrototype:getFluidboxPrototypes()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluidbox_prototypes
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return fluidbox prototype
--
-- @function [parent=#EntityPrototype] getFluidboxPrototype
--
-- @return #FluidboxPrototype
--
function EntityPrototype:getFluidboxPrototype(production_type)
  if self.lua_prototype ~= nil then
    local fluidboxes = self:getFluidboxPrototypes()
    if fluidboxes ~= nil then
      if production_type == nil then production_type = "input-output" end
      for _,fluidbox in pairs(fluidboxes) do
        if fluidbox.production_type == production_type then
          return FluidboxPrototype(fluidbox)
        end
      end
    end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return inserter capacity
--
-- @function [parent=#EntityPrototype] getInserterCapacity
--
-- @return #number default 0
--
function EntityPrototype:getInserterCapacity()
  if self.lua_prototype ~= nil then
    local stack_bonus = 0
    if self.lua_prototype.stack == true then
      stack_bonus = Player.getForce().stack_inserter_capacity_bonus or 0
    else
      stack_bonus = Player.getForce().inserter_stack_size_bonus or 0
    end
    return 1 + stack_bonus
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return inserter rotation speed �/s
--
-- @function [parent=#EntityPrototype] getInserterRotationSpeed
--
-- @return #number default 0
--
function EntityPrototype:getInserterRotationSpeed()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.inserter_rotation_speed*60
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return belt speed
--
-- @function [parent=#EntityPrototype] getBeltSpeed
--
-- @return #number default 0
--
function EntityPrototype:getBeltSpeed()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.belt_speed or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return pollution
--
-- @function [parent=#EntityPrototype] getPollution
--
-- @return #number default 0
--
function EntityPrototype:getPollution()
  if self.lua_prototype ~= nil then
    local energy_usage = self:getEnergyConsumption()
    local energy_type = self:getEnergyTypeInput()
    local maximum_temperature = self:getMaximumTemperature()
    if energy_type == "electric" then
      energy_usage = self:getMaxEnergyUsage()
    end
    local emission_multiplier = 1
    local emission = 0
    local energy_prototype = self:getEnergySource()
    if energy_type == "fluid" and maximum_temperature > temperature_limit then
      local fluid_fuel = self:getFluidFuelPrototype()
      if fluid_fuel ~= nil then
        emission_multiplier = fluid_fuel:getEmissionMultiplier()
      end
    end
    if energy_prototype ~= nil then
      emission = energy_prototype:getEmissions()
    end
    return energy_usage * emission * emission_multiplier
  end
  return 0
end
