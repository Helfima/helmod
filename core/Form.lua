-------------------------------------------------------------------------------
-- Class to help to build form
--
-- @module Form
--
Form = class(function(base,classname)
  base.classname = classname
  base.otherClose = true
  base.locate = "screen"
  base.panelClose = true
  base.help_button = true
  base.auto_clear = true
  base.content_verticaly = true
  base:onInit()
end)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Form] onInit
--
function Form:onInit()
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#Form] isVisible
--
-- @return boolean
--
function Form:isVisible()
  return true
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#Form] isSpecial
--
-- @return boolean
--
function Form:isSpecial()
  return false
end

-------------------------------------------------------------------------------
-- Get panel name
--
-- @function [parent=#Form] getPanelName
--
-- @return #LuaGuiElement
--
function Form:getPanelName()
  return self.classname
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getParentPanel
--
-- @return #LuaGuiElement
--
function Form:getParentPanel()
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
function Form:getPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil and parent_panel[self:getPanelName()].valid then
    return parent_panel[self:getPanelName()], parent_panel[self:getPanelName()]["content_panel"], parent_panel[self:getPanelName()]["header_panel"]["menu_panel"]
  end

  local flow_panel = ElementGui.addGuiFrameV(parent_panel, self:getPanelName(), helmod_frame_style.hidden)
  flow_panel.style.horizontally_stretchable = true
  flow_panel.style.vertically_stretchable = true
  flow_panel.location = User.getLocationForm(self:getPanelName())
  Logging:debug(self.classname, "location", self:getPanelName(), User.getLocationForm(self:getPanelName()))
  ElementGui.setStyle(flow_panel, self.classname, "width")
  ElementGui.setStyle(flow_panel, self.classname, "height")
  
  local header_panel = ElementGui.addGuiFlowH(flow_panel, "header_panel")
  local title_panel = ElementGui.addGuiFrameH(header_panel, "title_panel", helmod_frame_style.default, self.panelCaption or self.classname)
  title_panel.style.height = 40
  local menu_panel = ElementGui.addGuiFrameH(header_panel, "menu_panel", helmod_frame_style.panel)
  --menu_panel.style.horizontal_spacing = 10
  menu_panel.style.horizontal_align = "right"
  
  local content_panel
  if self.content_verticaly then
    content_panel = ElementGui.addGuiFlowV(flow_panel, "content_panel")
  else
    content_panel = ElementGui.addGuiFlowH(flow_panel, "content_panel")
  end
  title_panel.drag_target = flow_panel
  --Logging:debug(self.classname, "children",panel.children_names)
  return flow_panel, content_panel, menu_panel
end

-------------------------------------------------------------------------------
-- Get the menu panel
--
-- @function [parent=#Form] getMenuPanel
--
-- @return #LuaGuiElement
--
function Form:getMenuPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "menu"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = ElementGui.addGuiFrameH(content_panel, panel_name, helmod_frame_style.default)
  panel.style.horizontally_stretchable = true
  --panel.style.vertically_stretchable = true
  panel.style.height = 40
  return panel
end

-------------------------------------------------------------------------------
-- Get the left menu panel
--
-- @function [parent=#Form] getLeftMenuPanel
--
-- @return #LuaGuiElement
--
function Form:getLeftMenuPanel()
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
function Form:getRightMenuPanel()
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
function Form:isOpened()
  Logging:trace(self.classname, "isOpened()")
  local parent_panel = self:getParentPanel()
  if parent_panel[self.classname] ~= nil then
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
function Form:open(event, action, item, item2, item3)
  Logging:debug(self.classname, "open()", action, item, item2, item3)
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] == nil then
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
function Form:beforeEvent(event, action, item, item2, item3)
  Logging:debug(self.classname, "beforeEvent()", action, item, item2, item3)
  local parent_panel = self:getParentPanel()
  local close = self:onBeforeEvent(event, action, item, item2, item3)
  if parent_panel ~= nil and parent_panel[self:getPanelName()] ~= nil and parent_panel[self:getPanelName()].valid then
    Logging:debug(self.classname , "must close?",close)
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
function Form:onBeforeEvent(event, action, item, item2, item3)
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
function Form:onEvent(event, action, item, item2, item3)
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
function Form:onOpen(event, action, item, item2, item3)
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
function Form:prepare(event, action, item, item2, item3)
  return false
end

-------------------------------------------------------------------------------
-- Update top menu
--
-- @function [parent=#Form] updateTopMenu
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Form:updateTopMenu(event, action, item, item2, item3)
  Logging:debug(self.classname, "updateTopMenu()", action, item, item2, item3)
  -- ajoute un menu
  if self.panelCaption ~= nil then

    local flow_panel, content_panel, menu_panel = self:getPanel()
    menu_panel.clear()
    if self.panelClose then
      local group1 = ElementGui.addGuiFlowH(menu_panel,"group1",helmod_flow_style.horizontal)
      for _, form in pairs(Controller.getViews()) do
        if string.find(self.classname, "Tab") and string.find(form.classname, "Tab") and form:isVisible() and form:isSpecial() then
          local style, selected_style = form:getButtonStyles()
          if User.isActiveForm(form.classname) then style = selected_style end
          ElementGui.addGuiButton(group1, self.classname.."=change-tab=ID=", form.classname, style, nil, form:getButtonCaption())
        end
      end

      local group2 = ElementGui.addGuiFlowH(menu_panel,"group2",helmod_flow_style.horizontal)
      if self.help_button then
        ElementGui.addGuiButton(group2, "HMHelpPanel=OPEN", nil, "helmod_button_icon_help", nil, ({"helmod_button.help"}))
      end
      ElementGui.addGuiButton(group2, self.classname.."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
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
function Form:update(event, action, item, item2, item3)
  Logging:debug(self.classname, "update():", action, item, item2, item3)
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if self.auto_clear then content_panel.clear() end
  if action == "OPEN" then
    self:updateTopMenu(event, action, item, item2, item3)
  end
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
function Form:onUpdate(event, action, item, item2, item3)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#Form] close
--
-- @param #boolean force state close
--
function Form:close(force)
  Logging:debug(self.classname, "close()")
  local flow_panel, content_panel, menu_panel = self:getPanel()
  User.setCloseForm(self.classname, flow_panel.location)
  self:onClose()
  flow_panel.destroy()
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#Form] onClose
--
-- @return #boolean if true the next call close dialog
--
function Form:onClose()
end
