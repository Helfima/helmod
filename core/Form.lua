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

  self.otherClose = true
  self.locate = "dialog"

  self.pinLocate = "left"

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
  --local panel = ElementGui.addGuiTable(parent_panel, self:classname(), 1, helmod_table_style.panel)
  local panel = ElementGui.addGuiFrameV(parent_panel, self:classname(), helmod_frame_style.hidden)
  return panel
end

-------------------------------------------------------------------------------
-- Bind the button
--
-- @function [parent=#Form] bindButton
--
-- @param #LuaGuiElement gui parent element
-- @param #string label displayed text
--
function Form.methods:bindButton(gui, label)
  local caption = ({self.ACTION_OPEN})
  if label ~= nil then caption = label end
  if gui ~= nil then
    gui.add({type="button", name=self.ACTION_OPEN, caption=caption, style="helmod_button_default"})
  end
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
  local parentPanel = self:getParentPanel()
  if parentPanel[self:classname()] == nil then
    Logging:debug(self:classname(), "parentPanel.clear()")
    parentPanel.clear()
    self:onOpen(event, action, item, item2, item3)
    self:afterOpen(event, action, item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#Form] beforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Form.methods:beforeEvent(event, action, item, item2, item3)
  local parentPanel = self:getParentPanel()
  if parentPanel[self:classname()] ~= nil and parentPanel[self:classname()].valid then
    local close = self:onOpen(event, action, item, item2, item3)
    Logging:debug(self:classname() , "must close:",close)
    if close and action == "OPEN" then
      self:close(true)
    end
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
  Logging:debug(self:classname(), "onOpen():", action, item, item2, item3)
  return false
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
-- Update header
--
-- @function [parent=#Form] updateTitle
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Form.methods:updateTitle(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateTitle():", action, item, item2, item3)
      local panel = self:getPanel()
    -- affecte le caption
    if self.panelCaption ~= nil and panel["title-panel"] == nil then
      local caption = self.panelCaption

      local header_panel = ElementGui.addGuiFrameH(panel, "title-panel", helmod_frame_style.panel, caption)
      header_panel.style.height = 30
    end
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
  Logging:debug(self:classname(), "update():", action, item, item2, item3)
  self:updateTitle(event, action, item, item2, item3)
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
  Logging:debug(self:classname(), "close()")
  self:onClose()
  local parentPanel = self:getParentPanel()
  parentPanel.clear()
  local ui = Player.getGlobalUI()
  if string.find(self:classname(), "Edition") or string.find(self:classname(), "Selector") or string.find(self:classname(), "Settings") or string.find(self:classname(), "Help") or string.find(self:classname(), "Download") then
    ui.dialog = nil
  end
  if string.find(self:classname(), "Tab") then
    ui.data = nil
  end
  Logging:debug(self:classname(), "**** UI", ui)
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
