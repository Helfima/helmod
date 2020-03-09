require "selector.AbstractSelector"
-------------------------------------------------------------------------------
-- Class to build container selector
--
-- @module EnergySelector
-- @extends #AbstractSelector
--

EnergySelector = newclass(AbstractSelector)

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
  return EntityPrototype(element, type)
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
  Logging:trace(self.classname, "updateGroups()")
  for key, entity in pairs(Player.getEnergyMachines()) do
    self:appendGroups(entity, "entity", list_products, list_ingredients, list_translate)
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
  Logging:trace(self.classname, "buildPrototypeTooltip(player, prototype)", prototype)
  -- initalize tooltip
  local recipe_prototype = RecipePrototype(prototype.name, "energy")
  local lua_prototype = recipe_prototype:native()
  local entity_prototype = EntityPrototype(prototype)
  local energy_name = entity_prototype:getLocalisedName()
  --Logging:debug(self.classname, "energy_name", energy_name, energy_prototype:native())
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
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "energy"):choose(prototype.type, prototype.name):color():tooltip(tooltip))
  button.locked = true
end





