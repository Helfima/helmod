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
    if heat_capacity == nil then
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
    local energy_type = self:getEnergyTypeInput()
    if self.lua_prototype.type == "reactor" or energy_type == "heat" then
      return self:getMaxEnergyUsage()
    end
    if self.lua_prototype.type == "generator" then
      local fluid_usage = self:getFluidUsagePerTick() * 60
      local effectivity = self:getEffectivity()
      local maximum_temperature = self:getMaximumTemperature()
      local power_extract = self:getPowerExtract(maximum_temperature)
      -- [boiler.fluid_usage]x[boiler.fluid_usage]x[boiler.target_temperature]-15°c)x[200J/unit/°]
      return fluid_usage * effectivity * power_extract
    end
    -- if self.lua_prototype.type == "solar-panel" and self.lua_prototype.production ~= nil then
    --   return self.lua_prototype.production*60 or 0
    -- end
    if self.lua_prototype.type == "accumulator" then
      local energy_prototype = self:getEnergySource()
      return energy_prototype:getInputFlowLimit()
    end
    -- if energy_type == "heat" then
    --   local fluid_usage = self:getFluidUsagePerTick() * 60
    --   local effectivity = self:getEffectivity()
    --   local target_temperature = self:getTargetTemperature()
    --   local power_extract = self:getPowerExtract(maximum_temperature)
    --   return fluid_usage * effectivity * power_extract
    -- end
    local drain = 0
    if energy_type == "electric" then
      local energy_prototype = self:getEnergySource()
      if energy_prototype ~= nil then
        drain = energy_prototype:getDrain()
      end
    end
    return drain + self:getMaxEnergyUsage()
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
    local usage_priority = energy_prototype:getUsagePriority()
    if usage_priority == "solar" then
      return (self.lua_prototype.production or 0)*60
    end
    if usage_priority == "secondary-output" then
      if self:getEnergyTypeInput() == "fluid" then
        local fluid_usage = self:getFluidUsage()
        local effectivity = self:getEffectivity()
        local maximum_temperature = self:getMaximumTemperature()
        local power_extract = self:getPowerExtract(maximum_temperature)
        -- [boiler.fluid_usage]x[boiler.fluid_usage]x[boiler.target_temperature]-15°c)x[200J/unit/°]
        return fluid_usage * effectivity * power_extract
      end
    end
    if usage_priority == "managed-accumulator" then
      return energy_prototype:getOutputFlowLimit()
    end
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
function EntityPrototype:getFluidFuelPrototype()
  if self:getEnergyTypeInput() == "fluid" then
    if self:getFluidUsage() > 0 then
      local fluidboxes = self:getFluidboxPrototypes()
      if fluidboxes ~= nil then
        for _,fluidbox in pairs(fluidboxes) do
          if fluidbox.production_type == "input-output" then
            return FluidPrototype(fluidbox.filter)
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
    if fluid_usage > 0 then
      return fluid_usage
    end
    local energy_type = self:getEnergyTypeInput()
    if energy_type == "fluid" then
      local energy_source = self:getEnergySource()
      fluid_usage = energy_source:getFluidUsage()
      if fluid_usage > 0 then
        return fluid_usage
      else
        local fluid_fuel = self:getFluidFuelPrototype()
        local fluel_value = fluid_fuel:getFuelValue()
        local effectivity = self:getEffectivity()
        local energy_consumption = self:getEnergyConsumption()
        return energy_consumption / (effectivity * fluel_value)
      end
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid consumption
--
-- @function [parent=#EntityPrototype] getFluidConsumption
--
-- @return #number default 0
--
function EntityPrototype:getFluidConsumption2()
  if self.lua_prototype ~= nil then
    local energy_type = self:getEnergyType()
    if energy_type == "heat" then
      -- @see https://wiki.factorio.com/Heat_exchanger
      local energy_consumption = self:getEnergyConsumption()
      local max_energy_usage = self:getMaxEnergyUsage()
      return 60 * max_energy_usage / energy_consumption
    end
    if self:getType() == "boiler" then
      return self:getWaterConsumption()
    end
    if energy_type == "fluid" then
      local effectivity = self:getEffectivity()
      local maximum_temperature = self:getMaximumTemperature()
      local power_extract = self:getPowerExtract(maximum_temperature)
      -- [boiler.fluid_usage]x[boiler.target_temperature]-15°c)x[200J/unit/°]
      local max_energy_usage = self:getMaxEnergyUsage()
      return max_energy_usage / (effectivity * power_extract)
    end
    return self:getFluidUsage()
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
    if self:getType() == "boiler" then
      local effectivity = self:getEffectivity()
      local target_temperature = self:getTargetTemperature()
      local power_extract = self:getPowerExtract(target_temperature)
      local energy_consumption = self:getEnergyConsumption()
      return energy_consumption / (effectivity * power_extract)
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fluid production prototype
--
-- @function [parent=#EntityPrototype] getFluidProductionPrototype
--
-- @return #LuaFluidPrototype
--
function EntityPrototype:getFluidProductionPrototype()
  local fluidbox = self:getFluidboxPrototype("output")
  if fluidbox ~= nil then
    return fluidbox:getFilter()
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
    local power_extract = self:getPowerExtract()
    local power_usage = self:getEnergyConsumption()
    return power_usage/power_extract
  elseif recipe.type == "resource" then
    -- (mining power - ore mining hardness) * mining speed
    -- @see https://wiki.factorio.com/Mining
    local recipe_prototype = EntityPrototype(recipe.name)
    local mining_speed = self:getMiningSpeed()
    local hardness = recipe_prototype:getMineableHardness()
    local mining_time = recipe_prototype:getMineableMiningTime()
    return hardness * mining_speed / mining_time
  elseif recipe.type == "fluid" then
    -- @see https://wiki.factorio.com/Power_production
    local pumping_speed = self:getPumpingSpeed()
    return pumping_speed
  elseif recipe.type == "technology" then
    local bonus = Player.getForce().laboratory_speed_modifier or 1
    return 1*bonus
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
    if not(FactorioV017) then
      if self.lua_prototype.burner_prototype ~= nil then return "burner" end
      if self.lua_prototype.electric_energy_source_prototype ~= nil then return "electric" end
      if self.lua_prototype.heat_energy_source_prototype ~= nil then return "heat" end
      if self.lua_prototype.fluid_energy_source_prototype ~= nil then return "fluid" end
      if self.lua_prototype.void_energy_source_prototype ~= nil then return "void" end
    else
      -- adaptation pour Factorio V0.17
      if self.lua_prototype.burner_prototype ~= nil then return "burner" end
      if self.lua_prototype.electric_energy_source_prototype ~= nil then return "electric" end
      if self:getType() == "reactor" or (self:getType() == "boiler" and string.find(self.lua_prototype.name,"heat")) then return "heat" end
      if self:getMaxEnergyUsage() > 0 then
        return "fluid"
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
    if not(FactorioV017) then
      if self.lua_prototype.burner_prototype ~= nil then return BurnerPrototype(self.lua_prototype.burner_prototype, self.factory) end
      if self.lua_prototype.electric_energy_source_prototype ~= nil then return ElectricSourcePrototype(self.lua_prototype.electric_energy_source_prototype, self.factory) end
      if self.lua_prototype.heat_energy_source_prototype ~= nil then return HeatSourcePrototype(self.lua_prototype.heat_energy_source_prototype, self.factory) end
      if self.lua_prototype.fluid_energy_source_prototype ~= nil then return FluidSourcePrototype(self.lua_prototype.fluid_energy_source_prototype, self.factory) end
      if self.lua_prototype.void_energy_source_prototype ~= nil then return VoidSourcePrototype(self.lua_prototype.void_energy_source_prototype, self.factory) end
    else
      -- adaptation pour Factorio V0.17
      if self.lua_prototype.burner_prototype ~= nil then return BurnerPrototype(self.lua_prototype.burner_prototype, self.factory) end
      if self.lua_prototype.electric_energy_source_prototype ~= nil then return ElectricSourcePrototype(self.lua_prototype.electric_energy_source_prototype, self.factory) end
      if self:getType() == "reactor" or (self:getType() == "boiler" and string.find(self.lua_prototype.name,"heat")) then
        return HeatSourcePrototype({emissions=0}, self.factory)
      end
      if self:getMaxEnergyUsage() > 0 then
        return FluidSourcePrototype({emissions=5.5555e-7}, self.factory)
      end
    end
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
    if energy_type == "electric" then
      energy_usage = self:getMaxEnergyUsage()
    end
    local emission_multiplier = 1
    local emission = 0
    local energy_prototype = self:getEnergySource()
    if energy_type == "fluid" then
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
