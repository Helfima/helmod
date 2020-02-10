-------------------------------------------------------------------------------
-- Classe to build selector dialog
--
-- @module AbstractSelector
-- @extends #Form
--

AbstractSelector = newclass(Form,function(base,classname)
  Form.init(base,classname)
  base.auto_clear = false
end)

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#AbstractSelector] onBind
--
function AbstractSelector:onBind()
  Dispatcher:bind("on_gui_prepare", self, self.prepare)
  Dispatcher:bind("on_gui_translate", self, self.translate)
end

-------------------------------------------------------------------------------
-- Return filter - filtre sur les prototypes
--
-- @function [parent=#AbstractSelector] getProductFilter
--
-- @return #table
--
function AbstractSelector:getProductFilter()
  local filter_prototype_product = User.getParameter("filter_prototype_product")
  if filter_prototype_product == nil then filter_prototype_product = true end
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
  return User.getParameter("filter_prototype")
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
  return User.getCache(self.classname, "list_group") or {}
end

-------------------------------------------------------------------------------
-- Return list subgroup
--
-- @function [parent=#AbstractSelector] getListSubGroup
--
-- @return #table
--
function AbstractSelector:getListSubGroup()
  return User.getCache(self.classname, "list_subgroup") or {}
end

-------------------------------------------------------------------------------
-- Return list item
--
-- @function [parent=#AbstractSelector] getListItem
--
-- @return #table
--
function AbstractSelector:getListItem()
  return User.getCache(self.classname, "list_item") or {}
end

-------------------------------------------------------------------------------
-- Return list group elements
--
-- @function [parent=#AbstractSelector] getListGroupElements
--
-- @return #table
--
function AbstractSelector:getListGroupElements()
  return User.getCache(self.classname, "list_group_elements") or {}
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
  self.sprite_type = "item-group"
  self:afterInit()
  self.parameterTarget = string.format("%s_%s",self.classname,"target")
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
  local panel = GuiElement.add(content_panel, GuiFrameV("filter-panel"))
  panel.style.horizontally_stretchable = true
  GuiElement.add(panel, GuiLabel("frame_title"):caption({"helmod_common.filter"}):style("helmod_label_title_frame"))
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
  local main_panel = GuiElement.add(content_panel, GuiFrameV("main_panel"))
  GuiElement.setStyle(main_panel, "dialog", "width")
  GuiElement.setStyle(main_panel, "recipe_selector", "height")
  local scroll_panel = GuiElement.add(main_panel, GuiScroll("scroll_panel"):style(helmod_frame_style.scroll_recipe_selector))
  GuiElement.setStyle(scroll_panel, "scroll_recipe_selector", "width")
  GuiElement.setStyle(scroll_panel, "scroll_recipe_selector", "height")
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
  return GuiElement.add(scroll_panel, GuiFrameV("groups_panel"):style(helmod_frame_style.hidden))
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
  return GuiElement.add(scroll_panel, GuiFrameV("item_list_panel"):style(helmod_frame_style.hidden))
end

-------------------------------------------------------------------------------
-- On before open
--
-- @function [parent=#AbstractSelector] onBeforeOpen
--
-- @param #LuaEvent event
--
function AbstractSelector:onBeforeOpen(event)
  Logging:debug(self.classname, "onBeforeOpen()", event)
  
  if event.action == "OPEN" then
    User.setParameter(self.parameterTarget, event.item1)
  end
  
  if event.item3 ~= nil and event.item3 ~= "" then
    Logging:debug(self.classname, "event.item3", event.item3)
    if User.isFilterTranslate()  then
      User.setParameter("filter_prototype", User.getTranslate(event.item3))
    else
      User.setParameter("filter_prototype", event.item3)
    end
    self:resetGroups()
  else
    local filter_prototype = self:getFilter()
    if filter_prototype ~= nil then self:resetGroups() end
    User.setParameter("filter_prototype", nil)
  end

  if event ~= nil and event.button ~= nil and event.button == defines.mouse_button_type.right then
      User.setParameter("filter_prototype_product", false)
  else
    User.setParameter("filter_prototype_product", true)
  end
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
    if User.getParameter(self.parameterTarget) == "HMPropertiesTab" then
      if event.action == "element-select" then
        local prototype_compare = User.getParameter("prototype_compare") or {}
        table.insert(prototype_compare, {type = event.item1, name = event.item2 })
        User.setParameter("prototype_compare", prototype_compare)
        self:close()
        Controller:send("on_gui_refresh", event)
      end
    elseif User.getParameter(self.parameterTarget) == "HMRecipeExplorer" then
      if event.action == "element-select" then
        Controller:send("on_gui_event", event, "HMRecipeExplorer")
        self:close()
      end
    else
      -- classic selector
      if event.action == "element-select" and event.item1 ~= "container" then
        local index = nil
        if self:getProductFilter() == false then index = 0 end
        local new_recipe = ModelBuilder.addRecipeIntoProductionBlock(event.item2, event.item1, index)
        ModelCompute.update()
        User.setParameter("scroll_element", new_recipe.id)
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
    local switch_by_product = event.element.switch_state == "left"
    User.setParameter("filter_prototype_product", switch_by_product)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "filter-language-switch" then
    Logging:debug(self.classname, "filter-language-switch", event.element.switch_state)
    User.setParameter("filter-language", event.element.switch_state)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "filter-contain-switch" then
    Logging:debug(self.classname, "filter-contain-switch", event.element.switch_state)
    User.setParameter("filter-contain", event.element.switch_state)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "recipe-filter" then
    if User.getModGlobalSetting("filter_on_text_changed") then
      User.setParameter("filter_prototype", event.element.text)
      self:resetGroups()
      Controller:send("on_gui_update", event, self.classname)
    else
      if event.element.parent ~= nil and event.element.parent["filter-text"] ~= nil then
        User.setParameter("filter_prototype", event.element.parent["filter-text"].text)
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
  User.resetCache(self.classname, "list_group")
  User.resetCache(self.classname, "list_subgroup")
  User.resetCache(self.classname, "list_group_elements")
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
  if Cache.isEmpty(self.classname, "list_ingredients") then
    local list_products = {}
    local list_ingredients = {}
    local list_translate = {}

    self:updateGroups(list_products, list_ingredients, list_translate)

    Cache.setData(self.classname, "list_products", list_products)
    Cache.setData(self.classname, "list_ingredients", list_ingredients)

    Logging:debug(self.classname, "prepare ok")
    if User.getModGlobalSetting("filter_translated_string_active") then
      Cache.setData(self.classname, "list_translate", list_translate)
    end
    if event ~= nil then
      User.setParameter("next_event", {type_event=event.type, event=event, classname=self.classname, wait="prepare"})
    end
    return {wait=true, method="prepare"}
  else
    if event ~= nil then
      User.setParameter("next_event",nil)
    end
    return {wait=false, method="prepare"}
  end
end

-------------------------------------------------------------------------------
-- Translate
--
-- @function [parent=#AbstractSelector] translate
--
-- @param #LuaEvent event
--
function AbstractSelector:translate(event)
  Logging:debug(self.classname, "translate()", event)
  -- recuperation recipes
  if not(Cache.isEmpty(self.classname, "list_translate")) then
    if User.getModGlobalSetting("filter_translated_string_active") and not(User.isTranslate()) then
      local list_translate = Cache.getData(self.classname, "list_translate")

      for item_name,localised_name in pairs(list_translate) do
        --Logging:debug(Controller.classname, "translate", item_name, localised_name)
        Player.native().request_translation(localised_name)
      end
      User.setParameter("next_event", {type_event=event.type, event=event, classname=self.classname, wait="translate"})
      return {wait=true, method="translate"}
    else
      User.setParameter("next_event",nil)
      return {wait=false, method="translate"}
    end
  else
    User.setParameter("next_event",nil)
    return {wait=false, method="translate"}
  end
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

  Logging:profilerStep("onUpdate", "** start **")
  
  self:updateFilter(event)
  Logging:profilerStep("onUpdate", "updateFilter")
  
  self:updateWaitMessage("Wait prepare")
  local response = self:prepare(event)
  Logging:profilerStep("onUpdate", "** prepare **")
  
  if response.wait == true then 
    return
  end
  
  self:updateWaitMessage("Wait translate")
  response = self:translate(event)
  Logging:profilerStep("onUpdate", "** translate **")
  
  if response.wait == true then 
    return
  end
  
  self:createElementLists()
  Logging:profilerStep("onUpdate", "createElementLists")
  
  self:updateGroupSelector(event)
  Logging:profilerStep("onUpdate", "updateGroupSelector")

  self:updateItemList(event)
  Logging:profilerStep("onUpdate", "updateItemList")
  
  Logging:profilerStep("onUpdate", "** end **")
  
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
  local filter_prototype = self:getFilter()
  if filter_prototype ~= nil and filter_prototype ~= "" then
    if User.isFilterTranslate()  then
      search = User.getTranslate(search)
    end
    if User.isFilterContain() then
      return string.find(search:lower():gsub("[-]"," "), filter_prototype:lower():gsub("[-]"," "))
    else
      return search:lower():gsub("[-]"," ") == filter_prototype:lower():gsub("[-]"," ")
    end
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
  local filter_prototype = self:getFilter()

  if panel["filter"] == nil then
    Logging:debug(self.classname, "build filter")

    if self.product_option then
      GuiElement.add(panel, GuiSwitch(self.classname, "recipe-filter-switch"):state("left"):leftLabel({"helmod_recipe-edition-panel.filter-by-product"}):rightLabel({"helmod_recipe-edition-panel.filter-by-ingredient"}))
    end

    -- switch language
    local switch_position = "left"
    if User.getModGlobalSetting("filter_translated_string_active") and User.getParameter("filter-language") ~= nil then
      switch_position = User.getParameter("filter-language")
    end
    local filter_switch = GuiElement.add(panel, GuiSwitch(self.classname, "filter-language-switch"):state(switch_position):rightLabel({"helmod_recipe-edition-panel.filter-language-switch-left"}, {"tooltip.filter-language-switch-left"}):leftLabel({"helmod_recipe-edition-panel.filter-language-switch-right"}, {"tooltip.filter-language-switch-right"}):tooltip({"helmod_recipe-edition-panel.filter-language-switch"}))
    if not(User.getModGlobalSetting("filter_translated_string_active")) then
      filter_switch.enabled = false
      filter_switch.switch_state = "right"
    end
    -- switch contain
    local contain_position = "left"
    if User.getParameter("filter-contain") ~= nil then
      contain_position = User.getParameter("filter-contain")
    end
    Logging:debug(self.classname, "strict_position", contain_position)
    GuiElement.add(panel, GuiSwitch(self.classname, "filter-contain-switch"):state(contain_position):rightLabel({"helmod_recipe-edition-panel.filter-contain-switch-left"}, {"tooltip.filter-contain-switch-left"}):leftLabel({"helmod_recipe-edition-panel.filter-contain-switch-right"}, {"tooltip.filter-contain-switch-right"}):tooltip({"helmod_recipe-edition-panel.filter-contain-switch"}))

    local guiFilter = GuiElement.add(panel, GuiTable("filter"):column(2))
    if self.disable_option then
      local filter_show_disable = User.getSetting("filter_show_disable")
      GuiElement.add(guiFilter, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_disable"):state(filter_show_disable))
      GuiElement.add(guiFilter, GuiLabel("filter_show_disable"):caption({"helmod_recipe-edition-panel.filter-show-disable"}))
    end

    if self.hidden_option then
      local filter_show_hidden = User.getSetting("filter_show_hidden")
      GuiElement.add(guiFilter, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_hidden"):state(filter_show_hidden))
      GuiElement.add(guiFilter, GuiLabel("filter_show_hidden"):caption({"helmod_recipe-edition-panel.filter-show-hidden"}))
    end

    GuiElement.add(guiFilter, GuiLabel("filter-value"):caption({"helmod_common.filter"}))
    local cellFilter = GuiElement.add(guiFilter, GuiFrameH("cell-filter"):style(helmod_frame_style.hidden))
    if User.getModGlobalSetting("filter_on_text_changed") then
      local text_filter = GuiElement.add(cellFilter, GuiTextField(self.classname, "recipe-filter", "filter-value=onchange"):text(filter_prototype):style())
      text_filter.lose_focus_on_confirm = false
      text_filter.focus()
    else
      GuiElement.add(cellFilter, GuiTextField("filter-text"):text(filter_prototype):style())
      GuiElement.add(cellFilter, GuiButton(self.classname, "recipe-filter", "filter-value"):caption({"helmod_button.apply"}))
    end
    
  end

  if self.product_option then
    local switch_by_product = "right"
    if self:getProductFilter() == true then switch_by_product = "left" end
    panel[self.classname.."=recipe-filter-switch"].switch_state = switch_by_product
    if filter_prototype ~= nil then
      if User.getModGlobalSetting("filter_on_text_changed") then
        panel["filter"]["cell-filter"][self.classname.."=recipe-filter=filter-value=onchange"].text = filter_prototype
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

  local list_item = self:getListItem()
  local group_selected = User.getParameter("recipe_group_selected")
  local list_group = self:getListGroup()

  if list_group_elements[group_selected] then
    list_item = list_group_elements[group_selected]
  else
    local group_selected,_ = next(list_group)
    User.setParameter("recipe_group_selected", group_selected)
    list_item = list_group_elements[group_selected]
  end
  User.setCache(self.classname, "list_item", list_item or {})
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
-- @param #table list_products
-- @param #table list_ingredients
-- @param #table list_translate
--
function AbstractSelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  Logging:debug(self.classname, "appendGroups()", element.name, type)
  local prototype = self:getPrototype(element)
  local lua_prototype = prototype:native()

  if list_ingredients[lua_prototype.name] == nil then list_ingredients[lua_prototype.name] = {} end
  list_ingredients[lua_prototype.name][lua_prototype.name] = {name=lua_prototype.name, group=prototype:getGroup().name, subgroup=prototype:getSubgroup().name, type=type, order=lua_prototype.order}

  if lua_prototype.localised_name ~= nil then
    list_translate[element.name] = lua_prototype.localised_name
  end

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
  local list_group_elements = self:getListGroupElements()
  local list_group = self:getListGroup()
  local list_subgroup = self:getListSubGroup()

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
    User.setCache(self.classname, "list_group", list_group)
    User.setCache(self.classname, "list_subgroup", list_subgroup)
    User.setCache(self.classname, "list_group_elements", list_group_elements)
  end
  return list_group_elements
end

-------------------------------------------------------------------------------
-- Update wait message
--
-- @function [parent=#AbstractSelector] updateWaitMessage
--
-- @param #LuaEvent event
--
function AbstractSelector:updateWaitMessage(message)
  Logging:debug(self.classname, "updateWaitMessage()", message)
  local panel = self:getGroupsPanel()
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()

  GuiElement.add(item_list_panel, GuiLabel("wait message"):caption(message))
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
  local list_subgroup = self:getListSubGroup()
  local list_item = self:getListItem()
  
  Logging:profilerStep("updateItemList", "** start **")
  -- recuperation recipes et subgroupes
  local recipe_selector_list = GuiElement.add(item_list_panel, GuiFlowV("recipe_list"))
  for subgroup, list in spairs(list_item,function(t,a,b) return list_subgroup[b]["order"] > list_subgroup[a]["order"] end) do
    -- boucle subgroup
    local guiRecipeSubgroup = GuiElement.add(recipe_selector_list, GuiTable("recipe-table-", subgroup):column(10):style("helmod_table_recipe_selector"))
    for key, prototype in spairs(list,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
      local tooltip = self:buildPrototypeTooltip(prototype)
      self:buildPrototypeIcon(guiRecipeSubgroup, prototype, tooltip)
    end
    Logging:profilerStep("updateItemList", "->subgroup", subgroup, Model.countList(list))
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
  GuiElement.add(guiElement, GuiButtonSelectSprite(self.classname, "recipe-select"):sprite(prototype.type, prototype.name):tooltip(tooltip))
end

-------------------------------------------------------------------------------
-- Update group selector
--
-- @function [parent=#AbstractSelector] updateGroupSelector
--
-- @param #LuaEvent event
--
function AbstractSelector.updateGroupSelector(self, event)
  Logging:trace(self.classname, "updateGroupSelector()", event)
  local panel = self:getGroupsPanel()

  panel.clear()
  local list_group = self:getListGroup()

  -- ajouter de la table des groupes de recipe
  local gui_group_panel = GuiElement.add(panel, GuiTable("recipe-groups"):column(6):style("helmod_table_recipe_selector"))

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
    local action = GuiElement.add(gui_group_panel, GuiButtonSelectSpriteXxl(self.classname, "recipe-group"):sprite(self.sprite_type, group.name):tooltip({tooltip}):color(color))
  end

end
