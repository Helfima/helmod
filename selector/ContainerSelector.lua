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
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
  
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
-- Prepare groups
--
-- @function [parent=#RecipeSelector] prepareGroups
--
function RecipeSelector.methods:prepareGroups()
  Logging:debug(self:classname(), "prepareGroups()")
  self.list_group = {}
  self.list_subgroup = {}
  self.list_prototype = {}
  for key, entity in pairs(Player.getEntityPrototypes({"storage-tank", "container", "logistic-container", "cargo-wagon", "fluid-wagon", "item-with-entity-data", "car", "logistic-robot", "transport-belt"})) do
    self:appendGroups(entity.name, "entity")
  end
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#RecipeSelector] appendGroups2
--
-- @param #string name
-- @param #string type
--
function RecipeSelector.methods:appendGroups(name, type)
  Logging:trace(self:classname(), "appendGroups()", name, type)
  EntityPrototype.load(name, type)
  local lua_recipe = EntityPrototype.native()
  local group_name = lua_recipe.group.name
  local subgroup_name = lua_recipe.subgroup.name
  
  if firstGroup == nil then firstGroup = group_name end
  self.list_group[group_name] = lua_recipe.group
  self.list_subgroup[subgroup_name] = lua_recipe.subgroup
  if self.list_prototype[group_name] == nil then self.list_prototype[group_name] = {} end
  if self.list_prototype[group_name][subgroup_name] == nil then self.list_prototype[group_name][subgroup_name] = {} end
  table.insert(self.list_prototype[group_name][subgroup_name], {name=name, type=type, order=lua_recipe.order})
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
  local element = ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID=container=", Player.getEntityIconType(prototype), prototype.name, prototype.name, tooltip)
  return element.name,prototype.name,"entity"
end



