require "model.Prototype"
-------------------------------------------------------------------------------
-- Class Object
--
-- @module BurnerPrototype
--
BurnerPrototype = newclass(Prototype)

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
-- @function [parent=#BurnerPrototype] getFuelItemPrototypes
--
-- @return #table
--
function BurnerPrototype:getFuelItemPrototypes()
  local filters = {}
  for fuel_category,_ in pairs(self:getFuelCategories()) do
    table.insert(filters, {filter="fuel-category", mode="or", invert=false,["fuel-category"]=fuel_category})
  end
  return Player.getItemPrototypes(filters)
end

-------------------------------------------------------------------------------
-- Return first fuel item prototype
--
-- @function [parent=#BurnerPrototype] getFirstFuelItemPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype item prototypes
--
function BurnerPrototype:getFirstFuelItemPrototype()
  local fuel_items = self:getFuelItemPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil or fuel_item.name == "coal" then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end

-------------------------------------------------------------------------------
-- Return fuel fluid prototypes
--
-- @function [parent=#BurnerPrototype] getFuelFluidPrototypes
--
-- @return #table
--
function BurnerPrototype:getFuelFluidPrototypes()
  local filters = {}
  table.insert(filters, {filter="fuel-value", mode="or", invert=false, comparison=">", value=0})
  return Player.getFluidPrototypes(filters)
end

-------------------------------------------------------------------------------
-- Return first fuel fluid prototype
--
-- @function [parent=#BurnerPrototype] getFirstFuelFluidPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype fluid prototypes
--
function BurnerPrototype:getFirstFuelFluidPrototype()
  local fuel_items = self:getFuelFluidPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end


function BurnerPrototype:toString()
  local data = {}
  data.emissions = self.lua_prototype.emissions
  data.effectivity = self.lua_prototype.effectivity
  data.fuel_inventory_size = self.lua_prototype.fuel_inventory_size
  data.burnt_inventory_size = self.lua_prototype.burnt_inventory_size
  data.fuel_categories = self.lua_prototype.fuel_categories
  data.valid = self.lua_prototype.valid
  return string.format("%s",game.table_to_json(data))
end