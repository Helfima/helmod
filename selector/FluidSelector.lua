require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module FluidSelector
-- @extends #AbstractSelector
--

FluidSelector = setclass("HMFluidSelector", AbstractSelector)

local firstGroup = nil

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#FluidSelector] getCaption
--
-- @param #Controller parent parent controller
--
function FluidSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.item-title"}
end

-------------------------------------------------------------------------------
-- Check filter
--
-- @function [parent=#FluidSelector] checkFilter
--
-- @param #LuaFluidPrototype prototype
--
-- @return boolean
--
function FluidSelector.methods:checkFilter(prototype)
  Logging:trace(self:classname(), "checkFilter()")
  local filter_prototype = self:getFilter()
  local filter_prototype_product = self:getProductFilter()

  if filter_prototype ~= nil and filter_prototype ~= "" then
    if filter_prototype_product ~= true then
      local search = prototype.name:lower():gsub("[-]"," ")
      if string.find(search, filter_prototype) then
        return true
      end
    end
  else
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#FluidSelector] appendGroups
--
-- @param #string name
-- @param #string type
-- @param #table list_group
-- @param #table list_subgroup
-- @param #table list_prototype
--
function FluidSelector.methods:appendGroups(fluid, type, list_group, list_subgroup, list_prototype)
  Logging:debug(self:classname(), "appendGroups()", fluid.name, type)
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")

  if (fluid.valid == true or filter_show_disable == true) then
    FluidPrototype.load(fluid.name, type)
    local find = self:checkFilter(FluidPrototype.native())

    if find == true then
      local group_name = FluidPrototype.native().group.name
      local subgroup_name = FluidPrototype.native().subgroup.name
      
      if firstGroup == nil then firstGroup = group_name end
      list_group[group_name] = FluidPrototype.native().group
      list_subgroup[subgroup_name] = FluidPrototype.native().subgroup
      if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
      if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
      table.insert(list_prototype[group_name][subgroup_name], {name=fluid.name, type=type, order=FluidPrototype.native().order})
    end
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#FluidSelector] updateGroups
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return list_group, list_subgroup, list_prototype
--
function FluidSelector.methods:updateGroups(item, item2, item3)
  Logging:debug(self:classname(), "updateGroups():", item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()
  -- recuperation recipes
  local list_group = {}
  local list_subgroup = {}
  local list_prototype = {}

  firstGroup = nil

  for key, recipe in pairs(Player.getFluidPrototypes()) do
    self:appendGroups({name = recipe.name, valid = recipe.valid}, "recipe", list_group, list_subgroup, list_prototype)
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
-- @function [parent=#FluidSelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function FluidSelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(player, prototype):", prototype)
  -- initalize tooltip
  local tooltip = FluidPrototype.load(prototype).getLocalisedName()
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#FluidSelector] buildPrototypeIcon
--
function FluidSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID=fluid=", Player.getItemIconType(prototype), prototype.name, prototype.name, tooltip)
end



