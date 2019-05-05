require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build technology selector
--
-- @module FluidSelector
-- @extends #AbstractSelector
--

FluidSelector = setclass("HMFluidSelector", AbstractSelector)

local firstGroup = nil
local list_group = {}
local list_subgroup = {}
local list_prototype = {}

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
-- Reset groups
--
-- @function [parent=#FluidSelector] resetGroups
--
function FluidSelector.methods:resetGroups()
  Logging:trace(self:classname(), "resetGroups()")
  list_group = {}
  list_subgroup = {}
  list_prototype = {}
end

-------------------------------------------------------------------------------
-- Return list prototype
--
-- @function [parent=#FluidSelector] getListPrototype
--
-- @return #table
--
function FluidSelector.methods:getListPrototype()
  return list_prototype
end

-------------------------------------------------------------------------------
-- Return list group
--
-- @function [parent=#FluidSelector] getListGroup
--
-- @return #table
--
function FluidSelector.methods:getListGroup()
  return list_group
end

-------------------------------------------------------------------------------
-- Return list subgroup
--
-- @function [parent=#FluidSelector] getListSubgroup
--
-- @return #table
--
function FluidSelector.methods:getListSubgroup()
  return list_subgroup
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
function FluidSelector.methods:appendGroups(name, type, list_group, list_subgroup, list_prototype)
  Logging:debug(self:classname(), "appendGroups()", name, type)
  FluidPrototype.load(name, type)
  local find = self:checkFilter(FluidPrototype.native())
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
  
  if find == true and (FluidPrototype.getValid() == true or filter_show_disable == true) then
    local group_name = FluidPrototype.native().group.name
    local subgroup_name = FluidPrototype.native().subgroup.name
    
    if firstGroup == nil then firstGroup = group_name end
    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    list_subgroup[subgroup_name] = FluidPrototype.native().subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    
    local search_products = ""
    for key, element in pairs(RecipePrototype.getProducts()) do
      search_products = search_products .. element.name
      list_group[group_name].search_products = list_group[group_name].search_products .. search_products
    end
    
    local search_ingredients = ""
    for key, element in pairs(RecipePrototype.getIngredients()) do
      search_ingredients = search_ingredients .. element.name
      list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients
    end
    
    table.insert(list_prototype[group_name][subgroup_name], {name=name, type=type, order=FluidPrototype.native().order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#FluidSelector] updateGroups
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function FluidSelector.methods:updateGroups(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroups()", action, item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()

  self:resetGroups()

  firstGroup = nil

  for key, recipe in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(recipe.name, "recipe", list_group, list_subgroup, list_prototype)
  end

  if list_prototype[global_player.recipeGroupSelected] == nil then
    global_player.recipeGroupSelected = firstGroup
  end
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



