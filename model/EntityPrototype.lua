---
-- Description of the module.
-- @module EntityPrototype
--
local EntityPrototype = {
  -- single-line comment
  classname = "HMEntityPrototype"
}

local lua_entity_prototype = nil

-------------------------------------------------------------------------------
-- Load factorio player
--
-- @function [parent=#EntityPrototype] load
--
-- @param #object object prototype
--
-- @return #EntityPrototype
--
function EntityPrototype.load(object)
  if object ~= nil and type(object) == "string" then
    lua_entity_prototype = Player.getEntityPrototype(object)
  elseif object ~= nil and object.name ~= nil then
    lua_entity_prototype = Player.getEntityPrototype(object.name)
  end
  return EntityPrototype
end

-------------------------------------------------------------------------------
-- Return factorio player
--
-- @function [parent=#EntityPrototype] native
--
-- @return #lua_entity_prototype
--
function EntityPrototype.native()
  return lua_entity_prototype
end

-------------------------------------------------------------------------------
-- Return type
--
-- @function [parent=#EntityPrototype] getType
--
-- @return #string
--
function EntityPrototype.getType()
  if lua_entity_prototype == nil then return nil end
  return lua_entity_prototype.type
end

-------------------------------------------------------------------------------
-- Return ingredient_count
--
-- @function [parent=#EntityPrototype] getIngredientCount
--
-- @return #number
--
function EntityPrototype.getIngredientCount()
  return lua_entity_prototype.ingredient_count or 6
end

-------------------------------------------------------------------------------
-- Return valid
--
-- @function [parent=#EntityPrototype] getValid
--
-- @return #boolean
--
function EntityPrototype.getValid()
  if lua_entity_prototype == nil then return false end
  return lua_entity_prototype.valid
end

-------------------------------------------------------------------------------
-- Return energy usage per second
--
-- @function [parent=#EntityPrototype] getEnergyUsage
--
-- @return #number default 0
--
function EntityPrototype.getEnergyUsage()
  if lua_entity_prototype ~= nil and lua_entity_prototype.energy_usage ~= nil then
    return lua_entity_prototype.energy_usage*60
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
function EntityPrototype.getPowerExtract()
  if lua_entity_prototype ~= nil and lua_entity_prototype.target_temperature ~= nil then
    -- [boiler.target_temperature]-15°c)x[200J/unit/°]
    return (lua_entity_prototype.target_temperature-15)*200
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
function EntityPrototype.getMaxEnergyUsage()
  if lua_entity_prototype ~= nil and lua_entity_prototype.max_energy_usage ~= nil then
    return lua_entity_prototype.max_energy_usage*60
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
function EntityPrototype.getEnergyNominal()
  if lua_entity_prototype ~= nil then
    if lua_entity_prototype.type == EntityType.generator then
      local fluid_usage = EntityPrototype.getFluidUsagePerTick()
      local effectivity = EntityPrototype.getEffectivity()
      local maximum_temperature = EntityPrototype.getMaximumTemperature()
      -- formula energy_nominal = fluid_usage * 60_tick * effectivity * (target_temperature - nominal_temp) * 1000 / 5
      -- @see https://wiki.factorio.com/Liquids/Hot
      return fluid_usage*60*effectivity*(maximum_temperature-15)*1000/5
    end
    if lua_entity_prototype.type == EntityType.boiler then
      return EntityPrototype.getMaxEnergyUsage()
    end
    if lua_entity_prototype.type == EntityType.solar_panel and lua_entity_prototype.production ~= nil then
      return lua_entity_prototype.production*60 or 0
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#EntityPrototype] getLocalisedName
--
-- @return #number default 0
--
function EntityPrototype.getLocalisedName()
  if lua_entity_prototype ~= nil then
    if Player.getSettings("display_real_name", true) then
      return lua_entity_prototype.name
    end
    return lua_entity_prototype.localised_name
  end
  return "unknow"
end


-------------------------------------------------------------------------------
-- Return effectivity
--
-- @function [parent=#EntityPrototype] getEffectivity
--
-- @return #number default 1
--
function EntityPrototype.getEffectivity()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.effectivity or 1
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
function EntityPrototype.getDistributionEffectivity()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.distribution_effectivity or 1
  end return 1
end

-------------------------------------------------------------------------------
-- Return maximum temperature
--
-- @function [parent=#EntityPrototype] getMaximumTemperature
--
-- @return #number default 0
--
function EntityPrototype.getMaximumTemperature()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.maximum_temperature or 0
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
function EntityPrototype.getTargetTemperature()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.target_temperature or 0
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
function EntityPrototype.getFluidUsagePerTick()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.fluid_usage_per_tick or 0
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
function EntityPrototype.getModuleInventorySize()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.module_inventory_size or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return crafting speed
--
-- @function [parent=#EntityPrototype] getCraftingSpeed
--
-- @return #number default 0
--
function EntityPrototype.getCraftingSpeed()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.crafting_speed or 0
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
function EntityPrototype.getMiningSpeed()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.mining_speed or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return mining power
--
-- @function [parent=#EntityPrototype] getMiningPower
--
-- @return #number default 0
--
function EntityPrototype.getMiningPower()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.mining_power or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return energy type
--
-- @function [parent=#EntityPrototype] getEnergyType
--
-- @return #string default electrical
--
function EntityPrototype.getEnergyType()
  if lua_entity_prototype ~= nil and lua_entity_prototype.burner_prototype ~= nil then return "burner" end
  return "electrical"
end

-------------------------------------------------------------------------------
-- Return mineable property hardness
--
-- @function [parent=#EntityPrototype] getMineableHardness
--
-- @return #number default 1
--
function EntityPrototype.getMineableHardness()
  if lua_entity_prototype ~= nil and lua_entity_prototype.mineable_properties ~= nil then
    return lua_entity_prototype.mineable_properties.hardness or 1
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
function EntityPrototype.getMineableMiningTime()
  if lua_entity_prototype ~= nil and lua_entity_prototype.mineable_properties ~= nil then
    return lua_entity_prototype.mineable_properties.mining_time or 0.5
  end
  return 0.5
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype buffer capacity
--
-- @function [parent=#EntityPrototype] getElectricBufferCapacity
--
-- @return #number default 0
--
function EntityPrototype.getElectricBufferCapacity()
  if lua_entity_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.buffer_capacity or 0
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
function EntityPrototype.getElectricInputFlowLimit()
  if lua_entity_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype.input_flow_limit~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.input_flow_limit*60 or 0
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
function EntityPrototype.getElectricOutputFlowLimit()
  if lua_entity_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype.output_flow_limit~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.output_flow_limit*60 or 0
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
function EntityPrototype.getElectricEmissions()
  if lua_entity_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.emissions or 0
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
function EntityPrototype.getElectricEffectivity()
  if lua_entity_prototype ~= nil and lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.effectivity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return burner prototype effectivity
--
-- @function [parent=#EntityPrototype] getBurnerEffectivity
--
-- @return #number default 0
--
function EntityPrototype.getBurnerEffectivity()
  if lua_entity_prototype ~= nil and lua_entity_prototype.burner_prototype ~= nil then
    return lua_entity_prototype.burner_prototype.effectivity or 0
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
function EntityPrototype.getInventorySize(index)
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.get_inventory_size(index or 1)
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
function EntityPrototype.getFluidCapacity()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.fluid_capacity or 0
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
function EntityPrototype.getBeltSpeed()
  if lua_entity_prototype ~= nil then
    return lua_entity_prototype.belt_speed or 0
  end
  return 0
end

return EntityPrototype
