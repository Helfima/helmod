-------------------------------------------------------------------------------
-- Class to build abstract edition dialog
--
-- @module AbstractEdition
-- @extends #Form
--

AbstractEdition = class(Form,function(base,classname)
  Form.init(base,classname)
end)

local limit_display_height = 850

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#AbstractEdition] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function AbstractEdition:onBeforeEvent(event, action, item, item2, item3)
  local close = (action == "OPEN") -- only on open event
  User.setParameter("module_list_refresh",false)
  if item ~= nil and item2 ~= nil then
    local parameter_last = string.format("%s%s",item,item2)
    if User.getParameter(self.parameterLast) or User.getParameter(self.parameterLast) ~= parameter_last then
      close = false
      User.setParameter("factory_group_selected",nil)
      User.setParameter("beacon_group_selected",nil)
      User.setParameter("module_list_refresh",true)
    end

    User.setParameter(self.parameterLast,item)
  end
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#AbstractEdition] onClose
--
function AbstractEdition:onClose()
  User.setParameter(self.parameterLast,nil)
  User.setParameter("module_list_refresh",false)
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#AbstractEdition] getTabPanel
--
function AbstractEdition:getTabPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["menu_panel"] ~= nil and content_panel["menu_panel"].valid then
    return content_panel["menu_panel"]
  end
  return ElementGui.addGuiTable(content_panel, "menu_panel", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create left panel
--
-- @function [parent=#AbstractEdition] getLeftPanel
--
function AbstractEdition:getLeftPanel()
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
-- @function [parent=#AbstractEdition] getRightPanel
--
function AbstractEdition:getRightPanel()
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
-- @function [parent=#AbstractEdition] getTabLeftPanel
--
function AbstractEdition:getTabLeftPanel()
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
-- @function [parent=#AbstractEdition] getTabRightPanel
--
function AbstractEdition:getTabRightPanel()
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
-- Get or create factory selector panel
--
-- @function [parent=#AbstractEdition] getFactorySelectorPanel
--
function AbstractEdition:getFactorySelectorPanel()
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
-- @function [parent=#AbstractEdition] getFactoryInfoPanel
--
function AbstractEdition:getFactoryInfoPanel()
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
-- @function [parent=#AbstractEdition] getFactoryModulesSelectorPanel
--
function AbstractEdition:getFactoryModulesSelectorPanel()
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
-- @function [parent=#AbstractEdition] getFactoryActivedModulesPanel
--
function AbstractEdition:getFactoryActivedModulesPanel()
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
-- @function [parent=#AbstractEdition] getBeaconInfoPanel
--
function AbstractEdition:getBeaconInfoPanel()
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
-- @function [parent=#AbstractEdition] getBeaconSelectorPanel
--
function AbstractEdition:getBeaconSelectorPanel()
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
-- @function [parent=#AbstractEdition] getBeaconModulesSelectorPanel
--
function AbstractEdition:getBeaconModulesSelectorPanel()
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
-- @function [parent=#AbstractEdition] getBeaconActivedModulesPanel
--
function AbstractEdition:getBeaconActivedModulesPanel()
  local right_panel = self:getRightPanel()
  if right_panel["beacon_modules"] ~= nil and right_panel["beacon_modules"].valid then
    return right_panel["beacon_modules"]
  end
  local panel = ElementGui.addGuiFrameV(right_panel, "beacon_modules", helmod_frame_style.section, ({"helmod_recipe-edition-panel.current-modules"}))
  ElementGui.setStyle(panel, "recipe_edition_2", "width")
  return panel
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#AbstractEdition] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:onOpen(event, action, item, item2, item3)
  Logging:debug(self.classname, "onOpen()", action, item, item2, item3)
  local object = self:getObject(event, action, item, item2, item3)

  if User.getParameter("module_panel") == nil then
    User.setParameter("module_panel", true)
  end
  if User.getParameter("factory_tab") == nil then
    User.setParameter("factory_tab", true)
  end

  --self:updateTitle(event, action, item, item2, item3)
  self:buildHeaderPanel()
  if object ~= nil then
    -- factory
    self:buildFactoryPanel()
    -- beacon
    self:buildBeaconPanel()
  end
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#AbstractEdition] buildHeaderPanel
--
function AbstractEdition:buildHeaderPanel()
  Logging:debug(self.classname, "buildHeaderPanel()")
  -- TODO something
end

-------------------------------------------------------------------------------
-- Build factory panel
--
-- @function [parent=#AbstractEdition] buildFactoryPanel
--
function AbstractEdition:buildFactoryPanel()
  Logging:debug(self.classname, "buildFactoryPanel()")
  self:getFactoryInfoPanel()
  self:getFactoryOtherInfoPanel()
end

-------------------------------------------------------------------------------
-- Build beacon panel
--
-- @function [parent=#AbstractEdition] buildBeaconPanel
--
function AbstractEdition:buildBeaconPanel()
  Logging:debug(self.classname, "buildBeaconPanel()")
  self:getBeaconInfoPanel()
  self:getBeaconOtherInfoPanel()
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#AbstractEdition] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:onUpdate(event, action, item, item2, item3)
  Logging:debug(self.classname, "onUpdate():", action, item, item2, item3)
  local display_width, display_height = ElementGui.getDisplaySizes()
  local object = self:getObject(item, item2, item3)
  -- header
  self:updateHeader(item, item2, item3)
  if object ~= nil then
    self:getLeftPanel().clear()
    self:getRightPanel().clear()
    -- tab menu
    self:updateTabMenu(item, item2, item3)
    if display_height >= limit_display_height or User.getParameter("factory_tab") then
      -- factory
      self:updateFactory(item, item2, item3)
    end
    if display_height >= limit_display_height or not(User.getParameter("factory_tab")) then
      -- beacon
      self:updateBeacon(item, item2, item3)
    end
  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#AbstractEdition] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateHeader(item, item2, item3)
  Logging:debug(self.classname, "updateHeader():", item, item2, item3)
  -- TODO something
end

-------------------------------------------------------------------------------
-- Update tab menu
--
-- @function [parent=#AbstractEdition] updateTabMenu
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateTabMenu(item, item2, item3)
  Logging:debug(self.classname, "updateTabMenu():", item, item2, item3)
  local tab_left_panel = self:getTabLeftPanel()
  local tab_right_panel = self:getTabRightPanel()
  local object = self:getObject(item, item2, item3)

  local display_width, display_height = ElementGui.getDisplaySizes()

  tab_left_panel.clear()
  tab_right_panel.clear()

  -- left tab
  if display_height < limit_display_height then
    local style = "helmod_button_tab"
    if User.getParameter("factory_tab") == true then style = "helmod_button_tab_selected" end

    ElementGui.addGuiFrameH(tab_left_panel, self.classname.."_separator_factory",helmod_frame_style.tab).style.width = 5
    ElementGui.addGuiButton(tab_left_panel, self.classname.."=edition-change-tab=ID="..item.."="..object.id.."=", "factory", style, {"helmod_common.factory"}, {"helmod_common.factory"})

    local style = "helmod_button_tab"
    if User.getParameter("factory_tab") == false then style = "helmod_button_tab_selected" end

    ElementGui.addGuiFrameH(tab_left_panel, self.classname.."_separator_beacon",helmod_frame_style.tab).style.width = 5
    ElementGui.addGuiButton(tab_left_panel, self.classname.."=edition-change-tab=ID="..item.."="..object.id.."=", "beacon", style, {"helmod_common.beacon"}, {"helmod_common.beacon"})

    ElementGui.addGuiFrameH(tab_left_panel,"tab_final",helmod_frame_style.tab).style.width = 100
  end
  -- right tab
  local style = "helmod_button_tab"
  if User.getParameter("module_panel") == false then style = "helmod_button_tab_selected" end

  ElementGui.addGuiFrameH(tab_right_panel, self.classname.."_separator_factory",helmod_frame_style.tab).style.width = 5
  ElementGui.addGuiButton(tab_right_panel, self.classname.."=change-panel=ID="..item.."="..object.id.."=", "factory", style, {"helmod_common.factory"}, {"tooltip.selector-factory"})

  local style = "helmod_button_tab"
  if User.getParameter("module_panel") == true then style = "helmod_button_tab_selected" end

  ElementGui.addGuiFrameH(tab_right_panel, self.classname.."_separator_module",helmod_frame_style.tab).style.width = 5
  ElementGui.addGuiButton(tab_right_panel, self.classname.."=change-panel=ID="..item.."="..object.id.."=", "module", style, {"helmod_common.module"}, {"tooltip.selector-module"})

  ElementGui.addGuiFrameH(tab_right_panel,"tab_final",helmod_frame_style.tab).style.width = 100
end

-------------------------------------------------------------------------------
-- Update factory
--
-- @function [parent=#AbstractEdition] updateFactory
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateFactory(item, item2, item3)
  Logging:debug(self.classname, "updateFactory():", item, item2, item3)

  self:updateFactoryInfo(item, item2, item3)
  if User.getParameter("module_panel") == true then
    self:updateFactoryActivedModules(item, item2, item3)
    self:updateFactoryModulesSelector(item, item2, item3)
  else
    self:updateFactorySelector(item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- Update beacon
--
-- @function [parent=#AbstractEdition] updateBeacon
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateBeacon(item, item2, item3)
  Logging:debug(self.classname, "updateBeacon():", item, item2, item3)

  self:updateBeaconInfo(item, item2, item3)
  if User.getParameter("module_panel") == true then
    self:updateBeaconActivedModules(item, item2, item3)
    self:updateBeaconModulesSelector(item, item2, item3)
  else
    self:updateBeaconSelector(item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- Get element
--
-- @function [parent=#AbstractEdition] getElement
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:getObject(event, action, item, item2, item3)
  -- TODO something
  return nil
end
-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#AbstractEdition] updateFactoryInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateFactoryInfo(item, item2, item3)
  Logging:debug(self.classname, "updateFactoryInfo():", item, item2, item3)
  local infoPanel = self:getFactoryInfoPanel()
  local object = self:getObject(item, item2, item3)
  if object ~= nil then
    Logging:debug(self.classname, "updateFactoryInfo():object:",object)
    local factory = object.factory
    local factory_prototype = EntityPrototype.load(factory)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if User.getParameter("module_panel") == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self.classname.."=change-panel=ID="..item.."="..object.id.."=", Player.getIconType(factory), factory.name, factory.name, tooltip, ElementGui.color_button_edit)
    if EntityPrototype.native() == nil then
      ElementGui.addGuiLabel(headerPanel, "label", factory.name)
    else
      ElementGui.addGuiLabel(headerPanel, "label", EntityPrototype.getLocalisedName())
    end

    local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

    ElementGui.addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
    ElementGui.addGuiLabel(inputPanel, "module-slots", EntityPrototype.getModuleInventorySize())

    ElementGui.addGuiLabel(inputPanel, "label-energy", ({"helmod_label.energy"}))

    local sign = ""
    if factory.effects.consumption > 0 then sign = "+" end
    ElementGui.addGuiLabel(inputPanel, "energy", Format.formatNumberKilo(factory.energy, "W").." ("..sign..Format.formatPercent(factory.effects.consumption).."%)")
    if EntityPrototype.getEnergyType() == "burner" then

      ElementGui.addGuiLabel(inputPanel, "label-burner", ({"helmod_common.resource"}))
      local fuel_list = Player.getChemicalFuelItemPrototypes()
      local items = {}
      for _,item in pairs(fuel_list) do
        table.insert(items,"[item="..item.name.."]")
      end
      local default_fuel = "[item="..(factory.fuel or "coal").."]"
      ElementGui.addGuiDropDown(inputPanel, self.classname.."=factory-fuel-update=ID="..item.."=", object.id, items, default_fuel)
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
    ElementGui.addGuiText(inputPanel, string.format("%s=factory-update=ID=%s=%s", self.classname, item, object.id), factory.limit, "helmod_textfield", {"tooltip.factory-limit"})

  end
end

-------------------------------------------------------------------------------
-- Update module selector
--
-- @function [parent=#AbstractEdition] updateFactoryModulesSelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateFactoryModulesSelector(item, item2, item3)
  Logging:debug(self.classname, "updateFactoryModulesSelector():", item, item2, item3)
  local selectorPanel = self:getFactoryModulesSelectorPanel()
  local object = self:getObject(item, item2, item3)

  selectorPanel.clear()

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    local prototype = RecipePrototype.load(object)
    local category = prototype.getCategory()
    for k, module in pairs(Player.getModules(category)) do
      local tooltip = ElementGui.getTooltipModule(module.name)
      if Player.checkLimitationModule(module, object) == false then
        if module.limitation_message_key ~= nil then
          tooltip = {"item-limitation."..module.limitation_message_key}
        else
          tooltip = {"item-limitation.production-module-usable-only-on-intermediates"}
        end
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=do-nothing=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip, "red")
      else
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=factory-module-add=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update actived modules information
--
-- @function [parent=#AbstractEdition] updateFactoryActivedModules
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateFactoryActivedModules(item, item2, item3)
  Logging:debug(self.classname, "updateFactoryActivedModules():", item, item2, item3)
  local activedModulesPanel = self:getFactoryActivedModulesPanel()
  local object = self:getObject(item, item2, item3)
  local factory = object.factory

  if activedModulesPanel["modules"] ~= nil and activedModulesPanel["modules"].valid then
    activedModulesPanel["modules"].destroy()
  end

  -- actived modules panel
  local currentTableModulesPanel = ElementGui.addGuiTable(activedModulesPanel,"modules",4,"helmod_table_recipe_modules")
  for module, count in pairs(factory.modules) do
    for i = 1, count, 1 do
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self.classname.."=factory-module-remove=ID="..item.."="..object.id.."="..module.."="..i, "item", module, module, ElementGui.getTooltipModule(module.name))
    end
  end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#AbstractEdition] updateFactorySelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateFactorySelector(item, item2, item3)
  Logging:debug(self.classname, "updateFactorySelector():", item, item2, item3)
  local selectorPanel = self:getFactorySelectorPanel()

  selectorPanel.clear()

  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-factory", helmod_scroll_style.recipe_list, true)

  local object = self:getObject(item, item2, item3)

  -- ajouter de la table des groupes de recipe
  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "factory-groups", 2)
  Logging:debug(self.classname, "updateFactorySelector(): group category=",object.category)

  local prototype = RecipePrototype.load(object)
  local category = prototype.getCategory()
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
      local action = ElementGui.addGuiButton(groupsPanel, self.classname.."=factory-group=ID="..item.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "factory-table", 5)
  for key, factory in pairs(factories) do
    if category ~= nil or (factory.subgroup ~= nil and factory.subgroup.name == User.getParameter("factory_group_selected")) then
      local localised_name = EntityPrototype.load(factory.name).getLocalisedName()
      ElementGui.addGuiButtonSelectSprite(tablePanel, self.classname.."=factory-select=ID="..item.."="..object.id.."=", "entity", factory.name, factory.name, localised_name)
    end
  end
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#AbstractEdition] updateBeaconInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateBeaconInfo(item, item2, item3)
  Logging:debug(self.classname, "updateBeaconInfo():", item, item2, item3)
  local infoPanel = self:getBeaconInfoPanel()
  local object = self:getObject(item, item2, item3)

  if object ~= nil then
    local beacon = object.beacon
    local beacon_prototype = EntityPrototype.load(beacon)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if User.getParameter("module_panel") == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self.classname.."=change-panel=ID="..item.."="..object.id.."=", Player.getIconType(beacon), beacon.name, beacon.name, tooltip, ElementGui.color_button_edit)
    if beacon_prototype.native() == nil then
      ElementGui.addGuiLabel(headerPanel, "label", beacon.name)
    else
      ElementGui.addGuiLabel(headerPanel, "label", EntityPrototype.getLocalisedName())
    end

    local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

    ElementGui.addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
    ElementGui.addGuiLabel(inputPanel, "module-slots", EntityPrototype.getModuleInventorySize())

    ElementGui.addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy"}))
    ElementGui.addGuiLabel(inputPanel, "energy", Format.formatNumberKilo(EntityPrototype.getEnergyUsage(), "W"))

    ElementGui.addGuiLabel(inputPanel, "label-efficiency", ({"helmod_label.efficiency"}))
    ElementGui.addGuiLabel(inputPanel, "efficiency", EntityPrototype.getDistributionEffectivity())

    ElementGui.addGuiLabel(inputPanel, "label-combo", ({"helmod_label.beacon-on-factory"}), nil, {"tooltip.beacon-on-factory"})
    ElementGui.addGuiText(inputPanel, string.format("%s=beacon-update=ID=%s=%s=%s", self.classname, item, object.id, "combo"), beacon.combo, "helmod_textfield", {"tooltip.beacon-on-factory"})

    ElementGui.addGuiLabel(inputPanel, "label-factory", ({"helmod_label.factory-per-beacon"}), nil, {"tooltip.factory-per-beacon"})
    ElementGui.addGuiText(inputPanel, string.format("%s=beacon-update=ID=%s=%s=%s", self.classname, item, object.id, "factory"), beacon.factory, "helmod_textfield", {"tooltip.factory-per-beacon"})
  end
end

-------------------------------------------------------------------------------
-- Update actived modules information
--
-- @function [parent=#AbstractEdition] updateBeaconActivedModules
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateBeaconActivedModules(item, item2, item3)
  Logging:debug(self.classname, "updateBeaconActivedModules():", item, item2, item3)
  local activedModulesPanel = self:getBeaconActivedModulesPanel()

  local object = self:getObject(item, item2, item3)
  local beacon = object.beacon

  if activedModulesPanel["modules"] ~= nil and activedModulesPanel["modules"].valid then
    activedModulesPanel["modules"].destroy()
  end

  -- actived modules panel
  local currentTableModulesPanel = ElementGui.addGuiTable(activedModulesPanel,"modules",4, "helmod_table_recipe_modules")
  for module, count in pairs(beacon.modules) do
    for i = 1, count, 1 do
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self.classname.."=beacon-module-remove=ID="..item.."="..object.id.."="..module.."="..i, "item", module, module, ElementGui.getTooltipModule(module.name))
    end
  end
end

-------------------------------------------------------------------------------
-- Update modules selector
--
-- @function [parent=#AbstractEdition] updateBeaconModulesSelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateBeaconModulesSelector(item, item2, item3)
  Logging:debug(self.classname, "updateBeaconModulesSelector():", item, item2, item3)
  local selectorPanel = self:getBeaconModulesSelectorPanel()
  local object = self:getObject(item, item2, item3)
  local model_filter_beacon_module = User.getModGlobalSetting("model_filter_beacon_module")

  selectorPanel.clear()

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    local prototype = RecipePrototype.load(object)
    local beacon = object.beacon
    local allowed_effects = EntityPrototype.load(beacon).getAllowedEffects()
    local category = prototype.getCategory()
    for k, module in pairs(Player.getModules(category)) do
      local allowed = true
      if Player.getModuleBonus(module.name, "productivity") > 0 and not(allowed_effects.productivity) and model_filter_beacon_module == true then
        allowed = false
      end
      local tooltip = ElementGui.getTooltipModule(module.name)
      if allowed == false then
        tooltip = ({"item-limitation.item-not-allowed-in-this-container-item"})
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=do-nothing=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip, "red")
      else
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self.classname.."=beacon-module-add=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update factory group
--
-- @function [parent=#AbstractEdition] updateBeaconSelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:updateBeaconSelector(item, item2, item3)
  Logging:debug(self.classname, "updateBeaconSelector():", item, item2, item3)
  local selectorPanel = self:getBeaconSelectorPanel()

  selectorPanel.clear()

  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-beacon", helmod_scroll_style.recipe_list, true)

  local object = self:getObject(item, item2, item3)

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
      local action = ElementGui.addGuiButton(groupsPanel, self.classname.."=beacon-group=ID="..item.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "beacon-table", 5)
  for key, beacon in pairs(factories) do
    if category ~= nil or (beacon.subgroup ~= nil and beacon.subgroup.name == User.getParameter("beacon_group_selected")) then
      local localised_name = Player.getLocalisedName(beacon)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self.classname.."=beacon-select=ID="..item.."="..object.id.."=", "item", beacon.name, beacon.name, localised_name)
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractEdition] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition:onEvent(event, action, item, item2, item3)
  Logging:debug(self.classname, "onEvent():", action, item, item2, item3)
  local display_width, display_height = ElementGui.getDisplaySizes()
  local model = Model.getModel()

  if action == "edition-change-tab" then
    User.setParameter("factory_tab",not(User.getParameter("factory_tab")))
    self:onUpdate(event, action, item, item2, item3)
  end

  if action == "change-panel" then
    User.setParameter("module_panel",not(User.getParameter("module_panel")))
    self:onUpdate(event, action, item, item2, item3)
  end

  if action == "factory-group" then
    User.setParameter("factory_group_selected", item3)
    global_gui.factoryGroupSelected = item3
    self:updateFactorySelector(item, item2, item3)
  end

  if action == "beacon-group" then
    User.setParameter("beacon_group_selected", item3)
    self:updateBeaconSelector(item, item2, item3)
  end

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "object-update" then
      local options = {}
      local text = event.element.text
      options["production"] = (tonumber(text) or 100)/100
      ModelBuilder.updateObject(item, item2, options)
      ModelCompute.update()
      self:updateObjectInfo(item, item2, item3)
    end

    if action == "factory-select" then
      --element.state = true
      -- item=recipe item2=factory
      Model.setFactory(item, item2, item3)
      ModelCompute.update()
      self:updateHeader(item, item2, item3)
      self:updateFactoryInfo(item, item2, item3)
    end

    if action == "factory-update" then
      local inputPanel = self:getFactoryInfoPanel()["table-input"]
      local options = {}

      local text = event.element.text
      local ok , err = pcall(function()
        options["limit"] = formula(text) or 0

        ModelBuilder.updateFactory(item, item2, options)
        ModelCompute.update()
        self:updateFactoryInfo(item, item2, item3)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end

    if action == "factory-fuel-update" then

      local index = event.element.selected_index
      local fuel_list = Player.getChemicalFuelItemPrototypes()
      local items = {}
      local options = {}
      for _,item in pairs(fuel_list) do
        if index == 1 then
          options.fuel = item.name
          break end
        index = index - 1
      end
      ModelBuilder.updateFuelFactory(item, item2, options)
      ModelCompute.update()
      self:updateFactoryInfo(item, item2, item3)
    end

    if action == "factory-module-add" then
      ModelBuilder.addFactoryModule(item, item2, item3)
      ModelCompute.update()
      self:updateFactoryInfo(item, item2, item3)
      self:updateFactoryActivedModules(item, item2, item3)
    end

    if action == "factory-module-remove" then
      ModelBuilder.removeFactoryModule(item, item2, item3)
      ModelCompute.update()
      self:updateFactoryInfo(item, item2, item3)
      self:updateFactoryActivedModules(item, item2, item3)
    end

    if action == "beacon-select" then
      Model.setBeacon(item, item2, item3)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
    end

    if action == "beacon-update" then
      local options = {}
      local text = event.element.text
      -- item3 = "combo" or "factory"
      local ok , err = pcall(function()
        options[item3] = formula(text) or 0

        ModelBuilder.updateBeacon(item, item2, options)
        ModelCompute.update()
        self:updateBeaconInfo(item, item2, item3)
        if display_height >= limit_display_height or User.getParameter("factory_tab") then
          self:updateFactoryInfo(item, item2, item3)
        end
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end

    if action == "beacon-module-add" then
      ModelBuilder.addBeaconModule(item, item2, item3)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateBeaconActivedModules(item, item2, item3)
      if display_height >= limit_display_height or User.getParameter("factory_tab") then
        self:updateFactoryInfo(item, item2, item3)
      end
    end

    if action == "beacon-module-remove" then
      ModelBuilder.removeBeaconModule(item, item2, item3)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateBeaconActivedModules(item, item2, item3)
      if display_height >= limit_display_height or User.getParameter("factory_tab") then
        self:updateFactoryInfo(item, item2, item3)
      end
    end
  end
end
