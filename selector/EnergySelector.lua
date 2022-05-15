require "selector.AbstractSelector"
-------------------------------------------------------------------------------
---Class to build container selector
--
---@module EnergySelector
---@extends #AbstractSelector
--

EnergySelector = newclass(AbstractSelector)

-------------------------------------------------------------------------------
---After initialization
--
---@function [parent=#EnergySelector] afterInit
--
function EnergySelector:afterInit()
  self.disable_option = true
  self.hidden_option = true
  self.product_option = true
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function EnergySelector:getCaption()
  return {"helmod_selector-panel.energy-title"}
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function EnergySelector:getPrototype(element, type)
  return RecipePrototype(element, type)
end

-------------------------------------------------------------------------------
---Append groups
---@param element string
---@param type string
---@param list_products table
---@param list_ingredients table
---@param list_translate table
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
    if list_ingredients[element.name] == nil then
      list_ingredients[element.name] = {}
    end
    list_ingredients[element.name][prototype_name] = {name=lua_prototype.name, group=lua_prototype.group.name, subgroup=lua_prototype.subgroup.name, type=type, order=lua_prototype.order}
  end

end

-------------------------------------------------------------------------------
---Update groups
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function EnergySelector:updateGroups(list_products, list_ingredients, list_translate)
  for key, entity in pairs(Player.getEnergyMachines()) do
    self:appendGroups(entity, "energy", list_products, list_ingredients, list_translate)
  end
end

-------------------------------------------------------------------------------
---Build prototype tooltip line
---@param ingredient / product table
---@return table
function EnergySelector:buildPrototypeTooltipLine(item)
  local icon
  local quantity
  local detail
  if item.type == "energy" then
    local sprite = GuiElement.getSprite(defines.sprite_tooltips[item.name])
    icon = string.format("[img=%s]", sprite)
    quantity = Format.formatNumberKilo(item.amount, "W")
    detail = item.name
   else
    icon = string.format("[%s=%s] ", item.type, item.name)
    quantity = Format.formatNumberElement(item.amount)
    detail = {string.format("%s-name.%s", item.type, item.name)}
  end
  local line = {"", "\n", icon, helmod_tag.font.default_bold, quantity, " x ", helmod_tag.font.close, detail}
  if item.temperature then
    table.insert(line, string.format(" (%s °C)", item.temperature))
  end
  return line
end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function EnergySelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local recipe_prototype = RecipePrototype(prototype.name, "energy")
  local entity_prototype = EntityPrototype(prototype)
  local energy_name = entity_prototype:getLocalisedName()
  local tooltip = {""}
  table.insert(tooltip, {"", helmod_tag.font.default_bold, energy_name, helmod_tag.font.close})
  ---ingredients
  local ingredients = recipe_prototype:getIngredients(prototype)
  if table.size(ingredients) > 0 then
    table.insert(tooltip, {"", "\n", helmod_tag.font.default_bold, helmod_tag.color.gold, {"helmod_common.ingredients"}, ":", helmod_tag.color.close, helmod_tag.font.close})
    for _, ingredient in pairs(ingredients) do
      table.insert(tooltip, EnergySelector:buildPrototypeTooltipLine(ingredient))
    end
  end
  ---products
  local products = recipe_prototype:getProducts(prototype)
  if table.size(products) > 0 then
    table.insert(tooltip, {"", "\n", helmod_tag.font.default_bold, helmod_tag.color.gold, {"helmod_common.products"}, ":", helmod_tag.color.close, helmod_tag.font.close})
    for _, product in pairs(products) do
      table.insert(tooltip, EnergySelector:buildPrototypeTooltipLine(product))
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function EnergySelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  local button = GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "element-select", "energy"):choose("entity", prototype.name):color():tooltip(tooltip))
  button.locked = true
end
