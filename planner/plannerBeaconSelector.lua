-------------------------------------------------------------------------------
-- Classe to build factory dialog
-- 
-- @module PlannerBeaconSelector
-- @extends #PlannerDialog 
-- 

PlannerBeaconSelector = setclass("HMPlannerBeaconSelector", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerBeaconSelector] on_init
-- 
-- @param #PlannerController parent parent controller
-- 
function PlannerBeaconSelector.methods:on_init(parent)
	self.panelCaption = "Beacon"
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerBeaconSelector] getParentPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
-- 
function PlannerBeaconSelector.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerBeaconSelector] on_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
-- @return #boolean if true the next call close dialog
--  
function PlannerBeaconSelector.methods:on_open(player, element, action, item, item2)
	local model = self.model:getModel(player)
	local close = true
	if model.guiBeaconLast == nil or model.guiBeaconLast ~= item then
		close = false
		model.beaconGroupSelected = nil
	end
	model.guiBeaconLast = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerBeaconSelector] on_close
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerBeaconSelector.methods:on_close(player, element, action, item, item2)
	local model = self.model:getModel(player)
	model.beaconGroupSelected = nil
	model.guiBeaconLast = nil
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#PlannerBeaconSelector] getSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerBeaconSelector.methods:getSelectorPanel(player)
	local panel = self:getPanel(player)
	if panel["selector"] ~= nil and panel["selector"].valid then
		return panel["selector"]
	end
	return self:addGuiFrameV(panel, "selector", "helmod_module-table-frame")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerBeaconSelector] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerBeaconSelector.methods:getInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameV(panel, "info", "helmod_module-table-frame")
end

-------------------------------------------------------------------------------
-- Get or create modules panel
--
-- @function [parent=#PlannerBeaconSelector] getModulePanel
--
-- @param #LuaPlayer player
--
function PlannerBeaconSelector.methods:getModulesPanel(player)
	local panel = self:getPanel(player)
	if panel["modules"] ~= nil and panel["modules"].valid then
		return panel["modules"]
	end
	return self:addGuiFrameV(panel, "modules", "helmod_module-table-frame", "Modules")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerBeaconSelector] after_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerBeaconSelector.methods:after_open(player, element, action, item, item2)
	self:getSelectorPanel(player)
	self:getInfoPanel(player)
	self:getModulesPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerBeaconSelector] on_update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerBeaconSelector.methods:on_update(player, element, action, item, item2)
	self:updateSelector(player, item)
	self:updateInfo(player, item)
	self:updateModulesInfo(player, item)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerBeaconSelector] updateInfo
-- 
-- @param #LuaPlayer player
-- @param #string item item name
-- 
function PlannerBeaconSelector.methods:updateInfo(player, item)
	local infoPanel = self:getInfoPanel(player)
	local model = self.model:getModel(player)
	local recipe = model.recipes[item]
	if recipe ~= nil then
		local beacon = recipe.beacon

		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
		self:addIconButton(headerPanel, "icon", beacon.type, beacon.name)
		self:addGuiLabel(headerPanel, "label", beacon.name)
		
		local inputPanel = self:addGuiTable(infoPanel,"table-input",2)

		self:addGuiLabel(inputPanel, "label-energy-nominal", "Nominal energy")
		self:addGuiText(inputPanel, "energy-nominal", beacon.energy_nominal)
		
		self:addGuiLabel(inputPanel, "label-combo", "Combo")
		self:addGuiText(inputPanel, "combo", beacon.combo)
		
		self:addGuiLabel(inputPanel, "label-factory", "Factory")
		self:addGuiText(inputPanel, "factory", beacon.factory)
		
		self:addGuiLabel(inputPanel, "label-efficiency", "Efficiency")
		self:addGuiText(inputPanel, "efficiency", beacon.efficiency)
		
		self:addGuiLabel(inputPanel, "label-module-slots", "Module Slots")
		self:addGuiText(inputPanel, "module-slots", beacon.module_slots)

		self:addGuiButton(infoPanel, self:classname().."_beacon-update_ID_", recipe.name, "helmod_button-default", "Update")
	end
end

-------------------------------------------------------------------------------
-- Update module information
--
-- @function [parent=#PlannerBeaconSelector] updateModulesInfo
-- 
-- @param #LuaPlayer player
-- @param #string item item name
-- 
function PlannerBeaconSelector.methods:updateModulesInfo(player, item)
	local modulesPanel = self:getModulesPanel(player)
	local model = self.model:getModel(player)
	
	local recipe = model.recipes[item]
	local beacon = recipe.beacon

	for k,guiName in pairs(modulesPanel.children_names) do
		modulesPanel[guiName].destroy()
	end
	local tableModulesPanel = self:addGuiTable(modulesPanel,"modules",9)
	for k, module in pairs(self.player:getModules()) do
		local count = 0
		if beacon.modules[module.name] ~= nil then count = beacon.modules[module.name] end
		self:addIconButton(tableModulesPanel, self:classname().."_module_ID_"..recipe.name.."_", module.type, module.name, count)
		self:addGuiButton(tableModulesPanel, self:classname().."_module-add_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "+")
		self:addGuiButton(tableModulesPanel, self:classname().."_module-remove_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "-")
	end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#PlannerBeaconSelector] updateSelector
-- 
-- @param #LuaPlayer player
-- @param #string item item name
-- 
function PlannerBeaconSelector.methods:updateSelector(player, item)
	local selectorPanel = self:getSelectorPanel(player)
	local model = self.model:getModel(player)
	
	local recipe = model.recipes[item]

	if selectorPanel["beacon-groups"] ~= nil and selectorPanel["beacon-groups"].valid then
		selectorPanel["beacon-groups"].destroy()
	end

	-- ajouter de la table des groupes de recipe
	local groupsPanel = self:addGuiTable(selectorPanel, "beacon-groups", 5)
	for group, name in pairs(self.player:getProductionGroups("module")) do
		-- set le groupe
		if model.beaconGroupSelected == nil then model.beaconGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addItemButton(groupsPanel, self:classname().."_beacon-group_ID_"..recipe.name.."_", group)
	end

	if selectorPanel["beacon-table"] ~= nil and selectorPanel["beacon-table"].valid then
		selectorPanel["beacon-table"].destroy()
	end

	local tablePanel = self:addGuiTable(selectorPanel, "beacon-table", 10)
	--Logging:debug("factories:",self.player:getProductions())
	for key, beacon in pairs(self.player:getProductions()) do
		if beacon.type == model.beaconGroupSelected then
			self:addSpriteIconButton(tablePanel, self:classname().."_beacon-select_ID_"..recipe.name.."_", "item", beacon.name, true)
		end
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerBeaconSelector] on_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerBeaconSelector.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerBeaconSelector:on_event():",player, action, item, item2)
	local model = self.model:getModel(player)
	
	if action == "beacon-group" then
		model.beaconGroupSelected = item2
		self:updateSelector(player, item)
	end

	if action == "beacon-select" then
		self.model:setBeacon(player, item, item2)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

	if action == "beacon-update" then
		local inputPanel = self:getInfoPanel(player)["table-input"]
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

		self.model:updateBeacon(player, item, options)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

	if action == "module-add" then
		self.model:addBeaconModule(player, item, item2)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

	if action == "module-remove" then
		self.model:removeBeaconModule(player, item, item2)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

end
