---
-- Description of the module.
-- @module ElementGui
--
local ElementGui = {
  -- single-line comment
  classname = "HMElementGui"
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
-- Add a label element
--
-- @function [parent=#ElementGui] addGuiLabel
--
-- @param #LuaGuiElement parent container for element
-- @param #string key unique id
-- @param #string caption displayed text
-- @param #string style style of label
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiLabel(parent, key, caption, style, tooltip, single_line)
  Logging:trace(ElementGui.classname, "addGuiLabel", parent, key, caption, style, tooltip, single_line)
  local options = {}
  options.type = "label"
  options.name = key
  options.caption = caption
  if single_line ~= nil then
    options.single_line = single_line
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
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiButton(parent, action, key, style, caption, tooltip)
  Logging:trace(ElementGui.classname, "addGuiButton", parent, action, key, style, caption, tooltip)
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
    Logging:trace(ElementGui.classname, "addGuiButton", action, key, style, err)
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
  Logging:trace(ElementGui.classname, "addGuiRadioButton", parent, key, state, style, tooltip)
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
  Logging:trace(ElementGui.classname, "addGuiCheckbox", parent, key, state, style, tooltip)
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
  Logging:debug(ElementGui.classname, "addGuiDropDown", parent, action, key, items, selected, style, caption, tooltip)
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
  Logging:trace(ElementGui.classname, "addGuiButtonItem", parent, action, key, caption)
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
  Logging:trace(ElementGui.classname, "addGuiButtonIcon", parent, action, type, key, caption)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSpriteStyled", style,action, type, key, caption, tooltip)
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
  options.sprite = type.."/"..key

  local button = nil
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

    ElementGui.addGuiButtonIcon(parent, action, type, key, caption)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSpriteSm",action, type, key, caption, tooltip)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSelectSpriteSm",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon_sm"
  if color == "red" then style = "helmod_button_select_icon_sm_red" end
  if color == "yellow" then style = "helmod_button_select_icon_sm_yellow" end
  if color == "green" then style = "helmod_button_select_icon_sm_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_select_icon_sm", action, type, key, caption, tooltip, color)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSpriteM",action, type, key, caption, tooltip)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSelectSpriteM",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon_m"
  if color == "red" then style = "helmod_button_select_icon_m_red" end
  if color == "yellow" then style = "helmod_button_select_icon_m_yellow" end
  if color == "green" then style = "helmod_button_select_icon_m_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, "helmod_button_select_icon_m", action, type, key, caption, tooltip, color)
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
  Logging:trace(ElementGui.classname, ":addGuiButtonSprite",action, type, key, caption, tooltip)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSelectSprite",action, type, key, caption, tooltip, color)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSpriteXxl",action, type, key, caption, tooltip)
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
  Logging:trace(ElementGui.classname, "addGuiButtonSelectSpriteXxl",action, type, key, caption, tooltip, color)
  local style = "helmod_button_select_icon_xxl"
  if color == "red" then style = "helmod_button_select_icon_xxl_red" end
  if color == "yellow" then style = "helmod_button_select_icon_xxl_yellow" end
  if color == "green" then style = "helmod_button_select_icon_xxl_green" end
  return ElementGui.addGuiButtonSpriteStyled(parent, style, action, type, key, caption, tooltip)
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
  local options = {}
  options.type = "flow"
  options.direction = "horizontal"
  options.name = key
  if style ~= nil then
    options.style = style
  end
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
  local options = {}
  options.type = "flow"
  options.direction = "vertical"
  options.name = key
  if style ~= nil then
    options.style = style
  end
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
-- @param #string horizontal horizontal scroll policy
-- @param #string vertical vertical scroll policy
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiScrollPane(parent, key, style, horizontal, vertical)
  local options = {}
  options.type = "scroll-pane"
  options.horizontal_scroll_policy = "auto"
  options.vertical_scroll_policy = "auto"
  options.name = key
  if style ~= nil then
    options.style = style
  end
  if horizontal ~= nil then
    options.horizontal_scroll_policy = horizontal
  end
  if vertical ~= nil then
    options.vertical_scroll_policy = vertical
  end
  return parent.add(options)
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
-- @param #number colspan column number
-- @param #string style style of frame
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.addGuiTable(parent, key, colspan, style)
  local options = {}
  options.type = "table"
  options.colspan = colspan
  options.name = key
  if style ~= nil then
    options.style = style
  end
  return parent.add(options)
end

return ElementGui