PlannerBeaconSelector = setclass("HMPlannerBeaconSelector", PlannerDialog)

function PlannerBeaconSelector.methods:on_init(parent)
	self.panelCaption = "Beacon"
	self.player = self.parent.parent
	self.model = self.parent.model
end

--===========================
function PlannerBeaconSelector.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiBeaconLast == nil or self.guiBeaconLast ~= item then
		close = false
		self.beaconGroupSelected = nil
	end
	self.guiBeaconLast = item
	return close
end

--===========================
function PlannerBeaconSelector.methods:on_close(element, action, item, item2)
	self.beaconGroupSelected = nil
	self.guiBeaconLast = nil
end

--===========================
function PlannerBeaconSelector.methods:after_open(element, action, item, item2)
	self.guiSelector = self:addGuiFrameV(self.gui, "selector")
	self.guiData = self:addGuiFrameV(self.gui, "data")
	self.guiModule = self:addGuiFrameV(self.gui, "module", nil, "Modules")
end

--===========================
function PlannerBeaconSelector.methods:on_update(element, action, item, item2)
	self:updateSelector(item)
	self:updateInfo(item)
	self:updateModulesInfo(item)
end

--===========================
function PlannerBeaconSelector.methods:updateInfo(item)
	local recipe = self.model.recipes[item]
	if recipe ~= nil then
		local beacon = recipe.beacon

		for k,guiName in pairs(self.guiData.children_names) do
		self.guiData[guiName].destroy()
	end
	
	self:addIconButton(self.guiData, "icon", beacon.type, beacon.name)
	local guiTable = self:addGuiTable(self.guiData,"table",2)

	self:addGuiLabel(guiTable, "label-energy-nominal", "Nominal energy")
	self.guiInputs["energy-nominal"] = self:addGuiText(guiTable, "energy-nominal", beacon.energy_nominal)
	self:addGuiLabel(guiTable, "label-combo", "Combo")
	self.guiInputs["combo"] = self:addGuiText(guiTable, "combo", beacon.combo)
	self:addGuiLabel(guiTable, "label-factory", "Factory")
	self.guiInputs["factory"] = self:addGuiText(guiTable, "factory", beacon.factory)
	self:addGuiLabel(guiTable, "label-efficiency", "Efficiency")
	self.guiInputs["efficiency"] = self:addGuiText(guiTable, "efficiency", beacon.efficiency)
	self:addGuiLabel(guiTable, "label-module-slots", "Module Slots")
	self.guiInputs["module-slots"] = self:addGuiText(guiTable, "module-slots", beacon.module_slots)

	self:addGuiButton(self.guiData, self:classname().."_beacon-update_ID_", recipe.name, "helmod_button-default", "Update")
	end
end

--===========================
function PlannerBeaconSelector.methods:updateModulesInfo(item)
	local recipe = self.model.recipes[item]
	local beacon = recipe.beacon

	for k,guiName in pairs(self.guiModule.children_names) do
		self.guiModule[guiName].destroy()
	end
	local guiTable = self:addGuiTable(self.guiModule,"modules",9)
	for k, module in pairs(self.player:getModules()) do
		local count = 0
		if beacon.modules[module.name] ~= nil then count = beacon.modules[module.name] end
		self:addIconButton(guiTable, self:classname().."_module_ID_"..recipe.name.."_", module.type, module.name, count)
		self:addGuiButton(guiTable, self:classname().."_module-add_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "+")
		self:addGuiButton(guiTable, self:classname().."_module-remove_ID_"..recipe.name.."_", module.name, "helmod_button-small-bold", "-")
	end
end

--===========================
function PlannerBeaconSelector.methods:updateSelector(item)
	local recipe = self.model.recipes[item]
	Logging:debug("beacon recipe:",recipe)
	if self.guiGroups == nil then
		-- ajouter de la table des groupes de recipe
		self.guiGroups = self:addGuiTable(self.guiSelector, "beacon-groups", 5)
		for group, name in pairs(self.player:getProductionGroups("module")) do
			-- set le groupe
			if self.beaconGroupSelected == nil then self.beaconGroupSelected = group end
			-- ajoute les icons de groupe
			local action = self:addItemButton(self.guiGroups, self:classname().."_beacon-group_ID_", group)
		end
	end

	if self.guiTableSelector ~= nil and self.guiTableSelector.valid then
		self.guiTableSelector.destroy()
	end

	self.guiTableSelector = self:addGuiTable(self.guiSelector, "beacon-table", 10)
	Logging:debug("factories:",self.player:getProductions())
	for key, beacon in pairs(self.player:getProductions()) do
		if beacon.type == self.beaconGroupSelected then
			self:addIconCheckbox(self.guiTableSelector, self:classname().."_beacon-select_ID_"..recipe.name.."_", "item", beacon.name, true)
		end
	end
end

--===========================
function PlannerBeaconSelector.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "OPEN" then
		element.state = true
	end
	if action == "beacon-group" then
		self.beaconGroupSelected = item
		self:updateSelector(item)
	end

	if action == "beacon-select" then
		element.state = true
		-- item=recipe item2=factory
		self.model:setBeacon(item, item2)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

	if action == "beacon-update" then
		local options = {}
		if self.guiInputs["energy-nominal"] ~= nil then
			options["energy_nominal"] = self:getInputNumber(self.guiInputs["energy-nominal"])
		end

		if self.guiInputs["combo"] ~= nil then
			options["combo"] = self:getInputNumber(self.guiInputs["combo"])
		end

		if self.guiInputs["factory"] ~= nil then
			options["factory"] = self:getInputNumber(self.guiInputs["factory"])
		end

		if self.guiInputs["efficiency"] ~= nil then
			options["efficiency"] = self:getInputNumber(self.guiInputs["efficiency"])
		end

		if self.guiInputs["module-slots"] ~= nil then
			options["module_slots"] = self:getInputNumber(self.guiInputs["module-slots"])
		end

		self.model:updateBeacon(item, options)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

	if action == "module-add" then
		self.model:addBeaconModule(item, item2)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

	if action == "module-remove" then
		self.model:removeBeaconModule(item, item2)
		self.model:update()
		self:updateInfo(item)
		self:updateModulesInfo(item)
		self.parent:refreshDisplayData()
	end

end





















