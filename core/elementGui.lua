ElementGui = setclass("HMElementGui")

--===========================
function ElementGui.methods:getInputNumber(element)
	Logging:trace("ElementGui:getInputNumber", element)
	local count = 0
	if element ~= nil then
		local tempCount=tonumber(element.text)
		if type(tempCount) == "number" then count = tempCount end
	end
	return count
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiLabel(parent, key, caption)
	Logging:trace("ElementGui:addGuiLabel", parent, key, caption)
	return parent.add({type="label", name=key, caption=caption})
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiText(parent, key, text)
	Logging:trace("ElementGui:addGuiText", parent, key, text)
	return parent.add({type="textfield", name=key, text=text})
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiButton(parent, action, key, style, caption)
	Logging:trace("ElementGui:addGuiButton", parent, action, key, style, caption)
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

	local button = nil
	local ok , err = pcall(function()
		button = parent.add(options)
	end)
	if not ok then
		Logging:error("ElementGui:addGuiButton", action, key, style, err)
		options.style = "helmod_button-default"
		if caption ~= nil then
			options.caption = key.."("..caption..")"
		else
			options.caption = key
		end
		button = parent.add(options)
	end
	return button
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiCheckbox(parent, key, state, style)
	Logging:trace("ElementGui:addGuiCheckbox", parent, key, state, style)
	return parent.add({type="checkbox", name=key, state=state, style=style})
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addItemButton(parent, action, key, caption)
	Logging:trace("ElementGui:addItemButton", parent, action, key, caption)
	return self:addGuiButton(parent, action, key, key, caption)
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addIconButton(parent, action, type, key, caption)
	Logging:trace("ElementGui:addIconButton", parent, action, type, key, caption)
	return self:addGuiButton(parent, action, key, "helmod_button_"..type.."_"..key, caption)
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addStyledSpriteButton(parent, style, action, type, key, caption)
	Logging:trace("ElementGui:addStyledSpriteButton", style,action, type, key, caption)
	local options = {}
	options.type = "sprite-button"
	if key ~= nil then
		options.name = action..key
	else
		options.name = action
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

--------------------------------------------------------------------------------------
function ElementGui.methods:addSmSpriteButton(parent, action, type, key, caption)
	Logging:trace("ElementGui:addSmSpriteButton",action, type, key, caption)
	return self:addStyledSpriteButton(parent, "helmod_button-item-small", action, type, key, caption)
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addSpriteButton(parent, action, type, key, caption)
	Logging:trace("ElementGui:addSpriteButton",action, type, key, caption)
	return self:addStyledSpriteButton(parent, "helmod_button-item", action, type, key, caption)
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addXxlSpriteButton(parent, action, type, key, caption)
	Logging:trace("ElementGui:addXxlSpriteButton",action, type, key, caption)
	return self:addStyledSpriteButton(parent, "helmod_button-item-xxl", action, type, key, caption)
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiFlowH(parent, key)
	return parent.add{type="flow", name=key, direction="horizontal"}
end

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiFlowV(parent, key)
	return parent.add{type="flow", name=key, direction="vertical"}
end

--------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------
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

--------------------------------------------------------------------------------------
function ElementGui.methods:addGuiTable(parent, key, colspan)
	return parent.add{type="table", name=key, colspan=colspan}
end

function ElementGui.methods:formatNumber(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1 "):gsub(" (%-?)$","%1"):reverse()
end
