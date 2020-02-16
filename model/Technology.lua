---
-- Description of the module.
-- @module Technology
-- 
Technology = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getTechnologyPrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getTechnologyPrototype(object.name))
  end
  base.classname = "HMTechnology"
end)

-------------------------------------------------------------------------------
-- Return enable of Prototype
--
-- @function [parent=#Technology] getEnabled
--
-- @return #boolean
--
function Technology:getEnabled()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.enabled
  end
  return true
end

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

-------------------------------------------------------------------------------
-- Return group
--
-- @function [parent=#Technology] getGroup
--
-- @return #table
--
function Technology:getGroup()
  if self.lua_prototype == nil then return {} end
  local group_name = "normal"
  if self.lua_prototype.research_unit_count_formula ~= nil then group_name = "infinite" end
  return {name=group_name}
end

-------------------------------------------------------------------------------
-- Return group
--
-- @function [parent=#Technology] getSubgroup
--
-- @return #table
--
function Technology:getSubgroup()
  return {name="default"}
end

-------------------------------------------------------------------------------
-- Return isResearched
--
-- @function [parent=#Technology] isResearched
--
-- @return #boolean
--
function Technology:isResearched()
  if self.lua_prototype == nil then return false end
  local technology = Player.getTechnology(self.lua_prototype.name)
  return technology.researched
end
