---
-- Description of the module.
-- @module ItemPrototype
-- 
local ItemPrototype = {
  -- single-line comment
  classname = "ItemPrototype"
}

local lua_item_prototype = nil

-------------------------------------------------------------------------------
-- Load factorio ItemPrototype
--
-- @function [parent=#ItemPrototype] load
--
-- @param #object object prototype
-- 
-- @return #ItemPrototype
--
function ItemPrototype.load(object)
  if type(object) == "string" then
    lua_item_prototype = Player.getItemPrototype(object)
  elseif object.name ~= nil then
    lua_item_prototype = Player.getItemPrototype(object.name)
  end
  return ItemPrototype
end

-------------------------------------------------------------------------------
-- Return factorio ItemPrototype
--
-- @function [parent=#ItemPrototype] native
--
-- @return #lua_item_prototype
--
function ItemPrototype.native()
  return lua_item_prototype
end

return ItemPrototype