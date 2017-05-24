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
-- @function [parent=#EnergyEdition] on_init
--
-- @param #Controller parent parent controller
--
function EnergyEdition.methods:on_init(parent)
  self.panelCaption = ({"helmod_energy-edition-panel.title"})
  self.player = self.parent.player
  self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#EnergyEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function EnergyEdition.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create panel
--
-- @function [parent=#EnergyEdition] getPowerPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getPowerPanel(player)
  local panel = self:getPanel(player)
  if panel["power"] ~= nil and panel["power"].valid then
    return panel["power"]
  end
  return self:addGuiFrameV(panel, "power", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#EnergyEdition] getPrimaryPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getPrimaryPanel(player)
  local panel = self:getPanel(player)
  if panel["Primary"] ~= nil and panel["Primary"].valid then
    return panel["Primary"]
  end
  return self:addGuiFlowH(panel, "Primary", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#EnergyEdition] getPrimaryInfoPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getPrimaryInfoPanel(player)
  local panel = self:getPrimaryPanel(player)
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return self:addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.primary-generator"}))
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#EnergyEdition] getPrimarySelectorPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getPrimarySelectorPanel(player)
  local panel = self:getPrimaryPanel(player)
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return self:addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.generator"}))
end

-------------------------------------------------------------------------------
-- Build primary panel
--
-- @function [parent=#EnergyEdition] buildPrimaryPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:buildPrimaryPanel(player)
  Logging:debug(self:classname(), "buildPrimaryPanel():",player)
  self:getPrimaryInfoPanel(player)
  self:getPrimarySelectorPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create generator panel
--
-- @function [parent=#EnergyEdition] getSecondaryPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getSecondaryPanel(player)
  local panel = self:getPanel(player)
  if panel["Secondary"] ~= nil and panel["Secondary"].valid then
    return panel["Secondary"]
  end
  return self:addGuiFlowH(panel, "Secondary", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#EnergyEdition] getSecondaryInfoPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getSecondaryInfoPanel(player)
  local panel = self:getSecondaryPanel(player)
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return self:addGuiFrameV(panel, "info", "helmod_frame_recipe_factory", ({"helmod_common.secondary-generator"}))
end

-------------------------------------------------------------------------------
-- Get or create selector panel
--
-- @function [parent=#EnergyEdition] getSecondarySelectorPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:getSecondarySelectorPanel(player)
  local panel = self:getSecondaryPanel(player)
  if panel["selector"] ~= nil and panel["selector"].valid then
    return panel["selector"]
  end
  return self:addGuiFrameV(panel, "selector", "helmod_frame_recipe_factory", ({"helmod_common.generator"}))
end

-------------------------------------------------------------------------------
-- Build Secondary panel
--
-- @function [parent=#EnergyEdition] buildSecondaryPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:buildSecondaryPanel(player)
  Logging:debug(self:classname(), "buildSecondaryPanel():",player)
  self:getSecondaryInfoPanel(player)
  self:getSecondarySelectorPanel(player)
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#EnergyEdition] buildHeaderPanel
--
-- @param #LuaPlayer player
--
function EnergyEdition.methods:buildHeaderPanel(player)
  Logging:debug(self:classname(), "buildHeaderPanel():",player)
  self:getPowerPanel(player)
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#EnergyEdition] getObject
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:getObject(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
  if model.powers ~= nil and model.powers[item] ~= nil then
    -- return power
    return model.powers[item]
  end
  return nil
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#EnergyEdition] on_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function EnergyEdition.methods:on_open(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_open():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
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
-- @function [parent=#EnergyEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:on_close(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#EnergyEdition] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:after_open(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "after_open():",player, element, action, item, item2, item3)
  self.parent:send_event(player, "HMProductEdition", "CLOSE")
  self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
  self.parent:send_event(player, "HMSettings", "CLOSE")

  self:buildHeaderPanel(player)
  self:buildPrimaryPanel(player)
  self:buildSecondaryPanel(player)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#EnergyEdition] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  if action == "primary-group" then
    model.primaryGroupSelected = item2
    self:updatePrimarySelector(player, element, action, item, item2, item3)
  end

  if action == "secondary-group" then
    model.secondaryGroupSelected = item2
    self:updateSecondarySelector(player, element, action, item, item2, item3)
  end

  if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "power-update" then
      local inputPanel = self:getPowerPanel(player)["table-input"]
      local options = {}

      if inputPanel["power"] ~= nil then
        options["power"] = self:getInputNumber(inputPanel["power"])
      end

      self.model:updatePower(player, item, options)
      self:updatePowerInfo(player, element, action, item, item2, item3)
      self.parent:refreshDisplayData(player, nil, item, item2)
    end

    if action == "primary-select" then
      local object = self:getObject(player, element, action, item, item2, item3)
      if object ~= nil then
        local power = self.model:addPrimaryPower(player, item, item2)
      else
        local power = self.model:addPrimaryPower(player, nil, item2)
        item = power.id
      end
      self.model:computePower(player, item)
      self.parent:refreshDisplayData(player)
      self:send_event(player, element, "CLOSE", item, item2, item3)
      self:send_event(player, element, "OPEN", item, item2, item3)
    end

    if action == "secondary-select" then
      local object = self:getObject(player, element, action, item, item2, item3)
      if object ~= nil then
        local power = self.model:addSecondaryPower(player, item, item2)
      else
        local power = self.model:addSecondaryPower(player, nil, item2)
        item = power.id
      end
      self.model:computePower(player, item)
      self.parent:refreshDisplayData(player)
      self:send_event(player, element, "CLOSE", item, item2, item3)
      self:send_event(player, element, "OPEN", item, item2, item3)
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#EnergyEdition] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:on_update(player, element, action, item, item2, item3)
  self:updatePowerInfo(player, element, action, item, item2, item3)
  self:updatePrimary(player, element, action, item, item2, item3)
  self:updateSecondary(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updatePowerInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePowerInfo(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updatePowerInfo():",player, element, action, item, item2, item3)
  local infoPanel = self:getPowerPanel(player)
  local model = self.model:getModel(player)
  local default = self.model:getDefault(player)

  local model = self.model:getModel(player)
  if model.powers ~= nil and model.powers[item] ~= nil then
    local power = self:getObject(player, element, action, item, item2, item3)
    if power ~= nil then
      Logging:debug(self:classname(), "updatePowerInfo():power=",power)
      for k,guiName in pairs(infoPanel.children_names) do
        infoPanel[guiName].destroy()
      end

      local tablePanel = self:addGuiTable(infoPanel,"table-input",2)

      self:addGuiLabel(tablePanel, "label-power", ({"helmod_energy-edition-panel.power"}))
      self:addGuiText(tablePanel, "power", math.ceil(power.power/1000)/1000, "helmod_textfield")

      self:addGuiButton(tablePanel, self:classname().."=power-update=ID="..item.."=", power.id, "helmod_button_default", ({"helmod_button.update"}))    --
    end
  end
end
-------------------------------------------------------------------------------
-- Update Primary
--
-- @function [parent=#EnergyEdition] updatePrimary
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePrimary(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updatePrimary():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  self:updatePrimaryInfo(player, element, action, item, item2, item3)
  self:updatePrimarySelector(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updatePrimaryInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePrimaryInfo(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updatePrimaryInfo():",player, element, action, item, item2, item3)
  local infoPanel = self:getPrimaryInfoPanel(player)
  local object = self:getObject(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self:classname(), "updatePrimaryInfo():object:",object)
    local primary = object.primary
    if primary.name ~= nil then
      local _generator = self.player:getItemPrototype(primary.name)

      local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      self:addGuiButtonSprite(headerPanel, self:classname().."=do-nothing=ID=", self.player:getIconType(primary), primary.name, primary.name, tooltip)
      if _generator == nil then
        self:addGuiLabel(headerPanel, "label", primary.name)
      else
        self:addGuiLabel(headerPanel, "label", _generator.localised_name)
      end

      local primary_classification = self.player:getItemProperty(primary.name, "classification")

      local inputPanel = self:addGuiTable(infoPanel,"table-input",2)

      self:addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy-nominal"}))
      self:addGuiLabel(inputPanel, "energy-nominal", self:formatNumberKilo(primary.energy_nominal, "W"))

      if primary_classification == "generator" then
        self:addGuiLabel(inputPanel, "label-maximum-temperature", ({"helmod_label.maximum-temperature"}))
        self:addGuiLabel(inputPanel, "maximum-temperature", primary.maximum_temperature or "NAN")

        self:addGuiLabel(inputPanel, "label-fluid-usage", ({"helmod_label.fluid-usage"}))
        self:addGuiLabel(inputPanel, "fluid-usage", primary.fluid_usage or "NAN")

        self:addGuiLabel(inputPanel, "label-effectivity", ({"helmod_label.effectivity"}))
        self:addGuiLabel(inputPanel, "effectivity", primary.effectivity or "NAN")
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#EnergyEdition] updatePrimarySelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updatePrimarySelector(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updatePrimarySelector():",player, element, action, item, item2, item3)
  local selectorPanel = self:getPrimarySelectorPanel(player)
  local model = self.model:getModel(player)

  if selectorPanel["scroll-primary"] ~= nil and selectorPanel["scroll-primary"].valid then
    selectorPanel["scroll-primary"].destroy()
  end
  local scrollPanel = self:addGuiScrollPane(selectorPanel, "scroll-primary", "helmod_scroll_recipe_factories", "auto", "auto")

  local object = self:getObject(player, element, action, item, item2, item3)

  local groupsPanel = self:addGuiTable(scrollPanel, "primary-groups", 1)

  local category = "primary"
  if not(self.player:getSettings(player, "model_filter_generator", true)) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = self.player:getGenerators("primary")
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
      local action = self:addGuiButton(groupsPanel, self:classname().."=primary-group=ID="..item.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = self:addGuiTable(scrollPanel, "primary-table", 5)
  --Logging:debug(self:classname(), "factories:",self.player:getProductions())
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.primaryGroupSelected) then
      local localised_name = self.player:getLocalisedName(player, element)
      self:addGuiButtonSelectSprite(tablePanel, self:classname().."=primary-select=ID="..item.."=", "item", element.name, element.name, localised_name)
    end
  end
end

-------------------------------------------------------------------------------
-- Update Secondary
--
-- @function [parent=#EnergyEdition] updateSecondary
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updateSecondary(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updateSecondary():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  self:updateSecondaryInfo(player, element, action, item, item2, item3)
  self:updateSecondarySelector(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#EnergyEdition] updateSecondaryInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updateSecondaryInfo(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updateSecondaryInfo():",player, element, action, item, item2, item3)
  local infoPanel = self:getSecondaryInfoPanel(player)
  local object = self:getObject(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  if object ~= nil then
    Logging:debug(self:classname(), "updateSecondaryInfo():object:",object)
    local secondary = object.secondary
    if secondary.name ~= nil then
      local _generator = self.player:getItemPrototype(secondary.name)

      local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
      local tooltip = ({"tooltip.selector-module"})
      if model.module_panel == true then tooltip = ({"tooltip.selector-factory"}) end
      self:addGuiButtonSprite(headerPanel, self:classname().."=do-nothing=ID=", self.player:getIconType(secondary), secondary.name, secondary.name, tooltip)
      if _generator == nil then
        self:addGuiLabel(headerPanel, "label", secondary.name)
      else
        self:addGuiLabel(headerPanel, "label", _generator.localised_name)
      end

      local inputPanel = self:addGuiTable(infoPanel,"table-input",2)

      local secondary_classification = self.player:getItemProperty(secondary.name, "classification")

      if secondary_classification == "boiler" then
        self:addGuiLabel(inputPanel, "label-energy-nominal", ({"helmod_label.energy-nominal"}))
        self:addGuiLabel(inputPanel, "energy-nominal", self:formatNumberKilo(secondary.energy_nominal, "W"))

        self:addGuiLabel(inputPanel, "label-effectivity", ({"helmod_label.effectivity"}))
        self:addGuiLabel(inputPanel, "effectivity", secondary.effectivity)
      end

      if secondary_classification == "accumulator" then
        self:addGuiLabel(inputPanel, "label-buffer-capacity", ({"helmod_label.buffer-capacity"}))
        self:addGuiLabel(inputPanel, "buffer-capacity", self:formatNumberKilo(secondary.buffer_capacity, "J"))

        self:addGuiLabel(inputPanel, "label-input_flow_limit", ({"helmod_label.input-flow-limit"}))
        self:addGuiLabel(inputPanel, "input-flow-limit", self:formatNumberKilo(secondary.input_flow_limit, "W"))

        self:addGuiLabel(inputPanel, "label-output-flow-limit", ({"helmod_label.output-flow-limit"}))
        self:addGuiLabel(inputPanel, "output-flow-limit", self:formatNumberKilo(secondary.output_flow_limit, "W"))
      end

    end
  end
end

-------------------------------------------------------------------------------
-- Update selector
--
-- @function [parent=#EnergyEdition] updateSecondarySelector
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function EnergyEdition.methods:updateSecondarySelector(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updateSecondarySelector():",player, element, action, item, item2, item3)
  local selectorPanel = self:getSecondarySelectorPanel(player)
  local model = self.model:getModel(player)

  if selectorPanel["scroll-secondary"] ~= nil and selectorPanel["scroll-secondary"].valid then
    selectorPanel["scroll-secondary"].destroy()
  end
  local scrollPanel = self:addGuiScrollPane(selectorPanel, "scroll-secondary", "helmod_scroll_recipe_factories", "auto", "auto")

  local object = self:getObject(player, element, action, item, item2, item3)

  local groupsPanel = self:addGuiTable(scrollPanel, "secondary-groups", 1)

  local category = "secondary"
  if not(self.player:getSettings(player, "model_filter_generator", true)) then category = nil end
  -- ajouter de la table des groupes de recipe
  local factories = self.player:getGenerators("secondary")
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
      local action = self:addGuiButton(groupsPanel, self:classname().."=secondary-group=ID="..item.."=", group, "helmod_button_default", group)
    end
  end

  local tablePanel = self:addGuiTable(scrollPanel, "secondary-table", 5)
  --Logging:debug(self:classname(), "factories:",self.player:getProductions())
  for key, element in pairs(factories) do
    if category ~= nil or (element.subgroup ~= nil and element.subgroup.name == model.secondaryGroupSelected) then
      local localised_name = self.player:getLocalisedName(player, element)
      self:addGuiButtonSelectSprite(tablePanel, self:classname().."=secondary-select=ID="..item.."=", "item", element.name, element.name, localised_name)
    end
  end
end
