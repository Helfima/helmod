require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build item selector
--
-- @module ItemSelector
-- @extends #AbstractSelector
--

ItemSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#ItemSelector] getCaption
--
-- @param #Controller parent parent controller
--
function ItemSelector:getCaption(parent)
  return {"helmod_selector-panel.item-title"}
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#ItemSelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function ItemSelector:getPrototype(element, type)
  return ItemPrototype(element, type)
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ItemSelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function ItemSelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, item in pairs(Player.getItemPrototypes()) do
    self:appendGroups(item, "item", list_products, list_ingredients, list_translate)
  end

end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#ItemSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function ItemSelector:buildPrototypeTooltip(prototype)
  -- initalize tooltip
  local tooltip = ItemPrototype(prototype):getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#ItemSelector] buildPrototypeIcon
--
function ItemSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "item"):choose(prototype.type, prototype.name))
  button.locked = true
end
