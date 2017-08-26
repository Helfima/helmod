-------------------------------------------------------------------------------
-- Class to build settings panel
--
-- @module Settings
-- @extends #Dialog
--

Settings = setclass("HMSettings", Dialog)

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
  return self.parent:getDialogPanel()
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
  return ElementGui.addGuiFrameV(panel, "about-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.about-section"}))
end

-------------------------------------------------------------------------------
-- Get or create display settings panel
--
-- @function [parent=#Settings] getDisplaySettingsPanel
--
function Settings.methods:getDisplaySettingsPanel()
  local panel = self:getPanel()
  if panel["display-settings"] ~= nil and panel["display-settings"].valid then
    return panel["display-settings"]
  end
  return ElementGui.addGuiFrameV(panel, "display-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.display-section"}))
end

-------------------------------------------------------------------------------
-- Get or create data settings panel
--
-- @function [parent=#Settings] getDataSettingsPanel
--
function Settings.methods:getDataSettingsPanel()
  local panel = self:getPanel()
  if panel["data-settings"] ~= nil and panel["data-settings"].valid then
    return panel["data-settings"]
  end
  return ElementGui.addGuiFrameV(panel, "data-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.data-section"}))
end

-------------------------------------------------------------------------------
-- Get or create model settings panel
--
-- @function [parent=#Settings] getModelSettingsPanel
--
function Settings.methods:getModelSettingsPanel()
  local panel = self:getPanel()
  if panel["model-settings"] ~= nil and panel["model-settings"].valid then
    return panel["model-settings"]
  end
  return ElementGui.addGuiFrameV(panel, "model-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.model-section"}))
end

-------------------------------------------------------------------------------
-- Get or create other settings panel
--
-- @function [parent=#Settings] getOtherSettingsPanel
--
function Settings.methods:getOtherSettingsPanel()
  local panel = self:getPanel()
  if panel["other-settings"] ~= nil and panel["other-settings"].valid then
    return panel["other-settings"]
  end
  return ElementGui.addGuiFrameV(panel, "other-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.other-section"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Settings] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Settings.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  local globalSettings = Player.getGlobal("settings")
  local defaultSettings = Player.getDefaultSettings()

  if action == "change-boolean-settings" then
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    globalSettings[item] = not(globalSettings[item])
    self.parent:refreshDisplayData(item, item2, item3)
  end

  if action == "change-number-settings" then
    local panel = self:getPanel()[item]["settings"]
    local value = ElementGui.getInputNumber(panel[item2])
    if globalSettings[item2] ~= value then
      globalSettings[item2] = value
      self.parent:refreshDisplayData(item, item2, item3)
    end
  end

  if action == "change-display-settings" then
    local value = item2
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    if globalSettings[item] ~= value then
      globalSettings[item] = value
      self:updateDisplaySettings(element, action, item, item2, item3)
      self.parent:refreshDisplay(item, item2, item3)
    end
  end

  if action == "change-option-settings" then
    local value = item2
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    if globalSettings[item] ~= value then
      globalSettings[item] = value
      self:updateDisplaySettings(element, action, item, item2, item3)
      self.parent:refreshDisplayData(item, item2, item3)
    end
  end

  if action == "change-column-settings" then
    local value = tonumber(item2)
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    if globalSettings[item] ~= value then
      globalSettings[item] = value
      self:updateDisplaySettings(element, action, item, item2, item3)
      self.parent:refreshDisplayData(item, item2, item3)
    end
  end

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

  ElementGui.addGuiLabel(aboutSettingsPanel, self:classname().."=info", {"helmod_settings-panel.mod-info"}, "helmod_label_max_250", nil, false)
end