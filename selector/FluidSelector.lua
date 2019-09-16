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
-- @param #LuaEvent event
--
function FluidSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)

  local list_products = {}
  local list_ingredients = {}

  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid, "fluid", list_products, list_ingredients)
  end
  Cache.setData(self.classname, "list_products", list_products)
  Cache.setData(self.classname, "list_ingredients", list_ingredients)
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#FluidSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function FluidSelector:buildPrototypeTooltip(prototype)
  Logging:trace(self.classname, "buildPrototypeTooltip(player, prototype)", prototype)
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
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=element-select=ID=fluid=", Player.getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end



