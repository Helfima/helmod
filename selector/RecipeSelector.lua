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
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
  self.hidden_player_crafting = true
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
-- Get prototype
--
-- @function [parent=#RecipeSelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function RecipeSelector:getPrototype(element, type)
  return RecipePrototype(element, type)
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#RecipeSelector] appendGroups
--
-- @param #string element
-- @param #string type
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
-- 

function RecipeSelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  local prototype = self:getPrototype(element, type)
  local has_burnt_result = false

  local lua_prototype = prototype:native()
  local prototype_name = string.format("%s-%s",type , lua_prototype.name)
  for key, raw_product in pairs(prototype:getRawProducts()) do
    if list_products[raw_product.name] == nil then list_products[raw_product.name] = {} end
    list_products[raw_product.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
    
    local product = Product(raw_product)
    local localised_name = product:getLocalisedName(true)
    has_burnt_result = product:hasBurntResult()
    if localised_name ~= nil and localised_name ~= "unknow" then
      list_translate[raw_product.name] = localised_name
    end
  end
  for key, raw_ingredient in pairs(prototype:getRawIngredients()) do
    if list_ingredients[raw_ingredient.name] == nil then list_ingredients[raw_ingredient.name] = {} end
    list_ingredients[raw_ingredient.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end
  return has_burnt_result
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#RecipeSelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function RecipeSelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, recipe in pairs(Player.getRecipePrototypes()) do
    local has_burnt_result = self:appendGroups(recipe, "recipe", list_products, list_ingredients, list_translate)
    if has_burnt_result == true then
      self:appendGroups(recipe, "recipe-burnt", list_products, list_ingredients, list_translate)
    end
  end
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid, "fluid", list_products, list_ingredients, list_translate)
  end
  for key, resource in pairs(Player.getResources()) do
    self:appendGroups(resource, "resource", list_products, list_ingredients, list_translate)
  end
  for key, item in pairs(Player.getItemPrototypes()) do
    if item.rocket_launch_products ~= nil and Model.countList(item.rocket_launch_products) > 0 then
      self:appendGroups(item, "rocket", list_products, list_ingredients, list_translate)
    end
  end
end

-------------------------------------------------------------------------------
-- Create prototype icon
--
-- @function [parent=#RecipeSelector] buildPrototypeIcon
--
-- @param #table prototype
--
function RecipeSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local recipe_prototype = self:getPrototype(prototype)
  local color = nil
  if recipe_prototype:getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif recipe_prototype:getEnabled() == false then
    color = "red"
  end
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", prototype.type):choose(prototype.type, prototype.name):color(color))
  button.locked = true
  if prototype.type == "recipe-burnt" then
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({"tooltip.burnt-recipe"}))
    sprite.style.top_padding = -8
  elseif prototype.type == "rocket" then
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({"tooltip.rocket-recipe"}))
    sprite.style.top_padding = -8
  elseif prototype.type ~= "recipe" then
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({"tooltip.resource-recipe"}))
    sprite.style.top_padding = -8
  end
end
