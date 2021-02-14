require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build entity selector
--
---@module EntitySelector
---@extends #AbstractSelector
--

EntitySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---Return caption
---@return table
function EntitySelector:getCaption()
  return {"helmod_selector-panel.entity-title"}
end

-------------------------------------------------------------------------------
---After initialization
--
---@function [parent=#EntitySelector] afterInit
--
function EntitySelector:afterInit()
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function EntitySelector:getPrototype(element, type)
  return EntityPrototype(element, type)
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function EntitySelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, entity in pairs(Player.getEntityPrototypes()) do
    self:appendGroups(entity, "entity", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function EntitySelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local entity_prototype = self:getPrototype(prototype)
  local tooltip = entity_prototype:getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function EntitySelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "entity"):choose(prototype.type, prototype.name))
  button.locked = true
end
