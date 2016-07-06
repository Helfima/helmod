PlannerDialog = setclass("HMPlannerDialog")

function PlannerDialog.methods:init(parent)
	self.parent = parent
	self.index = 0
	self.guiInputs = {}
	
	self.ACTION_OPEN = self:classname().."_OPEN"
	self.ACTION_UPDATE =  self:classname().."_UPDATE"
	self.ACTION_CLOSE =  self:classname().."_CLOSE"
	self:on_init(parent)
end

----------------------------------------------------------------
function PlannerDialog.methods:on_init(parent)
	
end

----------------------------------------------------------------
function PlannerDialog.methods:bindPanel(gui)
	if gui ~= nil then
		self.guiPanel = gui
	end
end
----------------------------------------------------------------
function PlannerDialog.methods:bindButton(gui, label)
	local caption = ({self.ACTION_OPEN})
	if label ~= nil then caption = label end
	if gui ~= nil then
		gui.add({type="button", name=self.ACTION_OPEN, caption=caption, style="helmod_button-default"})
	end
end
----------------------------------------------------------------
function PlannerDialog.methods:on_gui_click(event)
	if event.element.valid and string.find(event.element.name, self:classname()) then
		local patternAction = self:classname().."_([^_]*)"
		local patternItem = self:classname()..".*_ID_([^_]*)"
		local patternRecipe = self:classname()..".*_ID_[^_]*_([^_]*)"
		local action = string.match(event.element.name,patternAction,1)
		local item = string.match(event.element.name,patternItem,1)
		local item2 = string.match(event.element.name,patternRecipe,1)
		
		if string.find(event.element.name, self.ACTION_OPEN) then
			self:open(event.element, action, item, item2)
		end

		if string.find(event.element.name, self.ACTION_UPDATE) then
			self:update(event.element, action, item, item2)
		end

		if string.find(event.element.name, self.ACTION_CLOSE) then
			self:close(event.element, action, item, item2)
		end
		
		self:on_event(event.element, action, item, item2)
	end
end

--===========================
function PlannerDialog.methods:open(element, action, item, item2)
	if self.gui == nil then
		local caption = self:classname()
		if self.panelCaption ~= nil then caption = self.panelCaption end
		
		self.gui = self:addGuiFrameV(self.guiPanel, self:classname(), nil, caption)
		self:on_open(element, action, item, item2)
		self:after_open(element, action, item, item2)
		self:update(element, action, item, item2)
	else
		local close = self:on_open(element, action, item, item2)
		--Logging:debug("must close:",close)
		if close then
			self:close(element, action, item, item2)
		else
			self:update(element, action, item, item2)
		end
	end
end

--===========================
function PlannerDialog.methods:on_event(element, action, item, item2)
end

--===========================
function PlannerDialog.methods:on_open(element, action, item, item2)
end

--===========================
function PlannerDialog.methods:after_open(element, action, item, item2)
end

--===========================
function PlannerDialog.methods:update(element, action, item, item2)
	self:on_update(element, action, item, item2)
end

--===========================
function PlannerDialog.methods:on_update(element, action, item, item2)
	
end

--===========================
function PlannerDialog.methods:close(element, action, item, item2)
	self:on_close(element, action, item, item2)
	if self.gui ~= nil then
		self.gui.destroy()
		self.gui = nil
	end
end

--===========================
function PlannerDialog.methods:on_close(element, action, item, item2)
end

--===========================
function PlannerDialog.methods:getInputNumber(element)
	local count = 0
	if element ~= nil then
		local tempCount=tonumber(element.text)
		if type(tempCount) == "number" then count = tempCount end
	end
	return count
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addGuiLabel(parent, key, caption)
	return parent.add({type="label", name=key, caption=caption})
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addGuiText(parent, key, text)
	return parent.add({type="textfield", name=key, text=text})
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addGuiButton(parent, action, key, style, caption)
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
function PlannerDialog.methods:addGuiCheckbox(parent, key, state, style)
	return parent.add({type="checkbox", name=key, state=state, style=style})
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addItemButton(parent, action, key, caption)
	return self:addGuiButton(parent, action, key, key, caption)
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addIconButton(parent, action, type, key, caption)
	return self:addGuiButton(parent, action, key, "helmod_button_"..type.."_"..key, caption)
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addIconCheckbox(parent, action, type, key, state , caption)
	local controller = self
	local checkbox = nil
	local ok , err = pcall(function()
		checkbox = controller:addGuiCheckbox(parent, action..key, state, "helmod_checkbox_"..type.."_"..key)
	end)
	if not ok then
		Logging:debug(err)
		if caption ~= nil then
			checkbox = self:addGuiButton(parent, action, key, "helmod_button-default", key.."("..caption..")")
		else
			checkbox = self:addGuiButton(parent, action, key, "helmod_button-default", key)
		end
	end
	return checkbox
end
--------------------------------------------------------------------------------------
function PlannerDialog.methods:addGuiFlowH(parent, key)
	return parent.add{type="flow", name=key, direction="horizontal"}
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addGuiFlowV(parent, key)
	return parent.add{type="flow", name=key, direction="vertical"}
end

--------------------------------------------------------------------------------------
function PlannerDialog.methods:addGuiFrameH(parent, key, style, caption)
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
function PlannerDialog.methods:addGuiFrameV(parent, key, style, caption)
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
function PlannerDialog.methods:addGuiTable(parent, key, colspan)
	return parent.add{type="table", name=key, colspan=colspan}
end

function PlannerDialog.methods:formatNumber(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1 "):gsub(" (%-?)$","%1"):reverse()
end

function PlannerDialog.methods:saveData(data)
	local content = serpent.dump(data)
	game.write_file(self.modelFilename, content)
end


