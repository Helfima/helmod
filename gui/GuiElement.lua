---
-- Description of the module.
-- 
-- @module GuiElement
--
-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] constructor
-- @param #arg name
-- @return #GuiElement
-- 
GuiElement = newclass(function(base,...)
  base.name = {...}
  base.classname = "HMGuiElement"
  base.options = {}
  base.is_caption = true
end)
GuiElement.classname = "HMGuiElement"
GuiElement.color_button_default = "gray"
GuiElement.color_button_none = "blue"
GuiElement.color_button_edit = "green"
GuiElement.color_button_add = "yellow"
GuiElement.color_button_rest = "red"
-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] style
-- @param #list style
-- @return #GuiElement
-- 
function GuiElement:style(...)
  self.options.style = table.concat({...},"_")
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] caption
-- @param #string caption
-- @return #GuiElement
-- 
function GuiElement:caption(caption)
  self.m_caption = caption
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] tooltip
-- @param #string tooltip
-- @return #GuiElement
-- 
function GuiElement:tooltip(tooltip)
  self.options.tooltip = tooltip
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] getOptions
-- @return #table
-- 
function GuiElement:getOptions()
  self.options.name = table.concat(self.name,"=")
  if self.is_caption then
    self.options.caption = self.m_caption
  end
  return self.options
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] onErrorOptions
-- @return #table
-- 
function GuiElement:onErrorOptions()
  local options = self:getOptions()
  options.style = nil
  return options
end

