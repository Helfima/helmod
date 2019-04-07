require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build recipe selector
--
-- @module RecipeSelector
-- @extends #AbstractSelector
--

RecipeSelector = setclass("HMRecipeSelector", AbstractSelector)

local firstGroup = nil

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#RecipeSelector] afterInit
--
function RecipeSelector.methods:afterInit()
  Logging:debug(self:classname(), "afterInit()")
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
end

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#RecipeSelector] getCaption
--
-- @param #Controller parent parent controller
--
function RecipeSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
-- Check filter
--
-- @function [parent=#RecipeSelector] checkFilter
--
-- @param #RecipePrototype recipe_prototype
--
-- @return boolean
--
function RecipeSelector.methods:checkFilter(recipe_prototype)
  Logging:trace(self:classname(), "checkFilter()")
  local filter_prototype = self:getFilter()
  local filter_prototype_product = self:getProductFilter()
  local find = false
  if filter_prototype ~= nil and filter_prototype ~= "" then
    local elements = recipe_prototype.getProducts()
    if filter_prototype_product ~= true then
      elements = recipe_prototype.getIngredients()
    end

    for key, element in pairs(elements) do
      local search = element.name:lower():gsub("[-]"," ")
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
-- @function [parent=#RecipeSelector] appendGroups
--
-- @param #string recipe
-- @param #string type
-- @param #table list_group
-- @param #table list_subgroup
-- @param #table list_prototype
--
function RecipeSelector.methods:appendGroups(recipe, type, list_group, list_subgroup, list_prototype)
  Logging:trace(self:classname(), "appendGroups()", recipe.name, type)
  RecipePrototype.set(recipe, type)
  local find = self:checkFilter(RecipePrototype)
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
  
  if find == true and (RecipePrototype.getEnabled() == true or filter_show_disable == true) and (RecipePrototype.getHidden() == false or filter_show_hidden == true) then
    local lua_recipe = RecipePrototype.native()
    local group_name = lua_recipe.group.name
    local subgroup_name = lua_recipe.subgroup.name
    
    if firstGroup == nil then firstGroup = group_name end
    list_group[group_name] = lua_recipe.group
    list_subgroup[subgroup_name] = lua_recipe.subgroup
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end
    table.insert(list_prototype[group_name][subgroup_name], {name=recipe.name, type=type, order=lua_recipe.order})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#RecipeSelector] updateGroups
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return list_group, list_subgroup, list_prototype
--
function RecipeSelector.methods:updateGroups(item, item2, item3)
  Logging:trace(self:classname(), "updateGroups():", item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()
  -- recuperation recipes
  local list_group = {}
  local list_subgroup = {}
  local list_prototype = {}
  --Logging:debug(Controller.classname, "filter_prototype", self:getFilter())
  firstGroup = nil
  for key, recipe in pairs(Player.getRecipes()) do
    self:appendGroups(recipe, "recipe", list_group, list_subgroup, list_prototype)
  end
  if global_gui.currentTab ~= "HMPropertiesTab" then
    for key, fluid in pairs(Player.getFluidPrototypes()) do
      self:appendGroups(fluid, "fluid", list_group, list_subgroup, list_prototype)
    end
    for key, resource in pairs(Player.getResources()) do
      self:appendGroups(resource, "resource", list_group, list_subgroup, list_prototype)
    end
  end

  if list_prototype[global_player.recipeGroupSelected] == nil then
    global_player.recipeGroupSelected = firstGroup
  end
  Logging:trace(self:classname(), "list_group", list_group, "list_subgroup", list_subgroup, "list_prototype", list_prototype)
  return list_group, list_subgroup, list_prototype
end

-------------------------------------------------------------------------------
-- Build recipe tooltip
--
-- @function [parent=#RecipeSelector] buildPrototypeTooltip
--
-- @param #table prototype
-- 
function RecipeSelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildRecipeTooltip(element):", prototype)
  return ElementGui.getTooltipRecipe(prototype)
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#RecipeSelector] buildPrototypeIcon
--
-- @param #table prototype
-- 
function RecipeSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  local recipe_prototype = RecipePrototype.load(prototype)
  local type = RecipePrototype.type()
  local prototype_name = RecipePrototype.native().name
  local prototype_localised_name = RecipePrototype.getLocalisedName()
  local color = nil
  if RecipePrototype.getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif RecipePrototype.getEnabled() == false then
    color = "red"
  end
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=element-select=ID="..type.."=", Player.getRecipeIconType(RecipePrototype.native()), prototype_name, prototype_localised_name, tooltip, color)
end
