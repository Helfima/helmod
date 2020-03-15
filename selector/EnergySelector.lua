require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build container selector
--
-- @module EnergySelector
-- @extends #AbstractSelector
--

EnergySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#EnergySelector] afterInit
--
function EnergySelector:afterInit()
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
end

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#EnergySelector] getCaption
--
-- @param #Controller parent parent controller
--
function EnergySelector:getCaption(parent)
  return {"helmod_selector-panel.energy-title"}
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#EnergySelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function EnergySelector:getPrototype(element, type)
  return RecipePrototype(element, type)
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#EnergySelector] appendGroups
--
-- @param #string element
-- @param #string type
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
-- 

function EnergySelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  local prototype = self:getPrototype(element, type)

  local lua_prototype = prototype:native()
  local prototype_name = string.format("%s-%s",type , lua_prototype.name)
  for key, element in pairs(prototype:getRawProducts()) do
    if list_products[element.name] == nil then list_products[element.name] = {} end
    list_products[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
    
    local localised_name = Product(element):getLocalisedName()
    if localised_name ~= nil and localised_name ~= "unknow" then
      list_translate[element.name] = localised_name
    end
  end
  for key, element in pairs(prototype:getRawIngredients()) do
    if list_ingredients[element.name] == nil then list_ingredients[element.name] = {} end
    list_ingredients[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end

end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#EnergySelector] updateGroups
--
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function EnergySelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, entity in pairs(Player.getEnergyMachines()) do
    self:appendGroups(entity, "energy", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#EnergySelector] buildPrototypeTooltip
--
-- @param #LuaPrototype prototype
--
function EnergySelector:buildPrototypeTooltip(prototype)
  -- initalize tooltip
  local recipe_prototype = RecipePrototype(prototype.name, "energy")
  local lua_prototype = recipe_prototype:native()
  local entity_prototype = EntityPrototype(prototype)
  local energy_name = entity_prototype:getLocalisedName()
  local tooltip = {""}
  table.insert(tooltip, energy_name)
  --table.insert(tooltip, {"", "\n",entity_prototype:getType()})
  -- products
  table.insert(tooltip, {"", "\n", "products"})
  for _,product in pairs(recipe_prototype:getProducts()) do
    if product.type == "energy" and product.name == "energy" then
        table.insert(tooltip, {"", "\n", "[img=helmod-energy-white]", "x", Format.formatNumberKilo(product.amount,"W")})
    elseif product.type == "energy" and product.name == "steam-heat" then
        table.insert(tooltip, {"", "\n", "[img=helmod-steam-heat-white]", "x", Format.formatNumberKilo(product.amount,"W")})
    else
      table.insert(tooltip, {"", "\n", string.format("[%s=%s]", product.type, product.name), "x", product.amount})
    end
  end
  -- ingredients
  table.insert(tooltip, {"", "\n", "ingredients"})
  for _,ingredient in pairs(recipe_prototype:getIngredients()) do
    if ingredient.type == "energy" and ingredient.name == "energy" then
      table.insert(tooltip, {"", "\n", "[img=helmod-energy-white]", "x", Format.formatNumberKilo(ingredient.amount,"W")})
    elseif ingredient.type == "energy" and ingredient.name == "steam-heat" then
      table.insert(tooltip, {"", "\n", "[img=helmod-steam-heat-white]", "x", Format.formatNumberKilo(ingredient.amount,"W")})
    else
      table.insert(tooltip, {"", "\n", string.format("[%s=%s]", ingredient.type, ingredient.name), "x", ingredient.amount})
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#EnergySelector] buildPrototypeIcon
--
function EnergySelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "energy"):choose("entity", prototype.name):color():tooltip(tooltip))
  button.locked = true
end
