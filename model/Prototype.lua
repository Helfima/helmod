-------------------------------------------------------------------------------
---@class Prototype
Prototype = newclass(function(base, lua_prototype)
  base.lua_prototype = lua_prototype
end)

-------------------------------------------------------------------------------
---Return factorio player
---@return LuaPrototype
function Prototype:native()
  return self.lua_prototype
end

-------------------------------------------------------------------------------
---Return valid
---@return boolean
function Prototype:getValid()
  if self.lua_prototype == nil then return false end
  return self.lua_prototype.valid
end

-------------------------------------------------------------------------------
---Return localised name
---@return string
function Prototype:getLocalisedName()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.localised_name
  end
  return "unknow"
end

-------------------------------------------------------------------------------
---Return type
---@return string
function Prototype:getType()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.type
end

-------------------------------------------------------------------------------
---Return group
---@return table
function Prototype:getGroup()
  if self.lua_prototype == nil then return {} end
  return self.lua_prototype.group
end

-------------------------------------------------------------------------------
---Return subgroup
---@return table
function Prototype:getSubgroup()
  if self.lua_prototype == nil then return {} end
  return self.lua_prototype.subgroup
end