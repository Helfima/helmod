-------------------------------------------------------------------------------
-- Classe to build recipe edition dialog
--
-- @module PlannerRecipeEdition
-- @extends #PlannerDialog
--

PlannerRecipeEdition = setclass("HMPlannerRecipeEdition", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerRecipeEdition] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerRecipeEdition.methods:on_init(parent)
	self.panelCaption = "Recipe"
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
-- @param #string item second item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerRecipeEdition.methods:on_open(player, element, action, item, item2)
	local model = self.model:getModel(player)
	local close = true
	if model.guiRecipeLast == nil or model.guiRecipeLast ~= item then
		close = false
	end
	model.guiRecipeLast = item
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
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:on_close(player, element, action, item, item2)
	local model = self.model:getModel(player)
	model.guiRecipeLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerRecipeEdition] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameV(panel, "info", "helmod_module-table-frame")
end

-------------------------------------------------------------------------------
-- Get or create ingredients panel
--
-- @function [parent=#PlannerRecipeEdition] getIngredientsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getIngredientsPanel(player)
	local panel = self:getPanel(player)
	if panel["ingredients"] ~= nil and panel["ingredients"].valid then
		return panel["ingredients"]
	end
	return self:addGuiFrameV(panel, "ingredients", "helmod_module-table-frame", "Ingredients")
end

-------------------------------------------------------------------------------
-- Get or create products panel
--
-- @function [parent=#PlannerRecipeEdition] getProductsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeEdition.methods:getProductsPanel(player)
	local panel = self:getPanel(player)
	if panel["products"] ~= nil and panel["products"].valid then
		return panel["products"]
	end
	return self:addGuiFrameV(panel, "products", "helmod_module-table-frame", "Products")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerRecipeEdition] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:after_open(player, element, action, item, item2)
	self:getInfoPanel(player)
	self:getIngredientsPanel(player)
	self:getProductsPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerRecipeEdition] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:on_update(player, element, action, item, item2)
	Logging:debug("PlannerRecipeEdition:on_update():",player, element, action, item, item2)
	self:updateInfo(player, element, action, item, item2)
	self:updateIngredients(player, element, action, item, item2)
	self:updateProducts(player, element, action, item, item2)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerRecipeEdition] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:updateInfo(player, element, action, item, item2)
	Logging:debug("PlannerRecipeEdition:updateInfo():",player, element, action, item, item2)
	local infoPanel = self:getInfoPanel(player)
	local model = self.model:getModel(player)
	local default = self.model:getDefault(player)
	local recipe = self.player:getRecipe(player, item)

	if recipe ~= nil then
		Logging:debug("PlannerRecipeEdition:updateInfo():recipe=",recipe)
		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local tablePanel = self:addGuiTable(infoPanel,"table-info",2)
		self:addIconButton(tablePanel, "recipe", "recipe", recipe.name)
		self:addGuiLabel(tablePanel, "label", recipe.name)

		self:addGuiLabel(tablePanel, "label-active", "Active")

		local actived = true
		if model.recipes[item] ~= nil then
			actived = model.recipes[item].active
		elseif default.recipes[item] ~= nil then
			actived = default.recipes[item].active
		end
		self:addGuiCheckbox(tablePanel, self:classname().."=recipe-active=ID="..recipe.name, actived)
	end
end

-------------------------------------------------------------------------------
-- Update ingredients information
--
-- @function [parent=#PlannerRecipeEdition] updateIngredients
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:updateIngredients(player, element, action, item, item2)
	local ingredientsPanel = self:getIngredientsPanel(player)
	local model = self.model:getModel(player)
	local recipe = self.player:getRecipe(player, item)

	if recipe ~= nil then

		for k,guiName in pairs(ingredientsPanel.children_names) do
			ingredientsPanel[guiName].destroy()
		end
		local tablePanel= self:addGuiTable(ingredientsPanel, "table-ingredients", 2)
		for key, ingredient in pairs(recipe.ingredients) do
			self:addIconButton(tablePanel, "item=ID=", self.player:getItemIconType(ingredient), ingredient.name)
			self:addGuiLabel(tablePanel, ingredient.name, ingredient.amount)
		end
	end
end

-------------------------------------------------------------------------------
-- Update products information
--
-- @function [parent=#PlannerRecipeEdition] updateProducts
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:updateProducts(player, element, action, item, item2)
	local productsPanel = self:getProductsPanel(player)
	local model = self.model:getModel(player)
	local recipe = self.player:getRecipe(player, item)

	if recipe ~= nil then

		for k,guiName in pairs(productsPanel.children_names) do
			productsPanel[guiName].destroy()
		end
		local tablePanel= self:addGuiTable(productsPanel, "table-products", 2)
		for key, product in pairs(recipe.products) do
			self:addIconButton(tablePanel, "item=ID=", self.player:getItemIconType(product), product.name)
			self:addGuiLabel(tablePanel, product.name, product.amount)
		end
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerRecipeEdition] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerRecipeEdition:on_event():",player, element, action, item, item2)
	if action == "recipe-active" then
		self.model:setActiveRecipe(player, item)
		self.model:update(player)
		self.parent:refreshDisplayData(player)
		self:close(player)
	end
end
