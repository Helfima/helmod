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
-- @param #LuaPlayer player
--
function EnergyTab.methods:updateData(player)
  Logging:debug(self:classname(), "updatePowers():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)

  -- data
  local scrollPanel = self.parent:getResultScrollPanel(player, {"helmod_result-panel.tab-title-energy"})
  local menuPanel = self:addGuiFlowH(scrollPanel,"menu")
  self:addGuiButton(menuPanel, "HMEnergyEdition=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.add-button-power"}))

  local countBlock = self.model:countPowers(player)
  if model.powers ~= nil and countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")

    local extra_cols = 0
    if self.player:getSettings(player, "display_data_col_id", true) then
      extra_cols = extra_cols + 1
    end
    local resultTable = self:addGuiTable(scrollPanel,"list-data",4 + extra_cols, "helmod_table-odd")

    self:addTableHeader(player, resultTable)

    local i = 0
    for _, element in spairs(model.powers, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(player, resultTable, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#EnergyTab] addTableHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function EnergyTab.methods:addTableHeader(player, itable)
  Logging:debug(self:classname(), "addTableHeader():", player, itable)
  local model = self.model:getModel(player)

  self:addCellHeader(player, itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(player, itable, "id", {"helmod_result-panel.col-header-id"},"id")
  -- data columns
  self:addCellHeader(player, itable, "power", {"helmod_result-panel.col-header-energy"})
  self:addCellHeader(player, itable, "primary", {"helmod_result-panel.col-header-primary"})
  self:addCellHeader(player, itable, "secondary", {"helmod_result-panel.col-header-secondary"})
end

-------------------------------------------------------------------------------
-- Add row table
--
-- @function [parent=#EnergyTab] addTableRow
--
-- @param #LuaPlayer player
--
function EnergyTab.methods:addTableRow(player, guiTable, power)
  Logging:debug(self:classname(), "addPowersRow():", player, guiTable, power)
  local model = self.model:getModel(player)

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..power.id, "helmod_flow_default")
  self:addGuiButton(guiAction, self.parent:classname().."=power-remove=ID=", power.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))

  -- col id
  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(guiTable,"id"..power.id)
    self:addGuiLabel(guiId, "id", power.id)
  end
  -- col power
  local guiPower = self:addGuiFlowH(guiTable,"power"..power.id)
  self:addGuiLabel(guiPower, power.id, self:formatNumberKilo(power.power, "W"), "helmod_label_right_70")

  -- col primary
  local guiPrimary = self:addGuiFlowH(guiTable,"primary"..power.id)
  local primary = power.primary
  if primary.name ~= nil then
    self:addGuiLabel(guiPrimary, primary.name, self:formatNumberFactory(primary.count), "helmod_label_right_60")
    self:addGuiButtonSelectSprite(guiPrimary, "HMEnergyEdition=OPEN=ID="..power.id.."=", self.player:getIconType(primary), primary.name, "X"..self:formatNumberFactory(primary.count), ({"tooltip.edit-energy", self.player:getLocalisedName(player, primary)}))
  end
  -- col secondary
  local guiSecondary = self:addGuiFlowH(guiTable,"secondary"..power.id)
  local secondary = power.secondary
  if secondary.name ~= nil then
    self:addGuiLabel(guiSecondary, secondary.name, self:formatNumberFactory(secondary.count), "helmod_label_right_60")
    self:addGuiButtonSelectSprite(guiSecondary, "HMEnergyEdition=OPEN=ID="..power.id.."=", self.player:getIconType(secondary), secondary.name, "X"..self:formatNumberFactory(secondary.count), ({"tooltip.edit-energy", self.player:getLocalisedName(player, secondary)}))
  end
end
