-------------------------------------------------------------------------------
-- Classe to build settings panel
--
-- @module PlannerSettings
-- @extends #ElementGui
--

PlannerSettings = setclass("HMPlannerSettings", PlannerDialog)

local dropdown = {}

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlannerSettings] init
--
-- @param #PlannerController parent parent controller
--
function PlannerSettings.methods:init(parent)
  self.panelCaption = ({"helmod_settings-panel.title"})

  self.parent = parent
  self.player = self.parent.player
  self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerSettings] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerSettings.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerSettings] on_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerSettings.methods:on_open(player, element, action, item, item2, item3)
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- Get or create about settings panel
--
-- @function [parent=#PlannerSettings] getAboutSettingsPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getAboutSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["about-settings"] ~= nil and panel["about-settings"].valid then
    return panel["about-settings"]
  end
  return self:addGuiFrameV(panel, "about-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.about-section"}))
end

-------------------------------------------------------------------------------
-- Get or create display settings panel
--
-- @function [parent=#PlannerSettings] getDisplaySettingsPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getDisplaySettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["display-settings"] ~= nil and panel["display-settings"].valid then
    return panel["display-settings"]
  end
  return self:addGuiFrameV(panel, "display-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.display-section"}))
end

-------------------------------------------------------------------------------
-- Get or create data settings panel
--
-- @function [parent=#PlannerSettings] getDataSettingsPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getDataSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["data-settings"] ~= nil and panel["data-settings"].valid then
    return panel["data-settings"]
  end
  return self:addGuiFrameV(panel, "data-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.data-section"}))
end

-------------------------------------------------------------------------------
-- Get or create model settings panel
--
-- @function [parent=#PlannerSettings] getModelSettingsPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getModelSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["model-settings"] ~= nil and panel["model-settings"].valid then
    return panel["model-settings"]
  end
  return self:addGuiFrameV(panel, "model-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.model-section"}))
end

