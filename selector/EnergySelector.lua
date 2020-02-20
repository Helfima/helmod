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

  local filters = {}

  for _,type in pairs({EntityType.generator, EntityType.solar_panel, EntityType.boiler, EntityType.accumulator, EntityType.reactor}) do
    table.insert(filters, {filter="type", mode="or", invert=false, type=type})
  end
  for key, entity in pairs(Player.getEntityPrototypes(filters)) do
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
  local energy_prototype = EnergyPrototype(prototype)
  local lua_prototype = energy_prototype:native()
  local energy_name = EntityPrototype(prototype):getLocalisedName()
  --Logging:debug(self.classname, "energy_name", energy_name, energy_prototype:native())
  local tooltip = {""}
  table.insert(tooltip, energy_name)
  -- products
  table.insert(tooltip, {"", "\n", "products"})
  for _,product in pairs(energy_prototype:getProducts()) do
    if product.type == "energy" then
      table.insert(tooltip, {"", "\n", "[img=helmod-energy-white]", "x", product.amount})
    elseif product.temperature ~= nil and product.temperature >= 500 then
      table.insert(tooltip, {"", "\n", "[img=helmod-steam-heat-white]", "x", product.amount})
    else
      table.insert(tooltip, {"", "\n", string.format("[%s=%s]", product.type, product.name), "x", product.amount})
    end
  end
  -- ingredients
  table.insert(tooltip, {"", "\n", "ingredients"})
  for _,ingredient in pairs(energy_prototype:getIngredients()) do
    if ingredient.type == "energy" then
      table.insert(tooltip, {"", "\n", "[img=helmod-energy-white]", "x", ingredient.amount})
    elseif ingredient.temperature ~= nil and ingredient.temperature >= 500 then
      table.insert(tooltip, {"", "\n", "[img=helmod-steam-heat-white]", "x", ingredient.amount})
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
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  local button = GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "element-select", "container"):choose(prototype.type, prototype.name):color():tooltip(tooltip))
  button.locked = true
end





