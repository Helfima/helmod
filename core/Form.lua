-------------------------------------------------------------------------------
-- Class to help to build form
-- 
-- @module Form
-- 
Form = setclass("HMForm")

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Form] init
-- 
-- @param #Controller parent parent controller
-- 
function Form.methods:init(parent)
	self.parent = parent
  self.color_button_edit = "green"
  self.color_button_add = "yellow"
  self.color_button_rest = "red"

  self.state = 0

  self.STATE_CLOSE = 0
  self.STATE_EVENT = 1
  self.STATE_OPEN = 2
  self.STATE_UPDATE = 3
  
  self.otherClose = true
  
	self:onInit(parent)
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Form] onInit
-- 
-- @param #Controller parent parent controller
-- 
function Form.methods:onInit(parent)
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getParentPanel
-- 
-- @return #LuaGuiElement
--  
function Form.methods:getParentPanel()
	
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getPanel
-- 
-- @return #LuaGuiElement
--  
function Form.methods:getPanel()
	local parent_panel = self:getParentPanel()
	if parent_panel[self:classname()] ~= nil and parent_panel[self:classname()].valid then
		return parent_panel[self:classname()]
	end
	return ElementGui.addGuiTable(parent_panel, self:classname(), 1, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Is opened panel
--
-- @function [parent=#Form] isOpened
--
function Form.methods:isOpened()
  Logging:trace(self:classname(), "isOpened()")
  local parent_panel = self:getParentPanel()
  if parent_panel[self:classname()] ~= nil then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#Form] open
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Form.methods:open(event, action, item, item2, item3)
	Logging:debug(self:classname(), "open():", action, item, item2, item3)
	if(self.otherClose) then
  	for view_name,form in pairs(Controller.getViews()) do
  	  if string.find(view_name, "Edition") or string.find(view_name, "Selector") or string.find(view_name, "Settings") or string.find(view_name, "Help") or string.find(view_name, "Download") then
  	    if view_name ~= self:classname() then form:close() end
  	  end
  	end
	end
	
  local parentPanel = self:getParentPanel()
  if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
    local close = self:onOpen(event, action, item, item2, item3)
    --Logging:debug(self:classname() , "must close:",close)
    if close and action == "OPEN" then
      self:close(true)
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

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Form] onEvent
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Form.methods:onEvent(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Before Open
--
-- @function [parent=#Form] beforeOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Form.methods:beforeOpen(event, action, item, item2, item3)
  Logging:debug(self:classname(), "beforeOpen():", action, item, item2, item3)
end
-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Form] onOpen
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Form.methods:onOpen(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#Form] afterOpen
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Form.methods:afterOpen(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#Form] update
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Form.methods:update(event, action, item, item2, item3)
	self:onUpdate(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Form] onUpdate
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function Form.methods:onUpdate(event, action, item, item2, item3)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#Form] close
-- 
-- @param #boolean force state close
-- 
function Form.methods:close(force)
	self:onClose()
	local parentPanel = self:getParentPanel()
	if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
		parentPanel[self:classname()].destroy()
	end
	if force then
	 self.state = self.STATE_CLOSE
	end
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#Form] onClose
-- 
-- @return #boolean if true the next call close dialog
-- 
function Form.methods:onClose()
end
