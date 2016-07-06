require "planner/plannerModel"
require "planner/plannerBuilder"
require "planner/plannerDialog"
require "planner/plannerRecipeSelector"
require "planner/plannerRecipeUpdate"
require "planner/plannerRecipeEdition"
require "planner/plannerFactorySelector"
require "planner/plannerBeaconSelector"

PLANNER_COMMAND = "planner-command"
PLANNER_PANEL_MAIN = "planner_main"
PLANNER_PANEL_INFO = "planner-info"
PLANNER_PANEL_DATA = "planner-data"
PLANNER_PANEL_DIALOGUE = "planner-dialogue"
PLANNER_PANEL_RESULT = "planner-result"
PLANNER_PANEL_MENU = "planner-menu"
PLANNER_PANEL_RECIPE_LIST = "planner-list-recipes"
PLANNER_TABLE_RESULT = "planner-result-table"
PLANNER_TABLE_SUMMARY = "planner-summary-table"

PLANNER_ACTION_SAVE_MODEL = "planner-save-model"

PLANNER_ACTION_INGREDIENT_INFO_OPEN = "ingredient-info-open"
PLANNER_ACTION_PRODUCT_INFO_OPEN = "product-info-open"

PlannerController = setclass("HMPlannerController")

function PlannerController.methods:init(parent)
	self.parent = parent
	self.index = 0
	self.controllers = {}
	self.guiInputs = {}
	self.modelFilename = "helmod-planner-model.data"
	self.model = PlannerModel:new(self)
	self.items = PlannerBuilder:new(self)
end

function PlannerController.methods:getPrefix()
	return self.parent.prefix
end

function PlannerController.methods:cleanController()
	if self.parent.player.gui.left[self:getGuiName(PLANNER_PANEL_MAIN)] ~= nil then
		self.parent.player.gui.left[self:getGuiName(PLANNER_PANEL_MAIN)].destroy()
	end
end
function PlannerController.methods:bindController()
	if self.parent.gui ~= nil then
		self.parent.gui.add({type="button", name=self:getGuiName(PLANNER_COMMAND), caption=({PLANNER_COMMAND}), style="helmod_button-small-bold"})
	end
end
----------------------------------------------------------------
function PlannerController.methods:on_gui_click(event)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:on_gui_click(event)
		end
	end

	if event.element.valid then
		if event.element.name == self:getGuiName(PLANNER_COMMAND) then
			self:main()
		elseif string.find(event.element.name, self:classname()) then
			local patternAction = self:classname().."([^_]*)"
			local patternItem = self:classname()..".*_ID_([^_]*)"
			local patternRecipe = self:classname()..".*_ID_[^_]*_([^_]*)"
			local action = string.match(event.element.name,patternAction,1)
			local item = string.match(event.element.name,patternItem,1)
			local item2 = string.match(event.element.name,patternRecipe,1)

			--Logging:debug(event.element.name)
			--Logging:debug(action)
			--Logging:debug(item)
			if action ~= nil and action == PLANNER_ACTION_SAVE_MODEL then
				self:saveData(self.model)
			end
		end
	end
end

--===========================
function PlannerController.methods:main()
	if self.guiMain ~= nil then
		self.guiMain.destroy()
		self.guiMain = nil
		self.guiRecipeInfo = nil
		self.guiRecipeList = nil
		self.guiInputs = {}
		self.guiPanelResult = nil
		self.guiTableResult = nil
		self.guiSummary = nil
	else
		self.captions = {}
		-- main panel
		self.guiMain = self:addGuiFlowH(self.parent.player.gui.left, PLANNER_PANEL_MAIN)
		-- info
		self.guiInfo = self:addGuiFlowV(self.guiMain, PLANNER_PANEL_INFO)
		-- menu
		self.guiMenu =self:addGuiFrameH(self.guiInfo, PLANNER_PANEL_MENU, "helmod_menu_frame_style")
		self:addGuiButton(self.guiMenu, PLANNER_ACTION_SAVE_MODEL, nil , "helmod_button-default", ({"helmod_planner-save-model"}))
		-- data
		self.guiData =self:addGuiFlowH(self.guiInfo, PLANNER_PANEL_DATA)
		-- dialogue
		self.guiPanelDialogue = self:addGuiFlowH(self.guiMain, PLANNER_PANEL_DIALOGUE)
		self:updateListRecipes()
		--self:updateData()
		-- menu

		self.controllers["recipe-selector"] = PlannerRecipeSelector:new(self)
		self.controllers["recipe-selector"]:bindPanel(self.guiPanelDialogue)
		self.controllers["recipe-selector"]:bindButton(self.guiMenu, ({"helmod_planner-add-item"}))

		self.controllers["factory-selector"] = PlannerFactorySelector:new(self)
		self.controllers["factory-selector"]:bindPanel(self.guiPanelDialogue)

		self.controllers["beacon-selector"] = PlannerBeaconSelector:new(self)
		self.controllers["beacon-selector"]:bindPanel(self.guiPanelDialogue)

		self.controllers["recipe-update"] = PlannerRecipeUpdate:new(self)
		self.controllers["recipe-update"]:bindPanel(self.guiPanelDialogue)

		self.controllers["recipe-edition"] = PlannerRecipeEdition:new(self)
		self.controllers["recipe-edition"]:bindPanel(self.guiPanelDialogue)

	end
