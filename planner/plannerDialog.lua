-------------------------------------------------------------------------------
-- Classe to help to build dialog
-- 
-- @module PlannerDialog
-- @extends #ElementGui 
-- 
PlannerDialog = setclass("HMPlannerDialog", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlannerDialog] init
-- 
-- @param #PlannerController parent parent controller
-- 
function PlannerDialog.methods:init(parent)
	self.parent = parent
	self.index = 0
	self.guiInputs = {}

	self.ACTION_OPEN = self:classname().."_OPEN"
	self.ACTION_UPDATE =  self:classname().."_UPDATE"
	self.ACTION_CLOSE =  self:classname().."_CLOSE"
	self:on_init(parent)
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerDialog] on_init
-- 
-- @param #PlannerController parent parent controller
-- 
function PlannerDialog.methods:on_init(parent)

end

-------------------------------------------------------------------------------
-- Bind the parent panel
--
-- @function [parent=#PlannerDialog] bindPanel
-- 
-- @param #LuaGuiElement gui parent element
-- 
function PlannerDialog.methods:bindPanel(gui)
	if gui ~= nil then
		self.guiPanel = gui
	end
end

-------------------------------------------------------------------------------
-- Bind the button
--
-- @function [parent=#PlannerDialog] bindButton
-- 
-- @param #LuaGuiElement gui parent element
-- @param #string label displayed text
-- 
function PlannerDialog.methods:bindButton(gui, label)
	local caption = ({self.ACTION_OPEN})
	if label ~= nil then caption = label end
	if gui ~= nil then
		gui.add({type="button", name=self.ACTION_OPEN, caption=caption, style="helmod_button-default"})
	end
end

-------------------------------------------------------------------------------
-- On gui click
--
-- @function [parent=#PlannerDialog] on_gui_click
-- 
-- @param #table event
-- @param #string label displayed text
-- 
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

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#PlannerDialog] open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
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

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerDialog] on_event
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerDialog.methods:on_event(element, action, item, item2)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerDialog] on_open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerDialog.methods:on_open(element, action, item, item2)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerDialog] after_open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerDialog.methods:after_open(element, action, item, item2)
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerDialog] update
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerDialog.methods:update(element, action, item, item2)
	self:on_update(element, action, item, item2)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerDialog] on_update
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerDialog.methods:on_update(element, action, item, item2)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#PlannerDialog] close
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerDialog.methods:close(element, action, item, item2)
	self:on_close(element, action, item, item2)
	if self.gui ~= nil then
		self.gui.destroy()
		self.gui = nil
	end
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerDialog] on_close
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
-- @return #boolean if true the next call close dialog
-- 
function PlannerDialog.methods:on_close(element, action, item, item2)
end
