require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module TechnologySelector
-- @extends #AbstractSelector
--

TechnologySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#TechnologySelector] afterInit
--
function TechnologySelector:afterInit()
  self.disable_option = true
  self.sprite_type = nil
end

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#TechnologySelector] getCaption
--
-- @param #Controller parent parent controller
--
function TechnologySelector:getCaption(parent)
  return {"helmod_selector-panel.technology-title"}
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#TechnologySelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function TechnologySelector:getPrototype(element, type)
  return Technology(element, type)
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#TechnologySelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function TechnologySelector:updateGroups(list_products, list_ingredients, list_translate)
  Logging:trace(self.classname, "updateGroups()")

  for key, technology in pairs(Player.getTechnologies()) do
    self:appendGroups(technology, "technology", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#TechnologySelector] buildPrototypeIcon
--
function TechnologySelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self.classname, "buildPrototypeIcon(guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select=ID", "technology"):choose(prototype.type, prototype.name))
  button.locked = true
end





