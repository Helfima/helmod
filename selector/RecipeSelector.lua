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
local loop = {product=0,ingredient=0}

function RecipeSelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  Logging:trace(self.classname, "appendGroups()", element.name, type)
  local prototype = self:getPrototype(element, type)

  local lua_prototype = prototype:native()
  local prototype_name = string.format("%s-%s",type , lua_prototype.name)
  Logging:trace(self.classname, "lua_recipe", lua_prototype)
  for key, element in pairs(prototype:getRawProducts()) do
    if list_products[element.name] == nil then list_products[element.name] = {} end
    list_products[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
    loop.product = loop.product + 1
    
    if lua_prototype.localised_name ~= nil then
      list_translate[element.name] = lua_prototype.localised_name
    end
  end
  for key, element in pairs(prototype:getRawIngredients()) do
    if list_ingredients[element.name] == nil then list_ingredients[element.name] = {} end
    list_ingredients[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
    loop.ingredient = loop.ingredient + 1
  end

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
  Logging:trace(self.classname, "updateGroups()")
  loop = {product=0,ingredient=0}

  for key, recipe in pairs(Player.getRecipes()) do
    self:appendGroups(recipe, "recipe", list_products, list_ingredients, list_translate)
  end
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    self:appendGroups(fluid, "fluid", list_products, list_ingredients, list_translate)
  end
  for key, resource in pairs(Player.getResources()) do
    self:appendGroups(resource, "resource", list_products, list_ingredients, list_translate)
  end

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
  local recipe_prototype = self:getPrototype(prototype)
  local type = recipe_prototype:getType()
  local prototype_name = recipe_prototype:native().name
  local prototype_localised_name = recipe_prototype:getLocalisedName()
  local color = nil
  if recipe_prototype:getCategory() == "crafting-handonly" then
    color = "yellow"
  elseif recipe_prototype:getEnabled() == false then
    color = "red"
  end
  --GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select=ID", type):sprite(prototype.type, prototype_name):caption(prototype_localised_name):tooltip(tooltip):color(color))
  GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select=ID", type):choose(prototype.type, prototype_name):color(color)).locked = true
end
