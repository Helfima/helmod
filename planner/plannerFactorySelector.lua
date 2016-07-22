-------------------------------------------------------------------------------
-- Classe to build factory dialog
-- 
-- @module PlannerFactorySelector
-- @extends #PlannerDialog 
-- 

PlannerFactorySelector = setclass("HMPlannerFactorySelector", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerFactorySelector] on_init
-- 
-- @param #PlannerController parent parent controller
-- 
function PlannerFactorySelector.methods:on_init(parent)
	self.panelCaption = "Factory"
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerFactorySelector] getParentPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
-- 
function PlannerFactorySelector.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerFactorySelector] on_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
-- @return #boolean if true the next call close dialog
-- 
function PlannerFactorySelector.methods:on_open(player, element, action, item, item2)
	local model = self.model:getModel(player)
	local close = true
	if model.guiFactoryLast == nil or model.guiFactoryLast ~= item then
		close = false
		model.factoryGroupSelected = nil
	end
	model.guiFactoryLast = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerFactorySelector] on_close
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:on_close(player, element, action, item, item2)
	local model = self.model:getModel(player)
	model.factoryGroupSelected = nil
	model.guiFactoryLast = nil
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#PlannerFactorySelector] getSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerFactorySelector.methods:getSelectorPanel(player)
	local panel = self:getPanel(player)
	if panel["selector"] ~= nil and panel["selector"].valid then
		return panel["selector"]
	end
	return self:addGuiFrameV(panel, "selector", "helmod_module-table-frame")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerFactorySelector] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerFactorySelector.methods:getInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameV(panel, "info", "helmod_module-table-frame")
end

-------------------------------------------------------------------------------
-- Get or create modules panel
--
-- @function [parent=#PlannerFactorySelector] getModulePanel
--
-- @param #LuaPlayer player
--
function PlannerFactorySelector.methods:getModulesPanel(player)
	local panel = self:getPanel(player)
	if panel["modules"] ~= nil and panel["modules"].valid then
		return panel["modules"]
	end
	return self:addGuiFrameV(panel, "modules", "helmod_module-table-frame", "Modules")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerFactorySelector] after_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:after_open(player, element, action, item, item2)
	self:getSelectorPanel(player)
	self:getInfoPanel(player)
	self:getModulesPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerFactorySelector] on_update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:on_update(player, element, action, item, item2)
	self:updateSelector(player, item)
	self:updateInfo(player, item)
	self:updateModulesInfo(player, item)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerFactorySelector] updateInfo
-- 
-- @param #LuaPlayer player
-- @param #string item item name
-- 
function PlannerFactorySelector.methods:updateInfo(player, item)
	local infoPanel = self:getInfoPanel(player)
	local model = self.model:getModel(player)
	local recipe = model.recipes[item]
	if recipe ~= nil then
		local factory = recipe.factory

		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
		self:addIconButton(headerPanel, "icon", factory.type, factory.name)
		self:addGuiLabel(headerPanel, "label", factory.name)
		
		local inputPanel = self:addGuiTable(infoPanel,"table-input",2)

		self:addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label-energy-nominal"}))
		self:addGuiText(inputPanel, "energy-nominal", factory.energy_nominal)
		
		self:addGuiLabel(inputPanel, "label-speed-nominal", ({"helmod_label-speed-nominal"}))
		self:addGuiText(inputPanel, "speed-nominal", factory.speed_nominal)
		
		self:addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label-module-slots"}))
		self:addGuiText(inputPanel, "module-slots", factory.module_slots)

		self:addGuiLabel(inputPanel, "label-energy", ({"helmod_label-energy"}))
		self:addGuiLabel(inputPanel, "energy", factory.energy)
		
		self:addGuiLabel(inputPanel, "label-speed", ({"helmod_label-speed"}))
		self:addGuiLabel(inputPanel, "speed", factory.speed)
		
		self:addGuiButton(infoPanel, self:classname().."_factory-update_ID_", recipe.name, "helmod_button-default", ({"helmod_button-update"}))
	end
end

-------------------------------------------------------------------------------
-- Update module information
--
-- @function [parent=#PlannerFactorySelector] updateModulesInfo
-- 
-- @param #LuaPlayer player
-- @param #string item item name
-- 
function PlannerFactorySelector.methods:updateModulesInfo(player, item)
	local modulesPanel = self:getModulesPanel(player)
	local model = self.model:getModel(player)
	
	local recipe = model.recipes[item]
	local factory = recipe.factory

	for k,guiName in pairs(modulesPanel.children_names) do
		modulesPanel[guiName].destroy()
	end
	local tableModulesPanel = self:addGuiTable(modulesPanel,"modules",9)
	for k, module in pairs(self.player:getModules()) do
		local count = 0
		if factory.modules[module.name] ~= nil then count = factory.modules[module.name] end
		self:addIconButton(tableModulesPanel, self:classname().."_module_ID_"..recipe.name.."_", module.type, module.name, count)
		self:addGuiButton(tableModulesPanel, self:classname().."_module-add_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "+")
		self:addGuiButton(tableModulesPanel, self:classname().."_module-remove_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "-")
	end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#PlannerFactorySelector] updateSelector
-- 
-- @param #LuaPlayer player
-- @param #string item item name
-- 
function PlannerFactorySelector.methods:updateSelector(player, item)
	local selectorPanel = self:getSelectorPanel(player)
	local model = self.model:getModel(player)
	
	local recipe = model.recipes[item]
	
	if selectorPanel["factory-groups"] ~= nil and selectorPanel["factory-groups"].valid then
		selectorPanel["factory-groups"].destroy()
	end

	-- ajouter de la table des groupes de recipe
	local groupsPanel = self:addGuiTable(selectorPanel, "factory-groups", 5)
	for group, name in pairs(self.player:getProductionGroups(recipe.category)) do
		-- set le groupe
		if model.factoryGroupSelected == nil then model.factoryGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addItemButton(groupsPanel, self:classname().."_factory-group_ID_"..recipe.name.."_", group)
	end

	if selectorPanel["factory-table"] ~= nil and selectorPanel["factory-table"].valid then
		selectorPanel["factory-table"].destroy()
	end

	local tablePanel = self:addGuiTable(selectorPanel, "factory-table", 10)
	--Logging:debug("factories:",self.player:getProductions())
	for key, factory in pairs(self.player:getProductions()) do
		if factory.type == model.factoryGroupSelected then
			self:addSpriteIconButton(tablePanel, self:classname().."_factory-select_ID_"..recipe.name.."_", "item", factory.name, true)
		end
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerFactorySelector] on_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerFactorySelector:on_event():",player, action, item, item2)
	local model = self.model:getModel(player)
	
	if action == "factory-group" then
		model.factoryGroupSelected = item2
		self:updateSelector(player, item)
	end

	if action == "factory-select" then
		--element.state = true
		-- item=recipe item2=factory
		self.model:setFactory(player, item, item2)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

	if action == "factory-update" then
		local inputPanel = self:getInfoPanel(player)["table-input"]
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

		self.model:updateFactory(player, item, options)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

	if action == "module-add" then
		self.model:addFactoryModule(player, item, item2)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

	if action == "module-remove" then
		self.model:removeFactoryModule(player, item, item2)
		self.model:update(player)
		self:updateInfo(player, item)
		self:updateModulesInfo(player, item)
		self.parent:refreshDisplayData(player)
	end

end