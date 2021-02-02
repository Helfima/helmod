-------------------------------------------------------------------------------
-- Class to build recipe edition dialog
--
-- @module RecipeEdition
-- @extends #FormModel
--

RecipeEdition = newclass(FormModel)

local limit_display_height = 850
local tool_spacing = 2

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#RecipeEdition] onBind
--
function RecipeEdition:onBind()
  Dispatcher:bind("on_gui_priority_module", self, self.updateFactoryModules)
  Dispatcher:bind("on_gui_priority_module", self, self.updateBeaconModules)
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#RecipeEdition] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function RecipeEdition:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_height = 100,
    maximal_height = math.max(height_main,800),
  }
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#RecipeEdition] onInit
--
function RecipeEdition:onInit()
  self.panelCaption = ({"helmod_recipe-edition-panel.title"})
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- Get or create recipe info panel
--
-- @function [parent=#RecipeEdition] getObjectInfoPanel
--
-- @return #LuaGuiElement
--
function RecipeEdition:getObjectInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info"] ~= nil and content_panel["info"].valid then
    return content_panel["info"]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV("info"))
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#RecipeEdition] getTabPanel
--
function RecipeEdition:getTabPanel()
  local display_width, display_height = Player.getDisplaySizes()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "tab_panel"
  local factory_panel_name = "facory_panel"
  local beacon_panel_name = "beacon_panel"

  if display_height >= limit_display_height then
    -- affichage normal
    if content_panel[factory_panel_name] ~= nil and content_panel[factory_panel_name].valid then
      return content_panel[factory_panel_name], content_panel[beacon_panel_name]
    end
    local factory_panel = GuiElement.add(content_panel, GuiFrameH(factory_panel_name))
    factory_panel.style.horizontally_stretchable = true

    local beacon_panel = GuiElement.add(content_panel, GuiFrameH(beacon_panel_name))
    beacon_panel.style.horizontally_stretchable = true

    return factory_panel, beacon_panel
  else
    -- affichage tab
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
      return content_panel[panel_name][panel_name][factory_panel_name], content_panel[panel_name][panel_name][beacon_panel_name]
    end
    local panel = GuiElement.add(content_panel, GuiFrameH(panel_name))
    local tab_panel = GuiElement.add(panel, GuiTabPane(panel_name))
    local factory_tab_panel = GuiElement.add(tab_panel, GuiTab("factory-tab"):caption({"helmod_common.factory"}))
    local factory_panel = GuiElement.add(tab_panel, GuiFlowV(factory_panel_name))
    tab_panel.add_tab(factory_tab_panel, factory_panel)

    local beacon_tab_panel = GuiElement.add(tab_panel, GuiTab("beacon-tab"):caption({"helmod_common.beacon"}))
    local beacon_panel = GuiElement.add(tab_panel, GuiFlowV(beacon_panel_name))
    tab_panel.add_tab(beacon_tab_panel, beacon_panel)
    return factory_panel, beacon_panel
  end
end

