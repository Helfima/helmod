-------------------------------------------------------------------------------
---Classe to build selector dialog
--
---@module AbstractSelector
---@extends #Form
--

AbstractSelector = newclass(FormModel,function(base,classname)
  FormModel.init(base,classname)
  base.auto_clear = false
end)

local limit_display_height = 850

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function AbstractSelector:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    width = 490,
    height = math.max(height_main,800)
  }
  styles.block_info = {
    width = 310,
    height = 50*2+45
  }
end

-------------------------------------------------------------------------------
---Return filter - filtre sur les prototypes
---@return table
function AbstractSelector:getProductFilter()
  local filter_prototype_product = User.getParameter("filter_prototype_product")
  if filter_prototype_product == nil then filter_prototype_product = true end
  return filter_prototype_product
end

-------------------------------------------------------------------------------
---Return filter - filtre sur les prototypes
---@return table
function AbstractSelector:getFilter()
  return User.getParameter("filter_prototype")
end

-------------------------------------------------------------------------------
---Return list prototype
---@return table
function AbstractSelector:getListPrototype()
  if self:getProductFilter() and not(Cache.isEmpty(self.classname, "list_products")) then
    return Cache.getData(self.classname, "list_products") or {}
  end
  return Cache.getData(self.classname, "list_ingredients") or {}
end

-------------------------------------------------------------------------------
---Return list group
---@return table
function AbstractSelector:getListGroup()
  return User.getCache(self.classname, "list_group") or {}
end

-------------------------------------------------------------------------------
---Return list subgroup
---@return table
function AbstractSelector:getListSubGroup()
  return User.getCache(self.classname, "list_subgroup") or {}
end

-------------------------------------------------------------------------------
---Return list item
---@return table
function AbstractSelector:getListItem()
  return User.getCache(self.classname, "list_item") or {}
end

-------------------------------------------------------------------------------
---Return list group elements
---@return table
function AbstractSelector:getListGroupElements()
  return User.getCache(self.classname, "list_group_elements") or {}
end

-------------------------------------------------------------------------------
---Return caption
---@return table
function AbstractSelector:getCaption()
  return {"helmod_selector-panel.recipe-title"}
end

-------------------------------------------------------------------------------
---On initialization
function AbstractSelector:onInit()
  self.panelCaption = self:getCaption() ---obligatoire sinon le panneau ne s'affiche pas
  self.sprite_type = "item-group"
  self:afterInit()
  self.parameterTarget = string.format("%s_%s",self.classname,"target")
end

-------------------------------------------------------------------------------
---After initialization
function AbstractSelector:afterInit()
  self.disable_option = false
  self.hidden_option = false
  self.product_option = false
end

-------------------------------------------------------------------------------
---Get or create filter panel
---@return LuaGuiElement
function AbstractSelector:getFilterPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["filter-panel"] ~= nil and content_panel["filter-panel"].valid then
    return content_panel["filter-panel"]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV("filter-panel"))
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
---Get or create scroll panel
---@return LuaGuiElement
function AbstractSelector:getSrollPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["main_panel"] ~= nil and content_panel["main_panel"].valid then
    return content_panel["main_panel"]["scroll_panel"]
  end
  local main_panel = GuiElement.add(content_panel, GuiFrameV("main_panel"))
  main_panel.style.horizontally_stretchable = true
  local scroll_panel = GuiElement.add(main_panel, GuiScroll("scroll_panel"):style("helmod_scroll_pane"))
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create groups panel
---@return LuaGuiElement
function AbstractSelector:getGroupsPanel()
  local display_width, display_height = Player.getDisplaySizes()
  if display_height >= limit_display_height then
    --- affichage normal
    local flow_panel, content_panel, menu_panel = self:getPanel()
    --local content_panel = self:getSrollPanel()
    if content_panel["groups_panel"] ~= nil and content_panel["groups_panel"].valid then
      return content_panel["groups_panel"]
    end
    local group_panel = GuiElement.add(content_panel, GuiFrameV("groups_panel"))
    group_panel.style.horizontally_stretchable = true
    return group_panel
  else
    --- affichage full scroll
    local content_panel = self:getSrollPanel()
    if content_panel["groups_panel"] ~= nil and content_panel["groups_panel"].valid then
      return content_panel["groups_panel"]
    end
    return GuiElement.add(content_panel, GuiFlowV("groups_panel"))
  end
