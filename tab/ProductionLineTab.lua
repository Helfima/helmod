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
-- Update header
--
-- @function [parent=#ProductionLineTab] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateHeader(item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local model = Model.getModel()

  local infoPanel = self.parent:getInfoPanel()
  -- info panel
  local blockPanel = ElementGui.addGuiFrameH(infoPanel, "block", "helmod_frame_default", ({"helmod_result-panel.tab-title-production-line"}))
  local blockScroll = ElementGui.addGuiScrollPane(blockPanel, "output-scroll", "helmod_scroll_block_info", "auto", "auto")
  local blockTable = ElementGui.addGuiTable(blockScroll,"output-table",2)


  local elementPanel = ElementGui.addGuiFlowV(infoPanel, "elements", "helmod_flow_default")
  -- ouput panel
  local outputPanel = ElementGui.addGuiFrameV(elementPanel, "output", "helmod_frame_resize_row_width", ({"helmod_common.output"}))
  local outputScroll = ElementGui.addGuiScrollPane(outputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  Player.setStyle(outputScroll, "scroll_block_element", "minimal_width")
  Player.setStyle(outputScroll, "scroll_block_element", "maximal_width")

  -- input panel
  local inputPanel = ElementGui.addGuiFrameV(elementPanel, "input", "helmod_frame_resize_row_width", ({"helmod_common.input"}))
  local inputScroll = ElementGui.addGuiScrollPane(inputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  Player.setStyle(inputScroll, "scroll_block_element", "minimal_width")
  Player.setStyle(inputScroll, "scroll_block_element", "maximal_width")

  -- admin panel
  ElementGui.addGuiLabel(blockTable, "label-owner", ({"helmod_result-panel.owner"}))
  ElementGui.addGuiLabel(blockTable, "value-owner", model.owner)

  ElementGui.addGuiLabel(blockTable, "label-share", ({"helmod_result-panel.share"}))

  local tableAdminPanel = ElementGui.addGuiTable(blockTable, "table" , 9)
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self.parent:classname().."=share-model=ID=read="..model.id, model_read, nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self.parent:classname().."=share-model-read", "R", nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self.parent:classname().."=share-model=ID=write="..model.id, model_write, nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self.parent:classname().."=share-model-write", "W", nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self.parent:classname().."=share-model=ID=delete="..model.id, model_delete, nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self.parent:classname().."=share-model-delete", "X", nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))

  local countBlock = Model.countBlocks()
  if countBlock > 0 then
    local globalSettings = Player.getGlobal("settings")

    -- info panel
    ElementGui.addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      ElementGui.addGuiLabel(blockTable, "power", Format.formatNumberKilo(model.summary.energy or 0, "W"))
    end

    -- ouput panel
    local inputTable = ElementGui.addGuiTable(outputScroll,"output-table",6)
    if model.products ~= nil then
      for r, element in pairs(model.products) do
        ElementGui.addCellElement(inputTable, element, self.parent:classname().."=product-selected=ID=new="..element.name.."=", false, "tooltip.product", nil)
      end
    end

    -- input panel
    local inputTable = ElementGui.addGuiTable(inputScroll,"input-table",6)
    if model.ingredients ~= nil then
      for r, element in pairs(model.ingredients) do
        ElementGui.addCellElement(inputTable, element, self.parent:classname().."=product-selected=ID=new="..element.name.."=", false, "tooltip.ingredient", nil)
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

  -- data panel
  local scrollPanel = self.parent:getResultScrollPanel({"helmod_common.blocks"})

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
    local resultTable = ElementGui.addGuiTable(scrollPanel,"list-data",5 + extra_cols, "helmod_table-odd")

    self:addTableHeader(resultTable)

    local i = 0
    for _, element in spairs(model.blocks, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(resultTable, element)
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
-- @param #LuaGuiElement guiTable
-- @param #table block production block
--
function ProductionLineTab.methods:addTableRow(guiTable, block)
  Logging:debug(self:classname(), "addTableRow()", block)
  local model = Model.getModel()

  local globalSettings = Player.getGlobal("settings")
  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end

  -- col action
  local guiAction = ElementGui.addGuiFlowH(guiTable,"action"..block.id, "helmod_flow_default")
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-block-remove=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-block-down=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element", Player.getSettings("row_move_step")}))
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-block-up=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element", Player.getSettings("row_move_step")}))
  if unlinked then
    ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-block-unlink=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-unlink"}), ({"tooltip.unlink-element"}))
  else
    ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-block-unlink=ID=", block.id, "helmod_button_selected", ({"helmod_result-panel.row-button-unlink"}), ({"tooltip.unlink-element"}))
  end

  -- col index
  if Player.getSettings("display_data_col_index", true) then
    local guiIndex = ElementGui.addGuiFlowH(guiTable,"index"..block.id)
    ElementGui.addGuiLabel(guiIndex, "index", block.index, "helmod_label_row_right_40")
  end
  -- col id
  if Player.getSettings("display_data_col_id", true) then
    local guiId = ElementGui.addGuiFlowH(guiTable,"id"..block.id)
    ElementGui.addGuiLabel(guiId, "id", block.id)
  end
  -- col name
  if Player.getSettings("display_data_col_name", true) then
    local guiName = ElementGui.addGuiFlowH(guiTable,"name"..block.id)
    ElementGui.addGuiLabel(guiName, "name_", block.name)
  end

  -- col recipe
  local guiRecipe = ElementGui.addGuiFlowH(guiTable,"recipe"..block.id)
  self:addIconRecipeCell(guiRecipe, block, self.parent:classname().."=change-tab=ID=HMProductionBlockTab="..block.id.."=", true, "tooltip.edit-block", self.color_button_edit)

  -- col energy
  local guiEnergy = self:addCellLabel(guiTable, block.id, Format.formatNumberKilo(block.power, "W"), 60)

  -- products
  local display_product_cols = Player.getSettings("display_product_cols") + 1
  local tProducts = ElementGui.addGuiTable(guiTable,"products_"..block.id, display_product_cols)
  if block.products ~= nil then
    for r, product in pairs(block.products) do
      if bit32.band(product.state, 1) > 0 then
        if not(unlinked) or block.by_factory == true then
          ElementGui.addCellElement(tProducts, product, self.parent:classname().."=product-selected=ID="..block.id.."="..product.name.."=", false, "tooltip.product", nil)
        else
          ElementGui.addCellElement(tProducts, product, self.parent:classname().."=product-edition=ID="..block.id.."="..product.name.."=", true, "tooltip.edit-product", self.color_button_edit)
        end
      end
      if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
        ElementGui.addCellElement(tProducts, product, self.parent:classname().."=product-selected=ID="..block.id.."="..product.name.."=", true, "tooltip.rest-product", self.color_button_rest)
      end
      if product.state == 0 then
        ElementGui.addCellElement(tProducts, product, self.parent:classname().."=product-selected=ID="..block.id.."="..product.name.."=", false, "tooltip.other-product", nil)
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = Player.getSettings("display_ingredient_cols") + 2
  local tIngredient = ElementGui.addGuiTable(guiTable,"ingredients_"..block.id, display_ingredient_cols)
  if block.ingredients ~= nil then
    for r, ingredient in pairs(block.ingredients) do
      ElementGui.addCellElement(tIngredient, ingredient, self.parent:classname().."=production-block-add=ID="..block.id.."="..ingredient.name.."=", true, "tooltip.add-recipe", self.color_button_add)
    end
  end
end