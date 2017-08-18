---
-- Description of the module.
-- @module EntityPrototype
--
local EntityPrototype = {
  -- single-line comment
  classname = "EntityPrototype"
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
-- @function [parent=#EntityPrototype] type
--
-- @return #string
--
function EntityPrototype.type()
  if lua_entity_prototype == nil then return nil end
  return lua_entity_prototype.type
end

-------------------------------------------------------------------------------
-- Return energy usage per second
--
-- @function [parent=#EntityPrototype] energyUsage
--
-- @return #number default 0
--
function EntityPrototype.energyUsage()
  if lua_entity_prototype.energy_usage ~= nil then
    return lua_entity_prototype.energy_usage*60
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return max energy usage per second
--
-- @function [parent=#EntityPrototype] maxEnergyUsage
--
-- @return #number default 0
--
function EntityPrototype.maxEnergyUsage()
  if lua_entity_prototype.max_energy_usage ~= nil then
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
  if lua_entity_prototype.type == EntityType.generator then
    local fluid_usage = EntityPrototype.fluidUsagePerTick()
    local effectivity = EntityPrototype.effectivity()
    local maximum_temperature = EntityPrototype.maximumTemperature()
    -- formula energy_nominal = fluid_usage * 60_tick * effectivity * (target_temperature - nominal_temp) * 1000 / 5
    -- @see https://wiki.factorio.com/Liquids/Hot
    return fluid_usage*60*effectivity*(maximum_temperature-15)*1000/5
  end
  if lua_entity_prototype.type == EntityType.boiler then
    return EntityPrototype.maxEnergyUsage()
  end
  if lua_entity_prototype.type == EntityType.solar_panel then
    return lua_entity_prototype.production or 0
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
  return Player.getLocalisedName({name=lua_entity_prototype.name, EntityType.type})
end


-------------------------------------------------------------------------------
-- Return effectivity
--
-- @function [parent=#EntityPrototype] effectivity
-- 
-- @return #number default 1
--
function EntityPrototype.effectivity()
  return lua_entity_prototype.effectivity or 1
end

-------------------------------------------------------------------------------
-- Return distribution effectivity
--
-- @function [parent=#EntityPrototype] distributionEffectivity
--
-- @return #number default 1
--
function EntityPrototype.distributionEffectivity()
  return lua_entity_prototype.distribution_effectivity or 1
end

-------------------------------------------------------------------------------
-- Return maximum temperature
--
-- @function [parent=#EntityPrototype] maximumTemperature
--
-- @return #number default 0
--
function EntityPrototype.maximumTemperature()
  return lua_entity_prototype.maximum_temperature or 0
end

-------------------------------------------------------------------------------
-- Return fluid usage per tick
--
-- @function [parent=#EntityPrototype] fluidUsagePerTick
--
-- @return #number default 0
--
function EntityPrototype.fluidUsagePerTick()
  return lua_entity_prototype.fluid_usage_per_tick or 0
end

-------------------------------------------------------------------------------
-- Return module inventory size
--
-- @function [parent=#EntityPrototype] moduleInventorySize
--
-- @return #number default 0
--
function EntityPrototype.moduleInventorySize()
  return lua_entity_prototype.module_inventory_size or 0
end

-------------------------------------------------------------------------------
-- Return crafting speed
--
-- @function [parent=#EntityPrototype] craftingSpeed
--
-- @return #number default 0
--
function EntityPrototype.craftingSpeed()
  return lua_entity_prototype.crafting_speed or 0
end

-------------------------------------------------------------------------------
-- Return mining speed
--
-- @function [parent=#EntityPrototype] miningSpeed
--
-- @return #number default 0
--
function EntityPrototype.miningSpeed()
  return lua_entity_prototype.mining_speed or 0
end

-------------------------------------------------------------------------------
-- Return mining power
--
-- @function [parent=#EntityPrototype] miningPower
--
-- @return #number default 0
--
function EntityPrototype.miningPower()
  return lua_entity_prototype.mining_power or 0
end

-------------------------------------------------------------------------------
-- Return energy type
--
-- @function [parent=#EntityPrototype] energyType
--
-- @return #string default electrical
--
function EntityPrototype.energyType()
  if lua_entity_prototype.burner_prototype ~= nil then return "burner" end
  return "electrical"
end

-------------------------------------------------------------------------------
-- Return mineable property hardness
--
-- @function [parent=#EntityPrototype] mineableHardness
--
-- @return #number default 1
--
function EntityPrototype.mineableHardness()
  if lua_entity_prototype.mineable_properties ~= nil then
    return lua_entity_prototype.mineable_properties.hardness or 1
  end
  return 1
end

-------------------------------------------------------------------------------
-- Return mineable property mining time
--
-- @function [parent=#EntityPrototype] mineableMiningTime
--
-- @return #number default 0.5
--
function EntityPrototype.mineableMiningTime()
  if lua_entity_prototype.mineable_properties ~= nil then
    return lua_entity_prototype.mineable_properties.mining_time or 0.5
  end
  return 0.5
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype buffer capacity
--
-- @function [parent=#EntityPrototype] electricBufferCapacity
--
-- @return #number default 0
--
function EntityPrototype.electricBufferCapacity()
  if lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.buffer_capacity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype input flow limit
--
-- @function [parent=#EntityPrototype] electricInputFlowLimit
--
-- @return #number default 0
--
function EntityPrototype.electricInputFlowLimit()
  if lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.input_flow_limit or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype output flow limit
--
-- @function [parent=#EntityPrototype] electricOutputFlowLimit
--
-- @return #number default 0
--
function EntityPrototype.electricOutputFlowLimit()
  if lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.output_flow_limit or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype emissions
--
-- @function [parent=#EntityPrototype] electricEmissions
--
-- @return #number default 0
--
function EntityPrototype.electricEmissions()
  if lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.emissions or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return electric energy source prototype effectivity
--
-- @function [parent=#EntityPrototype] electricEffectivity
--
-- @return #number default 0
--
function EntityPrototype.electricEffectivity()
  if lua_entity_prototype.electric_energy_source_prototype ~= nil then
    return lua_entity_prototype.electric_energy_source_prototype.effectivity or 0
  end
  return 0
end

return EntityPrototype
