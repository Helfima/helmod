-------------------------------------------------------------------------------
-- Class to build abstract edition dialog
--
-- @module AbstractEdition
-- @extends #Dialog
--

AbstractEdition = setclass("HMAbstractEdition", Dialog)

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
  local model = Model.getModel()
  local close = true
  model.moduleListRefresh = false
  if model.guiElementLast == nil or model.guiElementLast ~= item..item2 then
    close = false
    model.factoryGroupSelected = nil
    model.beaconGroupSelected = nil
    model.moduleListRefresh = true
  end
  model.guiElementLast = item..item2
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
  local model = Model.getModel()
  model.guiElementLast = nil
  model.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create factory panel
--
-- @function [parent=#AbstractEdition] getFactoryPanel
--
function AbstractEdition.methods:getFactoryPanel()
  local panel = self:getPanel()
  if panel["factory"] ~= nil and panel["factory"].valid then
    return panel["factory"]
  end
  return ElementGui.addGuiFlowH(panel, "factory", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#AbstractEdition] getFactoryOtherInfoPanel
--
function AbstractEdition.methods:getFactoryOtherInfoPanel()
  local panel = self:getFactoryPanel()
  if panel["other-info"] ~= nil and panel["other-info"].valid then
    return panel["other-info"]
  end
  return ElementGui.addGuiFlowV(panel, "other-info", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create factory selector panel
--
-- @function [parent=#AbstractEdition] getFactorySelectorPanel
--
function AbstractEdition.methods:getFactorySelectorPanel()
  local panel = self:getFactoryOtherInfoPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return ElementGui.addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.factory"}))
end

-------------------------------------------------------------------------------
-- Get or create factory info panel
--
-- @function [parent=#AbstractEdition] getFactoryInfoPanel
--
function AbstractEdition.methods:getFactoryInfoPanel()
  local panel = self:getFactoryPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return ElementGui.addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.factory"}))
end

-------------------------------------------------------------------------------
-- Get or create factory modules selector panel
--
-- @function [parent=#AbstractEdition] getFactoryModulesSelectorPanel
--
function AbstractEdition.methods:getFactoryModulesSelectorPanel()
  local modulesPanel = self:getFactoryOtherInfoPanel()
  local selectionModulesPanel = modulesPanel["selection-modules"]
  if selectionModulesPanel == nil then
    selectionModulesPanel = ElementGui.addGuiFrameV(modulesPanel, "selection-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.selection-modules"}))
  end

  local scrollModulesPanel = selectionModulesPanel["scroll-modules"]
  if scrollModulesPanel == nil then
    scrollModulesPanel = ElementGui.addGuiScrollPane(selectionModulesPanel, "scroll-modules", "helmod_scroll_recipe_module_list", "auto", "auto")
  end
  return scrollModulesPanel
end

-------------------------------------------------------------------------------
-- Get or create factory actived modules panel
--
-- @function [parent=#AbstractEdition] getFactoryActivedModulesPanel
--
function AbstractEdition.methods:getFactoryActivedModulesPanel()
  local modulesPanel = self:getFactoryOtherInfoPanel()
  if modulesPanel["current-modules"] ~= nil and modulesPanel["current-modules"].valid then
    return modulesPanel["current-modules"]
  end
  return ElementGui.addGuiFrameV(modulesPanel, "current-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.current-modules"}))
end

-------------------------------------------------------------------------------
-- Get or create beacon panel
--
-- @function [parent=#AbstractEdition] getBeaconPanel
--
function AbstractEdition.methods:getBeaconPanel()
  local panel = self:getPanel()
  if panel["beacon"] ~= nil and panel["beacon"].valid then
    return panel["beacon"]
  end
  return ElementGui.addGuiFlowH(panel, "beacon", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#AbstractEdition] getBeaconOtherInfoPanel
--
function AbstractEdition.methods:getBeaconOtherInfoPanel()
  local panel = self:getBeaconPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return ElementGui.addGuiFlowV(panel, "selector", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#AbstractEdition] getBeaconSelectorPanel
--
function AbstractEdition.methods:getBeaconSelectorPanel()
  local panel = self:getBeaconOtherInfoPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return ElementGui.addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.beacon"}))
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#AbstractEdition] getBeaconInfoPanel
--
function AbstractEdition.methods:getBeaconInfoPanel()
  local panel = self:getBeaconPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return ElementGui.addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.beacon"}))
end

-------------------------------------------------------------------------------
-- Get or create beacon modules selector panel
--
-- @function [parent=#AbstractEdition] getBeaconModulesSelectorPanel
--
function AbstractEdition.methods:getBeaconModulesSelectorPanel()
  local modulesPanel = self:getBeaconOtherInfoPanel()
  local selectionModulesPanel = modulesPanel["selection-modules"]
  if selectionModulesPanel == nil then
    selectionModulesPanel = ElementGui.addGuiFrameV(modulesPanel, "selection-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.selection-modules"}))
  end

  local scrollModulesPanel = selectionModulesPanel["scroll-modules"]
  if scrollModulesPanel == nil then
    scrollModulesPanel = ElementGui.addGuiScrollPane(selectionModulesPanel, "scroll-modules", "helmod_scroll_recipe_module_list", "auto", "auto")
  end
  return scrollModulesPanel
end

-------------------------------------------------------------------------------
-- Get or create beacon actived modules panel
--
-- @function [parent=#AbstractEdition] getBeaconActivedModulesPanel
--
function AbstractEdition.methods:getBeaconActivedModulesPanel()
  local modulesPanel = self:getBeaconOtherInfoPanel()
  if modulesPanel["current-modules"] ~= nil and modulesPanel["current-modules"].valid then
    return modulesPanel["current-modules"]
  end
  return ElementGui.addGuiFrameV(modulesPanel, "current-modules", "helmod_frame_recipe_modules", ({"helmod_recipe-edition-panel.current-modules"}))
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
  Controller.sendEvent(nil, "HMProductEdition", "CLOSE")
  Controller.sendEvent(nil, "HMRecipeSelector", "CLOSE")
  Controller.sendEvent(nil, "HMItemSelector", "CLOSE")
  Controller.sendEvent(nil, "HMEntitySelector", "CLOSE")
  Controller.sendEvent(nil, "HMFluidSelector", "CLOSE")
  Controller.sendEvent(nil, "HMTechnologySelector", "CLOSE")
  Controller.sendEvent(nil, "HMSettings", "CLOSE")
  local object = self:getObject(event, action, item, item2, item3)

  local model = Model.getModel()
  if model.module_panel == nil then
    model.module_panel = true
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
  self:getFactoryInfoPanel(player)
  self:getFactoryOtherInfoPanel(player)
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
  local object = self:getObject(item, item2, item3)
  -- header
  self:updateHeader(item, item2, item3)
  if object ~= nil then
    -- factory
    self:updateFactory(item, item2, item3)
    -- beacon
    self:updateBeacon(item, item2, item3)
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
  local model = Model.getModel()

  self:updateFactoryInfo(item, item2, item3)
  if model.module_panel == true then
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
  local model = Model.getModel()

  self:updateBeaconInfo(item, item2, item3)
  if model.module_panel == true then
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
  local model = Model.getModel()
  if object ~= nil then
    Logging:debug(self:classname(), "updateFactoryInfo():object:",object)
    local factory = object.factory
    local factory_prototype = EntityPrototype.load(factory)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self:classname().."=change-panel=ID="..item.."="..object.id.."=", Player.getIconType(factory), factory.name, factory.name, tooltip, self.color_button_edit)
    if factory_prototype.native() == nil then
      ElementGui.addGuiLabel(headerPanel, "label", factory.name)
    else
      ElementGui.addGuiLabel(headerPanel, "label", factory_prototype.native().localised_name)
    end

    local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

    ElementGui.addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
    ElementGui.addGuiLabel(inputPanel, "module-slots", factory_prototype.moduleInventorySize())

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
  local model = Model.getModel()
  local object = self:getObject(item, item2, item3)
  local model_filter_factory_module = Player.getSettings("model_filter_factory_module", true)


  if selectorPanel["modules"] ~= nil and selectorPanel["modules"].valid and model.moduleListRefresh == true then
    selectorPanel["modules"].destroy()
  end

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    local factory = object.factory
    for k, module in pairs(Player.getModules()) do
      local allowed = true
      local factory_type = Player.getEntityProperty(factory.name, "type")
      local consumption = Format.formatPercent(Player.getModuleBonus(module.name, "consumption"))
      local speed = Format.formatPercent(Player.getModuleBonus(module.name, "speed"))
      local productivity = Format.formatPercent(Player.getModuleBonus(module.name, "productivity"))
      local pollution = Format.formatPercent(Player.getModuleBonus(module.name, "pollution"))
      if productivity > 0 and factory_type ~= "mining-drill" and factory_type ~= "lab" and model_filter_factory_module == true then
        if module.limitations[object.name] == nil then allowed = false end
      end
      if factory.module_slots ==  0 then
        allowed = false
      end
      local localised_name = Player.getLocalisedName(module)
      local tooltip = ({"tooltip.module-description" , localised_name, consumption, speed, productivity, pollution})
      if allowed == false then
        tooltip = ({"item-limitation."..module.limitation_message_key})
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
    local tooltip = module
    local _module = Player.getItemPrototype(module)
    if _module ~= nil then
      local consumption = Format.formatPercent(Player.getModuleBonus(_module.name, "consumption"))
      local speed = Format.formatPercent(Player.getModuleBonus(_module.name, "speed"))
      local productivity = Format.formatPercent(Player.getModuleBonus(_module.name, "productivity"))
      local pollution = Format.formatPercent(Player.getModuleBonus(_module.name, "pollution"))
      tooltip = ({"tooltip.module-description" , _module.localised_name, consumption, speed, productivity, pollution})
    end
    for i = 1, count, 1 do
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self:classname().."=factory-module-remove=ID="..item.."="..object.id.."="..module.."="..i, "item", module, module, tooltip)
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

  if selectorPanel["scroll-factory"] ~= nil and selectorPanel["scroll-factory"].valid then
    selectorPanel["scroll-factory"].destroy()
  end
  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-factory", "helmod_scroll_recipe_factories", "auto", "auto")

  local model = Model.getModel()

  local object = self:getObject(item, item2, item3)

  -- ajouter de la table des groupes de recipe
  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "factory-groups", 2)
  Logging:debug(self:classname(), "updateFactorySelector(): group category=",object.category)

  local prototype = RecipePrototype.load(object)
  local category = prototype.getCategory()
  if not(Player.getSettings("model_filter_factory", true)) then category = nil end

  local factories = Player.getProductionsCrafting(category, object.name)
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
      if model.factoryGroupSelected == nil then model.factoryGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self:classname().."=factory-group=ID="..item.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "factory-table", 5)
  for key, factory in pairs(factories) do
    if category ~= nil or (factory.subgroup ~= nil and factory.subgroup.name == model.factoryGroupSelected) then
      local localised_name = Player.getLocalisedName(factory)
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
  local model = Model.getModel()

  if object ~= nil then
    local beacon = object.beacon
    local beacon_prototype = EntityPrototype.load(beacon)

    for k,guiName in pairs(infoPanel.children_names) do
      infoPanel[guiName].destroy()
    end

    local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
    local tooltip = ({"tooltip.selector-module"})
    if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
    ElementGui.addGuiButtonSelectSprite(headerPanel, self:classname().."=change-panel=ID="..item.."="..object.id.."=", Player.getIconType(beacon), beacon.name, beacon.name, tooltip, self.color_button_edit)
    if beacon_prototype.native() == nil then
      ElementGui.addGuiLabel(headerPanel, "label", beacon.name)
    else
      ElementGui.addGuiLabel(headerPanel, "label", beacon_prototype.native().localised_name)
    end

    local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

    ElementGui.addGuiLabel(inputPanel, "label-module-slots", ({"helmod_label.module-slots"}))
    ElementGui.addGuiLabel(inputPanel, "module-slots", beacon_prototype.moduleInventorySize())

    ElementGui.addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy"}))
    ElementGui.addGuiLabel(inputPanel, "energy", Format.formatNumberKilo(beacon_prototype.energyUsage(), "W"))

    ElementGui.addGuiLabel(inputPanel, "label-efficiency", ({"helmod_label.efficiency"}))
    ElementGui.addGuiLabel(inputPanel, "efficiency", beacon_prototype.distributionEffectivity())

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
    local tooltip = module
    local _module = Player.getItemPrototype(module)
    if _module ~= nil then
      local consumption = Format.formatPercent(Player.getModuleBonus(_module.name, "consumption"))
      local speed = Format.formatPercent(Player.getModuleBonus(_module.name, "speed"))
      local productivity = Format.formatPercent(Player.getModuleBonus(_module.name, "productivity"))
      local pollution = Format.formatPercent(Player.getModuleBonus(_module.name, "pollution"))
      tooltip = ({"tooltip.module-description" , _module.localised_name, consumption, speed, productivity, pollution})
    end

    for i = 1, count, 1 do
      ElementGui.addGuiButtonSelectSprite(currentTableModulesPanel, self:classname().."=beacon-module-remove=ID="..item.."="..object.id.."="..module.."="..i, "item", module, module, tooltip)
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
  local model = Model.getModel()
  local object = self:getObject(item, item2, item3)
  local model_filter_beacon_module = Player.getSettings("model_filter_beacon_module", true)

  if selectorPanel["modules"] ~= nil and selectorPanel["modules"].valid and model.moduleListRefresh == true then
    selectorPanel["modules"].destroy()
  end

  if selectorPanel["modules"] == nil then
    local tableModulesPanel = ElementGui.addGuiTable(selectorPanel,"modules",5)
    for k, module in pairs(Player.getModules()) do
      local allowed = true
      local consumption = Format.formatPercent(Player.getModuleBonus(module.name, "consumption"))
      local speed = Format.formatPercent(Player.getModuleBonus(module.name, "speed"))
      local productivity = Format.formatPercent(Player.getModuleBonus(module.name, "productivity"))
      local pollution = Format.formatPercent(Player.getModuleBonus(module.name, "pollution"))
      if productivity > 0 and model_filter_beacon_module == true then
        allowed = false
      end
      local localised_name = Player.getLocalisedName(module)
      local tooltip = ({"tooltip.module-description" , localised_name, consumption, speed, productivity, pollution})
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
  local model = Model.getModel()

  if selectorPanel["scroll-beacon"] ~= nil and selectorPanel["scroll-beacon"].valid then
    selectorPanel["scroll-beacon"].destroy()
  end
  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-beacon", "helmod_scroll_recipe_factories", "auto", "auto")

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
      if model.beaconGroupSelected == nil then model.beaconGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self:classname().."=beacon-group=ID="..item.."="..object.id.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "beacon-table", 5)
  --Logging:debug(self:classname(), "factories:",self.player:getProductions())
  for key, beacon in pairs(factories) do
    if category ~= nil or (beacon.subgroup ~= nil and beacon.subgroup.name == model.beaconGroupSelected) then
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
  local model = Model.getModel()

  if action == "change-panel" then
    model.module_panel = not(model.module_panel)
    self:sendEvent(event, "CLOSE", item, item2, item3)
    self:sendEvent(event, "OPEN", item, item2, item3)
  end

  if action == "factory-group" then
    model.factoryGroupSelected = item3
    self:updateFactorySelector(item, item2, item3)
  end

  if action == "beacon-group" then
    model.beaconGroupSelected = item3
    self:updateBeaconSelector(item, item2, item3)
  end

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "object-update" then
      local inputPanel = self:getObjectInfoPanel(player)["table-input"]
      local options = {}

      if inputPanel["production"] ~= nil then
        options["production"] = ElementGui.getInputNumber(inputPanel["production"])
      end

      Model.updateObject(item, item2, options)
      Model.update()
      self:updateObjectInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-select" then
      --element.state = true
      -- item=recipe item2=factory
      Model.setFactory(item, item2, item3)
      Model.update()
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-update" then
      local inputPanel = self:getFactoryInfoPanel()["table-input"]
      local options = {}

      if inputPanel["limit"] ~= nil then
        options["limit"] = ElementGui.getInputNumber(inputPanel["limit"])
      end

      Model.updateFactory(item, item2, options)
      Model.update()
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-module-add" then
      Model.addFactoryModule(item, item2, item3)
      Model.update()
      self:updateFactoryInfo(item, item2, item3)
      self:updateFactoryActivedModules(item, item2, item3)
      self:updateBeaconInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "factory-module-remove" then
      Model.removeFactoryModule(item, item2, item3)
      Model.update()
      self:updateFactoryInfo(item, item2, item3)
      self:updateFactoryActivedModules(item, item2, item3)
      self:updateBeaconInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-select" then
      Model.setBeacon(item, item2, item3)
      Model.update()
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

      Model.updateBeacon(item, item2, options)
      Model.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-module-add" then
      Model.addBeaconModule(item, item2, item3)
      Model.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateBeaconActivedModules(item, item2, item3)
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "beacon-module-remove" then
      Model.removeBeaconModule(item, item2, item3)
      Model.update()
      self:updateBeaconInfo(item, item2, item3)
      self:updateBeaconActivedModules(item, item2, item3)
      self:updateFactoryInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end
  end
end
