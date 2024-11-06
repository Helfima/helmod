require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build tile selector
--
---@module TileSelector
---@extends #AbstractSelector
--

TileSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
function TileSelector:afterInit()
  self.hidden_option = true
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function TileSelector:getCaption()
  return {"helmod_selector-panel.tile-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function TileSelector:getPrototype(element, type)
  return TilePrototype(element, type)
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function TileSelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, item in pairs(Player.getTilePrototypes()) do
    self:appendGroups(item, "tile", list_products, list_ingredients, list_translate)
  end

end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function TileSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local tooltip = TilePrototype(prototype):getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function TileSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "tile"):choose(prototype.type, prototype.name))
  button.locked = true
end
