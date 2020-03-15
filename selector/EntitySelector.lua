require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build entity selector
--
-- @module EntitySelector
-- @extends #AbstractSelector
--

EntitySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#EntitySelector] getCaption
--
-- @param #Controller parent parent controller
--
function EntitySelector:getCaption(parent)
  return {"helmod_selector-panel.entity-title"}
end

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#EntitySelector] afterInit
--
function EntitySelector:afterInit()
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#EntitySelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function EntitySelector:getPrototype(element, type)
  return EntityPrototype(element, type)
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#EntitySelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function EntitySelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, entity in pairs(Player.getEntityPrototypes()) do
    self:appendGroups(entity, "entity", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#EntitySelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function EntitySelector:buildPrototypeTooltip(prototype)
  -- initalize tooltip
  local entity_prototype = self:getPrototype(prototype)
  local tooltip = entity_prototype:getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#EntitySelector] buildPrototypeIcon
--
function EntitySelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "entity"):choose(prototype.type, prototype.name))
  button.locked = true
end
