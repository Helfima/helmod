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

	self.currentTab = self.DATA_TAB

	self.page = 0
	self.step = 10
end

-------------------------------------------------------------------------------
-- Bind the parent panel
--
-- @function [parent=#PlannerResult] bindPanel
--
-- @param #LuaGuiElement gui parent element
--
function PlannerResult.methods:bindPanel(gui)
	if gui ~= nil then
		self.guiPanel = gui
	end
end

-------------------------------------------------------------------------------
-- Build the parent panel
--
-- @function [parent=#PlannerResult] buildPanel
--
function PlannerResult.methods:buildPanel()
	if self.guiPanel ~= nil then
		self.guiSelector = self:addGuiFrameH(self.guiPanel, "selector", "helmod_menu_frame_style")
		self:addGuiButton(self.guiSelector, self:classname().."_change-tab_ID_", self.DATA_TAB, "helmod_button-default", "Data")
		self:addGuiButton(self.guiSelector, self:classname().."_change-tab_ID_", self.ENERGY_TAB, "helmod_button-default", "Energy")
		self:addGuiButton(self.guiSelector, self:classname().."_change-tab_ID_", self.RESOURCES_TAB, "helmod_button-default", "Resources")


		local count = self.model.global:countDisabledRecipes()
		self.guiRecipesButton = self:addGuiButton(self.guiSelector, self:classname().."_change-tab_ID_", self.RECIPES_TAB, "helmod_button-default", "Disable recipes")

		self.guiData = self:addGuiFlowV(self.guiPanel, "data")

		self:update()
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
	if event.element.valid and string.find(event.element.name, self:classname()) then
		local patternAction = self:classname().."_([^_]*)"
		local patternItem = self:classname()..".*_ID_([^_]*)"
		local patternRecipe = self:classname()..".*_ID_[^_]*_([^_]*)"
		local action = string.match(event.element.name,patternAction,1)
		local item = string.match(event.element.name,patternItem,1)
		local item2 = string.match(event.element.name,patternRecipe,1)

		self:on_event(event.element, action, item, item2)
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerResult] on_event
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerResult.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "change-tab" then
		self.currentTab = item
		self:update()
	end
	if action == "change-page" then
		self:updatePage(item, item2)
		self:update()
	end
end

-------------------------------------------------------------------------------
-- Update page
--
-- @function [parent=#PlannerResult] updatePage
--
function PlannerResult.methods:updatePage(item, item2)
	Logging:debug("PlannerResult:updatePage", item)
	if item == "down" then
		if self.page > 0 then
			self.page = self.page - 1
		end
	end
	if item == "up" then
		Logging:debug("PlannerResult:updatePage, rawlen", rawlen(self.model.recipes))
		local maxPage = math.floor(self.model:countRepices()/self.step)
		if self.page < maxPage then
			self.page = self.page + 1
		end
	end
	if item == "direct" then
		self.page = tonumber(item2)
	end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerResult] update
--
function PlannerResult.methods:update()
	if self.guiPanelResult ~= nil then
		self.guiPanelResult.destroy()
		self.guiPanelResult = nil
	end

	local count = self.model.global:countDisabledRecipes()
	if self.guiRecipesButton ~= nil and self.guiRecipesButton.valid then
		self.guiRecipesButton.caption = "Disable recipes ("..count..")"
	end

	if self.currentTab == self.DATA_TAB then
		self:updateData()
	end
	if self.currentTab == self.ENERGY_TAB then
		self:updateEnergy()
	end
	if self.currentTab == self.RESOURCES_TAB then
		self:updateResources()
	end
	if self.currentTab == self.RECIPES_TAB then
		self:updateRecipes()
	end
end

-------------------------------------------------------------------------------
-- Update data tab
--
-- @function [parent=#PlannerResult] updateData
--
function PlannerResult.methods:updateData()
	-- data
	self.guiPanelResult = self:addGuiFrameV(self.guiData, PLANNER_PANEL_RESULT, "helmod_result", "Data")
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
	self:addPagination(self.guiPanelResult)

	self.guiTableResult = self:addGuiTable(self.guiPanelResult,PLANNER_TABLE_RESULT,6)

	self:addHeader(self.guiTableResult)

	local indexBegin = self.page * self.step
	local indexEnd = (self.page + 1) * self.step
	Logging:debug("pagination:", {page = self.page, step = self.step, indexBegin = indexBegin, indexEnd = indexEnd})
	local i = 0
	for _, recipe in pairs(self.model.recipes) do
		if i >= indexBegin and i < indexEnd then
			self:addRow(self.guiTableResult, recipe)
		end
		i = i + 1
	end

	self:addGuiLabel(self.guiTableResult, "foot-1", "Total")
	self:addGuiLabel(self.guiTableResult, "blank-1", "")
	self:addGuiLabel(self.guiTableResult, "blank-2", "")
	if self.model.summary ~= nil then
		self:addGuiLabel(self.guiTableResult, "energy", self.model.summary.energy)
	end
end

-------------------------------------------------------------------------------
-- Add pagination data tab
--
-- @function [parent=#PlannerResult] addPagination
--
function PlannerResult.methods:addPagination(itable)
	local guiPagination = self:addGuiFlowH(itable,"pagination", "helmod_page-result-flow")

	self:addGuiButton(guiPagination, self:classname().."_change-page_ID_", "down", "helmod_button-default", "<")

	local maxPage = math.floor(self.model:countRepices()/self.step)
	for page = 0, maxPage, 1 do
		if page == self.page then
			self:addGuiLabel(guiPagination, self:classname().."_change-page_ID_", page + 1, "helmod_page-label")
		else
			self:addGuiButton(guiPagination, self:classname().."_change-page_ID_direct_", page, "helmod_button-default", page + 1)
		end
	end

	self:addGuiButton(guiPagination, self:classname().."_change-page_ID_", "up", "helmod_button-default", ">")
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PlannerResult] addHeader
--
function PlannerResult.methods:addHeader(itable)
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
function PlannerResult.methods:addRow(guiTable, recipe)
	-- col recipe
	local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..recipe.name)
	self:addSelectSpriteIconButton(guiRecipe, "HMPlannerRecipeEdition_OPEN_ID_", self.player:getRecipeIconType(recipe), recipe.name)

	-- col factory
	local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.name)
	local factory = recipe.factory
	self:addSelectSpriteIconButton(guiFactory, "HMPlannerFactorySelector_OPEN_ID_"..recipe.name.."_", self.player:getItemIconType(factory), factory.name)
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
	self:addSelectSpriteIconButton(guiBeacon, "HMPlannerBeaconSelector_OPEN_ID_"..recipe.name.."_", self.player:getItemIconType(beacon), beacon.name)
	self:addGuiLabel(guiBeacon, beacon.name, beacon.count)

	-- col energy
	local guiEnergy = self:addGuiFlowH(guiTable,"energy"..recipe.name, "helmod_align-right-flow")
	self:addGuiLabel(guiEnergy, recipe.name, recipe.energy_total)

	-- products
	local tProducts = self:addGuiFlowH(guiTable,"products_"..recipe.name)
	if recipe.products ~= nil then
		for r, product in pairs(recipe.products) do
			-- product = {type="item", name="steel-plate", amount=8}
			self:addSpriteIconButton(tProducts, PLANNER_ACTION_PRODUCT_INFO_OPEN.."_ID_"..recipe.name.."_"..product.name.."_", self.player:getItemIconType(product), product.name, "X"..product.amount)

			self:addGuiLabel(tProducts, product.name, product.count)
		end
	end
	-- ingredients
	local tIngredient = self:addGuiFlowH(guiTable,"ingredients_"..recipe.name)
	if recipe.ingredients ~= nil then
		for r, ingredient in pairs(recipe.ingredients) do
			-- ingredient = {type="item", name="steel-plate", amount=8}
			self:addSpriteIconButton(tIngredient, PLANNER_ACTION_INGREDIENT_INFO_OPEN.."_ID_"..recipe.name.."_"..ingredient.name.."_", self.player:getItemIconType(ingredient), ingredient.name, "X"..ingredient.amount)

			self:addGuiLabel(tIngredient, ingredient.name, ingredient.count)
		end
	end
