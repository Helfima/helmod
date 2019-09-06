---
-- Description of the module.
-- @module Technology
-- 
Technology = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getTechnology(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getTechnology(object.name))
  end
  base.classname = "HMTechnology"
end)

-------------------------------------------------------------------------------
-- Return level
--
-- @function [parent=#Technology] getLevel
--
-- @return #number
--
function Technology:getLevel()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.level
end

-------------------------------------------------------------------------------
-- Return formula
--
-- @function [parent=#Technology] getFormula
--
-- @return #string
--
function Technology:getFormula()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.research_unit_count_formula
end

-------------------------------------------------------------------------------
-- Return ingredients
--
-- @function [parent=#Technology] getIngredients
--
-- @return #table
--
function Technology:getIngredients()
  if self.lua_prototype == nil then return {} end
  return self.lua_prototype.research_unit_ingredients or {}
end
