---
-- Description of the module.
-- @module FluidPrototype
-- 
local FluidPrototype = {
  -- single-line comment
  classname = "HMFluidPrototype"
}

local lua_fluid_prototype = nil

-------------------------------------------------------------------------------
-- Load factorio player
--
-- @function [parent=#FluidPrototype] load
--
-- @param #object object prototype
-- 
-- @return #FluidPrototype
--
function FluidPrototype.load(object)
  if type(object) == "string" then
    lua_fluid_prototype = Player.getFluidPrototype(object)
  elseif object.name ~= nil then
    lua_fluid_prototype = Player.getFluidPrototype(object.name)
  end
  return FluidPrototype
end

-------------------------------------------------------------------------------
-- Return factorio player
--
-- @function [parent=#FluidPrototype] native
--
-- @return #LuaFluidPrototype
--
function FluidPrototype.native()
  return lua_fluid_prototype
end

-------------------------------------------------------------------------------
-- Return valid
--
-- @function [parent=#FluidPrototype] getValid
--
-- @return #boolean
--
function FluidPrototype.getValid()
  if lua_fluid_prototype == nil then return false end
  return lua_fluid_prototype.valid
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#FluidPrototype] getLocalisedName
--
-- @return #number default 0
--
function FluidPrototype.getLocalisedName()
  if lua_fluid_prototype ~= nil then
    if User.getModGlobalSetting("display_real_name") then
      return lua_fluid_prototype.name
    end
    return lua_fluid_prototype.localised_name
  end
  return "unknow"
end

return FluidPrototype