end

-------------------------------------------------------------------------------
---Get or create groups panel
---@return LuaGuiElement
function AbstractSelector:getFailPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["groups_panel"] ~= nil and scroll_panel["groups_panel"].valid then
    return scroll_panel["groups_panel"]
  end
  return GuiElement.add(scroll_panel, GuiFlowV("groups_panel"))
end

-------------------------------------------------------------------------------
---Get or create item list panel
---@return LuaGuiElement
function AbstractSelector:getItemListPanel()
  local scroll_panel = self:getSrollPanel()
  if scroll_panel["item_list_panel"] ~= nil and scroll_panel["item_list_panel"].valid then
    return scroll_panel["item_list_panel"]
  end
  return GuiElement.add(scroll_panel, GuiFlowV("item_list_panel"))
end

-------------------------------------------------------------------------------
---On before open
---@param event LuaEvent
function AbstractSelector:onBeforeOpen(event)
  FormModel.onBeforeOpen(self, event)
  if event.action == "OPEN" then
    User.setParameter(self.parameterTarget, event.item1)
  end
  
  if event.item4 ~= nil and event.item4 ~= "" then
    if User.isFilterTranslate()  then
      User.setParameter("filter_prototype", User.getTranslate(event.item4))
    else
      User.setParameter("filter_prototype", event.item4)
    end
    if event.reset ~= true then
      event.reset = true
      self:resetGroups()
    end
  else
    local filter_prototype = self:getFilter()
    if filter_prototype ~= nil and event.continue ~= true then 
      event.reset = true
      self:resetGroups()
    end
    User.setParameter("filter_prototype", nil)
  end

  if event ~= nil and event.button ~= nil and event.button == defines.mouse_button_type.right then
      User.setParameter("filter_prototype_product", false)
  else
    User.setParameter("filter_prototype_product", true)
  end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function AbstractSelector:onEvent(event)
  local default_settings = User.getDefaultSettings()
  local model, block, recipe = self:getParameterObjects()
  local prototype_type = event.item1
  local prototype_name = event.item2

  if User.isWriter(model) then
    if User.getParameter(self.parameterTarget) == "HMPropertiesPanel" then
      if event.action == "element-select" then
        local prototype_compare = User.getParameter("prototype_compare") or {}
        table.insert(prototype_compare, {type = prototype_type, name = prototype_name })
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
      ---classic selector
      if event.action == "element-select" and prototype_type ~= "container" then
        local index = nil
        if self:getProductFilter() == false then index = 0 end
        local new_block, new_recipe = ModelBuilder.addRecipeIntoProductionBlock(model, block, prototype_name, prototype_type, index)
        ModelCompute.update(model)
        User.setParameter("scroll_element", new_recipe.id)
        User.setActiveForm("HMProductionPanel")
        User.setParameterObjects("HMProductionPanel", model.id, new_block.id, new_recipe.id)
        User.setParameterObjects(self.classname, model.id, new_block.id)
        Controller:send("on_gui_refresh", event)
      end
      ---container selector
      if event.action == "element-select" and prototype_type == "container" then
        local type = EntityPrototype(prototype_name):getType()
        if type == "container" or type == "logistic-container" then
          User.setParameter("container_solid", prototype_name)
        end
        if type == "storage-tank" then
          User.setParameter("container_fluid", prototype_name)
        end
        if type == "car" or type == "cargo-wagon" or type == "item-with-entity-data"  or type == "logistic-robot" or type == "transport-belt" then
          User.setParameter("vehicle_solid", prototype_name)
        end
        if type == "fluid-wagon" then
          User.setParameter("vehicle_fluid", prototype_name)
        end
        Controller:send("on_gui_refresh", event)
      end
    end
  end

  if event.action == "recipe-group" then
    User.setParameter("recipe_group_selected",event.item1)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "change-options-visibility" then
    local options_visible_name = "filter_options_visible"
    local filter_options_visible = User.getSetting(options_visible_name)
    if filter_options_visible == nil then filter_options_visible = true end
    
    local panel = self:getFilterPanel()
    panel["filter-options"].visible = not(filter_options_visible)
    User.setSetting(options_visible_name, not(filter_options_visible))

    self:updateFilter(event)
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
    User.setParameter("filter-language", event.element.switch_state)
    self:resetGroups()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "filter-contain-switch" then
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
      if event.element.parent ~= nil and event.element.parent[self.classname.."=recipe-filter=filter-text"] ~= nil then
        User.setParameter("filter_prototype", event.element.parent[self.classname.."=recipe-filter=filter-text"].text)
      end
      self:resetGroups()
      Controller:send("on_gui_update", event, self.classname)
    end
  end
