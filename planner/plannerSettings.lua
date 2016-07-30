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
-- Get the parent panel
--
-- @function [parent=#PlannerSettings] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerSettings.methods:getMenuPanel(player)
	return self.parent:getSettingsPanel(player)
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
-- @param #string item second item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerSettings.methods:on_open(player, element, action, item, item2)
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
	local parentPanel = self:getMenuPanel(player)
	if parentPanel["time"] ~= nil and parentPanel["time"].valid then
		return parentPanel["time"]
	end
	return self:addGuiFlowH(parentPanel, "time")
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
	return self:addGuiFrameV(panel, "about-settings", "helmod_module-table-frame", ({"helmod_settings-panel.about-section"}))
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
	return self:addGuiFrameV(panel, "data-settings", "helmod_module-table-frame", ({"helmod_settings-panel.data-section"}))
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
	return self:addGuiFrameV(panel, "model-settings", "helmod_module-table-frame", ({"helmod_settings-panel.model-section"}))
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
-- @param #string item second item name
--
function PlannerSettings.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerSettings:on_event():",player, element, action, item, item2)
	local model = self.model:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")

	if action == "change-time" then
		model.time = tonumber(item)
		self.model:update(player)
		self:update(player)
		self.parent:refreshDisplayData(player)
	end

	if action == "change-boolean-settings" then
		globalSettings[item] = not(globalSettings[item])
		self.parent:refreshDisplayData(player)
	end

	if action == "change-number-settings" then
		local panel = self:getPanel(player)[item]["settings"]
		globalSettings[item2] = self:getInputNumber(panel[item2])
		self.parent:refreshDisplayData(player)
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
-- @param #string item second item name
--
function PlannerSettings.methods:after_open(player, element, action, item, item2)
	self:updateAboutSettings(player, element, action, item, item2)
	self:updateDataSettings(player, element, action, item, item2)
	self:updateModelSettings(player, element, action, item, item2)
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

	self:addGuiLabel(timePanel, self:classname().."=base-time", ({"helmod_settings-panel.base-time"}), "helmod_page-label")

	local times = {
		{ value = 60, name = "1m"},
		{ value = 300, name = "5m"},
		{ value = 600, name = "10m"},
		{ value = 1800, name = "30m"},
		{ value = 3600, name = "1h"}
	}
	for _,time in pairs(times) do
		if model.time == time.value then
			self:addGuiLabel(timePanel, self:classname().."=change-time="..time.value, time.name, "helmod_page-label")
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
-- @param #string item second item name
--
function PlannerSettings.methods:updateAboutSettings(player, element, action, item, item2)
	Logging:debug("PlannerSettings:updateAboutSettings():",player, element, action, item, item2)

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
-- @param #string item second item name
--
function PlannerSettings.methods:updateDataSettings(player, element, action, item, item2)
	Logging:debug("PlannerSettings:updateDataSettings():",player, element, action, item, item2)

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

	local display_data_col_level = defaultSettings.display_data_col_level
	if globalSettings.display_data_col_level ~= nil then display_data_col_level = globalSettings.display_data_col_level end
	self:addGuiLabel(dataSettingsTable, self:classname().."=display_data_col_level", ({"helmod_settings-panel.data-col-level"}))
	self:addGuiCheckbox(dataSettingsTable, self:classname().."=change-boolean-settings=ID=display_data_col_level", display_data_col_level)

	local display_data_col_weight = defaultSettings.display_data_col_weight
	if globalSettings.display_data_col_weight ~= nil then display_data_col_weight = globalSettings.display_data_col_weight end
	self:addGuiLabel(dataSettingsTable, self:classname().."=display_data_col_weight", ({"helmod_settings-panel.data-col-weight"}))
	self:addGuiCheckbox(dataSettingsTable, self:classname().."=change-boolean-settings=ID=display_data_col_weight", display_data_col_weight)

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
-- @param #string item second item name
--
function PlannerSettings.methods:updateModelSettings(player, element, action, item, item2)
	Logging:debug("PlannerSettings:updateModelSettings():",player, element, action, item, item2)

	local globalSettings = self.player:getGlobal(player, "settings")
	local defaultSettings = self.player:getDefaultSettings()

	local modelSettingsPanel = self:getModelSettingsPanel(player)

	local modelSettingsTable = self:addGuiTable(modelSettingsPanel, "settings", 3)

	self:addGuiLabel(modelSettingsTable, self:classname().."=model_auto_compute", ({"helmod_settings-panel.model-auto-compute"}))

	local model_auto_compute = defaultSettings.model_auto_compute
	if globalSettings.model_auto_compute ~= nil then model_auto_compute = globalSettings.model_auto_compute end
	self:addGuiCheckbox(modelSettingsTable, self:classname().."=change-boolean-settings=ID=model_auto_compute", model_auto_compute)
	self:addGuiLabel(modelSettingsTable, self:classname().."=change-number-settings=ID=model-settings", "")

	self:addGuiLabel(modelSettingsTable, self:classname().."=model_loop_limit_label", ({"helmod_settings-panel.model-loop-limit"}))
	
	local model_loop_limit = defaultSettings.model_loop_limit
	if globalSettings.model_loop_limit ~= nil then model_loop_limit = globalSettings.model_loop_limit end
	self:addGuiText(modelSettingsTable, "model_loop_limit", model_loop_limit)
	self:addGuiButton(modelSettingsTable, self:classname().."=change-number-settings=ID=model-settings=", "model_loop_limit", "helmod_button-default", ({"helmod_button.apply"}))


end
