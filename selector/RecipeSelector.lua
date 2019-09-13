require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build recipe selector
--
-- @module RecipeSelector
-- @extends #AbstractSelector
--

RecipeSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#RecipeSelector] afterInit
--
function RecipeSelector:afterInit()
  Logging:debug(self.classname, "afterInit()")
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
function RecipeSelector:getCaption(parent)
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

function RecipeSelector:appendGroups2(recipe, type)
  Logging:trace(self.classname, "appendGroups()", recipe.name, type)
  local recipe_prototype = RecipePrototype(recipe, type)
  local filter_show_disable = User.getSetting("filter_show_disable")
  local filter_show_hidden = User.getSetting("filter_show_hidden")

  local list_group = Cache.getData(self.classname, "list_group")
  local list_prototype = Cache.getData(self.classname, "list_prototype")
  local list_subgroup = Cache.getData(self.classname, "list_subgroup")

  if (recipe_prototype:getEnabled() == true or filter_show_disable == true) and (recipe_prototype:getHidden() == false or filter_show_hidden == true) then
    local lua_recipe = recipe_prototype:native()
    Logging:debug(self.classname, "lua_recipe", lua_recipe)
    local group_name = lua_recipe.group.name
    local subgroup_name = lua_recipe.subgroup.name

    list_subgroup[subgroup_name] = lua_recipe.subgroup

    if list_group[group_name] == nil then
      list_group[group_name] = {name=group_name, search_products="", search_ingredients=""}
    end
    if list_prototype[group_name] == nil then list_prototype[group_name] = {} end
    if list_prototype[group_name][subgroup_name] == nil then list_prototype[group_name][subgroup_name] = {} end

    local search_products = ""
    for key, element in pairs(recipe_prototype:getProducts()) do
      search_products = search_products .. element.name
      list_group[group_name].search_products = list_group[group_name].search_products .. search_products
    end

    local search_ingredients = ""
    for key, element in pairs(recipe_prototype:getIngredients()) do
      search_ingredients = search_ingredients .. element.name
      list_group[group_name].search_ingredients = list_group[group_name].search_ingredients .. search_ingredients
    end

    table.insert(list_prototype[group_name][subgroup_name], {name=recipe.name, type=type, order=lua_recipe.order, search_products=search_products, search_ingredients=search_ingredients})
  end
end
local loop = {product=0,ingredient=0}

function RecipeSelector:appendGroups(recipe, type, list_group, list_subgroup, list_products, list_ingredients)
  Logging:trace(self.classname, "appendGroups()", recipe.name, type)
  local recipe_prototype = RecipePrototype(recipe, type)

  local lua_recipe = recipe_prototype:native()
  Logging:trace(self.classname, "lua_recipe", lua_recipe)
  local group_name = lua_recipe.group.name
  local subgroup_name = lua_recipe.subgroup.name

  list_subgroup[subgroup_name] = lua_recipe.subgroup
  list_group[group_name] = lua_recipe.group
  
  for key, element in pairs(recipe_prototype:getRawProducts()) do
    if list_products[element.name] == nil then list_products[element.name] = {} end
    if list_products[element.name][group_name] == nil then list_products[element.name][group_name] = {} end
    list_products[element.name][group_name][lua_recipe.name] = {name=lua_recipe.name, subgroup=subgroup_name, type=type, order=lua_recipe.order}
    loop.product = loop.product + 1
  end

  for key, element in pairs(recipe_prototype:getRawIngredients()) do
    if list_ingredients[element.name] == nil then list_ingredients[element.name] = {} end
    if list_ingredients[element.name][group_name] == nil then list_ingredients[element.name][group_name] = {} end
    list_ingredients[element.name][group_name][lua_recipe.name] = {name=lua_recipe.name, subgroup=subgroup_name, type=type, order=lua_recipe.order}
    loop.ingredient = loop.ingredient + 1
  end

end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#RecipeSelector] updateGroups
--
-- @param #LuaEvent event
--
function RecipeSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)

  local list_group = {}
  local list_subgroup = {}
  local list_products = {}
  local list_ingredients = {}

  for key, recipe in pairs(Player.getRecipes()) do
    self:appendGroups(recipe, "recipe", list_group, list_subgroup, list_products, list_ingredients)
  end
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid, "fluid", list_group, list_subgroup, list_products, list_ingredients)
  end
  for key, resource in pairs(Player.getResources()) do
    self:appendGroups(resource, "resource", list_group, list_subgroup, list_products, list_ingredients)
  end
  
  Cache.setData(self.classname, "list_group", list_group)
  Cache.setData(self.classname, "list_subgroup", list_subgroup)
  Cache.setData(self.classname, "list_products", list_products)
  Cache.setData(self.classname, "list_ingredients", list_ingredients)
  --Player.print(string.format("product=%d , ingredient=%s", loop.product, loop.ingredient))
end

-------------------------------------------------------------------------------
-- Create recipe tooltip
--
-- @function [parent=#RecipeSelector] buildPrototypeTooltip
--
-- @param #table prototype
--
function RecipeSelector:buildPrototypeTooltip(prototype)
  Logging:trace(self.classname, "buildRecipeTooltip(element)", prototype)
  return ElementGui.getTooltipRecipe(prototype)
end

-------------------------------------------------------------------------------
-- Create prototype icon
--
-- @function [parent=#RecipeSelector] buildPrototypeIcon
--
-- @param #table prototype
--
function RecipeSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  local recipe_prototype = RecipePrototype(prototype)
  local type = recipe_prototype:getType()
  local prototype_name = recipe_prototype:native().name
  local prototype_localised_name = recipe_prototype:getLocalisedName()
  local color = nil
  if recipe_prototype:getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif recipe_prototype:getEnabled() == false then
    color = "red"
  end
  --GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", type):sprite(Player.getRecipeIconType(recipe_prototype:native()), prototype_name.."1"):caption(prototype_localised_name):tooltip(tooltip):color(color))
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=element-select=ID="..type.."=", Player.getRecipeIconType(recipe_prototype:native()), prototype_name, prototype_localised_name, tooltip, color)
end
