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
-- Get or create groups panel
--
-- @function [parent=#PlannerRecipeSelector] getGroupsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeSelector.methods:getGroupsPanel(player)
	local panel = self:getPanel(player)
	if panel["groups-panel"] ~= nil and panel["groups-panel"].valid then
		return panel["groups-panel"]["scroll-groups"]
	end
	local groupsPanel = self:addGuiFrameV(panel, "groups-panel", "helmod_frame_resize_row_width")
	return self:addGuiScrollPane(groupsPanel, "scroll-groups", "helmod_scroll_recipe_selector_group", "auto", "auto")
end

-------------------------------------------------------------------------------
-- Get or create item list panel
--
-- @function [parent=#PlannerRecipeSelector] getItemListPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeSelector.methods:getItemListPanel(player)
	local panel = self:getPanel(player)
	if panel["item-list-panel"] ~= nil and panel["item-list-panel"].valid then
		return panel["item-list-panel"]["scroll-list"]
	end
	local listPanel = self:addGuiFrameV(panel, "item-list-panel", "helmod_frame_resize_row_width")
	return self:addGuiScrollPane(listPanel, "scroll-list", "helmod_scroll_recipe_selector_list", "auto", "auto")
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
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
-- @return #boolean if true the next call close dialog
--  
function PlannerRecipeSelector.methods:on_open(player, element, action, item, item2, item3)
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
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerRecipeSelector.methods:after_open(player, element, action, item, item2, item3)
	self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
	self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
	self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
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
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerRecipeSelector.methods:on_event(player, element, action, item, item2, item3)
	Logging:debug("PlannerRecipeSelector:on_event():",player, element, action, item, item2, item3)
	local globalPlayer = self.player:getGlobal(player)
	if action == "recipe-group" then
		globalPlayer.recipeGroupSelected = item2
		self:on_update(player, element, action, item, item2, item3)
	end
	
	if action == "recipe-select" then
		local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, item, item2)
		self.parent.model:update(player)
		self.parent:refreshDisplayData(player, nil, productionBlock.id)
		--self.parent:send_event(player, "HMPlannerRecipeUpdate", "OPEN", item, nil)
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
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerRecipeSelector.methods:on_update(player, element, action, item, item2, item3)
	Logging:trace("PlannerRecipeSelector:on_update():",player, element, action, item, item2, item3)
	self:updateGroupSelector(player, element, action, item, item2, item3)
	self:updateItemList(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update item list
--
-- @function [parent=#PlannerRecipeSelector] updateItemList
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerRecipeSelector.methods:updateItemList(player, element, action, item, item2, item3)
	Logging:trace("PlannerRecipeSelector:updateItemList():",player, element, action, item, item2, item3)
	local globalPlayer = self.player:getGlobal(player)
	local panel = self:getItemListPanel(player)
	
	if panel["recipe-table"] ~= nil  and panel["recipe-table"].valid then
		panel["recipe-table"].destroy()
	end

	local guiRecipeSelectorTable = self:addGuiTable(panel, "recipe-table", 10)
	for key, recipe in pairs(self.player:getRecipes(player)) do
		if recipe.group.name == globalPlayer.recipeGroupSelected then
			Logging:trace("PlannerRecipeSelector:on_update",recipe.name)
			self:addSelectSpriteIconButton(guiRecipeSelectorTable, self:classname().."=recipe-select=ID="..item.."=", self.player:getRecipeIconType(player, recipe), recipe.name, recipe.name, nil, recipe.localised_name)
		end
	end

end

-------------------------------------------------------------------------------
-- Update group selector
--
-- @function [parent=#PlannerRecipeSelector] updateGroupSelector
-- 
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function PlannerRecipeSelector.methods:updateGroupSelector(player, element, action, item, item2, item3)
	Logging:trace("PlannerRecipeSelector:updateGroupSelector():",player, element, action, item, item2, item3)
	local globalPlayer = self.player:getGlobal(player)
	local panel = self:getGroupsPanel(player)
	
	if panel["recipe-groups"] ~= nil  and panel["recipe-groups"].valid then
		panel["recipe-groups"].destroy()
	end

	-- ajouter de la table des groupes de recipe
	local guiRecipeSelectorGroups = self:addGuiTable(panel, "recipe-groups", 6)
	for group, name in pairs(self.player:getRecipeGroups(player)) do
		-- set le groupe
		if globalPlayer.recipeGroupSelected == nil then globalPlayer.recipeGroupSelected = group end
		local color = nil
		if globalPlayer.recipeGroupSelected == group then
			color = "yellow"
		end
		local tooltip = group
		-- ajoute les icons de groupe
		local action = self:addXxlSelectSpriteIconButton(guiRecipeSelectorGroups, self:classname().."=recipe-group=ID="..item.."=", "item-group", group, group, color, tooltip)
	end

end
