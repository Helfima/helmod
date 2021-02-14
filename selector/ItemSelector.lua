require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build item selector
--
---@module ItemSelector
---@extends #AbstractSelector
--

ItemSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---Return caption
---@return table
function ItemSelector:getCaption()
  return {"helmod_selector-panel.item-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function ItemSelector:getPrototype(element, type)
  return ItemPrototype(element, type)
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function ItemSelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, item in pairs(Player.getItemPrototypes()) do
    self:appendGroups(item, "item", list_products, list_ingredients, list_translate)
  end

end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function ItemSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local tooltip = ItemPrototype(prototype):getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function ItemSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "item"):choose(prototype.type, prototype.name))
  button.locked = true
end