end

--===========================
function PlannerController.methods:refreshDisplayData()
	self:updateListRecipes()
	self:updateData()
end

--===========================
function PlannerController.methods:getInputNumber(element)
	local count = 0
	if element ~= nil then
		local tempCount=tonumber(element.text)
		if type(tempCount) == "number" then count = tempCount end
	end
	return count
end
--===========================
function PlannerController.methods:modelAddInput(element)
	local count = 1
	if self.guiRecipeCount ~= nil then
		local tempCount=tonumber(self.guiRecipeCount.text)
		if type(tempCount) == "number" then count = tempCount end
	end
	self.model:addInput(element, count)
	self.model:update()
	self:updateListRecipes()
	self:updateData()
	self:closeRecipeSelector()
	self:closeRecipeInfo()
end

--===========================
function PlannerController.methods:updateListRecipes()
	if self.guiRecipeList ~= nil then
		self.guiRecipeList.destroy()
		self.guiRecipeList = nil
	end
	self.guiRecipeList = self:addGuiFlowH(self.guiMenu, PLANNER_PANEL_RECIPE_LIST)
	if self.model.input ~= nil then
		for r, recipe in pairs(self.model.input) do
			self:addIconButton(self.guiRecipeList, "HMPlannerRecipeUpdate_OPEN_ID_", self.parent:getRecipeIconType(recipe), recipe.name, recipe.count)
		end
	end
end

--===========================
function PlannerController.methods:updateData()
	if self.guiPanelResult ~= nil then
		self.guiPanelResult.destroy()
		self.guiPanelResult = nil
	end
	-- data
	self.guiPanelResult = self:addGuiFrameV(self.guiData, PLANNER_PANEL_RESULT)
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
	self.guiTableResult = self:addGuiTable(self.guiPanelResult,PLANNER_TABLE_RESULT,5)
	self:addHeader(self.guiTableResult)
	for r, recipe in pairs(self.model.recipes) do
		self:addRow(self.guiTableResult, recipe)
	end
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addHeader(itable)
	self:addGuiLabel(itable, "header-recipes", "Recipes")
	self:addGuiLabel(itable, "header-factory", "Factory")
	self:addGuiLabel(itable, "header-beacon", "Beacon")
	--	self:addGuiLabel(itable, "header-module", "Modules")
	--	self:addGuiLabel(itable, "header-module2", "Modules")
	--	self:addGuiLabel(itable, "header-assembly", "Assemblage")
	--	self:addGuiLabel(itable, "header-total", "Total")
	--	self:addGuiLabel(itable, "header-speed", "Speed")
	--	self:addGuiLabel(itable, "header-kw", "KW")
	--	self:addGuiLabel(itable, "header-q", "Quantite")
	--	self:addGuiLabel(itable, "header-e", "Energie")
	self:addGuiLabel(itable, "header-products", "Products")
	self:addGuiLabel(itable, "header-ingredients", "Ingredients")