end

-------------------------------------------------------------------------------
---Reset groups
function AbstractSelector:resetGroups()
  User.resetCache(self.classname, "list_group")
  User.resetCache(self.classname, "list_subgroup")
  User.resetCache(self.classname, "list_group_elements")
end

-------------------------------------------------------------------------------
---Update groups
---@param event LuaEvent
---@return table, table, table --list_group, list_subgroup, list_prototype
function AbstractSelector:updateGroups(event)
  return {},{},{}
end

-------------------------------------------------------------------------------
---Prepare
---@param event LuaEvent
function AbstractSelector:prepare(event)
  ---recuperation recipes
  if Cache.isEmpty(self.classname, "list_ingredients") then
    local list_products = {}
    local list_ingredients = {}
    local list_translate = {}

    self:updateGroups(list_products, list_ingredients, list_translate)

    Cache.setData(self.classname, "list_products", list_products)
    Cache.setData(self.classname, "list_ingredients", list_ingredients)

    if User.getModGlobalSetting("filter_translated_string_active") then
      Cache.setData(self.classname, "list_translate", list_translate)
    end
  end
end

-------------------------------------------------------------------------------
---Translate
---@param event LuaEvent
function AbstractSelector:translate(event)
  ---List du cache non vide
  if not(Cache.isEmpty(self.classname, "list_translate")) then
    ---bluid table translate
    if User.getModGlobalSetting("filter_translated_string_active") and not(User.isTranslate()) and event.continue ~= true then
      local list_translate = Cache.getData(self.classname, "list_translate")
      local table_translate = {}
      local step_translate = User.getModGlobalSetting("user_cache_step") or 100
      local index = 0
      event.continue = true
      local query_translate
      for item_name,localised_name in pairs(list_translate) do
        if index % step_translate == 0 then
          query_translate = {index=index,list_translate={}}
          table.insert(table_translate, query_translate)
        end
        table.insert(query_translate.list_translate, localised_name)
        index = index + 1
      end
      event.table_translate = table_translate
      return User.createNextEvent(event, self.classname, "translate")
    end
    ---execute loop
    if event.continue and event.method == "translate" then
      local query_translate = table.remove(event.table_translate)
      self:updateWaitMessage(string.format("Wait translate: %s", query_translate.index or 0))
      for _,localised_name in pairs(query_translate.list_translate) do
        Player.native().request_translation(localised_name)
      end
      if #event.table_translate > 0 then
        return User.createNextEvent(event, self.classname, "translate")
      else
        event.continue = false
      end
    end
  end
  return User.createNextEvent(nil, self.classname, "translate")
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function AbstractSelector:onUpdate(event)
  self:updateFilter(event)

  local response = {wait=false, method="none"}
  
  response = self:translate(event)
  
  if response.wait == true then 
    return
  end
  
  response = self:createElementLists(event)

  if response.wait == true then 
    return
  end
  self:updateGroupSelector(event)

  self:updateItemList(event)
  
  end

-------------------------------------------------------------------------------
---Check filter
---@param search string
---@return boolean
function AbstractSelector:checkFilter(search)
  local filter_prototype = self:getFilter()
  if filter_prototype ~= nil and filter_prototype ~= "" then
    if User.isFilterTranslate()  then
      search = User.getTranslate(search)
    end
    if User.isFilterContain() then
      return string.find(search:lower(), filter_prototype:lower(), 1, true)
    else
      return search:lower() == filter_prototype:lower()
    end
  end
  return true
end

