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
--
-- @return #number default 0
--
function EntityPrototype:getPowerExtract(temperature)
  if self.lua_prototype ~= nil then
    -- @see https://wiki.factorio.com/Heat_exchanger
    local target_temperature = temperature or 165
    if self.lua_prototype.target_temperature ~= nil then
      target_temperature = math.min(target_temperature , self.lua_prototype.target_temperature)
    end
    -- [boiler.target_temperature]-15°c)x[200J/unit/°]
    return (target_temperature-15)*200
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
-- Return nominal energy for generator
-- @see https://wiki.factorio.com/Power_production
-- @see https://wiki.factorio.com/Liquids/Hot
--
-- @function [parent=#EntityPrototype] getEnergyConsumption
--
-- @return #number default 0
--
function EntityPrototype:getEnergyConsumption()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.type == EntityType.generator then
      local fluid_usage = self:getFluidUsagePerTick()
      local effectivity = self:getEffectivity()
      local maximum_temperature = self:getMaximumTemperature()
      -- formula energy_nominal = fluid_usage * 60_tick * effectivity * (target_temperature - nominal_temp) * 1000 / 5
      -- @see https://wiki.factorio.com/Liquids/Hot
      return fluid_usage*60*effectivity*(maximum_temperature-15)*1000/5
    end
    if self.lua_prototype.type == EntityType.solar_panel and self.lua_prototype.production ~= nil then
      return self.lua_prototype.production*60 or 0
    end
    local energy_type = self:getEnergyType()
    if energy_type == "burner" or energy_type == "fluid" then
      --return self:getFuelValue()
    end
    
    return self:getMaxEnergyUsage()
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return fuel value
--
-- @function [parent=#EntityPrototype] getFuelValue
--
-- @return #boolean
--
function EntityPrototype:getFuelValue()
  local energy_prototype = self:getEnergySource()
  local factory_fuel = energy_prototype:getFuelPrototype()
  if factory_fuel ~= nil then
    local temperature = self.factory.target_temperature or self.lua_prototype.target_temperature
    local fuel_value = factory_fuel:getFuelValue(temperature)
    return fuel_value
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

-------------------------------------------------------------------------------
-- Return fluid usage per tick
--
-- @function [parent=#EntityPrototype] getFluidUsagePerTick
--
-- @return #number default 0
--
function EntityPrototype:getFluidUsagePerTick()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluid_usage_per_tick or 1
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
function EntityPrototype:getFluidConsumption()
  if self.lua_prototype ~= nil then
    return self:getFluidUsagePerTick()*60
  end
  return 0
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
  return "electric"
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
-- Return fluid capacity
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
-- Return inserter rotation speed °/s
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
    local emission = 0
    local energy_prototype = self:getEnergySource()
    if energy_prototype ~= nil then
      emission = energy_prototype:getEmissions()
    end
    return energy_usage * emission
  end
  return 0
end
