require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build container selector
---@class ContainerSelector
ContainerSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---Return caption
---@return table
function ContainerSelector:getCaption()
  return {"helmod_selector-panel.container-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function ContainerSelector:getPrototype(element, type)
  return EntityPrototype(element, type)
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
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
---Build prototype tooltip
---@param prototype table
---@return table
function ContainerSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local entity_prototype = EntityPrototype(prototype)
  local tooltip = entity_prototype:getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function ContainerSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "container"):choose(prototype.type, prototype.name):color())
  button.locked = true
end
