require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build recipe selector
--
---@module RecipeSelector
---@extends #AbstractSelector
--

RecipeSelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
--
---@function [parent=#RecipeSelector] afterInit
--
function RecipeSelector:afterInit()
  self.unlock_recipe = true
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
  self.hidden_player_crafting = true
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function RecipeSelector:getCaption()
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function RecipeSelector:getPrototype(element, type)
  return RecipePrototype(element, type)
end

-------------------------------------------------------------------------------
---Append groups
---@param element string
---@param type string
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function RecipeSelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  local prototype = self:getPrototype(element, type)

  local lua_prototype = prototype:native()
  if lua_prototype == nil then
    return
  end
  local prototype_name = string.format("%s-%s", type, lua_prototype.name)

  for key, raw_product in pairs(prototype:getRawProducts()) do
    if list_products[raw_product.name] == nil then
      list_products[raw_product.name] = {}
    end
    list_products[raw_product.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
    
    local product = Product(raw_product)
    local localised_name = product:getLocalisedName()
    if localised_name ~= nil and localised_name ~= "unknow" then
      list_translate[raw_product.name] = localised_name
    end
  end

  for key, raw_ingredient in pairs(prototype:getRawIngredients()) do
    if list_ingredients[raw_ingredient.name] == nil then
      list_ingredients[raw_ingredient.name] = {}
    end
    list_ingredients[raw_ingredient.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
    
    local ingredient = Product(raw_ingredient)
    local localised_name = ingredient:getLocalisedName()
    if localised_name ~= nil and localised_name ~= "unknow" then
      list_translate[raw_ingredient.name] = localised_name
    end
  end
end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function RecipeSelector:updateGroups(list_products, list_ingredients, list_translate)
  RecipeSelector:updateUnlockRecipesCache()
  for key, recipe in pairs(Player.getRecipes()) do
    self:appendGroups(recipe, "recipe", list_products, list_ingredients, list_translate)
    if self:getPrototype(recipe, "recipe"):getHasBurntResult() == true then
      self:appendGroups(recipe, "recipe-burnt", list_products, list_ingredients, list_translate)
    end
  end
  for key, recipe in pairs(Player.getFluidRecipes()) do
    self:appendGroups(recipe, "fluid", list_products, list_ingredients, list_translate)
  end
  for key, recipe in pairs(Player.getBoilerRecipes()) do
    self:appendGroups(recipe, "boiler", list_products, list_ingredients, list_translate)
  end
  for key, recipe in pairs(Player.getResourceRecipes()) do
    self:appendGroups(recipe, "resource", list_products, list_ingredients, list_translate)
  end
  for key, recipe in pairs(Player.getRocketRecipes()) do
    self:appendGroups(recipe, "rocket", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
---Update unlock recipes cache
function RecipeSelector:updateUnlockRecipesCache()
  local unlock_recipes = {}
  local filters = {{filter = "hidden", invert = true, mode = "or"},{filter = "has-effects", invert = false, mode = "and"}}
  local technology_prototypes = Player.getTechnologies(filters)
  for _,technology in pairs(technology_prototypes) do
    local modifiers = technology.effects
    for _,modifier in pairs(modifiers) do
      if modifier.type == "unlock-recipe" and modifier.recipe ~= nil then
        unlock_recipes[modifier.recipe] = true
      end
    end
  end
  for _, recipe in pairs(Player.getRecipes()) do
    if recipe.enabled == true then
      unlock_recipes[recipe.name] = true
    end
  end
  Cache.setData("other", "unlock_recipes", unlock_recipes)
end

-------------------------------------------------------------------------------
---Create prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function RecipeSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local model, block, recipe = self:getParameterObjects()
  local recipe_prototype = self:getPrototype(prototype)
  local color = nil
  if recipe_prototype:getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif recipe_prototype:getEnabled() == false then
    color = "red"
  end
  local icon_name, icon_type = recipe_prototype:getIcon()
  local button_prototype = GuiButtonSelectSprite(self.classname, "element-select", prototype.type):choose(icon_type, icon_name, prototype.name):color(color)
  local button = GuiElement.add(gui_element, button_prototype)
  button.locked = true
  GuiElement.infoRecipe(button, prototype)
end

