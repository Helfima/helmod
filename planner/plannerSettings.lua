-------------------------------------------------------------------------------
-- Classe to build settings panel
--
-- @module PlannerSettings
-- @extends #ElementGui
--

PlannerSettings = setclass("HMPlannerSettings", PlannerDialog)

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
	self.player = self.parent.parent
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
-- Get the menu panel
--
-- @function [parent=#PlannerSettings] getMenuPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerSettings.methods:getMenuPanel(player)
	return self.parent:getMenuPanel(player)
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
-- Get or create time panel
--
-- @function [parent=#PlannerSettings] getTimePanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getTimePanel(player)
	local menuPanel = self:getMenuPanel(player)
	if menuPanel["time"] ~= nil and menuPanel["time"].valid then
		return menuPanel["time"]
	end
	return self:addGuiFlowH(menuPanel, "time")
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
-- Build the parent panel
--
-- @function [parent=#PlannerSettings] buildPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:buildPanel(player)
	Logging:debug("PlannerSettings:buildPanel():",player)

	local model = self.model:getModel(player)

	local parentPanel = self:getMenuPanel(player)

	if parentPanel ~= nil then
		self:addGuiButton(parentPanel, self:classname().."=OPEN", nil, "helmod_button-default", ({"helmod_button.options"}))

		self:getTimePanel(player)

		self:update(player)
	end
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
	Logging:debug("PlannerSettings:on_event():",player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")
	local defaultSettings = self.player:getDefaultSettings()

	if action == "change-time" then
		model.time = tonumber(item)
		self.model:update(player)
		self:update(player)
		self.parent:refreshDisplayData(player, item, item2, item3)
	end

	if action == "change-boolean-settings" then
		if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
		globalSettings[item] = not(globalSettings[item])
		self.parent:refreshDisplayData(player, item, item2, item3)
	end

	if action == "change-number-settings" then
		local panel = self:getPanel(player)[item]["settings"]
		globalSettings[item2] = self:getInputNumber(panel[item2])
		self.parent:refreshDisplayData(player, item, item2, item3)
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

	self:updateAboutSettings(player, element, action, item, item2, item3)
	self:updateDataSettings(player, element, action, item, item2, item3)
	self:updateModelSettings(player, element, action, item, item2, item3)
	self:updateOtherSettings(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerSettings] update
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:update(player)
	Logging:debug("PlannerResult:update():", player)
	local model = self.model:getModel(player)
	local timePanel = self:getTimePanel(player)

	for k,guiName in pairs(timePanel.children_names) do
		timePanel[guiName].destroy()
	end

	self:addGuiLabel(timePanel, self:classname().."=base-time", ({"helmod_settings-panel.base-time"}), "helmod_label_time")

	local times = {
		{ value = 1, name = "1s"},
		{ value = 60, name = "1m"},
		{ value = 300, name = "5m"},
		{ value = 600, name = "10m"},
		{ value = 1800, name = "30m"},
		{ value = 3600, name = "1h"}
	}
	for _,time in pairs(times) do
		if model.time == time.value then
			self:addGuiLabel(timePanel, self:classname().."=change-time="..time.value, time.name, "helmod_label_time")
		else
			self:addGuiButton(timePanel, self:classname().."=change-time=ID=", time.value, "helmod_button-default", time.name)
		end
	end
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
	Logging:debug("PlannerSettings:updateAboutSettings():",player, element, action, item, item2, item3)

	local globalSettings = self.player:getGlobal(player, "settings")
	local defaultSettings = self.player:getDefaultSettings()

	local dataSettingsPanel = self:getAboutSettingsPanel(player)

	local dataSettingsTable = self:addGuiTable(dataSettingsPanel, "settings", 2)

	self:addGuiLabel(dataSettingsTable, self:classname().."=version-label", ({"helmod_settings-panel.mod-version"}))
	self:addGuiLabel(dataSettingsTable, self:classname().."=version", helmod.version)

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
	Logging:debug("PlannerSettings:updateDataSettings():",player, element, action, item, item2, item3)

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
	Logging:debug("PlannerSettings:updateModelSettings():",player, element, action, item, item2, item3)

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
	Logging:debug("PlannerSettings:updateOtherSettings():",player, element, action, item, item2, item3)

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

