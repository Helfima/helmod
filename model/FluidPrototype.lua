---
-- Description of the module.
-- @module FluidPrototype
-- 
local FluidPrototype = {
  -- single-line comment
  classname = "FluidPrototype"
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

return FluidPrototype