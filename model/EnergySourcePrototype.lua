require "model.Prototype"
-------------------------------------------------------------------------------
-- Class Object
--
-- @module EnergySourcePrototype
--
EnergySourcePrototype = newclass(Prototype,function(base,lua_prototype)
  Prototype.init(base,lua_prototype)
end)
-------------------------------------------------------------------------------
-- Return emissions
--
-- @function [parent=#EnergySourcePrototype] getEmissions
--
-- @return #number default 0
--
function EnergySourcePrototype:getEmissions()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.emissions or 1
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return effectivity
--
-- @function [parent=#EnergySourcePrototype] getEffectivity
--
-- @return #number default 0
--
function EnergySourcePrototype:getEffectivity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.effectivity or 1
  end
  return 0
end

ElectricSourcePrototype = newclass(EnergySourcePrototype,function(base,lua_prototype)
  EnergySourcePrototype.init(base,lua_prototype)
end)

-------------------------------------------------------------------------------
-- Return buffer capacity
--
-- @function [parent=#ElectricSourcePrototype] getBufferCapacity
--
-- @return #number default 0
--
function ElectricSourcePrototype:getBufferCapacity()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.buffer_capacity or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return input flow limit
--
-- @function [parent=#ElectricSourcePrototype] getInputFlowLimit
--
-- @return #number default 0
--
function ElectricSourcePrototype:getInputFlowLimit()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.input_flow_limit*60 or 0
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return output flow limit
--
-- @function [parent=#ElectricSourcePrototype] getOutputFlowLimit
--
-- @return #number default 0
--
function ElectricSourcePrototype:getOutputFlowLimit()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.output_flow_limit*60 or 0
  end
  return 0
end

BurnerPrototype = newclass(EnergySourcePrototype,function(base,lua_prototype)
  EnergySourcePrototype.init(base,lua_prototype)
end)

-------------------------------------------------------------------------------
-- Return fuel categories
--
-- @function [parent=#BurnerPrototype] getFuelCategories
--
-- @return #table
--
function BurnerPrototype:getFuelCategories()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fuel_categories or {}
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return fuel item prototypes
--
-- @function [parent=#BurnerPrototype] getFuelPrototypes
--
-- @return #table
--
function BurnerPrototype:getFuelPrototypes()
  local filters = {}
  for fuel_category,_ in pairs(self:getFuelCategories()) do
    table.insert(filters, {filter="fuel-category", mode="or", invert=false,["fuel-category"]=fuel_category})
  end
  return Player.getItemPrototypes(filters)
end

-------------------------------------------------------------------------------
-- Return first fuel item prototype
--
-- @function [parent=#BurnerPrototype] getFirstFuelPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype item prototype
--
function BurnerPrototype:getFirstFuelPrototype()
  local fuel_items = self:getFuelPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil or fuel_item.name == "coal" then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end

-------------------------------------------------------------------------------
-- Return fuel prototype
--
-- @function [parent=#BurnerPrototype] getFuelPrototype
--
-- @param #table factory
--
-- @return #ItemPrototype item prototype
--
function BurnerPrototype:getFuelPrototype(factory)
  local fuel = factory.fuel
  if fuel == nil then
    local first_fuel = self:getFirstFuelPrototype()
    fuel = first_fuel.name
  end
  return ItemPrototype(fuel)
end

function BurnerPrototype:toData()
  local data = {}
  data.emissions = self.lua_prototype.emissions
  data.effectivity = self.lua_prototype.effectivity
  data.fuel_inventory_size = self.lua_prototype.fuel_inventory_size
  data.burnt_inventory_size = self.lua_prototype.burnt_inventory_size
  data.fuel_categories = self.lua_prototype.fuel_categories
  data.valid = self.lua_prototype.valid
  return data
end

function BurnerPrototype:toString()
  return game.table_to_json(self:toData())
end

FluidSourcePrototype = newclass(EnergySourcePrototype,function(base,lua_prototype)
  EnergySourcePrototype.init(base,lua_prototype)
end)

-------------------------------------------------------------------------------
-- Return fuel fluid prototypes
--
-- @function [parent=#FluidSourcePrototype] getFuelPrototypes
--
-- @return #table
--
function FluidSourcePrototype:getFuelPrototypes()
  if self.lua_prototype ~= nil and self.lua_prototype.fluid_box ~= nil and self.lua_prototype.fluid_box.filter ~= nil then
    return {self.lua_prototype.fluid_box.filter}
  else
    local filters = {}
    table.insert(filters, {filter="fuel-value", mode="or", invert=false, comparison=">", value=0})
    return Player.getFluidPrototypes(filters)
  end
end

-------------------------------------------------------------------------------
-- Return first fuel fluid prototype
--
-- @function [parent=#FluidSourcePrototype] getFirstFuelPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype fluid prototypes
--
function FluidSourcePrototype:getFirstFuelPrototype()
  local fuel_items = self:getFuelPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end

-------------------------------------------------------------------------------
-- Return fuel prototype
--
-- @function [parent=#FluidSourcePrototype] getFuelPrototype
--
-- @param #table factory
--
-- @return #FluidPrototype item prototype
--
function FluidSourcePrototype:getFuelPrototype(factory)
  local fuel = factory.fuel
  if fuel == nil then
    local first_fuel = self:getFirstFuelPrototype()
    fuel = first_fuel.name
  end
  return FluidPrototype(fuel)
end

-------------------------------------------------------------------------------
-- Return fluid usage per tick
--
-- @function [parent=#FluidSourcePrototype] getFluidUsagePerTick
--
-- @return #number default 0
--
function FluidSourcePrototype:getFluidUsagePerTick()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fluid_usage_per_tick or 1
  end
  return 0
end

VoidSourcePrototype = newclass(FluidSourcePrototype,function(base,lua_prototype)
  EnergySourcePrototype.init(base,lua_prototype)
end)

HeatSourcePrototype = newclass(EnergySourcePrototype,function(base,lua_prototype)
  EnergySourcePrototype.init(base,lua_prototype)
end)