-------------------------------------------------------------------------------
-- Get or create factory panel
--
-- @function [parent=#RecipeEdition] getFactoryTablePanel
--
function RecipeEdition:getFactoryTablePanel()
  local content_panel, _ = self:getTabPanel()
  local table_name = "factory_table"
  local info_name = "factory_info"
  local module_name = "factory_module"
  if content_panel[table_name] ~= nil and content_panel[table_name].valid then
    return content_panel[table_name][info_name], content_panel[table_name][module_name]
  end

  local table_panel = GuiElement.add(content_panel, GuiTable(table_name):column(2))
  table_panel.vertical_centering = false
  local info_panel = GuiElement.add(table_panel, GuiFlowV(info_name))
  info_panel.style.minimal_width = 250
  GuiElement.add(info_panel, GuiLabel("factory_label"):caption({"helmod_common.factory"}):style("helmod_label_title_frame"))
  
  local module_panel = GuiElement.add(table_panel, GuiFlowV(module_name))

  module_panel.style.minimal_width = 300
  return info_panel, module_panel
end

-------------------------------------------------------------------------------
-- Get or create factory panel
--
-- @function [parent=#RecipeEdition] getFactoryInfoPanel
--
function RecipeEdition:getFactoryInfoPanel()
  local info_panel, module_panel = self:getFactoryTablePanel()
  local tool_name = "factory_tool"
  local detail_name = "factory_detail"
  if info_panel[detail_name] ~= nil and info_panel[detail_name].valid then
    return info_panel[tool_name], info_panel[detail_name]
  end
  local tool_panel = GuiElement.add(info_panel, GuiFlowV(tool_name))
  local detail_panel = GuiElement.add(info_panel, GuiFlowV(detail_name))
  return tool_panel, detail_panel
end

-------------------------------------------------------------------------------
-- Get or create factory panel
--
-- @function [parent=#RecipeEdition] getFactoryModulePanel
--
function RecipeEdition:getFactoryModulePanel()
  local info_panel, module_panel = self:getFactoryTablePanel()
  local tool_name = "factory_tool"
  local module_name = "factory_module"
  if module_panel[module_name] ~= nil and module_panel[module_name].valid then
    return module_panel[tool_name], module_panel[module_name]
  end
  local tool_panel = GuiElement.add(module_panel, GuiFlowV(tool_name))
  local module_panel = GuiElement.add(module_panel, GuiFlowV(module_name))
  return tool_panel, module_panel
end

-------------------------------------------------------------------------------
-- Get or create beacon table panel
--
-- @function [parent=#RecipeEdition] getBeaconTablePanel
--
function RecipeEdition:getBeaconTablePanel()
  local _, content_panel = self:getTabPanel()
  local table_name = "beacon_table"
  local info_name = "beacon_info"
  local module_name = "beacon_module"
  if content_panel[table_name] ~= nil and content_panel[table_name].valid then
    return content_panel[table_name][info_name], content_panel[table_name][module_name]
  end

  local table_panel = GuiElement.add(content_panel, GuiTable(table_name):column(2))
  table_panel.vertical_centering = false
  local info_panel = GuiElement.add(table_panel, GuiFlowV(info_name))
  info_panel.style.minimal_width = 250
  GuiElement.add(info_panel, GuiLabel("beacon_label"):caption({"helmod_common.beacon"}):style("helmod_label_title_frame"))
  
  local module_panel = GuiElement.add(table_panel, GuiFlowV(module_name))

  module_panel.style.minimal_width = 300
  return info_panel, module_panel
end

-------------------------------------------------------------------------------
-- Get or create beacon info panel
--
-- @function [parent=#RecipeEdition] getBeaconInfoPanel
--
function RecipeEdition:getBeaconInfoPanel()
  local info_panel, module_panel = self:getBeaconTablePanel()
  local tool_name = "beacon_tool"
  local detail_name = "beacon_detail"
  if info_panel[detail_name] ~= nil and info_panel[detail_name].valid then
    return info_panel[tool_name], info_panel[detail_name]
  end
  local tool_panel = GuiElement.add(info_panel, GuiFlowV(tool_name))
  local detail_panel = GuiElement.add(info_panel, GuiFlowV(detail_name))
  return tool_panel, detail_panel
end

-------------------------------------------------------------------------------
-- Get or create beacon module panel
--
-- @function [parent=#RecipeEdition] getBeaconModulePanel
--
function RecipeEdition:getBeaconModulePanel()
  local info_panel, module_panel = self:getBeaconTablePanel()
  local tool_name = "beacon_tool"
  local module_name = "beacon_module"
  if module_panel[module_name] ~= nil and module_panel[module_name].valid then
    return module_panel[tool_name], module_panel[module_name]
  end
  local tool_panel = GuiElement.add(module_panel, GuiFlowV(tool_name))
  local module_panel = GuiElement.add(module_panel, GuiFlowV(module_name))
  return tool_panel, module_panel
end

-------------------------------------------------------------------------------
-- On before open
--
-- @function [parent=#RecipeEdition] onBeforeOpen
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function RecipeEdition:onBeforeOpen(event)
  FormModel.onBeforeOpen(self, event)
  local close = (event.action == "OPEN") -- only on open event
  User.setParameter("module_list_refresh",false)
  if event.action == "OPEN" then
    local parameter_last = string.format("%s%s%s", event.item1, event.item2, event.item3)
    if User.getParameter(self.parameterLast) or User.getParameter(self.parameterLast) ~= parameter_last then
      close = false
      User.setParameter("factory_group_selected",nil)
      User.setParameter("beacon_group_selected",nil)
      User.setParameter("module_list_refresh",true)
    end

    User.setParameter(self.parameterLast, parameter_last)
  end
  return close
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#RecipeEdition] onEvent
--
-- @param #LuaEvent event
--
function RecipeEdition:onEvent(event)
  local display_width, display_height = Player.getDisplaySizes()

  local model, block, recipe = self:getParameterObjects()
  if model == nil or block == nil or recipe == nil then return end
  if User.isWriter(model) then
    

    User.setParameter("scroll_element", recipe.id)
    
    if event.action == "neighbour-bonus-update" then
      local index = event.element.selected_index
      local items = {1,2,4,8}
      ModelBuilder.updateRecipeNeighbourBonus(recipe, items[index])
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end
    
    if event.action == "recipe-update" then
      local text = event.element.text
      local production = (tonumber(text) or 100)/100
      ModelBuilder.updateRecipeProduction(recipe, production)
      ModelCompute.update(model)
      self:updateObjectInfo(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-select" then
      -- item1=recipe item2=factory
      Model.setFactory(recipe, event.item4)
      ModelBuilder.applyFactoryModulePriority(recipe)
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-temperature" then
      local factory_prototype = EntityPrototype(recipe.factory)
      local temperature = factory_prototype:getMaximumTemperature()

      local text = event.element.text
      local ok , err = pcall(function()
        temperature = formula(text) or 0
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
        
      ModelBuilder.updateTemperatureFactory(recipe, temperature)
      ModelCompute.update(model)
      self:updateFactoryInfo(event)
      self:updateHeader(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-fuel-update" then

      local index = event.element.selected_index
      local factory_prototype = EntityPrototype(recipe.factory)
      local energy_type = factory_prototype:getEnergyTypeInput()
      local fuel_list = {}
      if energy_type == "burner" or energy_type == "fluid" then
        local energy_prototype = factory_prototype:getEnergySource()

        if energy_type == "fluid" then
          fuel_list = factory_prototype:getFluidFuelPrototypes()
        else
          fuel_list = energy_prototype:getFuelPrototypes()
        end
      end
      local fuel_name = nil
      for _,item in pairs(fuel_list) do
        if index == 1 then
          fuel_name = item.name
          break end
        index = index - 1
      end
      ModelBuilder.updateFuelFactory(recipe, fuel_name)
      ModelCompute.update(model)
      self:updateFactoryInfoTool(event)
      self:updateFactoryInfo(event)
      self:updateHeader(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-tool" then
      if event.item4 == "default" then
        User.setDefaultFactory(recipe)
      elseif event.item4 == "block" then
        ModelBuilder.setFactoryBlock(block, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "line" then
        ModelBuilder.setFactoryLine(model, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "all" then
        User.setParameter("default_factory_mode", "all")
      elseif event.item4 == "category" then
        User.setParameter("default_factory_mode", "category")
      elseif event.item4 == "module" then
        User.setParameter("default_factory_with_module", not(User.getParameter("default_factory_with_module")))
      elseif event.item4 == "temperature" then
        ModelBuilder.updateFactoryTemperature(recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      end
      self:update(event)
    end

    if event.action == "factory-module-tool" then
      if event.item4 == "default" then
        User.setDefaultFactoryModule(recipe)
      elseif event.item4 == "block" then
        ModelBuilder.setFactoryModuleBlock(block, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "line" then
        ModelBuilder.setFactoryModuleLine(model, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "erase" then
        ModelBuilder.setFactoryModulePriority(recipe, nil)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      end
      self:update(event)
    end

    if event.action == "factory-module-priority-select" then
      User.setParameter("factory_module_priority", tonumber(event.item4))
      self:updateFactoryModules(event)
    end

    if event.action == "factory-module-priority-apply" then
      local factory_module_priority = User.getParameter("factory_module_priority") or 1
      local priority_modules = User.getParameter("priority_modules")
      if factory_module_priority ~= nil and priority_modules ~= nil and priority_modules[factory_module_priority] ~= nil then
        ModelBuilder.setFactoryModulePriority(recipe, priority_modules[factory_module_priority])
        ModelCompute.update(model)
        self:update(event)
        Controller:send("on_gui_refresh", event)
      end
    end

    if event.action == "factory-module-select" then
      ModelBuilder.addFactoryModule(recipe, event.item4, event.control)
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end
    
    if event.action == "factory-module-remove" then
      ModelBuilder.removeFactoryModule(recipe, event.item4, event.control)
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end
    
    if event.action == "beacon-tool" then
      if event.item4 == "default" then
        User.setDefaultBeacon(recipe)
      elseif event.item4 == "block" then
        ModelBuilder.setBeaconBlock(block, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "line" then
        ModelBuilder.setBeaconLine(model, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "all" then
        User.setParameter("default_beacon_mode", "all")
      elseif event.item4 == "category" then
        User.setParameter("default_beacon_mode", "category")
      elseif event.item4 == "module" then
        User.setParameter("default_beacon_with_module", not(User.getParameter("default_beacon_with_module")))
      end
      self:update(event)
    end

    if event.action == "beacon-module-tool" then
      if event.item4 == "default" then
        User.setDefaultBeaconModule(recipe)
      elseif event.item4 == "block" then
        ModelBuilder.setBeaconModuleBlock(block, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "line" then
        ModelBuilder.setBeaconModuleLine(model, recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      elseif event.item4 == "erase" then
        ModelBuilder.setBeaconModulePriority(recipe, nil)
        ModelCompute.update(model)
        Controller:send("on_gui_refresh", event)
      end
      self:update(event)
    end

    if event.action == "beacon-module-priority-select" then
      User.setParameter("beacon_module_priority", tonumber(event.item4))
      self:updateBeaconModules(event)
    end

    if event.action == "beacon-module-priority-apply" then
      local beacon_module_priority = User.getParameter("beacon_module_priority") or 1
      local priority_modules = User.getParameter("priority_modules")
      if beacon_module_priority ~= nil and priority_modules ~= nil and priority_modules[beacon_module_priority] ~= nil then
        ModelBuilder.setBeaconModulePriority(recipe, priority_modules[beacon_module_priority])
        ModelCompute.update(model)
        self:update(event)
        Controller:send("on_gui_refresh", event)
      end
    end

    if event.action == "beacon-module-select" then
      ModelBuilder.addBeaconModule(recipe, event.item4, event.control)
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end
    
    if event.action == "beacon-module-remove" then
      ModelBuilder.removeBeaconModule(recipe, event.item4, event.control)
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end
    
    if event.action == "beacon-select" then
      Model.setBeacon(recipe, event.item4)
      ModelCompute.update(model)
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "beacon-update" then
      local options = {}
      local text = event.element.text
      -- item3 = "combo" or "factory"
      local ok , err = pcall(function()
        options[event.item4] = formula(text) or 0

        ModelBuilder.updateBeacon(recipe, options)
        ModelCompute.update(model)
        self:updateBeaconInfo(event)
        if display_height >= limit_display_height or User.getParameter("factory_tab") then
          self:updateFactoryInfo(event)
        end
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end

    if event.action == "factory-switch-module" then
      local factory_switch_priority = event.element.switch_state == "right"
      User.setParameter("factory_switch_priority", factory_switch_priority)
      self:updateFactoryModules(event)
    end

    if event.action == "beacon-switch-module" then
      local beacon_switch_priority = event.element.switch_state == "right"
      User.setParameter("beacon_switch_priority", beacon_switch_priority)
      self:updateBeaconModules(event)
    end
  end
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#RecipeEdition] onClose
--
function RecipeEdition:onClose()
  User.setParameter(self.parameterLast,nil)
  User.setParameter("module_list_refresh",false)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#RecipeEdition] onOpen
--
-- @param #LuaEvent event
--
function RecipeEdition:onOpen(event)
  if User.getParameter("module_panel") == nil then
    User.setParameter("module_panel", true)
  end
  if User.getParameter("factory_tab") == nil then
    User.setParameter("factory_tab", true)
  end
end
-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RecipeEdition] onUpdate
--
-- @param #LuaEvent event
--
function RecipeEdition:onUpdate(event)
  local model, block, recipe = self:getParameterObjects()
  -- header
  self:updateHeader(event)
  if recipe ~= nil then
    if recipe.type == "energy" then
      self:updateFactoryInfo(event)
    else
      self:updateFactoryInfoTool(event)
      self:updateFactoryInfo(event)
      self:updateFactoryModulesActive(event)
      self:updateFactoryModules(event)
    end

    if recipe.type ~= "energy" then
      self:updateBeaconInfoTool(event)
      self:updateBeaconInfo(event)
      self:updateBeaconModulesActive(event)
      self:updateBeaconModules(event)
    end
  end
end

-------------------------------------------------------------------------------
-- Update tab menu
--
-- @function [parent=#RecipeEdition] updateTabMenu
--
-- @param #LuaEvent event
--
function RecipeEdition:updateTabMenu(event)
  local tab_left_panel = self:getTabLeftPanel()
  local tab_right_panel = self:getTabRightPanel()
  local model, block, recipe = self:getParameterObjects()

  local display_width, display_height = Player.getDisplaySizes()

  tab_left_panel.clear()
  tab_right_panel.clear()

  -- left tab
  if display_height < limit_display_height then
    local style = "helmod_button_tab"
    if User.getParameter("factory_tab") == true then style = "helmod_button_tab_selected" end

    GuiElement.add(tab_left_panel, GuiFrameH(self.classname, "separator_factory"):style(helmod_frame_style.tab)).style.width = 5
    GuiElement.add(tab_left_panel, GuiButton(self.classname, "edition-change-tab", model.id, block.id, recipe.id, "factory"):style(style):caption({"helmod_common.factory"}):tooltip({"helmod_common.factory"}))

    local style = "helmod_button_tab"
    if User.getParameter("factory_tab") == false then style = "helmod_button_tab_selected" end

    GuiElement.add(tab_left_panel, GuiFrameH(self.classname, "separator_beacon"):style(helmod_frame_style.tab)).style.width = 5
    GuiElement.add(tab_left_panel, GuiButton(self.classname, "edition-change-tab", model.id, block.id, recipe.id, "beacon"):style(style):caption({"helmod_common.beacon"}):tooltip({"helmod_common.beacon"}))

    GuiElement.add(tab_left_panel, GuiFrameH("tab_final"):style(helmod_frame_style.tab)).style.width = 100
  end
  -- right tab
  local style = "helmod_button_tab"
  if User.getParameter("module_panel") == false then style = "helmod_button_tab_selected" end

  GuiElement.add(tab_right_panel, GuiFrameH(self.classname, "separator_factory"):style(helmod_frame_style.tab)).style.width = 5
  GuiElement.add(tab_right_panel, GuiButton(self.classname, "change-panel", model.id, block.id, recipe.id, "factory"):style(style):caption({"helmod_common.factory"}):tooltip({"tooltip.selector-factory"}))

  local style = "helmod_button_tab"
  if User.getParameter("module_panel") == true then style = "helmod_button_tab_selected" end

  GuiElement.addGuiFrameH(tab_right_panel, self.classname.."_separator_module",helmod_frame_style.tab).style.width = 5
  GuiElement.add(tab_right_panel, GuiButton(self.classname, "change-panel", model.id, block.id, recipe.id, "module"):style(style):caption({"helmod_common.module"}):tooltip({"tooltip.selector-module"}))

  GuiElement.add(tab_right_panel, GuiFrameH("tab_final"):style(helmod_frame_style.tab)).style.width = 100
end

-------------------------------------------------------------------------------
-- Update factory tool
--
-- @function [parent=#RecipeEdition] updateFactoryInfoTool
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryInfoTool(event)
  local tool_panel, detail_panel = self:getFactoryInfoPanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local factory = recipe.factory
    local factory_prototype = EntityPrototype(factory)

    tool_panel.clear()

    -- factory tool
    local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
    tool_panel1.style.horizontal_spacing = tool_spacing

    local default_factory = User.getDefaultFactory(recipe)
    local record_style = "helmod_button_menu_sm_default"
    if default_factory ~= nil and default_factory.name == factory.name  and default_factory.fuel == factory.fuel  then record_style = "helmod_button_menu_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "default"):sprite("menu", "record-sm", "record-sm"):style(record_style):tooltip(GuiTooltipFactory("helmod_recipe-edition-panel.set-default"):element(default_factory)))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "block"):sprite("menu", "play-sm", "play-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipFactory("helmod_recipe-edition-panel.apply-block"):element(factory):tooltip("helmod_recipe-edition-panel.current-factory")))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "line"):sprite("menu", "end-sm", "end-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipFactory("helmod_recipe-edition-panel.apply-line"):element(factory):tooltip("helmod_recipe-edition-panel.current-factory")))

    local tool_panel2 = GuiElement.add(tool_action_panel, GuiFlowH("tool2"))
    tool_panel2.style.horizontal_spacing = tool_spacing
    local button_style = "helmod_button_menu_sm_bold"
    local selected_button_style = "helmod_button_menu_sm_bold_selected"
    local default_factory_mode = User.getParameter("default_factory_mode")
    local all_button_style = button_style
    local category_button_style = selected_button_style
    if default_factory_mode ~= "category" then
      all_button_style = selected_button_style
      category_button_style = button_style
    end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "all"):caption("A"):style(all_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-all"}))
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "category"):caption("C"):style(category_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-category"}))
    local default_factory_with_module = User.getParameter("default_factory_with_module")
    local module_button_style = button_style
    if default_factory_with_module == true then module_button_style = selected_button_style end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "module"):caption("M"):style(module_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-module"}))
    if factory_prototype:getType() == "boiler" then
      local temperature_button_style = button_style
      if factory.temperature_enabled == true then temperature_button_style = selected_button_style end
      GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "temperature"):caption("T"):style(temperature_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-temperature"}))
    end

  end
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeEdition] updateFactoryInfo
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryInfo(event)
  local tool_panel, detail_panel = self:getFactoryInfoPanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local factory = recipe.factory
    local factory_prototype = EntityPrototype(factory)

    detail_panel.clear()

    -- factory selection
    local scroll_panel = GuiElement.add(detail_panel, GuiScroll("factory-scroll"):policy(true))
    local recipe_prototype = RecipePrototype(recipe)
    local category = recipe_prototype:getCategory()
    local factories = {}
    if recipe.type == "energy" then
      factories[recipe.factory.name] = recipe.factory
    else
      factories = Player.getProductionsCrafting(category, recipe)
    end

    local factory_table_panel = GuiElement.add(scroll_panel, GuiTable("factory-table"):column(5))
    for key, element in spairs(factories, function(t,a,b) return t[b].crafting_speed > t[a].crafting_speed end) do
      local color = nil
      if factory.name == element.name then color = GuiElement.color_button_edit end
      local button = GuiElement.add(factory_table_panel, GuiButtonSelectSprite(self.classname, "factory-select", model.id, block.id, recipe.id):choose("entity", element.name):color(color))
      button.locked = true
    end

    -- factory info
    local header_panel = GuiElement.add(detail_panel, GuiTable("table-header"):column(2))
    if factory_prototype:native() == nil then
      GuiElement.add(header_panel, GuiLabel("label"):caption(factory.name))
    else
      GuiElement.add(header_panel, GuiLabel("label"):caption(factory_prototype:getLocalisedName()))
    end

    local input_panel = GuiElement.add(detail_panel, GuiTable("table-input"):column(2))
    input_panel.style.horizontal_spacing = 10

    GuiElement.add(input_panel, GuiLabel("label-module-slots"):caption({"helmod_label.module-slots"}))
    GuiElement.add(input_panel, GuiLabel("module-slots"):caption(factory_prototype:getModuleInventorySize()))

    -- neighbour
    if factory_prototype:getType() == "reactor" then
      local items = {}
      local default_neighbour = nil
      local item = nil
      for _,value in pairs({1,2,4,8}) do
        item = {"", value, " ", {"entity-name.nuclear-reactor"}}
        table.insert(items, item)
        if default_neighbour == nil then
          default_neighbour = item
        end
        if factory.neighbour_bonus == value then
          default_neighbour = item
        end
      end
      
      GuiElement.add(input_panel, GuiLabel("label-neighbour"):caption({"description.neighbour-bonus"}))
      GuiElement.add(input_panel, GuiDropDown(self.classname, "neighbour-bonus-update", model.id, block.id, recipe.id):items(items, default_neighbour))
    end
    -- energy
    local cell_energy = GuiElement.add(input_panel, GuiFlowH("label-energy"))
    GuiElement.add(cell_energy, GuiLabel("label-energy"):caption({"helmod_label.energy"}))
    self:addAlert(cell_energy, factory, "consumption")

    local sign = ""
    if factory.effects.consumption > 0 then sign = "+" end
    GuiElement.add(input_panel, GuiLabel("energy"):caption(Format.formatNumberKilo(factory.energy, "W").." ("..sign..Format.formatPercent(factory.effects.consumption).."%)"))
    
    -- burner
    local energy_type = factory_prototype:getEnergyTypeInput()
    if energy_type == "burner" or energy_type == "fluid" then
      local fuel_type = "item"
      if energy_type == "fluid" then
        fuel_type = "fluid"
      end
      local energy_prototype = factory_prototype:getEnergySource()
      local fuel_list = {}
      local factory_fuel = nil

      if energy_type == "fluid" then
        factory_fuel = factory_prototype:getFluidFuelPrototype(true)
        fuel_list = factory_prototype:getFluidFuelPrototypes()
      else
        fuel_list = energy_prototype:getFuelPrototypes()
        factory_fuel = energy_prototype:getFuelPrototype()
      end
      
      if fuel_list ~= nil and factory_fuel ~= nil then
        local items = {}
        for _,item in pairs(fuel_list) do
          table.insert(items,string.format("[%s=%s]", fuel_type, item.name))
        end
        local default_fuel = string.format("[%s=%s]", fuel_type, factory_fuel:native().name)
        GuiElement.add(input_panel, GuiLabel("label-burner"):caption({"helmod_common.resource"}))
        GuiElement.add(input_panel, GuiDropDown(self.classname, "factory-fuel-update", model.id, block.id, recipe.id, fuel_type):items(items, default_fuel))
      end
      -- local maximum_temperature = factory_prototype:getMaximumTemperature()
      -- if maximum_temperature > 0 then
      --   GuiElement.add(input_panel, GuiLabel("label-temperature"):caption({"helmod_common.temperature"}))
      --   GuiElement.add(input_panel, GuiTextField(self.classname, "factory-temperature", block.id, recipe.id):text(factory.temperature or maximum_temperature):isNumeric())
      -- end
    end

    -- speed
    local sign = ""
    if factory.effects.speed > 0 then sign = "+" end
    local cell_speed = GuiElement.add(input_panel, GuiFlowH("label-speed"))
    GuiElement.add(cell_speed, GuiLabel("label-speed"):caption({"helmod_label.speed"}))
    self:addAlert(cell_speed, factory, "speed")
    GuiElement.add(input_panel, GuiLabel("speed"):caption(Format.formatNumber(factory.speed).." ("..sign..Format.formatPercent(factory.effects.speed).."%)"))

    -- productivity
    local sign = ""
    if factory.effects.productivity > 0 then sign = "+" end
    local cell_productivity = GuiElement.add(input_panel, GuiFlowH("label-productivity"))
    GuiElement.add(cell_productivity, GuiLabel("label-productivity"):caption({"helmod_label.productivity"}))
    self:addAlert(cell_productivity, factory, "productivity")
    GuiElement.add(input_panel, GuiLabel("productivity"):caption(sign..Format.formatPercent(factory.effects.productivity).."%"))

    -- pollution
    local cell_pollution = GuiElement.add(input_panel, GuiFlowH("label-pollution"))
    GuiElement.add(cell_pollution, GuiLabel("label-pollution"):caption({"helmod_common.pollution"}))
    self:addAlert(cell_pollution, factory, "pollution")
    GuiElement.add(input_panel, GuiLabel("pollution"):caption({"helmod_si.per-minute", Format.formatNumberElement((factory.pollution or 0)*60 )}))
    
  end
end

-------------------------------------------------------------------------------
-- Add alert information
--
-- @function [parent=#RecipeEdition] addAlert
--
-- @param #LuaEvent event
--
function RecipeEdition:addAlert(cell, factory, type)
  if factory.cap ~= nil and factory.cap[type] ~= nil and factory.cap[type] > 0 then
    local tooltip = {""}
    if ModelCompute.cap_reason[type].cycle ~= nil and ModelCompute.cap_reason[type].cycle > 0 and bit32.band(factory.cap[type], ModelCompute.cap_reason[type].cycle) > 0 then
      table.insert(tooltip, {string.format("helmod_cap_reason.%s-cycle", type)})
    end
    if ModelCompute.cap_reason[type].module_low ~= nil and ModelCompute.cap_reason[type].module_low > 0 and bit32.band(factory.cap[type], ModelCompute.cap_reason[type].module_low) > 0 then
      table.insert(tooltip, {string.format("helmod_cap_reason.%s-module-low", type)})
    end
    if ModelCompute.cap_reason[type].module_high ~= nil and ModelCompute.cap_reason[type].module_high > 0 and bit32.band(factory.cap[type], ModelCompute.cap_reason[type].module_high) > 0 then
      table.insert(tooltip, {string.format("helmod_cap_reason.%s-module-high", type)})
    end
    GuiElement.add(cell, GuiSprite("alert"):sprite("helmod-alert1"):tooltip(tooltip))
  end
end

-------------------------------------------------------------------------------
-- Update modules information
--
-- @function [parent=#RecipeEdition] updateFactoryModulesActive
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryModulesActive(event)
  if not(self:isOpened()) then return end
  local tool_panel, module_panel = self:getFactoryModulePanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local factory = recipe.factory

    tool_panel.clear()
    GuiElement.add(tool_panel, GuiLabel("module_label"):caption({"helmod_recipe-edition-panel.current-modules"}):style("helmod_label_title_frame"))

    -- module tool
    local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
    tool_panel1.style.horizontal_spacing = tool_spacing
    local default_factory_module = User.getDefaultFactoryModule(recipe)
    local record_style = "helmod_button_menu_sm"
    if compare_priority(default_factory_module, factory.module_priority) then record_style = "helmod_button_menu_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "default"):sprite("menu", "record-sm", "record-sm"):style(record_style):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.set-default"):element(default_factory_module)))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "block"):sprite("menu", "play-sm", "play-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.apply-block"):element(factory.module_priority):tooltip("helmod_recipe-edition-panel.current-module")))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "line"):sprite("menu", "end-sm", "end-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.apply-line"):element(factory.module_priority):tooltip("helmod_recipe-edition-panel.current-module")))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "erase"):sprite("menu", "erase-sm", "erase-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.module-clear"):element(factory.module_priority)))

    -- actived modules panel
    local module_table = GuiElement.add(tool_panel, GuiTable("modules"):column(6):style("helmod_table_recipe_modules"))
    local control_info = "module-remove"
    for module, count in pairs(factory.modules) do
      local module_cell = GuiElement.add(module_table, GuiFlowH("module-cell", module))
      local tooltip = GuiTooltipModule("tooltip.remove-module"):element({type="item", name=module}):withControlInfo(control_info)
      GuiElement.add(module_cell, GuiButtonSelectSprite(self.classname, "factory-module-remove", model.id, block.id, recipe.id, module):sprite("item", module):tooltip(tooltip))
      GuiElement.add(module_cell, GuiLabel("module-amount"):caption({"", "x", count}))
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules information
--
-- @function [parent=#RecipeEdition] updateFactoryModules
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryModules(event)
  if not(self:isOpened()) then return end
  local tool_panel, module_panel = self:getFactoryModulePanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local factory_switch_priority = User.getParameter("factory_switch_priority")
  
    module_panel.clear()

    local element_state = "left"
    if factory_switch_priority == true then element_state = "right" end
    local factory_switch_module = GuiElement.add(module_panel, GuiSwitch(self.classname, "factory-switch-module", model.id, block.id, recipe.id):state(element_state):leftLabel({"helmod_recipe-edition-panel.selection-modules"}):rightLabel({"helmod_label.priority-modules"}))
    if factory_switch_priority == true then
      -- module priority
      self:updateFactoryModulesPriority(module_panel)
    else
      -- module selector
      self:updateFactoryModulesSelector(module_panel)
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules priority
--
-- @function [parent=#RecipeEdition] updateFactoryModulesPriority
--
-- @param #LuaGuiElement factory_module_panel
-- @param #string block_id
-- @param #string recipe_id
--
function RecipeEdition:updateFactoryModulesPriority(factory_module_panel)
  local model, block, recipe = self:getParameterObjects()
  -- module priority
  local factory_module_priority = User.getParameter("factory_module_priority") or 1
  local priority_modules = User.getParameter("priority_modules") or {}

  -- configuration select
  local tool_action_panel2 = GuiElement.add(factory_module_panel, GuiFlowH("tool-action2"))
  tool_action_panel2.style.horizontal_spacing = 10
  tool_action_panel2.style.bottom_padding = 10

  local tool_panel1 = GuiElement.add(tool_action_panel2, GuiFlowH("tool1"))
  tool_panel1.style.horizontal_spacing = tool_spacing
  local button_style = "helmod_button_menu_sm_bold"
  GuiElement.add(tool_panel1, GuiButton("HMPreferenceEdition", "OPEN", "priority_module"):sprite("menu", "services-sm", "services-sm"):style("helmod_button_menu_sm"):tooltip({"helmod_button.preferences"}))
  GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-priority-apply", model.id, block.id, recipe.id):sprite("menu", "arrow-up-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"helmod_recipe-edition-panel.apply-priority"}))

  local tool_panel2 = GuiElement.add(tool_action_panel2,  GuiTable("tool2"):column(6))
  for i, priority_module in pairs(priority_modules) do
    local button_style2 = button_style
    if factory_module_priority == i then button_style2 = "helmod_button_menu_sm_bold_selected" end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-module-priority-select", model.id, block.id, recipe.id, i):caption(i):style(button_style2))
  end

  -- module priority info
  local priority_table_panel = GuiElement.add(factory_module_panel, GuiTable("module-priority-table"):column(2))
  if priority_modules[factory_module_priority] ~= nil then
    local control_info = "module-add"
    for index, element in pairs(priority_modules[factory_module_priority]) do
      local color = nil
      local module = ItemPrototype(element.name)
      local tooltip = GuiTooltipModule("tooltip.add-module"):element({type="item", name=element.name}):withControlInfo(control_info)
      if Player.checkFactoryLimitationModule(module:native(), recipe) == false then
        if module.limitation_message_key ~= nil then
          tooltip = {"item-limitation."..module.limitation_message_key}
        else
          tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
        end
        color = GuiElement.color_button_rest
      end
      GuiElement.add(priority_table_panel, GuiButtonSelectSprite(self.classname, "factory-module-select", model.id, block.id, recipe.id):sprite("entity", element.name):color(color):index(index):tooltip(tooltip))
      GuiElement.add(priority_table_panel, GuiLabel("priority-value", index):caption({"", "x", element.value}))
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules selector
--
-- @function [parent=#RecipeEdition] updateFactoryModulesSelector
--
-- @param #LuaGuiElement factory_module_panel
-- @param #string block_id
-- @param #string recipe_id
--
function RecipeEdition:updateFactoryModulesSelector(factory_module_panel)
  local model, block, recipe = self:getParameterObjects()
  local block_id = block.id
  local recipe_id = recipe.id
  local module_scroll = GuiElement.add(factory_module_panel, GuiScroll("module-selector-scroll"))
  module_scroll.style.maximal_height = 118
  local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(6))
  for k, element in pairs(Player.getModules()) do
    local color = nil
    local control_info = "module-add"
    local tooltip = GuiTooltipModule("tooltip.add-module"):element({type="item", name=element.name}):withControlInfo(control_info)
    local module = ItemPrototype(element.name)
    if Player.checkFactoryLimitationModule(module:native(), recipe) == false then
      if module.limitation_message_key ~= nil then
        tooltip = {"item-limitation."..module.limitation_message_key}
      else
        tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
      end
      color = GuiElement.color_button_rest
    end
    GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "factory-module-select", model.id, block.id, recipe.id):sprite("entity", element.name):color(color):tooltip(tooltip))
  end
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeEdition] updateBeaconInfo
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconInfo(event)
  if event.is_queue == true then return end
  local tool_panel, detail_panel = self:getBeaconInfoPanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local beacon = recipe.beacon
    local beacon_prototype = EntityPrototype(beacon)

    detail_panel.clear()
    
    -- factory selection
    local scroll_panel = GuiElement.add(detail_panel, GuiScroll("beacon-scroll"):policy(true))
    local factories = Player.getProductionsBeacon()

    local factory_table_panel = GuiElement.add(scroll_panel, GuiTable("beacon-table"):column(5))
    for key, element in pairs(factories) do
      local color = nil
      if beacon.name == element.name then color = GuiElement.color_button_edit end
      local button = GuiElement.add(factory_table_panel, GuiButtonSelectSprite(self.classname, "beacon-select", model.id, block.id, recipe.id):choose("entity", element.name):color(color))
      button.locked = true
    end

    -- beacon info
    local header_panel = GuiElement.add(detail_panel, GuiTable("table-header"):column(2))
    if beacon_prototype:native() == nil then
      GuiElement.add(header_panel, GuiLabel("label"):caption(beacon.name))
    else
      GuiElement.add(header_panel, GuiLabel("label"):caption(beacon_prototype:getLocalisedName()))
    end

    local input_panel = GuiElement.add(detail_panel, GuiTable("table-input"):column(2))

    GuiElement.add(input_panel, GuiLabel("label-module-slots"):caption({"helmod_label.module-slots"}))
    GuiElement.add(input_panel, GuiLabel("module-slots"):caption(beacon_prototype:getModuleInventorySize()))

    GuiElement.add(input_panel, GuiLabel("label-energy-nominal"):caption({"helmod_label.energy"}))
    GuiElement.add(input_panel, GuiLabel("energy"):caption(Format.formatNumberKilo(beacon_prototype:getEnergyUsage(), "W")))

    GuiElement.add(input_panel, GuiLabel("label-efficiency"):caption({"helmod_label.efficiency"}))
    GuiElement.add(input_panel, GuiLabel("efficiency"):caption(beacon_prototype:getDistributionEffectivity()))

    GuiElement.add(input_panel, GuiLabel("label-combo"):caption({"helmod_label.beacon-on-factory"}):tooltip({"tooltip.beacon-on-factory"}))
    GuiElement.add(input_panel, GuiTextField(self.classname, "beacon-update", model.id, block.id, recipe.id, "combo", "onqueue"):text(beacon.combo):style("helmod_textfield"):tooltip({"tooltip.beacon-on-factory"}))

    GuiElement.add(input_panel, GuiLabel("label-by-factory"):caption({"helmod_label.beacon-per-factory"}):tooltip({"tooltip.beacon-per-factory"}))
    GuiElement.add(input_panel, GuiTextField(self.classname, "beacon-update", model.id, block.id, recipe.id, "per_factory", "onqueue"):text(beacon.per_factory):style("helmod_textfield"):tooltip({"tooltip.beacon-per-factory"}))

    GuiElement.add(input_panel, GuiLabel("label-by-factory-constant"):caption({"helmod_label.beacon-per-factory-constant"}):tooltip({"tooltip.beacon-per-factory-constant"}))
    GuiElement.add(input_panel, GuiTextField(self.classname, "beacon-update", model.id, block.id, recipe.id, "per_factory_constant", "onqueue"):text(beacon.per_factory_constant):style("helmod_textfield"):tooltip({"tooltip.beacon-per-factory-constant"}))
  end
end

-------------------------------------------------------------------------------
-- Update beacon tool
--
-- @function [parent=#RecipeEdition] updateBeaconInfoTool
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconInfoTool(event)
  local tool_panel, detail_panel = self:getBeaconInfoPanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local beacon = recipe.beacon

    tool_panel.clear()

    -- factory tool
    local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
    tool_panel1.style.horizontal_spacing = tool_spacing

    local default_beacon = User.getDefaultBeacon(recipe)
    local record_style = "helmod_button_menu_sm"
    if default_beacon ~= nil and default_beacon.name == beacon.name  then record_style = "helmod_button_menu_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "default"):sprite("menu", "record-sm", "record-sm"):style(record_style):tooltip(GuiTooltipFactory("helmod_recipe-edition-panel.set-default"):element(default_beacon)))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "block"):sprite("menu", "play-sm", "play-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipFactory("helmod_recipe-edition-panel.apply-block"):element(beacon):tooltip("helmod_recipe-edition-panel.current-beacon")))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "line"):sprite("menu", "end-sm", "end-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipFactory("helmod_recipe-edition-panel.apply-line"):element(beacon):tooltip("helmod_recipe-edition-panel.current-beacon")))

    local tool_panel2 = GuiElement.add(tool_action_panel, GuiFlowH("tool2"))
    tool_panel2.style.horizontal_spacing = tool_spacing
    local button_style = "helmod_button_menu_sm_bold"
    local selected_button_style = "helmod_button_menu_sm_bold_selected"
    local default_beacon_mode = User.getParameter("default_beacon_mode")
    local all_button_style = button_style
    local category_button_style = selected_button_style
    if default_beacon_mode ~= "category" then
      all_button_style = selected_button_style
      category_button_style = button_style
    end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "all"):caption("A"):style(all_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-all"}))
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "category"):caption("C"):style(category_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-category"}))
    local default_beacon_with_module = User.getParameter("default_beacon_with_module")
    local module_button_style = button_style
    if default_beacon_with_module == true then module_button_style = selected_button_style end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "module"):caption("M"):style(module_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-module"}))

  end
end

-------------------------------------------------------------------------------
-- Update modules information
--
-- @function [parent=#RecipeEdition] updateBeaconModulesActive
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconModulesActive(event)
  if not(self:isOpened()) then return end
  local tool_panel, module_panel = self:getBeaconModulePanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then
    local beacon = recipe.beacon

    tool_panel.clear()
    GuiElement.add(tool_panel, GuiLabel("module_label"):caption({"helmod_recipe-edition-panel.current-modules"}):style("helmod_label_title_frame"))

    -- module tool
    local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
    tool_panel1.style.horizontal_spacing = tool_spacing
    local default_beacon_module = User.getDefaultBeaconModule(recipe)
    local record_style = "helmod_button_menu_sm"
    if compare_priority(default_beacon_module, beacon.module_priority) then record_style = "helmod_button_menu_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "default"):sprite("menu", "record-sm", "record-sm"):style(record_style):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.set-default"):element(default_beacon_module)))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "block"):sprite("menu", "play-sm", "play-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.apply-block"):element(beacon.module_priority):tooltip("helmod_recipe-edition-panel.current-module")))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "line"):sprite("menu", "end-sm", "end-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.apply-line"):element(beacon.module_priority):tooltip("helmod_recipe-edition-panel.current-module")))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "erase"):sprite("menu", "erase-sm", "erase-sm"):style("helmod_button_menu_sm"):tooltip(GuiTooltipPriority("helmod_recipe-edition-panel.module-clear"):element(beacon.module_priority)))

    -- actived modules panel
    local module_table = GuiElement.add(tool_panel, GuiTable("modules"):column(6):style("helmod_table_recipe_modules"))
    local control_info = "module-remove"
    for module, count in pairs(beacon.modules) do
      local module_cell = GuiElement.add(module_table, GuiFlowH("module-cell", module))
      local tooltip = GuiTooltipModule("tooltip.remove-module"):element({type="item", name=module}):withControlInfo(control_info)
      GuiElement.add(module_cell, GuiButtonSelectSprite(self.classname, "beacon-module-remove", model.id, block.id, recipe.id, module):sprite("item", module):tooltip(tooltip))
      GuiElement.add(module_cell, GuiLabel("module-amount"):caption({"", "x", count}))
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules information
--
-- @function [parent=#RecipeEdition] updateBeaconModules
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconModules(event)
  if not(self:isOpened()) then return end
  local tool_panel, module_panel = self:getBeaconModulePanel()
  local model, block, recipe = self:getParameterObjects()
  if recipe ~= nil then

    module_panel.clear()

    local beacon_switch_priority = User.getParameter("beacon_switch_priority")
    local element_state = "left"
    if beacon_switch_priority == true then element_state = "right" end
    local factory_switch_module = GuiElement.add(module_panel, GuiSwitch(self.classname, "beacon-switch-module", model.id, block.id, recipe.id):state(element_state):leftLabel({"helmod_recipe-edition-panel.selection-modules"}):rightLabel({"helmod_label.priority-modules"}))
    if beacon_switch_priority == true then
      -- module priority
      self:updateBeaconModulesPriority(module_panel)
    else
      -- module selector
      self:updateBeaconModulesSelector(module_panel)
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules priority
--
-- @function [parent=#RecipeEdition] updateBeaconModulesPriority
--
-- @param #LuaGuiElement beacon_module_panel
-- @param #string block_id
-- @param #string recipe_id
--
function RecipeEdition:updateBeaconModulesPriority(beacon_module_panel)
  local model, block, recipe = self:getParameterObjects()
  -- module priority
  local beacon_module_priority = User.getParameter("beacon_module_priority") or 1
  local priority_modules = User.getParameter("priority_modules") or {}

  -- configuration select
  local tool_action_panel2 = GuiElement.add(beacon_module_panel, GuiFlowH("tool-action2"))
  tool_action_panel2.style.horizontal_spacing = 10
  tool_action_panel2.style.bottom_padding = 10

  local tool_panel1 = GuiElement.add(tool_action_panel2, GuiFlowH("tool1"))
  tool_panel1.style.horizontal_spacing = tool_spacing
  local button_style = "helmod_button_small_bold"
  GuiElement.add(tool_panel1, GuiButton("HMPreferenceEdition", "OPEN", "priority_module"):sprite("menu", "services-sm", "services-sm"):style("helmod_button_menu_sm"):tooltip({"helmod_button.preferences"}))
  GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-priority-apply", model.id, block.id, recipe.id):sprite("menu", "arrow-up-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"helmod_recipe-edition-panel.apply-priority"}))

  local tool_panel2 = GuiElement.add(tool_action_panel2,  GuiTable("tool2"):column(6))
  for i, priority_module in pairs(priority_modules) do
    local button_style2 = button_style
    if beacon_module_priority == i then button_style2 = "helmod_button_small_bold_selected" end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-module-priority-select", model.id, block.id, recipe.id, i):caption(i):style(button_style2))
  end

  -- module priority info
  local priority_table_panel = GuiElement.add(beacon_module_panel, GuiTable("module-priority-table"):column(2))
  if priority_modules[beacon_module_priority] ~= nil then
    local control_info = "module-add"
    for index, element in pairs(priority_modules[beacon_module_priority]) do
      local color = nil
      local tooltip = GuiTooltipModule("tooltip.add-module"):element({type="item", name=element.name}):withControlInfo(control_info)
      local module = ItemPrototype(element.name)
      if Player.checkBeaconLimitationModule(module:native(), recipe) == false then
        if module.limitation_message_key ~= nil then
          tooltip = {"item-limitation."..module.limitation_message_key}
        else
          tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
        end
        color = GuiElement.color_button_rest
      end
      GuiElement.add(priority_table_panel, GuiButtonSelectSprite(self.classname, "beacon-module-select", model.id, block.id, recipe.id):sprite("entity", element.name):color(color):index(index):tooltip(tooltip))
      GuiElement.add(priority_table_panel, GuiLabel("priority-value", index):caption({"", "x", element.value}))
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules selector
--
-- @function [parent=#RecipeEdition] updateBeaconModulesSelector
--
-- @param #LuaGuiElement beacon_module_panel
-- @param #string block_id
-- @param #string recipe_id
--
function RecipeEdition:updateBeaconModulesSelector(beacon_module_panel)
  local model, block, recipe = self:getParameterObjects()
  
  local module_scroll = GuiElement.add(beacon_module_panel, GuiScroll("module-selector-scroll"))
  module_scroll.style.maximal_height = 118
  local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(6))
  for k, element in pairs(Player.getModules()) do
    local color = nil
    local control_info = "module-add"
    local tooltip = GuiTooltipModule("tooltip.add-module"):element({type="item", name=element.name}):withControlInfo(control_info)
    local module = ItemPrototype(element.name)
    if Player.checkBeaconLimitationModule(module:native(), recipe) == false then
      if module.limitation_message_key ~= nil then
        tooltip = {"item-limitation."..module.limitation_message_key}
      else
        tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
      end
      color = GuiElement.color_button_rest
    end
    GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "beacon-module-select", model.id, block.id, recipe.id):sprite("entity", element.name):color(color):tooltip(tooltip))
  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#RecipeEdition] updateHeader
