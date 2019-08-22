require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ResourceTab
-- @extends #AbstractTab
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
-- Get Button Styles
--
-- @function [parent=#ResourceTab] getButtonStyles
--
-- @return boolean
--
function ResourceTab.methods:getButtonStyles()
  return "helmod_button_icon_jewel","helmod_button_icon_jewel_selected"
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#ResourceTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function ResourceTab.methods:addTableHeader(itable)
  Logging:debug(self:classname(), "addTableHeader():", itable)
  
  -- optionnal columns
  self:addCellHeader(itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(itable, "name", {"helmod_result-panel.col-header-name"},"name")
  -- data columns
  self:addCellHeader(itable, "count", {"helmod_result-panel.col-header-total"},"count")
  self:addCellHeader(itable, "ingredient", {"helmod_result-panel.col-header-ingredient"}, "index")
  self:addCellHeader(itable, "ressource_type", {"helmod_result-panel.col-header-type"}, "resource_category")
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#ResourceTab] addTableRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table ingredient
--
function ResourceTab.methods:addTableRow(guiTable, ingredient)
  Logging:debug(self:classname(), "addTableRow():", guiTable, ingredient)
  local model = Model.getModel()

  -- col index
  if Player.getSettings("display_data_col_index", true) then
    local guiIndex = ElementGui.addGuiFrameH(guiTable,"index"..ingredient.name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiIndex, "index", ingredient.index, "helmod_label_row_right_40")
  end
  -- col name
  if Player.getSettings("display_data_col_name", true) then
    local guiName = ElementGui.addGuiFrameH(guiTable,"name"..ingredient.name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiName, "name_", ingredient.name)
  end
  -- col count
  local guiCount = ElementGui.addGuiFrameH(guiTable,"count"..ingredient.name, helmod_frame_style.hidden)
  ElementGui.addGuiLabel(guiCount, ingredient.name, Format.formatNumberElement(ingredient.count), "helmod_label_right_60")

  -- col ingredient
  local guiIngredient = ElementGui.addGuiFrameH(guiTable,"ingredient"..ingredient.name, helmod_frame_style.hidden)
  ElementGui.addGuiButtonSprite(guiIngredient, "HMIngredient=OPEN=ID=", Player.getIconType(ingredient), ingredient.name, ingredient.name, Player.getLocalisedName(ingredient))

  -- col type
  local guiType = ElementGui.addGuiFrameH(guiTable,"type"..ingredient.name, helmod_frame_style.hidden)
  ElementGui.addGuiLabel(guiType, ingredient.name, ingredient.resource_category)

end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ResourceTab] updateData
--
function ResourceTab.methods:updateData()
  Logging:debug(self:classname(), "updateData()")
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  -- data
  local scrollPanel = self:getResultScrollPanel({"helmod_result-panel.tab-title-energy"})


  local extra_cols = 0
  if Player.getSettings("display_data_col_index", true) then
    extra_cols = extra_cols + 1
  end
  if Player.getSettings("display_data_col_name", true) then
    extra_cols = extra_cols + 1
  end
  local resultTable = ElementGui.addGuiTable(scrollPanel,"table-resources",3 + extra_cols)

  self:addTableHeader(resultTable)


  for _, recipe in spairs(model.ingredients, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
    self:addTableRow(resultTable, recipe)
  end
end
