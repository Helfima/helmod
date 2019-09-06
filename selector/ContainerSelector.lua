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
-- Append groups
--
-- @function [parent=#ContainerSelector] appendGroups
--
-- @param #string name
-- @param #string type
--
function ContainerSelector:appendGroups(name, type)
  Logging:debug(self.classname, "appendGroups()", name, type)
  local entity_prototype = EntityPrototype(name)
  local find = self:checkFilter(entity_prototype:native())
  local filter_show_disable = User.getSetting("filter_show_disable")
  local filter_show_hidden = User.getSetting("filter_show_hidden")
  
  local list_group = Cache.getData(self.classname, "list_group")
  local list_prototype = Cache.getData(self.classname, "list_prototype")
  local list_subgroup = Cache.getData(self.classname, "list_subgroup")
  
  if find == true and (entity_prototype:getValid() == true or filter_show_disable == true) then
    local group_name = entity_prototype:native().group.name
    local subgroup_name = entity_prototype:native().subgroup.name
    
    list_subgroup[subgroup_name] = entity_prototype:native().subgroup
    
    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    list_subgroup[subgroup_name] = entity_prototype:native().subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    
    local search_products = name
    list_group[group_name].search_products = list_group[group_name].search_products .. search_products
    
    local search_ingredients = name
    list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients
    
    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=entity_prototype:native().order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ContainerSelector] updateGroups
--
-- @param #LuaEvent event
--
function ContainerSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)
  
  self:resetGroups()

  for key, entity in pairs(Player.getEntityPrototypes({"storage-tank", "container", "logistic-container", "cargo-wagon", "fluid-wagon", "item-with-entity-data", "car", "logistic-robot", "transport-belt"})) do
    self:appendGroups(entity.name, "entity")
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
  Logging:trace(self.classname, "buildPrototypeTooltip(player, prototype)", prototype)
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
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=element-select=ID=container=", Player.getEntityIconType(prototype), prototype.name, prototype.name, tooltip)
end



