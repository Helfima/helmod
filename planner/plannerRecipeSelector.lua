PlannerRecipeSelector = setclass("HMPlannerRecipeSelector", PlannerDialog)

function PlannerRecipeSelector.methods:on_init(parent)
	self.panelCaption = "Recipe Selector"
	self.player = self.parent.parent
end

--===========================
function PlannerRecipeSelector.methods:on_open(element, action, item, item2)
	-- close si nouvel appel
	return true
end

--===========================
function PlannerRecipeSelector.methods:after_open(element, action, item, item2)
	-- ajouter de la table des groupes de recipe
	self.guiRecipeSelectorGroups = self:addGuiTable(self.gui, "recipe-groups", 10)
	for group, name in pairs(self.player:getRecipeGroups()) do
		-- set le groupe
		if self.recipeGroupSelected == nil then self.recipeGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addIconCheckbox(self.guiRecipeSelectorGroups, self:classname().."_recipe-group_ID_", "item-group", group, true)
	end
end

--===========================
function PlannerRecipeSelector.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "recipe-group" then
		self.recipeGroupSelected = item
		element.state = true
		self:on_update(element, action, item, item2)
	end
	
	if action == "recipe-select" then
		self.parent.model:addInput(item)
		self.parent.model:update()
		self.parent:refreshDisplayData()
		self:close()
	end
	
end

--===========================
function PlannerRecipeSelector.methods:on_update(element, action, item, item2)
	if self.guiRecipeSelectorTable ~= nil  and self.guiRecipeSelectorTable.valid then
		self.guiRecipeSelectorTable.destroy()
	end

	self.guiRecipeSelectorTable = self:addGuiTable(self.gui, "recipe-table", 10)
	for key, recipe in pairs(self.player:getRecipes()) do
		if recipe.group.name == self.recipeGroupSelected then
			self:addIconCheckbox(self.guiRecipeSelectorTable, self:classname().."_recipe-select_ID_", self.player:getRecipeIconType(recipe), recipe.name, true)
		end
	end

end
