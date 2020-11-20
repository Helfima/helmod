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
GuiElement.color_button_default_product = "blue"
GuiElement.color_button_default_ingredient = "yellow"
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
  if tooltip ~= nil and tooltip.classname == "HMGuiTooltip" then
    self.options.tooltip = tooltip:create()
  else
    self.options.tooltip = tooltip
  end
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] overlay
-- @param #string type
-- @param #string name
-- @return #GuiElement
-- 
function GuiElement:overlay(type, name)
  if type == nil then return self end
  if name == nil then
    self.m_overlay = string.format("helmod-%s", type)
  elseif type ~= nil and name ~= nil then
    if type == "resource" then type = "item" end
    if Player.is_valid_sprite_path(string.format("%s/%s", type, name)) then
      self.m_overlay = string.format("%s/%s", type, name)
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item", name)) then
      self.m_overlay = string.format("%s/%s", "item", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> item")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "entity", name)) then
      self.m_overlay = string.format("%s/%s", "entity", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> entity")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "fluid", name)) then
      self.m_overlay = string.format("%s/%s", "fluid", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> fluid")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "technology", name)) then
      self.m_overlay = string.format("%s/%s", "technology", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> technology")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "recipe", name)) then
      self.m_overlay = string.format("%s/%s", "recipe", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> recipe")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item-group", name)) then
      self.m_overlay = string.format("%s/%s", "item-group", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> item-group")
    end
  end
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] getSprite
-- @param #string type
-- @param #string name
-- @return #GuiElement
-- 
function GuiElement.getSprite(type, name)
  local sprite = ""
  if name == nil then
    sprite = string.format("helmod-%s", type)
  elseif type ~= nil and name ~= nil then
    if type == "resource" then type = "entity" end
    if type == "rocket" then type = "item" end
    if Player.is_valid_sprite_path(string.format("%s/%s", type, name)) then
      sprite = string.format("%s/%s", type, name)
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item", name)) then
      sprite = string.format("%s/%s", "item", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> item")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "entity", name)) then
      sprite = string.format("%s/%s", "entity", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> entity")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "fluid", name)) then
      sprite = string.format("%s/%s", "fluid", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> fluid")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "technology", name)) then
      sprite = string.format("%s/%s", "technology", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> technology")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "recipe", name)) then
      sprite = string.format("%s/%s", "recipe", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> recipe")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item-group", name)) then
      sprite = string.format("%s/%s", "item-group", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> item-group")
    end
  end
  return sprite
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] getOptions
-- @return #table
-- 
function GuiElement:getOptions()
  if self.m_index ~= nil then
    table.insert(self.name, self.m_index)
  end
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
-- Get main sizes
--
-- @function [parent=#GuiElement] getMainSizes
--
-- return
--
function GuiElement.getMainSizes()
  local width , height = GuiElement.getDisplaySizes()
  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local display_ratio_vertictal = User.getModSetting("display_ratio_vertical")
  if type(width) == "number" and  type(height) == "number" then
    local width_main = math.ceil(width*display_ratio_horizontal)
    local height_main = math.ceil(height*display_ratio_vertictal)
    return width_main, height_main
  end
  return 800,600
end

-------------------------------------------------------------------------------
-- Get style sizes
--
-- @function [parent=#GuiElement] getStyleSizes
--
function GuiElement.getStyleSizes()
  local width_main, height_main = GuiElement.getMainSizes()
  local style_sizes = {}

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

  style_sizes["Tab"] = {width = width_main,height = height_main}
  style_sizes["HMRecipeExplorer"] = {
    minimal_width = 300,
    maximal_width = width_main,
    minimal_height = 200,
    maximal_height = height_main
    }
  
  style_sizes["HMModelDebug"] = {
    width = width_main,
    minimal_height = 200,
    maximal_height = height_main
    }
    
  style_sizes["HMPinPanel"] = {
    minimal_width = 50,
    maximal_width = 600,
    minimal_height = 0,
    maximal_height = height_main
    }
  
  style_sizes["HMSummaryPanel"] = {
    minimal_width = 50,
    maximal_width = 450,
    minimal_height = 0,
    maximal_height = height_main
    }
    
  style_sizes["HMRichTextPanel"] = {
    minimal_width = 322,
    maximal_width = 322,
    minimal_height = 300,
    maximal_height = height_main
    }
      
      
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
  style_sizes.block_info.height = 50*2+40

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

  style_sizes.scroll_block_list.minimal_height = height_main - height_block_header
  style_sizes.scroll_block_list.maximal_height = height_main - height_block_header

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

  return math.ceil((width_main - 100)/36)
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
  return math.max(5, math.floor((width_main-600)/(2*size)))
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

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] infoTemperature
--
function GuiElement.infoTemperature(parent, element, style)
  if element.type == "fluid" then
    style = style or "helmod_label_element_black_m"
    local T = element.temperature
    local Tmin = element.minimum_temperature 
    local Tmax = element.maximum_temperature 
    if T ~= nil then
      local caption = {"",  T, "°"}
      GuiElement.add(parent, GuiLabel("temperature"):caption(caption):style(style))
    end
    if Tmin ~= nil or Tmax ~= nil then
      Tmin = Tmin or -1e300
      Tmax = Tmax or 1e300
      if Tmin > -1e300 and Tmax > 1e300 then
        local caption_min = {"",  "≥", Tmin, "°"}
        GuiElement.add(parent, GuiLabel("temperature_min"):caption(caption_min):style(style))
      end
      if Tmin < -1e300 and Tmax < 1e300 then
        local caption_max = {"", "≤", Tmax, "°"}
        GuiElement.add(parent, GuiLabel("temperature_max"):caption(caption_max):style(style))
      end
      if Tmin > -1e300 and Tmax < 1e300 then
        local panel = GuiElement.add(parent, GuiFlowV("temperature"))
        local caption_min = {"", "≥", Tmin, "°"}
        GuiElement.add(panel, GuiLabel("temperature_min"):caption(caption_min):style(style))
        local caption_max = {"", "≤", Tmax, "°"}
        GuiElement.add(panel, GuiLabel("temperature_max"):caption(caption_max):style(style))
      end
      
    end
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] infoTemperature
--
function GuiElement.infoRecipe(parent, element)
  if element.type == "recipe-burnt" then
    local sprite = GuiElement.add(parent, GuiSprite("recipe-info"):sprite("developer"):tooltip({"tooltip.burnt-recipe"}))
    sprite.style.top_padding = -8
  elseif element.type == "rocket" then
    local sprite = GuiElement.add(parent, GuiSprite("recipe-info"):sprite("developer"):tooltip({"tooltip.rocket-recipe"}))
    sprite.style.top_padding = -8
  elseif element.type == "technology" then
    local sprite = GuiElement.add(parent, GuiSprite("recipe-info"):sprite("developer"):tooltip({"tooltip.technology-recipe"}))
    sprite.style.top_padding = -8
  elseif element.type ~= "recipe" then
    local sprite = GuiElement.add(parent, GuiSprite("recipe-info"):sprite("developer"):tooltip({"tooltip.resource-recipe"}))
    sprite.style.top_padding = -8
  end
end
