-------------------------------------------------------------------------------
-- Classe to build selector dialog
--
-- @module AbstractSelector
-- @extends #Form
--

AbstractSelector = newclass(Form,function(base,classname)
  Form.init(base,classname)
end)

local filter_prototype = nil
local filter_prototype_product = true
-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#AbstractSelector] onBind
--
function AbstractSelector:onBind()
  Dispatcher:bind("on_gui_prepare", self, self.prepare)
end

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#AbstractSelector] getProductFilter
--
-- @return #table
--
function AbstractSelector:getProductFilter()
  return filter_prototype_product
end

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#AbstractSelector] getFilter
--
-- @return #table
--
function AbstractSelector:getFilter()
  return filter_prototype
end

-------------------------------------------------------------------------------
-- Return list prototype
--
-- @function [parent=#AbstractSelector] getListPrototype
--
-- @return #table
--
function AbstractSelector:getListPrototype()
  if self:getProductFilter() and not(Cache.isEmpty(self.classname, "list_products")) then
    return Cache.getData(self.classname, "list_products") or {}
  end
  return Cache.getData(self.classname, "list_ingredients") or {}
end

-------------------------------------------------------------------------------
-- Return list group
--
-- @function [parent=#AbstractSelector] getListGroup
--
-- @return #table
--
function AbstractSelector:getListGroup()
  return Cache.getData(self.classname, "list_group") or {}
end

-------------------------------------------------------------------------------
-- Return list subgroup
--
-- @function [parent=#AbstractSelector] getListSubgroup
--
-- @return #table
--
function AbstractSelector:getListSubgroup()
  return Cache.getData(self.classname, "list_subgroup") or {}
end

-------------------------------------------------------------------------------
-- Return caption
--
-- @function [parent=#AbstractSelector] getCaption
--
function AbstractSelector:getCaption()
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#AbstractSelector] onInit
--
function AbstractSelector:onInit()
  self.panelCaption = self:getCaption() -- obligatoire sinon le panneau ne s'affiche pas
  self.auto_clear = false
  self:afterInit()
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- After initialization
--
-- @function [parent=#AbstractSelector] afterInit
--
function AbstractSelector:afterInit()
  self.disable_option = false
  self.hidden_option = false
  self.product_option = false
end

-------------------------------------------------------------------------------
-- Get or create filter panel
--
-- @function [parent=#AbstractSelector] getFilterPanel
--
function AbstractSelector:getFilterPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["filter-panel"] ~= nil and content_panel["filter-panel"].valid then
    return content_panel["filter-panel"]
  end
  local panel = ElementGui.addGuiFrameV(content_panel, "filter-panel", helmod_frame_style.default)
  panel.style.horizontally_stretchable = true
  ElementGui.addGuiLabel(panel,"frame_title",({"helmod_common.filter"}),"helmod_label_title_frame")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create scroll panel
--
-- @function [parent=#AbstractSelector] getSrollPanel
--
function AbstractSelector:getSrollPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["main_panel"] ~= nil and content_panel["main_panel"].valid then
    return content_panel["main_panel"]["scroll_panel"]
  end
  local main_panel = ElementGui.addGuiFrameV(content_panel, "main_panel", helmod_frame_style.default)
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
function AbstractSelector:getGroupsPanel()
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
function AbstractSelector:getItemListPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["item_list_panel"] ~= nil and scroll_panel["item_list_panel"].valid then
    return scroll_panel["item_list_panel"]
  end
  return ElementGui.addGuiFrameV(scroll_panel, "item_list_panel", helmod_frame_style.hidden)
end

-------------------------------------------------------------------------------
-- On before open
--
-- @function [parent=#AbstractSelector] onBeforeOpen
--
-- @param #LuaEvent event
--
function AbstractSelector:onBeforeOpen(event)
  Logging:debug(self.classname, "onBeforeEvent()", event)
  local close = event.action == "OPEN"
  User.setParameter("recipe_group_selected",nil)

  filter_prototype_product = true

  if event.item3 ~= nil and event.item3 ~= "" then
    Logging:debug(self.classname, "event.item3", event.item3)
    filter_prototype = event.item3:lower():gsub("[-]"," ")
    self:resetGroups()
  else
    if filter_prototype ~= nil then self:resetGroups() end
    filter_prototype = nil
  end
  
  if event ~= nil and event.button ~= nil and event.button == defines.mouse_button_type.right then
    filter_prototype_product = false
  end
  if event.item1 ~= nil and event.item2 ~= nil and event.item3 ~= nil then
    local parameter_last = string.format("%s_%s_%s", event.item1, event.item2, event.item3)
    if User.getParameter(self.parameterLast) ~= parameter_last then
      close = false
    end
    User.setParameter(self.parameterLast,parameter_last)
  end
  Logging:debug(self.classname, "filter_prototype_product", filter_prototype_product)
  -- close si nouvel appel
  return close
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractSelector] onEvent
--
-- @param #LuaEvent event
--
function AbstractSelector:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local default_settings = User.getDefaultSettings()

  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if User.isActiveForm("HMPropertiesTab") then
      if event.action == "element-select" then
        local prototype_compare = User.getParameter("prototype_compare") or {}
        table.insert(prototype_compare, {type = event.item1, name = event.item2 })
        User.setParameter("prototype_compare", prototype_compare)
        self:close()
        Controller:send("on_gui_refresh", event)
      end
    else
      -- classic selector
      if event.action == "element-select" and event.item1 ~= "container" then
        local productionBlock = ModelBuilder.addRecipeIntoProductionBlock(event.item2, event.item1)
        ModelCompute.update()
        User.setParameter("scroll_down",true)
        User.setActiveForm("HMProductionBlockTab")
        Controller:send("on_gui_refresh", event)
      end
      -- container selector
      if event.action == "element-select" and event.item1 == "container" then
        local type = EntityPrototype(event.item2):getType()
        if type == "container" or type == "logistic-container" then
          User.setParameter("container_solid",event.item2)
        end
        if type == "storage-tank" then
          User.setParameter("container_fluid",event.item2)
        end
        if type == "car" or type == "cargo-wagon" or type == "item-with-entity-data"  or type == "logistic-robot" or type == "transport-belt" then
          User.setParameter("vehicle_solid",event.item2)
        end
        if type == "fluid-wagon" then
          User.setParameter("vehicle_fluid",event.item2)
        end
        Controller:send("on_gui_refresh", event)
      end
    end
  end

  if event.action == "recipe-group" then
    User.setParameter("recipe_group_selected",event.item1)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "change-boolean-settings" then
    if User.getSetting(event.item1) == nil then User.setSetting(event.item1, default_settings[event.item]) end
    User.setSetting(event.item1, not(User.getSetting(event.item1)))
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "recipe-filter-switch" then
    filter_prototype_product = not(filter_prototype_product)
    self:resetGroups()
    Controller:send("on_gui_prepare", event, self.classname)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "recipe-filter" then
    if User.getModGlobalSetting("filter_on_text_changed") then
      filter_prototype = event.element.text
      self:resetGroups()
      Controller:send("on_gui_update", event, self.classname)
    else
      if event.element.parent ~= nil and event.element.parent["filter-text"] ~= nil then
        filter_prototype = event.element.parent["filter-text"].text
      end
      self:resetGroups()
      Controller:send("on_gui_update", event, self.classname)
    end
  end

end

-------------------------------------------------------------------------------
-- Reset groups
--
-- @function [parent=#AbstractSelector] resetGroups
--
function AbstractSelector:resetGroups()
  Logging:debug(self.classname, "resetGroups()")
  Cache.setData(self.classname, "list_group", nil)
  Cache.setData(self.classname, "list_subgroup", nil)
  Cache.setData(self.classname, "list_group_elements", nil)
end

-------------------------------------------------------------------------------
-- Update groups
--
-- @function [parent=#AbstractSelector] updateGroups
--
-- @param #LuaEvent event
--
-- @return {list_group, list_subgroup, list_prototype}
--
function AbstractSelector:updateGroups(event)
  Logging:trace(self.classname, "updateGroups()", event)
  return {},{},{}
end

-------------------------------------------------------------------------------
-- Prepare
--
-- @function [parent=#AbstractSelector] prepare
--
-- @param #LuaEvent event
--
function AbstractSelector:prepare(event)
  Logging:debug(self.classname, "prepare()", event)
  -- recuperation recipes
  if Model.countList(Cache.getData(self.classname, "list_products")) == 0 then
    self:updateGroups(event)
    Logging:debug(self.classname, "prepare ok")
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#AbstractSelector] onUpdate
--
-- @param #LuaEvent event
--
function AbstractSelector:onUpdate(event)
  Logging:debug(self.classname, "onUpdate()", event)

  self:createElementLists()

  self:updateFilter(event)
  self:updateGroupSelector(event)
  self:updateItemList(event)
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
function AbstractSelector:checkFilter(search)
  local filter_prototype_product = self:getProductFilter()
  if filter_prototype ~= nil and filter_prototype ~= "" then
    return string.find(search:lower():gsub("[-]"," "), filter_prototype)
  end
  return true
end

-------------------------------------------------------------------------------
-- Update filter
--
-- @function [parent=#AbstractSelector] updateFilter
--
-- @param #LuaEvent event
--
function AbstractSelector:updateFilter(event)
  Logging:trace(self.classname, "updateFilter()", event)
  local panel = self:getFilterPanel()

  if panel["filter"] == nil then
    Logging:debug(self.classname, "build filter")
    local guiFilter = ElementGui.addGuiTable(panel, "filter", 2)
    if self.disable_option then
      local filter_show_disable = User.getSetting("filter_show_disable")
      ElementGui.addGuiCheckbox(guiFilter, self.classname.."=change-boolean-settings=ID=filter_show_disable", filter_show_disable)
      ElementGui.addGuiLabel(guiFilter, "filter_show_disable", ({"helmod_recipe-edition-panel.filter-show-disable"}))
    end

    if self.hidden_option then
      local filter_show_hidden = User.getSetting("filter_show_hidden")
      ElementGui.addGuiCheckbox(guiFilter, self.classname.."=change-boolean-settings=ID=filter_show_hidden", filter_show_hidden)
      ElementGui.addGuiLabel(guiFilter, "filter_show_hidden", ({"helmod_recipe-edition-panel.filter-show-hidden"}))
    end

    if self.product_option then
      ElementGui.addGuiCheckbox(guiFilter, self.classname.."=recipe-filter-switch=ID=filter-product", filter_prototype_product)
      ElementGui.addGuiLabel(guiFilter, "filter-product", ({"helmod_recipe-edition-panel.filter-by-product"}))

      ElementGui.addGuiCheckbox(guiFilter, self.classname.."=recipe-filter-switch=ID=filter-ingredient", not(filter_prototype_product))
      ElementGui.addGuiLabel(guiFilter, "filter-ingredient", ({"helmod_recipe-edition-panel.filter-by-ingredient"}))
    end

    ElementGui.addGuiLabel(guiFilter, "filter-value", ({"helmod_common.filter"}))
    local cellFilter = ElementGui.addGuiFrameH(guiFilter,"cell-filter", helmod_frame_style.hidden)
    if User.getModGlobalSetting("filter_on_text_changed") then
      local text_filter = ElementGui.addGuiText(cellFilter, self.classname.."=recipe-filter=ID=filter-value=onchange", filter_prototype)
      text_filter.lose_focus_on_confirm = false
      text_filter.focus()
    else
      ElementGui.addGuiText(cellFilter, "filter-text", filter_prototype)
      ElementGui.addGuiButton(cellFilter, self.classname.."=recipe-filter=ID=", "filter-value", "helmod_button_default", ({"helmod_button.apply"}))
    end

    ElementGui.addGuiLabel(panel, "message", ({"helmod_recipe-edition-panel.message"}))
  end

  if self.product_option then
    panel["filter"][self.classname.."=recipe-filter-switch=ID=filter-product"].state = filter_prototype_product
    panel["filter"][self.classname.."=recipe-filter-switch=ID=filter-ingredient"].state = not(filter_prototype_product)
    if filter_prototype ~= nil and event.action == "OPEN" then
      if User.getModGlobalSetting("filter_on_text_changed") then
        panel["filter"]["cell-filter"][self.classname.."=recipe-filter=ID=filter-value=onchange"].text = filter_prototype
      else
        panel["filter"]["cell-filter"]["filter-text"].text = filter_prototype
      end
    end
  end

end

-------------------------------------------------------------------------------
-- Create element lists
--
-- @function [parent=#AbstractSelector] createElementLists
--
-- @return #table
--
function AbstractSelector:createElementLists()
  Logging:trace(self.classname, "createElementLists()")
  local list_group_elements = self:onCreateElementLists()
  
  local list_item = Cache.getData(self.classname, "list_item") or {}
  local group_selected = User.getParameter("recipe_group_selected")
  local list_group = Cache.getData(self.classname, "list_group") or {}
  
  if list_group_elements[group_selected] then
    list_item = list_group_elements[group_selected]
  else
    local group_selected,_ = next(list_group)
    User.setParameter("recipe_group_selected", group_selected)
    list_item = list_group_elements[group_selected]
  end
  Cache.setData(self.classname, "list_item", list_item or {})
end

-------------------------------------------------------------------------------
-- Get prototype
--
-- @function [parent=#AbstractSelector] getPrototype
--
-- @param element
-- @param type
--
-- @return #table
--
function AbstractSelector:getPrototype(element, type)
end

-------------------------------------------------------------------------------
-- Append groups
--
-- @function [parent=#AbstractSelector] appendGroups
--
-- @param #string element
-- @param #string type
--
function AbstractSelector:appendGroups(element, type, list_products, list_ingredients)
  Logging:debug(self.classname, "appendGroups()", element.name, type)
  local prototype = self:getPrototype(element)
  local lua_prototype = prototype:native()

  if list_ingredients[lua_prototype.name] == nil then list_ingredients[lua_prototype.name] = {} end
  list_ingredients[lua_prototype.name][lua_prototype.name] = {name=lua_prototype.name, group=prototype:getGroup().name, subgroup=prototype:getSubgroup().name, type=type, order=lua_prototype.order}
end

-------------------------------------------------------------------------------
-- On create element lists
--
-- @function [parent=#AbstractSelector] onCreateElementLists
--
-- @return #table
--
function AbstractSelector:onCreateElementLists()
  Logging:trace(self.classname, "onCreateElementLists()")
  local list_group_elements = Cache.getData(self.classname, "list_group_elements") or {}
  local list_group = Cache.getData(self.classname, "list_group") or {}
  local list_subgroup = Cache.getData(self.classname, "list_subgroup") or {}

  if Model.countList(list_group) == 0 then
    local list = self:getListPrototype()
    local filter_show_disable = User.getSetting("filter_show_disable")
    local filter_show_hidden = User.getSetting("filter_show_hidden")

    -- list_products[element.name][type - lua_recipe.name]
    for key, element in pairs(list) do
      -- filter sur le nom element (product ou ingredient)
      if self:checkFilter(key) then
        for element_name, element in pairs(element) do
          local prototype = self:getPrototype(element)
          if (not(self.disable_option) or (prototype:getEnabled() == true or filter_show_disable == true)) and (not(self.hidden_option) or (prototype:getHidden() == false or filter_show_hidden == true)) then
            if list_group_elements[element.group] == nil then list_group_elements[element.group] = {} end
            if list_group_elements[element.group][element.subgroup] == nil then list_group_elements[element.group][element.subgroup] = {} end
            list_group_elements[element.group][element.subgroup][element_name] = element

            list_group[element.group] = prototype:getGroup()
            list_subgroup[element.subgroup] = prototype:getSubgroup()
          end
        end
      end
    end
    Cache.setData(self.classname, "list_group", list_group)
    Cache.setData(self.classname, "list_subgroup", list_subgroup)
    Cache.setData(self.classname, "list_group_elements", list_group_elements)
  end
  return list_group_elements
end

-------------------------------------------------------------------------------
-- Update item list
--
-- @function [parent=#AbstractSelector] updateItemList
--
-- @param #LuaEvent event
--
function AbstractSelector:updateItemList(event)
  Logging:debug(self.classname, "updateItemList()", event)
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()
  local list_subgroup = Cache.getData(self.classname, "list_subgroup") or {}
  local list_item = Cache.getData(self.classname, "list_item") or {}
  -- recuperation recipes et subgroupes
  local recipe_selector_list = ElementGui.addGuiTable(item_list_panel, "recipe_list", 1, helmod_table_style.list)
  for subgroup, list in spairs(list_item,function(t,a,b) return list_subgroup[b]["order"] > list_subgroup[a]["order"] end) do
    -- boucle subgroup
    local guiRecipeSubgroup = ElementGui.addGuiTable(recipe_selector_list, "recipe-table-"..subgroup, 10, "helmod_table_recipe_selector")
    for key, prototype in spairs(list,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
      local tooltip = self:buildPrototypeTooltip(prototype)
      self:buildPrototypeIcon(guiRecipeSubgroup, prototype, tooltip)
    end
  end

end

-------------------------------------------------------------------------------
-- Build prototype tooltip
--
-- @function [parent=#AbstractSelector] buildPrototypeTooltip
--
function AbstractSelector:buildPrototypeTooltip(prototype)
  Logging:trace(self.classname, "buildPrototypeTooltip(element)", prototype)
  -- initalize tooltip
  local tooltip = ""
  return tooltip
end

-------------------------------------------------------------------------------
-- Build prototype icon
--
-- @function [parent=#AbstractSelector] buildPrototypeIcon
--
function AbstractSelector:buildPrototypeIcon(guiElement, prototype, tooltip)
  Logging:trace(self.classname, "buildPrototypeIcon(player, guiElement, prototype, tooltip:", guiElement, prototype, tooltip)
  ElementGui.addGuiButtonSelectSprite(guiElement, self.classname.."=recipe-select=ID=", Player.getRecipeIconType(prototype), prototype.name, prototype.name, tooltip)
end

-------------------------------------------------------------------------------
-- Update group selector
--
-- @function [parent=#AbstractSelector] updateGroupSelector
--
-- @param #LuaEvent event
--
function AbstractSelector:updateGroupSelector(event)
  Logging:trace(self.classname, "updateGroupSelector()", event)
  local panel = self:getGroupsPanel()

  panel.clear()
  local list_group = Cache.getData(self.classname, "list_group") or {}
  Logging:debug(self.classname, "list_group:",list_group)

  -- ajouter de la table des groupes de recipe
  local gui_group_panel = ElementGui.addGuiTable(panel, "recipe-groups", 6, "helmod_table_recipe_selector")

  local group_selected = User.getParameter("recipe_group_selected")

  for _, group in spairs(list_group,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    -- set le groupe
    local group_selected = User.getParameter("recipe_group_selected")
    if group_selected == nil then User.setParameter("recipe_group_selected",group.name) end
    local color = nil
    if User.getParameter("recipe_group_selected") == group.name then
      color = "yellow"
    end
    local tooltip = "item-group-name."..group.name
    -- ajoute les icons de groupe
    local action = ElementGui.addGuiButtonSelectSpriteXxl(gui_group_panel, self.classname.."=recipe-group=ID=", "item-group", group.name, group.name, ({tooltip}), color)
  end

end
