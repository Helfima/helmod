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
  self.player = self.parent.player
  self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Settings] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function Settings.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Settings] on_open
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function Settings.methods:on_open(player, event, action, item, item2, item3)
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- Get or create about settings panel
--
-- @function [parent=#Settings] getAboutSettingsPanel
--
-- @param #LuaPlayer player
--
function Settings.methods:getAboutSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["about-settings"] ~= nil and panel["about-settings"].valid then
    return panel["about-settings"]
  end
  return self:addGuiFrameV(panel, "about-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.about-section"}))
end

-------------------------------------------------------------------------------
-- Get or create display settings panel
--
-- @function [parent=#Settings] getDisplaySettingsPanel
--
-- @param #LuaPlayer player
--
function Settings.methods:getDisplaySettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["display-settings"] ~= nil and panel["display-settings"].valid then
    return panel["display-settings"]
  end
  return self:addGuiFrameV(panel, "display-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.display-section"}))
end

-------------------------------------------------------------------------------
-- Get or create data settings panel
--
-- @function [parent=#Settings] getDataSettingsPanel
--
-- @param #LuaPlayer player
--
function Settings.methods:getDataSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["data-settings"] ~= nil and panel["data-settings"].valid then
    return panel["data-settings"]
  end
  return self:addGuiFrameV(panel, "data-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.data-section"}))
end

-------------------------------------------------------------------------------
-- Get or create model settings panel
--
-- @function [parent=#Settings] getModelSettingsPanel
--
-- @param #LuaPlayer player
--
function Settings.methods:getModelSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["model-settings"] ~= nil and panel["model-settings"].valid then
    return panel["model-settings"]
  end
  return self:addGuiFrameV(panel, "model-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.model-section"}))
end

-------------------------------------------------------------------------------
-- Get or create other settings panel
--
-- @function [parent=#Settings] getOtherSettingsPanel
--
-- @param #LuaPlayer player
--
function Settings.methods:getOtherSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["other-settings"] ~= nil and panel["other-settings"].valid then
    return panel["other-settings"]
  end
  return self:addGuiFrameV(panel, "other-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.other-section"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Settings] on_event
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Settings.methods:on_event(player, event, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event():", action, item, item2, item3)
  local model = self.model:getModel(player)
  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  if action == "change-boolean-settings" then
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    globalSettings[item] = not(globalSettings[item])
    self.parent:refreshDisplayData(player, item, item2, item3)
  end

  if action == "change-number-settings" then
    local panel = self:getPanel(player)[item]["settings"]
    local value = self:getInputNumber(panel[item2])
    if globalSettings[item2] ~= value then
      globalSettings[item2] = value
      self.parent:refreshDisplayData(player, item, item2, item3)
    end
  end

  if action == "change-display-settings" then
    local value = item2
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    if globalSettings[item] ~= value then
      globalSettings[item] = value
      self:updateDisplaySettings(player, element, action, item, item2, item3)
      self.parent:refreshDisplay(player, item, item2, item3)
    end
  end

  if action == "change-option-settings" then
    local value = item2
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    if globalSettings[item] ~= value then
      globalSettings[item] = value
      self:updateDisplaySettings(player, element, action, item, item2, item3)
      self.parent:refreshDisplayData(player, item, item2, item3)
    end
  end

  if action == "change-column-settings" then
    local value = tonumber(item2)
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    if globalSettings[item] ~= value then
      globalSettings[item] = value
      self:updateDisplaySettings(player, element, action, item, item2, item3)
      self.parent:refreshDisplayData(player, item, item2, item3)
    end
  end

end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#Settings] after_open
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Settings.methods:after_open(player, event, action, item, item2, item3)
  self.parent:send_event(player, "HMRecipeEdition", "CLOSE")
  self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
  self.parent:send_event(player, "HMProductEdition", "CLOSE")
  self.parent:send_event(player, "HMEnergyEdition", "CLOSE")

  self:updateAboutSettings(player, event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update about settings
--
-- @function [parent=#Settings] updateAboutSettings
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Settings.methods:updateAboutSettings(player, event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateAboutSettings():", action, item, item2, item3)

  local aboutSettingsPanel = self:getAboutSettingsPanel(player)

  local dataSettingsTable = self:addGuiTable(aboutSettingsPanel, "settings", 2)

  self:addGuiLabel(dataSettingsTable, self:classname().."=version-label", {"helmod_settings-panel.mod-version"})
  self:addGuiLabel(dataSettingsTable, self:classname().."=version", game.active_mods["helmod"])

  self:addGuiLabel(aboutSettingsPanel, self:classname().."=info", {"helmod_settings-panel.mod-info"}, "helmod_label_max_250", nil, false)
end