require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ResourceTab
-- @extends #ElementGui
--

ResourceTab = setclass("HMResourceTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#ResourceTab] getButtonCaption
--
-- @return #string
--
function ResourceTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-resources"}
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#ResourceTab] addTableHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function ResourceTab.methods:addTableHeader(player, itable)
  Logging:debug(self:classname(), "addTableHeader():", player, itable)
  
  -- optionnal columns
  self:addCellHeader(player, itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(player, itable, "name", {"helmod_result-panel.col-header-name"},"name")
  -- data columns
  self:addCellHeader(player, itable, "count", {"helmod_result-panel.col-header-total"},"count")
  self:addCellHeader(player, itable, "ingredient", {"helmod_result-panel.col-header-ingredient"}, "index")
  self:addCellHeader(player, itable, "type", {"helmod_result-panel.col-header-type"}, "resource_category")
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#ResourceTab] addTableRow
--
-- @param #LuaPlayer player
--
function ResourceTab.methods:addTableRow(player, guiTable, ingredient)
  Logging:debug(self:classname(), "addTableRow():", player, guiTable, ingredient)
  local model = self.model:getModel(player)

  -- col index
  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..ingredient.name)
    self:addGuiLabel(guiIndex, "index", ingredient.index, "helmod_label_row_right_40")
  end
  -- col name
  if self.player:getSettings(player, "display_data_col_name", true) then
    local guiName = self:addGuiFlowH(guiTable,"name"..ingredient.name)
    self:addGuiLabel(guiName, "name_", ingredient.name)
  end
  -- col count
  local guiCount = self:addGuiFlowH(guiTable,"count"..ingredient.name)
  self:addGuiLabel(guiCount, ingredient.name, self:formatNumberElement(ingredient.count), "helmod_label_right_60")

  -- col ingredient
  local guiIngredient = self:addGuiFlowH(guiTable,"ingredient"..ingredient.name)
  self:addGuiButtonSprite(guiIngredient, "HMIngredient=OPEN=ID=", self.player:getIconType(ingredient), ingredient.name, ingredient.name, self.player:getLocalisedName(player, ingredient))

  -- col type
  local guiType = self:addGuiFlowH(guiTable,"type"..ingredient.name)
  self:addGuiLabel(guiType, ingredient.name, ingredient.resource_category)

end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ResourceTab] updateData
--
-- @param #LuaPlayer player
--
function ResourceTab.methods:updateData(player)
  Logging:debug(self:classname(), "updateData():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  -- data
  local scrollPanel = self.parent:getResultScrollPanel(player, {"helmod_result-panel.tab-title-energy"})


  local extra_cols = 0
  if self.player:getSettings(player, "display_data_col_index", true) then
    extra_cols = extra_cols + 1
  end
  if self.player:getSettings(player, "display_data_col_name", true) then
    extra_cols = extra_cols + 1
  end
  local resultTable = self:addGuiTable(scrollPanel,"table-resources",3 + extra_cols)

  self:addTableHeader(player, resultTable)


  for _, recipe in spairs(model.ingredients, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
    self:addTableRow(player, resultTable, recipe)
  end
end