-------------------------------------------------------------------------------
---Update filter
---@param event LuaEvent
function AbstractSelector:updateFilter(event)
  local panel = self:getFilterPanel()
  local filter_prototype = self:getFilter()
  local filter_options_visible = User.getSetting("filter_options_visible")

  if panel["options-menu"] == nil then
    local options_menu = GuiElement.add(panel, GuiFlowH("options-menu"))
    local options_left = GuiElement.add(options_menu, GuiFlowH("options-left"))
    GuiElement.add(options_left, GuiLabel("frame_title"):caption({"helmod_button.options"}):style("helmod_label_title_frame"))
    
    local options_right = GuiElement.add(options_menu, GuiFlowH("options-right"))
    options_right.style.horizontal_align = "right"
    options_right.style.horizontally_stretchable = true
  end

  if panel["options-menu"] ~= nil then
    local options_right = panel["options-menu"]["options-right"]
    options_right.clear()
    if filter_options_visible == true or filter_options_visible == nil then
      GuiElement.add(options_right, GuiButton(self.classname, "change-options-visibility"):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"))
    else
      GuiElement.add(options_right, GuiButton(self.classname, "change-options-visibility"):sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black):style("helmod_button_menu_sm"))
    end
  end

  if panel["filter-options"] == nil then
    local options_panel = GuiElement.add(panel, GuiFlowV("filter-options"))
    options_panel.visible = filter_options_visible

    if self.product_option then
      GuiElement.add(options_panel, GuiSwitch(self.classname, "recipe-filter-switch"):state("left"):leftLabel({"helmod_recipe-edition-panel.filter-by-product"}):rightLabel({"helmod_recipe-edition-panel.filter-by-ingredient"}))
    end

    ---switch language
    local switch_position = "left"
    if User.getModGlobalSetting("filter_translated_string_active") and User.getParameter("filter-language") ~= nil then
      switch_position = User.getParameter("filter-language")
    end
    local filter_switch = GuiElement.add(options_panel, GuiSwitch(self.classname, "filter-language-switch"):state(switch_position):rightLabel({"helmod_recipe-edition-panel.filter-language-switch-left"}, {"tooltip.filter-language-switch-left"}):leftLabel({"helmod_recipe-edition-panel.filter-language-switch-right"}, {"tooltip.filter-language-switch-right"}):tooltip({"helmod_recipe-edition-panel.filter-language-switch"}))
    if not(User.getModGlobalSetting("filter_translated_string_active")) then
      filter_switch.enabled = false
      filter_switch.switch_state = "right"
    end
    ---switch contain
    local contain_position = "left"
    if User.getParameter("filter-contain") ~= nil then
      contain_position = User.getParameter("filter-contain")
    end
    GuiElement.add(options_panel, GuiSwitch(self.classname, "filter-contain-switch"):state(contain_position):rightLabel({"helmod_recipe-edition-panel.filter-contain-switch-left"}, {"tooltip.filter-contain-switch-left"}):leftLabel({"helmod_recipe-edition-panel.filter-contain-switch-right"}, {"tooltip.filter-contain-switch-right"}):tooltip({"helmod_recipe-edition-panel.filter-contain-switch"}))

    ---filter table
    local filter_table = GuiElement.add(options_panel, GuiTable("filter"):column(2))
    filter_table.vertical_centering = true

    if self.disable_option then
      local filter_show_disable = User.getSetting("filter_show_disable")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_disable"):state(filter_show_disable))
      GuiElement.add(filter_table, GuiLabel("filter_show_disable"):caption({"helmod_recipe-edition-panel.filter-show-disable"}))
    end

    if self.hidden_option then
      local filter_show_hidden = User.getSetting("filter_show_hidden")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_hidden"):state(filter_show_hidden))
      GuiElement.add(filter_table, GuiLabel("filter_show_hidden"):caption({"helmod_recipe-edition-panel.filter-show-hidden"}))
    end

    if self.hidden_player_crafting then
      local filter_show_hidden_player_crafting = User.getSetting("filter_show_hidden_player_crafting")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_hidden_player_crafting"):state(filter_show_hidden_player_crafting))
      GuiElement.add(filter_table, GuiLabel("filter_show_hidden_player_crafting"):caption({"helmod_recipe-edition-panel.filter-show-hidden-player-crafting"}))
    end

    if self.unlock_recipe then
      local filter_show_lock_recipes = User.getSetting("filter_show_lock_recipes")
      GuiElement.add(filter_table, GuiCheckBox(self.classname, "change-boolean-settings", "filter_show_lock_recipes"):state(filter_show_lock_recipes))
      GuiElement.add(filter_table, GuiLabel("filter_show_lock_recipes"):caption({"helmod_recipe-edition-panel.filter-show-lock-recipes"}))
    end

    ---filter
    local filter_box_panel = GuiElement.add(panel, GuiFlowH("filter-box-panel"))

    local label_filter_value = GuiElement.add(filter_box_panel, GuiLabel("filter-value"):caption({"helmod_common.filter"}))
    label_filter_value.style.margin = {5,5,0,0}
    if User.getModGlobalSetting("filter_on_text_changed") then
      local text_filter = GuiElement.add(filter_box_panel, GuiTextField(self.classname, "recipe-filter", "filter-value=onchange"):text(filter_prototype):style("helmod_textfield_filter"))
      text_filter.lose_focus_on_confirm = false
      text_filter.focus()
    else
      GuiElement.add(filter_box_panel, GuiTextField(self.classname, "recipe-filter", "filter-text"):text(filter_prototype):style("helmod_textfield_filter"))
      GuiElement.add(filter_box_panel, GuiButton(self.classname, "recipe-filter", "filter-button"):caption({"helmod_button.apply"}))
    end

  end
  if self.product_option then
      local switch_by_product = "right"
      if self:getProductFilter() == true then switch_by_product = "left" end
      panel["filter-options"][self.classname.."=recipe-filter-switch"].switch_state = switch_by_product
      if filter_prototype ~= nil then
        if User.getModGlobalSetting("filter_on_text_changed") then
          panel["filter-box-panel"][self.classname.."=recipe-filter=filter-value=onchange"].text = filter_prototype
        else
          panel["filter-box-panel"][self.classname.."=recipe-filter=filter-text"].text = filter_prototype
        end
      end
  end
