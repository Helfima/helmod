require "model.Prototype"
-------------------------------------------------------------------------------
-- Class Object
--
-- @module FluidboxPrototype
--
FluidboxPrototype = newclass(Prototype)

-------------------------------------------------------------------------------
-- Return fuel categories
--
-- @function [parent=#FluidboxPrototype] getFuelCategories
--
-- @return #table
--
function FluidboxPrototype:getFuelCategories()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.fuel_categories or {}
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return fuel item prototypes
--
-- @function [parent=#FluidboxPrototype] getFuelItemPrototypes
--
-- @return #table
--
function FluidboxPrototype:getFuelItemPrototypes()
  local filters = {}
  for fuel_category,_ in pairs(self:getFuelCategories()) do
    table.insert(filters, {filter="fuel-category", mode="or", invert=false,["fuel-category"]=fuel_category})
  end
  return Player.getItemPrototypes(filters)
end

-------------------------------------------------------------------------------
-- Return first fuel item prototype
--
-- @function [parent=#FluidboxPrototype] getFirstFuelItemPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype item prototypes
--
function FluidboxPrototype:getFirstFuelItemPrototype()
  local fuel_items = self:getFuelItemPrototypes()
  local first_fuel = nil
  for _,fuel_item in pairs(fuel_items) do
    if first_fuel == nil or fuel_item.name == "coal" then
      first_fuel = fuel_item
    end
  end
  return first_fuel
end


function FluidboxPrototype:toString()
  local data = {}
  data.entity = self.lua_prototype.entity
  data.index = self.lua_prototype.index
  data.pipe_connections = self.lua_prototype.pipe_connections
  data.production_type = self.lua_prototype.production_type
  data.base_area = self.lua_prototype.base_area
  data.base_level = self.lua_prototype.base_level
  data.height = self.lua_prototype.height
  data.volume = self.lua_prototype.volume
  data.filter = self.lua_prototype.filter
  data.minimum_temperature = self.lua_prototype.minimum_temperature
  data.maximum_temperature = self.lua_prototype.maximum_temperature
  data.secondary_draw_orders = self.lua_prototype.secondary_draw_orders
  data.render_layer = self.lua_prototype.render_layer
  data.valid = self.lua_prototype.valid
  return string.format("%s",game.table_to_json(data))
end