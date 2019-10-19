-------------------------------------------------------------------------------
-- Class to build recipe edition dialog
--
-- @module RecipeEdition
-- @extends #AbstractEdition
--

RecipeEdition = newclass(Form,function(base,classname)
  Form.init(base,classname)
  base.content_verticaly = true
end)

local limit_display_height = 850

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
-- On initialization
--
-- @function [parent=#RecipeEdition] onInit
--
function RecipeEdition:onInit()
  Logging:debug(self.classname, "onInit()")
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
  local panel = ElementGui.addGuiFrameV(content_panel, "info", helmod_frame_style.default)

  return panel
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#RecipeEdition] getOtherInfoPanel
--
-- @return #LuaGuiElement
--
function RecipeEdition:getOtherInfoPanel()
  local panel = self:getRecipePanel()
  if panel["other_info_panel"] ~= nil and panel["other_info_panel"].valid then
    return panel["other_info_panel"]
  end
  local table_panel = ElementGui.addGuiTable(panel, "other_info_panel", 1, helmod_table_style.panel)
  return table_panel
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#RecipeEdition] getTabPanel
--
function RecipeEdition:getTabPanel()
  local display_width, display_height = ElementGui.getDisplaySizes()
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
-- Get object
--
-- @function [parent=#RecipeEdition] getObject
--
function RecipeEdition:getObject()
  local model = Model.getModel()
  local element = User.getParameter("recipe_edition_object")
  if element ~= nil and model.blocks[element.block] ~= nil and model.blocks[element.block].recipes[element.recipe] ~= nil then
    return model.blocks[element.block].recipes[element.recipe]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Get or create factory panel
--
-- @function [parent=#RecipeEdition] getFactoryPanel
--
function RecipeEdition:getFactoryPanel()
  local content_panel, _ = self:getTabPanel()
  local table_name = "factory_table"
  local factory_info_name = "factory_info"
  local factory_module_name = "factory_module"
  if content_panel[table_name] ~= nil and content_panel[table_name].valid then
    return content_panel[table_name][factory_info_name], content_panel[table_name][factory_module_name]
  end

  local table_panel = GuiElement.add(content_panel, GuiTable(table_name):column(2))
  table_panel.vertical_centering = false
  local factory_info_panel = GuiElement.add(table_panel, GuiFlowV(factory_info_name))
  factory_info_panel.style.width = 250
  local factory_module_panel = GuiElement.add(table_panel, GuiFlowV(factory_module_name))
  factory_module_panel.style.width = 250
  return factory_info_panel, factory_module_panel
end

-------------------------------------------------------------------------------
-- Get or create beacon panel
--
-- @function [parent=#RecipeEdition] getBeaconPanel
--
function RecipeEdition:getBeaconPanel()
  local _, content_panel = self:getTabPanel()
  local table_name = "beacon_table"
  local beacon_info_name = "beacon_info"
  local beacon_module_name = "beacon_module"
  if content_panel[table_name] ~= nil and content_panel[table_name].valid then
    return content_panel[table_name][beacon_info_name], content_panel[table_name][beacon_module_name]
  end

  local table_panel = GuiElement.add(content_panel, GuiTable(table_name):column(2))
  table_panel.vertical_centering = false
  local beacon_info_panel = GuiElement.add(table_panel, GuiFlowV(beacon_info_name))
  beacon_info_panel.style.width = 250
  local beacon_module_panel = GuiElement.add(table_panel, GuiFlowV(beacon_module_name))
  beacon_module_panel.style.width = 250
  return beacon_info_panel, beacon_module_panel
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
  local close = (event.action == "OPEN") -- only on open event
  User.setParameter("module_list_refresh",false)
  if event.action == "OPEN" and event.item1 ~= nil and event.item2 ~= nil then
    local parameter_last = string.format("%s%s", event.item1, event.item2)
    User.setParameter("recipe_edition_object", {block=event.item1, recipe=event.item2})
    Logging:debug(self.classname, "onBeforeEvent()", {block=event.item1, recipe=event.item2})
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
  Logging:debug(self.classname, "onEvent()", event)
  local display_width, display_height = ElementGui.getDisplaySizes()
  local model = Model.getModel()

  if User.isWriter() then
    if event.action == "object-update" then
      local options = {}
      local text = event.element.text
      options["production"] = (tonumber(text) or 100)/100
      ModelBuilder.updateObject(event.item1, event.item2, options)
      ModelCompute.update()
      self:updateObjectInfo(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-select" then
      --element.state = true
      -- item1=recipe item2=factory
      Model.setFactory(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-update" then
      local options = {}

      local text = event.element.text
      local ok , err = pcall(function()
        options["limit"] = formula(text) or 0

        ModelBuilder.updateFactory(event.item1, event.item2, options)
        ModelCompute.update()
        self:updateFactoryInfo(event)
        self:updateHeader(event)
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end

    if event.action == "factory-fuel-update" then

      local index = event.element.selected_index
      local object = self:getObject()
      local factory_prototype = EntityPrototype(object.factory)
      local fuel_list = factory_prototype:getBurnerPrototype():getFuelItemPrototypes()
      local items = {}
      local options = {}
      for _,item in pairs(fuel_list) do
        if index == 1 then
          options.fuel = item.name
          break end
        index = index - 1
      end
      ModelBuilder.updateFuelFactory(event.item1, event.item2, options)
      ModelCompute.update()
      self:updateFactoryInfo(event)
      self:updateHeader(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-tool" then
      local recipe = self:getObject()
      if event.item3 == "default" then
        User.setDefaultFactory(recipe)
      elseif event.item3 == "block" then
        ModelBuilder.setFactoryBlock(event.item1, recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "line" then
        ModelBuilder.setFactoryLine(recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "all" then
        User.setParameter("default_factory_mode", "all")
      elseif event.item3 == "category" then
        User.setParameter("default_factory_mode", "category")
      elseif event.item3 == "module" then
        User.setParameter("default_factory_with_module", not(User.getParameter("default_factory_with_module")))
      end
      self:update(event)
    end

    if event.action == "factory-module-tool" then
      local recipe = self:getObject()
      if event.item3 == "default" then
        User.setDefaultFactoryModule(recipe)
      elseif event.item3 == "block" then
        ModelBuilder.setFactoryModuleBlock(event.item1, recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "line" then
        ModelBuilder.setFactoryModuleLine(recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "erase" then
        ModelBuilder.setFactoryModulePriority(event.item1, event.item2, nil)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      end
      self:update(event)
    end

    if event.action == "factory-module-priority-select" then
      User.setParameter("factory_module_priority", tonumber(event.item3))
      self:updateFactoryModules(event)
    end

    if event.action == "factory-module-priority-apply" then
      local factory_module_priority = User.getParameter("factory_module_priority") or 1
      local priority_modules = User.getParameter("priority_modules")
      if factory_module_priority ~= nil and priority_modules ~= nil and priority_modules[factory_module_priority] ~= nil then
        ModelBuilder.setFactoryModulePriority(event.item1, event.item2, priority_modules[factory_module_priority])
        ModelCompute.update()
        self:update(event)
        Controller:send("on_gui_refresh", event)
      end
    end

    if event.action == "beacon-tool" then
      local recipe = self:getObject()
      if event.item3 == "default" then
        User.setDefaultBeacon(recipe)
      elseif event.item3 == "block" then
        ModelBuilder.setBeaconBlock(event.item1, recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "line" then
        ModelBuilder.setBeaconLine(recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "all" then
        User.setParameter("default_beacon_mode", "all")
      elseif event.item3 == "category" then
        User.setParameter("default_beacon_mode", "category")
      elseif event.item3 == "module" then
        User.setParameter("default_beacon_with_module", not(User.getParameter("default_beacon_with_module")))
      end
      self:update(event)
    end

    if event.action == "beacon-module-tool" then
      local recipe = self:getObject()
      if event.item3 == "default" then
        User.setDefaultBeaconModule(recipe)
      elseif event.item3 == "block" then
        ModelBuilder.setBeaconModuleBlock(event.item1, recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "line" then
        ModelBuilder.setBeaconModuleLine(recipe)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      elseif event.item3 == "erase" then
        ModelBuilder.setBeaconModulePriority(event.item1, event.item2, nil)
        ModelCompute.update()
        Controller:send("on_gui_refresh", event)
      end
      self:update(event)
    end

    if event.action == "beacon-module-priority-select" then
      User.setParameter("beacon_module_priority", tonumber(event.item3))
      self:updateBeaconModules(event)
    end

    if event.action == "beacon-module-priority-apply" then
      local beacon_module_priority = User.getParameter("beacon_module_priority") or 1
      local priority_modules = User.getParameter("priority_modules")
      if beacon_module_priority ~= nil and priority_modules ~= nil and priority_modules[beacon_module_priority] ~= nil then
        ModelBuilder.setBeaconModulePriority(event.item1, event.item2, priority_modules[beacon_module_priority])
        ModelCompute.update()
        self:update(event)
        Controller:send("on_gui_refresh", event)
      end
    end

    if event.action == "beacon-select" then
      Model.setBeacon(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:update(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "beacon-update" then
      local options = {}
      local text = event.element.text
      -- item3 = "combo" or "factory"
      local ok , err = pcall(function()
        options[event.item3] = formula(text) or 0

        ModelBuilder.updateBeacon(event.item1, event.item2, options)
        ModelCompute.update()
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
  Logging:debug(self.classname, "onOpen()", event)
  local object = self:getObject()

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
  Logging:debug(self.classname, "onUpdate()", event)
  local object = self:getObject()
  -- header
  self:updateHeader(event)
  if object ~= nil then
    self:updateFactory(event)
    self:updateBeacon(event)
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
  Logging:debug(self.classname, "updateTabMenu()", event)
  local tab_left_panel = self:getTabLeftPanel()
  local tab_right_panel = self:getTabRightPanel()
  local object = self:getObject()

  local display_width, display_height = ElementGui.getDisplaySizes()

  tab_left_panel.clear()
  tab_right_panel.clear()

  -- left tab
  if display_height < limit_display_height then
    local style = "helmod_button_tab"
    if User.getParameter("factory_tab") == true then style = "helmod_button_tab_selected" end

    ElementGui.addGuiFrameH(tab_left_panel, self.classname.."_separator_factory",helmod_frame_style.tab).style.width = 5
    ElementGui.addGuiButton(tab_left_panel, self.classname.."=edition-change-tab=ID="..event.item1.."="..object.id.."=", "factory", style, {"helmod_common.factory"}, {"helmod_common.factory"})

    local style = "helmod_button_tab"
    if User.getParameter("factory_tab") == false then style = "helmod_button_tab_selected" end

    ElementGui.addGuiFrameH(tab_left_panel, self.classname.."_separator_beacon",helmod_frame_style.tab).style.width = 5
    ElementGui.addGuiButton(tab_left_panel, self.classname.."=edition-change-tab=ID="..event.item1.."="..object.id.."=", "beacon", style, {"helmod_common.beacon"}, {"helmod_common.beacon"})

    ElementGui.addGuiFrameH(tab_left_panel,"tab_final",helmod_frame_style.tab).style.width = 100
  end
  -- right tab
  local style = "helmod_button_tab"
  if User.getParameter("module_panel") == false then style = "helmod_button_tab_selected" end

  ElementGui.addGuiFrameH(tab_right_panel, self.classname.."_separator_factory",helmod_frame_style.tab).style.width = 5
  ElementGui.addGuiButton(tab_right_panel, self.classname.."=change-panel=ID="..event.item1.."="..object.id.."=", "factory", style, {"helmod_common.factory"}, {"tooltip.selector-factory"})

  local style = "helmod_button_tab"
  if User.getParameter("module_panel") == true then style = "helmod_button_tab_selected" end

  ElementGui.addGuiFrameH(tab_right_panel, self.classname.."_separator_module",helmod_frame_style.tab).style.width = 5
  ElementGui.addGuiButton(tab_right_panel, self.classname.."=change-panel=ID="..event.item1.."="..object.id.."=", "module", style, {"helmod_common.module"}, {"tooltip.selector-module"})

  ElementGui.addGuiFrameH(tab_right_panel,"tab_final",helmod_frame_style.tab).style.width = 100
end

-------------------------------------------------------------------------------
-- Update factory
--
-- @function [parent=#RecipeEdition] updateFactory
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactory(event)
  Logging:debug(self.classname, "updateFactory()", event)

  self:updateFactoryInfo(event)
  self:updateFactoryModules(event)
end

-------------------------------------------------------------------------------
-- Update beacon
--
-- @function [parent=#RecipeEdition] updateBeacon
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeacon(event)
  Logging:debug(self.classname, "updateBeacon()", event)

  self:updateBeaconInfo(event)
  self:updateBeaconModules(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeEdition] updateFactoryInfo
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryInfo(event)
  Logging:debug(self.classname, "updateFactoryInfo()", event)
  local factory_info_panel, factory_module_panel = self:getFactoryPanel()
  local element = User.getParameter("recipe_edition_object")
  local recipe = self:getObject()
  if element ~= nil and recipe ~= nil then
    local block_id = element.block
    local recipe_id = element.recipe
    Logging:debug(self.classname, "updateFactoryInfo():object:",recipe)
    local factory = recipe.factory
    local factory_prototype = EntityPrototype(factory)

    factory_info_panel.clear()
    GuiElement.add(factory_info_panel, GuiLabel("factory_label"):caption({"helmod_common.factory"}):style("helmod_label_title_frame"))

    -- factory tool
    local tool_action_panel = GuiElement.add(factory_info_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))

    local default_factory = User.getDefaultFactory(recipe)
    local record_style = "helmod_button_icon_record_sm"
    if default_factory ~= nil and default_factory.name == factory.name  then record_style = "helmod_button_icon_record_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool=ID", block_id, recipe_id, "default"):style(record_style):tooltip({"helmod_recipe-edition-panel.set-default"}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool=ID", block_id, recipe_id, "block"):style("helmod_button_icon_play_sm"):tooltip({"helmod_recipe-edition-panel.apply-block", {"helmod_recipe-edition-panel.current-factory"}}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool=ID", block_id, recipe_id, "line"):style("helmod_button_icon_end_sm"):tooltip({"helmod_recipe-edition-panel.apply-line", {"helmod_recipe-edition-panel.current-factory"}}))

    local tool_panel2 = GuiElement.add(tool_action_panel, GuiFlowH("tool2"))
    local button_style = "helmod_button_small_bold"
    local selected_button_style = "helmod_button_small_bold_selected"
    local default_factory_mode = User.getParameter("default_factory_mode")
    local all_button_style = button_style
    local category_button_style = selected_button_style
    if default_factory_mode ~= "category" then
      all_button_style = selected_button_style
      category_button_style = button_style
    end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool=ID", block_id, recipe_id, "all"):caption("A"):style(all_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-all"}))
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool=ID", block_id, recipe_id, "category"):caption("C"):style(category_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-category"}))
    local default_factory_with_module = User.getParameter("default_factory_with_module")
    local module_button_style = button_style
    if default_factory_with_module == true then module_button_style = selected_button_style end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-tool=ID", block_id, recipe_id, "module"):caption("M"):style(module_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-module"}))

    -- factory selection
    local scroll_panel = GuiElement.add(factory_info_panel, GuiScroll("factory-scroll"):policy(true))
    local recipe_prototype = RecipePrototype(recipe)
    local category = recipe_prototype:getCategory()
    local factories = Player.getProductionsCrafting(category, recipe)

    local factory_table_panel = GuiElement.add(scroll_panel, GuiTable("factory-table"):column(5))
    for key, element in pairs(factories) do
      local localised_name = EntityPrototype(element.name):getLocalisedName()
      local color = nil
      if factory.name == element.name then color = ElementGui.color_button_edit end
      GuiElement.add(factory_table_panel, GuiButtonSelectSprite(self.classname, "factory-select=ID", block_id, recipe_id):sprite("entity", element.name):tooltip(localised_name):color(color))
    end

    -- factory info
    local header_panel = GuiElement.add(factory_info_panel, GuiTable("table-header"):column(2))
    if factory_prototype:native() == nil then
      GuiElement.add(header_panel, GuiLabel("label"):caption(factory.name))
    else
      GuiElement.add(header_panel, GuiLabel("label"):caption(factory_prototype:getLocalisedName()))
    end

    local input_panel = GuiElement.add(factory_info_panel, GuiTable("table-input"):column(2))

    GuiElement.add(input_panel, GuiLabel("label-module-slots"):caption({"helmod_label.module-slots"}))
    GuiElement.add(input_panel, GuiLabel("module-slots"):caption(factory_prototype:getModuleInventorySize()))

    GuiElement.add(input_panel, GuiLabel("label-energy"):caption({"helmod_label.energy"}))

    local sign = ""
    if factory.effects.consumption > 0 then sign = "+" end
    GuiElement.add(input_panel, GuiLabel("energy"):caption(Format.formatNumberKilo(factory.energy, "W").." ("..sign..Format.formatPercent(factory.effects.consumption).."%)"))
    if factory_prototype:getEnergyType() == "burner" then

      GuiElement.add(input_panel, GuiLabel("label-burner"):caption({"helmod_common.resource"}))
      local fuel_list = factory_prototype:getBurnerPrototype():getFuelItemPrototypes()
      local first_fuel = factory_prototype:getBurnerPrototype():getFirstFuelItemPrototype()
      local items = {}
      for _,item in pairs(fuel_list) do
        table.insert(items,"[item="..item.name.."]")
      end
      local default_fuel = "[item="..(factory.fuel or first_fuel.name).."]"
      GuiElement.add(input_panel, GuiDropDown(self.classname, "factory-fuel-update=ID", block_id, recipe_id):items(items, default_fuel))
    end

    local sign = ""
    if factory.effects.speed > 0 then sign = "+" end
    GuiElement.add(input_panel, GuiLabel("label-speed"):caption({"helmod_label.speed"}))
    GuiElement.add(input_panel, GuiLabel("speed"):caption(Format.formatNumber(factory.speed).." ("..sign..Format.formatPercent(factory.effects.speed).."%)"))

    local sign = ""
    if factory.effects.productivity > 0 then sign = "+" end
    GuiElement.add(input_panel, GuiLabel("label-productivity"):caption({"helmod_label.productivity"}))
    local productivity_tooltip = nil
    if recipe.type == "resource" then
    --productivity_tooltip = ({"gui-bonus.mining-drill-productivity-bonus"})
    end
    GuiElement.add(input_panel, GuiLabel("productivity"):caption(sign..Format.formatPercent(factory.effects.productivity).."%"):tooltip(productivity_tooltip))

    GuiElement.add(input_panel, GuiLabel("label-limit"):caption({"helmod_label.limit"}):tooltip({"tooltip.factory-limit"}))
    GuiElement.add(input_panel, GuiTextField(self.classname, "factory-update=ID", block_id, recipe_id):text(factory.limit):tooltip({"tooltip.factory-limit"}))

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
  Logging:debug(self.classname, "updateFactoryModules()", event)
  local factory_info_panel, factory_module_panel, factory_tool_panel = self:getFactoryPanel()
  local element = User.getParameter("recipe_edition_object")
  local recipe = self:getObject()
  if element ~= nil and recipe ~= nil then
    local block_id = element.block
    local recipe_id = element.recipe
    local factory = recipe.factory

    factory_module_panel.clear()

    GuiElement.add(factory_module_panel, GuiLabel("module_label"):caption({"helmod_recipe-edition-panel.current-modules"}):style("helmod_label_title_frame"))

    -- module tool
    local tool_action_panel = GuiElement.add(factory_module_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
    local default_factory_module = User.getDefaultFactoryModule(recipe)
    local record_style = "helmod_button_icon_record_sm"
    Logging:debug(self.classname, "default_factory_module", default_factory_module, factory.module_priority)
    if compare_priority(default_factory_module, factory.module_priority) then record_style = "helmod_button_icon_record_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool=ID", block_id, recipe_id, "default"):style(record_style):tooltip({"helmod_recipe-edition-panel.set-default"}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool=ID", block_id, recipe_id, "block"):style("helmod_button_icon_play_sm"):tooltip({"helmod_recipe-edition-panel.apply-block", {"helmod_recipe-edition-panel.current-module"}}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool=ID", block_id, recipe_id, "line"):style("helmod_button_icon_end_sm"):tooltip({"helmod_recipe-edition-panel.apply-line", {"helmod_recipe-edition-panel.current-module"}}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool=ID", block_id, recipe_id, "erase"):style("helmod_button_icon_erase_sm"):tooltip({"helmod_recipe-edition-panel.module-clear"}))

    -- actived modules panel
    local module_table = GuiElement.add(factory_module_panel, GuiTable("modules"):column(6):style("helmod_table_recipe_modules"))
    for module, count in pairs(factory.modules) do
      for i = 1, count, 1 do
        GuiElement.add(module_table, GuiButtonSelectSprite(self.classname, "factory-module-remove=ID", block_id, recipe_id, module, i):sprite("item", module):tooltip(ElementGui.getTooltipModule(module)))
      end
    end

    -- module priority
    local factory_module_priority = User.getParameter("factory_module_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    GuiElement.add(factory_module_panel, GuiLabel("priority_label"):caption("Module priority"):style("helmod_label_title_frame"))

    -- configuration select
    local tool_action_panel2 = GuiElement.add(factory_module_panel, GuiFlowH("tool-action2"))
    tool_action_panel2.style.horizontal_spacing = 10
    tool_action_panel2.style.bottom_padding = 10

    local tool_panel1 = GuiElement.add(tool_action_panel2, GuiFlowH("tool1"))
    local button_style = "helmod_button_small_bold"
    GuiElement.add(tool_panel1, GuiButton("HMPreferenceEdition=OPEN=ID="):style("helmod_button_icon_services_sm"):tooltip({"helmod_button.preferences"}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-priority-apply=ID", block_id, recipe_id):style("helmod_button_icon_arrow_top_sm"):tooltip({"helmod_recipe-edition-panel.apply-priority"}))

    local tool_panel2 = GuiElement.add(tool_action_panel2, GuiFlowH("tool2"))
    for i, priority_module in pairs(priority_modules) do
      local button_style2 = button_style
      if factory_module_priority == i then button_style2 = "helmod_button_small_bold_selected" end
      GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-module-priority-select=ID", block_id, recipe_id, i):caption(i):style(button_style2))
    end

    -- module priority info
    local priority_table_panel = GuiElement.add(factory_module_panel, GuiTable("module-priority-table"):column(2))
    if priority_modules[factory_module_priority] ~= nil then
      Logging:debug(self.classname, "priority_modules", priority_modules, factory_module_priority)
      for index, element in pairs(priority_modules[factory_module_priority]) do
        local tooltip = ElementGui.getTooltipModule(element.name)
        local module = ItemPrototype(element.name)
        if Player.checkFactoryLimitationModule(module:native(), recipe) == false then
          if module.limitation_message_key ~= nil then
            tooltip = {"item-limitation."..module.limitation_message_key}
          else
            tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
          end
        end
        GuiElement.add(priority_table_panel, GuiButtonSprite("do-nothing", block_id, recipe_id, index):sprite("entity", element.name):tooltip(tooltip))
        GuiElement.add(priority_table_panel, GuiLabel("priority-value", index):caption(element.value))
      end
    end
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
  Logging:debug(self.classname, "updateBeaconInfo()", event)
  local beacon_info_panel, beacon_module_panel = self:getBeaconPanel()
  local element = User.getParameter("recipe_edition_object")
  local recipe = self:getObject()
  if element ~= nil and recipe ~= nil then
    local block_id = element.block
    local recipe_id = element.recipe
    local beacon = recipe.beacon
    local beacon_prototype = EntityPrototype(beacon)

    beacon_info_panel.clear()
    GuiElement.add(beacon_info_panel, GuiLabel("beacon_label"):caption({"helmod_common.beacon"}):style("helmod_label_title_frame"))
    -- factory tool
    local tool_action_panel = GuiElement.add(beacon_info_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))

    local default_beacon = User.getDefaultBeacon(recipe)
    local record_style = "helmod_button_icon_record_sm"
    if default_beacon ~= nil and default_beacon.name == beacon.name  then record_style = "helmod_button_icon_record_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool=ID", block_id, recipe_id, "default"):style(record_style):tooltip({"helmod_recipe-edition-panel.set-default"}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool=ID", block_id, recipe_id, "block"):style("helmod_button_icon_play_sm"):tooltip({"helmod_recipe-edition-panel.apply-block", {"helmod_recipe-edition-panel.current-beacon"}}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool=ID", block_id, recipe_id, "line"):style("helmod_button_icon_end_sm"):tooltip({"helmod_recipe-edition-panel.apply-line", {"helmod_recipe-edition-panel.current-beacon"}}))

    local tool_panel2 = GuiElement.add(tool_action_panel, GuiFlowH("tool2"))
    local button_style = "helmod_button_small_bold"
    local selected_button_style = "helmod_button_small_bold_selected"
    local default_beacon_mode = User.getParameter("default_beacon_mode")
    local all_button_style = button_style
    local category_button_style = selected_button_style
    if default_beacon_mode ~= "category" then
      all_button_style = selected_button_style
      category_button_style = button_style
    end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-tool=ID", block_id, recipe_id, "all"):caption("A"):style(all_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-all"}))
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-tool=ID", block_id, recipe_id, "category"):caption("C"):style(category_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-category"}))
    local default_beacon_with_module = User.getParameter("default_beacon_with_module")
    local module_button_style = button_style
    if default_beacon_with_module == true then module_button_style = selected_button_style end
    GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-tool=ID", block_id, recipe_id, "module"):caption("M"):style(module_button_style):tooltip({"helmod_recipe-edition-panel.apply-option-module"}))

    -- factory selection
    local scroll_panel = GuiElement.add(beacon_info_panel, GuiScroll("beacon-scroll"):policy(true))
    local factories = Player.getProductionsBeacon()

    local factory_table_panel = GuiElement.add(scroll_panel, GuiTable("beacon-table"):column(5))
    for key, element in pairs(factories) do
      local localised_name = EntityPrototype(element.name):getLocalisedName()
      local color = nil
      if beacon.name == element.name then color = ElementGui.color_button_edit end
      GuiElement.add(factory_table_panel, GuiButtonSelectSprite(self.classname, "beacon-select=ID", block_id, recipe_id):sprite("entity", element.name):tooltip(localised_name):color(color))
    end

    -- beacon info
    local header_panel = GuiElement.add(beacon_info_panel, GuiTable("table-header"):column(2))
    if beacon_prototype:native() == nil then
      GuiElement.add(header_panel, GuiLabel("label"):caption(beacon.name))
    else
      GuiElement.add(header_panel, GuiLabel("label"):caption(beacon_prototype:getLocalisedName()))
    end

    local input_panel = GuiElement.add(beacon_info_panel, GuiTable("table-input"):column(2))

    GuiElement.add(input_panel, GuiLabel("label-module-slots"):caption({"helmod_label.module-slots"}))
    GuiElement.add(input_panel, GuiLabel("module-slots"):caption(beacon_prototype:getModuleInventorySize()))

    GuiElement.add(input_panel, GuiLabel("label-energy-nominal"):caption({"helmod_label.energy"}))
    GuiElement.add(input_panel, GuiLabel("energy"):caption(Format.formatNumberKilo(beacon_prototype:getEnergyUsage(), "W")))

    GuiElement.add(input_panel, GuiLabel("label-efficiency"):caption({"helmod_label.efficiency"}))
    GuiElement.add(input_panel, GuiLabel("efficiency"):caption(beacon_prototype:getDistributionEffectivity()))

    GuiElement.add(input_panel, GuiLabel("label-combo"):caption({"helmod_label.beacon-on-factory"}):tooltip({"tooltip.beacon-on-factory"}))
    ElementGui.addGuiText(input_panel, string.format("%s=beacon-update=ID=%s=%s=%s", self.classname, block_id, recipe_id, "combo"), beacon.combo, "helmod_textfield", {"tooltip.beacon-on-factory"})

    GuiElement.add(input_panel, GuiLabel("label-factory"):caption({"helmod_label.factory-per-beacon"}):tooltip({"tooltip.factory-per-beacon"}))
    ElementGui.addGuiText(input_panel, string.format("%s=beacon-update=ID=%s=%s=%s", self.classname, block_id, recipe_id, "factory"), beacon.factory, "helmod_textfield", {"tooltip.factory-per-beacon"})
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
  Logging:debug(self.classname, "updateBeaconActivedModules()", event)
  local beacon_info_panel, beacon_module_panel = self:getBeaconPanel()
  local element = User.getParameter("recipe_edition_object")
  local recipe = self:getObject()
  if element ~= nil and recipe ~= nil then
    local block_id = element.block
    local recipe_id = element.recipe
    local beacon = recipe.beacon

    beacon_module_panel.clear()

    GuiElement.add(beacon_module_panel, GuiLabel("module_label"):caption({"helmod_recipe-edition-panel.current-modules"}):style("helmod_label_title_frame"))

    -- module tool
    local tool_action_panel = GuiElement.add(beacon_module_panel, GuiFlowH("tool-action"))
    tool_action_panel.style.horizontal_spacing = 10
    tool_action_panel.style.bottom_padding = 10
    local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
    local default_beacon_module = User.getDefaultBeaconModule(recipe)
    local record_style = "helmod_button_icon_record_sm"
    Logging:debug(self.classname, "default_factory_module", default_beacon_module, beacon.module_priority)
    if compare_priority(default_beacon_module, beacon.module_priority) then record_style = "helmod_button_icon_record_sm_selected" end
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool=ID", block_id, recipe_id, "default"):style(record_style):tooltip({"helmod_recipe-edition-panel.set-default"}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool=ID", block_id, recipe_id, "block"):style("helmod_button_icon_play_sm"):tooltip({"helmod_recipe-edition-panel.apply-block", {"helmod_recipe-edition-panel.current-module"}}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool=ID", block_id, recipe_id, "line"):style("helmod_button_icon_end_sm"):tooltip({"helmod_recipe-edition-panel.apply-line", {"helmod_recipe-edition-panel.current-module"}}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool=ID", block_id, recipe_id, "erase"):style("helmod_button_icon_erase_sm"):tooltip({"helmod_recipe-edition-panel.module-clear"}))

    -- actived modules panel
    local module_table = GuiElement.add(beacon_module_panel, GuiTable("modules"):column(6):style("helmod_table_recipe_modules"))
    for module, count in pairs(beacon.modules) do
      for i = 1, count, 1 do
        GuiElement.add(module_table, GuiButtonSelectSprite(self.classname, "beacon-module-remove=ID", block_id, recipe_id, module, i):sprite("item", module):tooltip(ElementGui.getTooltipModule(module)))
      end
    end

    -- module priority
    local beacon_module_priority = User.getParameter("beacon_module_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    GuiElement.add(beacon_module_panel, GuiLabel("priority_label"):caption("Module priority"):style("helmod_label_title_frame"))

    -- configuration select
    local tool_action_panel2 = GuiElement.add(beacon_module_panel, GuiFlowH("tool-action2"))
    tool_action_panel2.style.horizontal_spacing = 10
    tool_action_panel2.style.bottom_padding = 10

    local tool_panel1 = GuiElement.add(tool_action_panel2, GuiFlowH("tool1"))
    local button_style = "helmod_button_small_bold"
    GuiElement.add(tool_panel1, GuiButton("HMPreferenceEdition=OPEN=ID="):style("helmod_button_icon_services_sm"):tooltip({"helmod_button.preferences"}))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-priority-apply=ID", block_id, recipe_id):style("helmod_button_icon_arrow_top_sm"):tooltip({"helmod_recipe-edition-panel.apply-priority"}))

    local tool_panel2 = GuiElement.add(tool_action_panel2, GuiFlowH("tool2"))
    for i, priority_module in pairs(priority_modules) do
      local button_style2 = button_style
      if beacon_module_priority == i then button_style2 = "helmod_button_small_bold_selected" end
      GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-module-priority-select=ID", block_id, recipe_id, i):caption(i):style(button_style2))
    end

    -- module priority info
    local priority_table_panel = GuiElement.add(beacon_module_panel, GuiTable("module-priority-table"):column(2))
    if priority_modules[beacon_module_priority] ~= nil then
      Logging:debug(self.classname, "priority_modules", priority_modules, beacon_module_priority)
      for index, element in pairs(priority_modules[beacon_module_priority]) do
        local tooltip = ElementGui.getTooltipModule(element.name)
        local module = ItemPrototype(element.name)
        if Player.checkBeaconLimitationModule(module:native(), recipe) == false then
          if module.limitation_message_key ~= nil then
            tooltip = {"item-limitation."..module.limitation_message_key}
          else
            tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
          end
        end
        GuiElement.add(priority_table_panel, GuiButtonSprite("do-nothing", block_id, recipe_id, index):sprite("entity", element.name):tooltip(tooltip))
        GuiElement.add(priority_table_panel, GuiLabel("priority-value", index):caption(element.value))
      end
    end
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
  Logging:debug(self.classname, "updateHeader()", event)
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
  Logging:debug(self.classname, "updateObjectInfo()", event)
  local info_panel = self:getObjectInfoPanel()
  local model = Model.getModel()
  local element = User.getParameter("recipe_edition_object")
  local recipe = self:getObject()
  if element ~= nil and recipe ~= nil then
    local block_id = element.block
    local recipe_id = element.recipe
    Logging:debug(self.classname, "updateObjectInfo():recipe=",recipe)
    info_panel.clear()

    local recipe_prototype = RecipePrototype(recipe)
    local recipe_table = GuiElement.add(info_panel, GuiTable("list-data"):column(4))
    recipe_table.vertical_centering = false

    ElementGui.addGuiLabel(recipe_table, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
    ElementGui.addGuiLabel(recipe_table, "header-energy", ({"helmod_result-panel.col-header-energy"}))
    ElementGui.addGuiLabel(recipe_table, "header-products", ({"helmod_result-panel.col-header-products"}))
    ElementGui.addGuiLabel(recipe_table, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
    local cell_recipe = ElementGui.addGuiFrameH(recipe_table,"recipe"..recipe.id, helmod_frame_style.hidden)
    ElementGui.addCellRecipe(cell_recipe, recipe, self.classname.."=do_noting=ID=", true, "tooltip.product", "gray")


    -- energy
    local cell_energy = ElementGui.addGuiFrameH(recipe_table,"energy"..recipe.id, helmod_frame_style.hidden)
    local element_energy = {name = "helmod_button_icon_clock_flat2" ,count = recipe_prototype:getEnergy(),localised_name = "helmod_label.energy"}
    ElementGui.addCellProduct(cell_energy, element_energy, self.classname.."=do_noting=ID=", true, "tooltip.product", "gray")

    -- products
    local cell_products = GuiElement.add(recipe_table, GuiTable("products", recipe.id):column(3):style("helmod_table_element"))
    if recipe_prototype:getProducts() ~= nil then
      for index, lua_product in pairs(recipe_prototype:getProducts()) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:getElementAmount()
        ElementGui.addCellProductSm(cell_products, product, self.classname.."=do_noting=ID=", false, "tooltip.product", nil, index)
      end
    end

    -- ingredients
    local cell_ingredients = GuiElement.add(recipe_table, GuiTable("ingredients_"..recipe.id, recipe.id):column(3):style("helmod_table_element"))
    if recipe_prototype:getIngredients() ~= nil then
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:getElementAmount()
        ElementGui.addCellProductSm(cell_ingredients, ingredient, self.classname.."=do_noting=ID=", true, "tooltip.product", ElementGui.color_button_add, index)
      end
    end

    local tablePanel = ElementGui.addGuiTable(info_panel,"table-input",3)
    ElementGui.addGuiLabel(tablePanel, "label-production", ({"helmod_recipe-edition-panel.production"}))
    ElementGui.addGuiText(tablePanel, string.format("%s=object-update=ID=%s=%s", self.classname, event.item1, recipe.id), (recipe.production or 1)*100, "helmod_textfield")

  end
end
