require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build fluid selector
--
-- @module FluidSelector
-- @extends #AbstractSelector
--

FluidSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#FluidSelector] getCaption
--
-- @param #Controller parent parent controller
--
function FluidSelector:getCaption(parent)
  return {"helmod_selector-panel.fluid-title"}
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#FluidSelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function FluidSelector:getPrototype(element, type)
  return FluidPrototype(element, type)
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#FluidSelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function FluidSelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid, "fluid", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#FluidSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function FluidSelector:buildPrototypeTooltip(prototype)
  -- initalize tooltip
  local tooltip = FluidPrototype(prototype):getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#FluidSelector] buildPrototypeIcon
--
function FluidSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "fluid"):choose(prototype.type, prototype.name))
  button.locked = true
end
