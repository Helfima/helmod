-------------------------------------------------------------------------------
-- Classe to build result dialog
--
-- @module PlannerResult
-- @extends #ElementGui
--

PlannerResult = setclass("HMPlannerResult", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlannerResult] init
--
-- @param #PlannerController parent parent controller
--
function PlannerResult.methods:init(parent)
	self.parent = parent
	self.player = self.parent.parent
	self.model = self.parent.model

	self.PRODUCTION_BLOCK_TAB = "product-block"
	self.PRODUCTION_LINE_TAB = "product-line"
	self.SUMMARY_TAB = "summary"
	self.RESOURCES_TAB = "resources"
	
	self.sectionItemStyle1 = "helmod_block-item-section-frame1"
	self.scrollItemStyle1 = "helmod_block-item-scroll1"
	
	self.sectionItemStyle2 = "helmod_block-item-section-frame2"
	self.scrollItemStyle2 = "helmod_block-item-scroll2"
	
	self.scrollDataStyle = "helmod_block-list-scroll"
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerResult] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerResult.methods:getParentPanel(player)
	return self.parent:getDataPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#PlannerResult] getDataPanel
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:getDataPanel(player)
	local parentPanel = self:getParentPanel(player)
	if parentPanel["data"] ~= nil and parentPanel["data"].valid then
		return parentPanel["data"]
	end
	return self:addGuiFlowV(parentPanel, "data")
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#PlannerResult] getResultPanel
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:getResultPanel(player, caption)
	local dataPanel = self:getDataPanel(player)
	if dataPanel["result"] ~= nil and dataPanel["result"].valid then
		return dataPanel["result"]
	end
	return self:addGuiFrameV(dataPanel, "result", "helmod_result", caption)
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#PlannerResult] getSelectorPanel
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:getSelectorPanel(player)
	local menuPanel = self.parent:getMenuPanel(player)
	if menuPanel["selector"] ~= nil and menuPanel["selector"].valid then
		return menuPanel["selector"]
	end
	return self:addGuiFlowH(menuPanel, "selector")
end

-------------------------------------------------------------------------------
-- Build the parent panel
--
-- @function [parent=#PlannerResult] buildPanel
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:buildPanel(player)
	Logging:debug("PlannerResult:buildPanel():",player)

	local model = self.model:getModel(player)
	model.page = 0
	model.step = 15
	model.currentTab = self.PRODUCTION_LINE_TAB

	Logging:debug("test version:", model.version, helmod.version)
	if model.version == nil or model.version ~= helmod.version then
		self.model:update(player, true)
	end

	model.order = {name="index", ascendant=true}

	local parentPanel = self:getParentPanel(player)

	if parentPanel ~= nil then
		local selectorPanel = self:getSelectorPanel(player)
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_LINE_TAB, "helmod_button-default", ({"helmod_result-panel.tab-button-production-line"}))
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.SUMMARY_TAB, "helmod_button-default", ({"helmod_result-panel.tab-button-summary"}))
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.RESOURCES_TAB, "helmod_button-default", ({"helmod_result-panel.tab-button-resources"}))

		self:getDataPanel(player)

		self:update(player)
	end
end

