-------------------------------------------------------------------------------
-- Class to build settings panel
--
-- @module Settings
-- @extends #Dialog
--

Settings = setclass("HMSettings", Form)

local dropdown = {}

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Settings] init
--
-- @param #Controller parent parent controller
--
function Settings.methods:init(parent)
  self.panelCaption = ({"helmod_settings-panel.title"})
  self.parent = parent
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Settings] getParentPanel
--
-- @return #LuaGuiElement
--
function Settings.methods:getParentPanel()
  return Controller.getDialogPanel()
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Settings] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function Settings.methods:onOpen(event, action, item, item2, item3)
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- Get or create about settings panel
--
-- @function [parent=#Settings] getAboutSettingsPanel
--
function Settings.methods:getAboutSettingsPanel()
  local panel = self:getPanel()
  if panel["about-settings"] ~= nil and panel["about-settings"].valid then
    return panel["about-settings"]
  end
  return ElementGui.addGuiFrameV(panel, "about-settings", helmod_frame_style.panel, ({"helmod_settings-panel.about-section"}))
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#Settings] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Settings.methods:afterOpen(event, action, item, item2, item3)
  self:updateAboutSettings(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update about settings
--
-- @function [parent=#Settings] updateAboutSettings
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Settings.methods:updateAboutSettings(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateAboutSettings():", action, item, item2, item3)

  local aboutSettingsPanel = self:getAboutSettingsPanel()

  local dataSettingsTable = ElementGui.addGuiTable(aboutSettingsPanel, "settings", 2)

  ElementGui.addGuiLabel(dataSettingsTable, self:classname().."=version-label", {"helmod_settings-panel.mod-version"})
  ElementGui.addGuiLabel(dataSettingsTable, self:classname().."=version", game.active_mods["helmod"])

  ElementGui.addGuiLabel(aboutSettingsPanel, self:classname().."=info", {"helmod_settings-panel.mod-info"}, "helmod_label_help", nil, true)
end