-------------------------------------------------------------------------------
-- Add a element
--
-- @function [parent=#GuiElement] add
--
-- @param #LuaGuiElement parent container for element
-- @param #GuiElement gui_element
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function GuiElement.add(parent, gui_element)
  Logging:trace(gui_element.classname, "add", gui_element)
  local element = nil
  local ok , err = pcall(function()
    --log(gui_element.classname)
    if gui_element.classname ~= "HMGuiCell" then
      element = parent.add(gui_element:getOptions())
    else
      element = gui_element:create(parent)
    end
  end)
  if not ok then
    element = parent.add(gui_element:onErrorOptions())
  end
  return element
end

-------------------------------------------------------------------------------
-- Get display sizes
--
-- @function [parent=#GuiElement] getDisplaySizes
--
-- return
--
function GuiElement.getDisplaySizes()
  local display_resolution = Player.native().display_resolution
  local display_scale = Player.native().display_scale
  return display_resolution.width/display_scale, display_resolution.height/display_scale
end

-------------------------------------------------------------------------------
-- Get style sizes
--
-- @function [parent=#GuiElement] getStyleSizes
--
function GuiElement.getStyleSizes()
  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local display_ratio_vertictal = User.getModSetting("display_ratio_vertical")

  local width , height = GuiElement.getDisplaySizes()
  local style_sizes = {}
  if type(width) == "number" and  type(height) == "number" then
    local width_recipe_column_1 = 240
    local width_recipe_column_2 = 250
    local width_dialog = width_recipe_column_1 + width_recipe_column_2
    local width_scroll = 8
    local width_block_info = 320
    local width_left_menu = 50
    local height_block_header = 450
    local height_selector_header = 230
    local height_recipe_info = 220
    local height_row_element = 160

    local width_main = math.ceil(width*display_ratio_horizontal)
    local height_main = math.ceil(height*display_ratio_vertictal)

    style_sizes["Tab"] = {width = width_main,height = height_main}

    style_sizes.main = {}
    style_sizes.main.width = width_main
    style_sizes.main.height = height_main

    style_sizes.dialog = {}
    style_sizes.dialog.width = width_dialog

    style_sizes.data = {}
    style_sizes.data.width = width_main - width_dialog - width_left_menu

    style_sizes.power = {}
    style_sizes.power.width = width_dialog/2
    style_sizes.power.height = 200

    style_sizes.edition_product_tool = {}
    style_sizes.edition_product_tool.height = 150

    style_sizes.data_section = {}
    style_sizes.data_section.width = width_main - width_dialog - width_left_menu - 4*width_scroll

    style_sizes.recipe_selector = {}
    style_sizes.recipe_selector.height = height_main - height_selector_header

    style_sizes.scroll_recipe_selector = {}
    style_sizes.scroll_recipe_selector.width = width_dialog - 20
    style_sizes.scroll_recipe_selector.height = height_main - height_selector_header - 20

    style_sizes.recipe_product = {}
    style_sizes.recipe_product.height = 77

    style_sizes.recipe_tab = {}
    style_sizes.recipe_tab.height = 32

    style_sizes.recipe_module = {}
    style_sizes.recipe_module.width = width_recipe_column_2 - width_scroll*2
    style_sizes.recipe_module.height = 147

    style_sizes.recipe_info_object = {}
    style_sizes.recipe_info_object.height = 155

    style_sizes.recipe_edition_1 = {}
    style_sizes.recipe_edition_1.width = width_recipe_column_1
    style_sizes.recipe_edition_1.height = 250

    style_sizes.recipe_edition_2 = {}
    style_sizes.recipe_edition_2.width = width_recipe_column_2

    style_sizes.scroll_help = {}
    style_sizes.scroll_help.width = width_dialog - width_scroll
    style_sizes.scroll_help.height = height_main - 125


    -- block
    local row_number = math.floor(Model.countModel()/GuiElement.getIndexColumnNumber())
    style_sizes.block_data = {}
    style_sizes.block_data.height = height_main - 122 - row_number*32

    style_sizes.block_info = {}
    style_sizes.block_info.width = 500
    style_sizes.block_info.height = 50*2+30

    style_sizes.scroll_block = {}
    style_sizes.scroll_block.height = height_recipe_info - 34

    -- input/output table
    style_sizes.block_element = {}
    style_sizes.block_element.height = height_row_element
    style_sizes.block_element.width = width_main - width_dialog - width_block_info

    -- input/output table
    style_sizes.scroll_block_element = {}
    style_sizes.scroll_block_element.height = height_row_element - 34

    -- recipe table
    style_sizes.scroll_block_list = {}
    style_sizes.scroll_block_list.minimal_width = width_main - width_dialog - width_scroll
    style_sizes.scroll_block_list.maximal_width = width_main - width_dialog - width_scroll

    if User.getModGlobalSetting("debug") ~= "none" then
      style_sizes.scroll_block_list.minimal_height = height_main - height_block_header - 200
      style_sizes.scroll_block_list.maximal_height = height_main - height_block_header - 200
    else
      style_sizes.scroll_block_list.minimal_height = height_main - height_block_header
      style_sizes.scroll_block_list.maximal_height = height_main - height_block_header
    end


  end
  return style_sizes
end

-------------------------------------------------------------------------------
-- Get Index column number
--
-- @function [parent=#GuiElement] getIndexColumnNumber
--
-- @return #number
--
function GuiElement.getIndexColumnNumber()

  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local width , height = GuiElement.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal)

  return math.ceil((width_main-650)/36)
end

-------------------------------------------------------------------------------
-- Get Element column number
--
-- @function [parent=#GuiElement] getElementColumnNumber
--
-- @param #number size
--
-- @return #number
--
function GuiElement.getElementColumnNumber(size)

  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local width , height = GuiElement.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal)
  return math.floor((width_main-600)/(2*size))
end
-------------------------------------------------------------------------------
-- Set style
--
-- @function [parent=#GuiElement] setStyle
--
-- @param #LuaGuiElement element
-- @param #string style
-- @param #string property
--
function GuiElement.setStyle(element, style, property)
  local style_sizes = GuiElement.getStyleSizes()
  if string.find(style, "Tab") then
    style = "Tab"
  end
  if element.style ~= nil and style_sizes[style] ~= nil and style_sizes[style][property] ~= nil then
    element.style[property] = style_sizes[style][property]
  end
end

-------------------------------------------------------------------------------
-- Get tooltip for product
--
-- @function [parent=#GuiElement] getTooltipProduct
--
-- @param #lua_product element
-- @param #string container name
--
-- @return #table
--
function GuiElement.getTooltipProduct(element, container)
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
-- @function [parent=#GuiElement] getTooltipModule
--
-- @param #string module_name
--
-- @return #table
--
function GuiElement.getTooltipModule(module_name)
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
-- @function [parent=#GuiElement] getTooltipRecipe
--
-- @param #table prototype
--
-- @return #table
--


function GuiElement.getTooltipRecipe(prototype)
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
-- @function [parent=#GuiElement] getTooltipTechnology
--
-- @param #table prototype
--
-- @return #table
--
function GuiElement.getTooltipTechnology(prototype)
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
-- Get the number of textfield input
--
-- @function [parent=#GuiElement] getInputNumber
--
-- @param #LuaGuiElement element textfield input
--
-- @return #number number of textfield input
--
function GuiElement.getInputNumber(element)
  local count = 0
  if element ~= nil then
    local tempCount=tonumber(element.text)
    if type(tempCount) == "number" then count = tempCount end
  end
  return count
end

-------------------------------------------------------------------------------
-- Get dropdown selection
--
-- @function [parent=#GuiElement] getDropdownSelection
--
-- @param #LuaGuiElement element
--
function GuiElement.getDropdownSelection(element)
  if element.selected_index == 0 then return nil end
  if #element.items == 0 then return nil end
  return element.items[element.selected_index]
end

-------------------------------------------------------------------------------
-- Set the text of textfield input
--
-- @function [parent=#GuiElement] setInputText
--
-- @param #LuaGuiElement element textfield input
-- @param #number value
--
-- @return #number number of textfield input
--
function GuiElement.setInputText(element, value)
  if element ~= nil and element.text ~= nil then
    element.text = value
  end
end
