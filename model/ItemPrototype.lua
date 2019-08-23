---
-- Description of the module.
-- @module ItemPrototype
-- 
local ItemPrototype = {
  -- single-line comment
  classname = "HMItemPrototype"
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

-------------------------------------------------------------------------------
-- Return valid
--
-- @function [parent=#ItemPrototype] getValid
--
-- @return #boolean
--
function ItemPrototype.getValid()
  if lua_item_prototype == nil then return false end
  return lua_item_prototype.valid
end

-------------------------------------------------------------------------------
-- Return fuel value
--
-- @function [parent=#ItemPrototype] getFuelValue
--
-- @return #boolean
--
function ItemPrototype.getFuelValue()
  if lua_item_prototype == nil then return 0 end
  return lua_item_prototype.fuel_value
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#ItemPrototype] getLocalisedName
--
-- @return #number default 0
--
function ItemPrototype.getLocalisedName()
  if lua_item_prototype ~= nil then
    if User.getModGlobalSetting("display_real_name") then
      return lua_item_prototype.name
    end
    return lua_item_prototype.localised_name
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return stack size
--
-- @function [parent=#ItemPrototype] stackSize
--
-- @return #number default 0
--
function ItemPrototype.stackSize(index)
  if lua_item_prototype ~= nil then
    return lua_item_prototype.stack_size or 0
  end
  return 0
end

return ItemPrototype