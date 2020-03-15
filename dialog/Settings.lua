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
-- Get or create about settings panel
--
-- @function [parent=#Settings] getAboutSettingsPanel
--
function Settings:getAboutSettingsPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["about-settings"] ~= nil and content_panel["about-settings"].valid then
    return content_panel["about-settings"]
  end
  return GuiElement.add(content_panel, GuiFrameV("about-settings"):style(helmod_frame_style.panel):caption({"helmod_settings-panel.about-section"}))
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
  local aboutSettingsPanel = self:getAboutSettingsPanel()

  local dataSettingsTable = GuiElement.add(aboutSettingsPanel, GuiTable("settings"):column(2))

  GuiElement.add(dataSettingsTable, GuiLabel(self.classname, "version-label"):caption({"helmod_settings-panel.mod-version"}))
  GuiElement.add(dataSettingsTable, GuiLabel(self.classname, "version"):caption(game.active_mods["helmod"]))

  GuiElement.add(aboutSettingsPanel, GuiLabel(self.classname, "info"):caption({"helmod_settings-panel.mod-info"}):style("helmod_label_help"))
end