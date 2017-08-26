---
-- Description of the module.
-- @module Technology
-- 
local Technology = {
  -- single-line comment
  classname = "HMTechnology"
}

local lua_technology = nil

-------------------------------------------------------------------------------
-- Load factorio Technology
--
-- @function [parent=#Technology] load
--
-- @param #object object prototype
-- 
-- @return #Technology
--
function Technology.load(object)
  if type(object) == "string" then
    lua_technology = Player.getTechnology(object)
  elseif object.name ~= nil then
    lua_technology = Player.getTechnology(object.name)
  end
  return Technology
end

-------------------------------------------------------------------------------
-- Return factorio Technology
--
-- @function [parent=#Technology] native
--
-- @return #LuaTechnology
--
function Technology.native()
  return lua_technology
end

return Technology