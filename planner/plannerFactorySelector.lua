PlannerFactorySelector = setclass("HMPlannerFactorySelector", PlannerDialog)

function PlannerFactorySelector.methods:on_init(parent)
	self.panelCaption = "Factory"
	self.player = self.parent.parent
	self.model = self.parent.model
end

--===========================
function PlannerFactorySelector.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiFactoryLast == nil or self.guiFactoryLast ~= item then
		close = false
		self.factoryGroupSelected = nil
	end
	self.guiFactoryLast = item
	return close
end

--===========================
function PlannerFactorySelector.methods:on_close(element, action, item, item2)
	self.factoryGroupSelected = nil
	self.guiFactoryLast = nil
end

--===========================
function PlannerFactorySelector.methods:after_open(element, action, item, item2)
	self.guiFactorySelector = self:addGuiFrameV(self.gui, "selector")
	self.guiFactoryData = self:addGuiFrameV(self.gui, "data")
	self.guiFactoryModule = self:addGuiFrameV(self.gui, "module", nil, "Modules")
end

--===========================
function PlannerFactorySelector.methods:on_update(element, action, item, item2)
	self:updateSelector(item)
	self:updateInfo(item)
	self:updateModulesInfo(item)
end

--===========================
function PlannerFactorySelector.methods:updateInfo(item)
	local recipe = self.model.recipes[item]
	if recipe ~= nil then
		local factory = recipe.factory

		for k,guiName in pairs(self.guiFactoryData.children_names) do
			self.guiFactoryData[guiName].destroy()
		end

		local guiTableHeader = self:addGuiTable(self.guiFactoryData,"table-header",2)
		self:addIconButton(guiTableHeader, "icon", factory.type, factory.name)
		self:addGuiLabel(guiTableHeader, "label", factory.name)
		
		local guiTableInput = self:addGuiTable(self.guiFactoryData,"table",2)

		self:addGuiLabel(guiTableInput, "label-energy-nominal", "Energy nominal")
		self.guiInputs["energy-nominal"] = self:addGuiText(guiTableInput, "energy-nominal", factory.energy_nominal)
		self:addGuiLabel(guiTableInput, "label-speed-nominal", "Speed nominal")
		self.guiInputs["speed-nominal"] = self:addGuiText(guiTableInput, "speed-nominal", factory.speed_nominal)
		self:addGuiLabel(guiTableInput, "label-module-slots", "Module Slots")
		self.guiInputs["module-slots"] = self:addGuiText(guiTableInput, "module-slots", factory.module_slots)

		self:addGuiButton(self.guiFactoryData, self:classname().."_factory-update_ID_", recipe.name, "helmod_button-default", "Update")
	end
end

--===========================
function PlannerFactorySelector.methods:updateModulesInfo(item)
	local recipe = self.model.recipes[item]
	local factory = recipe.factory

	for k,guiName in pairs(self.guiFactoryModule.children_names) do
		self.guiFactoryModule[guiName].destroy()
	end
	local guiModuleTable = self:addGuiTable(self.guiFactoryModule,"modules",9)
	for k, module in pairs(self.player:getModules()) do
		local count = 0
		if factory.modules[module.name] ~= nil then count = factory.modules[module.name] end
		self:addIconButton(guiModuleTable, self:classname().."_module_ID_"..recipe.name.."_", module.type, module.name, count)
		self:addGuiButton(guiModuleTable, self:classname().."_module-add_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "+")
		self:addGuiButton(guiModuleTable, self:classname().."_module-remove_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "-")
	end
end

--===========================
function PlannerFactorySelector.methods:updateSelector(item)
	local recipe = self.model.recipes[item]
	if self.guiFactoryGroups ~= nil and self.guiFactoryGroups.valid then
		self.guiFactoryGroups.destroy()
	end

	-- ajouter de la table des groupes de recipe
	self.guiFactoryGroups = self:addGuiTable(self.guiFactorySelector, "factory-groups", 5)
	for group, name in pairs(self.player:getProductionGroups(recipe.category)) do
		-- set le groupe
		if self.factoryGroupSelected == nil then self.factoryGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addItemButton(self.guiFactoryGroups, self:classname().."_factory-group_ID_", group)
	end

	if self.guiFactoryTableSelector ~= nil and self.guiFactoryTableSelector.valid then
		self.guiFactoryTableSelector.destroy()
	end

	self.guiFactoryTableSelector = self:addGuiTable(self.guiFactorySelector, "factory-table", 10)
	Logging:debug("factories:",self.player:getProductions())
	for key, factory in pairs(self.player:getProductions()) do
		if factory.type == self.factoryGroupSelected then
			self:addIconCheckbox(self.guiFactoryTableSelector, self:classname().."_factory-select_ID_"..recipe.name.."_", "item", factory.name, true)
		end
	end
end

--===========================
function PlannerFactorySelector.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "OPEN" then
		element.state = true
	end
	if action == "factory-group" then
		self.factoryGroupSelected = item
		self:updateSelector(item)
	end

	if action == "factory-select" then
		element.state = true
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