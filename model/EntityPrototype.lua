-------------------------------------------------------------------------------
---Description of the module.
---@class EntityPrototype : Prototype
---@field lua_prototype LuaEntityPrototype
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
---Return type
---@return string
function EntityPrototype:getType()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.type
end

-------------------------------------------------------------------------------
---Return Allowed Effects
---@return table
function EntityPrototype:getAllowedEffects()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.allowed_effects
end

-------------------------------------------------------------------------------
---Return Allowed Module Categories
---@return table
function EntityPrototype:getAllowedModuleCategories()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.allowed_module_categories
end

-------------------------------------------------------------------------------
---Return ingredient_count
---@return number
function EntityPrototype:getIngredientCount()
  return self.lua_prototype.ingredient_count or 255
end

-------------------------------------------------------------------------------
---Return energy usage per second
---@return number --default 0
function EntityPrototype:getEnergyUsage()
  if self.lua_prototype ~= nil and self.lua_prototype.energy_usage ~= nil then
    return self.lua_prototype.energy_usage*60
  end
  return 0
end

-------------------------------------------------------------------------------
---Return extract power of fluid (boiler) in J
---@param temperature number
---@param heat_capacity number
---@return number --default 0
function EntityPrototype:getPowerExtract(minimum_temperature, temperature, heat_capacity)
  if self.lua_prototype ~= nil and temperature ~= nil then
    if temperature < minimum_temperature then
      temperature = minimum_temperature
    end
    if heat_capacity == nil or heat_capacity == 0 then
      heat_capacity = 200
    end
    return (temperature - minimum_temperature) * heat_capacity
  end
  return 0
end

-------------------------------------------------------------------------------
---Return temperature energy of fluid_fuel in J
---@param fluid_fuel table
---@param maximum_temperature number
---@return number --default 0
function EntityPrototype:getTemperatureEnergy(fluid_fuel, maximum_temperature)
  if self.lua_prototype ~= nil then
    local heat_capacity = fluid_fuel:getHeatCapacity()
    local minimum_temperature = fluid_fuel:getMinimumTemperature()
    local temperature
    if not fluid_fuel.temperature then
      temperature = minimum_temperature
    elseif maximum_temperature > 0 then
      temperature = math.min(maximum_temperature, fluid_fuel.temperature)
    else
      temperature = fluid_fuel.temperature
    end
    
    return self:getPowerExtract(minimum_temperature, temperature, heat_capacity)
  end
  return 0
end

-------------------------------------------------------------------------------
---Return max energy usage per second
---@return number --default 0
function EntityPrototype:getMaxEnergyUsage()
  if self.lua_prototype ~= nil then
    local qualities = prototypes.quality
    local max_energy_usage = self.lua_prototype.get_max_energy_usage()
    return max_energy_usage * 60 / self:getEffectivity()
  end
  return 0
end

-------------------------------------------------------------------------------
---Return min energy usage per second
---@return number --default 0
function EntityPrototype:getMinEnergyUsage()
  local energy_prototype = self:getEnergySource()
  if energy_prototype ~= nil then
    return energy_prototype:getDrain()
  end
  return 0
end

-------------------------------------------------------------------------------
---Return nominal energy for generator
---@see https://wiki.factorio.com/Power_production
---@see https://wiki.factorio.com/Steam_engine
---@see https://wiki.factorio.com/Tutorial:Applied_power_math
---@return number --default 0
function EntityPrototype:getEnergyConsumption()
  if self.lua_prototype == nil then
    return 0
  end

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
    if energy_prototype ~= nil then
      max_energy_usage = max_energy_usage * energy_prototype:getSpeedModifier()
    end
    return max_energy_usage
  end

  if self.lua_prototype.type == "generator" then
    local fluid_usage = self:getFluidUsage()
    local effectivity = self:getEffectivity()
    local fluid_fuel = self:getFluidFuelPrototype()
    if fluid_fuel == nil then
      return 0
    end
    local fuel_value = fluid_fuel:getFuelValue()
    local max_energy_production = (self.lua_prototype.max_power_output or 0) * 60

    if self.lua_prototype.burns_fluid ~= true then
      ---Steam engine
      local maximum_temperature = self:getMaximumTemperature()
      fuel_value = self:getTemperatureEnergy(fluid_fuel, maximum_temperature)
    end

    return math.min(fluid_usage * fuel_value, max_energy_production / effectivity)
  end
  return 0
