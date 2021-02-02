-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module PreferenceEdition
-- @extends #AbstractEdition
--

PreferenceEdition = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PreferenceEdition] onInit
--
function PreferenceEdition:onInit()
  self.panelCaption = ({"helmod_preferences-edition-panel.title"})
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#PreferenceEdition] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function PreferenceEdition:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_height = 500,
    maximal_height = math.max(height_main,800),
  }
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#PreferenceEdition] onBind
--
function PreferenceEdition:onBind()
  Dispatcher:bind("on_gui_preference", self, self.updateFluidsLogistic)
  Dispatcher:bind("on_gui_preference", self, self.updateItemsLogistic)
  Dispatcher:bind("on_gui_preference", self, self.updatePriorityModule)
  Dispatcher:bind("on_gui_preference", self, self.updateUI)
end

-------------------------------------------------------------------------------
-- On scroll width
--
-- @function [parent=#PreferenceEdition] getSrollWidth
--
function PreferenceEdition:getSrollWidth()
  local number_column = User.getPreferenceSetting("preference_number_column")
  return 38 * (number_column or 6) + 20
end

-------------------------------------------------------------------------------
-- On scroll height
--
-- @function [parent=#PreferenceEdition] getSrollHeight
--
function PreferenceEdition:getSrollHeight()
  local number_line = User.getPreferenceSetting("preference_number_line")
  return 38 * (number_line or 3) + 4
end

-------------------------------------------------------------------------------
-- Get or create preference panel
--
-- @function [parent=#PreferenceEdition] getPrefrencePanel
--
function PreferenceEdition:getPrefrencePanel()
  local panel = self:getFrameTabbedPanel("preference_panel")
  panel.style.minimal_width = 600
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#PreferenceEdition] getTabPane
--
function PreferenceEdition:getTabPane()
  local content_panel = self:getPrefrencePanel()
  local panel_name = "tab_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(panel_name):style("helmod_tabbed_pane"))
  return panel
end

-------------------------------------------------------------------------------
-- Set active tab panel
--
-- @function [parent=#PreferenceEdition] setActiveTab
-- 
-- @param #string tab_name
--
function PreferenceEdition:setActiveTab(tab_name)
  local content_panel = self:getTabPane()
  for index,tab in pairs(content_panel.tabs) do
    if string.find(tab.content.name,tab_name) then
      content_panel.selected_tab_index = index
    end
  end
end

-------------------------------------------------------------------------------
-- Get or create general tab panel
--
-- @function [parent=#PreferenceEdition] getGeneralTab
--
function PreferenceEdition:getGeneralTab()
  local content_panel = self:getTabPane()
  local panel_name = "general_tab_panel"
  local scroll_name = "general_scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_label.general"}))
  local scroll_panel = GuiElement.add(content_panel, GuiFlowV(scroll_name))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create UI tab panel
--
-- @function [parent=#PreferenceEdition] getUITab
--
function PreferenceEdition:getUITab()
  local content_panel = self:getTabPane()
  local panel_name = "ui_tab_panel"
  local scroll_name = "ui_scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_label.ui"}))
  local scroll_panel = GuiElement.add(content_panel, GuiFlowV(scroll_name))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create priority module tab panel
--
-- @function [parent=#PreferenceEdition] getPriorityModuleTab
--
function PreferenceEdition:getPriorityModuleTab()
  local content_panel = self:getTabPane()
  local panel_name = "priority_module_tab_panel"
  local scroll_name = "priority_module_scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_label.priority-modules"}))
  local scroll_panel = GuiElement.add(content_panel, GuiFlowV(scroll_name))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create solid container tab panel
--
-- @function [parent=#PreferenceEdition] getSolidContainerTab
--
function PreferenceEdition:getSolidContainerTab()
  local content_panel = self:getTabPane()
  local panel_name = "solid_container_tab_panel"
  local scroll_name = "solid_container_scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_preferences-edition-panel.items-logistic-default"}))
  local scroll_panel = GuiElement.add(content_panel, GuiFlowV(scroll_name))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create fluid container tab panel
