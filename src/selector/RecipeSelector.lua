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
  self.is_support_quality = true
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

  if prototype:getRawProducts() ~= nil then
    for key, raw_product in pairs(prototype:getRawProducts()) do
      if raw_product.name ~= nil then
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
    end
  end

  if prototype:getRawIngredients() ~= nil then
    for key, raw_ingredient in pairs(prototype:getRawIngredients()) do
      if raw_ingredient.name ~= nil then
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
  for key, entity in pairs(Player.getEnergyMachines()) do
    self:appendGroups(entity, "energy", list_products, list_ingredients, list_translate)
  end
  for key, recipe in pairs(Player.getAgriculturalRecipes()) do
    self:appendGroups(recipe, "agricultural", list_products, list_ingredients, list_translate)
  end
  for key, recipe in pairs(Player.getSpoilableRecipes()) do
    self:appendGroups(recipe, "spoiling", list_products, list_ingredients, list_translate)
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
      local factories = Player.getProductionsCrafting(recipe.category, recipe)
      if table.size(factories) > 0 then
        unlock_recipes[recipe.name] = true
      end
    end
  end
  Cache.setData("other", "unlock_recipes", unlock_recipes)
end

-------------------------------------------------------------------------------
---Build prototype tooltip line
---@param item ingredient / product table
---@param displayQuantity boolean
---@return table
function RecipeSelector:buildPrototypeTooltipLine(item, displayQuantity)
  local line = {"", "\n"}
  if item.type == "energy" then
    local sprite = GuiElement.getSprite(defines.sprite_tooltips[item.name])
    table.insert(line, string.format("[img=%s] ", sprite))
    table.insert(line, defines.mod.tags.font.default_bold)
    table.insert(line, Format.formatNumberKilo(item.amount, "W"))
    table.insert(line, " x ")
    table.insert(line, defines.mod.tags.font.close)
  else
    table.insert(line, string.format("[%s=%s] ", item.type, item.name))
    if displayQuantity then
      table.insert(line, defines.mod.tags.font.default_bold)
      table.insert(line, Format.formatNumberElement(item.amount))
      table.insert(line, " x ")
      table.insert(line, defines.mod.tags.font.close)    
    end
  end
  table.insert(line, Player.getLocalisedName(item))

  return line
end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function RecipeSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local tooltip = ""

  if prototype.type == "boiler" or prototype.type == "fluid" or prototype.type == "energy" then

    local recipe_prototype = RecipePrototype(prototype.name, prototype.type)
    local recipe_name
    local displayQuantity = false
    local factory = nil
    if prototype.type == "energy" then
      local entity_prototype = EntityPrototype(prototype)
      recipe_name = entity_prototype:getLocalisedName()
      factory = prototype
      displayQuantity = true
    else
      recipe_name = recipe_prototype:getLocalisedName()
    end
    tooltip = {""}

    ---heading
    table.insert(tooltip, {"", defines.mod.tags.font.default_bold, recipe_name, defines.mod.tags.font.close})

    ---ingredients
    local ingredients = recipe_prototype:getIngredients(factory)
    if table.size(ingredients) > 0 then
      table.insert(tooltip, {"", "\n", defines.mod.tags.font.default_bold, defines.mod.tags.color.gold, {"helmod_common.ingredients"}, ":", defines.mod.tags.color.close, defines.mod.tags.font.close})
      for _, ingredient in pairs(ingredients) do
        table.insert(tooltip, RecipeSelector:buildPrototypeTooltipLine(ingredient, displayQuantity))
      end
    end

    ---products
    local products = recipe_prototype:getProducts(factory)
    if table.size(products) > 0 then
      table.insert(tooltip, {"", "\n", defines.mod.tags.font.default_bold, defines.mod.tags.color.gold, {"helmod_common.products"}, ":", defines.mod.tags.color.close, defines.mod.tags.font.close})
      for _, product in pairs(products) do
        table.insert(tooltip, RecipeSelector:buildPrototypeTooltipLine(product, displayQuantity))
      end
    end

    ---made in
    local entities = {}
    if prototype.type == "boiler" then
      entities = Player.getBoilersForRecipe(recipe_prototype)
    elseif prototype.type == "fluid" then
      entities = Player.getOffshorePumps()
    end
    if table.size(entities) > 0 then
      table.insert(tooltip, {"", "\n", defines.mod.tags.font.default_bold, defines.mod.tags.color.gold, {"helmod_common.made-in"}, ":", defines.mod.tags.color.close, defines.mod.tags.font.close})
      for _, entity in pairs(entities) do
        if #tooltip >= 19 then
          table.insert(tooltip, {"", "\n", "..."})
          break
        end
        local entity_prototype = EntityPrototype(entity)
        table.insert(tooltip, {"", "\n", string.format("[%s=%s] ", "entity", entity.name), entity_prototype:getLocalisedName()})
      end
    end
  end

  return tooltip
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

  local icon_type, icon_name = recipe_prototype:getIcon()
  local button_prototype = GuiButtonSelectSprite(self.classname, "element-select", prototype.type):choose(icon_type, icon_name, prototype.name):color(color):tooltip(tooltip)
  local button = GuiElement.add(gui_element, button_prototype)

  button.locked = true
  if prototype.type == "boiler" then
    prototype.output_fluid_temperature = recipe_prototype.output_fluid_temperature
  end
  GuiElement.infoRecipe(button, prototype)
end