end

-------------------------------------------------------------------------------
---Create element lists
---@param event LuaEvent
---@return table
function AbstractSelector:createElementLists(event)
  local list_group_elements = self:getListGroupElements()
  local list_group = self:getListGroup()
  local list_subgroup = self:getListSubGroup()

  if table.size(list_group) == 0 and event.continue ~= true then
    local list = self:getListPrototype()
    local step_list = User.getModGlobalSetting("user_cache_step") or 100
    local index = 0
    local table_element = {}
    local query_list = {}
    event.continue = true
    ---list_products[element.name][type - lua_recipe.name]
    for key, element in pairs(list) do
      if index % step_list == 0 then
        query_list = {index=index,list={}}
        table.insert(table_element, query_list)
      end
      query_list.list[key] = element
      index = index + 1
    end
    event.table_element = table_element
    return User.createNextEvent(event, self.classname, "list")
  end
  ---execute loop
  if event.continue and event.method == "list" then
    local filter_show_lock_recipes = User.getSetting("filter_show_lock_recipes")
    local filter_show_disable = User.getSetting("filter_show_disable")
    local filter_show_hidden = User.getSetting("filter_show_hidden")
    local filter_show_hidden_player_crafting = User.getSetting("filter_show_hidden_player_crafting")
    local query_list = table.remove(event.table_element)
    self:updateWaitMessage(string.format("Wait list build: %s", query_list.index or 0))

    for key, element in pairs(query_list.list) do
      ---filter sur le nom element (product ou ingredient)
      if self:checkFilter(key) then
        for element_name, element in pairs(element) do
          local prototype = self:getPrototype(element)
          if (not(self.unlock_recipe) or (prototype:getUnlock() == true or filter_show_lock_recipes == true)) and 
            (not(self.disable_option) or (prototype:getEnabled() == true or filter_show_disable == true)) and 
            (not(self.hidden_option) or (prototype:getHidden() == false or filter_show_hidden == true)) and
            (not(self.hidden_player_crafting) or (prototype:getHiddenPlayerCrafting() == false or filter_show_hidden_player_crafting == true)) then

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
    if #event.table_element > 0 then
      return User.createNextEvent(event, self.classname, "list")
    else
      event.continue = false
    end
  end
  
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
  event.continue = false

  return User.createNextEvent(nil, self.classname, "list")
end

-------------------------------------------------------------------------------
---Get prototype
---@param element table
---@param type string
---@return table
function AbstractSelector:getPrototype(element, type)
end

