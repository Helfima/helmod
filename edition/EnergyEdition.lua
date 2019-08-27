require "edition.AbstractEdition"
-------------------------------------------------------------------------------
-- Class to build power edition dialog
--
-- @module EnergyEdition
-- @extends #AbstractEdition
--

EnergyEdition = class(AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#EnergyEdition] onInit
--
-- @param #Controller parent parent controller
--
function EnergyEdition:onInit(parent)
  self.panelCaption = ({"helmod_energy-edition-panel.title"})
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- Get or create panel
--
-- @function [parent=#EnergyEdition] getPowerPanel
--
function EnergyEdition:getPowerPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["power"] ~= nil and content_panel["power"].valid then
    return content_panel["power"]
  end
  local panel = ElementGui.addGuiFrameH(content_panel, "power", helmod_frame_style.panel)
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#EnergyEdition] getPrimaryPanel
--
function EnergyEdition:getPrimaryPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["Primary"] ~= nil and content_panel["Primary"].valid then
    return content_panel["Primary"]
  end
  return ElementGui.addGuiTable(content_panel, "Primary", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#EnergyEdition] getPrimaryInfoPanel
--
function EnergyEdition:getPrimaryInfoPanel()
  local panel = self:getPrimaryPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.panel, ({"helmod_common.primary-generator"}))
  ElementGui.setStyle(panel, "power", "width")
  ElementGui.setStyle(panel, "power", "height")
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#EnergyEdition] getPrimarySelectorPanel
--
function EnergyEdition:getPrimarySelectorPanel()
  local panel = self:getPrimaryPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]["scroll-primary"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "selector", helmod_frame_style.panel, ({"helmod_common.generator"}))
  panel.style.horizontally_stretchable = true
  ElementGui.setStyle(panel, "power", "width")
  ElementGui.setStyle(panel, "power", "height")
  local scroll_panel = ElementGui.addGuiScrollPane(panel, "scroll-primary", helmod_frame_style.scroll_pane, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Build primary panel
--
-- @function [parent=#EnergyEdition] buildPrimaryPanel
--
function EnergyEdition:buildPrimaryPanel()
  Logging:debug(self.classname, "buildPrimaryPanel()")
  self:getPrimaryInfoPanel()
  self:getPrimarySelectorPanel()
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#EnergyEdition] getSecondaryPanel
--
function EnergyEdition:getSecondaryPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["Secondary"] ~= nil and content_panel["Secondary"].valid then
    return content_panel["Secondary"]
  end
  return ElementGui.addGuiTable(content_panel, "Secondary", 2, helmod_table_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#EnergyEdition] getSecondaryInfoPanel
--
function EnergyEdition:getSecondaryInfoPanel()
  local panel = self:getSecondaryPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.panel, ({"helmod_common.secondary-generator"}))
  ElementGui.setStyle(panel, "power", "width")
  ElementGui.setStyle(panel, "power", "height")
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#EnergyEdition] getSecondarySelectorPanel
--
function EnergyEdition:getSecondarySelectorPanel()
  local panel = self:getSecondaryPanel()
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "selector", helmod_frame_style.panel, ({"helmod_common.generator"}))
  panel.style.horizontally_stretchable = true
  ElementGui.setStyle(panel, "power", "width")
  ElementGui.setStyle(panel, "power", "height")
  local scroll_panel = ElementGui.addGuiScrollPane(panel, "scroll-primary", helmod_frame_style.scroll_pane, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Build Secondary panel
--
-- @function [parent=#EnergyEdition] buildSecondaryPanel
--
function EnergyEdition:buildSecondaryPanel()
  Logging:debug(self.classname, "buildSecondaryPanel()")
  self:getSecondaryInfoPanel()
  self:getSecondarySelectorPanel()
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#EnergyEdition] buildHeaderPanel
--
function EnergyEdition:buildHeaderPanel()
  Logging:debug(self.classname, "buildHeaderPanel()")
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
function EnergyEdition:getObject(item, item2, item3)
  local model = Model.getModel()
  if model.powers ~= nil and model.powers[item] ~= nil then
    -- return power
    return model.powers[item]
  end
  return nil
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#EnergyEdition] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function EnergyEdition:onBeforeEvent(event, action, item, item2, item3)
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
function EnergyEdition:onClose()
  local model = Model.getModel()
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
function EnergyEdition:onEvent(event, action, item, item2, item3)
  Logging:debug(self.classname, "onEvent():", action, item, item2, item3)
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
      self:close()
      Controller.createEvent(nil, self.classname, "OPEN", item, item2, item3)
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
      self:close()
      Controller.createEvent(nil, self.classname, "OPEN", item, item2, item3)
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
function EnergyEdition:onUpdate(event, action, item, item2, item3)
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
function EnergyEdition:updatePowerInfo(item, item2, item3)
  Logging:debug(self.classname, "updatePowerInfo():", item, item2, item3)
  local power_panel = self:getPowerPanel()
  local model = Model.getModel()
  local default = Model.getDefault()

  local model = Model.getModel()
  if model.powers ~= nil and model.powers[item] ~= nil then
    local power = self:getObject(item, item2, item3)
    if power ~= nil then
      Logging:debug(self.classname, "updatePowerInfo():power=",power)
      for k,guiName in pairs(power_panel.children_names) do
        power_panel[guiName].destroy()
      end

      local tablePanel = ElementGui.addGuiTable(power_panel,"table-input",2)

      ElementGui.addGuiLabel(tablePanel, "label-power", ({"helmod_energy-edition-panel.power"}))
      ElementGui.addGuiText(tablePanel, "power", math.ceil(power.power/1000)/1000, "helmod_textfield")

      ElementGui.addGuiButton(tablePanel, self.classname.."=power-update=ID="..item.."=", power.id, "helmod_button_default", ({"helmod_button.update"}))    --
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
function EnergyEdition:updatePrimary(item, item2, item3)
  Logging:debug(self.classname, "updatePrimary():", item, item2, item3)
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
function EnergyEdition:updatePrimaryInfo(item, item2, item3)
  Logging:debug(self.classname, "updatePrimaryInfo():", item, item2, item3)
  local infoPanel = self:getPrimaryInfoPanel()
  local object = self:getObject(item, item2, item3)
  local model = Model.getModel()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self.classname, "updatePrimaryInfo():object:",object)
    local primary = object.primary
    if primary.name ~= nil then

      local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      ElementGui.addGuiButtonSprite(headerPanel, self.classname.."=do-nothing=ID=", Player.getIconType(primary), primary.name, primary.name, tooltip)
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
function EnergyEdition:updatePrimarySelector(item, item2, item3)
  Logging:debug(self.classname, "updatePrimarySelector():", item, item2, item3)
  local scroll_panel = self:getPrimarySelectorPanel()
  local model = Model.getModel()

  scroll_panel.clear()

  local object = self:getObject(item, item2, item3)

  local groupsPanel = ElementGui.addGuiTable(scroll_panel, "primary-groups", 1)

  local category = "primary"
  if not(User.getModGlobalSetting("model_filter_generator")) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = Player.getGenerators("primary")
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
      if model.primaryGroupSelected == nil then model.primaryGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self.classname.."=primary-group=ID="..item.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scroll_panel, "primary-table", 5)
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.primaryGroupSelected) then
      local localised_name = Player.getLocalisedName(element)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self.classname.."=primary-select=ID="..item.."=", "entity", element.name, element.name, localised_name)
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
function EnergyEdition:updateSecondary(item, item2, item3)
  Logging:debug(self.classname, "updateSecondary():", item, item2, item3)
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
function EnergyEdition:updateSecondaryInfo(item, item2, item3)
  Logging:debug(self.classname, "updateSecondaryInfo():", item, item2, item3)
  local infoPanel = self:getSecondaryInfoPanel()
  local object = self:getObject(item, item2, item3)
  local model = Model.getModel()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self.classname, "updateSecondaryInfo():object:",object)
    local secondary = object.secondary
    if secondary.name ~= nil then

      local headerPanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      ElementGui.addGuiButtonSprite(headerPanel, self.classname.."=do-nothing=ID=", Player.getIconType(secondary), secondary.name, secondary.name, tooltip)
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
function EnergyEdition:updateSecondarySelector(item, item2, item3)
  Logging:debug(self.classname, "updateSecondarySelector():", item, item2, item3)
  local scroll_panel = self:getSecondarySelectorPanel()
  local model = Model.getModel()

  scroll_panel.clear()
  
  local object = self:getObject(item, item2, item3)

  local groupsPanel = ElementGui.addGuiTable(scroll_panel, "secondary-groups", 1)

  local category = "secondary"
  if not(User.getModGlobalSetting("model_filter_generator")) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = Player.getGenerators("secondary")
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
      if model.secondaryGroupSelected == nil then model.secondaryGroupSelected = group end
      -- ajoute les icons de groupe
      local action = ElementGui.addGuiButton(groupsPanel, self.classname.."=secondary-group=ID="..item.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = ElementGui.addGuiTable(scroll_panel, "secondary-table", 5)
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.secondaryGroupSelected) then
      local localised_name = Player.getLocalisedName(element)
      ElementGui.addGuiButtonSelectSprite(tablePanel, self.classname.."=secondary-select=ID="..item.."=", "entity", element.name, element.name, localised_name)
    end
  end
end
