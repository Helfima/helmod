require "planner/plannerAbstractEdition"

-------------------------------------------------------------------------------
-- Classe to build recipe edition dialog
--
-- @module PlannerRecipeEdition
-- @extends #PlannerDialog
--

PlannerRecipeEdition = setclass("HMPlannerRecipeEdition", PlannerAbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerRecipeEdition] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerRecipeEdition.methods:on_init(parent)
	self.panelCaption = ({"helmod_recipe-edition-panel.title"})
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerRecipeEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerRecipeEdition.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerRecipeEdition] on_open
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
function PlannerRecipeEdition.methods:on_open(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	local close = true
	model.moduleListRefresh = false
	if model.guiRecipeLast == nil or model.guiRecipeLast ~= item..item2 then
		close = false
		model.factoryGroupSelected = nil
		model.beaconGroupSelected = nil
		model.moduleListRefresh = true
	end
	model.guiRecipeLast = item..item2
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerRecipeEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerRecipeEdition.methods:on_close(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	model.guiRecipeLast = nil
	model.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create recipe panel
--
-- @function [parent=#PlannerRecipeEdition] getRecipePanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getRecipePanel(player)
	local panel = self:getPanel(player)
	if panel["recipe"] ~= nil and panel["recipe"].valid then
		return panel["recipe"]
	end
	return self:addGuiFlowH(panel, "recipe", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create recipe info panel
--
-- @function [parent=#PlannerRecipeEdition] getObjectInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getObjectInfoPanel(player)
	local panel = self:getRecipePanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameH(panel, "info", "helmod_frame_recipe_info", ({"helmod_common.recipe"}))
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#PlannerRecipeEdition] getOtherInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getOtherInfoPanel(player)
	local panel = self:getRecipePanel(player)
	if panel["other-info"] ~= nil and panel["other-info"].valid then
		return panel["other-info"]
	end
	return self:addGuiFlowV(panel, "other-info", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create ingredients recipe panel
--
-- @function [parent=#PlannerRecipeEdition] getRecipeIngredientsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getRecipeIngredientsPanel(player)
	local panel = self:getOtherInfoPanel(player)
	if panel["ingredients"] ~= nil and panel["ingredients"].valid then
		return panel["ingredients"]
	end
	return self:addGuiFrameV(panel, "ingredients", "helmod_frame_recipe_ingredients", ({"helmod_common.ingredients"}))
end

-------------------------------------------------------------------------------
-- Get or create products recipe panel
--
-- @function [parent=#PlannerRecipeEdition] getRecipeProductsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getRecipeProductsPanel(player)
	local panel = self:getOtherInfoPanel(player)
	if panel["products"] ~= nil and panel["products"].valid then
		return panel["products"]
	end
	return self:addGuiFrameV(panel, "products", "helmod_frame_recipe_products", ({"helmod_common.products"}))
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#PlannerRecipeEdition] getObject
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerRecipeEdition.methods:getObject(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	if  model.blocks[item] ~= nil and model.blocks[item].recipes[item2] ~= nil then
		-- return recipe
		return model.blocks[item].recipes[item2]
	end
	return nil
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#PlannerRecipeEdition] buildHeaderPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:buildHeaderPanel(player)
	Logging:debug("HMPlannerRecipeEdition", "buildHeaderPanel():",player)
	self:getObjectInfoPanel(player)
	self:getRecipeIngredientsPanel(player)
	self:getRecipeProductsPanel(player)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#PlannerRecipeEdition] updateHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerRecipeEdition.methods:updateHeader(player, element, action, item, item2, item3)
	Logging:debug("HMPlannerRecipeEdition", "updateHeader():",player, element, action, item, item2, item3)
	self:updateObjectInfo(player, element, action, item, item2, item3)
	self:updateRecipeIngredients(player, element, action, item, item2, item3)
	self:updateRecipeProducts(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerRecipeEdition] updateObjectInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerRecipeEdition.methods:updateObjectInfo(player, element, action, item, item2, item3)
	Logging:debug("HMPlannerRecipeEdition", "updateObjectInfo():",player, element, action, item, item2, item3)
	local infoPanel = self:getObjectInfoPanel(player)
	local model = self.model:getModel(player)
	local default = self.model:getDefault(player)
	local _recipe = self.player:getRecipe(player, item2)

	local model = self.model:getModel(player)
	if  model.blocks[item] ~= nil then
		local recipe = self:getObject(player, element, action, item, item2, item3)
		if recipe ~= nil then
			Logging:debug("HMPlannerRecipeEdition", "updateObjectInfo():recipe=",recipe)
			for k,guiName in pairs(infoPanel.children_names) do
				infoPanel[guiName].destroy()
			end

			local tablePanel = self:addGuiTable(infoPanel,"table-input",2)
			self:addGuiButtonSprite(tablePanel, "recipe", self.player:getRecipeIconType(player, recipe), recipe.name)
			if _recipe == nil then
				self:addGuiLabel(tablePanel, "label", recipe.name)
			else
				self:addGuiLabel(tablePanel, "label", _recipe.localised_name)
			end


			self:addGuiLabel(tablePanel, "label-energy", ({"helmod_common.energy"}))
			self:addGuiLabel(tablePanel, "energy", recipe.energy)

			self:addGuiLabel(tablePanel, "label-production", ({"helmod_common.production"}))
			self:addGuiText(tablePanel, "production", recipe.production, "helmod_textfield")

			self:addGuiButton(tablePanel, self:classname().."=object-update=ID="..item.."=", recipe.name, "helmod_button_default", ({"helmod_button.update"}))		--
		end
	end
end

-------------------------------------------------------------------------------
-- Update ingredients information
--
-- @function [parent=#PlannerRecipeEdition] updateRecipeIngredients
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerRecipeEdition.methods:updateRecipeIngredients(player, element, action, item, item2, item3)
	Logging:debug("HMPlannerRecipeEdition", "updateRecipeIngredients():",player, element, action, item, item2, item3)
	local ingredientsPanel = self:getRecipeIngredientsPanel(player)
	local model = self.model:getModel(player)
	local recipe = self.player:getRecipe(player, item2)

	if recipe ~= nil then

		for k,guiName in pairs(ingredientsPanel.children_names) do
			ingredientsPanel[guiName].destroy()
		end
		local tablePanel= self:addGuiTable(ingredientsPanel, "table-ingredients", 6)
		for key, ingredient in pairs(recipe.ingredients) do
			local tooltip = nil
			local localisedName = self.player:getLocalisedName(player, ingredient)
			if ingredient.amount ~= nil then
				tooltip = ({"tooltip.element-amount", localisedName, ingredient.amount})
			else
				tooltip = ({"tooltip.element-amount-probability", localisedName, ingredient.amount_min, ingredient.amount_max, ingredient.probability})
			end
			self:addGuiButtonSpriteSm(tablePanel, "item=ID=", self.player:getIconType(ingredient), ingredient.name, ingredient.name, tooltip)
			self:addGuiLabel(tablePanel, ingredient.name, self.model:getElementAmount(ingredient), "helmod_label_sm")
		end
	end
end

-------------------------------------------------------------------------------
-- Update products information
--
-- @function [parent=#PlannerRecipeEdition] updateRecipeProducts
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerRecipeEdition.methods:updateRecipeProducts(player, element, action, item, item2, item3)
	Logging:debug("HMPlannerRecipeEdition", "updateRecipeProducts():",player, element, action, item, item2, item3)
	local productsPanel = self:getRecipeProductsPanel(player)
	local model = self.model:getModel(player)
	local recipe = self.player:getRecipe(player, item2)

	if recipe ~= nil then

		for k,guiName in pairs(productsPanel.children_names) do
			productsPanel[guiName].destroy()
		end
		local tablePanel= self:addGuiTable(productsPanel, "table-products", 6)
		for key, product in pairs(recipe.products) do
			local tooltip = nil
			local localisedName = self.player:getLocalisedName(player, product)
			if product.amount ~= nil then
				tooltip = ({"tooltip.element-amount", localisedName, product.amount})
			else
				tooltip = ({"tooltip.element-amount-probability", localisedName, product.amount_min, product.amount_max, product.probability})
			end
			self:addGuiButtonSpriteSm(tablePanel, "item=ID=", self.player:getIconType(product), product.name, product.name, tooltip)
			self:addGuiLabel(tablePanel, product.name, self.model:getElementAmount(product), "helmod_label_sm")
		end
	end
end