end

-------------------------------------------------------------------------------
---Return nominal energy for generator
---@see https://wiki.factorio.com/Power_production
---@see https://wiki.factorio.com/Steam_engine
---@see https://wiki.factorio.com/Tutorial:Applied_power_math
---@return number --default 0
function EntityPrototype:getEnergyProduction()
  if self.lua_prototype ~= nil then
    local energy_prototype = self:getElectricEnergySource()
    if energy_prototype ~= nil then
      local usage_priority = energy_prototype:getUsagePriority()
      local production
      if usage_priority == "managed-accumulator" then
        production = energy_prototype:getOutputFlowLimit()
      else
        production = (self.lua_prototype.max_power_output or 0) * 60
      end
      
      if self.lua_prototype.type == "generator" then
        local effectivity = self:getEffectivity()
        local fluid_fuel = self:getFluidFuelPrototype()
        if fluid_fuel ~= nil then
          local consumption = self:getFluidConsumption()
          local fuel_value
          if self:getBurnsFluid() == true then
            ---Fluid burning generator
            fuel_value = fluid_fuel:getFuelValue()
          else
            ---Steam engine
            local maximum_temperature = self:getMaximumTemperature()
            fuel_value = self:getTemperatureEnergy(fluid_fuel, maximum_temperature)
          end
          return consumption * fuel_value * effectivity
        end
        return production * effectivity
      else
        return production
      end
    elseif self.lua_prototype.type == "reactor" then
      local max_energy_usage = self:getMaxEnergyUsage()
      local effectivity = 1
      local energy_prototype = self:getEnergySource()
      if energy_prototype ~= nil then
        effectivity = energy_prototype:getEffectivity()
      end
      return max_energy_usage * effectivity
    end
  end
  return 0
end

local empty_effect ={
  consumption=0,
  speed=0,
  productivity=0,
  pollution=0,
  quality=0
}
-------------------------------------------------------------------------------
---Return base effect
---@return table
function EntityPrototype:getBaseEffect()
  if self.lua_prototype ~= nil and self.lua_prototype.effect_receiver ~= nil then
    return self.lua_prototype.effect_receiver.base_effect or empty_effect
  end
  return empty_effect
end

-------------------------------------------------------------------------------
---Return effectivity
---@return number --default 1
function EntityPrototype:getEffectivity()
  if self.lua_prototype ~= nil then
    local effectivity = self.lua_prototype.effectivity or 1
    local energy_prototype = self:getEnergySource()
    if energy_prototype ~= nil then
      effectivity = effectivity * energy_prototype:getEffectivity()
    end
    return effectivity
  end
  return 1
end

-------------------------------------------------------------------------------
---Return distribution effectivity
---@return number --default 1
function EntityPrototype:getDistributionEffectivity()
  if self.lua_prototype ~= nil then
    local distribution_effectivity = self.lua_prototype.distribution_effectivity or 1
    local distribution_effectivity_bonus_per_quality_level = self:getDistributionEffectivityBonusPerQualityLevel()
    local quality = Player.getQualityPrototype(self.factory.quality)
    local quality_level = 0
    if quality ~= nil then
      quality_level = quality.level
    end
    distribution_effectivity = distribution_effectivity + distribution_effectivity_bonus_per_quality_level * quality_level
    return distribution_effectivity
  end return 1
end

-------------------------------------------------------------------------------
---Return distribution effectivity
---@return number --default 1
function EntityPrototype:getDistributionEffectivityBonusPerQualityLevel()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.distribution_effectivity_bonus_per_quality_level or 0
  end
