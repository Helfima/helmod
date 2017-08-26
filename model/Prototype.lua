---
-- Description of the module.
-- @module Prototype
-- 
local Prototype = {
  -- single-line comment
  classname = "HMPrototype"
}

local lua_prototype = nil
local lua_type = nil

-------------------------------------------------------------------------------
-- Load factorio Prototype
--
-- @function [parent=#Prototype] load
--
-- @param #object object prototype
-- @param #string object_type prototype type
-- 
-- @return #Prototype
--
function Prototype.load(object, object_type)
  Logging:debug(Prototype.classname, "load(object, object_type)", object, object_type)
  local object_name = nil
  if type(object) == "string" then
    object_name = object
    lua_type = object_type
  elseif object.name ~= nil then
    object_name = object.name
    lua_type = object.type
  end
  Logging:debug(Prototype.classname, "object_name", object_name, "lua_type", lua_type)
  if lua_type == nil or lua_type == "entity" then
    lua_prototype = EntityPrototype.load(object_name).native()
    lua_type = "entity"
  elseif lua_type == "recipe" then
    lua_prototype = RecipePrototype.load(object_name).native()
    lua_type = "recipe"
  elseif lua_type == "item" then
    lua_prototype = ItemPrototype.load(object_name).native()
    lua_type = "item"
  elseif lua_type == "resource" then
    lua_prototype = ItemPrototype.load(object_name).native()
    lua_type = "resource"
  elseif lua_type == "fluid" then
    lua_prototype = FluidPrototype.load(object_name).native()
    lua_type = "fluid"
  elseif lua_type == "technology" then
    lua_prototype = Technology.load(object_name).native()
    lua_type = "technology"
  end
  return Prototype
end

-------------------------------------------------------------------------------
-- Return factorio Prototype
--
-- @function [parent=#Prototype] native
--
-- @return #lua_prototype
--
function Prototype.native()
  return lua_prototype
end

-------------------------------------------------------------------------------
-- Return type Prototype
--
-- @function [parent=#Prototype] type
--
-- @return #lua_type
--
function Prototype.type()
  return lua_type
end

-------------------------------------------------------------------------------
-- Return category of Prototype
--
-- @function [parent=#Prototype] getCategory
--
-- @return #table
--
function Prototype.getCategory()
  Logging:debug(Prototype.classname, "getCategory()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.category or "crafting"
  elseif lua_type == "resource" then
    return "resource"
  elseif lua_type == "fluid" then
    return "fluid"
  elseif lua_type == "technology" then
    return "technology"
  end
  return nil
end

return Prototype