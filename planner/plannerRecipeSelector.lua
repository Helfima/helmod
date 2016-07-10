-------------------------------------------------------------------------------
-- Classe to build recipe dialog
-- 
-- @module PlannerRecipeSelector
-- @extends #PlannerDialog 
-- 

PlannerRecipeSelector = setclass("HMPlannerRecipeSelector", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerRecipeSelector] on_init
-- 
-- @param #PlannerController parent parent controller
-- 
function PlannerRecipeSelector.methods:on_init(parent)
	self.panelCaption = "Recipe Selector"
	self.player = self.parent.parent
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerRecipeSelector] on_open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
-- @return #boolean if true the next call close dialog
--  
function PlannerRecipeSelector.methods:on_open(element, action, item, item2)
	-- close si nouvel appel
	return true
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerRecipeSelector] after_open
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerRecipeSelector.methods:after_open(element, action, item, item2)
	-- ajouter de la table des groupes de recipe
	self.guiRecipeSelectorGroups = self:addGuiTable(self.gui, "recipe-groups", 10)
	for group, name in pairs(self.player:getRecipeGroups()) do
		-- set le groupe
		if self.recipeGroupSelected == nil then self.recipeGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addXxlSelectSpriteIconButton(self.guiRecipeSelectorGroups, self:classname().."_recipe-group_ID_", "item-group", group)
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerRecipeSelector] on_event
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerRecipeSelector.methods:on_event(element, action, item, item2)
	Logging:trace("on_event:",action, item, item2)
	if action == "recipe-group" then
		self.recipeGroupSelected = item
		self:on_update(element, action, item, item2)
	end
	
	if action == "recipe-select" then
		self.parent.model:addInput(item)
		self.parent.model:update()
		self.parent:refreshDisplayData()
		self:close()
	end
	
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerRecipeSelector] on_update
-- 
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerRecipeSelector.methods:on_update(element, action, item, item2)
	if self.guiRecipeSelectorTable ~= nil  and self.guiRecipeSelectorTable.valid then
		self.guiRecipeSelectorTable.destroy()
	end

	self.guiRecipeSelectorTable = self:addGuiTable(self.gui, "recipe-table", 10)
	for key, recipe in pairs(self.player:getRecipes()) do
		if recipe.group.name == self.recipeGroupSelected then
			Logging:trace("PlannerRecipeSelector:on_update",recipe.name)
			self:addSelectSpriteIconButton(self.guiRecipeSelectorTable, self:classname().."_recipe-select_ID_", self.player:getRecipeIconType(recipe), recipe.name)
		end
	end

end