--
-- @param #LuaEvent event
--
function RecipeEdition:updateHeader(event)
  self:updateObjectInfo(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeEdition] updateObjectInfo
--
-- @param #LuaEvent event
--
function RecipeEdition:updateObjectInfo(event)
  local info_panel = self:getObjectInfoPanel()
  local model, block, recipe = self:getParameterObjects()
  if block ~= nil and recipe ~= nil then
    info_panel.clear()

    local recipe_prototype = RecipePrototype(recipe)
    local recipe_table = GuiElement.add(info_panel, GuiTable("list-data"):column(4))
    recipe_table.style.horizontally_stretchable = false
    recipe_table.style.horizontal_spacing = 10
    recipe_table.vertical_centering = false

    GuiElement.add(recipe_table, GuiLabel("header-recipe"):caption({"helmod_result-panel.col-header-recipe"}))
    GuiElement.add(recipe_table, GuiLabel("header-energy"):caption({"helmod_result-panel.col-header-energy"}))
    GuiElement.add(recipe_table, GuiLabel("header-products"):caption({"helmod_result-panel.col-header-products"}))
    GuiElement.add(recipe_table, GuiLabel("header-ingredients"):caption({"helmod_result-panel.col-header-ingredients"}))
    local cell_recipe = GuiElement.add(recipe_table, GuiFrameH("recipe", recipe.id):style(helmod_frame_style.hidden))
    GuiElement.add(cell_recipe, GuiCellRecipe(self.classname, "do_noting"):element(recipe):tooltip("helmod_common.recipe"):color("gray"))


    -- energy
    local cell_energy = GuiElement.add(recipe_table, GuiFrameH("energy", recipe.id):style(helmod_frame_style.hidden))
    local element_energy = {name = "helmod_button_menu_flat", hovered = "clock-white", sprite = "clock" , count = recipe_prototype:getEnergy(),localised_name = "helmod_label.energy"}
    GuiElement.add(cell_energy, GuiCellProduct(self.classname, "do_noting"):element(element_energy):tooltip("tooltip.product"):color("gray"))

    -- products
    local cell_products = GuiElement.add(recipe_table, GuiTable("products", recipe.id):column(3):style("helmod_table_element"))
    local lua_products = recipe_prototype:getProducts(recipe.factory)
    if lua_products ~= nil then
      for index, lua_product in pairs(lua_products) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:getElementAmount()
        GuiElement.add(cell_products, GuiCellProductSm(self.classname, "do_noting"):element(product):tooltip("tooltip.product"):index(index):color(GuiElement.color_button_none))
      end
    end

    -- ingredients
    local cell_ingredients = GuiElement.add(recipe_table, GuiTable("ingredients", recipe.id):column(5):style("helmod_table_element"))
    local lua_ingredients = recipe_prototype:getIngredients(recipe.factory)
    if lua_ingredients ~= nil then
      for index, lua_ingredient in pairs(lua_ingredients) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:getElementAmount()
        GuiElement.add(cell_ingredients, GuiCellProductSm(self.classname, "do_noting"):element(ingredient):tooltip("tooltip.product"):index(index):color(GuiElement.color_button_add))
      end
    end

    local tablePanel = GuiElement.add(info_panel, GuiTable("table-input"):column(2))
    GuiElement.add(tablePanel, GuiLabel("label-production"):caption({"helmod_recipe-edition-panel.production"}))
    GuiElement.add(tablePanel, GuiTextField(self.classname, "recipe-update", model.id, block.id, recipe.id):text(Format.formatNumberElement((recipe.production or 1)*100)):style("helmod_textfield"))

  end
end
