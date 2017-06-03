-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module PinPanel
-- @extends #Dialog
--

PinPanel = setclass("HMPinPanel", Dialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PinPanel] on_init
--
-- @param #Controller parent parent controller
--
function PinPanel.methods:on_init(parent)
	self.panelCaption = ({"helmod_pin-tab-panel.title"})
	self.player = self.parent.player
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PinPanel] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PinPanel.methods:getParentPanel(player)
	return self.parent:getPinTabPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PinPanel] on_open
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function PinPanel.methods:on_open(player, event, action, item, item2, item3)
	local globalGui = self.player:getGlobalGui(player)
	local close = true
	if globalGui.pinBlock == nil or globalGui.pinBlock ~= item then
		close = false
	end
	globalGui.pinBlock = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PinPanel] on_close
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:on_close(player, event, action, item, item2, item3)
	local globalGui = self.player:getGlobalGui(player)
	globalGui.pinBlock = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PinPanel] getInfoPanel
--
-- @param #LuaPlayer player
--
function PinPanel.methods:getInfoPanel(player)
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
-- @function [parent=#PinPanel] getHeaderPanel
--
-- @param #LuaPlayer player
--
function PinPanel.methods:getHeaderPanel(player)
	local panel = self:getPanel(player)
	if panel["header"] ~= nil and panel["header"].valid then
		return panel["header"]
	end
	return self:addGuiFrameV(panel, "header", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PinPanel] after_open
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:after_open(player, event, action, item, item2, item3)
	self:updateHeader(player, event, action, item, item2, item3)
	self:getInfoPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PinPanel] on_update
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:on_update(player, event, action, item, item2, item3)
	self:updateInfo(player, event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PinPanel] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:updateHeader(player, event, action, item, item2, item3)
	Logging:debug(self:classname(), "updateHeader():", action, item, item2, item3)
	local headerPanel = self:getHeaderPanel(player)
	local model = self.model:getModel(player)

	local settingsTable = self:addGuiTable(headerPanel, "settings", 2)

	self:addGuiButton(settingsTable, self:classname().."=CLOSE", nil, "helmod_button_default", ({"helmod_button.close"}))
	self:addGuiLabel(settingsTable, "blank_1", "")

	local display_pin_beacon = self.player:getGlobalSettings(player,"display_pin_beacon")
	self:addGuiLabel(settingsTable, self:classname().."=display_pin_beacon", ({"helmod_settings-panel.display-pin-beacon"}))
	self:addGuiCheckbox(settingsTable, self:classname().."=change-boolean-settings=ID=display_pin_beacon", display_pin_beacon)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PinPanel] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:updateInfo(player, event, action, item, item2, item3)
	Logging:debug(self:classname(), "updateInfo():", action, item, item2, item3)
	local infoPanel = self:getInfoPanel(player)
	local model = self.model:getModel(player)
	local globalGui = self.player:getGlobalGui(player)

	for k,guiName in pairs(infoPanel.children_names) do
		infoPanel[guiName].destroy()
	end

	local column = 4
	local display_pin_beacon = self.player:getGlobalSettings(player,"display_pin_beacon")
	if display_pin_beacon == true then column = column + 1 end

	if globalGui.pinBlock ~= nil and model.blocks[globalGui.pinBlock] ~= nil then
		local block = model.blocks[globalGui.pinBlock]

		local resultTable = self:addGuiTable(infoPanel,"list-data",column, "helmod_table-odd")

		self:addProductionBlockHeader(player, resultTable)
		for _, recipe in spairs(block.recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
			self:addProductionBlockRow(player, resultTable, globalGui.pinBlock, recipe)
		end

	end
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PinPanel] addProductionBlockHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PinPanel.methods:addProductionBlockHeader(player, itable)
	Logging:debug(self:classname(), "addProductionBlockHeader():", player, itable)
	local model = self.model:getModel(player)

	local guiRecipe = self:addGuiFlowH(itable,"header-recipe")
	self:addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))

	local guiProducts = self:addGuiFlowH(itable,"header-products")
	self:addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-products"}))

	local guiFactory = self:addGuiFlowH(itable,"header-factory")
	self:addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))

	local guiIngredients = self:addGuiFlowH(itable,"header-ingredients")
	self:addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))

	local display_pin_beacon = self.player:getGlobalSettings(player,"display_pin_beacon")
	if display_pin_beacon == true then
		local guiBeacon = self:addGuiFlowH(itable,"header-beacon")
		self:addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
	end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PinPanel] addProductionBlockRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #string blockId
