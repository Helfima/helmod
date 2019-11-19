-------------------------------------------------------------------------------
-- Class to help to build GuiTooltip
--
-- @module GuiTooltip
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltip
--
GuiTooltip = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] element
-- @param #table element
-- @return #GuiCell
--
function GuiTooltip:element(element)
  self.element = element
  return self
end

-------------------------------------------------------------------------------
-- Get tooltip for container
--
-- @function [parent=#GuiTooltip] container
--
-- @param #lua_product element
-- @param #string container name
--
-- @return #table
--
function GuiTooltip.container(element, container)
  local entity_prototype = EntityPrototype(container)
  local tooltip = {"tooltip.cargo-info", entity_prototype:getLocalisedName()}
  local product_prototype = Product(element)
  local total_tooltip = {"tooltip.cargo-info-element", {"helmod_common.total"}, Format.formatNumberElement(product_prototype:countContainer(element.count, container))}
  if element.limit_count ~= nil then
    local limit_tooltip = {"tooltip.cargo-info-element", {"helmod_common.per-sub-block"}, Format.formatNumberElement(product_prototype:countContainer(element.limit_count, container))}
    table.insert(tooltip, limit_tooltip)
    table.insert(tooltip, total_tooltip)
  else
    table.insert(tooltip, total_tooltip)
    table.insert(tooltip, "")
  end
  return tooltip
end

-------------------------------------------------------------------------------
-- Get tooltip for module
--
-- @function [parent=#GuiTooltip] module
--
-- @param #string module_name
--
-- @return #table
--
function GuiTooltip.module(module_name)
  local tooltip = nil
  if module_name == nil then return nil end
  local module_prototype = ItemPrototype(module_name)
  local module = module_prototype:native()
  if module ~= nil then
    local consumption = Format.formatPercent(Player.getModuleBonus(module.name, "consumption"))
    local speed = Format.formatPercent(Player.getModuleBonus(module.name, "speed"))
    local productivity = Format.formatPercent(Player.getModuleBonus(module.name, "productivity"))
    local pollution = Format.formatPercent(Player.getModuleBonus(module.name, "pollution"))
    tooltip = {"tooltip.module-description" , module_prototype:getLocalisedName(), consumption, speed, productivity, pollution}
  end
  return tooltip
end

-------------------------------------------------------------------------------
-- Get tooltip for recipe
--
-- @function [parent=#GuiTooltip] recipe
--
-- @param #table prototype
--
-- @return #table
--


function GuiTooltip.recipe(prototype)
  local recipe_prototype = RecipePrototype(prototype)
  if recipe_prototype:native() == nil then return nil end
  local cache_tooltip_recipe = Cache.getData(GuiElement.classname, "tooltip_recipe") or {}
  local prototype_type = prototype.type or "other"
  if cache_tooltip_recipe[prototype_type] ~= nil and cache_tooltip_recipe[prototype_type][prototype.name] ~= nil and cache_tooltip_recipe[prototype_type][prototype.name].enabled == recipe_prototype:getEnabled() then
    return cache_tooltip_recipe[prototype_type][prototype.name].value
  end
  -- initalize tooltip
  local tooltip = {"tooltip.recipe-info"}
  -- insert __1__ value
  table.insert(tooltip, recipe_prototype:getLocalisedName())

  -- insert __2__ value
  if recipe_prototype:getCategory() == "crafting-handonly" then
    table.insert(tooltip, {"tooltip.recipe-by-hand"})
  else
    table.insert(tooltip, "")
  end

  -- insert __3__ value
  local lastTooltip = tooltip
  for _,element in pairs(recipe_prototype:getRawProducts()) do
    local product_prototype = Product(element)
    local count = product_prototype:getElementAmount()
    local name = product_prototype:getLocalisedName()
    local currentTooltip = {"tooltip.recipe-info-element", string.format("[%s=%s]",element.type,element.name), count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")

  -- insert __4__ value
  local lastTooltip = tooltip
  for _,element in pairs(recipe_prototype:getRawIngredients()) do
    local product_prototype = Product(element)
    local count = product_prototype:getElementAmount(element)
    local name = product_prototype:getLocalisedName()
    local currentTooltip = {"tooltip.recipe-info-element", string.format("[%s=%s]",element.type,element.name), count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")
  if cache_tooltip_recipe[prototype_type] == nil then cache_tooltip_recipe[prototype_type] = {} end
  cache_tooltip_recipe[prototype_type][prototype.name] = {}
  cache_tooltip_recipe[prototype_type][prototype.name].value = tooltip
  cache_tooltip_recipe[prototype_type][prototype.name].enabled = recipe_prototype:getEnabled()
  Cache.setData(GuiElement.classname, "tooltip_recipe",cache_tooltip_recipe)
  return tooltip
end

-------------------------------------------------------------------------------
-- Get tooltip for technology
--
-- @function [parent=#GuiTooltip] technology
--
-- @param #table prototype
--
-- @return #table
--
function GuiTooltip.technology(prototype)
  -- initalize tooltip
  local tooltip = {"tooltip.technology-info"}
  local technology_protoype = Technology(prototype)
  -- insert __1__ value
  table.insert(tooltip, technology_protoype:getLocalisedName())

  -- insert __2__ value
  table.insert(tooltip, technology_protoype:getLevel())

  -- insert __3__ value
  table.insert(tooltip, technology_protoype:getFormula() or "")

  -- insert __4__ value
  local lastTooltip = tooltip
  for _,element in pairs(technology_protoype:getIngredients()) do
    local count = Product.getElementAmount(element)
    local name = Player.getLocalisedName(element)
    local currentTooltip = {"tooltip.recipe-info-element", string.format("[%s=%s]",element.type,element.name), count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")
  return tooltip
end

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltip] create
--
function GuiTooltip:create()
  local tooltip = {""}
  if string.find(self.name[1], "edit") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-edit]", " ", "[color=255,222,61]", "[font=default-bold]", self.name, "[/font]", "[/color]", "\n"})
  elseif string.find(self.name[1], "add") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-add]", " ", "[color=255,222,61]", "[font=default-bold]", self.name, "[/font]", "[/color]", "\n"})
  elseif string.find(self.name[1], "info") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-info]", " ", "[color=229,229,229]", "[font=default-bold]", self.name, "[/font]", "[/color]", "\n"})
  else
    table.insert(tooltip, {"", "[img=helmod-tooltip-blank]", " ", "[font=default-bold]", self.name, "[/font]", "\n"})
  end
  if self.element then
    table.insert(tooltip, {"", string.format("[%s=%s]", self.element.type, self.element.name), " ", "[color=255,230,192]", "[font=default-bold]", Player.getLocalisedName(self.element), "[/font]", "[/color]"})
  end
  return tooltip
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipElement
--
GuiTooltipElement = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipElement] create
--
function GuiTooltipElement:create()
  local tooltip = self._super.create(self)
  -- quantity
  local total_count = Format.formatNumberElement(self.element.count)
  if self.element.limit_count ~= nil then
    local limit_count = Format.formatNumberElement(self.element.limit_count)
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", "[color=255,230,192]", "[font=default-bold]", {"helmod_common.quantity"}, ": ", "[/font]", "[/color]", limit_count or 0, "/", total_count})
  else
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", "[color=255,230,192]", "[font=default-bold]", {"helmod_common.quantity"}, ": ", "[/font]", "[/color]", total_count or 0})
  end
  if User.getModGlobalSetting("debug") ~= "none" then
    table.insert(tooltip, {"", "\n", "----------------------", "\n"})
    table.insert(tooltip, {"", "[img=developer]", " ", "State", ": ", "[font=default-bold]", self.element.state or 0, "[/font]"})
  end
  return tooltip
end
