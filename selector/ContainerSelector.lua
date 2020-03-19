require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build container selector
--
-- @module ContainerSelector
-- @extends #AbstractSelector
--

ContainerSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#ContainerSelector] getCaption
--
-- @param #Controller parent parent controller
--
function ContainerSelector:getCaption(parent)
  return {"helmod_selector-panel.container-title"}
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#ContainerSelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function ContainerSelector:getPrototype(element, type)
  return EntityPrototype(element, type)
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ContainerSelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function ContainerSelector:updateGroups(list_products, list_ingredients, list_translate)
  local filters = {}
  for _,type in pairs({"storage-tank", "container", "logistic-container", "cargo-wagon", "fluid-wagon", "item-with-entity-data", "car", "logistic-robot", "transport-belt"}) do
    table.insert(filters, {filter="type", mode="or", invert=false, type=type})
  end
  for key, entity in pairs(Player.getEntityPrototypes(filters)) do
    self:appendGroups(entity, "entity", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#ContainerSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function ContainerSelector:buildPrototypeTooltip(prototype)
  -- initalize tooltip
  local entity_prototype = EntityPrototype(prototype)
  local tooltip = entity_prototype:getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#ContainerSelector] buildPrototypeIcon
--
function ContainerSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "container"):choose(prototype.type, prototype.name):color())
  button.locked = true
end