-- @param #table element production recipe
--
function PinPanel.methods:addProductionBlockRow(player, guiTable, blockId, recipe)
	Logging:debug(self:classname(), "addProductionBlockRow():", player, guiTable, blockId, recipe)
	local model = self.model:getModel(player)

	-- col recipe
	local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..recipe.id, "helmod_flow_default")
	self:addGuiButtonSprite(guiRecipe, "PinPanel_recipe_"..blockId.."=", self.player:getRecipeIconType(player, recipe), recipe.name, recipe.name, self.player:getRecipeLocalisedName(player, recipe))

	-- products
	local tProducts = self:addGuiTable(guiTable,"products_"..recipe.id, 3)
	if recipe.products ~= nil then
		for r, product in pairs(recipe.products) do
			local cell = self:addGuiFlowH(tProducts,"cell_"..product.name, "helmod_flow_default")
			local amount = self.model:getElementAmount(product)
			self:addGuiLabel(cell, product.name, amount, "helmod_label_sm")
			-- product = {type="item", name="steel-plate", amount=8}
			self:addGuiButtonSpriteSm(cell, self:classname().."=do_noting=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(product), product.name, "X"..amount, self.player:getLocalisedName(player, product))
		end
	end

	-- col factory
	local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.id, "helmod_flow_default")
	local factory = recipe.factory
	self:addGuiLabel(guiFactory, factory.name, self:formatNumberFactory(factory.limit_count), "helmod_label_right_30")
	self:addGuiButtonSprite(guiFactory, "PinPanel_recipe_"..blockId.."="..recipe.name.."=", self.player:getIconType(factory), factory.name, factory.name, self.player:getLocalisedName(player, factory))
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
				self:addGuiButtonSpriteSm(guiFactoryModule, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
			else
				self:addGuiButtonSpriteSm(guiFactoryModule, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name)
			end
			index = index + 1
		end
	end

	-- ingredients
	local tIngredient = self:addGuiTable(guiTable,"ingredients_"..recipe.id, 3)
	if recipe.ingredients ~= nil then
		for r, ingredient in pairs(recipe.ingredients) do
			local cell = self:addGuiFlowH(tIngredient,"cell_"..ingredient.name, "helmod_flow_default")
			local amount = self.model:getElementAmount(ingredient)
			self:addGuiLabel(cell, ingredient.name, amount, "helmod_label_sm")
			-- ingredient = {type="item", name="steel-plate", amount=8}
			self:addGuiButtonSpriteSm(cell, self:classname().."=do_noting=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(ingredient), ingredient.name, "X"..amount, self.player:getLocalisedName(player, ingredient))
		end
	end

	local display_pin_beacon = self.player:getGlobalSettings(player,"display_pin_beacon")
	if display_pin_beacon == true then
		-- col beacon
		local guiBeacon = self:addGuiFlowH(guiTable,"beacon"..recipe.id, "helmod_flow_default")
		local beacon = recipe.beacon
		self:addGuiLabel(guiBeacon, beacon.name, self:formatNumberFactory(beacon.limit_count), "helmod_label_right_30")
		self:addGuiButtonSprite(guiBeacon, "PinPanel_recipe_"..blockId.."="..recipe.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, self.player:getLocalisedName(player, beacon))
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
					self:addGuiButtonSpriteSm(guiBeaconModule, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
				else
					self:addGuiButtonSpriteSm(guiBeaconModule, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name)
				end
				index = index + 1
			end
		end
	end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PinPanel] on_event
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:on_event(player, event, action, item, item2, item3)
	Logging:debug(self:classname(), "on_event():", action, item, item2, item3)
	local model = self.model:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")
	local defaultSettings = self.player:getDefaultSettings()
  local globalGui = self.player:getGlobalGui(player)

	if action == "change-boolean-settings" then
		if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
		globalSettings[item] = not(globalSettings[item])
		self:updateInfo(player, event, action, globalGui.pinBlock, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Format number for factory
--
-- @function [parent=#PinPanel] formatNumberFactory
--
-- @param #number number
--
function PinPanel.methods:formatNumberFactory(number)
  local decimal = 2
  local format_number = self.player:getSettings(nil, "format_number_factory", true)
  if format_number == "0" then decimal = 0 end
  if format_number == "0.0" then decimal = 1 end
  if format_number == "0.00" then decimal = 2 end
  return self:formatNumber(number, decimal)
end