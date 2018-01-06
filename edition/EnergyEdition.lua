-------------------------------------------------------------------------------
-- Class to build power edition dialog
--
-- @module EnergyEdition
-- @extends #Dialog
--

EnergyEdition = setclass("HMEnergyEdition", Dialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#EnergyEdition] onInit
--
-- @param #Controller parent parent controller
--
function EnergyEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_energy-edition-panel.title"})
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#EnergyEdition] getParentPanel
--
-- @return #LuaGuiElement
--
function EnergyEdition.methods:getParentPanel()
  return self.parent:getDialogPanel()
end

-------------------------------------------------------------------------------
-- Get or create panel
--
-- @function [parent=#EnergyEdition] getPowerPanel
--
function EnergyEdition.methods:getPowerPanel()
  local panel = self:getPanel()
  if panel["power"] ~= nil and panel["power"].valid then
    return panel["power"]
  end
  return ElementGui.addGuiFrameH(panel, "power", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#EnergyEdition] getPrimaryPanel
--
function EnergyEdition.methods:getPrimaryPanel()
  local panel = self:getPanel()
  if panel["Primary"] ~= nil and panel["Primary"].valid then
    return panel["Primary"]
  end
  return ElementGui.addGuiTable(panel, "Primary", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#EnergyEdition] getPrimaryInfoPanel
--
function EnergyEdition.methods:getPrimaryInfoPanel()
  local panel = self:getPrimaryPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.recipe_column, ({"helmod_common.primary-generator"}))
  ElementGui.setStyle(panel, "power", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#EnergyEdition] getPrimarySelectorPanel
--
function EnergyEdition.methods:getPrimarySelectorPanel()
  local panel = self:getPrimaryPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return ElementGui.addGuiFrameV(panel, "selector", helmod_frame_style.recipe_column, ({"helmod_common.generator"}))
end

-------------------------------------------------------------------------------
-- Build primary panel
--
-- @function [parent=#EnergyEdition] buildPrimaryPanel
--
function EnergyEdition.methods:buildPrimaryPanel()
  Logging:debug(self:classname(), "buildPrimaryPanel()")
  self:getPrimaryInfoPanel()
  self:getPrimarySelectorPanel()
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#EnergyEdition] getSecondaryPanel
--
function EnergyEdition.methods:getSecondaryPanel()
  local panel = self:getPanel()
  if panel["Secondary"] ~= nil and panel["Secondary"].valid then
    return panel["Secondary"]
  end
  return ElementGui.addGuiTable(panel, "Secondary", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#EnergyEdition] getSecondaryInfoPanel
--
function EnergyEdition.methods:getSecondaryInfoPanel()
  local panel = self:getSecondaryPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.recipe_column, ({"helmod_common.secondary-generator"}))
  ElementGui.setStyle(panel, "power", "height")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#EnergyEdition] getSecondarySelectorPanel
--
function EnergyEdition.methods:getSecondarySelectorPanel()
  local panel = self:getSecondaryPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return ElementGui.addGuiFrameV(panel, "selector", helmod_frame_style.recipe_column, ({"helmod_common.generator"}))
end

-------------------------------------------------------------------------------
-- Build Secondary panel
--
-- @function [parent=#EnergyEdition] buildSecondaryPanel
--
function EnergyEdition.methods:buildSecondaryPanel()
  Logging:debug(self:classname(), "buildSecondaryPanel()")
  self:getSecondaryInfoPanel()
  self:getSecondarySelectorPanel()
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#EnergyEdition] buildHeaderPanel
--
function EnergyEdition.methods:buildHeaderPanel()
  Logging:debug(self:classname(), "buildHeaderPanel()")
  self:getPowerPanel()
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#EnergyEdition] getObject
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:getObject(item, item2, item3)
  local model = Model.getModel()
  if model.powers ~= nil and model.powers[item] ~= nil then
    -- return power
    return model.powers[item]
  end
  return nil
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#EnergyEdition] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function EnergyEdition.methods:onOpen(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onOpen():", action, item, item2, item3)
  local model = Model.getModel()
  local close = true
  if model.guiPowerLast == nil or model.guiPowerLast ~= item then
    close = false
  end
  model.guiPowerLast = item
  model.primaryGroupSelected = nil
  model.secondaryGroupSelected = nil

  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#EnergyEdition] onClose
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:onClose(event, action, item, item2, item3)
  local model = Model.getModel()
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#EnergyEdition] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:afterOpen(event, action, item, item2, item3)
  Logging:debug(self:classname(), "afterOpen():", action, item, item2, item3)
  self:buildHeaderPanel()
  self:buildPrimaryPanel()
  self:buildSecondaryPanel()
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#EnergyEdition] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()

  if action == "primary-group" then
    model.primaryGroupSelected = item2
    self:updatePrimarySelector(item, item2, item3)
  end

  if action == "secondary-group" then
    model.secondaryGroupSelected = item2
    self:updateSecondarySelector(item, item2, item3)
  end

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "power-update" then
      local inputPanel = self:getPowerPanel()["table-input"]
      local options = {}

      if inputPanel["power"] ~= nil then
        options["power"] = ElementGui.getInputNumber(inputPanel["power"])
      end

      ModelBuilder.updatePower(item, options)
      self:updatePowerInfo(item, item2, item3)
      self.parent:refreshDisplayData(nil, item, item2)
    end

    if action == "primary-select" then
      local object = self:getObject(item, item2, item3)
      if object ~= nil then
        local power = ModelBuilder.addPrimaryPower(item, item2)
      else
        local power = ModelBuilder.addPrimaryPower(nil, item2)
        item = power.id
      end
      ModelCompute.computePower(item)
      self.parent:refreshDisplayData()
      Controller.sendEvent(nil, self:classname(), "CLOSE", item, item2, item3)
      Controller.sendEvent(nil, self:classname(), "OPEN", item, item2, item3)
    end

    if action == "secondary-select" then
      local object = self:getObject(item, item2, item3)
      if object ~= nil then
        local power = ModelBuilder.addSecondaryPower(item, item2)
      else
        local power = ModelBuilder.addSecondaryPower(nil, item2)
        item = power.id
      end
      ModelCompute.computePower(item)
      self.parent:refreshDisplayData()
      Controller.sendEvent(nil, self:classname(), "CLOSE", item, item2, item3)
      Controller.sendEvent(nil, self:classname(), "OPEN", item, item2, item3)
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#EnergyEdition] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:onUpdate(event, action, item, item2, item3)
  self:updatePowerInfo(item, item2, item3)
  self:updatePrimary(item, item2, item3)
  self:updateSecondary(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updatePowerInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePowerInfo(item, item2, item3)
  Logging:debug(self:classname(), "updatePowerInfo():", item, item2, item3)
  local power_panel = self:getPowerPanel()
  local model = Model.getModel()
  local default = Model.getDefault()

  local model = Model.getModel()
  if model.powers ~= nil and model.powers[item] ~= nil then
    local power = self:getObject(item, item2, item3)
    if power ~= nil then
      Logging:debug(self:classname(), "updatePowerInfo():power=",power)
      for k,guiName in pairs(power_panel.children_names) do
        power_panel[guiName].destroy()
      end

      local tablePanel = ElementGui.addGuiTable(power_panel,"table-input",2)

      ElementGui.addGuiLabel(tablePanel, "label-power", ({"helmod_energy-edition-panel.power"}))
      ElementGui.addGuiText(tablePanel, "power", math.ceil(power.power/1000)/1000, "helmod_textfield")

      ElementGui.addGuiButton(tablePanel, self:classname().."=power-update=ID="..item.."=", power.id, "helmod_button_default", ({"helmod_button.update"}))    --
    end
  end
end
-------------------------------------------------------------------------------
-- Update Primary
--
-- @function [parent=#EnergyEdition] updatePrimary
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePrimary(item, item2, item3)
  Logging:debug(self:classname(), "updatePrimary():", item, item2, item3)
  local model = Model.getModel()

  self:updatePrimaryInfo(item, item2, item3)
  self:updatePrimarySelector(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updatePrimaryInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePrimaryInfo(item, item2, item3)
  Logging:debug(self:classname(), "updatePrimaryInfo():", item, item2, item3)
  local infoPanel = self:getPrimaryInfoPanel()
  local object = self:getObject(item, item2, item3)
  local model = Model.getModel()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self:classname(), "updatePrimaryInfo():object:",object)
    local primary = object.primary
    if primary.name ~= nil then

      local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      ElementGui.addGuiButtonSprite(headerPanel, self:classname().."=do-nothing=ID=", Player.getIconType(primary), primary.name, primary.name, tooltip)
      if EntityPrototype.load(primary.name).native() ~= nil then
        ElementGui.addGuiLabel(headerPanel, "label", EntityPrototype.getLocalisedName())
      else
        ElementGui.addGuiLabel(headerPanel, "label", primary.name)
      end

      local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

      ElementGui.addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy-nominal"}))
      ElementGui.addGuiLabel(inputPanel, "energy-nominal", Format.formatNumberKilo(EntityPrototype.getEnergyNominal(), "W"))

      if EntityPrototype.getType() == "generator" then
        ElementGui.addGuiLabel(inputPanel, "label-maximum-temperature", ({"helmod_label.maximum-temperature"}))
        ElementGui.addGuiLabel(inputPanel, "maximum-temperature", EntityPrototype.getMaximumTemperature() or "NAN")

        ElementGui.addGuiLabel(inputPanel, "label-fluid-usage", ({"helmod_label.fluid-usage"}))
        ElementGui.addGuiLabel(inputPanel, "fluid-usage", EntityPrototype.getFluidUsagePerTick() or "NAN")

        ElementGui.addGuiLabel(inputPanel, "label-effectivity", ({"helmod_label.effectivity"}))
        ElementGui.addGuiLabel(inputPanel, "effectivity", EntityPrototype.getEffectivity() or "NAN")
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#EnergyEdition] updatePrimarySelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePrimarySelector(item, item2, item3)
  Logging:debug(self:classname(), "updatePrimarySelector():", item, item2, item3)
  local selectorPanel = self:getPrimarySelectorPanel()
  local model = Model.getModel()

  if selectorPanel["scroll-primary"] ~= nil and selectorPanel["scroll-primary"].valid then
    selectorPanel["scroll-primary"].destroy()
  end
  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-primary", helmod_frame_style.scroll_pane, true)

  local object = self:getObject(item, item2, item3)

  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "primary-groups", 1)

  local category = "primary"
  if not(Player.getSettings("model_filter_generator", true)) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = Player.getGenerators("primary")
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
      if model.primaryGroupSelected == nil then model.primaryGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self:classname().."=primary-group=ID="..item.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "primary-table", 5)
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.primaryGroupSelected) then
      local localised_name = Player.getLocalisedName(element)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self:classname().."=primary-select=ID="..item.."=", "item", element.name, element.name, localised_name)
    end
  end
end

-------------------------------------------------------------------------------
-- Update Secondary
--
-- @function [parent=#EnergyEdition] updateSecondary
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updateSecondary(item, item2, item3)
  Logging:debug(self:classname(), "updateSecondary():", item, item2, item3)
  local model = Model.getModel()

  self:updateSecondaryInfo(item, item2, item3)
  self:updateSecondarySelector(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updateSecondaryInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updateSecondaryInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateSecondaryInfo():", item, item2, item3)
  local infoPanel = self:getSecondaryInfoPanel()
  local object = self:getObject(item, item2, item3)
  local model = Model.getModel()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self:classname(), "updateSecondaryInfo():object:",object)
    local secondary = object.secondary
    if secondary.name ~= nil then

      local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      ElementGui.addGuiButtonSprite(headerPanel, self:classname().."=do-nothing=ID=", Player.getIconType(secondary), secondary.name, secondary.name, tooltip)
      if EntityPrototype.load(secondary.name).native() ~= nil then
        ElementGui.addGuiLabel(headerPanel, "label", EntityPrototype.getLocalisedName())
      else
        ElementGui.addGuiLabel(headerPanel, "label", secondary.name)
      end

      local inputPanel = ElementGui.addGuiTable(infoPanel,"table-input",2)

      if EntityPrototype.getType() == EntityType.boiler then
        ElementGui.addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy-nominal"}))
        ElementGui.addGuiLabel(inputPanel, "energy-nominal", Format.formatNumberKilo(EntityPrototype.getEnergyNominal(), "W"))

        ElementGui.addGuiLabel(inputPanel, "label-effectivity", ({"helmod_label.effectivity"}))
        ElementGui.addGuiLabel(inputPanel, "effectivity", EntityPrototype.getEffectivity())
      end

      if EntityPrototype.getType() == EntityType.accumulator then
        ElementGui.addGuiLabel(inputPanel, "label-buffer-capacity", ({"helmod_label.buffer-capacity"}))
        ElementGui.addGuiLabel(inputPanel, "buffer-capacity", Format.formatNumberKilo(EntityPrototype.getElectricBufferCapacity(), "J"))

        ElementGui.addGuiLabel(inputPanel, "label-input_flow_limit", ({"helmod_label.input-flow-limit"}))
        ElementGui.addGuiLabel(inputPanel, "input-flow-limit", Format.formatNumberKilo(EntityPrototype.getElectricInputFlowLimit(), "W"))

        ElementGui.addGuiLabel(inputPanel, "label-output-flow-limit", ({"helmod_label.output-flow-limit"}))
        ElementGui.addGuiLabel(inputPanel, "output-flow-limit", Format.formatNumberKilo(EntityPrototype.getElectricOutputFlowLimit(), "W"))
      end

    end
  end
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#EnergyEdition] updateSecondarySelector
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updateSecondarySelector(item, item2, item3)
  Logging:debug(self:classname(), "updateSecondarySelector():", item, item2, item3)
  local selectorPanel = self:getSecondarySelectorPanel()
  local model = Model.getModel()

  if selectorPanel["scroll-secondary"] ~= nil and selectorPanel["scroll-secondary"].valid then
    selectorPanel["scroll-secondary"].destroy()
  end
  local scrollPanel = ElementGui.addGuiScrollPane(selectorPanel, "scroll-secondary", helmod_frame_style.scroll_pane, true)

  local object = self:getObject(item, item2, item3)

  local groupsPanel = ElementGui.addGuiTable(scrollPanel, "secondary-groups", 1)

  local category = "secondary"
  if not(Player.getSettings("model_filter_generator", true)) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = Player.getGenerators("secondary")
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
      if model.secondaryGroupSelected == nil then model.secondaryGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self:classname().."=secondary-group=ID="..item.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scrollPanel, "secondary-table", 5)
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.secondaryGroupSelected) then
      local localised_name = Player.getLocalisedName(element)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self:classname().."=secondary-select=ID="..item.."=", "item", element.name, element.name, localised_name)
    end
  end
end
