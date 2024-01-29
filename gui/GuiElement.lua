-------------------------------------------------------------------------------
---Description of the module.
---@class GuiElement
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
---Set style
---@return GuiElement
function GuiElement:style(...)
  if ... ~= nil then
    self.options.style = table.concat({...},"_")
  end
  return self
end

-------------------------------------------------------------------------------
---Set caption
---@param caption string
---@return GuiElement
function GuiElement:caption(caption)
  self.m_caption = caption
  return self
end

-------------------------------------------------------------------------------
---Set tooltip
---@param tooltip table
---@return GuiElement
function GuiElement:tooltip(tooltip)
  if tooltip ~= nil and tooltip.classname == "HMGuiTooltip" then
    self.options.tooltip = tooltip:create()
  else
    self.options.tooltip = tooltip
  end
  return self
end

-------------------------------------------------------------------------------
---Set ignored by interaction
---@return GuiElement
function GuiElement:ignored_by_interaction()
  self.options.ignored_by_interaction = true
  return self
end

-------------------------------------------------------------------------------
---Set overlay
---@param type string
---@param name string
---@return GuiElement
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
---Get sprite string
---@param type string
---@param name string
---@param format string
---@return string
function GuiElement.getSprite(type, name, format)
  local sprite = ""
  if format == nil then
    format = "%s/%s"
  end
  if name == nil then
    sprite = string.format("helmod-%s", type)
  elseif type ~= nil and name ~= nil then
    if type == "resource" then type = "entity" end
    if type == "rocket" then type = "item" end
    if Player.is_valid_sprite_path(string.format("%s/%s", type, name)) then
      sprite = string.format(format, type, name)
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item", name)) then
      sprite = string.format(format, "item", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> item")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "entity", name)) then
      sprite = string.format(format, "entity", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> entity")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "fluid", name)) then
      sprite = string.format(format, "fluid", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> fluid")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "technology", name)) then
      sprite = string.format(format, "technology", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> technology")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "recipe", name)) then
      sprite = string.format(format, "recipe", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> recipe")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item-group", name)) then
      sprite = string.format(format, "item-group", name)
      Logging:warn(GuiButton.classname, "wrong type", type, name, "-> item-group")
    end
  end
  return sprite
end

-------------------------------------------------------------------------------
---Get options
---@return table
function GuiElement:getOptions()
  self.options.name = table.concat(self.name,"=")
  if self.is_caption then
    self.options.caption = self.m_caption
  end
  return self.options
end

-------------------------------------------------------------------------------
---Get option when error
---@return table
function GuiElement:onErrorOptions()
  local options = self:getOptions()
  options.style = nil
  return options
end

-------------------------------------------------------------------------------
---Add a element
---@param parent LuaGuiElement --container for element
---@param gui_element GuiElement
---@return LuaGuiElement --the LuaGuiElement added
function GuiElement.add(parent, gui_element)
  local element = nil
  local ok , err = pcall(function()
    if gui_element.classname ~= "HMGuiCell" then
      element = parent.add(gui_element:getOptions())
    else
      element = gui_element:create(parent)
    end
  end)
  if not ok then
    element = parent.add(gui_element:onErrorOptions())
    log(err)
    log(debug.traceback())
  end
  return element
end

-------------------------------------------------------------------------------
---Get Index column number
---@return number
function GuiElement.getIndexColumnNumber()

  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local width , height, scale = Player.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal/scale)

  return math.ceil((width_main - 100)/36)
end

-------------------------------------------------------------------------------
---Get Element column number
---@param size number
---@return number
function GuiElement.getElementColumnNumber(size)

  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local width , height, scale = Player.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal/scale)
  return math.max(5, math.floor((width_main-600)/(2*size)))
end

-------------------------------------------------------------------------------
---Get the number of textfield input
---@param element LuaGuiElement --textfield input
---@return number --number of textfield input
function GuiElement.getInputNumber(element)
  local count = 0
  if element ~= nil then
    local tempCount=tonumber(element.text)
    if type(tempCount) == "number" then count = tempCount end
  end
  return count
end

-------------------------------------------------------------------------------
---Get dropdown selection
---@param element LuaGuiElement
---@return string|table
function GuiElement.getDropdownSelection(element)
  if element.selected_index == 0 then return nil end
  if #element.items == 0 then return nil end
  return element.items[element.selected_index]
end

-------------------------------------------------------------------------------
---Set the text of textfield input
---@param element LuaGuiElement
---@param value string
function GuiElement.setInputText(element, value)
  if element ~= nil and element.text ~= nil then
    element.text = value
  end
end

-------------------------------------------------------------------------------
---Add temperature information
---@param parent LuaGuiElement
---@param element table
---@param style string
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
---Add recipe information
---@param parent LuaGuiElement
---@param element table
function GuiElement.infoRecipe(parent, element)
  local sprite_name = nil
  local tooltip = nil
  if element.type == "recipe-burnt" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.burnt)
    tooltip = {"tooltip.burnt-recipe"}
  elseif element.type == "rocket" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.rocket)
    tooltip = {"tooltip.rocket-recipe"}
  elseif element.type == "technology" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.education)
    tooltip = {"tooltip.technology-recipe"}
  elseif element.type == "energy" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.energy)
    tooltip = {"tooltip.energy-recipe"}
  elseif element.type == "boiler" then
    local style = "helmod_temperature_blue_m"
    local caption = Format.formatNumberKilo(element.output_fluid_temperature, "°")
    local label = GuiElement.add(parent, GuiLabel("temperature"):caption(caption):style(style):ignored_by_interaction())
    label.style.top_padding = -5
  elseif element.type ~= "recipe" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.developer)
    tooltip = {"tooltip.resource-recipe"}
  end
  if sprite_name ~= nil then
    local container = GuiElement.add(parent, GuiFlow("recipe-info"))
    container.style.top_padding = -4

    local sprite = GuiElement.add(container, GuiSprite("recipe-info"):sprite(sprite_name):tooltip(tooltip))
    sprite.style.width = defines.sprite_size
    sprite.style.height = defines.sprite_size
    sprite.style.stretch_image_to_widget_size = true
  end
end