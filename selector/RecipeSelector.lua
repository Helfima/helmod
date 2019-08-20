require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build recipe selector
--
-- @module RecipeSelector
-- @extends #AbstractSelector
--

RecipeSelector = setclass("HMRecipeSelector", AbstractSelector)

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
-- Append groups
--
-- @function [parent=#RecipeSelector] appendGroups
--
-- @param #string recipe
-- @param #string type
--

function RecipeSelector.methods:appendGroups(recipe, type)
  Logging:trace(self:classname(), "appendGroups()", recipe.name, type)
  RecipePrototype.set(recipe, type)
  local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
  local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
  
  local list_group = Cache.getData(self:classname(), "list_group")
  local list_prototype = Cache.getData(self:classname(), "list_prototype")
  local list_subgroup = Cache.getData(self:classname(), "list_subgroup")
  
  if (RecipePrototype.getEnabled() == true or filter_show_disable == true) and (RecipePrototype.getHidden() == false or filter_show_hidden == true) then
    local lua_recipe = RecipePrototype.native()
    local group_name = lua_recipe.group.name
    local subgroup_name = lua_recipe.subgroup.name
    
    list_subgroup[subgroup_name] = lua_recipe.subgroup
    
    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
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
    
    table.insert(list_prototype[group_name][subgroup_name], {name=recipe.name, type=type, order=lua_recipe.order, search_products=search_products, search_ingredients=search_ingredients})
  end
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#RecipeSelector] updateGroups
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RecipeSelector.methods:updateGroups(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroups()", action, item, item2, item3)
  local global_player = Player.getGlobal()
  local global_gui = Player.getGlobalGui()

  self:resetGroups()
  
  for key, recipe in pairs(Player.getRecipes()) do
    self:appendGroups(recipe, "recipe")
  end
  if global_gui.currentTab ~= "HMPropertiesTab" then
    for key, fluid in pairs(Player.getFluidPrototypes()) do
      self:appendGroups(fluid, "fluid")
    end
    for key, resource in pairs(Player.getResources()) do
      self:appendGroups(resource, "resource")
    end
  end
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
