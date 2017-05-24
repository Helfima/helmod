-------------------------------------------------------------------------------
-- Class to help to build dialog
-- 
-- @module Dialog
-- @extends #ElementGui 
-- 
Dialog = setclass("HMDialog", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Dialog] init
-- 
-- @param #Controller parent parent controller
-- 
function Dialog.methods:init(parent)
	self.parent = parent
	
	self.ACTION_OPEN = self:classname().."=OPEN"
	self.ACTION_UPDATE =  self:classname().."=UPDATE"
	self.ACTION_CLOSE =  self:classname().."=CLOSE"
	self:on_init(parent)
	
	self.color_button_edit="green"
  self.color_button_add="yellow"
  self.color_button_rest="red"
	
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Dialog] on_init
-- 
-- @param #Controller parent parent controller
-- 
function Dialog.methods:on_init(parent)

end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Dialog] getParentPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
--  
function Dialog.methods:getParentPanel(player)
	
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Dialog] getPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
--  
function Dialog.methods:getPanel(player)
	local panel = self:getParentPanel(player)
	if panel[self:classname()] ~= nil and panel[self:classname()].valid then
		return panel[self:classname()]
	end
	return self:addGuiFlowV(panel, self:classname(), "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Bind the button
--
-- @function [parent=#Dialog] bindButton
-- 
-- @param #LuaGuiElement gui parent element
-- @param #string label displayed text
-- 
function Dialog.methods:bindButton(gui, label)
	local caption = ({self.ACTION_OPEN})
	if label ~= nil then caption = label end
	if gui ~= nil then
		gui.add({type="button", name=self.ACTION_OPEN, caption=caption, style="helmod_button_default"})
	end
end

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#Dialog] open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:open(player, element, action, item, item2, item3)
	Logging:debug(self:classname(), "open():",player, element, action, item, item2, item3)
	local parentPanel = self:getParentPanel(player)
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		local close = self:on_open(player, element, action, item, item2, item3)
		--Logging:debug(self:classname() , "must close:",close)
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
-- @function [parent=#Dialog] send_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:send_event(player, element, action, item, item2, item3)
		Logging:debug(self:classname(), "send_event():",player, element, action, item, item2, item3)
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
-- @function [parent=#Dialog] on_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:on_event(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Dialog] on_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:on_open(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#Dialog] after_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:after_open(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#Dialog] update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:update(player, element, action, item, item2, item3)
	self:on_update(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Dialog] on_update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:on_update(player, element, action, item, item2, item3)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#Dialog] close
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:close(player, element, action, item, item2, item3)
	self:on_close(player, element, action, item, item2, item3)
	local parentPanel = self:getParentPanel(player)
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		parentPanel[self:classname()].destroy()
	end
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#Dialog] on_close
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
function Dialog.methods:on_close(player, element, action, item, item2, item3)
end
