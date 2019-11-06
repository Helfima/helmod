---
-- Description of the module.
-- @module ElementGui
--
local ElementGui = {
  -- single-line comment
  classname = "HMElementGui",
  color_button_edit = "green",
  color_button_add = "yellow",
  color_button_rest = "red"
}

-------------------------------------------------------------------------------
-- Get the number of textfield input
--
-- @function [parent=#ElementGui] getInputNumber
--
-- @param #LuaGuiElement element textfield input
--
-- @return #number number of textfield input
--
function ElementGui.getInputNumber(element)
  Logging:trace(ElementGui.classname, "getInputNumber", element)
  local count = 0
  if element ~= nil then
    local tempCount=tonumber(element.text)
    if type(tempCount) == "number" then count = tempCount end
  end
  return count
end

-------------------------------------------------------------------------------
-- Set the number of textfield input
--
-- @function [parent=#ElementGui] setInputNumber
--
-- @param #LuaGuiElement element textfield input
-- @param #number value
--
-- @return #number number of textfield input
--
function ElementGui.setInputNumber(element, value)
  Logging:trace(ElementGui.classname, "setInputNumber", element, value)
  if element ~= nil and element.text ~= nil then
    element.text = value
  end
end

-------------------------------------------------------------------------------
-- Set the text of textfield input
--
-- @function [parent=#ElementGui] setInputText
--
-- @param #LuaGuiElement element textfield input
-- @param #number value
--
-- @return #number number of textfield input
--
function ElementGui.setInputText(element, value)
  Logging:trace(ElementGui.classname, "setInputText", element, value)
  if element ~= nil and element.text ~= nil then
    element.text = value
  end
end

-------------------------------------------------------------------------------
-- Add a sprite element
--
-- @function [parent=#ElementGui] addSprite
--
-- @param #LuaGuiElement parent container for element
-- @param #string sprite name of sprite
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addSprite(parent, sprite)
  Logging:trace(ElementGui.classname, "addSprite", parent, key, caption, style, tooltip, single_line)
  return parent.add({type = "sprite", sprite= sprite})
end

-------------------------------------------------------------------------------
-- Add a label element
--
-- @function [parent=#ElementGui] addGuiLabel
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string caption displayed text
-- @param #string style style of label
-- @param #string tooltip displayed text
-- @param #boolean single_line
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiLabel(parent, key, caption, style, tooltip, single_line)
  Logging:trace(ElementGui.classname, "addGuiLabel", parent, key, caption, style, tooltip, single_line)
  local options = {}
  options.type = "label"
  options.name = key
  options.caption = caption
  if style ~= nil then
    options.style = style
  end
  if tooltip ~= nil then
    options.tooltip = tooltip
  end
  local label = parent.add(options)
  if single_line ~= nil then
    label.style.single_line = single_line
  end
  return label
end

-------------------------------------------------------------------------------
-- Add a input element
--
-- @function [parent=#ElementGui] addGuiText
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string text input text
-- @param #string style style of text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiText(parent, key, text, style, tooltip)
  Logging:trace(ElementGui.classname, "addGuiText", parent, key, text, style, tooltip)
  local options = {}
  options.type = "textfield"
  options.name = key
  options.text = ""
  if text ~= nil then
    options.text = text
  end
  if style ~= nil then
    options.style = style
  end
  if tooltip ~= nil then
    options.tooltip = tooltip
  end
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a text box element
--
-- @function [parent=#ElementGui] addGuiTextbox
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string text input text
-- @param #string style style of text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiTextbox(parent, key, text, style, tooltip)
  Logging:trace(ElementGui.classname, "addGuiTextbox", parent, key, text, style, tooltip)
  local options = {}
  options.type = "text-box"
  options.name = key
  options.text = ""
  if text ~= nil then
    options.text = text
  end
  if style ~= nil then
    options.style = style
  end
  if tooltip ~= nil then
    options.tooltip = tooltip
  end
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a button element
--
-- @function [parent=#ElementGui] addGuiButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string switch_state
-- @param #string allow_none_state
-- @param #string left_label_caption
-- @param #string left_label_tooltip
-- @param #string right_label_caption
-- @param #string right_label_tooltip
-- @param #string style style of button
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiSwitch(parent, action, switch_state, allow_none_state, left_label_caption, left_label_tooltip, right_label_caption, right_label_tooltip, style, tooltip)
  Logging:trace(ElementGui.classname, "addGuiSwitch", action, switch_state, allow_none_state, left_label_caption, left_label_tooltip, right_label_caption, right_label_tooltip, style, tooltip)
  local options = {}
  options.type = "switch"
  options.name = action
  options.switch_state = switch_state
  options.allow_none_state = allow_none_state
  options.left_label_caption = left_label_caption
  options.left_label_tooltip = left_label_tooltip
  options.right_label_caption = right_label_caption
  options.right_label_tooltip = right_label_tooltip
  options.tooltip = tooltip
  options.style = style
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a button element
--
-- @function [parent=#ElementGui] addGuiButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #string style style of button
-- @param #string caption container for element
-- @param #string tooltip displayed text
-- @param #number size
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButton(parent, action, key, style, caption, tooltip, size)
  --Logging:trace(ElementGui.classname, "addGuiButton", parent, action, key, style, caption, tooltip, size)
  local options = {}
  options.type = "button"
  if key ~= nil then
    options.name = action..key
  else
    options.name = action
  end
  if style ~= nil then
    options.style = style
  end
  if caption ~= nil then
    options.caption = caption
  end
  if tooltip ~= nil then
    options.tooltip = tooltip
  end

  local button = nil
  local ok , err = pcall(function()
    button = parent.add(options)
  end)
  if not ok then
    options.style = "helmod_button_default"
    if (type(caption) == "boolean") then
      Logging:error(ElementGui.classname, "addGuiButton - caption is a boolean")
    elseif caption ~= nil then
      options.caption = caption
    else
      options.caption = key
    end
    button = parent.add(options)
  end
  if size ~= nil then
    button.style.width = size
    button.style.height = size
  end
  return button
end

-------------------------------------------------------------------------------
-- Add a button element
--
-- @function [parent=#ElementGui] addGuiShortButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #string style style of button
-- @param #string caption container for element
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiShortButton(parent, action, key, style, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButton", parent, action, key, style, caption, tooltip)
  local button = ElementGui.addGuiButton(parent, action, key, style, caption, tooltip)
  button.style.width = 20
  return button
end

-------------------------------------------------------------------------------
-- Add a choose element button
--
-- @function [parent=#ElementGui] addGuiChooseButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #string elem_type "item", "tile", "entity", or "signal"
-- @param #string default
-- @param #string style style of button
-- @param #string caption container for element
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiChooseButton(parent, action, key, elem_type, default, style, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButton", parent, action, key, elem_type, default, style, caption, tooltip)
  local options = {}
  options.type = "choose-elem-button"
  if key ~= nil then
    options.name = action..key
  else
    options.name = action
  end
  options.elem_type = elem_type
  options[elem_type] = default
  options.style = style
  options.caption = caption
  options.tooltip = tooltip

  local button = nil
  local ok , err = pcall(function()
    button = parent.add(options)
  end)
  if not ok then
    options.style = "helmod_button_default"
    if (type(caption) == "boolean") then
      Logging:error(ElementGui.classname, "addGuiButton - caption is a boolean")
    elseif caption ~= nil then
      options.caption = caption
    else
      options.caption = key
    end
    button = parent.add(options)
  end
  return button
end

-------------------------------------------------------------------------------
-- Add a radio-button element
--
-- @function [parent=#ElementGui] addGuiRadioButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #boolean state state of radio-button
-- @param #string style style of radio-button
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiRadioButton(parent, key, state, style, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiRadioButton", parent, key, state, style, tooltip)
  return parent.add({type="radiobutton", name=key, state=state, style=style, tooltip=tooltip})
end

-------------------------------------------------------------------------------
-- Add a checkbox element
--
-- @function [parent=#ElementGui] addGuiCheckbox
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #boolean state state of checkbox
-- @param #string style style of checkbox
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiCheckbox(parent, key, state, style, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiCheckbox", parent, key, state, style, tooltip)
  return parent.add({type="checkbox", name=key, state=state, style=style, tooltip=tooltip})
end

-------------------------------------------------------------------------------
-- Add a dropdown element
--
-- @function [parent=#ElementGui] addGuiDropDown
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #table items list of element
-- @param #string selected selected element
-- @param #string style style of button
-- @param #string caption container for element
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiDropDown(parent, action, key, items, selected, style, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiDropDown", parent, action, key, items, selected, style, caption, tooltip)
  local options = {}
  options.type = "drop-down"
  if key ~= nil then
    options.name = action..key
  else
    options.name = action
  end
  if style ~= nil then
    options.style = style
  end
  if caption ~= nil then
    options.caption = caption
  end
  if tooltip ~= nil then
    options.tooltip = tooltip
  end

  local selected_index = 1
  if items ~= nil then
    options.items = items
    for index,item in ipairs(items) do
      if item == selected then
        selected_index = index
      end
    end
  end
  options.selected_index = 1
  if selected_index ~= nil and selected ~= nil then
    options.selected_index = selected_index
  end

  local element = nil
  local ok , err = pcall(function()
    element = parent.add(options)
  end)
  if not(ok) then Logging:error(ElementGui.classname, "addGuiDropDown", options, ok , err) end
  return element
end

-------------------------------------------------------------------------------
-- Add a selector element
--
-- @function [parent=#ElementGui] addGuiDropDownElement
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #string elem_type
-- @param #string selected selected element
-- @param #string style style of button
-- @param #string caption container for element
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiDropDownElement(parent, action, key, elem_type, selected, style, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiDropDownElement", parent, action, key, selected, style, caption, tooltip)
  local options = {}
  options.type = "choose-elem-button"
  options.style = style
  options.caption = caption
  options.tooltip = tooltip

  if key ~= nil then
    options.name = action..key
  else
    options.name = action
  end

  options.elem_type = elem_type
  if elem_type ~= nil and selected ~= nil then
    options[elem_type] = selected
  end

  local element = nil
  local ok , err = pcall(function()
    element = parent.add(options)
  end)
  if not(ok) then Logging:error(ElementGui.classname, "addGuiDropDownElement", options, ok , err) end
  return element
end

-------------------------------------------------------------------------------
-- Add a button element for item
--
-- @function [parent=#ElementGui] addGuiButtonItem
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonItem(parent, action, key, caption)
  --Logging:trace(ElementGui.classname, "addGuiButtonItem", parent, action, key, caption)
  return ElementGui.addGuiButton(parent, action, key, key, caption)
end

-------------------------------------------------------------------------------
-- Add a icon button element for item
--
-- @function [parent=#ElementGui] addGuiButtonIcon
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonIcon(parent, action, type, key, caption)
  --Logging:trace(ElementGui.classname, "addGuiButtonIcon", parent, action, type, key, caption)
  return ElementGui.addGuiButton(parent, action, key, "helmod_button_"..type.."_"..key, caption)
end

-------------------------------------------------------------------------------
-- Add a sprite button element for item
--
-- @function [parent=#ElementGui] addGuiButtonSpriteStyled
--
-- @param #LuaGuiElement parent container for element
-- @param #string style style of button
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSpriteStyled(parent, style, action, type, key, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButtonSpriteStyled", style, action, type, key, caption, tooltip)
  local options = {}
  options.type = "sprite-button"
  if key ~= nil then
    options.name = action..key
  else
    options.name = action
  end
  if tooltip ~= nil then
    options.tooltip = tooltip
  end
  options.style = style
  if type ~= nil and key ~= nil then
    if type == "resource" then type = "item" end
    if Player.is_valid_sprite_path(string.format("%s/%s", type, key)) then
      options.sprite = string.format("%s/%s", type, key)
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item", key)) then
      options.sprite = string.format("%s/%s", "item", key)
      Logging:warn(ElementGui.classname, "wrong type", type, key, "-> item")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "entity", key)) then
      options.sprite = string.format("%s/%s", "entity", key)
      Logging:warn(ElementGui.classname, "wrong type", type, key, "-> entity")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "fluid", key)) then
      options.sprite = string.format("%s/%s", "fluid", key)
      Logging:warn(ElementGui.classname, "wrong type", type, key, "-> fluid")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "technology", key)) then
      options.sprite = string.format("%s/%s", "technology", key)
      Logging:warn(ElementGui.classname, "wrong type", type, key, "-> technology")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "recipe", key)) then
      options.sprite = string.format("%s/%s", "recipe", key)
      Logging:warn(ElementGui.classname, "wrong type", type, key, "-> recipe")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item-group", key)) then
      options.sprite = string.format("%s/%s", "item-group", key)
      Logging:warn(ElementGui.classname, "wrong type", type, key, "-> item-group")
    end
  end

  local button = nil
  if type ~= nil then
    local ok , err = pcall(function()
      button = parent.add(options)
    end)
    if not ok then
      Logging:error(ElementGui.classname, "addGuiButtonSpriteStyled", action, type, key, err)
      if parent[options.name] and parent[options.name].valid then
        parent[options.name].destroy()
      end
      if caption ~= nil then
        options.caption = caption
      end

      button = ElementGui.addGuiButtonIcon(parent, action, type, key, caption)
    end
  else
    button = ElementGui.addGuiButton(parent, action, key, "helmod_button_default", caption)
  end
  return button
end

-------------------------------------------------------------------------------
-- Add a smal sprite button element for item
--
-- @function [parent=#ElementGui] addGuiButtonSpriteSm
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSpriteSm(parent, action, type, key, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButtonSpriteSm",action, type, key, caption, tooltip)
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_icon_sm", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a smal sprite button element for item selection
--
-- @function [parent=#ElementGui] addGuiButtonSelectSpriteSm
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
-- @param #string color background color
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSelectSpriteSm(parent, action, type, key, caption, tooltip, color)
  --Logging:trace(ElementGui.classname, "addGuiButtonSelectSpriteSm",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon_sm"
  if color == "red" then style = "helmod_button_select_icon_sm_red" end
  if color == "yellow" then style = "helmod_button_select_icon_sm_yellow" end
  if color == "green" then style = "helmod_button_select_icon_sm_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_select_icon_sm", action, type, key, caption, tooltip, color)
end

-------------------------------------------------------------------------------
-- Add a smal slot button element for item
--
-- @function [parent=#ElementGui] addGuiButtonSlotSm
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSlotSm(parent, action, type, key, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButtonSlotSm",action, type, key, caption, tooltip)
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_slot_sm", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a smal sprite button element for item
--
-- @function [parent=#ElementGui] addGuiButtonSpriteM
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSpriteM(parent, action, type, key, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButtonSpriteM",action, type, key, caption, tooltip)
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_icon_m", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a smal sprite button element for item selection
--
-- @function [parent=#ElementGui] addGuiButtonSelectSpriteM
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
-- @param #string color background color
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSelectSpriteM(parent, action, type, key, caption, tooltip, color)
  --Logging:trace(ElementGui.classname, "addGuiButtonSelectSpriteM",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon_m"
  if color == "red" then style = "helmod_button_select_icon_m_red" end
  if color == "yellow" then style = "helmod_button_select_icon_m_yellow" end
  if color == "green" then style = "helmod_button_select_icon_m_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, style, action, type, key, caption, tooltip, color)
end

-------------------------------------------------------------------------------
-- Add a normal sprite button element for item
--
-- @function [parent=#ElementGui] addGuiButtonSprite
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSprite(parent, action, type, key, caption, tooltip)
  --Logging:trace(ElementGui.classname, ":addGuiButtonSprite",action, type, key, caption, tooltip)
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_icon", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a sprite button element for item selection
--
-- @function [parent=#ElementGui] addGuiButtonSelectSprite
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
-- @param #string color background color
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSelectSprite(parent, action, type, key, caption, tooltip, color)
  --Logging:trace(ElementGui.classname, "addGuiButtonSelectSprite",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon"
  if color == "red" then style = "helmod_button_select_icon_red" end
  if color == "yellow" then style = "helmod_button_select_icon_yellow" end
  if color == "green" then style = "helmod_button_select_icon_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, style, action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a big sprite button element for item
--
-- @function [parent=#ElementGui] addGuiButtonSpriteXxl
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSpriteXxl(parent, action, type, key, caption, tooltip)
  --Logging:trace(ElementGui.classname, "addGuiButtonSpriteXxl",action, type, key, caption, tooltip)
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_icon_xxl", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a big sprite button element for item selection
--
-- @function [parent=#ElementGui] addGuiButtonSelectSpriteXxl
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string tooltip displayed text
-- @param #string color background color
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButtonSelectSpriteXxl(parent, action, type, key, caption, tooltip, color)
  --Logging:trace(ElementGui.classname, "addGuiButtonSelectSpriteXxl",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon_xxl"
  if color == "red" then style = "helmod_button_select_icon_xxl_red" end
  if color == "yellow" then style = "helmod_button_select_icon_xxl_yellow" end
  if color == "green" then style = "helmod_button_select_icon_xxl_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, style, action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a flow container
--
-- @function [parent=#ElementGui] addGuiFlowH
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string style style of frame
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiFlow(parent, key, style)
  --Logging:trace(ElementGui.classname, "addGuiFlow()", key, style)
  local options = {}
  options.type = "flow"
  options.name = key
  if style ~= nil then
    options.style = style
  end
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a horizontal flow container
--
-- @function [parent=#ElementGui] addGuiFlowH
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string style style of frame
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiFlowH(parent, key, style)
  --Logging:trace(ElementGui.classname, "addGuiFlowH()", key, style)
  local options = {}
  options.type = "flow"
  options.direction = "horizontal"
  options.name = key
  options.style = style or helmod_flow_style.horizontal
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a vertical flow container
--
-- @function [parent=#ElementGui] addGuiFlowV
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string style style of frame
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiFlowV(parent, key, style)
  --Logging:trace(ElementGui.classname, "addGuiFlowV()", key, style)
  local options = {}
  options.type = "flow"
  options.direction = "vertical"
  options.name = key
  options.style = style or helmod_flow_style.vertical
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a scroll pane
--
-- @function [parent=#ElementGui] addGuiScrollPane
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string style style of frame
-- @param #boolean policy scroll horizontally
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiScrollPane(parent, key, style, policy)
  local options = {}
  options.type = "scroll-pane"
  options.horizontal_scroll_policy = "auto"
  if policy == true then
    options.vertical_scroll_policy = "auto"
  end
  options.horizontally_stretchable = true
  options.name = key
  options.style = style
  local scroll = parent.add(options)
  return scroll
end

-------------------------------------------------------------------------------
-- Add a horizontal frame container
--
-- @function [parent=#ElementGui] addGuiFrameH
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string style style of frame
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiFrameH(parent, key, style, caption)
  local options = {}
  options.type = "frame"
  options.direction = "horizontal"
  options.name = key
  if style ~= nil then
    options.style = style
  end
  if caption ~= nil then
    options.caption = caption
  end
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a vertical frame container
--
-- @function [parent=#ElementGui] addGuiFrameV
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string style style of frame
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiFrameV(parent, key, style, caption)
  local options = {}
  options.type = "frame"
  options.direction = "vertical"
  options.name = key
  if style ~= nil then
    options.style = style
  end
  if caption ~= nil then
    options.caption = caption
  end
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add a grid container
--
-- @function [parent=#ElementGui] addGuiTable
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #number column_count column number
-- @param #string style style of frame
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiTable(parent, key, column_count, style)
  local options = {}
  options.type = "table"
  options.column_count = column_count
  options.name = key
  if style ~= nil then
    options.style = style
  end
  return parent.add(options)
end

-------------------------------------------------------------------------------
-- Add cell
--
-- @function [parent=#ElementGui] addCell
--
-- @param #LuaGuiElement parent container for element
-- @param #string name
-- @param #number column_count
--
function ElementGui.addCell(parent, name, column_count, index)
  --Logging:trace(ElementGui.classname, "addCell()", name)
  local cell = ElementGui.addGuiTable(parent, "cell".."_"..name..(index or ""), column_count or 3, helmod_table_style.list)
  return cell
end

-------------------------------------------------------------------------------
-- Add cell label
--
-- @function [parent=#ElementGui] addCellLabel
--
-- @param #LuaGuiElement parent container for element
-- @param #string name
-- @param #string label
-- @param #number minimal_width
--
function ElementGui.addCellLabel(parent, name, label, minimal_width)
  --Logging:trace(ElementGui.classname, "addCellLabel()", name, label, minimal_width)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local cell = ElementGui.addCell(parent, "cell_"..name)

  if display_cell_mod == "small-text"then
    -- small
    ElementGui.addGuiLabel(cell, "label1_"..name, label, "helmod_label_icon_text_sm", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "small-icon" then
    -- small
    ElementGui.addGuiLabel(cell, "label1_"..name, label, "helmod_label_icon_sm", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    ElementGui.addGuiLabel(cell, "label1_"..name, label, "helmod_label_row_right", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 50
  else
    -- default
    ElementGui.addGuiLabel(cell, "label1_"..name, label, "helmod_label_row_right", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 60

  end
  return cell
end

-------------------------------------------------------------------------------
-- Add cell label
--
-- @function [parent=#ElementGui] addCellLabel2
--
-- @param #LuaGuiElement parent container for element
-- @param #string name
-- @param #string label1
-- @param #string label2
-- @param #number minimal_width
--
function ElementGui.addCellLabel2(parent, name, label1, label2, minimal_width)
  --Logging:trace(ElementGui.classname, "addCellLabel()", name, label1, label2, minimal_width)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local cell = ElementGui.addCell(parent, "cell_"..name, 1)

  if display_cell_mod == "small-text"then
    -- small
    ElementGui.addGuiLabel(cell, "label1_"..name, label1, "helmod_label_row2_right_sm", {"helmod_common.per-sub-block"}).style["minimal_width"] = minimal_width or 45
    ElementGui.addGuiLabel(cell, "label2_"..name, label2, "helmod_label_row2_right_sm", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "small-icon" then
    -- small
    ElementGui.addGuiLabel(cell, "label1_"..name, label1, "helmod_label_row2_right_sm", {"helmod_common.per-sub-block"}).style["minimal_width"] = minimal_width or 45
    ElementGui.addGuiLabel(cell, "label2_"..name, label2, "helmod_label_row2_right_sm", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    ElementGui.addGuiLabel(cell, "label1_"..name, label1, "helmod_label_row2_right", {"helmod_common.per-sub-block"}).style["minimal_width"] = minimal_width or 45
    ElementGui.addGuiLabel(cell, "label2_"..name, label2, "helmod_label_row2_right", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 45
  else
    -- default
    ElementGui.addGuiLabel(cell, "label1_"..name, label1, "helmod_label_row2_right", {"helmod_common.per-sub-block"}).style["minimal_width"] = minimal_width or 45
    ElementGui.addGuiLabel(cell, "label2_"..name, label2, "helmod_label_row2_right", {"helmod_common.total"}).style["minimal_width"] = minimal_width or 45

  end
end

-------------------------------------------------------------------------------
-- Add cell input
--
-- @function [parent=#ElementGui] addCellInput
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string text input text
-- @param #string style style of text
-- @param #string tooltip displayed text
--
function ElementGui.addCellInput(parent, key, text, style, tooltip)
  --Logging:trace(ElementGui.classname, "addCellInput()", key, text, style, tooltip)
  local cell = ElementGui.addCell(parent, key, 2)
  local input = ElementGui.addGuiText(cell, key, text, style, ({"tooltip.formula-allowed"}))
  local button = ElementGui.addGuiButton(cell, key, "=validation", "helmod_button_icon_ok",nil, {"helmod_button.apply"})
  return cell, input, button
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#ElementGui] addCellIcon
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function ElementGui.addCellIcon(parent, element, action, select, tooltip_name, color)
  --Logging:trace(ElementGui.classname, "addCellIcon()", element, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local product_prototype = Product(element)
  local product_amount = product_prototype:getElementAmount()
  if display_cell_mod == "small-icon" then
    if parent ~= nil and select == true then
      ElementGui.addGuiButtonSelectSpriteM(parent, action, element.type, element.name, "X"..product_amount, ({tooltip_name, Player.getLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSpriteM(parent, action, element.type, element.name, "X"..product_amount, ({tooltip_name, Player.getLocalisedName(element)}), color)
    end
  else
    if parent ~= nil and select == true then
      ElementGui.addGuiButtonSelectSprite(parent, action, element.type, element.name, "X"..product_amount, ({tooltip_name, Player.getLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSprite(parent, action, element.type, element.name, "X"..product_amount, ({tooltip_name, Player.getLocalisedName(element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#ElementGui] addCellElement
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellElement(parent, element, action, select, tooltip_name, color, index)
  --Logging:trace(ElementGui.classname, "addCellElement()", element, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "blue"
  local cell = ElementGui.addGuiFlowV(parent,element.name..(index or ""), helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_element_"..color.."_1")
  --ElementGui.addCellIcon(row1, element, action, select, tooltip_name, nil)
  ElementGui.addGuiButtonSprite(row1, action, element.type, element.name, "X"..Product(element):getElementAmount(), ({tooltip_name, Player.getLocalisedName(element)}))
  ElementGui.addCellCargoInfo(row1, element)

  if element.limit_count ~= nil then
    local row2 = ElementGui.addGuiFrameH(cell,"row2","helmod_frame_element_"..color.."_2")
    if display_cell_mod == "by-kilo" then
      -- by-kilo
      ElementGui.addGuiLabel(row2, "label1_"..element.name, Format.formatNumberKilo(element.limit_count), "helmod_label_element", {"helmod_common.per-sub-block"})
    else
      ElementGui.addGuiLabel(row2, "label1_"..element.name, Format.formatNumberElement(element.limit_count), "helmod_label_element", {"helmod_common.per-sub-block"})
    end
  end

  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_element_"..color.."_3")
  if display_cell_mod == "by-kilo" then
    -- by-kilo
    ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumberKilo(element.count), "helmod_label_element", {"helmod_common.total"})
  else
    ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumberElement(element.count), "helmod_label_element", {"helmod_common.total"})
  end
  return cell
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#ElementGui] addCellElementSm
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellElementSm(parent, element, action, select, tooltip_name, color, index)
  --Logging:trace(ElementGui.classname, "addCellElementSm()", element, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "blue"
  local cell = ElementGui.addGuiFlowV(parent,element.name..(index or ""), helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_element_sm_"..color.."_1")
  ElementGui.addGuiButtonSpriteSm(row1, action, element.type, element.name, "X"..Product(element):getElementAmount(), ({tooltip_name, Player.getLocalisedName(element)}))

  if element.limit_count ~= nil then
    local row2 = ElementGui.addGuiFrameH(cell,"row2","helmod_frame_element_sm_"..color.."_2")
    if display_cell_mod == "by-kilo" then
      -- by-kilo
      ElementGui.addGuiLabel(row2, "label1_"..element.name, Format.formatNumberKilo(element.limit_count), "helmod_label_element_sm", {"helmod_common.per-sub-block"})
    else
      ElementGui.addGuiLabel(row2, "label1_"..element.name, Format.formatNumberElement(element.limit_count), "helmod_label_element_sm", {"helmod_common.per-sub-block"})
    end
  end

  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_element_sm_"..color.."_3")
  if display_cell_mod == "by-kilo" then
    -- by-kilo
    ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumberKilo(element.count), "helmod_label_element_sm", {"helmod_common.total"})
  else
    ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumberElement(element.count), "helmod_label_element_sm", {"helmod_common.total"})
  end
  return cell
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#ElementGui] addCellElementM
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellElementM(parent, element, action, select, tooltip_name, color, index)
  --Logging:trace(ElementGui.classname, "addCellElementM()", element, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "blue"
  local cell = ElementGui.addGuiFlowV(parent,element.name..(index or ""), helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_element_m_"..color.."_1")
  ElementGui.addGuiButtonSpriteM(row1, action, element.type, element.name, "X"..Product(element):getElementAmount(), ({tooltip_name, Player.getLocalisedName(element)}))

  if element.limit_count ~= nil then
    local row2 = ElementGui.addGuiFrameH(cell,"row2","helmod_frame_element_m_"..color.."_2")
    if display_cell_mod == "by-kilo" then
      -- by-kilo
      ElementGui.addGuiLabel(row2, "label1_"..element.name, Format.formatNumberKilo(element.limit_count), "helmod_label_element_m", {"helmod_common.per-sub-block"})
    else
      ElementGui.addGuiLabel(row2, "label1_"..element.name, Format.formatNumberElement(element.limit_count), "helmod_label_element_m", {"helmod_common.per-sub-block"})
    end
  end

  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_element_m_"..color.."_3")
  if display_cell_mod == "by-kilo" then
    -- by-kilo
    ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumberKilo(element.count), "helmod_label_element_m", {"helmod_common.total"})
  else
    ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumberElement(element.count), "helmod_label_element_m", {"helmod_common.total"})
  end
  return cell
end

-------------------------------------------------------------------------------
-- Add cell product (for recipe edition)
--
-- @function [parent=#ElementGui] addCellProduct
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellProduct(parent, element, action, select, tooltip_name, color, index)
  --Logging:trace(ElementGui.classname, "addCellProduct()", element, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "blue"
  local cell = ElementGui.addGuiFlowV(parent,element.name..(index or ""), helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_product_"..color.."_1")
  if string.find(element.name, "helmod") then
    ElementGui.addGuiButton(row1, action, nil, element.name, nil, ({element.localised_name}))
  else
    ElementGui.addGuiButtonSprite(row1, action, element.type, element.name, "X"..Product(element):getElementAmount(), ({tooltip_name, Player.getLocalisedName(element)}))
  end
  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_product_"..color.."_3")
  ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumber(element.count, 5), "helmod_label_element", {"helmod_common.total"})
  return cell
end

-------------------------------------------------------------------------------
-- Add cell product (for recipe edition)
--
-- @function [parent=#ElementGui] addCellProductSm
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellProductSm(parent, element, action, select, tooltip_name, color, index)
  --Logging:trace(ElementGui.classname, "addCellProductSm()", element, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "blue"
  local cell = ElementGui.addGuiFlowV(parent,element.name..(index or ""), helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_product_"..color.."_1")
  if string.find(element.name, "helmod") then
    ElementGui.addGuiButton(row1, action, nil, element.name, nil, ({element.localised_name}))
  else
    ElementGui.addGuiButtonSpriteSm(row1, action, element.type, element.name, "X"..Product(element):getElementAmount(), ({tooltip_name, Player.getLocalisedName(element)}))
  end
  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_product_"..color.."_3")
  ElementGui.addGuiLabel(row3, "label2_"..element.name, Format.formatNumber(element.count, 5), "helmod_label_element_sm", {"helmod_common.total"})
  return cell
end

-------------------------------------------------------------------------------
-- Add cell factory
--
-- @function [parent=#ElementGui] addCellFactory
--
-- @param #LuaGuiElement parent container for element
-- @param #table factory
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellFactory(parent, factory, action, select, tooltip_name, color)
  --Logging:trace(ElementGui.classname, "addCellFactory()", factory, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "green"
  local cell = ElementGui.addGuiFlowV(parent,factory.name, helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_element_"..color.."_1")
  if tooltip_name == nil then
    ElementGui.addGuiButtonSprite(row1, action, "entity", factory.name)
  else
    ElementGui.addGuiButtonSprite(row1, action, "entity", factory.name, nil, ({tooltip_name, Player.getLocalisedName(factory)}))
  end

  local col_size = math.ceil(Model.countModulesModel(factory)/2)
  if col_size < 2 then col_size = 2 end
  if display_cell_mod == "small-icon" then col_size = col_size * 2 end
  local cell_factory_module = ElementGui.addGuiTable(row1,"factory-modules", col_size, "helmod_factory_modules")
  -- modules
  if factory.modules ~= nil then
    for name, count in pairs(factory.modules) do
      for index = 1, count, 1 do
        ElementGui.addGuiButtonSpriteSm(cell_factory_module, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
        index = index + 1
      end
    end
  end
  if factory.limit_count ~= nil then
    local row2 = ElementGui.addGuiFrameH(cell,"row2","helmod_frame_element_"..color.."_2")
    ElementGui.addGuiLabel(row2, "label1_"..factory.name, Format.formatNumberFactory(factory.limit_count), "helmod_label_element", {"helmod_common.per-sub-block"})
  end

  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_element_"..color.."_3")
  ElementGui.addGuiLabel(row3, "label2_"..factory.name, Format.formatNumberFactory(factory.count), "helmod_label_element", {"helmod_common.total"})
  return cell
end

-------------------------------------------------------------------------------
-- Add cell recipe
--
-- @function [parent=#ElementGui] addCellRecipe
--
-- @param #LuaGuiElement parent container for element
-- @param #table recipe
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellRecipe(parent, recipe, action, select, tooltip_name, color, broken)
  --Logging:trace(ElementGui.classname, "addCellRecipe()", recipe, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "green"
  local cell = ElementGui.addGuiFlowV(parent,recipe.name, helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_product_"..color.."_1")

  local recipe_icon = ElementGui.addGuiButtonSprite(row1, action, recipe.type, recipe.name, recipe.name, ({tooltip_name, Player.getRecipeLocalisedName(recipe)}))
  if broken == true then
    recipe_icon.tooltip = "ERROR: Recipe ".. recipe.name .." not exist in game"
    recipe_icon.sprite = "utility/warning_icon"
    row1.style = "helmod_frame_product_red_1"
  end

  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_product_"..color.."_3")
  ElementGui.addGuiLabel(row3, "label2_"..recipe.name, Format.formatPercent(recipe.production or 1).."%", "helmod_label_element", {"helmod_common.total"})
  return cell
end

-------------------------------------------------------------------------------
-- Add cell block
--
-- @function [parent=#ElementGui] addCellBlock
--
-- @param #LuaGuiElement parent container for element
-- @param #table block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellBlock(parent, block, action, select, tooltip_name, color)
  --Logging:trace(ElementGui.classname, "addCellRecipe()", block, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "green"
  local cell = ElementGui.addGuiFlowV(parent,block.name, helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_product_"..color.."_1")

  local recipe_icon = ElementGui.addGuiButtonSprite(row1, action, "recipe", block.name, block.name, ({tooltip_name, Player.getRecipeLocalisedName(block)}))

  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_product_"..color.."_3")
  ElementGui.addGuiLabel(row3, "label2_"..block.name, Format.formatNumberFactory(block.count or 0), "helmod_label_element", {"helmod_common.total"})
  return cell
end

-------------------------------------------------------------------------------
-- Add cell energy
--
-- @function [parent=#ElementGui] addCellEnergy
--
-- @param #LuaGuiElement parent container for element
-- @param #table recipe
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function ElementGui.addCellEnergy(parent, recipe, action, select, tooltip_name, color)
  --Logging:trace(ElementGui.classname, "addCellEnergy()", recipe, action, select, tooltip_name, color)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local button = nil
  color = color or "green"
  local cell = ElementGui.addGuiFlowV(parent,recipe.name, helmod_flow_style.vertical)
  local row1 = ElementGui.addGuiFrameH(cell,"row1","helmod_frame_element_"..color.."_1")

  ElementGui.addGuiButton(row1, action, "item", "helmod_button_icon_energy_flat2", nil, {tooltip_name, {"helmod_common.energy"}})

  if recipe.limit_energy ~= nil then
    local row2 = ElementGui.addGuiFrameH(cell,"row2","helmod_frame_element_"..color.."_2")
    ElementGui.addGuiLabel(row2, "label1_"..recipe.name, Format.formatNumberKilo(recipe.limit_energy), "helmod_label_element", {"helmod_common.per-sub-block"})
  end
  
  local row3 = ElementGui.addGuiFrameH(cell,"row3","helmod_frame_element_"..color.."_3")
  ElementGui.addGuiLabel(row3, "label2_"..recipe.name, Format.formatNumberKilo(recipe.energy_total or recipe.power, "W"), "helmod_label_element", {"helmod_common.total"})
  return cell
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#ElementGui] addCellCargoInfo
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
--
function ElementGui.addCellCargoInfo(parent, element)
  --Logging:trace(ElementGui.classname, "addCellCargoInfo()", element)
  local parameters = User.getParameter()
  local product_prototype = Product(element)
  if product_prototype:native() ~= nil then
    local table_cargo = ElementGui.addGuiTable(parent,"element_cargo", 1, "helmod_beacon_modules")
    if element.type == 0 or element.type == "item" then
      local container_solid = parameters.container_solid or "steel-chest"
      local vehicle_solid = parameters.vehicle_solid or "cargo-wagon"
      ElementGui.addGuiButtonSpriteSm(table_cargo, container_solid, "item", container_solid, nil, ElementGui.getTooltipProduct(element, container_solid))
      ElementGui.addGuiButtonSpriteSm(table_cargo, vehicle_solid, "item", vehicle_solid, nil, ElementGui.getTooltipProduct(element, vehicle_solid))
    end

    if element.type == 1 or element.type == "fluid" then
      local container_fluid = parameters.container_fluid or "storage-tank"
      local vehicle_fluid = parameters.wagon_fluid or "fluid-wagon"
      ElementGui.addGuiButtonSpriteSm(table_cargo, container_fluid, "item", container_fluid, nil, ElementGui.getTooltipProduct(element, container_fluid))
      ElementGui.addGuiButtonSpriteSm(table_cargo, vehicle_fluid, "item", vehicle_fluid, nil, ElementGui.getTooltipProduct(element, vehicle_fluid))
    end
  end
end

-------------------------------------------------------------------------------
-- Get tooltip for product
--
-- @function [parent=#ElementGui] getTooltipProduct
--
-- @param #lua_product element
-- @param #string container name
--
-- @return #table
--
function ElementGui.getTooltipProduct(element, container)
  --Logging:trace(ElementGui.classname, "getTooltipProduct", element, container)
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
-- @function [parent=#ElementGui] getTooltipModule
--
-- @param #string module_name
--
-- @return #table
--
function ElementGui.getTooltipModule(module_name)
  --Logging:trace(ElementGui.classname, "getTooltipModule", module_name)
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
-- @function [parent=#ElementGui] getTooltipRecipe
--
-- @param #table prototype
--
-- @return #table
--


function ElementGui.getTooltipRecipe(prototype)
  --Logging:trace(ElementGui.classname, "getTooltipRecipe", prototype)
  local recipe_prototype = RecipePrototype(prototype)
  if recipe_prototype:native() == nil then return nil end
  local cache_tooltip_recipe = Cache.getData(ElementGui.classname, "tooltip_recipe") or {}
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
  Cache.setData(ElementGui.classname, "tooltip_recipe",cache_tooltip_recipe)
  return tooltip
end

-------------------------------------------------------------------------------
-- Get tooltip for technology
--
-- @function [parent=#ElementGui] getTooltipTechnology
--
-- @param #table prototype
--
-- @return #table
--
function ElementGui.getTooltipTechnology(prototype)
  --Logging:trace(ElementGui.classname, "getTooltipTechnology", prototype)
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
-- Get display sizes
--
-- @function [parent=#ElementGui] getDisplaySizes
--
-- return
--
function ElementGui.getDisplaySizes()
  --Logging:trace(ElementGui.classname, "getDisplaySizes()")
  local display_resolution = Player.native().display_resolution
  local display_scale = Player.native().display_scale
  return display_resolution.width/display_scale, display_resolution.height/display_scale
end

-------------------------------------------------------------------------------
-- Get style sizes
--
-- @function [parent=#ElementGui] getStyleSizes
--
function ElementGui.getStyleSizes()
  --Logging:trace(ElementGui.classname, "getStyleSizes()")
  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local display_ratio_vertictal = User.getModSetting("display_ratio_vertical")

  local width , height = ElementGui.getDisplaySizes()
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
    local row_number = math.floor(Model.countModel()/ElementGui.getIndexColumnNumber())
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
  --Logging:trace(ElementGui.classname, "getStyleSizes(player)", style_sizes)
  return style_sizes
end

-------------------------------------------------------------------------------
-- Get Index column number
--
-- @function [parent=#ElementGui] getIndexColumnNumber
--
-- @return #number
--
function ElementGui.getIndexColumnNumber()

  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local width , height = ElementGui.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal)

  return math.ceil((width_main-650)/36)
end

-------------------------------------------------------------------------------
-- Get Element column number
--
-- @function [parent=#ElementGui] getElementColumnNumber
--
-- @param #number size
--
-- @return #number
--
function ElementGui.getElementColumnNumber(size)

  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local width , height = ElementGui.getDisplaySizes()
  local width_main = math.ceil(width*display_ratio_horizontal)
  return math.floor((width_main-600)/(2*size))
end
-------------------------------------------------------------------------------
-- Set style
--
-- @function [parent=#ElementGui] setStyle
--
-- @param #LuaGuiElement element
-- @param #string style
-- @param #string property
--
function ElementGui.setStyle(element, style, property)
  --Logging:trace(ElementGui.classname, "setStyle(player, element, style, property)", element, style, property)
  local style_sizes = ElementGui.getStyleSizes()
  if string.find(style, "Tab") then
    style = "Tab"
  end
  if element.style ~= nil and style_sizes[style] ~= nil and style_sizes[style][property] ~= nil then
    element.style[property] = style_sizes[style][property]
  end
end

-------------------------------------------------------------------------------
-- Set style
--
-- @function [parent=#ElementGui] setVisible
--
-- @param #LuaGuiElement element
-- @param #boolean visible
--
function ElementGui.setVisible(element, visible)
  --Logging:trace(ElementGui.classname, "setVisible(element, visible)", element, visible)
  if element.style ~= nil then
    element.style.visible = visible
  end
end

-------------------------------------------------------------------------------
-- Get dropdown selection
--
-- @function [parent=#ElementGui] getDropdownSelection
--
-- @param #LuaGuiElement element
--
function ElementGui.getDropdownSelection(element)
  --Logging:trace(ElementGui.classname, "getDropdownSelection(element)", element)
  if element.selected_index == 0 then return nil end
  if #element.items == 0 then return nil end
  return element.items[element.selected_index]
end

return ElementGui
