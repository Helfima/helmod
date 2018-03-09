-------------------------------------------------------------------------------
-- Class to build abstract edition dialog
--
-- @module AbstractEdition
-- @extends #Dialog
--

AbstractEdition = setclass("HMAbstractEdition", Dialog)

local limit_display_height = 850
-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#AbstractEdition] getParentPanel
--
-- @return #LuaGuiElement
--
function AbstractEdition.methods:getParentPanel()
  return self.parent:getDialogPanel()
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
-- @return #boolean if true the next call close dialog
--
function AbstractEdition.methods:onOpen(event, action, item, item2, item3)
  local player_gui = Player.getGlobalGui()
  local close = true
  player_gui.moduleListRefresh = false
  if player_gui.guiElementLast == nil or player_gui.guiElementLast ~= item..item2 then
    close = false
    player_gui.factoryGroupSelected = nil
    player_gui.beaconGroupSelected = nil
    player_gui.moduleListRefresh = true
  end
  player_gui.guiElementLast = item..item2
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#AbstractEdition] onClose
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition.methods:onClose(event, action, item, item2, item3)
  local player_gui = Player.getGlobalGui()
  player_gui.guiElementLast = nil
  player_gui.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#AbstractEdition] getTabPanel
--
function AbstractEdition.methods:getTabPanel()
  local panel = self:getPanel()
  if panel["menu_panel"] ~= nil and panel["menu_panel"].valid then
    return panel["menu_panel"]
  end
  return ElementGui.addGuiTable(panel, "menu_panel", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create left panel
--
-- @function [parent=#AbstractEdition] getLeftPanel
--
function AbstractEdition.methods:getLeftPanel()
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
function AbstractEdition.methods:getRightPanel()
  local panel = self:getTabPanel()
  if panel["right_panel"] ~= nil and panel["right_panel"].valid then
    return panel["right_panel"]
  end
  local right_panel = ElementGui.addGuiFrameV(panel, "right_panel", helmod_frame_style.panel)
  ElementGui.setStyle(right_panel,"recipe_edition_2","width")
  return right_panel
end

-------------------------------------------------------------------------------
-- Get or create tab left panel
--
-- @function [parent=#AbstractEdition] getTabLeftPanel
--
function AbstractEdition.methods:getTabLeftPanel()
  local left_panel = self:getLeftPanel()
  if left_panel["tab_left_panel"] ~= nil and left_panel["tab_left_panel"].valid then
    return left_panel["tab_left_panel"]["tab_panel"]
  end
  local tab_panel = ElementGui.addGuiFrameH(left_panel, "tab_left_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(tab_panel,"recipe_tab","height")
  return ElementGui.addGuiTable(tab_panel, "tab_panel", 5, helmod_table_style.tab)
end

-------------------------------------------------------------------------------
-- Get or create tab right panel
--
-- @function [parent=#AbstractEdition] getTabRightPanel
--
function AbstractEdition.methods:getTabRightPanel()
  local right_panel = self:getRightPanel()
  if right_panel["tab_right_panel"] ~= nil and right_panel["tab_right_panel"].valid then
    return right_panel["tab_right_panel"]["tab_panel"]
  end
  local tab_panel = ElementGui.addGuiFrameV(right_panel, "tab_right_panel", helmod_frame_style.hidden)
  ElementGui.setStyle(tab_panel,"recipe_tab","height")
  return ElementGui.addGuiTable(tab_panel, "tab_panel", 5, helmod_table_style.tab)
end

-------------------------------------------------------------------------------
-- Get or create factory selector panel
--
-- @function [parent=#AbstractEdition] getFactorySelectorPanel
--
function AbstractEdition.methods:getFactorySelectorPanel()
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
function AbstractEdition.methods:getFactoryInfoPanel()
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
function AbstractEdition.methods:getFactoryModulesSelectorPanel()
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
function AbstractEdition.methods:getFactoryActivedModulesPanel()
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
function AbstractEdition.methods:getBeaconInfoPanel()
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
function AbstractEdition.methods:getBeaconSelectorPanel()
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
function AbstractEdition.methods:getBeaconModulesSelectorPanel()
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
function AbstractEdition.methods:getBeaconActivedModulesPanel()
  local right_panel = self:getRightPanel()
  if right_panel["beacon_modules"] ~= nil and right_panel["beacon_modules"].valid then
    return right_panel["beacon_modules"]
  end
  local panel = ElementGui.addGuiFrameV(right_panel, "beacon_modules", helmod_frame_style.section, ({"helmod_recipe-edition-panel.current-modules"}))
  ElementGui.setStyle(panel, "recipe_edition_2", "width")
  return panel
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#AbstractEdition] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractEdition.methods:afterOpen(event, action, item, item2, item3)
  Logging:debug(self:classname(), "afterOpen():", action, item, item2, item3)
  local object = self:getObject(event, action, item, item2, item3)

  local player_gui = Player.getGlobalGui()
  if player_gui.module_panel == nil then
    player_gui.module_panel = true
  end
  if player_gui.factory_tab == nil then
    player_gui.factory_tab = true
  end

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
function AbstractEdition.methods:buildHeaderPanel()
  Logging:debug(self:classname(), "buildHeaderPanel()")
  -- TODO something
end

-------------------------------------------------------------------------------
-- Build factory panel
--
-- @function [parent=#AbstractEdition] buildFactoryPanel
--
function AbstractEdition.methods:buildFactoryPanel()
  Logging:debug(self:classname(), "buildFactoryPanel()")
  self:getFactoryInfoPanel()
  self:getFactoryOtherInfoPanel()
end

-------------------------------------------------------------------------------
-- Build beacon panel
--
-- @function [parent=#AbstractEdition] buildBeaconPanel
--
function AbstractEdition.methods:buildBeaconPanel()
  Logging:debug(self:classname(), "buildBeaconPanel()")
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
function AbstractEdition.methods:onUpdate(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onUpdate():", action, item, item2, item3)
  local global_gui = Player.getGlobalGui()
  local display_width, display_height = ElementGui.getDisplaySizes()
  local object = self:getObject(item, item2, item3)
  -- header
  self:updateHeader(item, item2, item3)
  if object ~= nil then
    -- tab menu
    self:updateTabMenu(item, item2, item3)
    if display_height >= limit_display_height or global_gui.factory_tab then
      -- factory
      self:updateFactory(item, item2, item3)
    end
    if display_height >= limit_display_height or not(global_gui.factory_tab) then
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
function AbstractEdition.methods:updateHeader(item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
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
function AbstractEdition.methods:updateTabMenu(item, item2, item3)
  Logging:debug(self:classname(), "updateTabMenu():", item, item2, item3)
  local global_gui = Player.getGlobalGui()
  local tab_left_panel = self:getTabLeftPanel()
  local tab_right_panel = self:getTabRightPanel()
  local object = self:getObject(item, item2, item3)

  local display_width, display_height = ElementGui.getDisplaySizes()

  tab_left_panel.clear()
  tab_right_panel.clear()

  -- left tab
  if display_height < limit_display_height then
    local style = "helmod_button_tab"
    if global_gui.factory_tab == true then style = "helmod_button_tab_selected" end

    ElementGui.addGuiFrameH(tab_left_panel, self:classname().."_separator_factory",helmod_frame_style.tab).style.width = 5
    ElementGui.addGuiButton(tab_left_panel, self:classname().."=change-tab=ID="..item.."="..object.id.."=", "factory", style, {"helmod_common.factory"}, {"helmod_common.factory"})

    local style = "helmod_button_tab"
    if global_gui.factory_tab == false then style = "helmod_button_tab_selected" end

    ElementGui.addGuiFrameH(tab_left_panel, self:classname().."_separator_beacon",helmod_frame_style.tab).style.width = 5
    ElementGui.addGuiButton(tab_left_panel, self:classname().."=change-tab=ID="..item.."="..object.id.."=", "beacon", style, {"helmod_common.beacon"}, {"helmod_common.beacon"})

    ElementGui.addGuiFrameH(tab_left_panel,"tab_final",helmod_frame_style.tab).style.width = 100
  end
  -- right tab
  local style = "helmod_button_tab"
  if global_gui.module_panel == false then style = "helmod_button_tab_selected" end

  ElementGui.addGuiFrameH(tab_right_panel, self:classname().."_separator_factory",helmod_frame_style.tab).style.width = 5
  ElementGui.addGuiButton(tab_right_panel, self:classname().."=change-panel=ID="..item.."="..object.id.."=", "factory", style, {"helmod_common.factory"}, {"tooltip.selector-factory"})

  local style = "helmod_button_tab"
  if global_gui.module_panel == true then style = "helmod_button_tab_selected" end

  ElementGui.addGuiFrameH(tab_right_panel, self:classname().."_separator_module",helmod_frame_style.tab).style.width = 5
  ElementGui.addGuiButton(tab_right_panel, self:classname().."=change-panel=ID="..item.."="..object.id.."=", "module", style, {"helmod_common.module"}, {"tooltip.selector-module"})

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
function AbstractEdition.methods:updateFactory(item, item2, item3)
  Logging:debug(self:classname(), "updateFactory():", item, item2, item3)
  local global_gui = Player.getGlobalGui()

  self:updateFactoryInfo(item, item2, item3)
  if global_gui.module_panel == true then
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
function AbstractEdition.methods:updateBeacon(item, item2, item3)
  Logging:debug(self:classname(), "updateBeacon():", item, item2, item3)
  local global_gui = Player.getGlobalGui()

  self:updateBeaconInfo(item, item2, item3)
  if global_gui.module_panel == true then
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
function AbstractEdition.methods:getObject(event, action, item, item2, item3)
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
function AbstractEdition.methods:updateFactoryInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateFactoryInfo():", item, item2, item3)
  local infoPanel = self:getFactoryInfoPanel()
  local object = self:getObject(item, item2, item3)
  local global_gui = Player.getGlobalGui()
  if object ~= nil then
    Logging:debug(self:classname(), "updateFactoryInfo():object:",object)
    local factory = object.factory
    local factory_prototype = EntityPrototype.load(factory)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if global_gui.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self:classname().."=change-panel=ID="..item.."="..object.id.."=", Player.getIconType(factory), factory.name, factory.name, tooltip, self.color_button_edit)
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

    local sign = ""
    if factory.effects.speed > 0 then sign = "+" end
    ElementGui.addGuiLabel(inputPanel, "label-speed", ({"helmod_label.speed"}))
    ElementGui.addGuiLabel(inputPanel, "speed", Format.formatNumber(factory.speed).." ("..sign..Format.formatPercent(factory.effects.speed).."%)")

    local sign = ""
    if factory.effects.productivity > 0 then sign = "+" end
    ElementGui.addGuiLabel(inputPanel, "label-productivity", ({"helmod_label.productivity"}))
    ElementGui.addGuiLabel(inputPanel, "productivity", sign..Format.formatPercent(factory.effects.productivity).."%")

    ElementGui.addGuiLabel(inputPanel, "label-limit", ({"helmod_label.limit"}), nil, {"tooltip.factory-limit"})
    ElementGui.addGuiText(inputPanel, "limit", factory.limit, "helmod_textfield", {"tooltip.factory-limit"})

    ElementGui.addGuiButton(infoPanel, self:classname().."=factory-update=ID="..item.."=", object.id, "helmod_button_default", ({"helmod_button.update"}))
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
function AbstractEdition.methods:updateFactoryModulesSelector(item, item2, item3)
  Logging:debug(self:classname(), "updateFactoryModulesSelector():", item, item2, item3)
  local selectorPanel = self:getFactoryModulesSelectorPanel()
  local player_gui = Player.getGlobalGui()
  local object = self:getObject(item, item2, item3)


  if selectorPanel["modules"] ~= nil and selectorPanel["modules"].valid and player_gui.moduleListRefresh == true then
    selectorPanel["modules"].destroy()
  end

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
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self:classname().."=do-nothing=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip, "red")
      else
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self:classname().."=factory-module-add=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip)
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
function AbstractEdition.methods:updateFactoryActivedModules(item, item2, item3)
  Logging:debug(self:classname(), "updateFactoryActivedModules():", item, item2, item3)
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
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self:classname().."=factory-module-remove=ID="..item.."="..object.id.."="..module.."="..i, "item", module, module, ElementGui.getTooltipModule(module.name))
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
function AbstractEdition.methods:updateFactorySelector(item, item2, item3)
  Logging:debug(self:classname(), "updateFactorySelector():", item, item2, item3)
  local selectorPanel = self:getFactorySelectorPanel()
  local global_gui = Player.getGlobalGui()

  if selectorPanel["scroll-factory"] ~= nil and selectorPanel["scroll-factory"].valid then
    selectorPanel["scroll-factory"].destroy()
  end
  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-factory", helmod_scroll_style.recipe_list, true)

  local object = self:getObject(item, item2, item3)

  -- ajouter de la table des groupes de recipe
  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "factory-groups", 2)
  Logging:debug(self:classname(), "updateFactorySelector(): group category=",object.category)

  local prototype = RecipePrototype.load(object)
  local category = prototype.getCategory()
  if not(Player.getSettings("model_filter_factory", true)) then category = nil end

  local factories = Player.getProductionsCrafting(category, object)
  Logging:debug(self:classname(), "factories:",factories)


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
      if global_gui.factoryGroupSelected == nil then global_gui.factoryGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self:classname().."=factory-group=ID="..item.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "factory-table", 5)
  for key, factory in pairs(factories) do
    if category ~= nil or (factory.subgroup ~= nil and factory.subgroup.name == global_gui.factoryGroupSelected) then
      local localised_name = EntityPrototype.load(factory.name).getLocalisedName()
      ElementGui.addGuiButtonSelectSprite(tablePanel, self:classname().."=factory-select=ID="..item.."="..object.id.."=", "item", factory.name, factory.name, localised_name)
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
function AbstractEdition.methods:updateBeaconInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateBeaconInfo():", item, item2, item3)
  local infoPanel = self:getBeaconInfoPanel()
  local object = self:getObject(item, item2, item3)
  local global_gui = Player.getGlobalGui()

  if object ~= nil then
    local beacon = object.beacon
    local beacon_prototype = EntityPrototype.load(beacon)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if global_gui.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self:classname().."=change-panel=ID="..item.."="..object.id.."=", Player.getIconType(beacon), beacon.name, beacon.name, tooltip, self.color_button_edit)
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
    ElementGui.addGuiText(inputPanel, "combo", beacon.combo, "helmod_textfield", {"tooltip.beacon-on-factory"})

    ElementGui.addGuiLabel(inputPanel, "label-factory", ({"helmod_label.factory-per-beacon"}), nil, {"tooltip.factory-per-beacon"})
    ElementGui.addGuiText(inputPanel, "factory", beacon.factory, "helmod_textfield", {"tooltip.factory-per-beacon"})

    ElementGui.addGuiButton(infoPanel, self:classname().."=beacon-update=ID="..item.."=", object.id, "helmod_button_default", ({"helmod_button.update"}))
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
function AbstractEdition.methods:updateBeaconActivedModules(item, item2, item3)
  Logging:debug(self:classname(), "updateBeaconActivedModules():", item, item2, item3)
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
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self:classname().."=beacon-module-remove=ID="..item.."="..object.id.."="..module.."="..i, "item", module, module, ElementGui.getTooltipModule(module.name))
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
function AbstractEdition.methods:updateBeaconModulesSelector(item, item2, item3)
  Logging:debug(self:classname(), "updateBeaconModulesSelector():", item, item2, item3)
  local selectorPanel = self:getBeaconModulesSelectorPanel()
  local player_gui = Player.getGlobalGui()
  local object = self:getObject(item, item2, item3)
  local model_filter_beacon_module = Player.getSettings("model_filter_beacon_module", true)

  if selectorPanel["modules"] ~= nil and selectorPanel["modules"].valid and player_gui.moduleListRefresh == true then
    selectorPanel["modules"].destroy()
  end

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    local prototype = RecipePrototype.load(object)
    local category = prototype.getCategory()
    for k, module in pairs(Player.getModules(category)) do
      local allowed = true
      if Player.getModuleBonus(module.name, "productivity") > 0 and model_filter_beacon_module == true then
        allowed = false
      end
      local tooltip = ElementGui.getTooltipModule(module.name)
      if allowed == false then
        tooltip = ({"item-limitation.item-not-allowed-in-this-container-item"})
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self:classname().."=do-nothing=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip, "red")
      else
        ElementGui.addGuiButtonSelectSprite(tableModulesPanel, self:classname().."=beacon-module-add=ID="..item.."="..object.id.."=", "item", module.name, module.name, tooltip)
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
function AbstractEdition.methods:updateBeaconSelector(item, item2, item3)
  Logging:debug(self:classname(), "updateBeaconSelector():", item, item2, item3)
  local selectorPanel = self:getBeaconSelectorPanel()
  local global_gui = Player.getGlobalGui()

  if selectorPanel["scroll-beacon"] ~= nil and selectorPanel["scroll-beacon"].valid then
    selectorPanel["scroll-beacon"].destroy()
  end
  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-beacon", helmod_scroll_style.recipe_list, true)

  local object = self:getObject(item, item2, item3)

  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "beacon-groups", 2)

  local category = "module-beacon"
  if not(Player.getSettings("model_filter_beacon", true)) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = Player.getProductionsBeacon()
  Logging:debug(self:classname(), "factories:",factories)


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
      if global_gui.beaconGroupSelected == nil then global_gui.beaconGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self:classname().."=beacon-group=ID="..item.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "beacon-table", 5)
  for key, beacon in pairs(factories) do
    if category ~= nil or (beacon.subgroup ~= nil and beacon.subgroup.name == global_gui.beaconGroupSelected) then
      local localised_name = Player.getLocalisedName(beacon)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self:classname().."=beacon-select=ID="..item.."="..object.id.."=", "item", beacon.name, beacon.name, localised_name)
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
function AbstractEdition.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local display_width, display_height = ElementGui.getDisplaySizes()
  local model = Model.getModel()
  local global_gui = Player.getGlobalGui()

  if action == "change-tab" then
    global_gui.factory_tab = not(global_gui.factory_tab)
    self:sendEvent(event, "CLOSE", item, item2, item3)
    self:sendEvent(event, "OPEN", item, item2, item3)
  end

  if action == "change-panel" then
    global_gui.module_panel = not(global_gui.module_panel)
    self:sendEvent(event, "CLOSE", item, item2, item3)
    self:sendEvent(event, "OPEN", item, item2, item3)
  end

  if action == "factory-group" then
    global_gui.factoryGroupSelected = item3
    self:updateFactorySelector(item, item2, item3)
  end

  if action == "beacon-group" then
    global_gui.beaconGroupSelected = item3
    self:updateBeaconSelector(item, item2, item3)
  end

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "object-update" then
      local inputPanel = self:getObjectInfoPanel(player)["table-input"]
      local options = {}

      if inputPanel["production"] ~= nil then
        options["production"] = (ElementGui.getInputNumber(inputPanel["production"]) or 100)/100
      end

      ModelBuilder.updateObject(item, item2, options)
      ModelCompute.update()
      self:updateObjectInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-select" then
      --element.state = true
      -- item=recipe item2=factory
      Model.setFactory(item, item2, item3)
      ModelCompute.update()
      self:updateHeader(item, item2, item3)
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-update" then
      local inputPanel = self:getFactoryInfoPanel()["table-input"]
      local options = {}

      if inputPanel["limit"] ~= nil then
        options["limit"] = ElementGui.getInputNumber(inputPanel["limit"])
      end

      ModelBuilder.updateFactory(item, item2, options)
      ModelCompute.update()
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-module-add" then
      ModelBuilder.addFactoryModule(item, item2, item3)
      ModelCompute.update()
      self:updateFactoryInfo(item, item2, item3)
      self:updateFactoryActivedModules(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-module-remove" then
      ModelBuilder.removeFactoryModule(item, item2, item3)
      ModelCompute.update()
      self:updateFactoryInfo(item, item2, item3)
      self:updateFactoryActivedModules(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-select" then
      Model.setBeacon(item, item2, item3)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-update" then
      local inputPanel = self:getBeaconInfoPanel()["table-input"]
      local options = {}

      if inputPanel["combo"] ~= nil then
        options["combo"] = ElementGui.getInputNumber(inputPanel["combo"])
      end

      if inputPanel["factory"] ~= nil then
        options["factory"] = ElementGui.getInputNumber(inputPanel["factory"])
      end

      ModelBuilder.updateBeacon(item, item2, options)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
      if display_height >= limit_display_height or global_gui.factory_tab then
        self:updateFactoryInfo(item, item2, item3)
      end
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-module-add" then
      ModelBuilder.addBeaconModule(item, item2, item3)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateBeaconActivedModules(item, item2, item3)
      if display_height >= limit_display_height or global_gui.factory_tab then
        self:updateFactoryInfo(item, item2, item3)
      end
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-module-remove" then
      ModelBuilder.removeBeaconModule(item, item2, item3)
      ModelCompute.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateBeaconActivedModules(item, item2, item3)
      if display_height >= limit_display_height or global_gui.factory_tab then
        self:updateFactoryInfo(item, item2, item3)
      end
      self.parent:refreshDisplayData(nil, item, item2)
    end
  end
end
