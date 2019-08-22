require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ProductionLineTab
-- @extends #AbstractTab
--

ProductionLineTab = setclass("HMProductionLineTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#ProductionLineTab] getButtonCaption
--
-- @return #string
--
function ProductionLineTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-production-line"}
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#ProductionLineTab] getButtonStyles
--
-- @return boolean
--
function ProductionLineTab.methods:getButtonStyles()
  return "helmod_button_icon_factory","helmod_button_icon_factory_selected"
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateInfo", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug(self:classname(), "model:", model)
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  info_scroll.clear()
  -- info panel
  
  local block_table = ElementGui.addGuiTable(info_scroll,"output-table",2)

  ElementGui.addGuiLabel(block_table, "label-owner", ({"helmod_result-panel.owner"}))
  ElementGui.addGuiLabel(block_table, "value-owner", model.owner)

  ElementGui.addGuiLabel(block_table, "label-share", ({"helmod_result-panel.share"}))

  local tableAdminPanel = ElementGui.addGuiTable(block_table, "table" , 9)
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=read="..model.id, model_read, nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-read", "R", nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=write="..model.id, model_write, nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-write", "W", nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=delete="..model.id, model_delete, nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-delete", "X", nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))

  local count_block = Model.countBlocks()
  if count_block > 0 then
    -- info panel
    ElementGui.addGuiLabel(block_table, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      ElementGui.addGuiLabel(block_table, "power", Format.formatNumberKilo(model.summary.energy or 0, "W"))
    end
  end

end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateInput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateInput(item, item2, item3)
  Logging:debug(self:classname(), "updateInput", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  input_scroll.clear()
  -- input panel

  local count_block = Model.countBlocks()
  if count_block > 0 then

    local input_table = ElementGui.addGuiTable(input_scroll,"input-table", ElementGui.getElementColumnNumber(50), "helmod_table_element")
    
    if model.ingredients ~= nil then
      for index, element in pairs(model.ingredients) do
        ElementGui.addCellElementM(input_table, element, self:classname().."=production-block-add=ID=new="..element.name.."=", true, "tooltip.add-recipe", ElementGui.color_button_add, index)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateOutput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateOutput(item, item2, item3)
  Logging:debug(self:classname(), "updateOutput", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  output_scroll.clear()
  -- ouput panel

  -- production block result
  local count_block = Model.countBlocks()
  if count_block > 0 then

    -- ouput panel
    local output_table = ElementGui.addGuiTable(output_scroll,"output-table", ElementGui.getElementColumnNumber(50), "helmod_table_element")
    if model.products ~= nil then
      for index, element in pairs(model.products) do
        ElementGui.addCellElementM(output_table, element, self:classname().."=product-selected=ID=new="..element.name.."=", false, "tooltip.product", nil, index)
      end
    end
    
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionLineTab] updateData
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateData(item, item2, item3)
  Logging:debug(self:classname(), "updateData():", item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local model = Model.getModel()

  self:updateInfo(item, item2, item3)
  self:updateOutput(item, item2, item3)
  self:updateInput(item, item2, item3)
  
  -- data panel
  local scrollPanel = self:getResultScrollPanel()

  local countBlock = Model.countBlocks()
  if countBlock > 0 then
    local globalSettings = Player.getGlobal("settings")
    -- data panel
    local extra_cols = 0
    if Player.getSettings("display_data_col_index", true) then
      extra_cols = extra_cols + 1
    end
    if Player.getSettings("display_data_col_id", true) then
      extra_cols = extra_cols + 1
    end
    if Player.getSettings("display_data_col_name", true) then
      extra_cols = extra_cols + 1
    end
    local result_table = ElementGui.addGuiTable(scrollPanel,"list-data",5 + extra_cols, "helmod_table-odd")
    result_table.vertical_centering = false

    self:addTableHeader(result_table)

    local i = 0
    for _, element in spairs(model.blocks, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(result_table, element)
    end
  end
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#ProductionLineTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function ProductionLineTab.methods:addTableHeader(itable)
  Logging:debug(self:classname(), "addTableHeader()")
  local model = Model.getModel()
  
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(itable, "id", {"helmod_result-panel.col-header-id"},"id")
  self:addCellHeader(itable, "name", {"helmod_result-panel.col-header-name"},"name")
  -- data columns
  self:addCellHeader(itable, "recipe", {"helmod_result-panel.col-header-production-block"},"index")
  self:addCellHeader(itable, "energy", {"helmod_result-panel.col-header-energy"},"power")
  self:addCellHeader(itable, "products", {"helmod_result-panel.col-header-output"})
  self:addCellHeader(itable, "ingredients", {"helmod_result-panel.col-header-input"})
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#ProductionLineTab] addTableRow
--
-- @param #LuaGuiElement gui_table
-- @param #table block production block
--
function ProductionLineTab.methods:addTableRow(gui_table, block)
  Logging:debug(self:classname(), "addTableRow()", block)
  local model = Model.getModel()

  local globalSettings = Player.getGlobal("settings")
  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..block.id, 2)

  ElementGui.addGuiButton(cell_action, self:classname().."=production-block-up=ID=", block.id, "helmod_button_icon_arrow_top_sm", nil, ({"tooltip.up-element", Player.getSettings("row_move_step")}))
  ElementGui.addGuiButton(cell_action, self:classname().."=production-block-remove=ID=", block.id, "helmod_button_icon_delete_sm_red", nil, ({"tooltip.remove-element"}))
  ElementGui.addGuiButton(cell_action, self:classname().."=production-block-down=ID=", block.id, "helmod_button_icon_arrow_down_sm", nil, ({"tooltip.down-element", Player.getSettings("row_move_step")}))
  if unlinked then
    ElementGui.addGuiButton(cell_action, self:classname().."=production-block-unlink=ID=", block.id, "helmod_button_icon_unlink_sm", nil, ({"tooltip.unlink-element"}))
  else
    ElementGui.addGuiButton(cell_action, self:classname().."=production-block-unlink=ID=", block.id, "helmod_button_icon_link_sm_selected", nil, ({"tooltip.unlink-element"}))
  end

  -- col index
  if Player.getSettings("display_data_col_index", true) then
    ElementGui.addCellLabel(gui_table, "cell_index"..block.id, block.index)
  end
  -- col id
  if Player.getSettings("display_data_col_id", true) then
    ElementGui.addCellLabel(gui_table, "cell_id"..block.id, block.id)
  end
  -- col name
  if Player.getSettings("display_data_col_name", true) then
    ElementGui.addCellLabel(gui_table, "cell_name"..block.id, block.name)
  end

  -- col recipe
  local cell_recipe = ElementGui.addCell(gui_table, "recipe"..block.id)
  ElementGui.addCellBlock(cell_recipe, block, self:classname().."=change-tab=ID=HMProductionBlockTab="..block.id.."=", true, "tooltip.edit-block", "gray")

  -- col energy
  local cell_energy = ElementGui.addCell(gui_table, block.id)
  ElementGui.addCellEnergy(cell_energy, block, self:classname().."=change-tab=ID=HMProductionBlockTab="..block.id.."=", true, "tooltip.edit-block", "gray")
  
  -- products
  local display_product_cols = Player.getSettings("display_product_cols") + 1
  local cell_products = ElementGui.addCell(gui_table,"products_"..block.id, display_product_cols)
  if block.products ~= nil then
    for index, product in pairs(block.products) do
      if product.state == 1 then
        if not(unlinked) or block.by_factory == true then
          ElementGui.addCellElement(cell_products, product, self:classname().."=product-selected=ID="..block.id.."="..product.name.."=", false, "tooltip.product", nil, index)
        else
          ElementGui.addCellElement(cell_products, product, self:classname().."=product-edition=ID="..block.id.."="..product.name.."=", true, "tooltip.edit-product", ElementGui.color_button_edit, index)
        end
      elseif product.state == 3 then
        ElementGui.addCellElement(cell_products, product, self:classname().."=product-selected=ID="..block.id.."="..product.name.."=", true, "tooltip.rest-product", ElementGui.color_button_rest, index)
      else
        ElementGui.addCellElement(cell_products, product, self:classname().."=product-selected=ID="..block.id.."="..product.name.."=", false, "tooltip.other-product", nil, index)
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = Player.getSettings("display_ingredient_cols") + 2
  local cell_ingredients = ElementGui.addCell(gui_table,"ingredients_"..block.id, display_ingredient_cols)
  if block.ingredients ~= nil then
    for index, ingredient in pairs(block.ingredients) do
      ElementGui.addCellElement(cell_ingredients, ingredient, self:classname().."=production-block-add=ID="..block.id.."="..ingredient.name.."=", true, "tooltip.add-recipe", ElementGui.color_button_add, index)
    end
  end
end