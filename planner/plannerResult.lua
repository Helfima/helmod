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

	self.DATA_TAB = "data"
	self.ENERGY_TAB = "energy"
	self.RESOURCES_TAB = "resources"
	self.RECIPES_TAB = "disable-recipe"
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
	local parentPanel = self:getParentPanel(player)
	if parentPanel["selector"] ~= nil and parentPanel["selector"].valid then
		return parentPanel["selector"]
	end
	return self:addGuiFrameH(parentPanel, "selector", "helmod_menu_frame_style")
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
	model.currentTab = self.DATA_TAB
	
	local parentPanel = self:getParentPanel(player)
	
	if parentPanel ~= nil then
		local selectorPanel = self:getSelectorPanel(player)
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.DATA_TAB, "helmod_button-default", "Data")
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.ENERGY_TAB, "helmod_button-default", "Energy")
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.RESOURCES_TAB, "helmod_button-default", "Resources")
		self:addGuiButton(selectorPanel, self:classname().."=change-tab=ID=", self.RECIPES_TAB, "helmod_button-default", "Disable recipes")

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
		local patternRecipe = self:classname()..".*=ID=[^=]*=([^=]*)"
		local action = string.match(event.element.name,patternAction,1)
		local item = string.match(event.element.name,patternItem,1)
		local item2 = string.match(event.element.name,patternRecipe,1)

		self:on_event(player, event.element, action, item, item2)
	end
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
-- @param #string item second item name
--
function PlannerResult.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerResult:on_event():",player, element, action, item, item2)
	local model = self.model:getModel(player)
	
	if action == "change-tab" then
		model.currentTab = item
		self:update(player)
	end
	if action == "change-page" then
		self:updatePage(player, item, item2)
		self:update(player)
	end
end

-------------------------------------------------------------------------------
-- Update page
--
-- @function [parent=#PlannerResult] updatePage
-- 
-- @param #LuaPlayer player
--
function PlannerResult.methods:updatePage(player, item, item2)
	Logging:debug("PlannerResult:updatePage():",item, item2)
	local model = self.model:getModel(player)
	if item == "down" then
		if model.page > 0 then
			model.page = model.page - 1
		end
	end
	if item == "up" then
		Logging:debug("PlannerResult:updatePage, rawlen", rawlen(model.recipes))
		local maxPage = math.floor(self.model:countRepices(player)/model.step)
		if model.page < maxPage then
			model.page = model.page + 1
		end
	end
	if item == "direct" then
		model.page = tonumber(item2)
	end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerResult] update
-- 
-- @param #LuaPlayer player
--
function PlannerResult.methods:update(player)
	Logging:debug("PlannerResult:update():", player)
	local model = self.model:getModel(player)
	
	if self:getResultPanel(player) ~= nil then
		self:getResultPanel(player).destroy()
	end

	local count = self.model:countDisabledRecipes(player)
	local button = self:getSelectorPanel(player)[self:classname().."=change-tab=ID="..self.RECIPES_TAB]
	if button ~= nil and button.valid then
		button.caption = "Disable recipes ("..count..")"
	end

	if model.currentTab == self.DATA_TAB then
		self:updateData(player)
	end
	if model.currentTab == self.ENERGY_TAB then
		self:updateEnergy(player)
	end
	if model.currentTab == self.RESOURCES_TAB then
		self:updateResources(player)
	end
	if model.currentTab == self.RECIPES_TAB then
		self:updateRecipes(player)
	end
end

