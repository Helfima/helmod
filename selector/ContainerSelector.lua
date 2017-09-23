require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module ContainerSelector
-- @extends #AbstractSelector
--

ContainerSelector = setclass("HMContainerSelector", AbstractSelector)

local firstGroup = nil

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
-- Check filter
--
-- @function [parent=#ContainerSelector] checkFilter
--
-- @param #LuaEntityPrototype prototype
--
-- @return boolean
--
function ContainerSelector.methods:checkFilter(prototype)
  Logging:trace(self:classname(), "checkFilter()")
  local filter_prototype = self:getFilter()
  local filter_prototype_product = self:getProductFilter()
  local find = false
  if filter_prototype ~= nil and filter_prototype ~= "" then
    if filter_prototype_product ~= true then
      local search = prototype.name:lower():gsub("[-]"," ")
      if string.find(search, filter_prototype) then
        find = true
      end
    end
  else
    find = true
  end
  return find
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
    
    if firstGroup == nil then firstGroup = group_name end
    list_group[group_name] = EntityPrototype.native().group
    list_subgroup[subgroup_name] = EntityPrototype.native().subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=EntityPrototype.native().order})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#ContainerSelector] updateGroups
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return list_group, list_subgroup, list_prototype
--
function ContainerSelector.methods:updateGroups(item, item2, item3)
  Logging:debug(self:classname(), "updateGroups():", item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()
  -- recuperation recipes
  local list_group = {}
  local list_subgroup = {}
  local list_prototype = {}

  firstGroup = nil

  for key, entity in pairs(Player.getEntityPrototypes({"storage-tank", "container", "logistic-container", "cargo-wagon", "fluid-wagon", "item-with-entity-data", "car", "logistic-robot"})) do
    self:appendGroups(entity.name, "entity", list_group, list_subgroup, list_prototype)
  end

  if list_prototype[global_player.recipeGroupSelected] == nil then
    global_player.recipeGroupSelected = firstGroup
  end
  Logging:debug(self:classname(), "list_group", list_group, "list_subgroup", list_subgroup, "list_prototype", list_prototype)
  return list_group, list_subgroup, list_prototype
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