-------------------------------------------------------------------------------
-- On gui click
--
-- @function [parent=#PlannerResult] on_gui_click
--
-- @param #table event
-- @param #string label displayed text
--
function PlannerResult.methods:on_gui_click(event)
	Logging:debug("PlannerResult:on_gui_click():",event)
	if event.element.valid and string.find(event.element.name, self:classname()) then
		local player = game.players[event.player_index]

		local patternAction = self:classname().."=([^=]*)"
		local patternItem = self:classname()..".*=ID=([^=]*)"
		local patternItem2 = self:classname()..".*=ID=[^=]*=([^=]*)"
		local patternItem3 = self:classname()..".*=ID=[^=]*=[^=]*=([^=]*)"
		local action = string.match(event.element.name,patternAction,1)
		local item = string.match(event.element.name,patternItem,1)
		local item2 = string.match(event.element.name,patternItem2,1)
		local item3 = string.match(event.element.name,patternItem3,1)

		self:send_event(player, event.element, action, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Send event
--
-- @function [parent=#PlannerResult] send_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerResult.methods:send_event(player, element, action, item, item2, item3)
		Logging:debug("PlannerDialog:send_event():",player, element, action, item, item2, item3)
		self:on_event(player, element, action, item, item2, item3)
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerResult] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResult.methods:on_event(player, element, action, item, item2, item3)
	Logging:debug("PlannerResult:on_event():",player, element, action, item, item2, item3)
	local model = self.model:getModel(player)

	if action == "change-tab" then
		model.currentTab = item
		model.page = 0
		self:update(player, item, item2, item3)
		self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
	end

	if action == "change-page" then
		self:updatePage(player, item, item2, item3)
		self:update(player, nil, item, item3)
	end

	if action == "change-sort" then
		if model.order.name == item then
			model.order.ascendant = not(model.order.ascendant)
		else
			model.order = {name=item, ascendant=true}
		end
		self:update(player, item, item2, item3)
	end

	if action == "production-block-add" then
		if model.currentTab == self.PRODUCTION_LINE_TAB then
			local recipes = self.player:searchRecipe(player, item2)
			Logging:debug("line recipes:",recipes)
			if #recipes == 1 then
				local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, "new", recipes[1].name)
				self.parent.model:update(player)
				model.currentTab = self.PRODUCTION_BLOCK_TAB
				self:update(player, self.PRODUCTION_BLOCK_TAB, productionBlock.id, recipes[1].name)
			else
				model.currentTab = self.PRODUCTION_BLOCK_TAB
				self.parent:send_event(player, "HMPlannerRecipeSelector", "OPEN", "new")
			end
		end
	end

	if action == "production-block-remove" then
		if model.currentTab == self.PRODUCTION_LINE_TAB then
			self.parent.model:removeProductionBlock(player, item)
			self.parent.model:update(player)
			self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
		end
	end

	if action == "production-block-up" then
		if model.currentTab == self.PRODUCTION_LINE_TAB then
			self.parent.model:upProductionBlock(player, item)
			self.parent.model:update(player)
			self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
		end
	end

	if action == "production-block-down" then
		if model.currentTab == self.PRODUCTION_LINE_TAB then
			self.parent.model:downProductionBlock(player, item)
			self.parent.model:update(player)
			self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
		end
	end

	if action == "production-recipe-add" then
		if model.currentTab == self.PRODUCTION_BLOCK_TAB then
			local recipes = self.player:searchRecipe(player, item3)
			Logging:debug("block recipes:",recipes)
			if #recipes == 1 then
				Logging:debug("recipe name:", recipes[1].name)
				local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, item, recipes[1].name)
				self.parent.model:update(player)
				self:update(player, self.PRODUCTION_LINE_TAB, productionBlock.id, recipes[1].name)
			else
				self.parent:send_event(player, "HMPlannerRecipeSelector", "OPEN", item)
			end
		end
	end

	if action == "production-recipe-remove" then
		if model.currentTab == self.PRODUCTION_BLOCK_TAB then
			self.parent.model:removeProductionRecipe(player, item, item2)
			self.parent.model:update(player)
			self:update(player, self.PRODUCTION_BLOCK_TAB, item, item2, item3)
		end
	end

	if action == "production-recipe-up" then
		if model.currentTab == self.PRODUCTION_BLOCK_TAB then
			self.parent.model:upProductionRecipe(player, item, item2)
			self.parent.model:update(player)
			self:update(player, self.PRODUCTION_BLOCK_TAB, item, item2, item3)
		end
	end

	if action == "production-recipe-down" then
		if model.currentTab == self.PRODUCTION_BLOCK_TAB then
			self.parent.model:downProductionRecipe(player, item, item2)
			self.parent.model:update(player)
			self:update(player, self.PRODUCTION_BLOCK_TAB, item, item2, item3)
		end
	end
end

-------------------------------------------------------------------------------
-- Update page
--
-- @function [parent=#PlannerResult] updatePage
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResult.methods:updatePage(player, item, item2, item3)
	Logging:debug("PlannerResult:updatePage():",item, item2, item3)
	local model = self.model:getModel(player)
	if item2 == "down" then
		if model.page > 0 then
			model.page = model.page - 1
		end
	end
	if item2 == "up" then
		if model.page < model.maxPage then
			model.page = model.page + 1
		end
	end
	if item2 == "direct" then
		model.page = tonumber(item3)
	end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerResult] update
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResult.methods:update(player, item, item2, item3)
	Logging:debug("PlannerResult:update():", player, item, item2, item3)
	local model = self.model:getModel(player)

	if self:getResultPanel(player) ~= nil then
		self:getResultPanel(player).destroy()
	end

	if model.currentTab == self.PRODUCTION_LINE_TAB then
		self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
		self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
		self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
		self:updateProductionLine(player, item, item2, item3)
	end
	if model.currentTab == self.PRODUCTION_BLOCK_TAB then
		self:updateProductionBlock(player, item, item2, item3)
	end
	if model.currentTab == self.SUMMARY_TAB then
		self:updateSummary(player, item, item2, item3)
	end
	if model.currentTab == self.RESOURCES_TAB then
		self:updateResources(player, item, item2, item3)
	end
end

