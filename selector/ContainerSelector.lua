require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module ContainerSelector
-- @extends #AbstractSelector
--

ContainerSelector = setclass("HMContainerSelector", AbstractSelector)

local list_group = {}
local list_subgroup = {}
local list_prototype = {}

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#ContainerSelector] getCaption
--
-- @param #Controller parent parent controller
--
function ContainerSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.container-title"}
end

-------------------------------------------------------------------------------
-- Reset groups
--
-- @function [parent=#ContainerSelector] resetGroups
--
function ContainerSelector.methods:resetGroups()
  Logging:trace(self:classname(), "resetGroups()")
  list_group = {}
  list_subgroup = {}
  list_prototype = {}
end

-------------------------------------------------------------------------------
-- Return list prototype
--
-- @function [parent=#ContainerSelector] getListPrototype
--
-- @return #table
--
function ContainerSelector.methods:getListPrototype()
  return list_prototype
end

-------------------------------------------------------------------------------
-- Return list group
--
-- @function [parent=#ContainerSelector] getListGroup
--
-- @return #table
--
function ContainerSelector.methods:getListGroup()
  return list_group
end

-------------------------------------------------------------------------------
-- Return list subgroup
--
-- @function [parent=#ContainerSelector] getListSubgroup
--
-- @return #table
--
function ContainerSelector.methods:getListSubgroup()
  return list_subgroup
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#ContainerSelector] appendGroups
--
-- @param #string name
-- @param #string type
-- @param #table list_group
-- @param #table list_subgroup
-- @param #table list_prototype
--
function ContainerSelector.methods:appendGroups(name, type, list_group, list_subgroup, list_prototype)
  Logging:debug(self:classname(), "appendGroups()", name, type)
  EntityPrototype.load(name, type)
  local find = self:checkFilter(EntityPrototype.native())
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
  
  if find == true and (EntityPrototype.getValid() == true or filter_show_disable == true) then
    local group_name = EntityPrototype.native().group.name
    local subgroup_name = EntityPrototype.native().subgroup.name
    
    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    list_subgroup[subgroup_name] = EntityPrototype.native().subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    
    local search_products = name
    list_group[group_name].search_products = list_group[group_name].search_products .. search_products
    
    local search_ingredients = name
    list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients
    
    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=EntityPrototype.native().order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ContainerSelector] updateGroups
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ContainerSelector.methods:updateGroups(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroups()", action, item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()
  
  self:resetGroups()

  for key, entity in pairs(Player.getEntityPrototypes({"storage-tank", "container", "logistic-container", "cargo-wagon", "fluid-wagon", "item-with-entity-data", "car", "logistic-robot", "transport-belt"})) do
    self:appendGroups(entity.name, "entity", list_group, list_subgroup, list_prototype)
  end

end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#ContainerSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function ContainerSelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(player, prototype):", prototype)
  -- initalize tooltip
  local tooltip = EntityPrototype.load(prototype).getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#ContainerSelector] buildPrototypeIcon
--
function ContainerSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID=container=", Player.getEntityIconType(prototype), prototype.name, prototype.name, tooltip)
end