end
-------------------------------------------------------------------------------
---Return profile effectivity
---@return number --default 0
function EntityPrototype:getProfileEffectivity(profile_count)
  if self.lua_prototype ~= nil or profile_count == 0 then
    if profile_count > #self.lua_prototype.profile then
      return self.lua_prototype.profile[#self.lua_prototype.profile] or 1
    end
    return self.lua_prototype.profile[profile_count] or 1
  end
  return 1
end

-------------------------------------------------------------------------------
---Return maximum temperature
---@return number --default 0
function EntityPrototype:getMaximumTemperature()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.maximum_temperature or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return traget temperature
---@return number --default 0
function EntityPrototype:getTargetTemperature()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.target_temperature or 0
  end
  return 0
end

--------------------------------------------------------------------------------
---Return fluid capacity (container)
---@return number --default 0
function EntityPrototype:getFluidCapacity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluid_capacity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return fluid usage per tick
---@return number --default 0
function EntityPrototype:getFluidUsagePerTick()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluid_usage_per_tick or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return fluid usage
---@return number --default 0
function EntityPrototype:getFluidUsage()
  return self:getFluidUsagePerTick() * 60
end

-------------------------------------------------------------------------------
---Return fluid fuel prototype
---@return FluidPrototype
function EntityPrototype:getFluidFuelPrototype()
  if self:getEnergyTypeInput() ~= "fluid" then
    return nil
  end

  if self.factory ~= nil and self.factory.fuel ~= nil then
    local fuel_name = self.factory.fuel
    local fuel = nil
    if type(fuel_name) == "string" then
      fuel = FluidPrototype(fuel_name)
    else
      fuel = FluidPrototype(fuel_name.name)
      fuel:setTemperature(fuel_name.temperature)
    end
    return fuel
  end
  
  local energy_prototype = self:getEnergySource()
  if (energy_prototype ~= nil) and (energy_prototype:getType() == "fluid") then
    return energy_prototype:getFuelPrototype()
  end

  if self.lua_prototype.type == "generator" then
    local fluidboxes = self:getFluidboxPrototypes()
    if fluidboxes ~= nil then
      for _, fluidbox in pairs(fluidboxes) do
        if fluidbox.production_type == "input-output" or fluidbox.production_type == "input" then
          if fluidbox.filter ~= nil then
            if self.lua_prototype.burns_fluid == true then
              return FluidPrototype(fluidbox.filter)
            else
              local maximum_temperature = self:getMaximumTemperature()
              local fuels = Player.getFluidTemperaturePrototypes(fluidbox.filter)
              local first = nil
              for _, fuel in pairs(fuels) do
                if (first == nil) or ((first:getTemperature() < fuel:getTemperature()) and (fuel:getTemperature() <= maximum_temperature)) then
                  first = fuel
                end
              end
              return first
            end
          end
        end
      end

      -- No fluidbox filter found
      local fuels = Player.getFluidFuelPrototypes()
      local first = nil
      for _, fuel in pairs(fuels) do
        if (first == nil) or (first:getFuelValue() < fuel:getFuelValue()) then
          first = fuel
        end
      end
      return first
    end
  end

  return nil
end

-------------------------------------------------------------------------------
---Return fluid fuel prototype
---@return table of FluidPrototype
function EntityPrototype:getFluidFuelPrototypes()
  if self.lua_prototype == nil then
    return {}
  end
  
  local energy_prototype = self:getEnergySource()
  if energy_prototype:getType() == "fluid" then
    return energy_prototype:getFuelPrototypes()
  end

  if self.lua_prototype.type == "generator" then
    local fluidboxes = self:getFluidboxPrototypes()
    if fluidboxes ~= nil then
      for _, fluidbox in pairs(fluidboxes) do
        if fluidbox.production_type == "input-output" or fluidbox.production_type == "input" then
          if fluidbox.filter ~= nil then
            if self.lua_prototype.burns_fluid == true then
              return {FluidPrototype(fluidbox.filter)}
            else
              return Player.getFluidTemperaturePrototypes(fluidbox.filter)
            end
          end
        end
      end

      -- No fluidbox filter found
      return Player.getFluidFuelPrototypes()
    end
  end
  return {}
end

-------------------------------------------------------------------------------
---Return fluid consumption
---@return number --default 0
function EntityPrototype:getFluidConsumption()
  if self.lua_prototype ~= nil then
    local energy_type = self:getEnergyTypeInput()

    if self.lua_prototype.type == "generator" then

      local fluid_fuel = self:getFluidFuelPrototype()
      if fluid_fuel == nil then
        return 0
      end

      local max_fluid_usage = self:getFluidUsage()
      local max_energy_production = (self.lua_prototype.max_power_output or 0) * 60

      local fuel_value
      if self:getBurnsFluid() == true then
        ---Fluid burning generator
        fuel_value = fluid_fuel:getFuelValue()
      else
        ---Steam engine
        local maximum_temperature = self:getMaximumTemperature()
        fuel_value = self:getTemperatureEnergy(fluid_fuel, maximum_temperature)
      end

      ---Generators will only consume as much fluid as they need for max power output
      ---This is capped at max fluid usage
      ---Power output may be less than max if input fluid fuel value is very low
      local effectivity = self:getEffectivity()
      local consumption = max_energy_production / fuel_value / effectivity
      return math.min(max_fluid_usage, consumption)

    elseif energy_type == "fluid" then
      local fluid_fuel = self:getFluidFuelPrototype()
      if fluid_fuel == nil then
        return 0
      end
      local energy_prototype = self:getEnergySource()
      local energy_fluid_usage = energy_prototype:getFluidUsage()
      local fluid_burns = energy_prototype:getBurnsFluid()
      -- effectivity is already applied to energy_consumption
      -- getEnergyConsumption calls getMaxEnergyUsage
      local energy_consumption = self:getEnergyConsumption()
      local fuel_value = fluid_fuel:getFuelValue()

      if fluid_burns then
        ---si l'energy a du fluid usage en burns ca devient une limit
        ---if the energy source burns fluid and has fluid usage it becomes a limit
        if energy_fluid_usage > 0 then
          return math.min(energy_fluid_usage, energy_consumption / fuel_value)
        else
          return energy_consumption / fuel_value
        end
      else
        ---si l'energy a du fluid usage c'est forcement cette valeur
        ---if the energy source has fluid usage it must be this value
        if energy_fluid_usage > 0 then
          return energy_fluid_usage
        else
          local heat_capacity = fluid_fuel:getHeatCapacity()
          local minimum_temperature = fluid_fuel:getMinimumTemperature()
          local target_temperature = self:getTargetTemperature()
          
          local maximum_temperature = energy_prototype:getMaximumTemperature()
          if maximum_temperature > 0 then
            maximum_temperature = math.min(maximum_temperature, fluid_fuel.temperature)
          else
            maximum_temperature = fluid_fuel.temperature
          end
          
          if target_temperature > 0 then
            target_temperature = math.min(target_temperature, maximum_temperature)
          else
            target_temperature = maximum_temperature
          end

          local power_extract = self:getPowerExtract(minimum_temperature, target_temperature, heat_capacity)

          return energy_consumption / power_extract
        end
      end
      
    end
  end
  return 0
end

-------------------------------------------------------------------------------
---Return fluid production
---@return number --default 0
function EntityPrototype:getFluidProduction()
  if self:getType() == "offshore-pump" then

    return self:getPumpingSpeed()

  elseif self:getType() == "boiler" then

    local energy_prototype = self:getEnergySource()
    local effectivity
    if energy_prototype ~= nil then
      effectivity = energy_prototype:getEffectivity()
    else
      effectivity = 1
    end

    local fluidboxes = self:getFluidboxPrototypes()
    if fluidboxes ~= nil then
      for _, fluidbox in pairs(fluidboxes) do
        if fluidbox.production_type == "input-output" or fluidbox.production_type == "input" then

          local fluid_prototype = FluidPrototype(fluidbox.filter)
          local heat_capacity = fluid_prototype:getHeatCapacity()
          
          local minimum_temperature = fluid_prototype:getMinimumTemperature()
          local target_temperature = self:getTargetTemperature()
          local power_extract = self:getPowerExtract(minimum_temperature, target_temperature, heat_capacity)
          local energy_consumption = self:getEnergyConsumption()

          return (energy_consumption * effectivity) / power_extract
        end
      end
    end
  end

  return 0
end

-------------------------------------------------------------------------------
---Return fluid production filter
---@return LuaFluidPrototype
function EntityPrototype:getFluidProductionFilter()
  local fluidbox = self:getFluidboxPrototype("output")
  if fluidbox ~= nil then
    return fluidbox:getFilter()
  end
  return nil
end

-------------------------------------------------------------------------------
---Return fluid consumption filter
---@return LuaFluidPrototype
function EntityPrototype:getFluidConsumptionFilter()
  if self.lua_prototype ~= nil and self.lua_prototype.type == "boiler" then
    local fluidbox = self.lua_prototype.fluidbox_prototypes[1]
    if fluidbox ~= nil and fluidbox.filter ~= nil then
      return fluidbox.filter.name
    end
  end
  return nil
end

-------------------------------------------------------------------------------
---Return fuel
---@return table
function EntityPrototype:getFluel()
  if self.lua_prototype ~= nil then
    local energy_prototype = self:getEnergySource()
    local energy_type = self:getEnergyTypeInput()
    if energy_type == "fluid" then
      local fuel = self:getFluidFuelPrototype()
      if fuel ~= nil then
        return {name=fuel:native().name, type="fluid", temperature=fuel.temperature}
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
---Return module inventory size
---@return number --default 0
function EntityPrototype:getModuleInventorySize()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.module_inventory_size or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return crafting categories
---@return table
function EntityPrototype:getCraftingCategories()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.crafting_categories or {}
  end
  return {}
end

-------------------------------------------------------------------------------
---Return crafting speed
---@return number --default 0
function EntityPrototype:getCraftingSpeed()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.name == "character" then
      return Player.getCraftingSpeed()
    end

    local energy_prototype = self:getEnergySource()
    local speedModifier = energy_prototype:getSpeedModifier()

    return (self.lua_prototype.get_crafting_speed(self.factory.quality) or 1) * speedModifier
  end
  return 0
end

-------------------------------------------------------------------------------
---Return mining speed
---@return number --default 0
function EntityPrototype:getMiningSpeed()
  if self.lua_prototype ~= nil then
    return (self.lua_prototype.mining_speed or 0) * self:getSpeedModifier()
  end
  return 0
end

-------------------------------------------------------------------------------
---Return neighbour bonus
---@return number --default 0
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
---Return researching speed
---@return number --default 0
function EntityPrototype:getResearchingSpeed()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.get_researching_speed(self.factory.quality) or 1
  end
  return 0
end

-------------------------------------------------------------------------------
---Return pumping speed
---@return number --default 0
function EntityPrototype:getPumpingSpeed()
  if self.lua_prototype ~= nil then
    return (self.lua_prototype.pumping_speed or 0)*60 
  end
  return 0
end

-------------------------------------------------------------------------------
---Return speed factory for recipe
---@return number
function EntityPrototype:speedFactory(recipe)
  if self.lua_prototype and self.lua_prototype.type == "boiler" then
    ---@see https://wiki.factorio.com/Boiler
    ---info energy 1J=1W
    return 1
  elseif recipe.type == "resource" then
    ---(mining power - ore mining hardness) * mining speed
    ---@see https://wiki.factorio.com/Mining
    ---hardness removed
    ---@see https://www.factorio.com/blog/post/fff-266
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
    return self:getSpeedModifier()
  elseif recipe.type == "agricultural" then
    local growth_grid_tile_size = self.lua_prototype.growth_grid_tile_size or 3
    local tile_width = self.lua_prototype.tile_width or 3
    local tile_height = self.lua_prototype.tile_height or 3
    local machine_area = tile_width*tile_height
    local logistic_area = 9 -- area necessary for input/output and power
    local max_grid_tile_size = 21
    local max_area = max_grid_tile_size * max_grid_tile_size
    local growing_area = growth_grid_tile_size * growth_grid_tile_size
    local growable_area = max_area - machine_area - logistic_area
    local speed = growable_area/growing_area
    return speed
  else
    return self:getCraftingSpeed()
  end
end
-------------------------------------------------------------------------------
---Return energy type (electric or burner)
---@return string
function EntityPrototype:getEnergyType()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.burner_prototype ~= nil then return "burner" end
    if self.lua_prototype.heat_energy_source_prototype ~= nil then return "heat" end
    if self.lua_prototype.fluid_energy_source_prototype ~= nil then return "fluid" end
    if self.lua_prototype.void_energy_source_prototype ~= nil then return "void" end
    if self.lua_prototype.electric_energy_source_prototype ~= nil then return "electric" end
  end
  return "none"
end

-------------------------------------------------------------------------------
---Return energy type (electric or burner)
---@return string
function EntityPrototype:getEnergyTypeInput()
  if self.lua_prototype ~= nil then
    local fluid_usage = self:getFluidUsage()
    if fluid_usage > 0 then
      return "fluid"
    else
      local energy_prototype = self:getEnergySource()
      if energy_prototype ~= nil then
        local usage_priority = energy_prototype:getUsagePriority()
        if usage_priority ~= "secondary-output" and usage_priority ~= "solar" then
          return energy_prototype:getType()
        end
      end
    end
  end
  return "none"
end

-------------------------------------------------------------------------------
---Return energy type (electric or burner)
---@return string
function EntityPrototype:getEnergyTypeOutput()
  if self.lua_prototype ~= nil then
    if self:getType() == "reactor" then
      return "heat"
    end
    local energy_prototype = self:getElectricEnergySource()
    if energy_prototype ~= nil then
      local usage_priority = energy_prototype:getUsagePriority()
      if usage_priority == "secondary-output" or usage_priority == "managed-accumulator" or usage_priority == "solar" then
        return energy_prototype:getType()
      end
    end
  end
  return "none"
end

-------------------------------------------------------------------------------
---Return energy source
---@return EnergySourcePrototype
function EntityPrototype:getEnergySource()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.burner_prototype ~= nil then return BurnerPrototype(self.lua_prototype.burner_prototype, self.factory) end
    if self.lua_prototype.heat_energy_source_prototype ~= nil then return HeatSourcePrototype(self.lua_prototype.heat_energy_source_prototype, self.factory) end
    if self.lua_prototype.fluid_energy_source_prototype ~= nil then return FluidSourcePrototype(self.lua_prototype.fluid_energy_source_prototype, self.factory) end
    if self.lua_prototype.void_energy_source_prototype ~= nil then return VoidSourcePrototype(self.lua_prototype.void_energy_source_prototype, self.factory) end
    if self.lua_prototype.electric_energy_source_prototype ~= nil then return self:getElectricEnergySource() end
  end
  return nil
end

-------------------------------------------------------------------------------
---Return mineable property hardness
---@return number --default 1
function EntityPrototype:getMineableHardness()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.hardness or 1
  end
  return 1
end

-------------------------------------------------------------------------------
---Return mineable property mining time
---@return number --default 0.5
function EntityPrototype:getMineableMiningTime()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.mining_time or 0.5
  end
  return 0.5
end

-------------------------------------------------------------------------------
---Return mineable property required fluid
---@return string
function EntityPrototype:getMineableMiningFluidRequired()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.required_fluid
  end
  return nil
end

-------------------------------------------------------------------------------
---Return mineable property amount fluid
---@return number --default 0
function EntityPrototype:getMineableMiningFluidAmount()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.fluid_amount/10
  end
  return 0
end

-------------------------------------------------------------------------------
---Return mineable property products
---@return table
function EntityPrototype:getMineableMiningProducts()
  if self.lua_prototype ~= nil and self.lua_prototype.mineable_properties ~= nil then
    return self.lua_prototype.mineable_properties.products or {}
  end
  return {}
end

-------------------------------------------------------------------------------
---Return inventory size
---@return number --default 0
function EntityPrototype:getInventorySize(index)
  if self.lua_prototype ~= nil then
    return self.lua_prototype.get_inventory_size(index or 1)
  end
  return 0
end

-------------------------------------------------------------------------------
---Return fluid boxe prototypes
---@return number --default 0
function EntityPrototype:getFluidboxPrototypes()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluidbox_prototypes
  end
  return nil
end

-------------------------------------------------------------------------------
---Return fluidbox prototype
---@return FluidboxPrototype
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
---Return inserter capacity
---@return number --default 0
function EntityPrototype:getInserterCapacity()
  if self.lua_prototype ~= nil then
    local stack_bonus = 0
    if self.lua_prototype.bulk == true then
      stack_bonus = Player.getForce().bulk_inserter_capacity_bonus or 0
    else
      stack_bonus = Player.getForce().inserter_stack_size_bonus or 0
    end
    return 1 + stack_bonus
  end
  return 0
end

-------------------------------------------------------------------------------
---Return inserter rotation speed /s
---@return number --default 0
function EntityPrototype:getInserterRotationSpeed()
  if self.lua_prototype ~= nil then
    local rotation_speed = self.lua_prototype.get_inserter_rotation_speed()
    return rotation_speed*60
  end
  return 0
end

-------------------------------------------------------------------------------
---Return belt speed
---@return number --default 0
function EntityPrototype:getBeltSpeed()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.belt_speed or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return pollution
---@return number --default 0
function EntityPrototype:getPollution()
  if self.lua_prototype ~= nil then

    local energy_usage
    local energy_type = self:getEnergyTypeInput()
    if energy_type == "electric" then
      energy_usage = self:getMaxEnergyUsage()
    else
      energy_usage = self:getEnergyConsumption()
    end

    local energy_prototype = self:getEnergySource()
    local emission_multiplier = 1
    local emission = 1

    if energy_prototype ~= nil then
      local fuel
      if (energy_type == "fluid") and (self:getBurnsFluid() == true) then
        fuel = self:getFluidFuelPrototype()
      elseif energy_type == "burner" then
        fuel = energy_prototype:getFuelPrototype()
      end

      if fuel ~= nil then
        emission_multiplier = fuel:getFuelEmissionsMultiplier()
      end
      local emissions = energy_prototype:getEmissions()
      local emission_pollution = emissions["pollution"] or 2.7777777e-7
      emission = emission_pollution * self:getEffectivity()
    end

    return energy_usage * emission * emission_multiplier
  end

  return 0
end

-------------------------------------------------------------------------------
---Return speed modifier
---@return number --default 1
function EntityPrototype:getSpeedModifier()
  if self.lua_prototype == nil then
    return 1
  end
  
  local energy_prototype = self:getEnergySource()
  if (energy_prototype ~= nil) and (energy_prototype:getType() == "fluid") then
    return energy_prototype:getSpeedModifier()
  end

  return 1
end

-------------------------------------------------------------------------------
---Return electric energy source
---@return ElectricSourcePrototype --default nil
function EntityPrototype:getElectricEnergySource()
  if self.lua_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype ~= nil then
    return ElectricSourcePrototype(self.lua_prototype.electric_energy_source_prototype, self.factory)
  end
  return nil
end

-------------------------------------------------------------------------------
---Return burns fluid
---@return boolean
function EntityPrototype:getBurnsFluid()
  if self.lua_prototype ~= nil and self.lua_prototype.type == "generator" then
    return self.lua_prototype.burns_fluid
  elseif self:getEnergyType() == "fluid" then
    local energy_prototype = self:getEnergySource()
    if energy_prototype ~= nil then
      return energy_prototype:getBurnsFluid()
    end
  end
  return nil
end
