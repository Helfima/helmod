require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module EnergyTab
-- @extends #AbstractTab
--

EnergyTab = setclass("HMEnergyTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#EnergyTab] getButtonCaption
--
-- @return #string
--
function EnergyTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-energy"}
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#EnergyTab] updateData
--
function EnergyTab.methods:updateData()
  Logging:debug(self:classname(), "updatePowers()")
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()

  -- data
  local scrollPanel = self.parent:getResultScrollPanel({"helmod_result-panel.tab-title-energy"})
  local menuPanel = ElementGui.addGuiFlowH(scrollPanel,"menu")
  ElementGui.addGuiButton(menuPanel, "HMEnergyEdition=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.add-button-power"}))

  local countBlock = Model.countPowers()
  if model.powers ~= nil and countBlock > 0 then
    local globalSettings = Player.getGlobal("settings")

    local extra_cols = 0
    if Player.getSettings("display_data_col_id", true) then
      extra_cols = extra_cols + 1
    end
    local resultTable = ElementGui.addGuiTable(scrollPanel,"list-data",4 + extra_cols, "helmod_table-odd")

    self:addTableHeader(resultTable)

    local i = 0
    for _, element in spairs(model.powers, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(resultTable, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#EnergyTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function EnergyTab.methods:addTableHeader(itable)
  Logging:debug(self:classname(), "addTableHeader():", itable)
  local model = Model.getModel()

  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(itable, "id", {"helmod_result-panel.col-header-id"},"id")
  -- data columns
  self:addCellHeader(itable, "power", {"helmod_result-panel.col-header-energy"})
  self:addCellHeader(itable, "primary", {"helmod_result-panel.col-header-primary"})
  self:addCellHeader(itable, "secondary", {"helmod_result-panel.col-header-secondary"})
end

-------------------------------------------------------------------------------
-- Add row table
--
-- @function [parent=#EnergyTab] addTableRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table power
--
function EnergyTab.methods:addTableRow(guiTable, power)
  Logging:debug(self:classname(), "addPowersRow():", guiTable, power)
  local model = Model.getModel()

  -- col action
  local guiAction = ElementGui.addGuiFlowH(guiTable,"action"..power.id, "helmod_flow_default")
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=power-remove=ID=", power.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))

  -- col id
  if Player.getSettings("display_data_col_id", true) then
    local guiId = ElementGui.addGuiFlowH(guiTable,"id"..power.id)
    ElementGui.addGuiLabel(guiId, "id", power.id)
  end
  -- col power
  local guiPower = ElementGui.addGuiFlowH(guiTable,"power"..power.id)
  ElementGui.addGuiLabel(guiPower, power.id, Format.formatNumberKilo(power.power, "W"), "helmod_label_right_70")

  -- col primary
  local guiPrimary = ElementGui.addGuiFlowH(guiTable,"primary"..power.id)
  local primary = power.primary
  if primary.name ~= nil then
    ElementGui.addGuiLabel(guiPrimary, primary.name, Format.formatNumberFactory(primary.count), "helmod_label_right_60")
    ElementGui.addGuiButtonSelectSprite(guiPrimary, "HMEnergyEdition=OPEN=ID="..power.id.."=", Player.getIconType(primary), primary.name, "X"..Format.formatNumberFactory(primary.count), {"tooltip.edit-energy", Player.getLocalisedName(primary)})
  end
  -- col secondary
  local guiSecondary = ElementGui.addGuiFlowH(guiTable,"secondary"..power.id)
  local secondary = power.secondary
  if secondary.name ~= nil then
    ElementGui.addGuiLabel(guiSecondary, secondary.name, Format.formatNumberFactory(secondary.count), "helmod_label_right_60")
    ElementGui.addGuiButtonSelectSprite(guiSecondary, "HMEnergyEdition=OPEN=ID="..power.id.."=", Player.getIconType(secondary), secondary.name, "X"..Format.formatNumberFactory(secondary.count), {"tooltip.edit-energy", Player.getLocalisedName(secondary)})
  end
end
