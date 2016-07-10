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
-- On open
--
-- @function [parent=#PlannerFactorySelector] on_open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
-- @return #boolean if true the next call close dialog
-- 
function PlannerFactorySelector.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiFactoryLast == nil or self.guiFactoryLast ~= item then
		close = false
		self.factoryGroupSelected = nil
	end
	self.guiFactoryLast = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerFactorySelector] on_close
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:on_close(element, action, item, item2)
	self.factoryGroupSelected = nil
	self.guiFactoryLast = nil
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerFactorySelector] after_open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:after_open(element, action, item, item2)
	self.guiSelector = self:addGuiFrameV(self.gui, "selector", "helmod_module-table-frame")
	self.guiData = self:addGuiFrameV(self.gui, "data", "helmod_module-table-frame")
	self.guiModule = self:addGuiFrameV(self.gui, "module", "helmod_module-table-frame", "Modules")
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerFactorySelector] on_update
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:on_update(element, action, item, item2)
	self:updateSelector(item)
	self:updateInfo(item)
	self:updateModulesInfo(item)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerFactorySelector] updateInfo
-- 
-- @param #string item item name
-- 
function PlannerFactorySelector.methods:updateInfo(item)
	local recipe = self.model.recipes[item]
	if recipe ~= nil then
		local factory = recipe.factory

		for k,guiName in pairs(self.guiData.children_names) do
			self.guiData[guiName].destroy()
		end

		local guiTableHeader = self:addGuiTable(self.guiData,"table-header",2)
		self:addIconButton(guiTableHeader, "icon", factory.type, factory.name)
		self:addGuiLabel(guiTableHeader, "label", factory.name)
		
		local guiTableInput = self:addGuiTable(self.guiData,"table",2)

		self:addGuiLabel(guiTableInput, "label-energy-nominal", ({"helmod_label-energy-nominal"}))
		self.guiInputs["energy-nominal"] = self:addGuiText(guiTableInput, "energy-nominal", factory.energy_nominal)
		
		self:addGuiLabel(guiTableInput, "label-speed-nominal", ({"helmod_label-speed-nominal"}))
		self.guiInputs["speed-nominal"] = self:addGuiText(guiTableInput, "speed-nominal", factory.speed_nominal)
		
		self:addGuiLabel(guiTableInput, "label-module-slots", ({"helmod_label-module-slots"}))
		self.guiInputs["module-slots"] = self:addGuiText(guiTableInput, "module-slots", factory.module_slots)

		self:addGuiLabel(guiTableInput, "label-energy", ({"helmod_label-energy"}))
		self:addGuiLabel(guiTableInput, "energy", factory.energy)
		
		self:addGuiLabel(guiTableInput, "label-speed", ({"helmod_label-speed"}))
		self:addGuiLabel(guiTableInput, "speed", factory.speed)
		
		self:addGuiButton(self.guiData, self:classname().."_factory-update_ID_", recipe.name, "helmod_button-default", ({"helmod_button-update"}))
	end
end

-------------------------------------------------------------------------------
-- Update module information
--
-- @function [parent=#PlannerFactorySelector] updateModulesInfo
-- 
-- @param #string item item name
-- 
function PlannerFactorySelector.methods:updateModulesInfo(item)
	local recipe = self.model.recipes[item]
	local factory = recipe.factory

	for k,guiName in pairs(self.guiModule.children_names) do
		self.guiModule[guiName].destroy()
	end
	local guiModuleTable = self:addGuiTable(self.guiModule,"modules",9)
	for k, module in pairs(self.player:getModules()) do
		local count = 0
		if factory.modules[module.name] ~= nil then count = factory.modules[module.name] end
		self:addIconButton(guiModuleTable, self:classname().."_module_ID_"..recipe.name.."_", module.type, module.name, count)
		self:addGuiButton(guiModuleTable, self:classname().."_module-add_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "+")
		self:addGuiButton(guiModuleTable, self:classname().."_module-remove_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "-")
	end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#PlannerFactorySelector] updateSelector
-- 
-- @param #string item item name
-- 
function PlannerFactorySelector.methods:updateSelector(item)
	local recipe = self.model.recipes[item]
	if self.guiGroups ~= nil and self.guiGroups.valid then
		self.guiGroups.destroy()
	end

	-- ajouter de la table des groupes de recipe
	self.guiGroups = self:addGuiTable(self.guiSelector, "factory-groups", 5)
	for group, name in pairs(self.player:getProductionGroups(recipe.category)) do
		-- set le groupe
		if self.factoryGroupSelected == nil then self.factoryGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addItemButton(self.guiGroups, self:classname().."_factory-group_ID_"..recipe.name.."_", group)
	end

	if self.guiTableSelector ~= nil and self.guiTableSelector.valid then
		self.guiTableSelector.destroy()
	end

	self.guiTableSelector = self:addGuiTable(self.guiSelector, "factory-table", 10)
	--Logging:debug("factories:",self.player:getProductions())
	for key, factory in pairs(self.player:getProductions()) do
		if factory.type == self.factoryGroupSelected then
			self:addSpriteIconButton(self.guiTableSelector, self:classname().."_factory-select_ID_"..recipe.name.."_", "item", factory.name, true)
		end
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerFactorySelector] on_event
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerFactorySelector.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "factory-group" then
		self.factoryGroupSelected = item2
		self:updateSelector(item)
	end

	if action == "factory-select" then
		--element.state = true
		-- item=recipe item2=factory
		self.model:setFactory(item, item2)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

	if action == "factory-update" then
		local options = {}
		if self.guiInputs["energy-nominal"] ~= nil then
			options["energy_nominal"] = self:getInputNumber(self.guiInputs["energy-nominal"])
		end

		if self.guiInputs["speed-nominal"] ~= nil then
			options["speed_nominal"] = self:getInputNumber(self.guiInputs["speed-nominal"])
		end

		if self.guiInputs["module-slots"] ~= nil then
			options["module_slots"] = self:getInputNumber(self.guiInputs["module-slots"])
		end

		self.model:updateFactory(item, options)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

	if action == "module-add" then
		self.model:addFactoryModule(item, item2)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

	if action == "module-remove" then
		self.model:removeFactoryModule(item, item2)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

end