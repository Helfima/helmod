-------------------------------------------------------------------------------
-- Class to help to build dialog
-- 
-- @module Dialog
-- 
Dialog = setclass("HMDialog", Form)

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
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:open2(event, action, item, item2, item3)
	Logging:debug(self:classname(), "open():", action, item, item2, item3)
	
	for view_name,form in pairs(Controller.getViews()) do
	  if string.find(view_name, "Edition") or string.find(view_name, "Selector") or string.find(view_name, "Settings") or string.find(view_name, "Help") or string.find(view_name, "Download") then
	    if view_name ~= self:classname() then form:close() end
	  end
	end
	
	local parentPanel = self:getParentPanel()
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		local close = self:onOpen(event, action, item, item2, item3)
		--Logging:debug(self:classname() , "must close:",close)
		if close then
			self:close(event, action, item, item2, item3)
		else
			self:update(event, action, item, item2, item3)
		end
		
	else
		-- affecte le caption
		local caption = self:classname()
		if self.panelCaption ~= nil then caption = self.panelCaption end

		local panel = self:getPanel()
		
		ElementGui.addGuiFrameH(panel, "header-panel", helmod_frame_style.panel, caption)
		
		self:onOpen(event, action, item, item2, item3)
		self:afterOpen(event, action, item, item2, item3)
		
	end
end


