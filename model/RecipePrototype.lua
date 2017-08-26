---
-- Description of the module.
-- @module RecipePrototype
--
local RecipePrototype = {
  -- single-line comment
  classname = "HMRecipePrototype"
}

local lua_prototype = nil
local lua_type = nil

-------------------------------------------------------------------------------
-- Load factorio RecipePrototype
--
-- @function [parent=#RecipePrototype] load
--
-- @param #object object prototype
-- @param #string object_type prototype type
--
-- @return #RecipePrototype
--
function RecipePrototype.load(object, object_type)
  Logging:debug(RecipePrototype.classname, "load(object, object_type)", object, object_type)
  local object_name = nil
  if type(object) == "string" then
    object_name = object
    lua_type = object_type
  elseif object.name ~= nil then
    object_name = object.name
    lua_type = object.type
  end
  Logging:debug(RecipePrototype.classname, "object_name", object_name, "lua_type", lua_type)
  if lua_type == nil or lua_type == "recipe" then
    lua_prototype = Player.getRecipe(object_name)
    lua_type = "recipe"
  elseif lua_type == "resource" then
    lua_prototype = Player.getEntityPrototype(object_name)
    lua_type = "resource"
  elseif lua_type == "fluid" then
    lua_prototype = Player.getFluidPrototype(object_name)
    lua_type = "fluid"
  elseif lua_type == "technology" then
    lua_prototype = Player.getTechnology(object_name)
    lua_type = "technology"
  end
  if lua_prototype == nil then
    RecipePrototype.find(object)
  end
  return RecipePrototype
end

-------------------------------------------------------------------------------
-- Try to find prototype
--
-- @function [parent=#RecipePrototype] find
--
-- @param #object object prototype
--
-- @return #RecipePrototype
--
function RecipePrototype.find(object)
  Logging:debug(RecipePrototype.classname, "find(object)", object)
  local object_name = nil
  if type(object) == "string" then
    object_name = object
  elseif object.name ~= nil then
    object_name = object.name
  end
  lua_prototype = Player.getRecipe(object_name)
  lua_type = "recipe"
  if lua_prototype == nil then
    lua_prototype = Player.getTechnology(object_name)
    lua_type = "technology"
  end
  if lua_prototype == nil then
    lua_prototype = Player.getEntityPrototype(object_name)
    lua_type = "resource"
  end
  if lua_prototype == nil then
    lua_prototype = Player.getFluidPrototype(object_name)
    lua_type = "fluid"
  end
  return RecipePrototype
end

-------------------------------------------------------------------------------
-- new prototype model
--
-- @function [parent=#RecipePrototype] new
--
-- @param #string type
-- @param #string name
--
-- @return #table
--
function RecipePrototype.new(type, name)
  local prototype = {
    type = type,
    name = name
  }
  return prototype
end

-------------------------------------------------------------------------------
-- Return factorio Prototype
--
-- @function [parent=#RecipePrototype] native
--
-- @return #lua_prototype
--
function RecipePrototype.native()
  return lua_prototype
end

-------------------------------------------------------------------------------
-- Return type Prototype
--
-- @function [parent=#RecipePrototype] type
--
-- @return #lua_type
--
function RecipePrototype.type()
  return lua_type
end

-------------------------------------------------------------------------------
-- Return localised name of Prototype
--
-- @function [parent=#RecipePrototype] getLocalisedName
--
-- @return #table
--
function RecipePrototype.getLocalisedName()
  Logging:debug(RecipePrototype.classname, "getLocalisedName()", lua_prototype, lua_type)
  if lua_prototype ~= nil then
    if not(Player.getSettings("display_real_name", true)) then
      return lua_prototype.localised_name
    else
      return lua_prototype.name
    end
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return category of Prototype
--
-- @function [parent=#RecipePrototype] getCategory
--
-- @return #table
--
function RecipePrototype.getCategory()
  Logging:debug(RecipePrototype.classname, "getCategory()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.category or "crafting"
  elseif lua_type == "resource" then
    return "extraction-machine"
  elseif lua_type == "fluid" then
    return "chemistry"
  elseif lua_type == "technology" then
    return "technology"
  end
  return nil
end

-------------------------------------------------------------------------------
-- Return products array of Prototype
--
-- @function [parent=#RecipePrototype] getProducts
--
-- @return #table
--
function RecipePrototype.getProducts()
  Logging:debug(RecipePrototype.classname, "getProducts()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.products
  elseif lua_type == "resource" then
    return {{name=lua_prototype.name, type="item", amount=1}}
  elseif lua_type == "fluid" then
    return {{name=lua_prototype.name, type="fluid", amount=1}}
  elseif lua_type == "technology" then
    return {{name=lua_prototype.name, type="technology", amount=1}}
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return ingredients array of Prototype
--
-- @function [parent=#RecipePrototype] getIngredients
--
-- @return #table
--
function RecipePrototype.getIngredients()
  Logging:debug(RecipePrototype.classname, "getIngredients()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.ingredients
  elseif lua_type == "resource" then
    return {{name=lua_prototype.name, type="item", amount=1}}
  elseif lua_type == "fluid" then
    if lua_prototype.name == "steam" then
      return {{name="water", type="fluid", amount=1},{name="coal", type="item", amount=0.0076}}
    end
    return {{name=lua_prototype.name, type="fluid", amount=1}}
  elseif lua_type == "technology" then
    return lua_prototype.research_unit_ingredients
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return energy of Prototype
--
-- @function [parent=#RecipePrototype] getEnergy
--
-- @return #table
--
function RecipePrototype.getEnergy()
  Logging:debug(RecipePrototype.classname, "getEnergy()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.energy
  elseif lua_type == "resource" then
    return 1
  elseif lua_type == "fluid" then
    return 1
  elseif lua_type == "technology" then
    return lua_prototype.research_unit_energy/60
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return enable of Prototype
--
-- @function [parent=#RecipePrototype] getEnabled
--
-- @return #boolean
--
function RecipePrototype.getEnabled()
  Logging:debug(RecipePrototype.classname, "getEnabled()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.enabled
  elseif lua_type == "resource" then
    return true
  elseif lua_type == "fluid" then
    return true
  elseif lua_type == "technology" then
    return true
  end
  return true
end

-------------------------------------------------------------------------------
-- Return hidden of Prototype
--
-- @function [parent=#RecipePrototype] getHidden
--
-- @return #boolean
--
function RecipePrototype.getHidden()
  Logging:debug(RecipePrototype.classname, "getHidden()", lua_prototype, lua_type)
  if lua_type == "recipe" then
    return lua_prototype.hidden
  elseif lua_type == "resource" then
    return false
  elseif lua_type == "fluid" then
    return false
  elseif lua_type == "technology" then
    return false
  end
  return false
end

return RecipePrototype