end
--------------------------------------------------------------------------------------
function PlannerController.methods:addRow(guiTable, recipe)
	-- col recipe
	self:addIconCheckbox(guiTable, "HMPlannerRecipeEdition_OPEN_ID_", "recipe", recipe.name, true)
	-- col factory
	local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.name)
	local factory = recipe.factory
	self:addIconCheckbox(guiFactory, "HMPlannerFactorySelector_OPEN_ID_"..recipe.name.."_", "item", factory.name, true)
	self:addGuiLabel(guiFactory, factory.name, factory.count)
	-- col beacon
	local guiBeacon = self:addGuiFlowH(guiTable,"beacon"..recipe.name)
	local beacon = recipe.beacon
	self:addIconCheckbox(guiBeacon, "HMPlannerBeaconSelector_OPEN_ID_"..recipe.name.."_", "item", beacon.name, true)
	self:addGuiLabel(guiBeacon, beacon.name, beacon.count)
	-- ingredient
	local tProducts = self:addGuiFlowH(guiTable,"products_"..recipe.name)
	if recipe.products ~= nil then
		for r, product in pairs(recipe.products) do
			-- product = {type="item", name="steel-plate", amount=8}
			self:addIconButton(tProducts, PLANNER_ACTION_PRODUCT_INFO_OPEN.."_ID_"..recipe.name.."_"..product.name.."_", self.parent:getItemIconType(product), product.name, "X"..product.amount)

			self:addGuiLabel(tProducts, product.name, product.count)
		end
	end
	-- ingredient
	local tIngredient = self:addGuiFlowH(guiTable,"ingredients_"..recipe.name)
	if recipe.ingredients ~= nil then
		for r, ingredient in pairs(recipe.ingredients) do
			-- ingredient = {type="item", name="steel-plate", amount=8}
			self:addIconButton(tIngredient, PLANNER_ACTION_INGREDIENT_INFO_OPEN.."_ID_"..recipe.name.."_"..ingredient.name.."_", self.parent:getItemIconType(ingredient), ingredient.name, "X"..ingredient.amount)

			self:addGuiLabel(tIngredient, ingredient.name, ingredient.count)
		end
	end
end

function PlannerController.methods:updateValue()
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

--------------------------------------------------------------------------------------
function PlannerController.methods:getGuiName(key)
	--self.index = self.index+1
	return key
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiLabel(parent, key, caption)
	return parent.add({type="label", name=self:getGuiName(key), caption=caption})
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiText(parent, key, text)
	return parent.add({type="textfield", name=self:getGuiName(key), text=text})
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiButton(parent, action, key, style, caption)
	local options = {}
	options.type = "button"
	if key ~= nil then
		options.name = self:getGuiName(action..key)
	else
		options.name = self:getGuiName(action)
	end
	if style ~= nil then
		options.style = style
	end
	if caption ~= nil then
		options.caption = caption
	end

	local button = nil
	local ok , err = pcall(function()
		button = parent.add(options)
	end)
	if not ok then
		options.style = "helmod_button-default"
		if caption ~= nil then
			options.caption = key.."("..caption..")"
		else
			options.caption = key
		end
		button = parent.add(options)
	end
	return button
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiCheckbox(parent, key, state, style)
	return parent.add({type="checkbox", name=self:getGuiName(key), state=state, style=style})
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addItemButton(parent, action, key, caption)
	return self:addGuiButton(parent, action, key, self:getGuiName(key), caption)
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addIconButton(parent, action, type, key, caption)
	return self:addGuiButton(parent, action, key, "helmod_button_"..type.."_"..key, caption)
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addIconCheckbox(parent, action, type, key, state , caption)
	local controller = self
	local checkbox = nil
	local ok , err = pcall(function()
		checkbox = controller:addGuiCheckbox(parent, action..key, state, "helmod_checkbox_"..type.."_"..key)
	end)
	if not ok then
		Logging:debug(err)
		if caption ~= nil then
			checkbox = self:addGuiButton(parent, action, key, "helmod_button-default", key.."("..caption..")")
		else
			checkbox = self:addGuiButton(parent, action, key, "helmod_button-default", key)
		end
	end
	return checkbox
end
--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiFlowH(parent, key)
	return parent.add{type="flow", name=self:getGuiName(key), direction="horizontal"}
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiFlowV(parent, key)
	return parent.add{type="flow", name=self:getGuiName(key), direction="vertical"}
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiFrameH(parent, key, style, caption)
	local options = {}
	options.type = "frame"
	options.direction = "horizontal"
	options.name = self:getGuiName(key)
	if style ~= nil then
		options.style = style
	end
	if caption ~= nil then
		options.caption = caption
	end
	return parent.add(options)
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiFrameV(parent, key, style, caption)
	local options = {}
	options.type = "frame"
	options.direction = "vertical"
	options.name = self:getGuiName(key)
	if style ~= nil then
		options.style = style
	end
	if caption ~= nil then
		options.caption = caption
	end
	return parent.add(options)
end

--------------------------------------------------------------------------------------
function PlannerController.methods:addGuiTable(parent, key, colspan)
	return parent.add{type="table", name=self:getGuiName(key), colspan=colspan}
end

function PlannerController.methods:formatNumber(n)
	return tostring(math.floor(n)):reverse():gsub("(%d%d%d)","%1 "):gsub(" (%-?)$","%1"):reverse()
end

function PlannerController.methods:saveData(data)
	local content = serpent.dump(data)
	game.write_file(self.modelFilename, content)
end