--
-- @function [parent=#PreferenceEdition] getFluidContainerTab
--
function PreferenceEdition:getFluidContainerTab()
  local content_panel = self:getTabPane()
  local panel_name = "fluid_container_tab_panel"
  local scroll_name = "fluid_container_scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_preferences-edition-panel.fluids-logistic-default"}))
  local scroll_panel = GuiElement.add(content_panel, GuiFlowV(scroll_name))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PreferenceEdition] onUpdate
--
-- @param #LuaEvent event
--
function PreferenceEdition:onUpdate(event)
  self:updateGeneral(event)
  self:updateUI(event)
  self:updatePriorityModule(event)
  self:updateItemsLogistic(event)
  self:updateFluidsLogistic(event)
  if event.action == "OPEN" then
    self:setActiveTab(event.item1)
  end
end

-------------------------------------------------------------------------------
-- Update ui
--
-- @function [parent=#PreferenceEdition] updateUI
--
-- @param #LuaEvent event
--
function PreferenceEdition:updateUI(event)
  local container_panel = self:getUITab()
  container_panel.clear()

  GuiElement.add(container_panel, GuiLabel("fluid_container_label"):caption({"helmod_label.ui"}):style("helmod_label_title_frame"))

  local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
  options_table.vertical_centering = false
  options_table.style.horizontal_spacing=10
  options_table.style.vertical_spacing=5

  for preference_type,preference in pairs(helmod_preferences) do
    if preference.group == "ui" then
      GuiElement.add(options_table, GuiLabel(self.classname, "label", preference_type):caption(preference.localised_name):tooltip(preference.localised_description))
      local default_preference_type = User.getPreferenceSetting(preference_type)
      if preference.allowed_values then
        GuiElement.add(options_table, GuiDropDown(self.classname, "preference-setting", preference_type):items(preference.allowed_values, default_preference_type))
      else
        if preference.type == "bool-setting" then
          GuiElement.add(options_table, GuiCheckBox(self.classname, "preference-setting", preference_type):state(default_preference_type))
        end
        if preference.type == "int-setting" or preference.type == "string-setting" then
          local tooltip = nil
          if preference.minimum_value then
            tooltip = {"", {"helmod_pref_settings.range-value"}, "[",preference.minimum_value,",",preference.maximum_value,"]"}
          end
          GuiElement.add(options_table, GuiTextField(self.classname, "preference-setting", preference_type):text(default_preference_type):tooltip(tooltip))
        end
      end
      if preference.items ~= nil then
        for preference_name,checked in pairs(preference.items) do
          local view = Controller:getView(preference_name)
          if view ~= nil then
            local localised_name = view.panelCaption
            local default_preference_name = User.getPreferenceSetting(preference_type, preference_name)
            GuiElement.add(options_table, GuiLabel(self.classname, "label", preference_type, preference_name):caption({"", "\t\t\t\t", helmod_tag.color.gold, localised_name, helmod_tag.color.close}))
            local checkbox = GuiElement.add(options_table, GuiCheckBox(self.classname, "preference-setting", preference_type, preference_name):state(default_preference_name))
            if default_preference_type ~= true then
              checkbox.enabled = false
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update general
--
-- @function [parent=#PreferenceEdition] updateGeneral
--
-- @param #LuaEvent event
--
function PreferenceEdition:updateGeneral(event)
  local container_panel = self:getGeneralTab()
  container_panel.clear()

  GuiElement.add(container_panel, GuiLabel("fluid_container_label"):caption({"helmod_label.general"}):style("helmod_label_title_frame"))
  
  local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
  options_table.vertical_centering = false
  options_table.style.horizontal_spacing=10
  options_table.style.vertical_spacing=5
  
  for preference_name,preference in pairs(helmod_preferences) do
    if preference.group == "general" then
      GuiElement.add(options_table, GuiLabel(self.classname, "label", preference_name):caption(preference.localised_name):tooltip(preference.localised_description))
      local default_preference = User.getPreferenceSetting(preference_name)
      if preference.allowed_values then
        GuiElement.add(options_table, GuiDropDown(self.classname, "preference-setting", preference_name):items(preference.allowed_values, default_preference))
      else
        if preference.type == "bool-setting" then
          GuiElement.add(options_table, GuiCheckBox(self.classname, "preference-setting", preference_name):state(default_preference))
        end
        if preference.type == "int-setting" or preference.type == "string-setting" then
          GuiElement.add(options_table, GuiTextField(self.classname, "preference-setting", preference_name):text(default_preference))
        end
      end
    end
  end
end
-------------------------------------------------------------------------------
-- Update priority module
--
-- @function [parent=#PreferenceEdition] updatePriorityModule
--
-- @param #LuaEvent event
--

function PreferenceEdition:updatePriorityModule(event)
  local number_column = User.getPreferenceSetting("preference_number_column")
  local priority_module_panel = self:getPriorityModuleTab()
  priority_module_panel.clear()

  GuiElement.add(priority_module_panel, GuiLabel("priority_module_label"):caption({"helmod_label.priority-modules"}):style("helmod_label_title_frame"))

  local configuration_table_panel = GuiElement.add(priority_module_panel, GuiTable("configuration-table"):column(2))
  configuration_table_panel.vertical_centering = false

  local configuration_panel = GuiElement.add(configuration_table_panel, GuiFlowV("configuration"))
  -- configuration select
  local tool_panel = GuiElement.add(configuration_panel, GuiFlowH("tool"))
  tool_panel.style.width = 200
  local conf_table_panel = GuiElement.add(tool_panel, GuiTable("configuration-table"):column(6))
  local configuration_priority = User.getParameter("configuration_priority") or 1
  local priority_modules = User.getParameter("priority_modules") or {}
  local button_style = "helmod_button_bold"
  for i, priority_module in pairs(priority_modules) do
    local button_style2 = button_style
    if configuration_priority == i then button_style2 = "helmod_button_bold_selected" end
    GuiElement.add(conf_table_panel, GuiButton(self.classname, "configuration-priority-select", i):caption(i):style(button_style2))
  end
  GuiElement.add(conf_table_panel, GuiButton(self.classname, "configuration-priority-select", "new"):caption("+"):style(button_style))
  GuiElement.add(conf_table_panel, GuiButton(self.classname, "configuration-priority-remove", "new"):caption("-"):style(button_style))
  -- module priority
  local priority_table_panel = GuiElement.add(configuration_panel, GuiTable("module-priority-table"):column(3))
  if priority_modules[configuration_priority] ~= nil then
    for index, element in pairs(priority_modules[configuration_priority]) do
      local tooltip = GuiTooltipModule("tooltip.add-module"):element({type="item", name=element.name})
      GuiElement.add(priority_table_panel, GuiButtonSprite(self.classname, "do-nothing", index):sprite("entity", element.name):tooltip(tooltip))
      GuiElement.add(priority_table_panel, GuiTextField(self.classname, "priority-module-update", index):text(element.value))
      GuiElement.add(priority_table_panel, GuiButtonSprite(self.classname, "priority-module-remove", index):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip(tooltip))
    end
  end
  
  -- module selector
  local module_scroll = GuiElement.add(configuration_table_panel, GuiScroll("module-selector-scroll"))
  module_scroll.style.maximal_height = self:getSrollHeight()
  module_scroll.style.minimal_width = self:getSrollWidth()
  local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(number_column))
  for k, element in pairs(Player.getModules()) do
    local tooltip = GuiTooltipModule("tooltip.add-module"):element({type="item", name=element.name})
    GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "priority-module-select"):sprite("entity", element.name):tooltip(tooltip))
  end
