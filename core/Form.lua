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

  self.otherClose = true
  self.locate = "screen"
  self.panelClose = true
  self.help_button = true

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
-- Is visible
--
-- @function [parent=#Form] isVisible
--
-- @return boolean
--
function Form.methods:isVisible()
  return true
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#Form] isSpecial
--
-- @return boolean
--
function Form.methods:isSpecial()
  return false
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getParentPanel
--
-- @return #LuaGuiElement
--
function Form.methods:getParentPanel()
  local lua_player = Player.native()
  return lua_player.gui[self.locate]
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getPanel
--
-- @return #LuaGuiElement
--
function Form.methods:getPanel()
  local ui = Player.getGlobalUI()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:classname()] ~= nil and parent_panel[self:classname()].valid then
    return parent_panel[self:classname()]
  end
  if parent_panel.name == self.locate then
    local panel = ElementGui.addGuiFrameV(parent_panel, self:classname(), helmod_frame_style.default, self.panelCaption or self:classname())
    panel.style.horizontally_stretchable = true
    panel.style.vertically_stretchable = true
    local location = Controller.getLocationForm(self:classname())
    if location ~= nil then
      panel.location = location
    else
      panel.force_auto_center()
    end
    ElementGui.setStyle(panel, self:classname(), "width")
    ElementGui.setStyle(panel, self:classname(), "height")
    --Logging:debug(self:classname(), "children",panel.children_names)
    return panel
  else
    local panel = ElementGui.addGuiFlowH(parent_panel, self:classname(), helmod_flow_style.horizontal)
    panel.style.horizontally_stretchable = true
    panel.style.vertically_stretchable = true
    return panel
  end
end

-------------------------------------------------------------------------------
-- Get the menu panel
--
-- @function [parent=#Form] getMenuPanel
--
-- @return #LuaGuiElement
--
function Form.methods:getMenuPanel()
  local parent_panel = self:getPanel()
  local panel_name = "menu"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name]
  end
  local panel = ElementGui.addGuiFlowH(parent_panel, panel_name, helmod_flow_style.horizontal)
  panel.style.horizontally_stretchable = true
  --panel.style.vertically_stretchable = true
  panel.style.height = 32
  return panel
end

-------------------------------------------------------------------------------
-- Get the left menu panel
--
-- @function [parent=#Form] getLeftMenuPanel
--
-- @return #LuaGuiElement
--
function Form.methods:getLeftMenuPanel()
  local parent_panel = self:getMenuPanel()
  local panel_name = "left_menu"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name]
  end
  local panel = ElementGui.addGuiFlowH(parent_panel, panel_name, helmod_flow_style.horizontal)
  panel.style.horizontal_spacing = 10
  panel.style.horizontally_stretchable = true
  --panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get the right menu panel
--
-- @function [parent=#Form] getRightMenuPanel
--
-- @return #LuaGuiElement
--
function Form.methods:getRightMenuPanel()
  local parent_panel = self:getMenuPanel()
  local panel_name = "right_menu"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name]
  end
  local panel = ElementGui.addGuiFlowH(parent_panel, panel_name, helmod_flow_style.horizontal)
  panel.style.horizontal_spacing = 10
  --panel.style.horizontally_stretchable = true
  --panel.style.vertically_stretchable = true
  panel.style.horizontal_align = "right"
  return panel
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
  Logging:debug(self:classname(), "open()", action, item, item2, item3)
  local parent_panel = self:getParentPanel()
  if parent_panel[self:classname()] == nil then
    self:onOpen(event, action, item, item2, item3)
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
  Logging:debug(self:classname(), "beforeEvent()", action, item, item2, item3)
  local parent_panel = self:getParentPanel()
  local close = self:onBeforeEvent(event, action, item, item2, item3)
  if parent_panel ~= nil and parent_panel[self:classname()] ~= nil and parent_panel[self:classname()].valid then
    Logging:debug(self:classname() , "must close?",close)
    if close and action == "OPEN" then
      self:close(true)
    end
  end
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#Form] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Form.methods:onBeforeEvent(event, action, item, item2, item3)
  return false
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
  return false
end

-------------------------------------------------------------------------------
-- Prepare
--
-- @function [parent=#Form] prepare
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Form.methods:prepare(event, action, item, item2, item3)
  return false
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
  -- ajoute un menu
  if self.panelCaption ~= nil then

    local left_menu_panel = self:getLeftMenuPanel()
    local right_menu_panel = self:getRightMenuPanel()
    right_menu_panel.clear()
    if self.panelClose then
      local group1 = ElementGui.addGuiFlowH(right_menu_panel,"group1",helmod_flow_style.horizontal)
      for _, form in pairs(Controller.getViews()) do
        if string.find(form:classname(), "Tab") and form:isVisible() and form:isSpecial() then
          local style, selected_style = form:getButtonStyles()
          if Controller.isActiveForm(form:classname()) then style = selected_style end
          ElementGui.addGuiButton(group1, self:classname().."=change-tab=ID=", form:classname(), style, nil, form:getButtonCaption())
        end
      end

      local group2 = ElementGui.addGuiFlowH(right_menu_panel,"group2",helmod_flow_style.horizontal)
      if self.help_button then
        ElementGui.addGuiButton(group2, "HMHelpPanel=OPEN", nil, "helmod_button_icon_help", nil, ({"helmod_button.help"}))
      end
      ElementGui.addGuiButton(group2, self:classname().."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
    end
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
  local panel = self:getPanel()
  panel.clear()
  panel.focus()

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
  local ui = Player.getGlobalUI()
  local panel = self:getPanel()
  Controller.setCloseForm(self:classname(), panel.location)
  self:onClose()
  panel.destroy()
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
