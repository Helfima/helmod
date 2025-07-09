require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build fluid selector
--
---@module FluidSelector
---@extends #AbstractSelector
--

FluidSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
function FluidSelector:afterInit()
  self.hidden_option = true
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function FluidSelector:getCaption()
  return {"helmod_selector-panel.fluid-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function FluidSelector:getPrototype(element, type)
  return FluidPrototype(element, type)
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function FluidSelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid, "fluid", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function FluidSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local tooltip = FluidPrototype(prototype):getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function FluidSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "fluid"):choose(prototype.type, prototype.name))
  button.locked = true
end