-------------------------------------------------------------------------------
-- Get or create other settings panel
--
-- @function [parent=#PlannerSettings] getOtherSettingsPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getOtherSettingsPanel(player)
  local panel = self:getPanel(player)
  if panel["other-settings"] ~= nil and panel["other-settings"].valid then
    return panel["other-settings"]
  end
  return self:addGuiFrameV(panel, "other-settings", "helmod_frame_resize_row_width", ({"helmod_settings-panel.other-section"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerSettings] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerSettings", "on_event():",player, element, action, item, item2, item3)
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
-- @function [parent=#PlannerSettings] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:after_open(player, element, action, item, item2, item3)
  self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
  self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
  self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
  self.parent:send_event(player, "HMPlannerEnergyEdition", "CLOSE")

  self:updateAboutSettings(player, element, action, item, item2, item3)
  self:updateDisplaySettings(player, element, action, item, item2, item3)
  self:updateDataSettings(player, element, action, item, item2, item3)
  self:updateModelSettings(player, element, action, item, item2, item3)
  self:updateOtherSettings(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update about settings
--
-- @function [parent=#PlannerSettings] updateAboutSettings
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:updateAboutSettings(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerSettings", "updateAboutSettings():",player, element, action, item, item2, item3)

  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  local dataSettingsPanel = self:getAboutSettingsPanel(player)

  local dataSettingsTable = self:addGuiTable(dataSettingsPanel, "settings", 2)

  self:addGuiLabel(dataSettingsTable, self:classname().."=version-label", ({"helmod_settings-panel.mod-version"}))
  self:addGuiLabel(dataSettingsTable, self:classname().."=version", helmod.version)

end

-------------------------------------------------------------------------------
-- Update display settings
--
-- @function [parent=#PlannerSettings] updateDisplaySettings
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:updateDisplaySettings(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerSettings", "updateDisplaySettings():",player, element, action, item, item2, item3)

  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  local displaySettingsPanel = self:getDisplaySettingsPanel(player)

  for k,guiName in pairs(displaySettingsPanel.children_names) do
    displaySettingsPanel[guiName].destroy()
  end


  local sizeSettingsTable = self:addGuiTable(displaySettingsPanel, "size", 3)

  local display_size = defaultSettings.display_size
  if globalSettings.display_size ~= nil then display_size = globalSettings.display_size end
  self:addGuiLabel(sizeSettingsTable, self:classname().."=display_size", ({"helmod_settings-panel.display-size"}))

  local display_size = defaultSettings.display_size
  if globalSettings.display_size ~= nil then display_size = globalSettings.display_size end
  local cell = self:addGuiTable(sizeSettingsTable,"display_sizes_list", 3)
  for _,current_size in ipairs(helmod_display_sizes) do
    local style = "helmod_button_default"
    if display_size == current_size then style = "helmod_button_selected" end
    self:addGuiButton(cell, self:classname().."=change-display-settings=ID=display_size=", current_size, style, current_size)
  end

  local column_max = 7
  local columnSettingsTable = self:addGuiTable(displaySettingsPanel, "column", column_max)
  self:addGuiLabel(columnSettingsTable, self:classname().."=display_product_cols", ({"helmod_settings-panel.display-product-cols"}))
  local display_product_cols = defaultSettings.display_product_cols
  if globalSettings.display_product_cols ~= nil then display_product_cols = globalSettings.display_product_cols end
  for i = 2, column_max, 1 do
    local style = "helmod_button_default"
    if display_product_cols == i then style = "helmod_button_selected" end
    self:addGuiButton(columnSettingsTable, self:classname().."=change-column-settings=ID=display_product_cols=", i, style, i)
  end

  self:addGuiLabel(columnSettingsTable, self:classname().."=display_ingredient_cols", ({"helmod_settings-panel.display-ingredient-cols"}))
  local display_ingredient_cols = defaultSettings.display_ingredient_cols
  if globalSettings.display_ingredient_cols ~= nil then display_ingredient_cols = globalSettings.display_ingredient_cols end
  for i = 2, column_max, 1 do
    local style = "helmod_button_default"
    if display_ingredient_cols == i then style = "helmod_button_selected" end
    self:addGuiButton(columnSettingsTable, self:classname().."=change-column-settings=ID=display_ingredient_cols=", i, style, i)
  end

  local cellmodSettingsTable = self:addGuiTable(displaySettingsPanel, "display_cell_mod", 3)
  self:addGuiLabel(cellmodSettingsTable, self:classname().."=display_cell_mod", ({"helmod_settings-panel.display-cell-mod"}))
  local display_cell_mod = defaultSettings.display_cell_mod
  if globalSettings.display_cell_mod ~= nil then display_cell_mod = globalSettings.display_cell_mod end
  local cell = self:addGuiTable(cellmodSettingsTable,"display_mod_list", 2)
  for _,current_cell_mod in ipairs(helmod_display_cell_mod) do
    local style = "helmod_button_default"
    if display_cell_mod == current_cell_mod then style = "helmod_button_selected" end
    self:addGuiButton(cell, self:classname().."=change-option-settings=ID=display_cell_mod=", current_cell_mod, style, current_cell_mod)
  end

end

-------------------------------------------------------------------------------
-- Update data settings
--
-- @function [parent=#PlannerSettings] updateDataSettings
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:updateDataSettings(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerSettings", "updateDataSettings():",player, element, action, item, item2, item3)

  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  local dataSettingsPanel = self:getDataSettingsPanel(player)

  local dataSettingsTable = self:addGuiTable(dataSettingsPanel, "settings", 2)

  local display_data_col_name = defaultSettings.display_data_col_name
  if globalSettings.display_data_col_name ~= nil then display_data_col_name = globalSettings.display_data_col_name end
  self:addGuiLabel(dataSettingsTable, self:classname().."=display_data_col_name", ({"helmod_settings-panel.data-col-name"}))
  self:addGuiCheckbox(dataSettingsTable, self:classname().."=change-boolean-settings=ID=display_data_col_name", display_data_col_name)

  local display_data_col_id = defaultSettings.display_data_col_id
  if globalSettings.display_data_col_id ~= nil then display_data_col_id = globalSettings.display_data_col_id end
  self:addGuiLabel(dataSettingsTable, self:classname().."=display_data_col_id", ({"helmod_settings-panel.data-col-id"}))
  self:addGuiCheckbox(dataSettingsTable, self:classname().."=change-boolean-settings=ID=display_data_col_id", display_data_col_id)

  local display_data_col_index = defaultSettings.display_data_col_index
  if globalSettings.display_data_col_index ~= nil then display_data_col_index = globalSettings.display_data_col_index end
  self:addGuiLabel(dataSettingsTable, self:classname().."=display_data_col_index", ({"helmod_settings-panel.data-col-index"}))
  self:addGuiCheckbox(dataSettingsTable, self:classname().."=change-boolean-settings=ID=display_data_col_index", display_data_col_index)

end

-------------------------------------------------------------------------------
-- Update model settings
--
-- @function [parent=#PlannerSettings] updateModelSettings
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:updateModelSettings(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerSettings", "updateModelSettings():",player, element, action, item, item2, item3)

  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  local modelSettingsPanel = self:getModelSettingsPanel(player)

  local modelSettingsTable = self:addGuiTable(modelSettingsPanel, "settings", 3)

  -- model_filter_factory
  self:addGuiLabel(modelSettingsTable, self:classname().."=model_filter_factory", ({"helmod_settings-panel.model-filter-factory"}))

  local model_filter_factory = defaultSettings.model_filter_factory
  if globalSettings.model_filter_factory ~= nil then model_filter_factory = globalSettings.model_filter_factory end
  self:addGuiCheckbox(modelSettingsTable, self:classname().."=change-boolean-settings=ID=model_filter_factory", model_filter_factory)
  self:addGuiLabel(modelSettingsTable, self:classname().."=blank=ID=model_filter_factory", "")

  -- model_filter_factory
  self:addGuiLabel(modelSettingsTable, self:classname().."=model_filter_beacon", ({"helmod_settings-panel.model-filter-beacon"}))

  local model_filter_beacon = defaultSettings.model_filter_beacon
  if globalSettings.model_filter_beacon ~= nil then model_filter_beacon = globalSettings.model_filter_beacon end
  self:addGuiCheckbox(modelSettingsTable, self:classname().."=change-boolean-settings=ID=model_filter_beacon", model_filter_beacon)
  self:addGuiLabel(modelSettingsTable, self:classname().."=blank=ID=model_filter_beacon", "")

  -- model_filter_generator
  self:addGuiLabel(modelSettingsTable, self:classname().."=model_filter_generator", ({"helmod_settings-panel.model-filter-generator"}))

  local model_filter_generator = self.player:getGlobalSettings(player, "model_filter_generator")
  self:addGuiCheckbox(modelSettingsTable, self:classname().."=change-boolean-settings=ID=model_filter_generator", model_filter_generator)
  self:addGuiLabel(modelSettingsTable, self:classname().."=blank=ID=model_filter_generator", "")

  -- model_filter_factory_module
  self:addGuiLabel(modelSettingsTable, self:classname().."=model_filter_factory_module", ({"helmod_settings-panel.model-filter-factory-module"}))

  local model_filter_factory_module = self.player:getGlobalSettings(player, "model_filter_factory_module")
  self:addGuiCheckbox(modelSettingsTable, self:classname().."=change-boolean-settings=ID=model_filter_factory_module", model_filter_factory_module)
  self:addGuiLabel(modelSettingsTable, self:classname().."=blank=ID=model_filter_factory_module", "")

  -- model_filter_beacon_module
  self:addGuiLabel(modelSettingsTable, self:classname().."=model_filter_beacon_module", ({"helmod_settings-panel.model-filter-beacon-module"}))

  local model_filter_beacon_module = self.player:getGlobalSettings(player, "model_filter_beacon_module")
  self:addGuiCheckbox(modelSettingsTable, self:classname().."=change-boolean-settings=ID=model_filter_beacon_module", model_filter_beacon_module)
  self:addGuiLabel(modelSettingsTable, self:classname().."=blank=ID=model_filter_beacon_module", "")

end

-------------------------------------------------------------------------------
-- Update other settings
--
-- @function [parent=#PlannerSettings] updateOtherSettings
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerSettings.methods:updateOtherSettings(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerSettings", "updateOtherSettings():",player, element, action, item, item2, item3)

  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  local otherSettingsPanel = self:getOtherSettingsPanel(player)

  local otherSettingsTable = self:addGuiTable(otherSettingsPanel, "settings", 3)

  -- other_speed_panel
  self:addGuiLabel(otherSettingsTable, self:classname().."=other_speed_panel", ({"helmod_settings-panel.other-speed-panel"}))

  local other_speed_panel = defaultSettings.other_speed_panel
  if globalSettings.other_speed_panel ~= nil then other_speed_panel = globalSettings.other_speed_panel end
  self:addGuiCheckbox(otherSettingsTable, self:classname().."=change-boolean-settings=ID=other_speed_panel", other_speed_panel)
  self:addGuiLabel(otherSettingsTable, self:classname().."=blank=ID=other_speed_panel", "")

  -- real_name
  self:addGuiLabel(otherSettingsTable, self:classname().."=real_name", ({"helmod_settings-panel.real-name"}))

  local real_name = defaultSettings.real_name
  if globalSettings.real_name ~= nil then real_name = globalSettings.real_name end
  self:addGuiCheckbox(otherSettingsTable, self:classname().."=change-boolean-settings=ID=real_name", real_name)
  self:addGuiLabel(otherSettingsTable, self:classname().."=blank=ID=real_name", "")

end








