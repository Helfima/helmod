-------------------------------------------------------------------------------
-- Class to build power edition dialog
--
-- @module EnergyEdition
-- @extends #AbstractEdition
--

EnergyEdition = newclass(Form)

local input_quantity = nil
-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#EnergyEdition] onInit
--
function EnergyEdition:onInit()
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
  local panel = GuiElement.add(content_panel, GuiFrameH("power"):style(helmod_frame_style.panel))
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
  return GuiElement.add(content_panel, GuiTable("Primary"):column(2):style(helmod_table_style.panel))
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
  local panel = GuiElement.add(panel, GuiFrameV("info"):style(helmod_frame_style.panel):caption({"helmod_common.primary-generator"}))
  GuiElement.setStyle(panel, "power", "width")
  GuiElement.setStyle(panel, "power", "height")
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
  local panel = GuiElement.add(panel, GuiFrameV("selector"):style(helmod_frame_style.panel):caption({"helmod_common.generator"}))
  panel.style.horizontally_stretchable = true
  GuiElement.setStyle(panel, "power", "width")
  GuiElement.setStyle(panel, "power", "height")
  local scroll_panel = GuiElement.add(panel, GuiScroll("scroll-primary"):style(helmod_frame_style.scroll_pane))
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
  return GuiElement.add(content_panel, GuiTable("Secondary"):column(2):style(helmod_table_style.panel))
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
  local panel = GuiElement.add(panel, GuiFrameV("info"):style(helmod_frame_style.panel):caption({"helmod_common.secondary-generator"}))
  GuiElement.setStyle(panel, "power", "width")
  GuiElement.setStyle(panel, "power", "height")
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
  local panel = GuiElement.add(panel, GuiFrameV("selector"):style(helmod_frame_style.panel):caption({"helmod_common.generator"}))
  panel.style.horizontally_stretchable = true
  GuiElement.setStyle(panel, "power", "width")
  GuiElement.setStyle(panel, "power", "height")
  local scroll_panel = GuiElement.add(panel, GuiScroll("scroll-primary"):style(helmod_frame_style.scroll_pane))
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
-- @param #LuaEvent event
--
function EnergyEdition:getObject(event)
  local model = Model.getModel()
  if model.powers ~= nil and model.powers[event.item1] ~= nil then
    -- return power
    return model.powers[event.item1]
  end
  return nil
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#EnergyEdition] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function EnergyEdition:onBeforeEvent(event)
  local model = Model.getModel()
  local close = true
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) ~= event.item1 then
    close = false
  end
  User.setParameter(self.parameterLast, event.item1)
  model.primaryGroupSelected = nil
  model.secondaryGroupSelected = nil

  return false
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#EnergyEdition] onClose
--
function EnergyEdition:onClose()
  User.setParameter(self.parameterLast,nil)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#EnergyEdition] onEvent
