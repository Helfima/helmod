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
-- Get the parent panel
--
-- @function [parent=#PlannerRecipeSelector] getParentPanel
-- 
-- @param #LuaPlayer player
-- 
-- @return #LuaGuiElement
-- 
function PlannerRecipeSelector.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end
-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerRecipeSelector] on_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
-- @return #boolean if true the next call close dialog
--  
function PlannerRecipeSelector.methods:on_open(player, element, action, item, item2)
	-- close si nouvel appel
	return true
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerRecipeSelector] after_open
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerRecipeSelector.methods:after_open(player, element, action, item, item2)
	local globalPlayer = self.player:getGlobal(player)
	-- ajouter de la table des groupes de recipe
	local panel = self:getPanel(player)
	local guiRecipeSelectorGroups = self:addGuiTable(panel, "recipe-groups", 10)
	for group, name in pairs(self.player:getRecipeGroups(player)) do
		-- set le groupe
		if globalPlayer.recipeGroupSelected == nil then globalPlayer.recipeGroupSelected = group end
		-- ajoute les icons de groupe
		local action = self:addXxlSelectSpriteIconButton(guiRecipeSelectorGroups, self:classname().."_recipe-group_ID_", "item-group", group)
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerRecipeSelector] on_event
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerRecipeSelector.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerRecipeSelector:on_event():",player, element, action, item, item2)
	local globalPlayer = self.player:getGlobal(player)
	if action == "recipe-group" then
		globalPlayer.recipeGroupSelected = item
		self:on_update(player, element, action, item, item2)
	end
	
	if action == "recipe-select" then
		self.parent.model:addInput(player, item)
		self.parent.model:update(player)
		self.parent:refreshDisplayData(player)
		self:close(player)
	end
	
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerRecipeSelector] on_update
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
-- 
function PlannerRecipeSelector.methods:on_update(player, element, action, item, item2)
	Logging:trace("PlannerRecipeSelector:on_update():",player, element, action, item, item2)
	local globalPlayer = self.player:getGlobal(player)
	local panel = self:getPanel(player)
	
	if panel["recipe-table"] ~= nil  and panel["recipe-table"].valid then
		panel["recipe-table"].destroy()
	end

	local guiRecipeSelectorTable = self:addGuiTable(panel, "recipe-table", 10)
	for key, recipe in pairs(self.player:getRecipes(player)) do
		if recipe.group.name == globalPlayer.recipeGroupSelected then
			Logging:trace("PlannerRecipeSelector:on_update",recipe.name)
			self:addSelectSpriteIconButton(guiRecipeSelectorTable, self:classname().."_recipe-select_ID_", self.player:getRecipeIconType(player, recipe), recipe.name)
		end
	end

end
