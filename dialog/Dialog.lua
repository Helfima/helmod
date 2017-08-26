-------------------------------------------------------------------------------
-- Class to help to build dialog
-- 
-- @module Dialog
-- 
Dialog = setclass("HMDialog")

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
	self:onInit(parent)
	
	self.color_button_edit="green"
  self.color_button_add="yellow"
  self.color_button_rest="red"
	
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Dialog] onInit
-- 
-- @param #Controller parent parent controller
-- 
function Dialog.methods:onInit(parent)

end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Dialog] getParentPanel
-- 
-- @return #LuaGuiElement
--  
function Dialog.methods:getParentPanel()
	
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Dialog] getPanel
-- 
-- @return #LuaGuiElement
--  
function Dialog.methods:getPanel()
	local panel = self:getParentPanel()
	if panel[self:classname()] ~= nil and panel[self:classname()].valid then
		return panel[self:classname()]
	end
	return ElementGui.addGuiFlowV(panel, self:classname(), "helmod_flow_resize_row_width")
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
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:open(event, action, item, item2, item3)
	Logging:debug(self:classname(), "open():", action, item, item2, item3)
	
	for view_name,view in pairs(Controller.getViews()) do
	  if string.find(view_name, "Edition") or string.find(view_name, "Selector") or string.find(view_name, "Settings") then
	    if view_name ~= self:classname() then Controller.sendEvent(nil, view_name, "CLOSE") end
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
		local headerPanel = ElementGui.addGuiFrameH(panel, "header-panel", "helmod_frame_resize_row_width")
		ElementGui.addGuiLabel(headerPanel, "title", caption, "helmod_label_title_frame")
		
		self:onOpen(event, action, item, item2, item3)
		self:afterOpen(event, action, item, item2, item3)
		self:update(event, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Send event
--
-- @function [parent=#Dialog] sendEvent
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:sendEvent(event, action, item, item2, item3)
		Logging:debug(self:classname(), "sendEvent():", action, item, item2, item3)
		if action == "OPEN" then
			self:open(event, action, item, item2, item3)
		end

		if action == "UPDATE" then
			self:update(event, action, item, item2, item3)
		end

		if action == "CLOSE" then
			self:close(event, action, item, item2, item3)
		end

		self:onEvent(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Dialog] onEvent
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:onEvent(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Dialog] onOpen
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:onOpen(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#Dialog] afterOpen
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:afterOpen(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#Dialog] update
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:update(event, action, item, item2, item3)
	self:onUpdate(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Dialog] onUpdate
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:onUpdate(event, action, item, item2, item3)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#Dialog] close
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Dialog.methods:close(event, action, item, item2, item3)
	self:onClose(event, action, item, item2, item3)
	local parentPanel = self:getParentPanel()
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		parentPanel[self:classname()].destroy()
	end
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#Dialog] onClose
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
-- @return #boolean if true the next call close dialog
-- 
function Dialog.methods:onClose(event, action, item, item2, item3)
end
