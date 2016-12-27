-------------------------------------------------------------------------------
-- Classe to build pin tab dialog
--
-- @module PlannerPinTab
-- @extends #PlannerDialog
--

PlannerPinTab = setclass("HMPlannerPinTab", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerPinTab] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerPinTab.methods:on_init(parent)
	self.panelCaption = ({"helmod_pin-tab-panel.title"})
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerPinTab] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerPinTab.methods:getParentPanel(player)
	return self.parent:getPinTabPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerPinTab] on_open
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
function PlannerPinTab.methods:on_open(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	local close = true
	if model.guiPinBlock == nil or model.guiPinBlock ~= item then
		close = false
	end
	model.guiPinBlock = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerPinTab] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerPinTab.methods:on_close(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	model.guiPinBlock = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerPinTab] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerPinTab.methods:getInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info-panel"] ~= nil and panel["info-panel"].valid then
		return panel["info-panel"]["scroll-panel"]
	end
	local mainPanel = self:addGuiFrameV(panel, "info-panel", "helmod_frame_resize_row_width")
	return self:addGuiScrollPane(mainPanel, "scroll-panel", "helmod_scroll_block_pin_tab", "auto", "auto")
end

-------------------------------------------------------------------------------
-- Get or create header panel
--
-- @function [parent=#PlannerPinTab] getHeaderPanel
--
-- @param #LuaPlayer player
--
function PlannerPinTab.methods:getHeaderPanel(player)
	local panel = self:getPanel(player)
	if panel["header"] ~= nil and panel["header"].valid then
		return panel["header"]
	end
	return self:addGuiFrameV(panel, "header", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerPinTab] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerPinTab.methods:after_open(player, element, action, item, item2, item3)
	self:updateHeader(player, element, action, item, item2, item3)
	self:getInfoPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerPinTab] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerPinTab.methods:on_update(player, element, action, item, item2, item3)
	self:updateInfo(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerPinTab] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerPinTab.methods:updateHeader(player, element, action, item, item2, item3)
	Logging:debug("PlannerPinTab:updateHeader():",player, element, action, item, item2, item3)
	local headerPanel = self:getHeaderPanel(player)
	local model = self.model:getModel(player)

	self:addGuiButton(headerPanel, self:classname().."=CLOSE", nil, "helmod_button-default", ({"helmod_button.close"}))
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerPinTab] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerPinTab.methods:updateInfo(player, element, action, item, item2, item3)
	Logging:debug("PlannerPinTab:updateInfo():",player, element, action, item, item2, item3)
	local infoPanel = self:getInfoPanel(player)
	local model = self.model:getModel(player)

	for k,guiName in pairs(infoPanel.children_names) do
		infoPanel[guiName].destroy()
	end

	if model.guiPinBlock ~= nil and model.blocks[model.guiPinBlock] ~= nil then
		local block = model.blocks[model.guiPinBlock]

		local resultTable = self:addGuiTable(infoPanel,"list-data",3, "helmod_table-odd")

		for _, recipe in pairs(block.recipes) do
			self:addProductionBlockRow(player, resultTable, model.guiPinBlock, recipe)
		end

	end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PlannerResult] addProductionBlockRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #string blockId
-- @param #table element production recipe
--
function PlannerPinTab.methods:addProductionBlockRow(player, guiTable, blockId, recipe)
	Logging:debug("PlannerPinTab:addProductionBlockRow():", player, guiTable, blockId, recipe)
	local model = self.model:getModel(player)

	local globalSettings = self.player:getGlobal(player, "settings")

	-- col recipe
	local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..recipe.name, "helmod_flow_default")
	self:addSpriteIconButton(guiRecipe, "PlannerPinTab_recipe_"..blockId.."=", self.player:getRecipeIconType(player, recipe), recipe.name, recipe.name, self.player:getRecipeLocalisedName(player, recipe))

	-- col factory
	local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.name, "helmod_flow_default")
	local factory = recipe.factory
	self:addGuiLabel(guiFactory, factory.name, self:formatNumber(factory.limit_count).."/"..self:formatNumber(factory.count), "helmod_label-right-70")
	self:addSpriteIconButton(guiFactory, "PlannerPinTab_recipe_"..blockId.."="..recipe.name.."=", self.player:getIconType(factory), factory.name, factory.name, self.player:getLocalisedName(player, factory))
	local guiFactoryModule = self:addGuiTable(guiFactory,"factory-modules"..recipe.name, 2, "helmod_factory_modules")
	-- modules
	for name, count in pairs(factory.modules) do
		for index = 1, count, 1 do
			local module = self.player:getItemPrototype(name)
			if module ~= nil then
				local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
				local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
				local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
				local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
				local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
				self:addSmSpriteButton(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
			else
				self:addSmSpriteButton(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name)
			end
			index = index + 1
		end
	end

	-- col beacon
	local guiBeacon = self:addGuiFlowH(guiTable,"beacon"..recipe.name, "helmod_flow_default")
	local beacon = recipe.beacon
	self:addGuiLabel(guiBeacon, beacon.name, self:formatNumber(beacon.limit_count).."/"..self:formatNumber(beacon.count), "helmod_label-right-70")
	self:addSpriteIconButton(guiBeacon, "PlannerPinTab_recipe_"..blockId.."="..recipe.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, self.player:getLocalisedName(player, beacon))
	local guiBeaconModule = self:addGuiTable(guiBeacon,"beacon-modules"..recipe.name, 1, "helmod_beacon_modules")
	-- modules
	for name, count in pairs(beacon.modules) do
		for index = 1, count, 1 do
			local module = self.player:getItemPrototype(name)
			if module ~= nil then
				local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
				local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
				local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
				local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
				local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
				self:addSmSpriteButton(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
			else
				self:addSmSpriteButton(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name)
			end
			index = index + 1
		end
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerPinTab] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerPinTab.methods:on_event(player, element, action, item, item2, item3)
	Logging:debug("PlannerPinTab:on_event():",player, element, action, item, item2, item3)

	if action == "product-update" then
		local products = {}
		local inputPanel = self:getInfoPanel(player)["table-header"]

		local quantity = self:getInputNumber(inputPanel["quantity"])

		self.model:updateProduct(player, item, item2, quantity)
		self.model:update(player)
		self.parent:refreshDisplayData(player, nil, item, item2)
		self:close(player)
	end
end
