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
  self.parameterLast = string.format("%s_%s",self.classname,"last")
  self.scroll_height = 38*3+4
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PreferenceEdition] onInit
--
function PreferenceEdition:getSrollHeight()
  local number_line = User.getModSetting("preference_number_line") 
  return 38 * (number_line or 3) + 4
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#PreferenceEdition] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function PreferenceEdition:onBeforeEvent(event)
  local close = true
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) ~= event.item1 then
    close = false
  end
  User.setParameter(self.parameterLast, event.item1)
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PreferenceEdition] onClose
--
function PreferenceEdition:onClose()
  User.setParameter(self.parameterLast,nil)
end

-------------------------------------------------------------------------------
-- Get or create priority module panel
--
-- @function [parent=#PreferenceEdition] getPriorityModulePanel
--
function PreferenceEdition:getPriorityModulePanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "priority_module"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  --panel.style.height = 600
  --panel.style.width = 900

  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true

  return panel
end

-------------------------------------------------------------------------------
-- Get or create solid container panel
--
-- @function [parent=#PreferenceEdition] getSolidContainerPanel
--
function PreferenceEdition:getSolidContainerPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "solid_container"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  --panel.style.height = 600
  --panel.style.width = 900

  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true

  return panel
end

-------------------------------------------------------------------------------
-- Get or create fluid container panel
--
-- @function [parent=#PreferenceEdition] getFluidContainerPanel
--
function PreferenceEdition:getFluidContainerPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "fluid_container"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  --panel.style.height = 600
  --panel.style.width = 900

  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true

  return panel
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PreferenceEdition] onUpdate
--
-- @param #LuaEvent event
--
function PreferenceEdition:onUpdate(event)
  self:updatePriorityModule(event)
  self:updateItemsLogistic(event)
  self:updateFluidsLogistic(event)
end

-------------------------------------------------------------------------------
-- Update priority module
--
-- @function [parent=#PreferenceEdition] updatePriorityModule
--
-- @param #LuaEvent event
--

function PreferenceEdition:updatePriorityModule(event)
  Logging:debug(self.classname, "updatePriorityModule()", event)
  local priority_module_panel = self:getPriorityModulePanel()
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
    Logging:debug(self.classname, "priority_modules", priority_modules, configuration_priority)
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
  local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(6))
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
  Logging:debug(self.classname, "updateItemsLogistic()", event)
  local container_panel = self:getSolidContainerPanel()
  container_panel.clear()

  GuiElement.add(container_panel, GuiLabel("solid_container_label"):caption({"helmod_preferences-edition-panel.items-logistic-default"}):style("helmod_label_title_frame"))
  
  local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
  options_table.vertical_centering = false
  options_table.style.horizontal_spacing=10
  options_table.style.vertical_spacing=10
  
  for _,type in pairs({"belt", "container", "transport"}) do
    local type_label = GuiElement.add(options_table, GuiLabel(string.format("%s-label", type)):caption({string.format("helmod_preferences-edition-panel.items-logistic-%s", type)}))
    type_label.style.width = 200
    
    local scroll_panel = GuiElement.add(options_table, GuiScroll(string.format("%s-selector-scroll", type)))
    scroll_panel.style.maximal_height = self:getSrollHeight()
  
    local type_table_panel = GuiElement.add(scroll_panel, GuiTable(string.format("%s-selector-table", type)):column(6))
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
  Logging:debug(self.classname, "updateFluidContainer()", event)
  local container_panel = self:getFluidContainerPanel()
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
  
    local type_table_panel = GuiElement.add(scroll_panel, GuiTable(string.format("%s-selector-table", type)):column(6))
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
  Logging:debug(self.classname, "onEvent()", event)
  
  if event.action == "configuration-priority-select" then
    if event.item1 == "new" then
      local priority_modules = User.getParameter("priority_modules") or {}
      table.insert(priority_modules, {})
      User.setParameter("configuration_priority", Model.countList(priority_modules))
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
    User.setParameter("configuration_priority", Model.countList(priority_modules))
    User.setParameter("priority_modules", priority_modules)
    self:updatePriorityModule(event)
    Controller:send("on_gui_priority_module", event)
  end
  
  if event.action == "priority-module-select" then
    local configuration_priority = User.getParameter("configuration_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    if Model.countList(priority_modules) == 0 then
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
