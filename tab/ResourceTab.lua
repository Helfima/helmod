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
-- Get Button Sprites
--
-- @function [parent=#ResourceTab] getButtonSprites
--
-- @return boolean
--
function ResourceTab:getButtonSprites()
  return "jewel-white","jewel"
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
    local guiIndex = GuiElement.add(guiTable, GuiFrameH("index", ingredient.name):style(helmod_frame_style.hidden))
    GuiElement.add(guiIndex, GuiLabel("index"):caption(ingredient.index):style("helmod_label_row_right_40"))
  end
  -- col name
  if User.getModGlobalSetting("display_data_col_name") then
    local guiName = GuiElement.add(guiTable, GuiFrameH("name", ingredient.name):style(helmod_frame_style.hidden))
    GuiElement.add(guiName, GuiLabel("name", ingredient.name):caption(ingredient.name))
  end
  -- col count
  local guiCount = GuiElement.add(guiTable, GuiFrameH("count", ingredient.name):style(helmod_frame_style.hidden))
  GuiElement.add(guiCount, GuiLabel(ingredient.name):caption(Format.formatNumberElement(ingredient.count)):style("helmod_label_right_60"))

  -- col ingredient
  local guiIngredient = GuiElement.add(guiTable, GuiFrameH("ingredient", ingredient.name):style(helmod_frame_style.hidden))
  GuiElement.add(guiIngredient, GuiButtonSprite("HMIngredient=OPEN=ID"):sprite(ingredient.type, ingredient.name):tooltip(Player.getLocalisedName(ingredient)))

  -- col type
  local guiType = GuiElement.add(guiTable, GuiFrameH("type", ingredient.name):style(helmod_frame_style.hidden))
  GuiElement.add(guiType, GuiLabel(ingredient.name):caption(ingredient.resource_category))

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
  local resultTable = GuiElement.add(scrollPanel, GuiTable("table-resources"):column(3 + extra_cols))

  self:addTableHeader(resultTable)


  for _, recipe in spairs(model.ingredients, function(t,a,b) if order.ascendant then return t[b][order.name] > t[a][order.name] else return t[b][order.name] < t[a][order.name] end end) do
    self:addTableRow(resultTable, recipe)
  end
end
