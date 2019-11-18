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
-- On update
--
-- @function [parent=#PreferenceEdition] onUpdate
--
-- @param #LuaEvent event
--
function PreferenceEdition:onUpdate(event)
  self:updatePriorityModule(event)
end

-------------------------------------------------------------------------------
-- Update priority module
--
-- @function [parent=#PreferenceEdition] updatePriorityModule
--
-- @param #LuaEvent event
--

function PreferenceEdition:updatePriorityModule(event)
  Logging:debug(self.classname, "updateRecipeCategory()", event)
  local priority_module_panel = self:getPriorityModulePanel()
  priority_module_panel.clear()

  GuiElement.add(priority_module_panel, GuiLabel("priority_module_label"):caption({"helmod_common.module"}):style("helmod_label_title_frame"))


  local configuration_table_panel = GuiElement.add(priority_module_panel, GuiTable("configuration-table"):column(2))
  configuration_table_panel.vertical_centering = false

  local configuration_panel = GuiElement.add(configuration_table_panel, GuiFlowV("configuration"))
  -- configuration select
  local tool_panel = GuiElement.add(configuration_panel, GuiFlowH("tool"))
  tool_panel.style.width = 200
  local configuration_priority = User.getParameter("configuration_priority") or 1
  local priority_modules = User.getParameter("priority_modules") or {}
  local button_style = "helmod_button_bold"
  for i, priority_module in pairs(priority_modules) do
    local button_style2 = button_style
    if configuration_priority == i then button_style2 = "helmod_button_bold_selected" end
    GuiElement.add(tool_panel, GuiButton(self.classname, "configuration-priority-select=ID", i):caption(i):style(button_style2))
  end
  GuiElement.add(tool_panel, GuiButton(self.classname, "configuration-priority-select=ID", "new"):caption("+"):style(button_style))
  -- module priority
  local priority_table_panel = GuiElement.add(configuration_panel, GuiTable("module-priority-table"):column(3))
  if priority_modules[configuration_priority] ~= nil then
    Logging:debug(self.classname, "priority_modules", priority_modules, configuration_priority)
    for index, element in pairs(priority_modules[configuration_priority]) do
      local tooltip = GuiElement.getTooltipModule(element.module)
      GuiElement.add(priority_table_panel, GuiButtonSprite(self.classname, "do-nothing=ID", index):sprite("entity", element.name):tooltip(tooltip))
      GuiElement.add(priority_table_panel, GuiTextField(self.classname, "priority-module-update=ID", index):text(element.value))
      GuiElement.add(priority_table_panel, GuiButtonSprite(self.classname, "priority-module-remove=ID", index):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip(tooltip))
    end
  end
  
  -- module selector
  local module_table_panel = GuiElement.add(configuration_table_panel, GuiTable("module-selector-table"):column(6))
  for k, element in pairs(Player.getModules()) do
    local tooltip = GuiElement.getTooltipModule(element.name)
    GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "priority-module-select=ID"):sprite("entity", element.name):tooltip(tooltip))
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
end