-------------------------------------------------------------------------------
-- Update production line tab
--
-- @function [parent=#PlannerResult] updateProductionLine
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResult.methods:updateProductionLine(player, item, item2, item3)
	Logging:debug("PlannerResult:updateLine():", player, item, item2, item3)
	local model = self.model:getModel(player)
	-- data
	local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-production-line"}))

	local menuPanel = self:addGuiFlowH(resultPanel, "menu-panel", "helmod_result-menu-flow")
	self:addGuiButton(menuPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_BLOCK_TAB, "helmod_button-default", ({"helmod_result-panel.add-button-production-block"}))

	-- production line result
	local countBlock = self.model:countBlocks(player)
	if countBlock > 0 then
		-- data panel
		local dataPanel = self:addGuiFrameV(resultPanel, "data", self.sectionItemStyle, ({"helmod_common.blocks"}))
		local scrollPanel = self:addGuiScrollPane(dataPanel, "scroll-data", self.scrollDataStyle, "auto", "auto")
		
		local globalSettings = self.player:getGlobal(player, "settings")

		local extra_cols = 0
		if globalSettings.display_data_col_name then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_id then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_index then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_level then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_weight then
			extra_cols = extra_cols + 1
		end
		local resultTable = self:addGuiTable(scrollPanel,"list-data",5 + extra_cols, "helmod_table-odd")

		self:addProductionLineHeader(player, resultTable)

		local i = 0
		for _, element in spairs(model.blocks, function(t,a,b) if model.order.ascendant then return t[b][model.order.name] > t[a][model.order.name] else return t[b][model.order.name] < t[a][model.order.name] end end) do
			self:addProductionLineRow(player, resultTable, element)
		end

		for i = 1, 1 + extra_cols, 1 do
			self:addGuiLabel(resultTable, "blank-"..i, "")
		end
		self:addGuiLabel(resultTable, "foot-1", ({"helmod_result-panel.col-header-total"}))
		if model.summary ~= nil then
			self:addGuiLabel(resultTable, "energy", self:formatNumberKilo(model.summary.energy, "W"),"helmod_label-right-70")
		end
		self:addGuiLabel(resultTable, "blank-pro", "")
		self:addGuiLabel(resultTable, "blank-ing", "")
	end
end

-------------------------------------------------------------------------------
-- Update production block tab
--
-- @function [parent=#PlannerResult] updateProductionBlock
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResult.methods:updateProductionBlock(player, item, item2, item3)
	Logging:debug("PlannerResult:updateProductionBlock():", player, item, item2, item3)
	local model = self.model:getModel(player)
	Logging:debug("model:", model)
	-- data
	local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-production-block"}))

	local menuPanel = self:addGuiFlowH(resultPanel, "menu-panel", "helmod_result-menu-flow")
	local blockId = "new"
	if item2 ~= nil then
		blockId = item2
	end
	self:addGuiButton(menuPanel, "HMPlannerRecipeSelector=OPEN=ID=", blockId, "helmod_button-default", ({"helmod_result-panel.add-button-recipe"}))
	self:addGuiButton(menuPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_LINE_TAB, "helmod_button-default", ({"helmod_result-panel.back-button-production-line"}))

	local countRecipes = self.model:countBlockRecipes(player, blockId)
	-- production block result
	if countRecipes > 0 then

		local element = model.blocks[blockId]

		local firstRow = self:addGuiFlowH(resultPanel, "first-row")
		-- info panel
		local blockPanel = self:addGuiFrameV(firstRow, "block", self.sectionItemStyle1, ({"helmod_common.block"}))
		local blockScroll = self:addGuiScrollPane(blockPanel, "block-scroll", self.scrollItemStyle1, "auto", "auto")
		local blockTable = self:addGuiTable(blockScroll,"output-table",4)
		
		self:addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
		if model.summary ~= nil then
			self:addGuiLabel(blockTable, "power", self:formatNumberKilo(element.power, "W"),"helmod_label-right-70")
		end
		
		self:addGuiLabel(blockTable, "label-count", ({"helmod_label.block-number"}))
		if model.summary ~= nil then
			self:addGuiLabel(blockTable, "count", element.count,"helmod_label-right-70")
		end
		
		-- ouput panel
		local outputPanel = self:addGuiFrameV(firstRow, "output", self.sectionItemStyle1, ({"helmod_common.output"}))
		local outputScroll = self:addGuiScrollPane(outputPanel, "output-scroll", self.scrollItemStyle1, "auto", "auto")
		local outputTable = self:addGuiTable(outputScroll,"output-table",4)
		if element.products ~= nil then
			for r, product in pairs(element.products) do
				-- product = {type="item", name="steel-plate", amount=8}
				local cell = self:addGuiFlowH(outputTable,"cell_"..product.name)
				self:addSelectSpriteIconButton(cell, "HMPlannerProductEdition=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..product.amount, nil, ({"tooltip.edit-product"}))
				self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label-right-60")
			end
		end
		
		-- input panel
		local inputPanel = self:addGuiFrameV(resultPanel, "input", self.sectionItemStyle2, ({"helmod_common.input"}))
		local outputScroll = self:addGuiScrollPane(inputPanel, "output-scroll", self.scrollItemStyle2, "auto", "auto")
		local inputTable = self:addGuiTable(outputScroll,"input-table",8)
		if element.ingredients ~= nil then
			for r, ingredient in pairs(element.ingredients) do
				-- ingredient = {type="item", name="steel-plate", amount=8}
				local cell = self:addGuiFlowH(inputTable,"cell_"..ingredient.name)
				self:addSpriteIconButton(cell, "HMPlannerResourceInfo=OPEN=ID="..element.id.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount)
				self:addGuiLabel(cell, ingredient.name, self:formatNumber(ingredient.count), "helmod_label-right-60")
			end
		end

		-- data panel
		local dataPanel = self:addGuiFrameV(resultPanel, "data", self.sectionItemStyle, ({"helmod_common.recipes"}))
		local scrollPanel = self:addGuiScrollPane(dataPanel, "scroll-data", self.scrollDataStyle, "auto", "auto")
		
		local globalSettings = self.player:getGlobal(player, "settings")

		local extra_cols = 0
		if globalSettings.display_data_col_name then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_id then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_index then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_level then
			extra_cols = extra_cols + 1
		end
		if globalSettings.display_data_col_weight then
			extra_cols = extra_cols + 1
		end
		local resultTable = self:addGuiTable(scrollPanel,"list-data",7 + extra_cols, "helmod_table-odd")

		self:addProductionBlockHeader(player, resultTable)

		for _, recipe in spairs(model.blocks[blockId].recipes, function(t,a,b) if model.order.ascendant then return t[b][model.order.name] > t[a][model.order.name] else return t[b][model.order.name] < t[a][model.order.name] end end) do
			self:addProductionBlockRow(player, resultTable, blockId, recipe)
		end
	end
end

-------------------------------------------------------------------------------
-- Add pagination data tab
--
-- @function [parent=#PlannerResult] addPagination
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
-- @param #string blockId
-- @param #number maxPage
--
function PlannerResult.methods:addPagination(player, itable, blockId, maxPage)
	Logging:debug("PlannerResult:addPagination():", player, itable, blockId, maxPage)
	local model = self.model:getModel(player)
	local guiPagination = self:addGuiFlowH(itable,"pagination", "helmod_result-menu-flow")

	self:addGuiButton(guiPagination, self:classname().."=change-page=ID="..blockId.."=", "down", "helmod_button-default", "<")


	for page = 0, maxPage, 1 do
		if page == model.page then
			self:addGuiLabel(guiPagination, self:classname().."=change-page=ID="..blockId.."=", page + 1, "helmod_page-label")
		else
			self:addGuiButton(guiPagination, self:classname().."=change-page=ID="..blockId.."=direct=", page, "helmod_button-default", page + 1)
		end
	end

	self:addGuiButton(guiPagination, self:classname().."=change-page=ID="..blockId.."=", "up", "helmod_button-default", ">")
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PlannerResult] addProductionBlockHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerResult.methods:addProductionBlockHeader(player, itable)
	Logging:debug("PlannerResult:addHeader():", player, itable)
	local model = self.model:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")

	local guiAction = self:addGuiFlowH(itable,"header-action")
	self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

	if globalSettings.display_data_col_index then
		local guiIndex = self:addGuiFlowH(itable,"header-index")
		self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "index" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "index" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", style)
	end
	if globalSettings.display_data_col_level then
		local guiLevel = self:addGuiFlowH(itable,"header-level")
		self:addGuiLabel(guiLevel, "label", ({"helmod_result-panel.col-header-level"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "level" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "level" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiLevel, self:classname().."=change-sort=ID=", "level", style)
	end
	if globalSettings.display_data_col_weight then
		local guiLevel = self:addGuiFlowH(itable,"header-weight")
		self:addGuiLabel(guiLevel, "label", ({"helmod_result-panel.col-header-weight"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "weight" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "weight" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiLevel, self:classname().."=change-sort=ID=", "weight", style)
	end

	if globalSettings.display_data_col_id then
		local guiId = self:addGuiFlowH(itable,"header-id")
		self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "id" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "id" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", style)

	end
	if globalSettings.display_data_col_name then
		local guiName = self:addGuiFlowH(itable,"header-name")
		self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "name" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "name" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", style)

	end

	local guiRecipe = self:addGuiFlowH(itable,"header-recipe")
	self:addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "index" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "index" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiRecipe, self:classname().."=change-sort=ID=", "index", style)

	local guiFactory = self:addGuiFlowH(itable,"header-factory")
	self:addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))


	local guiBeacon = self:addGuiFlowH(itable,"header-beacon")
	self:addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))

	local guiEnergy = self:addGuiFlowH(itable,"header-energy")
	self:addGuiLabel(guiEnergy, "header-energy", ({"helmod_result-panel.col-header-energy"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "energy_total" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "energy_total" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiEnergy, self:classname().."=change-sort=ID=", "energy_total", style)


	local guiProducts = self:addGuiFlowH(itable,"header-products")
	self:addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-products"}))

	local guiIngredients = self:addGuiFlowH(itable,"header-ingredients")
	self:addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PlannerResult] addProductionLineHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerResult.methods:addProductionLineHeader(player, itable)
	Logging:debug("PlannerResult:addHeader():", player, itable)
	local model = self.model:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")

	local guiAction = self:addGuiFlowH(itable,"header-action")
	self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

	if globalSettings.display_data_col_index then
		local guiIndex = self:addGuiFlowH(itable,"header-index")
		self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "index" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "index" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", style)
	end
	if globalSettings.display_data_col_level then
		local guiLevel = self:addGuiFlowH(itable,"header-level")
		self:addGuiLabel(guiLevel, "label", ({"helmod_result-panel.col-header-level"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "level" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "level" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiLevel, self:classname().."=change-sort=ID=", "level", style)
	end
	if globalSettings.display_data_col_weight then
		local guiLevel = self:addGuiFlowH(itable,"header-weight")
		self:addGuiLabel(guiLevel, "label", ({"helmod_result-panel.col-header-weight"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "weight" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "weight" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiLevel, self:classname().."=change-sort=ID=", "weight", style)
	end

	if globalSettings.display_data_col_id then
		local guiId = self:addGuiFlowH(itable,"header-id")
		self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "id" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "id" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", style)

	end
	if globalSettings.display_data_col_name then
		local guiName = self:addGuiFlowH(itable,"header-name")
		self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "name" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "name" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", style)

	end

	local guiRecipe = self:addGuiFlowH(itable,"header-recipe")
	self:addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-production-block"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "index" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "index" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiRecipe, self:classname().."=change-sort=ID=", "index", style)

	--	local guiFactory = self:addGuiFlowH(itable,"header-factory")
	--	self:addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))
	--
	--
	--	local guiBeacon = self:addGuiFlowH(itable,"header-beacon")
	--	self:addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
	--
	local guiEnergy = self:addGuiFlowH(itable,"header-energy")
	self:addGuiLabel(guiEnergy, "header-energy", ({"helmod_result-panel.col-header-energy"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "energy_total" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "energy_total" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiEnergy, self:classname().."=change-sort=ID=", "power", style)


	local guiProducts = self:addGuiFlowH(itable,"header-products")
	self:addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-output"}))

	local guiIngredients = self:addGuiFlowH(itable,"header-ingredients")
	self:addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-input"}))
end

-------------------------------------------------------------------------------
-- Add header resources tab
--
-- @function [parent=#PlannerResult] addResourcesHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerResult.methods:addResourcesHeader(player, itable)
	Logging:debug("PlannerResult:addHeader():", player, itable)
	local model = self.model:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")
	if globalSettings.display_data_col_index then
		local guiIndex = self:addGuiFlowH(itable,"header-index")
		self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "index" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "index" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", style)
	end
	if globalSettings.display_data_col_level then
		local guiLevel = self:addGuiFlowH(itable,"header-level")
		self:addGuiLabel(guiLevel, "label", ({"helmod_result-panel.col-header-level"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "level" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "level" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiLevel, self:classname().."=change-sort=ID=", "level", style)
	end
	if globalSettings.display_data_col_weight then
		local guiLevel = self:addGuiFlowH(itable,"header-weight")
		self:addGuiLabel(guiLevel, "label", ({"helmod_result-panel.col-header-weight"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "weight" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "weight" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiLevel, self:classname().."=change-sort=ID=", "weight", style)
	end

	if globalSettings.display_data_col_id then
		local guiId = self:addGuiFlowH(itable,"header-id")
		self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "id" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "id" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", style)

	end
	if globalSettings.display_data_col_name then
		local guiName = self:addGuiFlowH(itable,"header-name")
		self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
		local style = "helmod_button-sorted-none"
		if model.order.name == "name" and model.order.ascendant then style = "helmod_button-sorted-up" end
		if model.order.name == "name" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
		self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", style)

	end

	local guiIngredient = self:addGuiFlowH(itable,"header-ingredient")
	self:addGuiLabel(guiIngredient, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "index" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "index" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiIngredient, self:classname().."=change-sort=ID=", "index", style)

	local guiCount = self:addGuiFlowH(itable,"header-count")
	self:addGuiLabel(guiCount, "header-count", ({"helmod_result-panel.col-header-total"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "count" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "count" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiCount, self:classname().."=change-sort=ID=", "count", style)

	local guiType = self:addGuiFlowH(itable,"header-type")
	self:addGuiLabel(guiType, "header-type", ({"helmod_result-panel.col-header-type"}))
	local style = "helmod_button-sorted-none"
	if model.order.name == "resource_category" and model.order.ascendant then style = "helmod_button-sorted-up" end
	if model.order.name == "resource_category" and not(model.order.ascendant) then style = "helmod_button-sorted-down" end
	self:addGuiButton(guiType, self:classname().."=change-sort=ID=", "resource_category", style)

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
function PlannerResult.methods:addProductionBlockRow(player, guiTable, blockId, recipe)
	Logging:debug("PlannerResult:addProductionBlockRow():", player, guiTable, blockId, recipe)
	local model = self.model:getModel(player)

	local globalSettings = self.player:getGlobal(player, "settings")

	-- col action
	local guiAction = self:addGuiFlowH(guiTable,"action"..recipe.name)
	if recipe.index ~= 0 then
		self:addGuiButton(guiAction, self:classname().."=production-recipe-remove=ID="..blockId.."=", recipe.name, "helmod_button-default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
		self:addGuiButton(guiAction, self:classname().."=production-recipe-down=ID="..blockId.."=", recipe.name, "helmod_button-default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
	end
	if recipe.index > 1 then
		self:addGuiButton(guiAction, self:classname().."=production-recipe-up=ID="..blockId.."=", recipe.name, "helmod_button-default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
	end
	-- col index
	if globalSettings.display_data_col_index then
		local guiIndex = self:addGuiFlowH(guiTable,"index"..recipe.name)
		self:addGuiLabel(guiIndex, "index", recipe.index, "helmod_label-right-40")
	end
	-- col level
	if globalSettings.display_data_col_level then
		local guiLevel = self:addGuiFlowH(guiTable,"level"..recipe.name)
		self:addGuiLabel(guiLevel, "level", recipe.level)
	end
	-- col weight
	if globalSettings.display_data_col_weight then
		local guiLevel = self:addGuiFlowH(guiTable,"weight"..recipe.name)
		self:addGuiLabel(guiLevel, "weight", recipe.weight)
	end
	-- col id
	if globalSettings.display_data_col_id then
		local guiId = self:addGuiFlowH(guiTable,"id"..recipe.name)
		self:addGuiLabel(guiId, "id", recipe.id)
	end
	-- col name
	if globalSettings.display_data_col_name then
		local guiName = self:addGuiFlowH(guiTable,"name"..recipe.name)
		self:addGuiLabel(guiName, "name", recipe.name)
	end
	-- col recipe
	local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..recipe.name)
	self:addSelectSpriteIconButton(guiRecipe, "HMPlannerRecipeEdition=OPEN=ID="..blockId.."=", self.player:getIconType(recipe), recipe.name, recipe.name, nil, ({"tooltip.edit-recipe"}))

	-- col factory
	local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.name)
	local factory = recipe.factory
	self:addSelectSpriteIconButton(guiFactory, "HMPlannerRecipeEdition=OPEN=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(factory), factory.name, factory.name, nil, ({"tooltip.edit-recipe"}))
	local guiFactoryModule = self:addGuiTable(guiFactory,"factory-modules"..recipe.name, 2, "helmod_factory-modules")
	-- modules
	for name, count in pairs(factory.modules) do
		for index = 1, count, 1 do
			self:addSmSpriteButton(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name)
			index = index + 1
		end
	end
	self:addGuiLabel(guiFactory, factory.name, self:formatNumber(factory.limit_count).."/"..self:formatNumber(factory.count), "helmod_label-right")

	-- col beacon
	local guiBeacon = self:addGuiFlowH(guiTable,"beacon"..recipe.name)
	local beacon = recipe.beacon
	self:addSelectSpriteIconButton(guiBeacon, "HMPlannerRecipeEdition=OPEN=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, nil, ({"tooltip.edit-recipe"}))
	local guiBeaconModule = self:addGuiTable(guiBeacon,"beacon-modules"..recipe.name, 1, "helmod_beacon-modules")
	-- modules
	for name, count in pairs(beacon.modules) do
		for index = 1, count, 1 do
			self:addSmSpriteButton(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name)
			index = index + 1
		end
	end
	self:addGuiLabel(guiBeacon, beacon.name, self:formatNumber(beacon.count), "helmod_label-right")

	-- col energy
	local guiEnergy = self:addGuiFlowH(guiTable,"energy"..recipe.name, "helmod_align-right-flow")
	self:addGuiLabel(guiEnergy, recipe.name, self:formatNumberKilo(recipe.energy_total, "W"), "helmod_label-right-70")

	-- products
	local tProducts = self:addGuiTable(guiTable,"products_"..recipe.name, 3)
	if recipe.products ~= nil then
		for r, product in pairs(recipe.products) do
			local cell = self:addGuiFlowH(tProducts,"cell_"..product.name)
			-- product = {type="item", name="steel-plate", amount=8}
			self:addSpriteIconButton(cell, "HMPlannerResourceInfo=OPEN=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(product), product.name, "X"..product.amount)

			self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label-right-60")
		end
	end
	-- ingredients
	local tIngredient = self:addGuiTable(guiTable,"ingredients_"..recipe.name, 3)
	if recipe.ingredients ~= nil then
		for r, ingredient in pairs(recipe.ingredients) do
			local cell = self:addGuiFlowH(tIngredient,"cell_"..ingredient.name)
			-- ingredient = {type="item", name="steel-plate", amount=8}
			self:addSelectSpriteIconButton(cell, self:classname().."=production-recipe-add=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount, "yellow", ({"tooltip.add-recipe"}))

			self:addGuiLabel(cell, ingredient.name, self:formatNumber(ingredient.count), "helmod_label-right-60")
		end
	end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PlannerResult] addProductionLineRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #table element production block
--
function PlannerResult.methods:addProductionLineRow(player, guiTable, element)
	Logging:debug("PlannerResult:addProductionLineRow():", player, guiTable, element)
	local model = self.model:getModel(player)

	local globalSettings = self.player:getGlobal(player, "settings")

	-- col action
	local guiAction = self:addGuiFlowH(guiTable,"action"..element.id)
	self:addGuiButton(guiAction, self:classname().."=production-block-remove=ID=", element.id, "helmod_button-default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
	self:addGuiButton(guiAction, self:classname().."=production-block-down=ID=", element.id, "helmod_button-default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
	self:addGuiButton(guiAction, self:classname().."=production-block-up=ID=", element.id, "helmod_button-default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
	-- col index
	if globalSettings.display_data_col_index then
		local guiIndex = self:addGuiFlowH(guiTable,"index"..element.id)
		self:addGuiLabel(guiIndex, "index", element.index, "helmod_label-right-40")
	end
	-- col level
	if globalSettings.display_data_col_level then
		local guiLevel = self:addGuiFlowH(guiTable,"level"..element.id)
		self:addGuiLabel(guiLevel, "level", element.level)
	end
	-- col weight
	if globalSettings.display_data_col_weight then
		local guiLevel = self:addGuiFlowH(guiTable,"weight"..element.id)
		self:addGuiLabel(guiLevel, "weight", element.weight)
	end
	-- col id
	if globalSettings.display_data_col_id then
		local guiId = self:addGuiFlowH(guiTable,"id"..element.id)
		self:addGuiLabel(guiId, "id", element.id)
	end
	-- col name
	if globalSettings.display_data_col_name then
		local guiName = self:addGuiFlowH(guiTable,"name"..element.id)
		self:addGuiLabel(guiName, "name", element.id)
	end
	-- col recipe
	local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..element.id)
	self:addSelectSpriteIconButton(guiRecipe, self:classname().."=change-tab=ID="..self.PRODUCTION_BLOCK_TAB.."="..element.id.."=", "recipe", element.name, element.name, nil, ({"tooltip.edit-block"}))

	-- col energy
	local guiEnergy = self:addGuiFlowH(guiTable,"energy"..element.id, "helmod_align-right-flow")
	self:addGuiLabel(guiEnergy, element.id, self:formatNumberKilo(element.power, "W"), "helmod_label-right-70")

	-- products
	local tProducts = self:addGuiTable(guiTable,"products_"..element.id, 2)
	if element.products ~= nil then
		for r, product in pairs(element.products) do
			-- product = {type="item", name="steel-plate", amount=8}
			local cell = self:addGuiFlowH(tProducts,"cell_"..product.name)
			self:addSelectSpriteIconButton(cell, "HMPlannerProductEdition=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..product.amount, nil, ({"tooltip.edit-product"}))

			self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label-right-60")
		end
	end
	-- ingredients
	local tIngredient = self:addGuiTable(guiTable,"ingredients_"..element.id, 4)
	if element.ingredients ~= nil then
		for r, ingredient in pairs(element.ingredients) do
			-- ingredient = {type="item", name="steel-plate", amount=8}
			local cell = self:addGuiFlowH(tIngredient,"cell_"..ingredient.name)
			self:addSelectSpriteIconButton(cell, self:classname().."=production-block-add=ID="..element.id.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount, "yellow", ({"tooltip.add-recipe"}))

			self:addGuiLabel(cell, ingredient.name, self:formatNumber(ingredient.count), "helmod_label-right-60")
		end
	end
end

-------------------------------------------------------------------------------
-- Add row resources tab
--
-- @function [parent=#PlannerResult] addResourcesRow
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:addResourcesRow(player, guiTable, ingredient)
	Logging:debug("PlannerResult:addRow():", player, guiTable, ingredient)
	local model = self.model:getModel(player)

	local globalSettings = self.player:getGlobal(player, "settings")
	-- col index
	if globalSettings.display_data_col_index then
		local guiIndex = self:addGuiFlowH(guiTable,"index"..ingredient.name)
		self:addGuiLabel(guiIndex, "index", ingredient.index)
	end
	-- col level
	if globalSettings.display_data_col_level then
		local guiLevel = self:addGuiFlowH(guiTable,"level"..ingredient.name)
		self:addGuiLabel(guiLevel, "level", ingredient.level)
	end
	-- col weight
	if globalSettings.display_data_col_weight then
		local guiLevel = self:addGuiFlowH(guiTable,"weight"..ingredient.name)
		self:addGuiLabel(guiLevel, "weight", ingredient.weight)
	end
	-- col id
	if globalSettings.display_data_col_id then
		local guiId = self:addGuiFlowH(guiTable,"id"..ingredient.name)
		self:addGuiLabel(guiId, "id", ingredient.id)
	end
	-- col name
	if globalSettings.display_data_col_name then
		local guiName = self:addGuiFlowH(guiTable,"name"..ingredient.name)
		self:addGuiLabel(guiName, "name", ingredient.name)
	end
	-- col ingredient
	local guiIngredient = self:addGuiFlowH(guiTable,"ingredient"..ingredient.name)
	self:addSelectSpriteIconButton(guiIngredient, "HMPlannerIngredient=OPEN=ID=", self.player:getIconType(ingredient), ingredient.name)

	-- col count
	local guiCount = self:addGuiFlowH(guiTable,"count"..ingredient.name)
	self:addGuiLabel(guiCount, ingredient.name, self:formatNumber(ingredient.count))

	-- col type
	local guiType = self:addGuiFlowH(guiTable,"type"..ingredient.name)
	self:addGuiLabel(guiType, ingredient.name, ingredient.resource_category)

end

-------------------------------------------------------------------------------
-- Update resources tab
--
-- @function [parent=#PlannerResult] updateResources
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:updateResources(player)
	Logging:debug("PlannerResult:updateResources():", player)
	local model = self.model:getModel(player)
	-- data
	local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-resources"}))

	local maxPage = math.floor(self.model:countIngredients(player)/model.step)
	self:addPagination(player, resultPanel, "none", maxPage)

	local globalSettings = self.player:getGlobal(player, "settings")

	local extra_cols = 0
	if globalSettings.display_data_col_name then
		extra_cols = extra_cols + 1
	end
	if globalSettings.display_data_col_id then
		extra_cols = extra_cols + 1
	end
	if globalSettings.display_data_col_index then
		extra_cols = extra_cols + 1
	end
	if globalSettings.display_data_col_level then
		extra_cols = extra_cols + 1
	end
	if globalSettings.display_data_col_weight then
		extra_cols = extra_cols + 1
	end
	local resultTable = self:addGuiTable(resultPanel,"table-resources",3 + extra_cols)

	self:addResourcesHeader(player, resultTable)


	local indexBegin = model.page * model.step
	local indexEnd = (model.page + 1) * model.step
	local i = 0
	for _, recipe in spairs(model.ingredients, function(t,a,b) if model.order.ascendant then return t[b][model.order.name] > t[a][model.order.name] else return t[b][model.order.name] < t[a][model.order.name] end end) do
		if i >= indexBegin and i < indexEnd then
			self:addResourcesRow(player, resultTable, recipe)
		end
		i = i + 1
	end
end

-------------------------------------------------------------------------------
-- Update summary tab
--
-- @function [parent=#PlannerResult] updateSummary
--
-- @param #LuaPlayer player
--
function PlannerResult.methods:updateSummary(player)
	Logging:debug("PlannerResult:updateSummary():", player)
	local model = self.model:getModel(player)
	local dataPanel = self:getDataPanel(player)
	-- data
	local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-summary"}))

	-- resources
	local resourcesPanel = self:addGuiFrameV(resultPanel, "ressources", nil, ({"helmod_common.resources"}))
	local resourcesTable = self:addGuiTable(resourcesPanel,"table-resources",3)
	self:addGuiLabel(resourcesTable, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
	self:addGuiLabel(resourcesTable, "header-extrator", ({"helmod_result-panel.col-header-extractor"}))
	self:addGuiLabel(resourcesTable, "header-energy", ({"helmod_result-panel.col-header-energy"}))

	for _, ingredient in pairs(model.ingredients) do
		if ingredient.resource_category ~= nil then
			-- ingredient
			local guiIngredient = self:addGuiFlowH(resourcesTable,"ingredient"..ingredient.name)
			self:addSpriteIconButton(guiIngredient, "HMPlannerIngredient=OPEN=ID=", self.player:getItemIconType(ingredient), ingredient.name)
			self:addGuiLabel(guiIngredient, "count", self:formatNumber(ingredient.count))
			-- extractor
			local guiExtractor = self:addGuiFlowH(resourcesTable,"extractor"..ingredient.name)
			if ingredient.extractor ~= nil then
				self:addSpriteIconButton(guiExtractor, "HMPlannerIngredient=OPEN=ID=", "item", ingredient.extractor.name)
				self:addGuiLabel(guiExtractor, "extractor", self:formatNumberKilo(ingredient.extractor.count))
			else
				self:addGuiLabel(guiExtractor, "extractor", "Data need update")
			end

			-- col energy
			local guiEnergy = self:addGuiFlowH(resourcesTable,"energy"..ingredient.name, "helmod_align-right-flow")
			self:addGuiLabel(guiEnergy, ingredient.name, self:formatNumberKilo(ingredient.extractor.energy_total, "W"))
		end
	end

	local energyPanel = self:addGuiFrameV(resultPanel, "energy", nil, ({"helmod_common.generators"}))
	local resultTable = self:addGuiTable(energyPanel,"table-energy",2)

	for _, item in pairs(model.generators) do
		-- col icon
		local guiIcon = self:addGuiFlowH(resultTable,"icon_"..item.name)
		self:addSpriteIconButton(guiIcon, "HMPlannerGenerator=OPEN=ID=", "item", item.name)

		-- col value
		local guiValue = self:addGuiFlowH(resultTable,"value_"..item.name)
		self:addGuiLabel(guiValue, item.name, self:formatNumberKilo(item.count))
	end

	-- factories
	local factoryPanel = self:addGuiFrameV(resultPanel, "factory", nil, ({"helmod_common.factories"}))
	local resultTable = self:addGuiTable(factoryPanel,"table-factory",2)

	for _, element in pairs(model.summary.factories) do
		-- col icon
		local guiIcon = self:addGuiFlowH(resultTable,"icon_"..element.name)
		self:addSpriteIconButton(guiIcon, "HMPlannerFactories=OPEN=ID=", "item", element.name)

		-- col value
		local guiValue = self:addGuiFlowH(resultTable,"value_"..element.name)
		self:addGuiLabel(guiValue, element.name, self:formatNumberKilo(element.count))
	end
	-- beacons
	local beaconPanel = self:addGuiFrameV(resultPanel, "beacon", nil, ({"helmod_common.beacons"}))
	local resultTable = self:addGuiTable(beaconPanel,"table-beacon",2)

	for _, element in pairs(model.summary.beacons) do
		-- col icon
		local guiIcon = self:addGuiFlowH(resultTable,"icon_"..element.name)
		self:addSpriteIconButton(guiIcon, "HMPlannerBeacons=OPEN=ID=", "item", element.name)

		-- col value
		local guiValue = self:addGuiFlowH(resultTable,"value_"..element.name)
		self:addGuiLabel(guiValue, element.name, self:formatNumberKilo(element.count))
	end
	-- modules
	local modulePanel = self:addGuiFrameV(resultPanel, "beacon_", nil, ({"helmod_common.modules"}))
	local resultTable = self:addGuiTable(modulePanel,"table-beacon",2)

	for _, element in pairs(model.summary.modules) do
		-- col icon
		local guiIcon = self:addGuiFlowH(resultTable,"icon_"..element.name)
		self:addSpriteIconButton(guiIcon, "HMPlannerModules=OPEN=ID=", "item", element.name)

		-- col value
		local guiValue = self:addGuiFlowH(resultTable,"value_"..element.name)
		self:addGuiLabel(guiValue, element.name, self:formatNumberKilo(element.count))
	end
end
