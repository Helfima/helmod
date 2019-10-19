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
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["menu_panel"] ~= nil and content_panel["menu_panel"].valid then
    return content_panel["menu_panel"]
  end
  return ElementGui.addGuiTable(content_panel, "menu_panel", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create left panel
--
-- @function [parent=#RecipeEdition] getLeftPanel
--
function RecipeEdition:getLeftPanel()
  local panel = self:getTabPanel()
  if panel["left_panel"] ~= nil and panel["left_panel"].valid then
    return panel["left_panel"]
  end
  local left_panel = ElementGui.addGuiFrameV(panel, "left_panel", helmod_frame_style.panel)
  ElementGui.setStyle(left_panel,"recipe_edition_1","width")
  return left_panel
end

-------------------------------------------------------------------------------
-- Get or create right panel
--
-- @function [parent=#RecipeEdition] getRightPanel
--
function RecipeEdition:getRightPanel()
  local panel = self:getTabPanel()
  if panel["right_panel"] ~= nil and panel["right_panel"].valid then
    return panel["right_panel"]
  end
  local right_panel = ElementGui.addGuiFrameV(panel, "right_panel", helmod_frame_style.panel)
  ElementGui.setStyle(right_panel,"recipe_edition_2","width")
  right_panel.style.horizontally_stretchable = true
  return right_panel
end

-------------------------------------------------------------------------------
-- Get or create tab left panel
--
-- @function [parent=#RecipeEdition] getTabLeftPanel
--
function RecipeEdition:getTabLeftPanel()
  local left_panel = self:getLeftPanel()
  if left_panel["tab_left_panel"] ~= nil and left_panel["tab_left_panel"].valid then
    return left_panel["tab_left_panel"]["tab_panel"]
  end
  local tab_panel = ElementGui.addGuiFrameH(left_panel, "tab_left_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(tab_panel,"recipe_tab","height")
  local table_panel = ElementGui.addGuiTable(tab_panel, "tab_panel", 5, helmod_table_style.tab)
  table_panel.style.horizontally_stretchable = true
  return table_panel
end

-------------------------------------------------------------------------------
-- Get or create tab right panel
--
-- @function [parent=#RecipeEdition] getTabRightPanel
--
function RecipeEdition:getTabRightPanel()
  local right_panel = self:getRightPanel()
  if right_panel["tab_right_panel"] ~= nil and right_panel["tab_right_panel"].valid then
    return right_panel["tab_right_panel"]["tab_panel"]
  end
  local tab_panel = ElementGui.addGuiFrameV(right_panel, "tab_right_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(tab_panel,"recipe_tab","height")
  local table_panel = ElementGui.addGuiTable(tab_panel, "tab_panel", 5, helmod_table_style.tab)
  table_panel.style.horizontally_stretchable = true
  return table_panel
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#RecipeEdition] getObject
--
-- @param #LuaEvent event
--
function RecipeEdition:getObject(event)
  Logging:debug(self.classname, "getObject()", event)
  local model = Model.getModel()
  if  model.blocks[event.item1] ~= nil and model.blocks[event.item1].recipes[event.item2] ~= nil then
    -- return recipe
    return model.blocks[event.item1].recipes[event.item2]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Get or create factory selector panel
--
-- @function [parent=#RecipeEdition] getFactorySelectorPanel
--
function RecipeEdition:getFactorySelectorPanel()
  local right_panel = self:getRightPanel()
  if right_panel["factory_selector"] ~= nil and right_panel["factory_selector"].valid then
    return right_panel["factory_selector"]
  end
  local panel = ElementGui.addGuiFrameV(right_panel, "factory_selector", helmod_frame_style.section, ({"helmod_common.factory"}))
  ElementGui.setStyle(panel, "recipe_edition_1", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create factory info panel
--
-- @function [parent=#RecipeEdition] getFactoryInfoPanel
--
function RecipeEdition:getFactoryInfoPanel()
  local left_panel = self:getLeftPanel()
  if left_panel["factory_info"] ~= nil and left_panel["factory_info"].valid then
    return left_panel["factory_info"]
  end
  local panel = ElementGui.addGuiFrameV(left_panel, "factory_info", helmod_frame_style.section, ({"helmod_common.factory"}))
  ElementGui.setStyle(panel, "recipe_edition_1", "width")
  ElementGui.setStyle(panel, "recipe_edition_1", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create factory modules selector panel
--
-- @function [parent=#RecipeEdition] getFactoryModulesSelectorPanel
--
function RecipeEdition:getFactoryModulesSelectorPanel()
  local right_panel = self:getRightPanel()
  if right_panel["factory_selection_modules"] ~= nil and right_panel["factory_selection_modules"].valid then
    return right_panel["factory_selection_modules"]["scroll_modules"]
  end

  local selection_panel = ElementGui.addGuiFrameV(right_panel, "factory_selection_modules", helmod_frame_style.section, ({"helmod_recipe-edition-panel.selection-modules"}))
  ElementGui.setStyle(selection_panel, "recipe_edition_2", "width")
  local scroll_panel = ElementGui.addGuiScrollPane(selection_panel, "scroll_modules", helmod_scroll_style.default, true)
  ElementGui.setStyle(scroll_panel, "recipe_module", "width")
  ElementGui.setStyle(scroll_panel, "recipe_module", "height")
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create factory actived modules panel
--
-- @function [parent=#RecipeEdition] getFactoryActivedModulesPanel
--
function RecipeEdition:getFactoryActivedModulesPanel()
  local right_panel = self:getRightPanel()
  if right_panel["factory_modules"] ~= nil and right_panel["factory_modules"].valid then
    return right_panel["factory_modules"]
  end
  local panel = ElementGui.addGuiFrameV(right_panel, "factory_modules", helmod_frame_style.section, ({"helmod_recipe-edition-panel.current-modules"}))
  ElementGui.setStyle(panel, "recipe_edition_2", "width")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#RecipeEdition] getBeaconInfoPanel
--
function RecipeEdition:getBeaconInfoPanel()
  local panel = self:getLeftPanel()
  if panel["beacon_info"] ~= nil and panel["beacon_info"].valid then
    return panel["beacon_info"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "beacon_info", helmod_frame_style.section, ({"helmod_common.beacon"}))
  ElementGui.setStyle(panel, "recipe_edition_1", "width")
  ElementGui.setStyle(panel, "recipe_edition_1", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#RecipeEdition] getBeaconSelectorPanel
--
function RecipeEdition:getBeaconSelectorPanel()
  local right_panel = self:getRightPanel()
  if right_panel["beacon_selector"] ~= nil and right_panel["beacon_selector"].valid then
    return right_panel["beacon_selector"]
  end
  local panel = ElementGui.addGuiFrameV(right_panel, "beacon_selector", helmod_frame_style.section, ({"helmod_common.beacon"}))
  ElementGui.setStyle(panel, "recipe_edition_2", "width")
  ElementGui.setStyle(panel, "recipe_edition_1", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create beacon modules selector panel
--
-- @function [parent=#RecipeEdition] getBeaconModulesSelectorPanel
--
function RecipeEdition:getBeaconModulesSelectorPanel()
  local right_panel = self:getRightPanel()
  if right_panel["beacon_selection_modules"] ~= nil and right_panel["beacon_selection_modules"].valid then
    return right_panel["beacon_selection_modules"]["scroll_modules"]
  end

  local selection_panel = ElementGui.addGuiFrameV(right_panel, "beacon_selection_modules", helmod_frame_style.section, ({"helmod_recipe-edition-panel.selection-modules"}))
  ElementGui.setStyle(selection_panel, "recipe_edition_2", "width")
  local scroll_panel = ElementGui.addGuiScrollPane(selection_panel, "scroll_modules", helmod_scroll_style.recipe_list, true)
  ElementGui.setStyle(scroll_panel, "recipe_module", "width")
  ElementGui.setStyle(scroll_panel, "recipe_module", "height")
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create beacon actived modules panel
--
-- @function [parent=#RecipeEdition] getBeaconActivedModulesPanel
--
function RecipeEdition:getBeaconActivedModulesPanel()
  local right_panel = self:getRightPanel()
  if right_panel["beacon_modules"] ~= nil and right_panel["beacon_modules"].valid then
    return right_panel["beacon_modules"]
  end
  local panel = ElementGui.addGuiFrameV(right_panel, "beacon_modules", helmod_frame_style.section, ({"helmod_recipe-edition-panel.current-modules"}))
  ElementGui.setStyle(panel, "recipe_edition_2", "width")
  return panel
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#RecipeEdition] buildHeaderPanel
--
function RecipeEdition:buildHeaderPanel()
  Logging:debug(self.classname, "buildHeaderPanel()")
  self:getObjectInfoPanel()
end

-------------------------------------------------------------------------------
-- Build factory panel
--
-- @function [parent=#RecipeEdition] buildFactoryPanel
--
function RecipeEdition:buildFactoryPanel()
  Logging:debug(self.classname, "buildFactoryPanel()")
  self:getFactoryInfoPanel()
end

-------------------------------------------------------------------------------
-- Build beacon panel
--
-- @function [parent=#RecipeEdition] buildBeaconPanel
--
function RecipeEdition:buildBeaconPanel()
  Logging:debug(self.classname, "buildBeaconPanel()")
  self:getBeaconInfoPanel()
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#RecipeEdition] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function RecipeEdition:onBeforeEvent(event)
  local close = (event.action == "OPEN") -- only on open event
  User.setParameter("module_list_refresh",false)
  if event.item1 ~= nil and event.item2 ~= nil then
    local parameter_last = string.format("%s%s", event.item1, event.item2)
    if User.getParameter(self.parameterLast) or User.getParameter(self.parameterLast) ~= parameter_last then
      close = false
      User.setParameter("factory_group_selected",nil)
      User.setParameter("beacon_group_selected",nil)
      User.setParameter("module_list_refresh",true)
    end

    User.setParameter(self.parameterLast, event.item1)
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

  if event.action == "edition-change-tab" then
    User.setParameter("factory_tab",not(User.getParameter("factory_tab")))
    self:onUpdate(event)
  end

  if event.action == "change-panel" then
    User.setParameter("module_panel",not(User.getParameter("module_panel")))
    self:onUpdate(event)
  end

  if event.action == "factory-group" then
    User.setParameter("factory_group_selected", event.item3)
    self:updateFactorySelector(event)
  end

  if event.action == "beacon-group" then
    User.setParameter("beacon_group_selected", event.item3)
    self:updateBeaconSelector(event)
  end

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
      self:updateHeader(event)
      self:updateFactoryInfo(event)
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
      local object = self:getObject(event)
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

    if event.action == "factory-module-add" then
      ModelBuilder.addFactoryModule(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:updateFactoryInfo(event)
      self:updateFactoryActivedModules(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "factory-module-remove" then
      ModelBuilder.removeFactoryModule(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:updateFactoryInfo(event)
      self:updateFactoryActivedModules(event)
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "beacon-select" then
      Model.setBeacon(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:updateBeaconInfo(event)
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

    if event.action == "beacon-module-add" then
      ModelBuilder.addBeaconModule(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:updateBeaconInfo(event)
      self:updateBeaconActivedModules(event)
      if display_height >= limit_display_height or User.getParameter("factory_tab") then
        self:updateFactoryInfo(event)
      end
      Controller:send("on_gui_refresh", event)
    end

    if event.action == "beacon-module-remove" then
      ModelBuilder.removeBeaconModule(event.item1, event.item2, event.item3)
      ModelCompute.update()
      self:updateBeaconInfo(event)
      self:updateBeaconActivedModules(event)
      if display_height >= limit_display_height or User.getParameter("factory_tab") then
        self:updateFactoryInfo(event)
      end
      Controller:send("on_gui_refresh", event)
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
  local object = self:getObject(event)

  if User.getParameter("module_panel") == nil then
    User.setParameter("module_panel", true)
  end
  if User.getParameter("factory_tab") == nil then
    User.setParameter("factory_tab", true)
  end

  --self:updateTitle(event)
  self:buildHeaderPanel()
  if object ~= nil then
    -- factory
    self:buildFactoryPanel()
    -- beacon
    self:buildBeaconPanel()
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
  local display_width, display_height = ElementGui.getDisplaySizes()
  local object = self:getObject(event)
  -- header
  self:updateHeader(event)
  if object ~= nil then
    self:getLeftPanel().clear()
    self:getRightPanel().clear()
    -- tab menu
    self:updateTabMenu(event)
    if display_height >= limit_display_height or User.getParameter("factory_tab") then
      -- factory
      self:updateFactory(event)
    end
    if display_height >= limit_display_height or not(User.getParameter("factory_tab")) then
      -- beacon
      self:updateBeacon(event)
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
  Logging:debug(self.classname, "updateTabMenu()", event)
  local tab_left_panel = self:getTabLeftPanel()
  local tab_right_panel = self:getTabRightPanel()
  local object = self:getObject(event)

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
  if User.getParameter("module_panel") == true then
    self:updateFactoryActivedModules(event)
    self:updateFactoryModulesSelector(event)
  else
    self:updateFactorySelector(event)
  end
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
  if User.getParameter("module_panel") == true then
    self:updateBeaconActivedModules(event)
    self:updateBeaconModulesSelector(event)
  else
    self:updateBeaconSelector(event)
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
  Logging:debug(self.classname, "updateFactoryInfo()", event)
  local infoPanel = self:getFactoryInfoPanel()
  local object = self:getObject(event)
  if object ~= nil then
    Logging:debug(self.classname, "updateFactoryInfo():object:",object)
    local factory = object.factory
    local factory_prototype = EntityPrototype(factory)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if User.getParameter("module_panel") == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self.classname.."=change-panel=ID="..event.item1.."="..object.id.."=", factory.type, factory.name, factory.name, tooltip, ElementGui.color_button_edit)
    if factory_prototype:native() == nil then
      ElementGui.addGuiLabel(headerPanel, "label", factory.name)
    else
      ElementGui.addGuiLabel(headerPanel, "label", factory_prototype:getLocalisedName())
    end

    local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

    ElementGui.addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
    ElementGui.addGuiLabel(inputPanel, "module-slots", factory_prototype:getModuleInventorySize())

    ElementGui.addGuiLabel(inputPanel, "label-energy", ({"helmod_label.energy"}))

    local sign = ""
    if factory.effects.consumption > 0 then sign = "+" end
    ElementGui.addGuiLabel(inputPanel, "energy", Format.formatNumberKilo(factory.energy, "W").." ("..sign..Format.formatPercent(factory.effects.consumption).."%)")
    if factory_prototype:getEnergyType() == "burner" then

      ElementGui.addGuiLabel(inputPanel, "label-burner", ({"helmod_common.resource"}))
      local fuel_list = factory_prototype:getBurnerPrototype():getFuelItemPrototypes()
      local first_fuel = factory_prototype:getBurnerPrototype():getFirstFuelItemPrototype()
      local items = {}
      for _,item in pairs(fuel_list) do
        table.insert(items,"[item="..item.name.."]")
      end
      local default_fuel = "[item="..(factory.fuel or first_fuel.name).."]"
      ElementGui.addGuiDropDown(inputPanel, self.classname.."=factory-fuel-update=ID="..event.item1.."=", object.id, items, default_fuel)
    end

    local sign = ""
    if factory.effects.speed > 0 then sign = "+" end
    ElementGui.addGuiLabel(inputPanel, "label-speed", ({"helmod_label.speed"}))
    ElementGui.addGuiLabel(inputPanel, "speed", Format.formatNumber(factory.speed).." ("..sign..Format.formatPercent(factory.effects.speed).."%)")

    local sign = ""
    if factory.effects.productivity > 0 then sign = "+" end
    ElementGui.addGuiLabel(inputPanel, "label-productivity", ({"helmod_label.productivity"}))
    local productivity_tooltip = nil
    if object.type == "resource" then
    --productivity_tooltip = ({"gui-bonus.mining-drill-productivity-bonus"})
    end
    ElementGui.addGuiLabel(inputPanel, "productivity", sign..Format.formatPercent(factory.effects.productivity).."%",nil,productivity_tooltip)

    ElementGui.addGuiLabel(inputPanel, "label-limit", ({"helmod_label.limit"}), nil, {"tooltip.factory-limit"})
    ElementGui.addGuiText(inputPanel, string.format("%s=factory-update=ID=%s=%s", self.classname, event.item1, object.id), factory.limit, "helmod_textfield", {"tooltip.factory-limit"})

  end
end

-------------------------------------------------------------------------------
-- Update module selector
--
-- @function [parent=#RecipeEdition] updateFactoryModulesSelector
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryModulesSelector(event)
  Logging:debug(self.classname, "updateFactoryModulesSelector()", event)
  local selectorPanel = self:getFactoryModulesSelectorPanel()
  local object = self:getObject(event)

  selectorPanel.clear()

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    local recipe_prototype = RecipePrototype(object)
    local category = recipe_prototype:getCategory()
    for k, module in pairs(Player.getModules(category)) do
      local tooltip = ElementGui.getTooltipModule(module.name)
      if Player.checkFactoryLimitationModule(module, object) == false then
        if module.limitation_message_key ~= nil then
          tooltip = {"item-limitation."..module.limitation_message_key}
        else
          tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
        end
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=do-nothing=ID="..event.item1.."="..object.id.."=", "item", module.name, module.name, tooltip, "red")
      else
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=factory-module-add=ID="..event.item1.."="..object.id.."=", "item", module.name, module.name, tooltip)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update actived modules information
--
-- @function [parent=#RecipeEdition] updateFactoryActivedModules
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactoryActivedModules(event)
  Logging:debug(self.classname, "updateFactoryActivedModules()", event)
  local activedModulesPanel = self:getFactoryActivedModulesPanel()
  local object = self:getObject(event)
  local factory = object.factory

  if activedModulesPanel["modules"] ~= nil and activedModulesPanel["modules"].valid then
    activedModulesPanel["modules"].destroy()
  end

  -- actived modules panel
  local currentTableModulesPanel = ElementGui.addGuiTable(activedModulesPanel,"modules",4,"helmod_table_recipe_modules")
  for module, count in pairs(factory.modules) do
    for i = 1, count, 1 do
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self.classname.."=factory-module-remove=ID="..event.item1.."="..object.id.."="..module.."="..i, "item", module, module, ElementGui.getTooltipModule(module.name))
    end
  end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#RecipeEdition] updateFactorySelector
--
-- @param #LuaEvent event
--
function RecipeEdition:updateFactorySelector(event)
  Logging:debug(self.classname, "updateFactorySelector()", event)
  local selectorPanel = self:getFactorySelectorPanel()

  selectorPanel.clear()

  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-factory", helmod_scroll_style.recipe_list, true)

  local object = self:getObject(event)

  -- ajouter de la table des groupes de recipe
  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "factory-groups", 2)
  Logging:debug(self.classname, "updateFactorySelector(): group category=",object.category)

  local recipe_prototype = RecipePrototype(object)
  local category = recipe_prototype:getCategory()
  if not(User.getModGlobalSetting("model_filter_factory")) then category = nil end

  local factories = Player.getProductionsCrafting(category, object)
  Logging:debug(self.classname, "factories:",factories)


  if category == nil then
    local subgroups = {}
    for key, factory in pairs(factories) do
      local subgroup = factory.subgroup.name
      if subgroup ~= nil then
        if subgroups[subgroup] == nil then
          subgroups[subgroup] = 1
        else
          subgroups[subgroup] = subgroups[subgroup] + 1
        end
      end
    end

    for group, count in pairs(subgroups) do
      -- set le groupe
      if User.getParameter("factory_group_selected") == nil then User.setParameter("factory_group_selected",group) end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self.classname.."=factory-group=ID="..event.item1.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "factory-table", 5)
  for key, factory in pairs(factories) do
    if category ~= nil or (factory.subgroup ~= nil and factory.subgroup.name == User.getParameter("factory_group_selected")) then
      local localised_name = EntityPrototype(factory.name):getLocalisedName()
      ElementGui.addGuiButtonSelectSprite(tablePanel, self.classname.."=factory-select=ID="..event.item1.."="..object.id.."=", "entity", factory.name, factory.name, localised_name)
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
  local infoPanel = self:getBeaconInfoPanel()
  local object = self:getObject(event)

  if object ~= nil then
    local beacon = object.beacon
    local beacon_prototype = EntityPrototype(beacon)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if User.getParameter("module_panel") == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self.classname.."=change-panel=ID="..event.item1.."="..object.id.."=", beacon.type, beacon.name, beacon.name, tooltip, ElementGui.color_button_edit)
    if beacon_prototype:native() == nil then
      ElementGui.addGuiLabel(headerPanel, "label", beacon.name)
    else
      ElementGui.addGuiLabel(headerPanel, "label", beacon_prototype:getLocalisedName())
    end

    local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

    ElementGui.addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
    ElementGui.addGuiLabel(inputPanel, "module-slots", beacon_prototype:getModuleInventorySize())

    ElementGui.addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy"}))
    ElementGui.addGuiLabel(inputPanel, "energy", Format.formatNumberKilo(beacon_prototype:getEnergyUsage(), "W"))

    ElementGui.addGuiLabel(inputPanel, "label-efficiency", ({"helmod_label.efficiency"}))
    ElementGui.addGuiLabel(inputPanel, "efficiency", beacon_prototype:getDistributionEffectivity())

    ElementGui.addGuiLabel(inputPanel, "label-combo", ({"helmod_label.beacon-on-factory"}), nil, {"tooltip.beacon-on-factory"})
    ElementGui.addGuiText(inputPanel, string.format("%s=beacon-update=ID=%s=%s=%s", self.classname, event.item1, object.id, "combo"), beacon.combo, "helmod_textfield", {"tooltip.beacon-on-factory"})

    ElementGui.addGuiLabel(inputPanel, "label-factory", ({"helmod_label.factory-per-beacon"}), nil, {"tooltip.factory-per-beacon"})
    ElementGui.addGuiText(inputPanel, string.format("%s=beacon-update=ID=%s=%s=%s", self.classname, event.item1, object.id, "factory"), beacon.factory, "helmod_textfield", {"tooltip.factory-per-beacon"})
  end
end

-------------------------------------------------------------------------------
-- Update actived modules information
--
-- @function [parent=#RecipeEdition] updateBeaconActivedModules
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconActivedModules(event)
  Logging:debug(self.classname, "updateBeaconActivedModules()", event)
  local activedModulesPanel = self:getBeaconActivedModulesPanel()

  local object = self:getObject(event)
  local beacon = object.beacon

  if activedModulesPanel["modules"] ~= nil and activedModulesPanel["modules"].valid then
    activedModulesPanel["modules"].destroy()
  end

  -- actived modules panel
  local currentTableModulesPanel = ElementGui.addGuiTable(activedModulesPanel,"modules",4, "helmod_table_recipe_modules")
  for module, count in pairs(beacon.modules) do
    for i = 1, count, 1 do
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self.classname.."=beacon-module-remove=ID="..event.item1.."="..object.id.."="..module.."="..i, "item", module, module, ElementGui.getTooltipModule(module.name))
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules selector
--
-- @function [parent=#RecipeEdition] updateBeaconModulesSelector
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconModulesSelector(event)
  Logging:debug(self.classname, "updateBeaconModulesSelector()", event)
  local selectorPanel = self:getBeaconModulesSelectorPanel()
  local object = self:getObject(event)
  local model_filter_beacon_module = User.getModGlobalSetting("model_filter_beacon_module")

  selectorPanel.clear()

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    local recipe_prototype = RecipePrototype(object)
    local beacon = object.beacon
    local allowed_effects = EntityPrototype(beacon):getAllowedEffects()
    local category = recipe_prototype:getCategory()
    for k, module in pairs(Player.getModules(category)) do
      local allowed = true
      if Player.getModuleBonus(module.name, "productivity") > 0 and not(allowed_effects.productivity) and model_filter_beacon_module == true then
        allowed = false
      end
      local tooltip = ElementGui.getTooltipModule(module.name)
      if allowed == false then
        tooltip = ({"item-limitation.item-not-allowed-in-this-container-item"})
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=do-nothing=ID="..event.item1.."="..object.id.."=", "item", module.name, module.name, tooltip, "red")
      else
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=beacon-module-add=ID="..event.item1.."="..object.id.."=", "item", module.name, module.name, tooltip)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#RecipeEdition] updateBeaconSelector
--
-- @param #LuaEvent event
--
function RecipeEdition:updateBeaconSelector(event)
  Logging:debug(self.classname, "updateBeaconSelector()", event)
  local selectorPanel = self:getBeaconSelectorPanel()

  selectorPanel.clear()

  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-beacon", helmod_scroll_style.recipe_list, true)

  local object = self:getObject(event)

  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "beacon-groups", 2)

  local category = "module-beacon"
  if not(User.getModGlobalSetting("model_filter_beacon")) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = Player.getProductionsBeacon()
  Logging:debug(self.classname, "factories:",factories)


  if category == nil then
    local subgroups = {}
    for key, factory in pairs(factories) do
      local subgroup = factory.subgroup.name
      if subgroup ~= nil then
        if subgroups[subgroup] == nil then
          subgroups[subgroup] = 1
        else
          subgroups[subgroup] = subgroups[subgroup] + 1
        end
      end
    end

    for group, count in pairs(subgroups) do
      -- set le groupe
      if User.getParameter("beacon_group_selected") == nil then User.setParameter("beacon_group_selected",group) end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self.classname.."=beacon-group=ID="..event.item1.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "beacon-table", 5)
  for key, beacon in pairs(factories) do
    if category ~= nil or (beacon.subgroup ~= nil and beacon.subgroup.name == User.getParameter("beacon_group_selected")) then
      local localised_name = Player.getLocalisedName(beacon)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self.classname.."=beacon-select=ID="..event.item1.."="..object.id.."=", "item", beacon.name, beacon.name, localised_name)
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
  if  model.blocks[event.item1] ~= nil then
    local recipe = self:getObject(event)
    if recipe ~= nil then
      Logging:debug(self.classname, "updateObjectInfo():recipe=",recipe)
      info_panel.clear()

      local recipe_prototype = RecipePrototype(recipe)
      local recipe_table = ElementGui.addGuiTable(info_panel,"list-data",4)
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
      local cell_products = ElementGui.addGuiTable(recipe_table,"products_"..recipe.id, 3)
      if recipe_prototype:getProducts() ~= nil then
        for index, lua_product in pairs(recipe_prototype:getProducts()) do
          local product_prototype = Product(lua_product)
          local product = product_prototype:clone()
          product.count = product_prototype:getElementAmount()
          ElementGui.addCellProductSm(cell_products, product, self.classname.."=do_noting=ID=", false, "tooltip.product", nil, index)
        end
      end
      
      -- ingredients
      local cell_ingredients = ElementGui.addGuiTable(recipe_table,"ingredients_"..recipe.id, 3)
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
end