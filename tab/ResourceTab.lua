require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ResourceTab
-- @extends #AbstractTab
--

ResourceTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#ResourceTab] getButtonCaption
--
-- @return #string
--
function ResourceTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-resources"}
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#ResourceTab] getButtonStyles
--
-- @return boolean
--
function ResourceTab:getButtonStyles()
  return "helmod_button_icon_jewel","helmod_button_icon_jewel_selected"
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#ResourceTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function ResourceTab:addTableHeader(itable)
  Logging:debug(self.classname, "addTableHeader()", itable)
  
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
function ResourceTab:addTableRow(guiTable, ingredient)
  Logging:debug(self.classname, "addTableRow()", guiTable, ingredient)
  local model = Model.getModel()

  -- col index
  if User.getModGlobalSetting("display_data_col_index") then
    local guiIndex = ElementGui.addGuiFrameH(guiTable,"index"..ingredient.name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiIndex, "index", ingredient.index, "helmod_label_row_right_40")
  end
  -- col name
  if User.getModGlobalSetting("display_data_col_name") then
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
-- @param #LuaEvent event
-- 
function ResourceTab:updateData(event)
  Logging:debug(self.classname, "updateData()", event)
  local model = Model.getModel()
  local order = User.getParameter("order")
  -- data
  local scrollPanel = self:getResultScrollPanel({"helmod_result-panel.tab-title-energy"})


  local extra_cols = 0
  if User.getModGlobalSetting("display_data_col_index") then
    extra_cols = extra_cols + 1
  end
  if User.getModGlobalSetting("display_data_col_name") then
    extra_cols = extra_cols + 1
  end
  local resultTable = ElementGui.addGuiTable(scrollPanel,"table-resources",3 + extra_cols)

  self:addTableHeader(resultTable)


  for _, recipe in spairs(model.ingredients, function(t,a,b) if order.ascendant then return t[b][order.name] > t[a][order.name] else return t[b][order.name] < t[a][order.name] end end) do
    self:addTableRow(resultTable, recipe)
  end
end
