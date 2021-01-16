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
  if ... ~= nil then
    self.options.style = table.concat({...},"_")
  end
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
    log(err)
  end
  return element
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
  local width , height = Player.getDisplaySizes()
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
  local width , height = Player.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal)
  return math.max(5, math.floor((width_main-600)/(2*size)))
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