--
-- @param #LuaEvent event
--
function EnergyEdition:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local model = Model.getModel()

  if event.action == "primary-group" then
    model.primaryGroupSelected = event.item2
    self:updatePrimarySelector(event)
  end

  if event.action == "secondary-group" then
    model.secondaryGroupSelected = event.item2
    self:updateSecondarySelector(event)
  end

  if User.isWriter() then
    if event.action == "power-update" then
      local options = {}
      local operation = input_quantity.text
      local ok , err = pcall(function()
        local quantity = formula(operation)
        if quantity == 0 then quantity = nil end
        options["power"] = quantity
        ModelBuilder.updatePower(event.item1, options)
        self:updatePowerInfo(event)
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end

    if event.action == "primary-select" then
      local object = self:getObject(event)
      if object ~= nil then
        local power = ModelBuilder.addPrimaryPower(event.item1, event.item2)
      else
        local power = ModelBuilder.addPrimaryPower(nil, event.item2)
        event.item1 = power.id
      end
      ModelCompute.computePower(event.item1)
      Controller:send("on_gui_update", event)
    end

    if event.action == "secondary-select" then
      local object = self:getObject(event)
      if object ~= nil then
        local power = ModelBuilder.addSecondaryPower(event.item1, event.item2)
      else
        local power = ModelBuilder.addSecondaryPower(nil, event.item2)
        event.item1 = power.id
      end
      ModelCompute.computePower(event.item1)
      Controller:send("on_gui_update", event)
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#EnergyEdition] onUpdate
--
-- @param #LuaEvent event
--
function EnergyEdition:onUpdate(event)
  self:updatePowerInfo(event)
  self:updatePrimary(event)
  self:updateSecondary(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updatePowerInfo
--
-- @param #LuaEvent event
--

function EnergyEdition:updatePowerInfo(event)
  Logging:debug(self.classname, "updatePowerInfo()", event)
  local power_panel = self:getPowerPanel()
  local model = Model.getModel()
  local default = Model.getDefault()

  local model = Model.getModel()
  if model.powers ~= nil and model.powers[event.item1] ~= nil then
    local power = self:getObject(event)
    if power ~= nil then
      Logging:debug(self.classname, "updatePowerInfo():power=",power)
      for k,guiName in pairs(power_panel.children_names) do
        power_panel[guiName].destroy()
      end

      local table_panel = GuiElement.add(power_panel, GuiTable("table-input"):column(2))

      GuiElement.add(table_panel, GuiLabel("label-power"):caption({"helmod_energy-edition-panel.power"}))
      local cell, button
      local power_value = math.ceil(power.power/1000)/1000
      cell, input_quantity, button = GuiCellInput(self.classname, "power-update=ID", event.item1, power.id):text(power_value or 0):create(table_panel)
      input_quantity.focus()
      input_quantity.select_all()
    end
  end
end
-------------------------------------------------------------------------------
-- Update Primary
--
-- @function [parent=#EnergyEdition] updatePrimary
--
-- @param #LuaEvent event
--
function EnergyEdition:updatePrimary(event)
  Logging:debug(self.classname, "updatePrimary()", event)
  local model = Model.getModel()

  self:updatePrimaryInfo(event)
  self:updatePrimarySelector(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updatePrimaryInfo
--
-- @param #LuaEvent event
--
function EnergyEdition:updatePrimaryInfo(event)
  Logging:debug(self.classname, "updatePrimaryInfo()", event)
  local infoPanel = self:getPrimaryInfoPanel()
  local object = self:getObject(event)
  local model = Model.getModel()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self.classname, "updatePrimaryInfo():object:",object)
    local primary = object.primary
    if primary.name ~= nil then

      local headerPanel = GuiElement.add(infoPanel, GuiTable("table-header"):column(2))
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      GuiElement.add(headerPanel, GuiButtonSprite(self.classname, "do-nothing=ID"):sprite(primary.type, primary.name):tooltip(tooltip))

      local entity_prototype = EntityPrototype(primary.name)
      if entity_prototype:native() ~= nil then
        GuiElement.add(headerPanel, GuiLabel("label"):caption(entity_prototype:getLocalisedName()))
      else
        GuiElement.add(headerPanel, GuiLabel("label"):caption(primary.name))
      end

      local inputPanel = GuiElement.add(infoPanel, GuiTable("table-input"):column(2))

      GuiElement.add(inputPanel, GuiLabel("label-energy-nominal"):caption({"helmod_label.energy-nominal"}))
      GuiElement.add(inputPanel, GuiLabel("energy-nominal"):caption(Format.formatNumberKilo(entity_prototype:getEnergyNominal(), "W")))

      if entity_prototype:getType() == "generator" then
        GuiElement.add(inputPanel, GuiLabel("label-maximum-temperature"):caption({"helmod_label.maximum-temperature"}))
        GuiElement.add(inputPanel, GuiLabel("maximum-temperature"):caption(entity_prototype:getMaximumTemperature() or "NAN"))

        GuiElement.add(inputPanel, GuiLabel("label-fluid-usage"):caption({"helmod_label.fluid-usage"}))
        GuiElement.add(inputPanel, GuiLabel("fluid-usage"):caption(entity_prototype:getFluidUsagePerTick() or "NAN"))

        GuiElement.add(inputPanel, GuiLabel("label-effectivity"):caption({"helmod_label.effectivity"}))
        GuiElement.add(inputPanel, GuiLabel("effectivity"):caption(entity_prototype:getEffectivity() or "NAN"))
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#EnergyEdition] updatePrimarySelector
--
-- @param #LuaEvent event
--
function EnergyEdition:updatePrimarySelector(event)
  Logging:debug(self.classname, "updatePrimarySelector()", event)
  local scroll_panel = self:getPrimarySelectorPanel()
  local model = Model.getModel()

  scroll_panel.clear()

  local object = self:getObject(event)

  local groupsPanel = GuiElement.add(scroll_panel, GuiTable("primary-groups"):column(1))

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
      local action = GuiElement.add(groupsPanel, GuiButton(self.classname, "primary-group=ID", event.item1, group):caption(group))
    end
  end

  local tablePanel = GuiElement.add(scroll_panel, GuiTable("primary-table"):column(5))
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.primaryGroupSelected) then
      local localised_name = Player.getLocalisedName(element)
      GuiElement.add(tablePanel, GuiButtonSelectSprite(self.classname, "primary-select=ID", event.item1):sprite("entity", element.name):tooltip(localised_name))
    end
  end
end

-------------------------------------------------------------------------------
-- Update Secondary
--
-- @function [parent=#EnergyEdition] updateSecondary
--
-- @param #LuaEvent event
--
function EnergyEdition:updateSecondary(event)
  Logging:debug(self.classname, "updateSecondary()", event)
  local model = Model.getModel()

  self:updateSecondaryInfo(event)
  self:updateSecondarySelector(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updateSecondaryInfo
--
-- @param #LuaEvent event
--
function EnergyEdition:updateSecondaryInfo(event)
  Logging:debug(self.classname, "updateSecondaryInfo()", event)
  local infoPanel = self:getSecondaryInfoPanel()
  local object = self:getObject(event)
  local model = Model.getModel()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self.classname, "updateSecondaryInfo():object:",object)
    local secondary = object.secondary
    if secondary.name ~= nil then

      local headerPanel = GuiElement.add(infoPanel, GuiTable("table-header"):column(2))
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      GuiElement.add(headerPanel, GuiButtonSelectSprite(self.classname, "do-nothing=ID"):sprite(secondary.type, secondary.name):tooltip(tooltip))

      local entity_prototype = EntityPrototype(secondary.name)
      if entity_prototype:native() ~= nil then
        GuiElement.add(headerPanel, GuiLabel("label"):caption(entity_prototype:getLocalisedName()))
      else
        GuiElement.add(headerPanel, GuiLabel("label"):caption(secondary.name))
      end

      local inputPanel = GuiElement.add(infoPanel, GuiTable("table-input"):column(2))

      if entity_prototype:getType() == EntityType.boiler then
        GuiElement.add(inputPanel, GuiLabel("label-energy-nominal"):caption({"helmod_label.energy-nominal"}))
        GuiElement.add(inputPanel, GuiLabel("energy-nominal"):caption(Format.formatNumberKilo(entity_prototype:getEnergyNominal(), "W")))

        GuiElement.add(inputPanel, GuiLabel("label-effectivity"):caption({"helmod_label.effectivity"}))
        GuiElement.add(inputPanel, GuiLabel("effectivity"):caption(entity_prototype:getEffectivity()))
      end

      if entity_prototype:getType() == EntityType.accumulator then
        GuiElement.add(inputPanel, GuiLabel("label-buffer-capacity"):caption({"helmod_label.buffer-capacity"}))
        GuiElement.add(inputPanel, GuiLabel("buffer-capacity"):caption(Format.formatNumberKilo(entity_prototype:getElectricBufferCapacity(), "J")))

        GuiElement.add(inputPanel, GuiLabel("label-input_flow_limit"):caption({"helmod_label.input-flow-limit"}))
        GuiElement.add(inputPanel, GuiLabel("input-flow-limit"):caption(Format.formatNumberKilo(entity_prototype:getElectricInputFlowLimit(), "W")))

        GuiElement.add(inputPanel, GuiLabel("label-output-flow-limit"):caption({"helmod_label.output-flow-limit"}))
        GuiElement.add(inputPanel, GuiLabel("output-flow-limit"):caption(Format.formatNumberKilo(entity_prototype:getElectricOutputFlowLimit(), "W")))
      end

    end
  end
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#EnergyEdition] updateSecondarySelector
--
-- @param #LuaEvent event
--
function EnergyEdition:updateSecondarySelector(event)
  Logging:debug(self.classname, "updateSecondarySelector()", event)
  local scroll_panel = self:getSecondarySelectorPanel()
  local model = Model.getModel()

  scroll_panel.clear()

  local object = self:getObject(event)

  local groupsPanel = GuiElement.add(scroll_panel, GuiTable("secondary-groups"):column(1))

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
      local action = GuiElement.add(groupsPanel, GuiButton(self.classname, "secondary-group=ID", event.item1, group):caption(group))
    end
  end

  local tablePanel = GuiElement.add(scroll_panel, GuiTable("secondary-table"):column(5))
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.secondaryGroupSelected) then
      local localised_name = Player.getLocalisedName(element)
      GuiElement.add(tablePanel, GuiButtonSelectSprite(self.classname, "secondary-select=ID", event.item1):sprite("entity", element.name):tooltip(localised_name))
    end
  end
end
