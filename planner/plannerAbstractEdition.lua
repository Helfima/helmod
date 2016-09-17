-------------------------------------------------------------------------------
-- Classe to build abstract edition dialog
--
-- @module PlannerAbstractEdition
-- @extends #PlannerDialog
--

PlannerAbstractEdition = setclass("HMPlannerAbstractEdition", PlannerDialog)

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerAbstractEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerAbstractEdition.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerAbstractEdition] on_open
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
function PlannerAbstractEdition.methods:on_open(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	local close = true
	model.moduleListRefresh = false
	if model.guiElementLast == nil or model.guiElementLast ~= item..item2 then
		close = false
		model.factoryGroupSelected = nil
		model.beaconGroupSelected = nil
		model.moduleListRefresh = true
	end
	model.guiElementLast = item..item2
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerAbstractEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:on_close(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	model.guiElementLast = nil
	model.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create factory panel
--
-- @function [parent=#PlannerAbstractEdition] getFactoryPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getFactoryPanel(player)
	local panel = self:getPanel(player)
	if panel["factory"] ~= nil and panel["factory"].valid then
		return panel["factory"]
	end
	return self:addGuiFlowH(panel, "factory", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#PlannerAbstractEdition] getFactoryOtherInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getFactoryOtherInfoPanel(player)
	local panel = self:getFactoryPanel(player)
	if panel["other-info"] ~= nil and panel["other-info"].valid then
		return panel["other-info"]
	end
	return self:addGuiFlowV(panel, "other-info", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create factory selector panel
--
-- @function [parent=#PlannerAbstractEdition] getFactorySelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getFactorySelectorPanel(player)
	local panel = self:getFactoryOtherInfoPanel(player)
	if panel["selector"] ~= nil and panel["selector"].valid then
		return panel["selector"]
	end
	return self:addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.factory"}))
end

-------------------------------------------------------------------------------
-- Get or create factory info panel
--
-- @function [parent=#PlannerAbstractEdition] getFactoryInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getFactoryInfoPanel(player)
	local panel = self:getFactoryPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.factory"}))
end

-------------------------------------------------------------------------------
-- Get or create factory modules selector panel
--
-- @function [parent=#PlannerAbstractEdition] getFactoryModulesSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getFactoryModulesSelectorPanel(player)
	local modulesPanel = self:getFactoryOtherInfoPanel(player)
	local selectionModulesPanel = modulesPanel["selection-modules"]
	if selectionModulesPanel == nil then
		selectionModulesPanel = self:addGuiFrameV(modulesPanel, "selection-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.selection-modules"}))
	end

	local scrollModulesPanel = selectionModulesPanel["scroll-modules"]
	if scrollModulesPanel == nil then
		scrollModulesPanel = self:addGuiScrollPane(selectionModulesPanel, "scroll-modules", "helmod_scroll_recipe_module_list", "auto", "auto")
	end
	return scrollModulesPanel
end

-------------------------------------------------------------------------------
-- Get or create factory actived modules panel
--
-- @function [parent=#PlannerAbstractEdition] getFactoryActivedModulesPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getFactoryActivedModulesPanel(player)
	local modulesPanel = self:getFactoryOtherInfoPanel(player)
	if modulesPanel["current-modules"] ~= nil and modulesPanel["current-modules"].valid then
		return modulesPanel["current-modules"]
	end
	return self:addGuiFrameV(modulesPanel, "current-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.current-modules"}))
end

-------------------------------------------------------------------------------
-- Get or create beacon panel
--
-- @function [parent=#PlannerAbstractEdition] getBeaconPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getBeaconPanel(player)
	local panel = self:getPanel(player)
	if panel["beacon"] ~= nil and panel["beacon"].valid then
		return panel["beacon"]
	end
	return self:addGuiFlowH(panel, "beacon", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#PlannerAbstractEdition] getBeaconOtherInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getBeaconOtherInfoPanel(player)
	local panel = self:getBeaconPanel(player)
	if panel["selector"] ~= nil and panel["selector"].valid then
		return panel["selector"]
	end
	return self:addGuiFlowV(panel, "selector", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#PlannerAbstractEdition] getBeaconSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getBeaconSelectorPanel(player)
	local panel = self:getBeaconOtherInfoPanel(player)
	if panel["selector"] ~= nil and panel["selector"].valid then
		return panel["selector"]
	end
	return self:addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.beacon"}))
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerAbstractEdition] getBeaconInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getBeaconInfoPanel(player)
	local panel = self:getBeaconPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.beacon"}))
end

-------------------------------------------------------------------------------
-- Get or create beacon modules selector panel
--
-- @function [parent=#PlannerAbstractEdition] getBeaconModulesSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getBeaconModulesSelectorPanel(player)
	local modulesPanel = self:getBeaconOtherInfoPanel(player)
	local selectionModulesPanel = modulesPanel["selection-modules"]
	if selectionModulesPanel == nil then
		selectionModulesPanel = self:addGuiFrameV(modulesPanel, "selection-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.selection-modules"}))
	end

	local scrollModulesPanel = selectionModulesPanel["scroll-modules"]
	if scrollModulesPanel == nil then
		scrollModulesPanel = self:addGuiScrollPane(selectionModulesPanel, "scroll-modules", "helmod_scroll_recipe_module_list", "auto", "auto")
	end
	return scrollModulesPanel
end

-------------------------------------------------------------------------------
-- Get or create beacon actived modules panel
--
-- @function [parent=#PlannerAbstractEdition] getBeaconActivedModulesPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:getBeaconActivedModulesPanel(player)
	local modulesPanel = self:getBeaconOtherInfoPanel(player)
	if modulesPanel["current-modules"] ~= nil and modulesPanel["current-modules"].valid then
		return modulesPanel["current-modules"]
	end
	return self:addGuiFrameV(modulesPanel, "current-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.current-modules"}))
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerAbstractEdition] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:after_open(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:after_open():",player, element, action, item, item2, item3)
	self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
	self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
	self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
	local object = self:getObject(player, element, action, item, item2, item3)

	local model = self.model:getModel(player)
	if model.module_panel == nil then
		model.module_panel = true
	end

	self:buildHeaderPanel(player)
	if object ~= nil then
		-- factory
		self:buildFactoryPanel(player)
		-- beacon
		self:buildBeaconPanel(player)
	end
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#PlannerAbstractEdition] buildHeaderPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:buildHeaderPanel(player)
	Logging:debug("PlannerAbstractEdition:buildHeaderPanel():",player)
	-- TODO something
end

-------------------------------------------------------------------------------
-- Build factory panel
--
-- @function [parent=#PlannerAbstractEdition] buildFactoryPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:buildFactoryPanel(player)
	Logging:debug("PlannerAbstractEdition:buildFactoryPanel():",player)
	self:getFactoryInfoPanel(player)
	self:getFactoryOtherInfoPanel(player)
end

-------------------------------------------------------------------------------
-- Build beacon panel
--
-- @function [parent=#PlannerAbstractEdition] buildBeaconPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractEdition.methods:buildBeaconPanel(player)
	Logging:debug("PlannerAbstractEdition:buildBeaconPanel():",player)
	self:getBeaconInfoPanel(player)
	self:getBeaconOtherInfoPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerAbstractEdition] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:on_update(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:on_update():",player, element, action, item, item2, item3)
	local object = self:getObject(player, element, action, item, item2, item3)
	-- header
	self:updateHeader(player, element, action, item, item2, item3)
	if object ~= nil then
		-- factory
		self:updateFactory(player, element, action, item, item2, item3)
		-- beacon
		self:updateBeacon(player, element, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#PlannerAbstractEdition] updateHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateHeader(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateHeader():",player, element, action, item, item2, item3)
	-- TODO something
end

-------------------------------------------------------------------------------
-- Update factory
--
-- @function [parent=#PlannerAbstractEdition] updateFactory
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateFactory(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateFactory():",player, element, action, item, item2, item3)
	local model = self.model:getModel(player)

	self:updateFactoryInfo(player, element, action, item, item2, item3)
	if model.module_panel == true then
		self:updateFactoryActivedModules(player, element, action, item, item2, item3)
		self:updateFactoryModulesSelector(player, element, action, item, item2, item3)
	else
		self:updateFactorySelector(player, element, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Update beacon
--
-- @function [parent=#PlannerAbstractEdition] updateBeacon
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateBeacon(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateBeacon():",player, element, action, item, item2, item3)
	local model = self.model:getModel(player)

	self:updateBeaconInfo(player, element, action, item, item2, item3)
	if model.module_panel == true then
		self:updateBeaconActivedModules(player, element, action, item, item2, item3)
		self:updateBeaconModulesSelector(player, element, action, item, item2, item3)
	else
		self:updateBeaconSelector(player, element, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Get element
--
-- @function [parent=#PlannerAbstractEdition] getElement
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:getObject(player, element, action, item, item2, item3)
	-- TODO something
	return nil
end
-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerAbstractEdition] updateFactoryInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateFactoryInfo(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateFactoryInfo():",player, element, action, item, item2, item3)
	local infoPanel = self:getFactoryInfoPanel(player)
	local object = self:getObject(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	if object ~= nil then
		Logging:debug("PlannerAbstractEdition:updateFactoryInfo():object:",object)
		local factory = object.factory
		local _factory = self.player:getItemPrototype(factory.name)

		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
		local tooltip = ({"tooltip.selector-module"})
		if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
		self:addSelectSpriteIconButton(headerPanel, self:classname().."=change-panel=ID="..item.."="..object.name.."=", self.player:getIconType(factory), factory.name, factory.name, nil, tooltip)
		if _factory == nil then
			self:addGuiLabel(headerPanel, "label", factory.name)
		else
			self:addGuiLabel(headerPanel, "label", _factory.localised_name)
		end

		local inputPanel = self:addGuiTable(infoPanel,"table-input",2)

		self:addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy-nominal"}))
		self:addGuiText(inputPanel, "energy-nominal", factory.energy_nominal, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-speed-nominal", ({"helmod_label.speed-nominal"}))
		self:addGuiText(inputPanel, "speed-nominal", factory.speed_nominal, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
		self:addGuiText(inputPanel, "module-slots", factory.module_slots, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-limit", ({"helmod_label.limit"}))
		self:addGuiText(inputPanel, "limit", factory.limit, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-energy", ({"helmod_label.energy"}))
		self:addGuiLabel(inputPanel, "energy", factory.energy)

		self:addGuiLabel(inputPanel, "label-speed", ({"helmod_label.speed"}))
		self:addGuiLabel(inputPanel, "speed", factory.speed)

		self:addGuiButton(infoPanel, self:classname().."=factory-update=ID="..item.."=", object.name, "helmod_button-default", ({"helmod_button.update"}))
	end
end

-------------------------------------------------------------------------------
-- Update module selector
--
-- @function [parent=#PlannerAbstractEdition] updateFactoryModulesSelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateFactoryModulesSelector(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateFactoryModulesSelector():",player, element, action, item, item2, item3)
	local selectorPanel = self:getFactoryModulesSelectorPanel(player)
	local model = self.model:getModel(player)
	local object = self:getObject(player, element, action, item, item2, item3)

	if selectorPanel["modules"] ~= nil and selectorPanel["modules"].valid and model.moduleListRefresh == true then
		selectorPanel["modules"].destroy()
	end

	if selectorPanel["modules"] == nil then
		local tableModulesPanel = self:addGuiTable(selectorPanel,"modules",4)
		for k, module in pairs(self.player:getModules()) do
			local allowed = true
			local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
			local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
			local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
			local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
			if productivity > 0 then
				if module.limitations[object.name] == nil then allowed = false end
			end
			local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
			if allowed == false then
				tooltip = ({"item-limitation."..module.limitation_message_key})
				self:addSelectSpriteIconButton(tableModulesPanel, self:classname().."=do-nothing=ID="..item.."="..object.name.."=", "item", module.name, module.name, "red", tooltip)
			else
				self:addSelectSpriteIconButton(tableModulesPanel, self:classname().."=factory-module-add=ID="..item.."="..object.name.."=", "item", module.name, module.name, nil, tooltip)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Update actived modules information
--
-- @function [parent=#PlannerAbstractEdition] updateFactoryActivedModules
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateFactoryActivedModules(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateFactoryActivedModules():",player, element, action, item, item2, item3)
	local activedModulesPanel = self:getFactoryActivedModulesPanel(player)
	local object = self:getObject(player, element, action, item, item2, item3)
	local factory = object.factory

	if activedModulesPanel["modules"] ~= nil and activedModulesPanel["modules"].valid then
		activedModulesPanel["modules"].destroy()
	end

	-- actived modules panel
	local currentTableModulesPanel = self:addGuiTable(activedModulesPanel,"modules",4,"helmod_table_recipe_modules")
	for module, count in pairs(factory.modules) do
		local tooltip = module
		local _module = self.player:getItemPrototype(module)
		if _module ~= nil then
			local consumption = self:formatPercent(self.player:getModuleBonus(_module.name, "consumption"))
			local speed = self:formatPercent(self.player:getModuleBonus(_module.name, "speed"))
			local productivity = self:formatPercent(self.player:getModuleBonus(_module.name, "productivity"))
			local pollution = self:formatPercent(self.player:getModuleBonus(_module.name, "pollution"))
			tooltip = ({"tooltip.module-description" , _module.localised_name, consumption, speed, productivity, pollution})
		end
		for i = 1, count, 1 do
			self:addSelectSpriteIconButton(currentTableModulesPanel, self:classname().."=factory-module-remove=ID="..item.."="..object.name.."="..module.."="..i, "item", module, module, nil, tooltip)
		end
	end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#PlannerAbstractEdition] updateFactorySelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateFactorySelector(player, element, action, item, item2, item3)
	Logging:debug("PlannerFactorySelector:updateFactorySelector():",player, element, action, item, item2, item3)
	local globalSettings = self.player:getGlobal(player, "settings")

	local selectorPanel = self:getFactorySelectorPanel(player)
	local model = self.model:getModel(player)

	local object = self:getObject(player, element, action, item, item2, item3)

	if selectorPanel["scroll-groups"] ~= nil and selectorPanel["scroll-groups"].valid then
		selectorPanel["scroll-groups"].destroy()
	end

	-- ajouter de la table des groupes de recipe
	local scrollGroups = self:addGuiScrollPane(selectorPanel, "scroll-groups", "helmod_scroll_recipe_factory_group", "auto", "auto")
	local groupsPanel = self:addGuiTable(scrollGroups, "factory-groups", 2)
	Logging:debug("PlannerFactorySelector:updateFactorySelector(): group category=",object.category)

	local category = object.category
	if globalSettings.model_filter_factory ~= nil and globalSettings.model_filter_factory == false then category = nil end

	for group, name in pairs(self.player:getProductionGroups(category)) do
		-- set le groupe
		if model.factoryGroupSelected == nil then model.factoryGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addGuiButton(groupsPanel, self:classname().."=factory-group=ID="..item.."="..object.name.."=", group, "helmod_button-default", group)
	end

	if selectorPanel["scroll-factory"] ~= nil and selectorPanel["scroll-factory"].valid then
		selectorPanel["scroll-factory"].destroy()
	end

	local scrollTable = self:addGuiScrollPane(selectorPanel, "scroll-factory", "helmod_scroll_recipe_factories", "auto", "auto")
	local tablePanel = self:addGuiTable(scrollTable, "factory-table", 5)
	Logging:debug("factories:",self.player:getProductions())
	for key, factory in pairs(self.player:getProductions()) do
		if factory.type == model.factoryGroupSelected then
			self:addSpriteIconButton(tablePanel, self:classname().."=factory-select=ID="..item.."="..object.name.."=", "item", factory.name, true)
		end
	end
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerAbstractEdition] updateBeaconInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateBeaconInfo(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateBeaconInfo():",player, element, action, item, item2, item3)
	local infoPanel = self:getBeaconInfoPanel(player)
	local object = self:getObject(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)

	if object ~= nil then
		local beacon = object.beacon
		local _beacon = self.player:getItemPrototype(beacon.name)

		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
		local tooltip = ({"tooltip.selector-module"})
		if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
		self:addSelectSpriteIconButton(headerPanel, self:classname().."=change-panel=ID="..item.."="..object.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, nil, tooltip)
		if _beacon == nil then
			self:addGuiLabel(headerPanel, "label", beacon.name)
		else
			self:addGuiLabel(headerPanel, "label", _beacon.localised_name)
		end

		local inputPanel = self:addGuiTable(infoPanel,"table-input",2)

		self:addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy-nominal"}))
		self:addGuiText(inputPanel, "energy-nominal", beacon.energy_nominal, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-combo", ({"helmod_label.combo"}))
		self:addGuiText(inputPanel, "combo", beacon.combo, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-factory", ({"helmod_label.factory"}))
		self:addGuiText(inputPanel, "factory", beacon.factory, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-efficiency", ({"helmod_label.efficiency"}))
		self:addGuiText(inputPanel, "efficiency", beacon.efficiency, "helmod_textfield")

		self:addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
		self:addGuiText(inputPanel, "module-slots", beacon.module_slots, "helmod_textfield")

		self:addGuiButton(infoPanel, self:classname().."=beacon-update=ID="..item.."=", object.name, "helmod_button-default", ({"helmod_button.update"}))
	end
end

-------------------------------------------------------------------------------
-- Update actived modules information
--
-- @function [parent=#PlannerAbstractEdition] updateBeaconActivedModules
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateBeaconActivedModules(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateBeaconActivedModules():",player, element, action, item, item2, item3)
	local activedModulesPanel = self:getBeaconActivedModulesPanel(player)

	local object = self:getObject(player, element, action, item, item2, item3)
	local beacon = object.beacon

	if activedModulesPanel["modules"] ~= nil and activedModulesPanel["modules"].valid then
		activedModulesPanel["modules"].destroy()
	end

	-- actived modules panel
	local currentTableModulesPanel = self:addGuiTable(activedModulesPanel,"modules",4, "helmod_table_recipe_modules")
	for module, count in pairs(beacon.modules) do
		local tooltip = module
		local _module = self.player:getItemPrototype(module)
		if _module ~= nil then
			local consumption = self:formatPercent(self.player:getModuleBonus(_module.name, "consumption"))
			local speed = self:formatPercent(self.player:getModuleBonus(_module.name, "speed"))
			local productivity = self:formatPercent(self.player:getModuleBonus(_module.name, "productivity"))
			local pollution = self:formatPercent(self.player:getModuleBonus(_module.name, "pollution"))
			tooltip = ({"tooltip.module-description" , _module.localised_name, consumption, speed, productivity, pollution})
		end

		for i = 1, count, 1 do
			self:addSelectSpriteIconButton(currentTableModulesPanel, self:classname().."=beacon-module-remove=ID="..item.."="..object.name.."="..module.."="..i, "item", module, module, nil, tooltip)
		end
	end
end

-------------------------------------------------------------------------------
-- Update modules selector
--
-- @function [parent=#PlannerAbstractEdition] updateBeaconModulesSelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateBeaconModulesSelector(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateBeaconModulesSelector():",player, element, action, item, item2, item3)
	local selectorPanel = self:getBeaconModulesSelectorPanel(player)
	local model = self.model:getModel(player)
	local object = self:getObject(player, element, action, item, item2, item3)

	if selectorPanel["modules"] ~= nil and selectorPanel["modules"].valid and model.moduleListRefresh == true then
		selectorPanel["modules"].destroy()
	end

	if selectorPanel["modules"] == nil then
		local tableModulesPanel = self:addGuiTable(selectorPanel,"modules",4)
		for k, module in pairs(self.player:getModules()) do
			local allowed = true
			local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
			local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
			local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
			local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
			if productivity > 0 then
				allowed = false
			end
			local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
			if allowed == false then
				tooltip = ({"item-limitation.item-not-allowed-in-this-container-item"})
				self:addSelectSpriteIconButton(tableModulesPanel, self:classname().."=do-nothing=ID="..item.."="..object.name.."=", "item", module.name, module.name, "red", tooltip)
			else
				self:addSelectSpriteIconButton(tableModulesPanel, self:classname().."=beacon-module-add=ID="..item.."="..object.name.."=", "item", module.name, module.name, nil, tooltip)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#PlannerAbstractEdition] updateBeaconSelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:updateBeaconSelector(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:updateBeaconSelector():",player, element, action, item, item2, item3)
	local globalSettings = self.player:getGlobal(player, "settings")
	local selectorPanel = self:getBeaconSelectorPanel(player)
	local model = self.model:getModel(player)

	local object = self:getObject(player, element, action, item, item2, item3)

	if selectorPanel["scroll-groups"] ~= nil and selectorPanel["scroll-groups"].valid then
		selectorPanel["scroll-groups"].destroy()
	end

	-- ajouter de la table des groupes de recipe
	local scrollGroups = self:addGuiScrollPane(selectorPanel, "scroll-groups", "helmod_scroll_recipe_factory_group", "auto", "auto")
	local groupsPanel = self:addGuiTable(scrollGroups, "beacon-groups", 2)
	local category = "module"
	if globalSettings.model_filter_beacon ~= nil and globalSettings.model_filter_beacon == false then category = nil end
	for group, name in pairs(self.player:getProductionGroups(category)) do
		-- set le groupe
		if model.beaconGroupSelected == nil then model.beaconGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addGuiButton(groupsPanel, self:classname().."=beacon-group=ID="..item.."="..object.name.."=", group, "helmod_button-default", group)
	end

	if selectorPanel["scroll-beacon"] ~= nil and selectorPanel["scroll-beacon"].valid then
		selectorPanel["scroll-beacon"].destroy()
	end

	local scrollTable = self:addGuiScrollPane(selectorPanel, "scroll-beacon", "helmod_scroll_recipe_factories", "auto", "auto")
	local tablePanel = self:addGuiTable(scrollTable, "beacon-table", 5)
	--Logging:debug("factories:",self.player:getProductions())
	for key, beacon in pairs(self.player:getProductions()) do
		if beacon.type == model.beaconGroupSelected then
			self:addSpriteIconButton(tablePanel, self:classname().."=beacon-select=ID="..item.."="..object.name.."=", "item", beacon.name, true)
		end
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerAbstractEdition] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractEdition.methods:on_event(player, element, action, item, item2, item3)
	Logging:debug("PlannerAbstractEdition:on_event():",player, element, action, item, item2, item3)
	local model = self.model:getModel(player)

	if action == "change-panel" then
		model.module_panel = not(model.module_panel)
		self:send_event(player, element, "CLOSE", item, item2, item3)
		self:send_event(player, element, "OPEN", item, item2, item3)
	end

	if action == "object-update" then
		local inputPanel = self:getObjectInfoPanel(player)["table-input"]
		local options = {}

		if inputPanel["production"] ~= nil then
			options["production"] = self:getInputNumber(inputPanel["production"])
		end

		self.model:updateObject(player, item, item2, options)
		self.model:update(player)
		self:updateObjectInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "factory-group" then
		model.factoryGroupSelected = item3
		self:updateFactorySelector(player, element, action, item, item2, item3)
	end

	if action == "factory-select" then
		--element.state = true
		-- item=recipe item2=factory
		self.model:setFactory(player, item, item2, item3)
		self.model:update(player)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "factory-update" then
		local inputPanel = self:getFactoryInfoPanel(player)["table-input"]
		local options = {}

		if inputPanel["energy-nominal"] ~= nil then
			options["energy_nominal"] = self:getInputNumber(inputPanel["energy-nominal"])
		end

		if inputPanel["speed-nominal"] ~= nil then
			options["speed_nominal"] = self:getInputNumber(inputPanel["speed-nominal"])
		end

		if inputPanel["module-slots"] ~= nil then
			options["module_slots"] = self:getInputNumber(inputPanel["module-slots"])
		end

		if inputPanel["limit"] ~= nil then
			options["limit"] = self:getInputNumber(inputPanel["limit"])
		end

		self.model:updateFactory(player, item, item2, options)
		self.model:update(player)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "factory-module-add" then
		self.model:addFactoryModule(player, item, item2, item3)
		self.model:update(player)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self:updateFactoryActivedModules(player, element, action, item, item2, item3)
		self:updateBeaconInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "factory-module-remove" then
		self.model:removeFactoryModule(player, item, item2, item3)
		self.model:update(player)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self:updateFactoryActivedModules(player, element, action, item, item2, item3)
		self:updateBeaconInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "beacon-group" then
		model.beaconGroupSelected = item3
		self:updateBeaconSelector(player, element, action, item, item2, item3)
	end

	if action == "beacon-select" then
		self.model:setBeacon(player, item, item2, item3)
		self.model:update(player)
		self:updateBeaconInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "beacon-update" then
		local inputPanel = self:getBeaconInfoPanel(player)["table-input"]
		local options = {}

		if inputPanel["energy-nominal"] ~= nil then
			options["energy_nominal"] = self:getInputNumber(inputPanel["energy-nominal"])
		end

		if inputPanel["combo"] ~= nil then
			options["combo"] = self:getInputNumber(inputPanel["combo"])
		end

		if inputPanel["factory"] ~= nil then
			options["factory"] = self:getInputNumber(inputPanel["factory"])
		end

		if inputPanel["efficiency"] ~= nil then
			options["efficiency"] = self:getInputNumber(inputPanel["efficiency"])
		end

		if inputPanel["module-slots"] ~= nil then
			options["module_slots"] = self:getInputNumber(inputPanel["module-slots"])
		end

		self.model:updateBeacon(player, item, item2, options)
		self.model:update(player)
		self:updateBeaconInfo(player, element, action, item, item2, item3)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "beacon-module-add" then
		self.model:addBeaconModule(player, item, item2, item3)
		self.model:update(player)
		self:updateBeaconInfo(player, element, action, item, item2, item3)
		self:updateBeaconActivedModules(player, element, action, item, item2, item3)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end

	if action == "beacon-module-remove" then
		self.model:removeBeaconModule(player, item, item2, item3)
		self.model:update(player)
		self:updateBeaconInfo(player, element, action, item, item2, item3)
		self:updateBeaconActivedModules(player, element, action, item, item2, item3)
		self:updateFactoryInfo(player, element, action, item, item2, item3)
		self.parent:refreshDisplayData(player, nil, item, item2)
	end
end