end

-------------------------------------------------------------------------------
-- Update items logistic
--
-- @function [parent=#PreferenceEdition] updateItemsLogistic
--
-- @param #LuaEvent event
--

function PreferenceEdition:updateItemsLogistic(event)
  local number_column = User.getPreferenceSetting("preference_number_column")
  local container_panel = self:getSolidContainerTab()
  container_panel.clear()

  GuiElement.add(container_panel, GuiLabel("solid_container_label"):caption({"helmod_preferences-edition-panel.items-logistic-default"}):style("helmod_label_title_frame"))
  
  local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
  options_table.vertical_centering = false
  options_table.style.horizontal_spacing=10
  options_table.style.vertical_spacing=10
  
  for _,type in pairs({"inserter", "belt", "container", "transport"}) do
    local type_label = GuiElement.add(options_table, GuiLabel(string.format("%s-label", type)):caption({string.format("helmod_preferences-edition-panel.items-logistic-%s", type)}))
    type_label.style.width = 200
    
    local scroll_panel = GuiElement.add(options_table, GuiScroll(string.format("%s-selector-scroll", type)))
    scroll_panel.style.maximal_height = self:getSrollHeight()
    scroll_panel.style.minimal_width = self:getSrollWidth()
    
    local type_table_panel = GuiElement.add(scroll_panel, GuiTable(string.format("%s-selector-table", type)):column(number_column))
    local item_logistic = Player.getDefaultItemLogistic(type)
    for key, entity in pairs(Player.getItemsLogistic(type)) do
      local color = nil
      if entity.name == item_logistic then color = "green" end
      local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "items-logistic-select", type):choose("entity", entity.name):color(color))
      button.locked = true
    end
  end
