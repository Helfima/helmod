-------------------------------------------------------------------------------
-- Classe to build selector dialog
--
-- @module AbstractSelector
-- @extends #Form
--

AbstractSelector = setclass("HMAbstractSelector", Form)

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
-- Return list prototype
--
-- @function [parent=#AbstractSelector] getListPrototype
--
-- @return #table
--
function AbstractSelector.methods:getListPrototype()
  return Cache.getData(self:classname(), "list_prototype") or {}
end

-------------------------------------------------------------------------------
-- Return list group
--
-- @function [parent=#AbstractSelector] getListGroup
--
-- @return #table
--
function AbstractSelector.methods:getListGroup()
  return Cache.getData(self:classname(), "list_group") or {}
end

-------------------------------------------------------------------------------
-- Return list subgroup
--
-- @function [parent=#AbstractSelector] getListSubgroup
--
-- @return #table
--
function AbstractSelector.methods:getListSubgroup()
  return Cache.getData(self:classname(), "list_subgroup") or {}
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
  return Controller.getDialogPanel()
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
  return ElementGui.addGuiFrameV(panel, "filter-panel", helmod_frame_style.panel, ({"helmod_common.filter"}))
end

-------------------------------------------------------------------------------
-- Get or create scroll panel
--
-- @function [parent=#AbstractSelector] getSrollPanel
--
function AbstractSelector.methods:getSrollPanel()
  local panel = self:getPanel()
  if panel["main_panel"] ~= nil and panel["main_panel"].valid then
    return panel["main_panel"]["scroll_panel"]
  end
  local main_panel = ElementGui.addGuiFrameV(panel, "main_panel", helmod_frame_style.panel)
  ElementGui.setStyle(main_panel, "dialog", "width")
  ElementGui.setStyle(main_panel, "recipe_selector", "height")
  local scroll_panel = ElementGui.addGuiScrollPane(main_panel, "scroll_panel", helmod_frame_style.scroll_recipe_selector)
  ElementGui.setStyle(scroll_panel, "scroll_recipe_selector", "width")
  ElementGui.setStyle(scroll_panel, "scroll_recipe_selector", "height")
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create groups panel
--
-- @function [parent=#AbstractSelector] getGroupsPanel
--
function AbstractSelector.methods:getGroupsPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["groups_panel"] ~= nil and scroll_panel["groups_panel"].valid then
    return scroll_panel["groups_panel"]
  end
  return ElementGui.addGuiFrameV(scroll_panel, "groups_panel", helmod_frame_style.hidden)
end

-------------------------------------------------------------------------------
-- Get or create item list panel
--
-- @function [parent=#AbstractSelector] getItemListPanel
--
function AbstractSelector.methods:getItemListPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["item_list_panel"] ~= nil and scroll_panel["item_list_panel"].valid then
    return scroll_panel["item_list_panel"]
  end
  return ElementGui.addGuiFrameV(scroll_panel, "item_list_panel", helmod_frame_style.hidden)
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#AbstractSelector] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:onBeforeEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onBeforeEvent()", action, item, item2, item3)
  local player_gui = Player.getGlobalGui()
  local global_player = Player.getGlobal()
  local close = action == "OPEN"
  if action == "OPEN" then
    global_player.recipeGroupSelected = nil
        
    filter_prototype_product = true

    local globalPlayer = Player.getGlobal()
    if item3 ~= nil then
      filter_prototype = item3:lower():gsub("[-]"," ")
    else
      filter_prototype = nil
    end
    if event ~= nil and event.button ~= nil and event.button == defines.mouse_button_type.right then
      filter_prototype_product = false
    end
    if item ~= nil and item2 ~= nil and item3 ~= nil then
      if player_gui.guiElementLast ~= item..item2..item3 then
        close = false
      end
      player_gui.guiElementLast = item..item2..item3
    end
    Logging:debug(self:classname(), "filter_prototype_product", filter_prototype_product)
  end
  --Logging:debug(Controller.classname, "filter_prototype", filter_prototype)
  -- close si nouvel appel
  return close
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
  local globalSettings = Player.getGlobalSettings()
  local defaultSettings = Player.getDefaultSettings()
  local globalGui = Player.getGlobalGui()
  local ui = Player.getGlobalUI()

  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if ui.data == "HMPropertiesTab" then
      if action == "element-select" then
        globalPlayer["prototype-properties"] = {type = item, name = item2 }
        self:close()
      end
    else
      -- classic selector
      if action == "element-select" and item ~= "container" then
        local productionBlock = ModelBuilder.addRecipeIntoProductionBlock(item2, item)
        ModelCompute.update()
        self:close()
        globalGui["scroll_down"] = true
        ui.data = "HMProductionBlockTab"
        ui.dialog = helmod_tab_dialog[ui.data]
      end
      -- container selector
      if action == "element-select" and item == "container" then
        local type = EntityPrototype.load(item2).getType()
        if type == "container" or type == "logistic-container" then
          globalGui.container_solid = item2
        end
        if type == "storage-tank" then
          globalGui.container_fluid = item2
        end
        if type == "car" or type == "cargo-wagon" or type == "item-with-entity-data"  or type == "logistic-robot" or type == "transport-belt" then
          globalGui.vehicle_solid = item2
        end
        if type == "fluid-wagon" then
          globalGui.vehicle_fluid = item2
        end
      end
    end
  end

  if action == "recipe-group" then
    globalPlayer.recipeGroupSelected = item
    Controller.createEvent(event, self:classname(), "UPDATE", item, item2, item3)
  end

  if action == "change-boolean-settings" then
    if globalSettings[item] == nil then globalSettings[item] = defaultSettings[item] end
    globalSettings[item] = not(globalSettings[item])
    self:resetGroups()
    Controller.createEvent(event, self:classname(), "UPDATE", item, item2, item3)
  end

  if action == "recipe-filter-switch" then
    filter_prototype_product = not(filter_prototype_product)
    Controller.createEvent(event, self:classname(), "UPDATE", item, item2, item3)
  end

  if action == "recipe-filter" then
    if Player.getSettings("filter_on_text_changed", true) then
      filter_prototype = event.element.text
      Controller.createEvent(event, self:classname(), "UPDATE", item, item2, item3)
    else
      if event.element.parent ~= nil and event.element.parent["filter-text"] ~= nil then
        filter_prototype = event.element.parent["filter-text"].text
      end
      Controller.createEvent(event, self:classname(), "UPDATE", item, item2, item3)
    end
  end

end

-------------------------------------------------------------------------------
-- Reset groups
--
-- @function [parent=#AbstractSelector] resetGroups
--
function AbstractSelector.methods:resetGroups()
  Cache.setData(self:classname(), "list_group", {})
  Cache.setData(self:classname(), "list_subgroup", {})
  Cache.setData(self:classname(), "list_prototype", {})
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#AbstractSelector] updateGroups
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return {list_group, list_subgroup, list_prototype}
--
function AbstractSelector.methods:updateGroups(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroups()", action, item, item2, item3)
  return {},{},{}
end

-------------------------------------------------------------------------------
-- Prepare
--
-- @function [parent=#AbstractSelector] prepare
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:prepare(event, action, item, item2, item3)
  Logging:trace(self:classname(), "prepare()", action, item, item2, item3)
  -- recuperation recipes
  if Model.countList(self:getListGroup()) == 0 then
    self:updateGroups(event, action, item, item2, item3)
    Logging:debug(self:classname(), "prepare ok")
  end
  --Logging:debug(self:classname(), "prepare()", Model.countList(list_group), Model.countList(list_subgroup), Model.countList(list_prototype))
  return true
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#AbstractSelector] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:onUpdate(event, action, item, item2, item3)
  Logging:trace(self:classname(), "onUpdate():", action, item, item2, item3)
  self:updateFilter(event, action, item, item2, item3)
  self:updateGroupSelector(event, action, item, item2, item3)
  self:updateItemList(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Check filter
--
-- @function [parent=#AbstractSelector] checkFilter
--
-- @param #element
--
-- @return boolean
--
function AbstractSelector.methods:checkFilter(element)
  local filter_prototype = self:getFilter()
  local filter_prototype_product = self:getProductFilter()
  --Logging:debug(self:classname(), element, "filter_prototype", filter_prototype, "filter_prototype_product", filter_prototype_product)
  local find = false
  if filter_prototype ~= nil and filter_prototype ~= "" then
    local search = element.search_products
    if filter_prototype_product ~= true then
      search = element.search_ingredients
    end
    return string.find(search:lower():gsub("[-]"," "), filter_prototype)
  else
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Update filter
--
-- @function [parent=#AbstractSelector] updateFilter
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:updateFilter(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateFilter()", action, item, item2, item3)
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
    local cellFilter = ElementGui.addGuiFrameH(guiFilter,"cell-filter", helmod_frame_style.hidden)
    if Player.getSettings("filter_on_text_changed", true) then
      ElementGui.addGuiText(cellFilter, self:classname().."=recipe-filter=ID=filter-value", filter_prototype)
    else
      ElementGui.addGuiText(cellFilter, "filter-text", filter_prototype)
      ElementGui.addGuiButton(cellFilter, self:classname().."=recipe-filter=ID=", "filter-value", "helmod_button_default", ({"helmod_button.apply"}))
    end

    ElementGui.addGuiLabel(panel, "message", ({"helmod_recipe-edition-panel.message"}))
  end

  if self.product_option then
    panel["filter"][self:classname().."=recipe-filter-switch=ID=filter-product"].state = filter_prototype_product
    panel["filter"][self:classname().."=recipe-filter-switch=ID=filter-ingredient"].state = not(filter_prototype_product)
    if filter_prototype ~= nil and action == "OPEN" then
      if Player.getSettings("filter_on_text_changed", true) then
        panel["filter"]["cell-filter"][self:classname().."=recipe-filter=ID=filter-value"].text = filter_prototype
      else
        panel["filter"]["cell-filter"]["filter-text"].text = filter_prototype
      end
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
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:updateItemList(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateItemList()", action, item, item2, item3)
  local item_list_panel = self:getItemListPanel()
  local filter_prototype = self:getFilter()

  if item_list_panel["recipe_list"] ~= nil  and item_list_panel["recipe_list"].valid then
    item_list_panel["recipe_list"].destroy()
  end

  -- recuperation recipes et subgroupes
  local list_item = self:getItemList()
  local list_subgroup = self:getListSubgroup()

  local recipe_selector_list = ElementGui.addGuiTable(item_list_panel, "recipe_list", 1, helmod_table_style.list)
  Logging:debug(self:classname(), "filter_prototype", filter_prototype)
  for subgroup, list in spairs(list_item,function(t,a,b) return list_subgroup[b]["order"] > list_subgroup[a]["order"] end) do
    -- boucle subgroup
    local guiRecipeSubgroup = ElementGui.addGuiTable(recipe_selector_list, "recipe-table-"..subgroup, 10, "helmod_table_recipe_selector")
    for key, prototype in spairs(list,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
      Logging:debug(self:classname(), "prototype test", prototype.name)
      if self:checkFilter(prototype) then
        Logging:debug(self:classname(), "prototype ok")
        local tooltip = self:buildPrototypeTooltip(prototype)
        self:buildPrototypeIcon(guiRecipeSubgroup, prototype, tooltip)
      end
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
  local list_prototype = self:getListPrototype()
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
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractSelector.methods:updateGroupSelector(event, action, item, item2, item3)
  Logging:trace(self:classname(), "updateGroupSelector():", action, item, item2, item3)
  local global_player = Player.getGlobal()
  local panel = self:getGroupsPanel()

  if panel["recipe-groups"] ~= nil  and panel["recipe-groups"].valid then
    panel["recipe-groups"].destroy()
  end

  local list_group = self:getListGroup()
  Logging:trace(self:classname(), "list_group:",list_group)

  -- ajouter de la table des groupes de recipe
  local gui_group_panel = ElementGui.addGuiTable(panel, "recipe-groups", 6, "helmod_table_recipe_selector")
  for _, group in spairs(list_group,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    if self:checkFilter(group) then
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

end
