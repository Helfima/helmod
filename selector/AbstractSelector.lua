-------------------------------------------------------------------------------
-- Classe to build selector dialog
--
-- @module AbstractSelector
-- @extends #Dialog
--

AbstractSelector = setclass("HMAbstractSelector", Dialog)

local list_group = {}
local list_subgroup = {}
local list_prototype = {}
local filter_prototype = nil
local filter_prototype_product = true

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#AbstractSelector] getProductFilter
--
-- @return #table
--
function AbstractSelector.methods:getProductFilter()
  return filter_prototype_product
end

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#AbstractSelector] getFilter
--
-- @return #table
--
function AbstractSelector.methods:getFilter()
  return filter_prototype
end

-------------------------------------------------------------------------------
-- Return groups
--
-- @function [parent=#AbstractSelector] getGroups
--
-- @return #table
--
function AbstractSelector.methods:getGroups()
  return list_group
end

-------------------------------------------------------------------------------
-- Set groups
--
-- @function [parent=#AbstractSelector] getGroups
--
-- @param #table list
--
-- @return #table
--
function AbstractSelector.methods:setGroups(list)
  list_group = list
end

-------------------------------------------------------------------------------
-- Return list prototype
--
-- @function [parent=#AbstractSelector] getListPrototype
--
-- @return #table
--
function AbstractSelector.methods:getListPrototype()
  return list_prototype
end

-------------------------------------------------------------------------------
-- Set list prototype
--
-- @function [parent=#AbstractSelector] setListPrototype
--
-- @param #table list
--
-- @return #table
--
function AbstractSelector.methods:setListPrototype(list)
  list_prototype = list
end

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#AbstractSelector] getCaption
--
-- @param #Controller parent parent controller
--
function AbstractSelector.methods:getCaption(parent)
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#AbstractSelector] onInit
--
-- @param #Controller parent parent controller
--
function AbstractSelector.methods:onInit(parent)
  self.panelCaption = self:getCaption(parent)
  self:afterInit()
end

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#AbstractSelector] afterInit
--
function AbstractSelector.methods:afterInit()
  Logging:debug(self:classname(), "afterInit()")
  self.disable_option = false
  self.hidden_option = false
  self.product_option = false
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#AbstractSelector] getParentPanel
--
-- @return #LuaGuiElement
--
function AbstractSelector.methods:getParentPanel()
  return self.parent:getDialogPanel()
end

-------------------------------------------------------------------------------
-- Get or create filter panel
--
-- @function [parent=#AbstractSelector] getFilterPanel
--
function AbstractSelector.methods:getFilterPanel()
  local panel = self:getPanel()
  if panel["filter-panel"] ~= nil and panel["filter-panel"].valid then
    return panel["filter-panel"]
  end
  return ElementGui.addGuiFrameV(panel, "filter-panel", "helmod_frame_resize_row_width", ({"helmod_common.filter"}))
end

-------------------------------------------------------------------------------
-- Get or create scroll panel
--
-- @function [parent=#AbstractSelector] getSrollPanel
--
function AbstractSelector.methods:getSrollPanel()
  local panel = self:getPanel()
  if panel["main-panel"] ~= nil and panel["main-panel"].valid then
    return panel["main-panel"]["scroll-panel"]
  end
  local mainPanel = ElementGui.addGuiFrameV(panel, "main-panel", "helmod_frame_resize_row_width")
  local panel = ElementGui.addGuiScrollPane(mainPanel, "scroll-panel", "helmod_scroll_recipe_selector", "auto", "auto")
  Player.setStyle(panel, "scroll_recipe_selector", "minimal_height")
  Player.setStyle(panel, "scroll_recipe_selector", "maximal_height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create groups panel
--
-- @function [parent=#AbstractSelector] getGroupsPanel
--
function AbstractSelector.methods:getGroupsPanel()
  local panel = self:getSrollPanel()
  if panel["groups-panel"] ~= nil and panel["groups-panel"].valid then
    return panel["groups-panel"]
  end
  return ElementGui.addGuiFlowV(panel, "groups-panel", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create item list panel
--
-- @function [parent=#AbstractSelector] getItemListPanel
--
function AbstractSelector.methods:getItemListPanel()
  local panel = self:getSrollPanel()
  if panel["item-list-panel"] ~= nil and panel["item-list-panel"].valid then
    return panel["item-list-panel"]
  end
  return ElementGui.addGuiFlowV(panel, "item-list-panel", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#AbstractSelector] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function AbstractSelector.methods:onOpen(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onOpen():", action, item, item2, item3)
  local globalPlayer = Player.getGlobal()
  if item3 ~= nil then
    filter_prototype = item3:lower():gsub("[-]"," ")
  else
    filter_prototype = nil
  end
  filter_prototype_product = true
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractSelector] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local globalPlayer = Player.getGlobal()
  local globalSettings = Player.getGlobal("settings")
  local defaultSettings = Player.getDefaultSettings()
  local globalGui = Player.getGlobalGui()

  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if globalGui.currentTab == "HMPropertiesTab" then
      if action == "element-select" then
        globalPlayer["prototype-properties"] = {type = item, name = item2 }
        self.parent:refreshDisplayData()
        self:close()
      end
    else
      if action == "element-select" then
        local productionBlock = Model.addRecipeIntoProductionBlock(item2, item)
        Model.update()
        self.parent:refreshDisplayData()
        self:close()
      end
    end
  end

  if action == "recipe-group" then
    globalPlayer.recipeGroupSelected = item
    self:onUpdate(item, item2, item3)
  end

  if action == "change-boolean-settings" then
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    globalSettings[item] = not(globalSettings[item])
    self:onUpdate(item, item2, item3)
  end

  if action == "recipe-filter-switch" then
    filter_prototype_product = not(filter_prototype_product)
    self:onUpdate(item, item2, item3)
  end

  if action == "recipe-filter" then
    if Player.getSettings("filter_on_text_changed", true) then
      filter_prototype = event.element.text
    else
      if event.element.parent ~= nil and event.element.parent["filter-text"] ~= nil then
        filter_prototype = event.element.parent["filter-text"].text
      end
    end
    self:onUpdate(item, item2, item3)
  end

end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#AbstractSelector] updateGroups
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {list_group, list_subgroup, list_prototype}
--
function AbstractSelector.methods:updateGroups(item, item2, item3)
  Logging:trace(self:classname(), "updateGroups():", item, item2, item3)
  return {},{},{}
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#AbstractSelector] onUpdate
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:onUpdate(item, item2, item3)
  Logging:debug(self:classname(), "onUpdate():",item, item2, item3)
  -- recuperation recipes
  list_group, list_subgroup, list_prototype = self:updateGroups(item, item2, item3)

  self:updateFilter(item, item2, item3)
  self:updateGroupSelector(item, item2, item3)
  self:updateItemList(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update filter
--
-- @function [parent=#AbstractSelector] updateFilter
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:updateFilter(item, item2, item3)
  Logging:trace(self:classname(), "updateFilter():", item, item2, item3)
  local panel = self:getFilterPanel()

  if panel["filter"] == nil then
    local guiFilter = ElementGui.addGuiTable(panel, "filter", 2)
    if self.disable_option then
      local filter_show_disable = Player.getGlobalSettings("filter_show_disable")
      ElementGui.addGuiCheckbox(guiFilter, self:classname().."=change-boolean-settings=ID=filter_show_disable", filter_show_disable)
      ElementGui.addGuiLabel(guiFilter, "filter_show_disable", ({"helmod_recipe-edition-panel.filter-show-disable"}))
    end
    
    if self.hidden_option then
      local filter_show_hidden = Player.getGlobalSettings("filter_show_hidden")
      ElementGui.addGuiCheckbox(guiFilter, self:classname().."=change-boolean-settings=ID=filter_show_hidden", filter_show_hidden)
      ElementGui.addGuiLabel(guiFilter, "filter_show_hidden", ({"helmod_recipe-edition-panel.filter-show-hidden"}))
    end

    if self.product_option then
      ElementGui.addGuiCheckbox(guiFilter, self:classname().."=recipe-filter-switch=ID=filter-product", filter_prototype_product)
      ElementGui.addGuiLabel(guiFilter, "filter-product", ({"helmod_recipe-edition-panel.filter-by-product"}))
  
      ElementGui.addGuiCheckbox(guiFilter, self:classname().."=recipe-filter-switch=ID=filter-ingredient", not(filter_prototype_product))
      ElementGui.addGuiLabel(guiFilter, "filter-ingredient", ({"helmod_recipe-edition-panel.filter-by-ingredient"}))
    end

    ElementGui.addGuiLabel(guiFilter, "filter-value", ({"helmod_common.filter"}))
    local cellFilter = ElementGui.addGuiFlowH(guiFilter,"text-filter")
    if Player.getSettings("filter_on_text_changed", true) then
      ElementGui.addGuiText(cellFilter, self:classname().."=recipe-filter=ID=filter-value", filter_prototype)
    else
      ElementGui.addGuiText(cellFilter, "filter-text", filter_prototype)
      ElementGui.addGuiButton(cellFilter, self:classname().."=recipe-filter=ID=", "filter-value", "helmod_button_default", ({"helmod_button.apply"}))
    end

    ElementGui.addGuiLabel(panel, "message", ({"helmod_recipe-edition-panel.message"}))
  else
    if self.product_option then
      panel["filter"][self:classname().."=recipe-filter-switch=ID=filter-product"].state = filter_prototype_product
      panel["filter"][self:classname().."=recipe-filter-switch=ID=filter-ingredient"].state = not(filter_prototype_product)
    end
  end

end

-------------------------------------------------------------------------------
-- Get item list
--
-- @function [parent=#AbstractSelector] getItemList
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
-- @return #table
--
function AbstractSelector.methods:getItemList(item, item2, item3)
  Logging:trace(self:classname(), "getItemList():",item, item2, item3)
  local global_player = Player.getGlobal()
  local list_selected = {}
  local list = self:getListPrototype()
  if list[global_player.recipeGroupSelected] ~= nil then
    list_selected = list[global_player.recipeGroupSelected]
  end
  return list_selected
end

-------------------------------------------------------------------------------
-- Update item list
--
-- @function [parent=#AbstractSelector] updateItemList
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:updateItemList(item, item2, item3)
  Logging:trace(self:classname(), "updateItemList():", item, item2, item3)
  local panel = self:getItemListPanel()

  if panel["recipe-list"] ~= nil  and panel["recipe-list"].valid then
    panel["recipe-list"].destroy()
  end

  -- recuperation recipes et subgroupes
  local list = self:getItemList()

  --local guiRecipeSelectorTable = ElementGui.addGuiTable(panel, "recipe-table", 10)
  local guiRecipeSelectorList = ElementGui.addGuiFlowV(panel, "recipe-list", "helmod_flow_recipe_selector")
  for subgroup, list in spairs(list,function(t,a,b) return list_subgroup[b]["order"] > list_subgroup[a]["order"] end) do
    -- boucle subgroup
    local guiRecipeSubgroup = ElementGui.addGuiTable(guiRecipeSelectorList, "recipe-table-"..subgroup, 10, "helmod_table_recipe_selector")
    for key, prototype in spairs(list,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
      local tooltip = self:buildPrototypeTooltip(prototype)
      self:buildPrototypeIcon(guiRecipeSubgroup, prototype, tooltip)
    end
  end

end

-------------------------------------------------------------------------------
-- Get item list
--
-- @function [parent=#AbstractSelector] getItemList
-- 
-- @return #table
--
function AbstractSelector.methods:getItemList()
  Logging:trace(self:classname(), "getItemList()")
  local global_player = Player.getGlobal()
  local list_selected = {}
  if list_prototype[global_player.recipeGroupSelected] ~= nil then
    list_selected = list_prototype[global_player.recipeGroupSelected]
  end
  return list_selected
end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#AbstractSelector] buildPrototypeTooltip
--
function AbstractSelector.methods:buildPrototypeTooltip(prototype)
  Logging:trace(self:classname(), "buildPrototypeTooltip(element):", prototype)
  -- initalize tooltip
  local tooltip = ""
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#AbstractSelector] buildPrototypeIcon
--
function AbstractSelector.methods:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self:classname(), "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self:classname().."=recipe-select=ID=", Player.getRecipeIconType(prototype), prototype.name, prototype.name, tooltip)
end

-------------------------------------------------------------------------------
-- Update group selector
--
-- @function [parent=#AbstractSelector] updateGroupSelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:updateGroupSelector(item, item2, item3)
  Logging:trace(self:classname(), "updateGroupSelector():", item, item2, item3)
  local global_player = Player.getGlobal()
  local panel = self:getGroupsPanel()

  if panel["recipe-groups"] ~= nil  and panel["recipe-groups"].valid then
    panel["recipe-groups"].destroy()
  end

  Logging:debug(self:classname(), "list_group:",list_group)

  -- ajouter de la table des groupes de recipe
  local gui_group_panel = ElementGui.addGuiTable(panel, "recipe-groups", 6, "helmod_table_recipe_selector")
  for _, group in spairs(list_group,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    -- set le groupe
    if global_player.recipeGroupSelected == nil then global_player.recipeGroupSelected = group.name end
    local color = nil
    if global_player.recipeGroupSelected == group.name then
      color = "yellow"
    end
    local tooltip = "item-group-name."..group.name
    -- ajoute les icons de groupe
    local action = ElementGui.addGuiButtonSelectSpriteXxl(gui_group_panel, self:classname().."=recipe-group=ID=", "item-group", group.name, group.name, ({tooltip}), color)
  end

end
