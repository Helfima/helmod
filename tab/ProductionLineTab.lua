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
-- Before update
--
-- @function [parent=#ProductionLineTab] beforeUpdate
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:beforeUpdate(player, item, item2, item3)
  Logging:trace(self:classname(), "beforeUpdate():", player, item, item2, item3)
  self.parent:send_event(player, "HMProductEdition", "CLOSE")
  self.parent:send_event(player, "HMRecipeEdition", "CLOSE")
  self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateHeader
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateHeader(player, item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  local model = self.model:getModel(player)

  local infoPanel = self.parent:getInfoPanel(player)
  -- info panel
  local blockPanel = self:addGuiFrameH(infoPanel, "block", "helmod_frame_default", ({"helmod_result-panel.tab-title-production-line"}))
  local blockScroll = self:addGuiScrollPane(blockPanel, "output-scroll", "helmod_scroll_block_info", "auto", "auto")
  local blockTable = self:addGuiTable(blockScroll,"output-table",2)


  local elementPanel = self:addGuiFlowV(infoPanel, "elements", "helmod_flow_default")
  -- ouput panel
  local outputPanel = self:addGuiFrameV(elementPanel, "output", "helmod_frame_resize_row_width", ({"helmod_common.output"}))
  local outputScroll = self:addGuiScrollPane(outputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "minimal_width")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "maximal_width")

  -- input panel
  local inputPanel = self:addGuiFrameV(elementPanel, "input", "helmod_frame_resize_row_width", ({"helmod_common.input"}))
  local inputScroll = self:addGuiScrollPane(inputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "minimal_width")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "maximal_width")

  -- admin panel
  self:addGuiLabel(blockTable, "label-owner", ({"helmod_result-panel.owner"}))
  self:addGuiLabel(blockTable, "value-owner", model.owner)

  self:addGuiLabel(blockTable, "label-share", ({"helmod_result-panel.share"}))

  local tableAdminPanel = self:addGuiTable(blockTable, "table" , 9)
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  self:addGuiCheckbox(tableAdminPanel, self.parent:classname().."=share-model=ID=read="..model.id, model_read, nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))
  self:addGuiLabel(tableAdminPanel, self.parent:classname().."=share-model-read", "R", nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  self:addGuiCheckbox(tableAdminPanel, self.parent:classname().."=share-model=ID=write="..model.id, model_write, nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))
  self:addGuiLabel(tableAdminPanel, self.parent:classname().."=share-model-write", "W", nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  self:addGuiCheckbox(tableAdminPanel, self.parent:classname().."=share-model=ID=delete="..model.id, model_delete, nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))
  self:addGuiLabel(tableAdminPanel, self.parent:classname().."=share-model-delete", "X", nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))

  local countBlock = self.model:countBlocks(player)
  if countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")

    -- info panel
    self:addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      self:addGuiLabel(blockTable, "power", self:formatNumberKilo(model.summary.energy or 0, "W"))
    end

    -- ouput panel
    local inputTable = self:addGuiTable(outputScroll,"output-table",6)
    if model.products ~= nil then
      for r, element in pairs(model.products) do
        self:addCellElement(player, inputTable, element, "HMIngredient=OPEN=ID="..element.name.."=", false, "tooltip.product", nil)
      end
    end

    -- input panel
    local inputTable = self:addGuiTable(inputScroll,"input-table",6)
    if model.ingredients ~= nil then
      for r, element in pairs(model.ingredients) do
        self:addCellElement(player, inputTable, element, "HMIngredient=OPEN=ID="..element.name.."=", false, "tooltip.ingredient", nil)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionLineTab] updateData
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionLineTab.methods:updateData(player, item, item2, item3)
  Logging:debug(self:classname(), "updateData():", item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  local model = self.model:getModel(player)

  -- data panel
  local scrollPanel = self.parent:getResultScrollPanel(player, {"helmod_common.blocks"})

  local countBlock = self.model:countBlocks(player)
  if countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")
    -- data panel
    local extra_cols = 0
    if self.player:getSettings(player, "display_data_col_index", true) then
      extra_cols = extra_cols + 1
    end
    if self.player:getSettings(player, "display_data_col_id", true) then
      extra_cols = extra_cols + 1
    end
    if self.player:getSettings(player, "display_data_col_name", true) then
      extra_cols = extra_cols + 1
    end
    local resultTable = self:addGuiTable(scrollPanel,"list-data",5 + extra_cols, "helmod_table-odd")

    self:addTableHeader(player, resultTable)

    local i = 0
    for _, element in spairs(model.blocks, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(player, resultTable, element)
    end
  end
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#ProductionLineTab] addTableHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function ProductionLineTab.methods:addTableHeader(player, itable)
  Logging:debug(self:classname(), "addTableHeader()")
  local model = self.model:getModel(player)
  
  self:addCellHeader(player, itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(player, itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(player, itable, "id", {"helmod_result-panel.col-header-id"},"id")
  self:addCellHeader(player, itable, "name", {"helmod_result-panel.col-header-name"},"name")
  -- data columns
  self:addCellHeader(player, itable, "recipe", {"helmod_result-panel.col-header-production-block"},"index")
  self:addCellHeader(player, itable, "energy", {"helmod_result-panel.col-header-energy"},"power")
  self:addCellHeader(player, itable, "products", {"helmod_result-panel.col-header-output"})
  self:addCellHeader(player, itable, "ingredients", {"helmod_result-panel.col-header-input"})
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#ProductionLineTab] addTableRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #table block production block
--
function ProductionLineTab.methods:addTableRow(player, guiTable, block)
  Logging:debug(self:classname(), "addTableRow()", block)
  local model = self.model:getModel(player)

  local globalSettings = self.player:getGlobal(player, "settings")
  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..block.id, "helmod_flow_default")
  self:addGuiButton(guiAction, self.parent:classname().."=production-block-remove=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  self:addGuiButton(guiAction, self.parent:classname().."=production-block-down=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
  self:addGuiButton(guiAction, self.parent:classname().."=production-block-up=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
  if unlinked then
    self:addGuiButton(guiAction, self.parent:classname().."=production-block-unlink=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-unlink"}), ({"tooltip.unlink-element"}))
  else
    self:addGuiButton(guiAction, self.parent:classname().."=production-block-unlink=ID=", block.id, "helmod_button_selected", ({"helmod_result-panel.row-button-unlink"}), ({"tooltip.unlink-element"}))
  end

  -- col index
  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..block.id)
    self:addGuiLabel(guiIndex, "index", block.index, "helmod_label_row_right_40")
  end
  -- col id
  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(guiTable,"id"..block.id)
    self:addGuiLabel(guiId, "id", block.id)
  end
  -- col name
  if self.player:getSettings(player, "display_data_col_name", true) then
    local guiName = self:addGuiFlowH(guiTable,"name"..block.id)
    self:addGuiLabel(guiName, "name_", block.name)
  end

  -- col recipe
  local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..block.id)
  self:addIconRecipeCell(player, guiRecipe, block, self.parent:classname().."=change-tab=ID=HMProductionBlockTab="..block.id.."=", true, "tooltip.edit-block", self.color_button_edit)

  -- col energy
  local guiEnergy = self:addCellLabel(player, guiTable, block.id, self:formatNumberKilo(block.power, "W"), 60)

  -- products
  local display_product_cols = self.player:getSettings(player, "display_product_cols") + 1
  local tProducts = self:addGuiTable(guiTable,"products_"..block.id, display_product_cols)
  if block.products ~= nil then
    for r, product in pairs(block.products) do
      if bit32.band(product.state, 1) > 0 then
        if not(unlinked) or block.by_factory == true then
          self:addCellElement(player, tProducts, product, "HMProduct=OPEN=ID=", false, "tooltip.product", nil)
        else
          self:addCellElement(player, tProducts, product, "HMProductEdition=OPEN=ID="..block.id.."=", true, "tooltip.edit-product", self.color_button_edit)
        end
      end
      if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
        self:addCellElement(player, tProducts, product, "HMProduct=OPEN=ID=", true, "tooltip.rest-product", self.color_button_rest)
      end
      if product.state == 0 then
        self:addCellElement(player, tProducts, product, "HMProduct=OPEN=ID=", false, "tooltip.other-product", nil)
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = self.player:getSettings(player, "display_ingredient_cols") + 2
  local tIngredient = self:addGuiTable(guiTable,"ingredients_"..block.id, display_ingredient_cols)
  if block.ingredients ~= nil then
    for r, ingredient in pairs(block.ingredients) do
      self:addCellElement(player, tIngredient, ingredient, self.parent:classname().."=production-block-add=ID="..block.id.."="..ingredient.name.."=", true, "tooltip.add-recipe", self.color_button_add)
    end
  end
end