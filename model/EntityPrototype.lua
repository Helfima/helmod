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
  base.classname = "HMEntityPrototype"
end)

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
-- @return #number default 0
--
function EntityPrototype:getPowerExtract()
  if self.lua_prototype ~= nil and self.lua_prototype.target_temperature ~= nil then
    -- [boiler.target_temperature]-15°c)x[200J/unit/°]
    return (self.lua_prototype.target_temperature-15)*200
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
-- @function [parent=#EntityPrototype] getEnergyNominal
--
-- @return #number default 0
--
function EntityPrototype:getEnergyNominal()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.type == EntityType.generator then
      local fluid_usage = self:getFluidUsagePerTick()
      local effectivity = self:getEffectivity()
      local maximum_temperature = self:getMaximumTemperature()
      -- formula energy_nominal = fluid_usage * 60_tick * effectivity * (target_temperature - nominal_temp) * 1000 / 5
      -- @see https://wiki.factorio.com/Liquids/Hot
      return fluid_usage*60*effectivity*(maximum_temperature-15)*1000/5
    end
    if self.lua_prototype.type == EntityType.boiler then
      return self:getMaxEnergyUsage()
    end
    if self.lua_prototype.type == EntityType.solar_panel and self.lua_prototype.production ~= nil then
      return self.lua_prototype.production*60 or 0
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
-- Return energy type (electrical or burner)
--
-- @function [parent=#EntityPrototype] getEnergyType
--
-- @return #string default electrical
--
function EntityPrototype:getEnergyType()
  if self.lua_prototype ~= nil and self.lua_prototype.burner_prototype ~= nil then return "burner" end
  return "electrical"
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
-- Return electric energy source prototype buffer capacity
--
-- @function [parent=#EntityPrototype] getElectricBufferCapacity
--
-- @return #number default 0
--
function EntityPrototype:getElectricBufferCapacity()
  if self.lua_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype ~= nil then
    return self.lua_prototype.electric_energy_source_prototype.buffer_capacity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype input flow limit
--
-- @function [parent=#EntityPrototype] getElectricInputFlowLimit
--
-- @return #number default 0
--
function EntityPrototype:getElectricInputFlowLimit()
  if self.lua_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype.input_flow_limit~= nil then
    return self.lua_prototype.electric_energy_source_prototype.input_flow_limit*60 or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype output flow limit
--
-- @function [parent=#EntityPrototype] getElectricOutputFlowLimit
--
-- @return #number default 0
--
function EntityPrototype:getElectricOutputFlowLimit()
  if self.lua_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype.output_flow_limit~= nil then
    return self.lua_prototype.electric_energy_source_prototype.output_flow_limit*60 or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype emissions
--
-- @function [parent=#EntityPrototype] getElectricEmissions
--
-- @return #number default 0
--
function EntityPrototype:getElectricEmissions()
  if self.lua_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype ~= nil then
    return self.lua_prototype.electric_energy_source_prototype.emissions or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype effectivity
--
-- @function [parent=#EntityPrototype] getElectricEffectivity
--
-- @return #number default 0
--
function EntityPrototype:getElectricEffectivity()
  if self.lua_prototype ~= nil and self.lua_prototype.electric_energy_source_prototype ~= nil then
    return self.lua_prototype.effectivity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return burner prototype
--
-- @function [parent=#EntityPrototype] getBurnerPrototype
--
-- @return #BurnerPrototype
--
function EntityPrototype:getBurnerPrototype()
  if self.lua_prototype ~= nil then
    return BurnerPrototype(self.lua_prototype.burner_prototype)
  end
  return BurnerPrototype()
end

-------------------------------------------------------------------------------
-- Return burner prototype effectivity
--
-- @function [parent=#EntityPrototype] getBurnerEffectivity
--
-- @return #number default 0
--
function EntityPrototype:getBurnerEffectivity()
  if self.lua_prototype ~= nil and self.lua_prototype.burner_prototype ~= nil then
    return self.lua_prototype.burner_prototype.effectivity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return burner energy source prototype emissions
--
-- @function [parent=#EntityPrototype] getBurnerEmissions
--
-- @return #number default 0
--
function EntityPrototype:getBurnerEmissions()
  if self.lua_prototype ~= nil and self.lua_prototype.burner_prototype ~= nil then
    return self.lua_prototype.burner_prototype.emissions or 1
  end
  return 0
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
    local energy_usage = self:getEnergyUsage()
    local emission = self:getElectricEmissions()
    if self:getBurnerEmissions() ~= 0 then
      emission = self:getBurnerEmissions()
    end
    return energy_usage * emission * 60
  end
  return 0
end
