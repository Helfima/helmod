-------------------------------------------------------------------------------
-- Class Object
--
-- @module Prototype
--
Prototype = newclass(function(base, lua_prototype)
  base.lua_prototype = lua_prototype
end)

-------------------------------------------------------------------------------
-- Return factorio player
--
-- @function [parent=#Prototype] native
--
-- @return #LuaFluidPrototype
--
function Prototype:native()
  return self.lua_prototype
end

-------------------------------------------------------------------------------
-- Return valid
--
-- @function [parent=#Prototype] getValid
--
-- @return #boolean
--
function Prototype:getValid()
  if self.lua_prototype == nil then return false end
  return self.lua_prototype.valid
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Prototype] getLocalisedName
--
-- @return #number default 0
--
function Prototype:getLocalisedName()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.localised_name
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return type
--
-- @function [parent=#Prototype] getType
--
-- @return #string
--
function Prototype:getType()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.type
end

-------------------------------------------------------------------------------
-- Return group
--
-- @function [parent=#Prototype] getGroup
--
-- @return #string
--
function Prototype:getGroup()
  if self.lua_prototype == nil then return {} end
  return self.lua_prototype.group
end

-------------------------------------------------------------------------------
-- Return group
--
-- @function [parent=#Prototype] getGroup
--
-- @return #string
--
function Prototype:getSubgroup()
  if self.lua_prototype == nil then return {} end
  return self.lua_prototype.subgroup
end