end

-------------------------------------------------------------------------------
-- Update data tab
--
-- @function [parent=#PlannerResult] updateValue
--
function PlannerResult.methods:updateValue()
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
function PlannerResult.methods:updateRecipes()
	-- data
	self.guiPanelResult = self:addGuiFrameV(self.guiData, PLANNER_PANEL_RESULT, "helmod_result", "Disable recipes")

	for r, recipe in pairs(self.model.global.recipes) do
		if not(recipe.active) then
			self:addSelectSpriteIconButton(self.guiPanelResult, "HMPlannerRecipeEdition_OPEN_ID_", self.player:getRecipeIconType(recipe), recipe.name)
		end
	end
end

-------------------------------------------------------------------------------
-- Update resources tab
--
-- @function [parent=#PlannerResult] updateResources
--
function PlannerResult.methods:updateResources()
	-- data
	self.guiPanelResult = self:addGuiFrameV(self.guiData, PLANNER_PANEL_RESULT, "helmod_result", "Resources")
end

-------------------------------------------------------------------------------
-- Update energy tab
--
-- @function [parent=#PlannerResult] updateEnergy
--
function PlannerResult.methods:updateEnergy()
	-- data
	self.guiPanelResult = self:addGuiFrameV(self.guiData, PLANNER_PANEL_RESULT, "helmod_result", "Energy")
end










