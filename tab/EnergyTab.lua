require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module EnergyTab
-- @extends #AbstractTab
--

EnergyTab = newclass(AbstractTab,function(base,classname)
  AbstractTab.init(base,classname)
end)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#EnergyTab] getButtonCaption
--
-- @return #string
--
function EnergyTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-energy"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#EnergyTab] getButtonSprites
--
-- @return boolean
--
function EnergyTab:getButtonSprites()
  return "nuclear-white","nuclear"
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#EnergyTab] updateData
--
function EnergyTab:updateData()
  Logging:debug(self.classname, "updatePowers()")
  local model = Model.getModel()
  local order = User.getParameter("order")

  -- data
  local scroll_panel = self:getResultScrollPanel()
  local menu_manel = GuiElement.add(scroll_panel, GuiFrameH("menu"):style(helmod_frame_style.hidden))
  GuiElement.add(menu_manel, GuiButton("HMEnergyEdition=OPEN=ID", "new"):caption({"helmod_result-panel.add-button-power"}))

  local countBlock = Model.countPowers()
  if model.powers ~= nil and countBlock > 0 then

    local extra_cols = 0
    if User.getModGlobalSetting("display_data_col_id") then
      extra_cols = extra_cols + 1
    end
    local resultTable = GuiElement.add(scroll_panel, GuiTable("list-data"):column(4 + extra_cols):style("helmod_table-odd"))

    self:addTableHeader(resultTable)

    local i = 0
    for _, element in spairs(model.powers, function(t,a,b) if order.ascendant then return t[b][order.name] > t[a][order.name] else return t[b][order.name] < t[a][order.name] end end) do
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
function EnergyTab:addTableHeader(itable)
  Logging:debug(self.classname, "addTableHeader()", itable)
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
function EnergyTab:addTableRow(gui_table, power)
  Logging:debug(self.classname, "addPowersRow()", gui_table, power)
  local model = Model.getModel()
  log(self.classname)
  -- col action
  local cell_action = GuiElement.add(gui_table, GuiFrameH("action", power.id):style(helmod_frame_style.hidden))
  GuiElement.add(cell_action, GuiButton(self.classname, "power-remove=ID", power.id):sprite("menu", "delete-white", "delete"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
  log(self.classname)

  -- col id
  if User.getModGlobalSetting("display_data_col_id") then
    local cell_id = GuiElement.add(gui_table, GuiFrameH("id", power.id):style(helmod_frame_style.hidden))
    GuiElement.add(cell_id, GuiLabel("id"):caption(power.id))
  end
  -- col power
  local cell_power = GuiElement.add(gui_table, GuiFrameH("power", power.id):style(helmod_frame_style.hidden))
  GuiElement.add(cell_power, GuiLabel(power.id):caption(Format.formatNumberKilo(power.power, "W")):style("helmod_label_right_70"))

  -- col primary
  local cell_primary = GuiElement.add(gui_table, GuiFrameH("primary",power.id):style(helmod_frame_style.hidden))
  local primary = power.primary
  if primary.name ~= nil then
    GuiElement.add(cell_primary, GuiLabel(primary.name):caption(Format.formatNumberFactory(primary.count)):style("helmod_label_right_60"))
    GuiElement.add(cell_primary, GuiButtonSelectSprite("HMEnergyEdition=OPEN=ID", power.id):sprite(primary.type, primary.name):caption("X"..Format.formatNumberFactory(primary.count)):tooltip({"tooltip.edit-energy", Player.getLocalisedName(primary)}))
  end
  -- col secondary
  local cell_secondary = GuiElement.add(gui_table, GuiFrameH("secondary", power.id):style(helmod_frame_style.hidden))
  local secondary = power.secondary
  if secondary.name ~= nil then
    GuiElement.add(cell_secondary, GuiLabel(secondary.name):caption(Format.formatNumberFactory(secondary.count)):style("helmod_label_right_60"))
    GuiElement.add(cell_secondary, GuiButtonSelectSprite("HMEnergyEdition=OPEN=ID", power.id):sprite(secondary.type, secondary.name):caption("X"..Format.formatNumberFactory(secondary.count)):tooltip({"tooltip.edit-energy", Player.getLocalisedName(secondary)}))
  end
end
