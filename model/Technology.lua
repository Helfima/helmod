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

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Technology] getLocalisedName
--
-- @return #number default 0
--
function Technology.getLocalisedName()
  if lua_technology ~= nil then
    if Player.getSettings("display_real_name", true) then
      return lua_technology.name
    end
    return lua_technology.localised_name
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return valid
--
-- @function [parent=#Technology] getValid
--
-- @return #boolean
--
function Technology.getValid()
  if lua_technology == nil then return false end
  return lua_technology.valid
end

-------------------------------------------------------------------------------
-- Return level
--
-- @function [parent=#Technology] getLevel
--
-- @return #number
--
function Technology.getLevel()
  if lua_technology == nil then return 0 end
  return lua_technology.level
end

-------------------------------------------------------------------------------
-- Return formula
--
-- @function [parent=#Technology] getFormula
--
-- @return #string
--
function Technology.getFormula()
  if lua_technology == nil then return nil end
  return lua_technology.research_unit_count_formula
end

-------------------------------------------------------------------------------
-- Return ingredients
--
-- @function [parent=#Technology] getIngredients
--
-- @return #table
--
function Technology.getIngredients()
  if lua_technology == nil then return {} end
  return lua_technology.research_unit_ingredients or {}
end

return Technology