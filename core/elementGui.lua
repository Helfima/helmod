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
  if type ~= nil and key ~= nil then
    options.sprite = type.."/"..key
  end

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

-------------------------------------------------------------------------------
-- Add cell
--
-- @function [parent=#ElementGui] addCell
--
-- @param #LuaGuiElement parent container for element
-- @param #string name
--
function ElementGui.addCell(parent, name)
  Logging:trace(ElementGui.classname, "addCell()", name)
  local cell = ElementGui.addGuiFlowH(parent,"cell_"..name, "helmod_flow_cell")
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
  Logging:trace(ElementGui.classname, "addCellLabel()", name, label, minimal_width)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  local cell = ElementGui.addGuiFlowV(parent,"cell_"..name, "helmod_flow_cell")

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
  Logging:trace(ElementGui.classname, "addCellLabel()", name, label1, label2, minimal_width)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  local cell = ElementGui.addGuiFlowV(parent,"cell_"..name, "helmod_flow_cell")

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
-- Add icon in cell element
--
-- @function [parent=#AbstractTab] addCellIcon
--
-- @param #LuaGuiElement parent container for element
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function ElementGui.addCellIcon(parent, element, action, select, tooltip_name, color)
  Logging:trace(ElementGui.classname, "addCellIcon()", element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if parent ~= nil and select == true then
      ElementGui.addGuiButtonSelectSpriteM(parent, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSpriteM(parent, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
    end
  else
    if parent ~= nil and select == true then
      ElementGui.addGuiButtonSelectSprite(parent, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSprite(parent, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
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
function ElementGui.addCellElement(parent, element, action, select, tooltip_name, color)
  Logging:trace(ElementGui.classname, "addCellElement():", element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local cell = nil
  local button = nil
  local cell = ElementGui.addCell(parent, element.name)
  if display_cell_mod == "by-kilo" then
    -- by-kilo
    if element.limit_count ~= nil then
      ElementGui.addCellLabel2(cell, element.name, Format.formatNumberKilo(element.limit_count), Format.formatNumberKilo(element.count))
    else
      ElementGui.addCellLabel(cell, element.name, Format.formatNumberKilo(element.count))
    end
  else
    if element.limit_count ~= nil then
      ElementGui.addCellLabel2(cell, element.name, Format.formatNumberElement(element.limit_count), Format.formatNumberElement(element.count))
    else
      ElementGui.addCellLabel(cell, element.name, Format.formatNumberElement(element.count))
    end
  end

  ElementGui.addCellIcon(cell, element, action, select, tooltip_name, color)
  ElementGui.addCellCargoInfo(cell, element)
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
  Logging:debug(ElementGui.classname, "addCellCargoInfo():", element)
  Product.load(element)
  if Product.native() ~= nil then
    local table_cargo = ElementGui.addGuiTable(parent,"element_cargo", 1, "helmod_beacon_modules")
    if element.type == 0 or element.type == "item" then
      ElementGui.addGuiButtonSpriteSm(table_cargo, "steel-chest", "item", "steel-chest", nil, ElementGui.getTooltipProduct(element, "steel-chest"))
      ElementGui.addGuiButtonSpriteSm(table_cargo, "cargo-wagon", "item", "cargo-wagon", nil, ElementGui.getTooltipProduct(element, "cargo-wagon"))
    end
  
    if element.type == 1 or element.type == "fluid" then
      ElementGui.addGuiButtonSpriteSm(table_cargo, "storage-tank", "item", "storage-tank", nil, ElementGui.getTooltipProduct(element, "storage-tank"))
      ElementGui.addGuiButtonSpriteSm(table_cargo, "fluid-wagon", "item", "fluid-wagon", nil, ElementGui.getTooltipProduct(element, "fluid-wagon"))
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
  Logging:debug(ElementGui.classname, "getTooltipProduct", element, container)
  local tooltip = {"tooltip.cargo-info", EntityPrototype.load(container).getLocalisedName()}
  local total_tooltip = {"tooltip.cargo-info-element", {"helmod_common.total"}, Format.formatNumberElement(Product.countContainer(element.count, container))}
  if element.limit_count ~= nil then
    local limit_tooltip = {"tooltip.cargo-info-element", {"helmod_common.per-sub-block"}, Format.formatNumberElement(Product.countContainer(element.limit_count, container))}
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
  Logging:debug(ElementGui.classname, "getTooltipModule", module_name)
  local tooltip = nil
  if module_name == nil then return nil end
  local module = ItemPrototype.load(module_name).native()
  if module ~= nil then
    local consumption = Format.formatPercent(Player.getModuleBonus(module.name, "consumption"))
    local speed = Format.formatPercent(Player.getModuleBonus(module.name, "speed"))
    local productivity = Format.formatPercent(Player.getModuleBonus(module.name, "productivity"))
    local pollution = Format.formatPercent(Player.getModuleBonus(module.name, "pollution"))
    tooltip = {"tooltip.module-description" , ItemPrototype.getLocalisedName(), consumption, speed, productivity, pollution}
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

local cache_tooltip_recipe = {}

function ElementGui.getTooltipRecipe(prototype)
  Logging:debug(ElementGui.classname, "getTooltipRecipe", prototype)
  RecipePrototype.load(prototype)
  if RecipePrototype.native() == nil then return nil end
  if cache_tooltip_recipe[prototype.name] ~= nil then return cache_tooltip_recipe[prototype.name] end
  -- initalize tooltip
  local tooltip = {"tooltip.recipe-info"}
  -- insert __1__ value
  table.insert(tooltip, RecipePrototype.getLocalisedName())

  -- insert __2__ value
  local lastTooltip = tooltip
  for _,element in pairs(RecipePrototype.getProducts()) do
    local product = Product.load(element)
    local count = Product.getElementAmount(element)
    local name = Product.getLocalisedName()
    local currentTooltip = {"tooltip.recipe-info-element", count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")

  -- insert __3__ value
  local lastTooltip = tooltip
  for _,element in pairs(RecipePrototype.getIngredients()) do
    local product = Product.load(element)
    local count = Product.getElementAmount(element)
    local name = Product.getLocalisedName()
    local currentTooltip = {"tooltip.recipe-info-element", count, name}
    -- insert le dernier tooltip dans le precedent
    table.insert(lastTooltip, currentTooltip)
    lastTooltip = currentTooltip
  end
  -- finalise la derniere valeur
  table.insert(lastTooltip, "")
  cache_tooltip_recipe[prototype.name] = tooltip
  return tooltip
end

return ElementGui
