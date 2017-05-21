-------------------------------------------------------------------------------
-- Classe to build selector dialog
--
-- @module PlannerAbstractSelector
-- @extends #PlannerDialog
--

PlannerAbstractSelector = setclass("HMPlannerAbstractSelector", PlannerDialog)

local groupList = {}
local prototypeGroups = {}
local prototypeFilter = nil
local prototypeFilterProduct = true

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#PlannerAbstractSelector] getProductFilter
--
-- @return #table
--
function PlannerAbstractSelector.methods:getProductFilter()
  return prototypeFilterProduct
end

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#PlannerAbstractSelector] getFilter
--
-- @return #table
--
function PlannerAbstractSelector.methods:getFilter()
  return prototypeFilter
end

-------------------------------------------------------------------------------
-- Return groups
--
-- @function [parent=#PlannerAbstractSelector] getGroups
--
-- @return #table
--
function PlannerAbstractSelector.methods:getGroups()
  return groupList
end

-------------------------------------------------------------------------------
-- Set groups
--
-- @function [parent=#PlannerAbstractSelector] getGroups
--
-- @param #table list
--
-- @return #table
--
function PlannerAbstractSelector.methods:setGroups(list)
  groupList = list
end

-------------------------------------------------------------------------------
-- Return prototype groups
--
-- @function [parent=#PlannerAbstractSelector] getPrototypeGroups
--
-- @return #table
--
function PlannerAbstractSelector.methods:getPrototypeGroups()
  return prototypeGroups
end

-------------------------------------------------------------------------------
-- Set prototype groups
--
-- @function [parent=#PlannerAbstractSelector] getPrototypeGroups
--
-- @param #table list
--
-- @return #table
--
function PlannerAbstractSelector.methods:setPrototypeGroups(list)
  prototypeGroups = list
end

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#PlannerAbstractSelector] getCaption
--
-- @param #PlannerController parent parent controller
--
function PlannerAbstractSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerAbstractSelector] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerAbstractSelector.methods:on_init(parent)
  self.panelCaption = self:getCaption(parent)
  self.player = self.parent.player
  self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerAbstractSelector] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerAbstractSelector.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create filter panel
--
-- @function [parent=#PlannerAbstractSelector] getFilterPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractSelector.methods:getFilterPanel(player)
  local panel = self:getPanel(player)
  if panel["filter-panel"] ~= nil and panel["filter-panel"].valid then
    return panel["filter-panel"]
  end
  return self:addGuiFrameV(panel, "filter-panel", "helmod_frame_resize_row_width", ({"helmod_common.filter"}))
end

-------------------------------------------------------------------------------
-- Get or create scroll panel
--
-- @function [parent=#PlannerAbstractSelector] getSrollPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractSelector.methods:getSrollPanel(player)
  local panel = self:getPanel(player)
  if panel["main-panel"] ~= nil and panel["main-panel"].valid then
    return panel["main-panel"]["scroll-panel"]
  end
  local mainPanel = self:addGuiFrameV(panel, "main-panel", "helmod_frame_resize_row_width")
  local panel = self:addGuiScrollPane(mainPanel, "scroll-panel", "helmod_scroll_recipe_selector", "auto", "auto")
  self.player:setStyle(player, panel, "scroll_recipe_selector", "minimal_height")
  self.player:setStyle(player, panel, "scroll_recipe_selector", "maximal_height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create groups panel
--
-- @function [parent=#PlannerAbstractSelector] getGroupsPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractSelector.methods:getGroupsPanel(player)
  local panel = self:getSrollPanel(player)
  if panel["groups-panel"] ~= nil and panel["groups-panel"].valid then
    return panel["groups-panel"]
  end
  return self:addGuiFlowV(panel, "groups-panel", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create item list panel
--
-- @function [parent=#PlannerAbstractSelector] getItemListPanel
--
-- @param #LuaPlayer player
--
function PlannerAbstractSelector.methods:getItemListPanel(player)
  local panel = self:getSrollPanel(player)
  if panel["item-list-panel"] ~= nil and panel["item-list-panel"].valid then
    return panel["item-list-panel"]
  end
  return self:addGuiFlowV(panel, "item-list-panel", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerAbstractSelector] on_open
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
function PlannerAbstractSelector.methods:on_open(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerAbstractSelector", "on_open():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  if item3 ~= nil then
    prototypeFilter = item3:lower():gsub("[-]"," ")
  else
    prototypeFilter = nil
  end
  prototypeFilterProduct = true
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerAbstractSelector] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:after_open(player, element, action, item, item2, item3)
  self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
  self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
  self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
  if self:classname() ~= "HMPlannerRecipeSelector" then self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE") end
  if self:classname() ~= "HMPlannerTechnologySelector" then self.parent:send_event(player, "HMPlannerTechnologySelector", "CLOSE") end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerAbstractSelector] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerAbstractSelector", "on_event():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  local globalSettings = self.player:getGlobal(player, "settings")
  local defaultSettings = self.player:getDefaultSettings()

  local model = self.model:getModel(player)
  if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "recipe-select" then
      local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, item)
      self.parent.model:update(player)
      self.parent:refreshDisplayData(player)
      self:close(player)
    end
  end
  if action == "recipe-group" then
    globalPlayer.recipeGroupSelected = item
    self:on_update(player, element, action, item, item2, item3)
  end

  if action == "change-boolean-settings" then
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    globalSettings[item] = not(globalSettings[item])
    self:on_update(player, item, item2, item3)
  end

  if action == "recipe-filter-switch" then
    prototypeFilterProduct = not(prototypeFilterProduct)
    self:on_update(player, element, action, item, item2, item3)
  end

  if action == "recipe-filter" then
    prototypeFilter = element.text
    self:on_update(player, element, action, item, item2, item3)
  end

end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#PlannerAbstractSelector] updateGroups
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {groupList, prototypeGroups}
--
function PlannerAbstractSelector.methods:updateGroups(player, element, action, item, item2, item3)
  Logging:trace("HMPlannerAbstractSelector", "updateGroups():",player, element, action, item, item2, item3)
  return {},{}
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerAbstractSelector] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:on_update(player, element, action, item, item2, item3)
  Logging:trace("HMPlannerAbstractSelector", "on_update():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  -- recuperation recipes
  groupList , prototypeGroups = self:updateGroups(player, element, action, item, item2, item3)

  self:updateFilter(player, element, action, item, item2, item3)
  self:updateGroupSelector(player, element, action, item, item2, item3)
  self:updateItemList(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update filter
--
-- @function [parent=#PlannerAbstractSelector] updateFilter
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:updateFilter(player, element, action, item, item2, item3)
  Logging:trace("HMPlannerAbstractSelector", "updateFilter():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  local panel = self:getFilterPanel(player)
  local globalSettings = self.player:getGlobal(player, "settings")

  if panel["filter"] == nil then
    local guiFilter = self:addGuiTable(panel, "filter", 2)
    local filter_show_hidden = self.player:getGlobalSettings(player, "filter_show_hidden")
    self:addGuiCheckbox(guiFilter, self:classname().."=change-boolean-settings=ID=filter_show_hidden", filter_show_hidden)
    self:addGuiLabel(guiFilter, "filter_show_hidden", ({"helmod_recipe-edition-panel.filter-show-hidden"}))

    self:addGuiCheckbox(guiFilter, self:classname().."=recipe-filter-switch=ID=filter-product", prototypeFilterProduct)
    self:addGuiLabel(guiFilter, "filter-product", ({"helmod_recipe-edition-panel.filter-by-product"}))

    self:addGuiCheckbox(guiFilter, self:classname().."=recipe-filter-switch=ID=filter-ingredient", not(prototypeFilterProduct))
    self:addGuiLabel(guiFilter, "filter-ingredient", ({"helmod_recipe-edition-panel.filter-by-ingredient"}))

    self:addGuiLabel(guiFilter, "filter-value", ({"helmod_common.filter"}))
    self:addGuiText(guiFilter, self:classname().."=recipe-filter=ID=filter-value", prototypeFilter)

    self:addGuiLabel(panel, "message", ({"helmod_recipe-edition-panel.message"}))
  else
    panel["filter"][self:classname().."=recipe-filter-switch=ID=filter-product"].state = prototypeFilterProduct
    panel["filter"][self:classname().."=recipe-filter-switch=ID=filter-ingredient"].state = not(prototypeFilterProduct)
  end

end

-------------------------------------------------------------------------------
-- Update item list
--
-- @function [parent=#PlannerAbstractSelector] updateItemList
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:updateItemList(player, element, action, item, item2, item3)
  Logging:trace("HMPlannerAbstractSelector", "updateItemList():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  local panel = self:getItemListPanel(player)

  if panel["recipe-list"] ~= nil  and panel["recipe-list"].valid then
    panel["recipe-list"].destroy()
  end

  -- recuperation recipes et subgroupes
  local list = self:getItemList(player, element, action, item, item2, item3)

  --local guiRecipeSelectorTable = self:addGuiTable(panel, "recipe-table", 10)
  local guiRecipeSelectorList = self:addGuiFlowV(panel, "recipe-list", "helmod_flow_recipe_selector")
  for key, subgroup in pairs(list) do
    -- boucle subgroup
    local guiRecipeSubgroup = self:addGuiTable(guiRecipeSelectorList, "recipe-table-"..key, 10, "helmod_table_recipe_selector")
    for key, prototype in spairs(subgroup,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
      --Logging:trace("HMPlannerAbstractSelector", "updateItemList():recipe", recipe.name, recipe.category, recipe.group.name, recipe.group.order, recipe.subgroup.name, recipe.subgroup.order, recipe.order)

      local tooltip = self:buildPrototypeTooltip(player, prototype)
      self:buildPrototypeIcon(player, guiRecipeSubgroup, prototype, tooltip)
    end
  end

end

-------------------------------------------------------------------------------
-- Get item list
--
-- @function [parent=#PlannerAbstractSelector] getItemList
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:getItemList(player, element, action, item, item2, item3)
  Logging:trace("HMPlannerAbstractSelector", "getItemList():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  local list = {}
  if prototypeGroups[globalPlayer.recipeGroupSelected] ~= nil then
    list = prototypeGroups[globalPlayer.recipeGroupSelected]
  end
  return list
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#PlannerAbstractSelector] buildPrototypeTooltip
--
-- @param #LuaPlayer player
--
function PlannerAbstractSelector.methods:buildPrototypeTooltip(player, prototype)
  Logging:trace("HMPlannerAbstractSelector", "buildPrototypeTooltip(player, element):",player, prototype)
  -- initalize tooltip
  local tooltip = ""
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#PlannerAbstractSelector] buildPrototypeIcon
--
-- @param #LuaPlayer player
--
function PlannerAbstractSelector.methods:buildPrototypeIcon(player, guiElement, prototype, tooltip)
  Logging:trace("HMPlannerAbstractSelector", "buildPrototypeIcon(player, guiElement, prototype, tooltip:",player, guiElement, prototype, tooltip)
  self:addGuiButtonSelectSprite(guiElement, self:classname().."=recipe-select=ID=", self.player:getRecipeIconType(player, prototype), prototype.name, prototype.name, tooltip)
end

-------------------------------------------------------------------------------
-- Update group selector
--
-- @function [parent=#PlannerAbstractSelector] updateGroupSelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerAbstractSelector.methods:updateGroupSelector(player, element, action, item, item2, item3)
  Logging:trace("HMPlannerAbstractSelector", "updateGroupSelector():",player, element, action, item, item2, item3)
  local globalPlayer = self.player:getGlobal(player)
  local panel = self:getGroupsPanel(player)

  if panel["recipe-groups"] ~= nil  and panel["recipe-groups"].valid then
    panel["recipe-groups"].destroy()
  end

  Logging:debug("HMPlannerAbstractSelector", "groupList:",groupList)

  -- ajouter de la table des groupes de recipe
  local guiRecipeSelectorGroups = self:addGuiTable(panel, "recipe-groups", 6, "helmod_table_recipe_selector")
  for _, group in spairs(groupList,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    -- set le groupe
    if globalPlayer.recipeGroupSelected == nil then globalPlayer.recipeGroupSelected = group.name end
    local color = nil
    if globalPlayer.recipeGroupSelected == group.name then
      color = "yellow"
    end
    local tooltip = "item-group-name."..group.name
    -- ajoute les icons de groupe
    local action = self:addGuiButtonSelectSpriteXxl(guiRecipeSelectorGroups, self:classname().."=recipe-group=ID=", "item-group", group.name, group.name, ({tooltip}), color)
  end

end