-------------------------------------------------------------------------------
-- Update data tab
--
-- @function [parent=#PlannerResult] updateData
--
-- @param #LuaPlayer player
-- 
function PlannerResult.methods:updateData(player)
	Logging:debug("PlannerResult:updateData():", player)
	local model = self.model:getModel(player)
	-- data
	local resultPanel = self:getResultPanel(player, "Data")
	--	-- summary
	--	self.guiSummaryFrame = self.guidata.add{type="frame", name=self.names.summary.."frame", direction="vertical", caption="Summary", style="helmod_summary-frame"}
	--	self.guiSummary = self.guiSummaryFrame.add{type="table", name=self.names.summary, colspan=2}
	--	if self.items.summary ~= nil then
	--		for r, value in pairs(self.items.summary) do
	--			if r ~= "energy" then
	--				self:addItemButton(self.guiSummary, "", "label"..r)
	--			else
	--				self:addGuiLabel(self.guiSummary, "label"..r, "energy")
	--			end
	--			self:addGuiLabel(self.guiSummary, "value"..r, value)
	--		end
	--	end
	-- result
	self:addPagination(player, resultPanel)

	local resultTable = self:addGuiTable(resultPanel,PLANNER_TABLE_RESULT,6)

	self:addHeader(player, resultTable)

	local indexBegin = model.page * model.step
	local indexEnd = (model.page + 1) * model.step
	Logging:debug("pagination:", {page = model.page, step = model.step, indexBegin = indexBegin, indexEnd = indexEnd})
	local i = 0
	for _, recipe in pairs(model.recipes) do
		if i >= indexBegin and i < indexEnd then
			self:addRow(player, resultTable, recipe)
		end
		i = i + 1
	end

	self:addGuiLabel(resultTable, "foot-1", "Total")
	self:addGuiLabel(resultTable, "blank-1", "")
	self:addGuiLabel(resultTable, "blank-2", "")
	if model.summary ~= nil then
		self:addGuiLabel(resultTable, "energy", model.summary.energy)
	end
end

-------------------------------------------------------------------------------
-- Add pagination data tab
--
-- @function [parent=#PlannerResult] addPagination
-- 
-- @param #LuaPlayer player
--
function PlannerResult.methods:addPagination(player, itable)
	Logging:debug("PlannerResult:addPagination():", player, itable)
	local model = self.model:getModel(player)
	local guiPagination = self:addGuiFlowH(itable,"pagination", "helmod_page-result-flow")

	self:addGuiButton(guiPagination, self:classname().."=change-page=ID=", "down", "helmod_button-default", "<")

	local maxPage = math.floor(self.model:countRepices(player)/model.step)
	for page = 0, maxPage, 1 do
		if page == model.page then
			self:addGuiLabel(guiPagination, self:classname().."=change-page=ID=", page + 1, "helmod_page-label")
		else
			self:addGuiButton(guiPagination, self:classname().."=change-page=ID=direct=", page, "helmod_button-default", page + 1)
		end
	end

	self:addGuiButton(guiPagination, self:classname().."=change-page=ID=", "up", "helmod_button-default", ">")
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PlannerResult] addHeader
-- 
-- @param #LuaPlayer player
--
function PlannerResult.methods:addHeader(player, itable)
	Logging:debug("PlannerResult:addHeader():", player, itable)
	self:addGuiLabel(itable, "header-recipes", "Recipes")
	self:addGuiLabel(itable, "header-factory", "Factory")
	self:addGuiLabel(itable, "header-beacon", "Beacon")
	self:addGuiLabel(itable, "header-kw", "Energy KW")
	self:addGuiLabel(itable, "header-products", "Products")
	self:addGuiLabel(itable, "header-ingredients", "Ingredients")
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PlannerResult] addRow
-- 
-- @param #LuaPlayer player
--
function PlannerResult.methods:addRow(player, guiTable, recipe)
	Logging:debug("PlannerResult:addRow():", player, guiTable, recipe)
	local model = self.model:getModel(player)
	-- col recipe
	local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..recipe.name)
	self:addSelectSpriteIconButton(guiRecipe, "HMPlannerRecipeEdition=OPEN=ID=", self.player:getIconType(recipe), recipe.name)

	-- col factory
	local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.name)
	local factory = recipe.factory
	self:addSelectSpriteIconButton(guiFactory, "HMPlannerFactorySelector=OPEN=ID="..recipe.name.."=", self.player:getIconType(factory), factory.name)
	local guiFactoryModule = self:addGuiFlowV(guiFactory,"factory-modules"..recipe.name)
	-- modules
--	for name, count in pairs(factory.modules) do
--		for index = 1, count, 1 do
--			self:addMiniIconButton(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "module", name)
--			index = index + 1
--		end
--	end
	self:addGuiLabel(guiFactory, factory.name, factory.count)

	-- col beacon
	local guiBeacon = self:addGuiFlowH(guiTable,"beacon"..recipe.name)
	local beacon = recipe.beacon
	self:addSelectSpriteIconButton(guiBeacon, "HMPlannerBeaconSelector=OPEN=ID="..recipe.name.."=", self.player:getIconType(beacon), beacon.name)
	self:addGuiLabel(guiBeacon, beacon.name, beacon.count)

	-- col energy
	local guiEnergy = self:addGuiFlowH(guiTable,"energy"..recipe.name, "helmod_align-right-flow")
	self:addGuiLabel(guiEnergy, recipe.name, recipe.energy_total)

	-- products
	local tProducts = self:addGuiFlowH(guiTable,"products_"..recipe.name)
	if recipe.products ~= nil then
		for r, product in pairs(recipe.products) do
			-- product = {type="item", name="steel-plate", amount=8}
			self:addSpriteIconButton(tProducts, "HMPlannerResourceInfo=OPEN=ID="..recipe.name.."=", self.player:getIconType(product), product.name, "X"..product.amount)

			self:addGuiLabel(tProducts, product.name, product.count)
		end
	end
	-- ingredients
	local tIngredient = self:addGuiFlowH(guiTable,"ingredients_"..recipe.name)
	if recipe.ingredients ~= nil then
		for r, ingredient in pairs(recipe.ingredients) do
			-- ingredient = {type="item", name="steel-plate", amount=8}
			self:addSpriteIconButton(tIngredient, "HMPlannerResourceInfo=OPEN=ID="..recipe.name.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount)

			self:addGuiLabel(tIngredient, ingredient.name, ingredient.count)
		end
	end
