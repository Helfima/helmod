
PLANNER_COMMAND = "helmod_planner-command"

-------------------------------------------------------------------------------
-- Class of main MainPanel
--
-- @module MainPanel
--

MainPanel = setclass("HMMainPanel")

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#MainPanel] init
--
function MainPanel.methods:init()
  Logging:debug(self:classname(), "init():global=", global)

  self.locate = "center"
  self.pinLocate = "left"

end

-------------------------------------------------------------------------------
-- Cleanup
--
-- @function [parent=#MainPanel] cleanMainPanel
--
function MainPanel.methods:cleanMainPanel()
  Logging:trace(self:classname(), "cleanMainPanel()")
  local lua_player = Player.native()
  for _,location in pairs(helmod_settings_mod.display_location.allowed_values) do
    if lua_player.gui[location]["helmod_planner_main"] ~= nil then
      lua_player.gui[location]["helmod_planner_main"].destroy()
    end
  end
end

-------------------------------------------------------------------------------
-- Bind all MainPanels
--
-- @function [parent=#MainPanel] bindMainPanel
--
function MainPanel.methods:bindMainPanel()
  Logging:trace(self:classname(), "bindMainPanel()")
  local parentGui = Player.getGui()
  if parentGui ~= nil then
    local guiButton = ElementGui.addGuiFrameH(parentGui, PLANNER_COMMAND, "helmod_frame_default")
    guiButton.add({type="button", name=PLANNER_COMMAND, tooltip=({PLANNER_COMMAND}), style="helmod_icon"})
  end
end

-------------------------------------------------------------------------------
-- Prepare main display
--
-- @function [parent=#MainPanel] main
--
function MainPanel.methods:main()
  Logging:debug(self:classname(), "main()")
  local lua_player = Player.native()
  local location = Player.getSettings("display_location")
  local guiMain = lua_player.gui[location]
  if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
    guiMain["helmod_planner_main"].destroy()
  else
    -- main panel
    local mainPanel = self:getMainPanel()
    -- menu
    local menuPanel = self:getMenuPanel()
    local actionPanel = ElementGui.addGuiFrameV(menuPanel, "settings", "helmod_frame_default")
    ElementGui.addGuiButton(actionPanel, self:classname().."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
    ElementGui.addGuiButton(actionPanel, "HMSettings=OPEN", nil, "helmod_button_icon_menu", nil, ({"helmod_button.options"}))
    ElementGui.addGuiButton(actionPanel, "HMHelpPanel=OPEN", nil, "helmod_button_icon_help", nil, ({"helmod_button.help"}))
    -- info
    local infoPanel = self:getInfoPanel()
    -- data
    local dataPanel = self:getDataPanel()
    -- dialogue
    local dialogPanel = self:getDialogPanel()

    -- tab
    Controller.getView("HMMainTab"):buildPanel()
  end
end

-------------------------------------------------------------------------------
-- Get or create main panel
--
-- @function [parent=#MainPanel] getMainPanel
--
function MainPanel.methods:getMainPanel()
  Logging:debug(self:classname(), "getMainPanel()")
  local lua_player = Player.native()
  local location = Player.getSettings("display_location")
  local guiMain = lua_player.gui[location]
  if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
    return guiMain["helmod_planner_main"]
  end
  local panel = ElementGui.addGuiFlowH(guiMain, "helmod_planner_main", "helmod_flow_resize_row_width")
  --local panel = ElementGui.addGuiFrameH(guiMain, "helmod_planner_main", "helmod_frame_main")
  Player.setStyle(panel, "main", "minimal_width")
  Player.setStyle(panel, "main", "minimal_height")
  return panel
end

-------------------------------------------------------------------------------
-- Is opened main panel
--
-- @function [parent=#MainPanel] isOpened
--
function MainPanel.methods:isOpened()
  Logging:trace(self:classname(), "isOpened()")
  local lua_player = Player.native()
  local location = Player.getSettings("display_location")
  local guiMain = lua_player.gui[location]
  if guiMain["helmod_planner_main"] ~= nil then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Get or create pin tab panel
--
-- @function [parent=#MainPanel] getPinTabPanel
--
function MainPanel.methods:getPinTabPanel()
  Logging:trace(self:classname(), "getPinTabPanel(player)")
  local lua_player = Player.native()
  local guiMain = lua_player.gui[self.pinLocate]
  if guiMain["helmod_planner_pin_tab"] ~= nil and guiMain["helmod_planner_pin_tab"].valid then
    return guiMain["helmod_planner_pin_tab"]
  end
  return ElementGui.addGuiFlowH(guiMain, "helmod_planner_pin_tab", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#MainPanel] getInfoPanel
--
function MainPanel.methods:getInfoPanel()
  local mainPanel = self:getMainPanel()
  if mainPanel["helmod_planner_info"] ~= nil and mainPanel["helmod_planner_info"].valid then
    return mainPanel["helmod_planner_info"]
  end
  return ElementGui.addGuiFlowV(mainPanel, "helmod_planner_info", "helmod_flow_info")
end

-------------------------------------------------------------------------------
-- Get or create dialog panel
--
-- @function [parent=#MainPanel] getDialogPanel
--
function MainPanel.methods:getDialogPanel()
  local mainPanel = self:getMainPanel()
  if mainPanel["helmod_planner_dialog"] ~= nil and mainPanel["helmod_planner_dialog"].valid then
    return mainPanel["helmod_planner_dialog"]
  end
  return ElementGui.addGuiFlowH(mainPanel, "helmod_planner_dialog", "helmod_flow_dialog")
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainPanel] getMenuPanel
--
function MainPanel.methods:getMenuPanel()
  local menuPanel = self:getMainPanel()
  if menuPanel["helmod_planner_settings"] ~= nil and menuPanel["helmod_planner_settings"].valid then
    return menuPanel["helmod_planner_settings"]
  end
  return ElementGui.addGuiFlowV(menuPanel, "helmod_planner_settings", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#MainPanel] getDataPanel
--
function MainPanel.methods:getDataPanel()
  local infoPanel = self:getInfoPanel()
  if infoPanel["helmod_planner_data"] ~= nil and infoPanel["helmod_planner_data"].valid then
    return infoPanel["helmod_planner_data"]
  end
  local panel = ElementGui.addGuiFlowV(infoPanel, "helmod_planner_data", "helmod_flow_resize_row_width")
  Player.setStyle(panel, "data", "minimal_width")
  Player.setStyle(panel, "data", "maximal_width")
  return panel
end

-------------------------------------------------------------------------------
-- Refresh display data
--
-- @function [parent=#MainPanel] refreshDisplayData
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainPanel.methods:refreshDisplayData(item, item2, item3)
  Logging:debug(self:classname(), "refreshDisplayData():", item, item2, item3)
  Controller.getView("HMMainTab"):update(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Refresh display
--
-- @function [parent=#MainPanel] refreshDisplay
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainPanel.methods:refreshDisplay(item, item2, item3)
  Logging:debug(self:classname(), "refreshDisplay():", item, item2, item3)
  self:main()
  self:main()
end

-------------------------------------------------------------------------------
-- Send event
--
-- @function [parent=#MainPanel] sendEvent
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function MainPanel.methods:sendEvent(event, action, item, item2, item3)
    Logging:debug(self:classname(), "sendEvent():", action, item, item2, item3)
    if action == "OPEN" then
      self:main()
    end

    if action == "CLOSE" then
      self:main()
    end

end