end

-------------------------------------------------------------------------------
-- Update fluids logistic
--
-- @function [parent=#PreferenceEdition] updateFluidsLogistic
--
-- @param #LuaEvent event
--

function PreferenceEdition:updateFluidsLogistic(event)
  local number_column = User.getPreferenceSetting("preference_number_column")
  local container_panel = self:getFluidContainerTab()
  container_panel.clear()

  GuiElement.add(container_panel, GuiLabel("fluid_container_label"):caption({"helmod_preferences-edition-panel.fluids-logistic-default"}):style("helmod_label_title_frame"))
  
  local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
  options_table.vertical_centering = false
  options_table.style.horizontal_spacing=10
  options_table.style.vertical_spacing=10
  
  local type_label = GuiElement.add(options_table, GuiLabel("maximum-flow"):caption({"helmod_preferences-edition-panel.fluids-logistic-maximum-flow"}))
  type_label.style.width = 200
  local fluids_logistic_maximum_flow = User.getParameter("fluids_logistic_maximum_flow")
  local default_flow = nil
  local items = {}
  for _,element in pairs(helmod_logistic_flow) do
    local flow = {"helmod_preferences-edition-panel.fluids-logistic-flow", element.pipe, element.flow}
    table.insert(items, flow)
    if fluids_logistic_maximum_flow ~= nil and fluids_logistic_maximum_flow == element.flow or element.flow == helmod_logistic_flow_default then
      default_flow = flow
    end
  end
  GuiElement.add(options_table, GuiDropDown(self.classname, "fluids-logistic-flow"):items(items, default_flow))
  
  for _,type in pairs({"pipe", "container", "transport"}) do
    local type_label = GuiElement.add(options_table, GuiLabel(string.format("%s-label", type)):caption({string.format("helmod_preferences-edition-panel.fluids-logistic-%s", type)}))
    type_label.style.width = 200
    
    local scroll_panel = GuiElement.add(options_table, GuiScroll(string.format("%s-selector-scroll", type)))
    scroll_panel.style.maximal_height = self:getSrollHeight()
    scroll_panel.style.minimal_width = self:getSrollWidth()
    local type_table_panel = GuiElement.add(scroll_panel, GuiTable(string.format("%s-selector-table", type)):column(number_column))
    local fluid_logistic = Player.getDefaultFluidLogistic(type)
    for key, entity in pairs(Player.getFluidsLogistic(type)) do
      local color = nil
      if entity.name == fluid_logistic then color = "green" end
      local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "fluids-logistic-select", type):choose("entity", entity.name):color(color))
      button.locked = true
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PreferenceEdition] onEvent
--
-- @param #LuaEvent event
--
function PreferenceEdition:onEvent(event)
  if event.action == "preference-setting" then
    local type = event.item1
    local name = event.item2
    if name == "" then
      local preference = helmod_preferences[type]
      if preference ~= nil then
        if preference.allowed_values then
          local index = event.element.selected_index
          User.setPreference(type, nil,preference.allowed_values[index])
        else
          if preference.type == "bool-setting" then
            User.setPreference(type, nil, event.element.state)
          end
          if preference.type == "int-setting" then
            local value = tonumber(event.element.text or preference.default_value)
            User.setPreference(type, nil, value)
          end
          if preference.type == "string-setting" then
            User.setPreference(type, nil, event.element.text or preference.default_value)
          end
        end
        Controller:send("on_gui_refresh", event)
        Controller:send("on_gui_preference", event)
      end
    else
      local preference = helmod_preferences[type]
      if preference ~= nil then
        User.setPreference(type, name, event.element.state)
      end
      Controller:send("on_gui_refresh", event)
      Controller:send("on_gui_preference", event)
    end
  end
  
  if event.action == "configuration-priority-select" then
    if event.item1 == "new" then
      local priority_modules = User.getParameter("priority_modules") or {}
      table.insert(priority_modules, {})
      User.setParameter("configuration_priority", table.size(priority_modules))
      User.setParameter("priority_modules", priority_modules)
    else
      User.setParameter("configuration_priority", tonumber(event.item1))
    end
    self:updatePriorityModule(event)
    Controller:send("on_gui_priority_module", event)
  end
  
  if event.action == "configuration-priority-remove" then
    local priority_modules = User.getParameter("priority_modules") or {}
    local configuration_priority = User.getParameter("configuration_priority")
    table.remove(priority_modules, configuration_priority)
    User.setParameter("configuration_priority", table.size(priority_modules))
    User.setParameter("priority_modules", priority_modules)
    self:updatePriorityModule(event)
    Controller:send("on_gui_priority_module", event)
  end
  
  if event.action == "priority-module-select" then
    local configuration_priority = User.getParameter("configuration_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    if table.size(priority_modules) == 0 then
      table.insert(priority_modules, {{name=event.item1, value=1}})
      User.setParameter("configuration_priority", 1)
      User.setParameter("priority_modules", priority_modules)
    else
      if priority_modules[configuration_priority] ~= nil then
        table.insert(priority_modules[configuration_priority], {name=event.item1, value=1})
      end
    end
    self:updatePriorityModule(event)
    Controller:send("on_gui_priority_module", event)
  end
  
  if event.action == "priority-module-update" then
    local configuration_priority = User.getParameter("configuration_priority")
    local priority_modules = User.getParameter("priority_modules")
    local priority_index = tonumber(event.item1)
    if priority_modules ~= nil and priority_modules[configuration_priority] ~= nil and priority_modules[configuration_priority][priority_index] ~= nil then
        local text = event.element.text
        priority_modules[configuration_priority][priority_index].value = tonumber(text)
    end
    self:updatePriorityModule(event)
    Controller:send("on_gui_priority_module", event)
  end
  
  if event.action == "priority-module-remove" then
    local configuration_priority = User.getParameter("configuration_priority")
    local priority_modules = User.getParameter("priority_modules")
    local priority_index = tonumber(event.item1)
    if priority_modules ~= nil and priority_modules[configuration_priority] ~= nil and priority_modules[configuration_priority][priority_index] ~= nil then
        table.remove(priority_modules[configuration_priority], priority_index)
    end
    self:updatePriorityModule(event)
    Controller:send("on_gui_priority_module", event)
  end
  
  if event.action == "items-logistic-select" then
    User.setParameter(string.format("items_logistic_%s", event.item1), event.item2)
    self:updateItemsLogistic(event)
    Controller:send("on_gui_refresh", event)
  end
  
  if event.action == "fluids-logistic-select" then
    User.setParameter(string.format("fluids_logistic_%s", event.item1), event.item2)
    self:updateFluidsLogistic(event)
    Controller:send("on_gui_refresh", event)
  end
  
  if event.action == "fluids-logistic-flow" then
    local index = event.element.selected_index
    local fluids_logistic_maximum_flow = helmod_logistic_flow[index].flow
    User.setParameter("fluids_logistic_maximum_flow", fluids_logistic_maximum_flow)
    Controller:send("on_gui_refresh", event)
  end
  
end
