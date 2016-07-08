PlannerRecipeEdition = setclass("HMPlannerRecipeEdition", PlannerDialog)

function PlannerRecipeEdition.methods:on_init(parent)
	self.panelCaption = "Recipe"
	self.player = self.parent.parent
	self.model = self.parent.model
end

--===========================
function PlannerRecipeEdition.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiRecipeLast == nil or self.guiRecipeLast ~= item then
		close = false
	end
	self.guiRecipeLast = item
	return close
end

--===========================
function PlannerRecipeEdition.methods:on_close(element, action, item, item2)
	self.guiRecipeLast = nil
end

--===========================
function PlannerRecipeEdition.methods:after_open(element, action, item, item2)
	self.guiInfo = self:addGuiFlowV(self.gui, "info")
	self.guiIngredients = self:addGuiFrameV(self.gui, "ingredients", nil, "Ingredients")
	self.guiProducts = self:addGuiFrameV(self.gui, "products", nil, "Products")
end

--===========================
function PlannerRecipeEdition.methods:on_update(element, action, item, item2)
	self.recipe = self.model.recipes[item]
	if self.recipe ~= nil then
		self:updateInfo(element, action, item, item2)
		self:updateIngredients(element, action, item, item2)
		self:updateProducts(element, action, item, item2)
	end
end

--===========================
function PlannerRecipeEdition.methods:updateInfo(element, action, item, item2)
	for k,guiName in pairs(self.guiInfo.children_names) do
		self.guiInfo[guiName].destroy()
	end
	self:addIconButton(self.guiInfo, "recipe", "recipe", self.recipe.name)
	local guiTable= self:addGuiTable(self.guiInfo, "table-recipe", 2)
	self:addGuiLabel(guiTable, "label-active", "Active")
	self:addGuiCheckbox(guiTable, self:classname().."_recipe-active_ID_"..self.recipe.name, self.recipe.valid)
end

--===========================
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

--===========================
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

--===========================
function PlannerRecipeEdition.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "recipe-active" then
		self.model:setActiveRecipe(item)
		self.model:update()
		self.parent:refreshDisplayData()
		self:close()
	end
end
















































































































































