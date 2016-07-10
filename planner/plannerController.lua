require "planner/plannerModel"
require "planner/plannerBuilder"
require "planner/plannerDialog"
require "planner/plannerResult"
require "planner/plannerRecipeSelector"
require "planner/plannerRecipeUpdate"
require "planner/plannerRecipeEdition"
require "planner/plannerFactorySelector"
require "planner/plannerBeaconSelector"

PLANNER_COMMAND = "helmod_planner-command"
PLANNER_PANEL_MAIN = "helmod_planner_main"
PLANNER_PANEL_INFO = "helmod_planner-info"
PLANNER_PANEL_DATA = "helmod_planner-data"
PLANNER_PANEL_DIALOGUE = "helmod_planner-dialogue"
PLANNER_PANEL_RESULT = "helmod_planner-result"
PLANNER_PANEL_MENU = "helmod_planner-menu"
PLANNER_PANEL_RECIPE_LIST = "helmod_planner-list-recipes"
PLANNER_TABLE_RESULT = "helmod_planner-result-table"
PLANNER_TABLE_SUMMARY = "helmod_planner-summary-table"

PLANNER_ACTION_SAVE_MODEL = "helmod_planner-save-model"

PLANNER_ACTION_INGREDIENT_INFO_OPEN = "helmod_ingredient-info-open"
PLANNER_ACTION_PRODUCT_INFO_OPEN = "helmod_product-info-open"

PlannerController = setclass("HMPlannerController", ElementGui)

function PlannerController.methods:init(parent)
	self.parent = parent
	self.index = 0
	self.controllers = {}
	self.guiInputs = {}
	self.modelFilename = "helmod-planner-model.data"
	self.model = PlannerModel:new(self)
	self.items = PlannerBuilder:new(self)
end

function PlannerController.methods:cleanController()
	if self.parent.player.gui.left[PLANNER_PANEL_MAIN] ~= nil then
		self.parent.player.gui.left[PLANNER_PANEL_MAIN].destroy()
	end
end
function PlannerController.methods:bindController()
	if self.parent.gui ~= nil then
		self.parent.gui.add({type="button", name=PLANNER_COMMAND, caption=({PLANNER_COMMAND}), style="helmod_button-small-bold"})
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
		if event.element.name == PLANNER_COMMAND then
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
		--self:addGuiButton(self.guiMenu, PLANNER_ACTION_SAVE_MODEL, nil , "helmod_button-default", ({"helmod_planner-save-model"}))
		-- data
		self.guiData =self:addGuiFlowV(self.guiInfo, PLANNER_PANEL_DATA)
		-- dialogue
		self.guiPanelDialogue = self:addGuiFlowH(self.guiMain, PLANNER_PANEL_DIALOGUE)
		self:updateListRecipes()
		--self:updateData()
		-- menu

		self.controllers["result"] = PlannerResult:new(self)
		self.controllers["result"]:bindPanel(self.guiData)
		self.controllers["result"]:buildPanel()

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
	self.controllers["result"]:update()
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
			self:addSelectSpriteIconButton(self.guiRecipeList, "HMPlannerRecipeUpdate_OPEN_ID_", self.parent:getRecipeIconType(recipe), recipe.name, recipe.count)
		end
	end
end

--------------------------------------------------------------------------------------
function PlannerController.methods:saveData(data)
	local content = serpent.dump(data)
	game.write_file(self.modelFilename, content)
end
