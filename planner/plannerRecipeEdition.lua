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
-- On open
--
-- @function [parent=#PlannerRecipeEdition] on_open
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerRecipeEdition.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiRecipeLast == nil or self.guiRecipeLast ~= item then
		close = false
	end
	self.guiRecipeLast = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerRecipeEdition] on_close
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:on_close(element, action, item, item2)
	self.guiRecipeLast = nil
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerRecipeEdition] after_open
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:after_open(element, action, item, item2)
	self.guiInfo = self:addGuiFlowV(self.gui, "info")
	self.guiIngredients = self:addGuiFrameV(self.gui, "ingredients", "helmod_recipe-table-frame", "Ingredients")
	self.guiProducts = self:addGuiFrameV(self.gui, "products", "helmod_recipe-table-frame", "Products")
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerRecipeEdition] on_update
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:on_update(element, action, item, item2)
	self.recipe = self.player:getRecipe(item)
	if self.recipe ~= nil then
		self:updateInfo(element, action, item, item2)
		self:updateIngredients(element, action, item, item2)
		self:updateProducts(element, action, item, item2)
	end
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerRecipeEdition] updateInfo
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:updateInfo(element, action, item, item2)
	for k,guiName in pairs(self.guiInfo.children_names) do
		self.guiInfo[guiName].destroy()
	end
	local guiTableHeader = self:addGuiTable(self.guiInfo,"table-header",2)
	self:addIconButton(guiTableHeader, "recipe", "recipe", self.recipe.name)
	self:addGuiLabel(guiTableHeader, "label", self.recipe.name)

	local guiTable= self:addGuiTable(self.guiInfo, "table-recipe", 2)
	self:addGuiLabel(guiTable, "label-active", "Active")

	local actived = true
	if self.model.recipes[item] ~= nil then
		actived = self.model.recipes[item].active
	elseif self.model.global.recipes[item] ~= nil then
		actived = self.model.global.recipes[item].active
	end
	self:addGuiCheckbox(guiTable, self:classname().."_recipe-active_ID_"..self.recipe.name, actived)
end

-------------------------------------------------------------------------------
-- Update ingredients information
--
-- @function [parent=#PlannerRecipeEdition] updateIngredients
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:updateIngredients(element, action, item, item2)
	for k,guiName in pairs(self.guiIngredients.children_names) do
		self.guiIngredients[guiName].destroy()
	end
	local guiTable= self:addGuiTable(self.guiIngredients, "table-ingredients", 2)
	for key, ingredient in pairs(self.recipe.ingredients) do
		self:addIconButton(guiTable, "item_ID_", self.player:getItemIconType(ingredient), ingredient.name)
		self:addGuiLabel(guiTable, ingredient.name, ingredient.amount)
	end
end

-------------------------------------------------------------------------------
-- Update products information
--
-- @function [parent=#PlannerRecipeEdition] updateProducts
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:updateProducts(element, action, item, item2)
	for k,guiName in pairs(self.guiProducts.children_names) do
		self.guiProducts[guiName].destroy()
	end
	local guiTable= self:addGuiTable(self.guiProducts, "table-products", 2)
	for key, product in pairs(self.recipe.products) do
		self:addIconButton(guiTable, "item_ID_", self.player:getItemIconType(product), product.name)
		self:addGuiLabel(guiTable, product.name, product.amount)
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerRecipeEdition] on_event
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeEdition.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "recipe-active" then
		self.model:setActiveRecipe(item)
		self.model:update()
		self.parent:refreshDisplayData()
		self:close()
	end
end