end

-------------------------------------------------------------------------------
-- Update data tab
--
-- @function [parent=#PlannerResult] updateValue
--
function PlannerResult.methods:updateValue(player)
	Logging:debug("PlannerResult:updateValue():", player)
	self.guiSummary.destroy()
	self.guiSummary = self:addGuiTable(self.guiSummaryFrame, PLANNER_TABLE_SUMMARY, 2)
	if self.items.summary ~= nil then
		for r, value in pairs(self.items.summary) do
			if r ~= "energy" then
				self:addGuiButton(self.guiSummary, "label"..r, self:getPrefix()..r)
			else
				self:addGuiLabel(self.guiSummary, "label"..r, "energy")
			end
			self:addGuiLabel(self.guiSummary, "value"..r, value)
		end
	end

	for r, idata in pairs(self.items.data) do
		if idata.factory.valid then
			idata.captions["factory-module-speed"].caption = idata.factory.modules.speed
			idata.captions["factory-module-productivity"].caption = idata.factory.modules.productivity
			idata.captions["factory-module-effectivity"].caption = idata.factory.modules.effectivity

			idata.captions["beacon"].caption = idata.beacon.count
			idata.captions["beacon-module-speed"].caption = idata.beacon.modules.speed
			idata.captions["beacon-module-productivity"].caption = idata.beacon.modules.productivity
			idata.captions["beacon-module-effectivity"].caption = idata.beacon.modules.effectivity
		end
		idata.captions["energy"].caption = idata.recipe.energy
		idata.captions["total"].caption = self:formatNumber(idata.count)
		if idata.factory.valid then
			idata.captions["crafting_speed_real"].caption = idata.factory.speed
			idata.captions["energy_usage_real"].caption = idata.factory.energy
			idata.captions["count"].caption = self:formatNumber(idata.factory.count)
			idata.captions["energy_total"].caption = self:formatNumber(idata.energy_total)
		end
	end
end

-------------------------------------------------------------------------------
-- Update recipes tab
--
-- @function [parent=#PlannerResult] updateRecipes
-- 
-- @param #LuaPlayer player
--
function PlannerResult.methods:updateRecipes(player)
	Logging:debug("PlannerResult:updateRecipes():", player)
	local default = self.model:getDefault(player)
	Logging:debug("PlannerResult:updateRecipes():default=", default)
	-- data
	local resultPanel = self:getResultPanel(player, "Disable recipes")

	for r, recipe in pairs(default.recipes) do
		if not(recipe.active) then
			self:addSelectSpriteIconButton(resultPanel, "HMPlannerRecipeEdition=OPEN=ID=", self.player:getRecipeIconType(player, recipe), recipe.name)
		end
	end
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
	local resultPanel = self:getResultPanel(player, "Resources")
	
	local resultTable = self:addGuiTable(resultPanel,"table-resources",9)
	
	for r, ingredient in pairs(model.ingredients) do
			-- ingredient = {type="item", name="steel-plate", amount=8}
			self:addSpriteIconButton(resultTable, "HMPlannerResourceInfo=OPEN=ID="..ingredient.name.."=", self.player:getIconType(ingredient), ingredient.name)

			self:addGuiLabel(resultTable, ingredient.name, ingredient.count)
			self:addGuiLabel(resultTable, ingredient.name.."type", ingredient.resource_category)
		end
end

-------------------------------------------------------------------------------
-- Update energy tab
--
-- @function [parent=#PlannerResult] updateEnergy
-- 
-- @param #LuaPlayer player
-- 
function PlannerResult.methods:updateEnergy(player)
	Logging:debug("PlannerResult:updateEnergy():", player)
	local model = self.model:getModel(player)
	local dataPanel = self:getDataPanel(player)
	-- data
	local resultPanel = self:getResultPanel(player, "Energy")
end










