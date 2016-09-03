-------------------------------------------------------------------------------
-- Classe to help to define Gui for Factorio
--
-- @module ElementGui
ElementGui = setclass("HMElementGui")

-------------------------------------------------------------------------------
-- Get the number of textfield input
--
-- @function [parent=#ElementGui] getInputNumber
--
-- @param #LuaGuiElement element textfield input
--
-- @return #number number of textfield input
--
function ElementGui.methods:getInputNumber(element)
	Logging:trace("ElementGui:getInputNumber", element)
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
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addGuiLabel(parent, key, caption, style)
	Logging:trace("ElementGui:addGuiLabel", parent, key, caption)
	local options = {}
	options.type = "label"
	options.name = key
	options.caption = caption
	if style ~= nil then
		options.style = style
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
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addGuiText(parent, key, text, style)
	Logging:trace("ElementGui:addGuiText", parent, key, text, style)
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
function ElementGui.methods:addGuiButton(parent, action, key, style, caption, tooltip)
	Logging:trace("ElementGui:addGuiButton", parent, action, key, style, caption, tooltip)
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
		Logging:error("ElementGui:addGuiButton", action, key, style, err)
		options.style = "helmod_button-default"
		if (type(caption) == "boolean") then
			Logging:error("ElementGui:addGuiButton - caption is a boolean")
		elseif caption ~= nil then
			options.caption = key.."("..caption..")"
		else
			options.caption = key
		end
		button = parent.add(options)
	end
	return button
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
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addGuiCheckbox(parent, key, state, style)
	Logging:trace("ElementGui:addGuiCheckbox", parent, key, state, style)
	return parent.add({type="checkbox", name=key, state=state, style=style})
end

-------------------------------------------------------------------------------
-- Add a button element for item
--
-- @function [parent=#ElementGui] addItemButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string key unique id
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addItemButton(parent, action, key, caption)
	Logging:trace("ElementGui:addItemButton", parent, action, key, caption)
	return self:addGuiButton(parent, action, key, key, caption)
end

-------------------------------------------------------------------------------
-- Add a icon button element for item
--
-- @function [parent=#ElementGui] addIconButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addIconButton(parent, action, type, key, caption)
	Logging:trace("ElementGui:addIconButton", parent, action, type, key, caption)
	return self:addGuiButton(parent, action, key, "helmod_button_"..type.."_"..key, caption)
end

-------------------------------------------------------------------------------
-- Add a icon button element for item
--
-- @function [parent=#ElementGui] addMiniIconButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addMiniIconButton(parent, action, type, key, caption)
	Logging:trace("ElementGui:addIconButton", parent, action, type, key, caption)
	return self:addGuiButton(parent, action, key, "helmod_16_button_"..type.."_"..key, caption)
end

-------------------------------------------------------------------------------
-- Add a sprite button element for item
--
-- @function [parent=#ElementGui] addStyledSpriteButton
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
function ElementGui.methods:addStyledSpriteButton(parent, style, action, type, key, caption, tooltip)
	Logging:trace("ElementGui:addStyledSpriteButton", style,action, type, key, caption, tooltip)
	local options = {}
	options.type = "sprite-button"
	if key ~= nil then
		options.name = action..key
	else
		options.name = action
	end
	if caption ~= nil then
		options.caption = caption
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
		Logging:error("ElementGui:addStyledSpriteButton", action, type, key, err)
		if parent[options.name] and parent[options.name].valid then
			parent[options.name].destroy()
		end
		self:addIconButton(parent, action, type, key, caption)
	end
	return button
end

-------------------------------------------------------------------------------
-- Add a smal sprite button element for item
--
-- @function [parent=#ElementGui] addSmSpriteButton
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
function ElementGui.methods:addSmSpriteButton(parent, action, type, key, caption, tooltip)
	Logging:trace("ElementGui:addSmSpriteButton",action, type, key, caption, tooltip)
	return self:addStyledSpriteButton(parent, "helmod_sm-button-icon", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a smal sprite button element for item selection
--
-- @function [parent=#ElementGui] addSelectSmSpriteButton
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
function ElementGui.methods:addSelectSmSpriteButton(parent, action, type, key, caption, tooltip)
	Logging:trace("ElementGui:addSmSpriteButton",action, type, key, caption, tooltip)
	return self:addStyledSpriteButton(parent, "helmod_sm-select-button-icon", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a normal sprite button element for item
--
-- @function [parent=#ElementGui] addSpriteIconButton
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
function ElementGui.methods:addSpriteIconButton(parent, action, type, key, caption, tooltip)
	Logging:trace("ElementGui:addSelectSpriteIconButton",action, type, key, caption, tooltip)
	return self:addStyledSpriteButton(parent, "helmod_button-icon", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a sprite button element for item selection
--
-- @function [parent=#ElementGui] addSelectSpriteIconButton
--
-- @param #LuaGuiElement parent container for element
-- @param #string action action name
-- @param #string type type of item
-- @param #string key name of item
-- @param #string caption displayed text
-- @param #string color background color
-- @param #string tooltip displayed text
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function ElementGui.methods:addSelectSpriteIconButton(parent, action, type, key, caption, color, tooltip)
	Logging:trace("ElementGui:addSelectSpriteIconButton",action, type, key, caption, color, tooltip)
	local style = "helmod_select-button-icon"
	if color == "red" then style = "helmod_select-button-icon-red" end
	if color == "yellow" then style = "helmod_select-button-icon-yellow" end
	if color == "green" then style = "helmod_select-button-icon-green" end
	return self:addStyledSpriteButton(parent, style, action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a big sprite button element for item
--
-- @function [parent=#ElementGui] addXxlSpriteIconButton
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
function ElementGui.methods:addXxlSpriteIconButton(parent, action, type, key, caption, tooltip)
	Logging:trace("ElementGui:addXxlSpriteButton",action, type, key, caption, tooltip)
	return self:addStyledSpriteButton(parent, "helmod_xxl-button-icon", action, type, key, caption, tooltip)
end

-------------------------------------------------------------------------------
-- Add a big sprite button element for item selection
--
-- @function [parent=#ElementGui] addXxlSelectSpriteIconButton
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
function ElementGui.methods:addXxlSelectSpriteIconButton(parent, action, type, key, caption, tooltip)
	Logging:trace("ElementGui:addXxlSelectSpriteIconButton",action, type, key, caption, tooltip)
	return self:addStyledSpriteButton(parent, "helmod_xxl-select-button-icon", action, type, key, caption, tooltip)
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
function ElementGui.methods:addGuiFlowH(parent, key, style)
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
function ElementGui.methods:addGuiFlowV(parent, key, style)
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
function ElementGui.methods:addGuiScrollPane(parent, key, style, horizontal, vertical)
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
function ElementGui.methods:addGuiFrameH(parent, key, style, caption)
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
function ElementGui.methods:addGuiFrameV(parent, key, style, caption)
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
function ElementGui.methods:addGuiTable(parent, key, colspan, style)
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
-- Format the number
--
-- @function [parent=#ElementGui] formatNumber
--
-- @param #number n the number
--
-- @return #number the formated number
--
function ElementGui.methods:formatNumber(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1 "):gsub(" (%-?)$","%1"):reverse()
end

-------------------------------------------------------------------------------
-- Format the number
--
-- @function [parent=#ElementGui] formatNumberKilo
--
-- @param #number n the number
-- @param #string suffix
--
-- @return #number the formated number
--
function ElementGui.methods:formatNumberKilo(value, suffix)
	if suffix == nil then suffix = "" end
	if value == nil then
		return 0
	elseif value < 1000 then
		return value
	elseif (value / 1000) < 1000 then
		return math.ceil(value*10 / 1000)/10 .. " K"..suffix
	elseif (value / (1000*1000)) < 1000 then
		return math.ceil(value*10 / (1000*1000))/10 .. " M"..suffix
	else
		return math.ceil(value*10 / (1000*1000*1000))/10 .. " G"..suffix
	end
end

-------------------------------------------------------------------------------
-- Format the number
--
-- @function [parent=#ElementGui] formatRound
--
-- @param #number n the number
--
-- @return #number the formated number
--
function ElementGui.methods:formatRound(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end


-------------------------------------------------------------------------------
-- Format the number
--
-- @function [parent=#ElementGui] formatPercent
--
-- @param #number n the number
--
-- @return #number the formated number
--
function ElementGui.methods:formatPercent(num)
  local mult = 10^3
  return math.floor(num * mult + 0.5) / 10
end
