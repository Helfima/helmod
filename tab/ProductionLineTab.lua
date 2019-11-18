require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ProductionLineTab
-- @extends #AbstractTab
--

ProductionLineTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#ProductionLineTab] getButtonCaption
--
-- @return #string
--
function ProductionLineTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-production-line"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#ProductionLineTab] getButtonSprites
--
-- @return boolean
--
function ProductionLineTab:getButtonSprites()
  return "factory-white","factory"
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateInfo
--
-- @param #LuaEvent event
--
function ProductionLineTab:updateInfo(event)
  Logging:debug(self.classname, "updateInfo", event)
  local model = Model.getModel()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  info_scroll.clear()
  -- info panel
  
  local block_table = GuiElement.add(info_scroll, GuiTable("output-table"):column(2))

  GuiElement.add(block_table, GuiLabel("label-owner"):caption({"helmod_result-panel.owner"}))
  GuiElement.add(block_table, GuiLabel("value-owner"):caption(model.owner))

  GuiElement.add(block_table, GuiLabel("label-share"):caption({"helmod_result-panel.share"}))

  local tableAdminPanel = GuiElement.add(block_table, GuiTable("table"):column(9))
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model=ID=read", model.id):state(model_read):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-read"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model=ID=write", model.id):state(model_write):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-write"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  GuiElement.add(tableAdminPanel,GuiCheckBox( self.classname, "share-model=ID=delete", model.id):state(model_delete):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-delete"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))

  local count_block = Model.countBlocks()
  if count_block > 0 then
    -- info panel
    GuiElement.add(block_table, GuiLabel("label-power"):caption({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      GuiElement.add(block_table, GuiLabel("power"):caption(Format.formatNumberKilo(model.summary.energy or 0, "W")))
    end
  end

end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateInput
--
-- @param #LuaEvent event
--
function ProductionLineTab:updateInput(event)
  Logging:debug(self.classname, "updateInput", event)
  local model = Model.getModel()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  input_scroll.clear()
  -- input panel

  local count_block = Model.countBlocks()
  if count_block > 0 then

    local input_table = GuiElement.add(input_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    
    if model.ingredients ~= nil then
      for index, element in pairs(model.ingredients) do
        GuiElement.add(input_table, GuiCellElementM(self.classname, "production-block-add=ID", "new", element.name):element(element):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index))
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateOutput
--
-- @param #LuaEvent event
--
function ProductionLineTab:updateOutput(event)
  Logging:debug(self.classname, "updateOutput", event)
  local model = Model.getModel()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  output_scroll.clear()
  -- ouput panel

  -- production block result
  local count_block = Model.countBlocks()
  if count_block > 0 then

    -- ouput panel
    local output_table = GuiElement.add(output_scroll, GuiTable("output-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    if model.products ~= nil then
      for index, element in pairs(model.products) do
        GuiElement.add(output_table, GuiCellElementM(self.classname, "product-selected=ID", "new", element.name):element(element):tooltip("tooltip.product"):index(index))
      end
    end
    
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionLineTab] updateData
--
-- @param #LuaEvent event
--
function ProductionLineTab:updateData(event)
  Logging:debug(self.classname, "updateData()", event)
  local model = Model.getModel()

  self:updateInfo(event)
  self:updateOutput(event)
  self:updateInput(event)
  
  -- data panel
  local scroll_panel = self:getResultScrollPanel()

  local countBlock = Model.countBlocks()
  if countBlock > 0 then
    -- data panel
    local extra_cols = 0
    for _,parameter in pairs({"display_data_col_index","display_data_col_id","display_data_col_name"}) do
      if User.getModGlobalSetting(parameter) then
        extra_cols = extra_cols + 1
      end
    end
    
    local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(5 + extra_cols):style("helmod_table-odd"))
    result_table.style.horizontally_stretchable = false
    result_table.vertical_centering = false

    self:addTableHeader(result_table)

    local last_element = nil
    for _, element in spairs(model.blocks, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
      local element_cell = self:addTableRow(result_table, element)
      if User.getParameter("scroll_element") == element.id then last_element = element_cell end
    end
    
    if last_element ~= nil then
      scroll_panel.scroll_to_element(last_element)
      User.setParameter("scroll_element", nil)
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
function ProductionLineTab:addTableHeader(itable)
  Logging:debug(self.classname, "addTableHeader()")
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
function ProductionLineTab:addTableRow(gui_table, block)
  Logging:debug(self.classname, "addTableRow()", block)
  local model = Model.getModel()

  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end

  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", block.id):column(2))

  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-up=ID", block.id):sprite("menu", "arrow-up-white-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-remove=ID", block.id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-down=ID", block.id):sprite("menu", "arrow-down-white-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  if unlinked then
    GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink=ID", block.id):sprite("menu", "unlink-white-sm", "unlink-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.unlink-element"}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink=ID", block.id):sprite("menu", "link-white-sm", "link-sm"):style("helmod_button_menu_sm_selected"):tooltip({"tooltip.unlink-element"}))
  end

  -- col index
  if User.getModGlobalSetting("display_data_col_index") then
    GuiElement.add(gui_table, GuiCellLabel("cell_index", block.id):caption(block.index))
  end
  -- col id
  if User.getModGlobalSetting("display_data_col_id") then
    GuiElement.add(gui_table, GuiCellLabel("cell_id", block.id):caption(block.id))
  end
  -- col name
  if User.getModGlobalSetting("display_data_col_name") then
    GuiElement.add(gui_table, GuiCellLabel("cell_name", block.id):caption(block.name))
  end

  -- col recipe
  local cell_recipe = GuiElement.add(gui_table, GuiTable("recipe", block.id):column(1))
  GuiElement.add(cell_recipe, GuiCellBlock(self.classname, "change-tab=ID", "HMProductionBlockTab", block.id):element(block):tooltip("tooltip.edit-block"):color(GuiElement.color_button_default))

  -- col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable(block.id):column(1))
  GuiElement.add(cell_energy, GuiCellEnergy(self.classname, "change-tab=ID", "HMProductionBlockTab", block.id):element(block):tooltip("tooltip.edit-block"):color("gray"))
  
  -- products
  local display_product_cols = User.getModSetting("display_product_cols") + 1
  local cell_products = GuiElement.add(gui_table, GuiTable("products", block.id):column(display_product_cols))
  cell_products.style.horizontally_stretchable = false
  if block.products ~= nil then
    for index, product in pairs(block.products) do
      if product.state == 1 then
        if not(unlinked) or block.by_factory == true then
          GuiElement.add(cell_products, GuiCellElement(self.classname, "product-selected=ID", block.id, product.name):element(product):tooltip("tooltip.product"):index(index))
        else
          GuiElement.add(cell_products, GuiCellElement(self.classname, "product-edition=ID", block.id, product.name):element(product):tooltip("tooltip.edit-product"):color(GuiElement.color_button_edit):index(index))
        end
      elseif product.state == 3 then
        GuiElement.add(cell_products, GuiCellElement(self.classname, "product-selected=ID", block.id, product.name):element(product):tooltip("tooltip.rest-product"):color(GuiElement.color_button_rest):index(index))
      else
        GuiElement.add(cell_products, GuiCellElement(self.classname, "product-selected=ID", block.id, product.name):element(product):tooltip("tooltip.other-product"):index(index))
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = User.getModSetting("display_ingredient_cols") + 2
  local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients", block.id):column(display_ingredient_cols))
  cell_ingredients.style.horizontally_stretchable = false
  if block.ingredients ~= nil then
    for index, ingredient in pairs(block.ingredients) do
      GuiElement.add(cell_ingredients, GuiCellElement(self.classname, "production-block-add=ID", block.id, ingredient.name):element(ingredient):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index))
    end
  end
  return cell_recipe
end