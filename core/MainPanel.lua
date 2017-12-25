
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
    if lua_player.gui[location]["helmod_main_panel"] ~= nil then
      lua_player.gui[location]["helmod_main_panel"].destroy()
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
    local guiButton = ElementGui.addGuiFrameH(parentGui, PLANNER_COMMAND, helmod_frame_style.default)
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
  local gui_main = lua_player.gui[location]
  if gui_main["helmod_main_panel"] ~= nil and gui_main["helmod_main_panel"].valid then
    gui_main["helmod_main_panel"].destroy()
  else
    -- menu
    local menuPanel = self:getMenuPanel()
    local actionPanel = ElementGui.addGuiFrameV(menuPanel, "settings", helmod_frame_style.default)
    ElementGui.addGuiButton(actionPanel, self:classname().."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
    ElementGui.addGuiButton(actionPanel, "HMSettings=OPEN", nil, "helmod_button_icon_menu", nil, ({"helmod_button.options"}))
    ElementGui.addGuiButton(actionPanel, "HMHelpPanel=OPEN", nil, "helmod_button_icon_help", nil, ({"helmod_button.help"}))
    
    -- data
    local dataPanel = self:getDataPanel()
    -- dialogue
    local dialogPanel = self:getDialogPanel()

    -- tab
    Controller.getView("HMMainTab"):buildPanel()
  end
end

-------------------------------------------------------------------------------
-- Name of display
--
--  Table.main
-- |--------------|--------------|--------------|
-- ||------------|||------------|||------------||
-- || Frame.menu ||| Frame.data ||| Frame.info ||
-- ||------------|||------------|||------------||
-- |--------------|--------------|--------------|
--

-------------------------------------------------------------------------------
-- Get or create main panel
--
-- @function [parent=#MainPanel] getMainPanel
--
function MainPanel.methods:getMainPanel()
  Logging:debug(self:classname(), "getMainPanel()")
  local lua_player = Player.native()
  local location = Player.getSettings("display_location")
  local gui_main = lua_player.gui[location]
  if gui_main["helmod_main_panel"] ~= nil and gui_main["helmod_main_panel"].valid then
    return gui_main["helmod_main_panel"]
  end
  local panel = ElementGui.addGuiFrameH(gui_main, "helmod_main_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(panel, "main", "width")
  ElementGui.setStyle(panel, "main", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create dialog panel
--
-- @function [parent=#MainPanel] getDialogPanel
--
function MainPanel.methods:getDialogPanel()
  local main_panel = self:getMainPanel()
  if main_panel["helmod_dialog_panel"] ~= nil and main_panel["helmod_dialog_panel"].valid then
    return main_panel["helmod_dialog_panel"]
  end
  local panel = ElementGui.addGuiFrameV(main_panel, "helmod_dialog_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(panel, "dialog", "width")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainPanel] getMenuPanel
--
function MainPanel.methods:getMenuPanel()
  local main_panel = self:getMainPanel()
  if main_panel["helmod_menu_panel"] ~= nil and main_panel["helmod_menu_panel"].valid then
    return main_panel["helmod_menu_panel"]
  end
  return ElementGui.addGuiTable(main_panel, "helmod_menu_panel", 1, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#MainPanel] getDataPanel
--
function MainPanel.methods:getDataPanel()
  local main_panel = self:getMainPanel()
  if main_panel["helmod_data_panel"] ~= nil and main_panel["helmod_data_panel"].valid and main_panel["helmod_data_panel"]["helmod_data_table"] then
    return main_panel["helmod_data_panel"]["helmod_data_table"]
  end
  local panel = ElementGui.addGuiFrameV(main_panel, "helmod_data_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(panel, "data", "width")
  panel.style.vertically_stretchable = true
  local table_panel = ElementGui.addGuiTable(panel, "helmod_data_table", 1, helmod_table_style.panel)
  --table_panel.draw_horizontal_lines = true
  return table_panel
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
  if guiMain["helmod_main_panel"] ~= nil then
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
  return ElementGui.addGuiFrameV(guiMain, "helmod_planner_pin_tab", helmod_frame_style.hidden)
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

