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
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ItemSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)

  local list_products = {}
  local list_ingredients = {}

  for key, item in pairs(Player.getItemPrototypes()) do
    self:appendGroups(item, "item", list_products, list_ingredients)
  end
  Cache.setData(self.classname, "list_products", list_products)
  Cache.setData(self.classname, "list_ingredients", list_ingredients)
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#ItemSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function ItemSelector:buildPrototypeTooltip(prototype)
  Logging:trace(self.classname, "buildPrototypeTooltip(player, prototype)", prototype)
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
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=element-select=ID=item=", Player.getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end








