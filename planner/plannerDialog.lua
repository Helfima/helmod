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
	
	self.ACTION_OPEN = self:classname().."=OPEN"
	self.ACTION_UPDATE =  self:classname().."=UPDATE"
	self.ACTION_CLOSE =  self:classname().."=CLOSE"
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
-- Get the parent panel
--
-- @function [parent=#PlannerDialog] getParentPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
--  
function PlannerDialog.methods:getParentPanel(player)
	
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerDialog] getPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
--  
function PlannerDialog.methods:getPanel(player)
	local panel = self:getParentPanel(player)
	if panel[self:classname()] ~= nil and panel[self:classname()].valid then
		return panel[self:classname()]
	end
	return self:addGuiFlowV(panel, self:classname(), "helmod_flow_resize_row_width")
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
-- 
function PlannerDialog.methods:on_gui_click(event)
	if event.element.valid and string.find(event.element.name, self:classname()) then
		local player = game.players[event.player_index]
		
		local patternAction = self:classname().."=([^=]*)"
		local patternItem = self:classname()..".*=ID=([^=]*)"
		local patternItem2 = self:classname()..".*=ID=[^=]*=([^=]*)"
		local patternItem3 = self:classname()..".*=ID=[^=]*=[^=]*=([^=]*)"
		local action = string.match(event.element.name,patternAction,1)
		local item = string.match(event.element.name,patternItem,1)
		local item2 = string.match(event.element.name,patternItem2,1)
		local item3 = string.match(event.element.name,patternItem3,1)

		self:send_event(player, event.element, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#PlannerDialog] open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:open(player, element, action, item, item2, item3)
	Logging:debug("PlannerDialog:open():",player, element, action, item, item2, item3)
	local parentPanel = self:getParentPanel(player)
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		local close = self:on_open(player, element, action, item, item2, item3)
		--Logging:debug("must close:",close)
		if close then
			self:close(player, element, action, item, item2, item3)
		else
			self:update(player, element, action, item, item2, item3)
		end
		
	else
		-- affecte le caption
		local caption = self:classname()
		if self.panelCaption ~= nil then caption = self.panelCaption end

		local panel = self:getPanel(player)
		local headerPanel = self:addGuiFrameH(panel, "header-panel", "helmod_frame_resize_row_width")
		self:addGuiLabel(headerPanel, "title", caption, "helmod_label_title_frame")
		
		self:on_open(player, element, action, item, item2, item3)
		self:after_open(player, element, action, item, item2, item3)
		self:update(player, element, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Send event
--
-- @function [parent=#PlannerDialog] send_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:send_event(player, element, action, item, item2, item3)
		Logging:debug("PlannerDialog:send_event():",player, element, action, item, item2, item3)
		if action == "OPEN" then
			self:open(player, element, action, item, item2, item3)
		end

		if action == "UPDATE" then
			self:update(player, element, action, item, item2, item3)
		end

		if action == "CLOSE" then
			self:close(player, element, action, item, item2, item3)
		end

		self:on_event(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerDialog] on_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:on_event(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerDialog] on_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:on_open(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerDialog] after_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:after_open(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerDialog] update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:update(player, element, action, item, item2, item3)
	self:on_update(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerDialog] on_update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:on_update(player, element, action, item, item2, item3)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#PlannerDialog] close
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerDialog.methods:close(player, element, action, item, item2, item3)
	self:on_close(player, element, action, item, item2, item3)
	local parentPanel = self:getParentPanel(player)
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		parentPanel[self:classname()].destroy()
	end
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerDialog] on_close
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
-- @return #boolean if true the next call close dialog
-- 
function PlannerDialog.methods:on_close(player, element, action, item, item2, item3)
end
