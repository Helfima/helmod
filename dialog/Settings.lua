-------------------------------------------------------------------------------
-- Class to build settings panel
--
-- @module Settings
-- @extends #Form
--

Settings = newclass(Form)

local dropdown = {}

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Settings] onInit
--
function Settings:onInit()
  self.panelCaption = ({"helmod_settings-panel.title"})
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#Settings] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function Settings:onBeforeEvent(event)
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- Get or create about settings panel
--
-- @function [parent=#Settings] getAboutSettingsPanel
--
function Settings:getAboutSettingsPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["about-settings"] ~= nil and content_panel["about-settings"].valid then
    return content_panel["about-settings"]
  end
  return ElementGui.addGuiFrameV(content_panel, "about-settings", helmod_frame_style.panel, ({"helmod_settings-panel.about-section"}))
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Settings] onUpdate
--
-- @param #LuaEvent event
--
function Settings:onUpdate(event)
  self:updateAboutSettings(event)
end

-------------------------------------------------------------------------------
-- Update about settings
--
-- @function [parent=#Settings] updateAboutSettings
--
-- @param #LuaEvent event
--
function Settings:updateAboutSettings(event)
  Logging:debug(self.classname, "updateAboutSettings()", event)

  local aboutSettingsPanel = self:getAboutSettingsPanel()

  local dataSettingsTable = ElementGui.addGuiTable(aboutSettingsPanel, "settings", 2)

  ElementGui.addGuiLabel(dataSettingsTable, self.classname.."=version-label", {"helmod_settings-panel.mod-version"})
  ElementGui.addGuiLabel(dataSettingsTable, self.classname.."=version", game.active_mods["helmod"])

  ElementGui.addGuiLabel(aboutSettingsPanel, self.classname.."=info", {"helmod_settings-panel.mod-info"}, "helmod_label_help", nil, true)
end