-------------------------------------------------------------------------------
---Append groups
---@param element string
---@param type string
---@param list_products table
---@param list_ingredients table
---@param list_translate table
function AbstractSelector:appendGroups(element, type, list_products, list_ingredients, list_translate)
  local prototype = self:getPrototype(element)
  local lua_prototype = prototype:native()

  if list_ingredients[lua_prototype.name] == nil then list_ingredients[lua_prototype.name] = {} end
  list_ingredients[lua_prototype.name][lua_prototype.name] = {name=lua_prototype.name, group=prototype:getGroup().name, subgroup=prototype:getSubgroup().name, type=type, order=lua_prototype.order}

  if lua_prototype.localised_name ~= nil then
    list_translate[element.name] = lua_prototype.localised_name
  end

end

-------------------------------------------------------------------------------
---Update wait message
---@param message string
function AbstractSelector:updateWaitMessage(message)
  local panel = self:getGroupsPanel()
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()
  GuiElement.add(item_list_panel, GuiLabel("wait message"):caption(message))
end

-------------------------------------------------------------------------------
---Update fail message
---@param message string
function AbstractSelector:updateFailMessage(message)
  local panel = self:getGroupsPanel()
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()
  GuiElement.add(item_list_panel, GuiLabel("wait message"):caption(message):fail())
end

-------------------------------------------------------------------------------
---Update item list
---@param event LuaEvent
function AbstractSelector:updateItemList(event)
  local item_list_panel = self:getItemListPanel()
  item_list_panel.clear()
  local list_subgroup = self:getListSubGroup()
  local list_item = self:getListItem()
  
  ---recuperation recipes et subgroupes
  local recipe_selector_list = GuiElement.add(item_list_panel, GuiFlowV("recipe_list"))
  if table.size(list_item) > 0 then
    for subgroup, list in spairs(list_item, function(t,a,b) return list_subgroup[b]["order"] > list_subgroup[a]["order"] end) do
      ---boucle subgroup
      local guiRecipeSubgroup = GuiElement.add(recipe_selector_list, GuiTable("recipe-table-", subgroup):column(10):style("helmod_table_recipe_selector"))
      for key, prototype in spairs(list,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
        local tooltip = self:buildPrototypeTooltip(prototype)
        self:buildPrototypeIcon(guiRecipeSubgroup, prototype, tooltip)
      end
    end
  else
    event.message = "Empty list"
    Dispatcher:send("on_gui_message", event, self.classname)
  end

end

-------------------------------------------------------------------------------
---Build prototype tooltip
---@param prototype table
---@return table
function AbstractSelector:buildPrototypeTooltip(prototype)
  ---initalize tooltip
  local tooltip = ""
  return tooltip
end

-------------------------------------------------------------------------------
---Build prototype icon
---@param gui_element GuiLuaElement
---@param prototype table
---@param tooltip table
function AbstractSelector:buildPrototypeIcon(gui_element, prototype, tooltip)
  GuiElement.add(gui_element, GuiButtonSelectSprite(self.classname, "recipe-select"):sprite(prototype.type, prototype.name):tooltip(tooltip))
end

-------------------------------------------------------------------------------
---Update group selector
---@param event LuaEvent
function AbstractSelector.updateGroupSelector(self, event)
  local panel = self:getGroupsPanel()

  panel.clear()
  local list_group = self:getListGroup()

  ---ajouter de la table des groupes de recipe
  local gui_group_panel = GuiElement.add(panel, GuiTable("recipe-groups"):column(6):style("helmod_table_recipe_selector"))

  for _, group in spairs(list_group,function(t,a,b) return t[b]["order"] > t[a]["order"] end) do
    ---set le groupe
    local group_selected = User.getParameter("recipe_group_selected")
    if group_selected == nil then User.setParameter("recipe_group_selected",group.name) end
    local color = nil
    if User.getParameter("recipe_group_selected") == group.name then
      color = "yellow"
    end
    local tooltip
    if group.name == "helmod" then
      tooltip = "Helmod"
    else
      tooltip = group.localised_name
    end

    ---ajoute les icons de groupe
    local action = GuiElement.add(gui_group_panel, GuiButtonSelectSpriteXxl(self.classname, "recipe-group"):sprite(self.sprite_type, group.name):tooltip(tooltip):color(color))
  end

end
