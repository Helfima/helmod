require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ProductionBlockTab
-- @extends #AbstractTab
--

ProductionBlockTab = setclass("HMProductionBlockTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#ProductionBlockTab] getButtonCaption
--
-- @return #string
--
function ProductionBlockTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-production-block"}
end

-------------------------------------------------------------------------------
-- Update debug panel
--
-- @function [parent=#ProductionBlockTab] updateDebugPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:updateDebugPanel(item, item2, item3)
  Logging:debug("ProductionBlockTab", "updateDebugPanel():", item, item2, item3)
  local debug_panel = self.parent:getDebugPanel()
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()

  local blockId = globalGui.currentBlock or "new"
  local countRecipes = Model.countBlockRecipes(blockId)

  if countRecipes > 0 then

    local block = model.blocks[blockId]

    local input_table = ElementGui.addGuiTable(debug_panel,"input-data", 2 , "helmod_table-odd")
    self:addCellHeader(input_table, "title", "Input")
    self:addCellHeader(input_table, "value", {"helmod_result-panel.col-header-value"})

    if block.input ~= nil then
      for input_name,value in pairs(block.input) do
        ElementGui.addGuiLabel(input_table, input_name.."_title", input_name)
        ElementGui.addGuiLabel(input_table, input_name.."_value", value)
      end
    end

    local product_table = ElementGui.addGuiTable(debug_panel,"product-data", 3 , "helmod_table-odd")
    self:addCellHeader(product_table, "title", "Product")
    self:addCellHeader(product_table, "value", {"helmod_result-panel.col-header-value"})
    self:addCellHeader(product_table, "state", {"helmod_result-panel.col-header-state"})


    if block.products ~= nil then
      for _,product in pairs(block.products) do
        ElementGui.addGuiLabel(product_table, product.name.."_title", product.name)
        ElementGui.addGuiLabel(product_table, product.name.."_value", product.count)
        ElementGui.addGuiLabel(product_table, product.name.."_state", product.state)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionBlockTab] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:updateHeader(item, item2, item3)
  Logging:debug("ProductionBlockTab", "updateHeader():", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local menuPanel = self.parent:getMenuPanel()

  local blockId = globalGui.currentBlock or "new"

  local countRecipes = Model.countBlockRecipes(blockId)

  local info_panel = self.parent:getInfoPanel()
  -- info panel
  local block_panel = ElementGui.addGuiFrameV(info_panel, "block", helmod_frame_style.panel, ({"helmod_result-panel.tab-title-production-block"}))
  local block_scroll = ElementGui.addGuiScrollPane(block_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(block_scroll, "scroll_block", "height")
  local block_table = ElementGui.addGuiTable(block_scroll,"output-table",2)

  local element_panel = ElementGui.addGuiTable(info_panel, "elements", 1, helmod_table_style.panel)
  -- ouput panel
  local output_panel = ElementGui.addGuiFrameV(element_panel, "output", helmod_frame_style.panel, ({"helmod_common.output"}))
  output_panel.style.horizontally_stretchable = true
  ElementGui.setStyle(output_panel, "block_element", "height")
  local output_scroll = ElementGui.addGuiScrollPane(output_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(output_scroll, "scroll_block_element", "height")

  -- input panel
  local input_panel = ElementGui.addGuiFrameV(element_panel, "input", helmod_frame_style.panel, ({"helmod_common.input"}))
  ElementGui.setStyle(input_panel, "block_element", "height")
  local input_scroll = ElementGui.addGuiScrollPane(input_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(input_scroll, "scroll_block_element", "height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    -- block panel
    ElementGui.addGuiLabel(block_table, "label-power", ({"helmod_label.electrical-consumption"}))
    ElementGui.addGuiLabel(block_table, "power", Format.formatNumberKilo(element.power or 0, "W"),"helmod_label_right_70")

    ElementGui.addGuiLabel(block_table, "label-count", ({"helmod_label.block-number"}))
    ElementGui.addGuiLabel(block_table, "count", Format.formatNumberFactory(element.count or 0),"helmod_label_right_70")

    ElementGui.addGuiLabel(block_table, "label-sub-power", ({"helmod_label.sub-block-power"}))
    ElementGui.addGuiLabel(block_table, "sub-power", Format.formatNumberKilo(element.sub_power or 0),"helmod_label_right_70")

    ElementGui.addGuiLabel(block_table, "options-linked", ({"helmod_label.block-unlinked"}))
    local unlinked = element.unlinked and true or false
    if element.index == 0 then unlinked = true end
    ElementGui.addGuiCheckbox(block_table, self.parent:classname().."=change-boolean-option=ID=unlinked", unlinked)

    ElementGui.addGuiLabel(block_table, "options-by-factory", ({"helmod_label.compute-by-factory"}))
    local by_factory = element.by_factory and true or false
    ElementGui.addGuiCheckbox(block_table, self.parent:classname().."=change-boolean-option=ID=by_factory", by_factory)

    if element.by_factory == true then
      local factory_number = element.factory_number or 0
      ElementGui.addGuiLabel(block_table, "label-factory_number", ({"helmod_label.factory-number"}))
      ElementGui.addGuiText(block_table, "factory_number", factory_number, "helmod_textfield")
      ElementGui.addGuiButton(block_table, self.parent:classname().."=change-number-option=ID=", "factory_number", "helmod_button_default", ({"helmod_button.update"}))
    end

    -- ouput panel
    local output_table = ElementGui.addGuiTable(output_scroll,"output-table",6)
    if element.products ~= nil then
      for r, lua_product in pairs(element.products) do
        local product = Product.load(lua_product).new()
        product.count = lua_product.count
        if element.count > 1 then
          product.limit_count = lua_product.count / element.count
        end
        if bit32.band(lua_product.state, 1) > 0 then
          if element.by_factory == true then
            ElementGui.addCellElement(output_table, product, self.parent:classname().."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.product", nil)
          else
            ElementGui.addCellElement(output_table, product, self.parent:classname().."=product-edition=ID="..element.id.."="..product.name.."=", true, "tooltip.edit-product", self.color_button_edit)
          end
        end
        if bit32.band(lua_product.state, 2) > 0 and bit32.band(lua_product.state, 1) == 0 then
          ElementGui.addCellElement(output_table, product, self.parent:classname().."=product-selected=ID="..element.id.."="..product.name.."=", true, "tooltip.rest-product", self.color_button_rest)
        end
        if lua_product.state == 0 then
          ElementGui.addCellElement(output_table, product, self.parent:classname().."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.other-product", nil)
        end
      end
    end

    -- input panel

    local input_table = ElementGui.addGuiTable(input_scroll,"input-table",6)
    if element.ingredients ~= nil then
      for r, lua_product in pairs(element.ingredients) do
        local ingredient = Product.load(lua_product).new()
        ingredient.count = lua_product.count
        if element.count > 1 then
          ingredient.limit_count = lua_product.count / element.count
        end
        ElementGui.addCellElement(input_table, ingredient, self.parent:classname().."=product-selected=ID="..element.id.."="..ingredient.name.."=", false, "tooltip.ingredient", nil)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionBlockTab] updateData
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:updateData(item, item2, item3)
  Logging:debug("ProductionBlockTab", "updateData():", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  local blockId = "new"
  if globalGui.currentBlock ~= nil then
    blockId = globalGui.currentBlock
  end

  -- data panel
  local scrollPanel = self.parent:getResultScrollPanel({"helmod_common.recipes"})

  local countRecipes = Model.countBlockRecipes(blockId)
  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]
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
    if Player.getSettings("display_data_col_type", true) then
      extra_cols = extra_cols + 1
    end
    local resultTable = ElementGui.addGuiTable(scrollPanel,"list-data",7 + extra_cols, "helmod_table-odd")

    self:addTableHeader(resultTable)

    for _, recipe in spairs(model.blocks[blockId].recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(resultTable, element, recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#ProductionBlockTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function ProductionBlockTab.methods:addTableHeader(itable)
  Logging:debug("ProductionBlockTab", "addTableHeader():", itable)

  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(itable, "id", {"helmod_result-panel.col-header-id"},"id")
  self:addCellHeader(itable, "name", {"helmod_result-panel.col-header-name"},"name")
  self:addCellHeader(itable, "type", {"helmod_result-panel.col-header-type"},"type")
  -- data columns
  self:addCellHeader(itable, "recipe", {"helmod_result-panel.col-header-recipe"},"index")
  self:addCellHeader(itable, "energy", {"helmod_result-panel.col-header-energy"},"energy_total")
  self:addCellHeader(itable, "factory", {"helmod_result-panel.col-header-factory"})
  self:addCellHeader(itable, "beacon", {"helmod_result-panel.col-header-beacon"})
  self:addCellHeader(itable, "products", {"helmod_result-panel.col-header-products"})
  self:addCellHeader(itable, "ingredients", {"helmod_result-panel.col-header-ingredients"})
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#ProductionBlockTab] addTableRow
--
-- @param #LuaGuiElement gui_table
-- @param #table block
-- @param #table recipe production recipe
--
function ProductionBlockTab.methods:addTableRow(gui_table, block, recipe)
  Logging:debug("ProductionBlockTab", "addTableRow():", gui_table, block, recipe)
  local lua_recipe = RecipePrototype.load(recipe).native()
  local display_cell_mod = Player.getSettings("display_cell_mod")

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..recipe.id, 3)
  ElementGui.addGuiButton(cell_action, self.parent:classname().."=production-recipe-remove=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  ElementGui.addGuiButton(cell_action, self.parent:classname().."=production-recipe-down=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element", Player.getSettings("row_move_step")}))
  ElementGui.addGuiButton(cell_action, self.parent:classname().."=production-recipe-up=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element", Player.getSettings("row_move_step")}))

  -- col index
  if Player.getSettings("display_data_col_index", true) then
    ElementGui.addGuiLabel(gui_table, "value_index"..recipe.id, recipe.index, "helmod_label_row_right_40")
  end
  -- col id
  if Player.getSettings("display_data_col_id", true) then
    ElementGui.addGuiLabel(gui_table, "value_id"..recipe.id, recipe.id)
  end
  -- col name
  if Player.getSettings("display_data_col_name", true) then
    ElementGui.addGuiLabel(gui_table, "value_name"..recipe.id, recipe.name)
  end
  -- col type
  if Player.getSettings("display_data_col_type", true) then
    ElementGui.addGuiLabel(gui_table, "value_type"..recipe.id, recipe.type)
  end
  -- col recipe
  local production = recipe.production or 1
  local cell_recipe = ElementGui.addCellLabel(gui_table, "recipe-"..recipe.id, Format.formatPercent(production).."%", 35)
  self:addIconRecipeCell(cell_recipe, recipe, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)

  -- col energy
  local cell_nergy = ElementGui.addCellLabel(gui_table, "energy-"..recipe.id, Format.formatNumberKilo(recipe.energy_total, "W"), 60)

  -- col factory
  local factory = recipe.factory
  local cell_factory = ElementGui.addCell(gui_table, "factory-"..recipe.id)

  if block.count > 1 then
    ElementGui.addCellLabel2(cell_factory, "factory-"..recipe.id, Format.formatNumberFactory(factory.limit_count), Format.formatNumberFactory(factory.count))
  else
    ElementGui.addCellLabel(cell_factory, "factory-"..recipe.id, Format.formatNumberFactory(factory.limit_count))
  end
  ElementGui.addCellIcon(cell_factory, factory, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)
  local col_size = 2
  if display_cell_mod == "small-icon" then col_size = 5 end
  local cell_factory_module = ElementGui.addGuiTable(cell_factory,"factory-modules"..recipe.name, col_size, "helmod_factory_modules")
  -- modules
  for name, count in pairs(factory.modules) do
    for index = 1, count, 1 do
      ElementGui.addGuiButtonSpriteSm(cell_factory_module, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
      index = index + 1
    end
  end

  -- col beacon
  local beacon = recipe.beacon
  local cell_beacon = ElementGui.addCell(gui_table, "beacon-"..recipe.id)

  if block.count > 1 then
    ElementGui.addCellLabel2(cell_beacon, "beacon-"..recipe.id, Format.formatNumberFactory(beacon.limit_count), Format.formatNumberFactory(beacon.count))
  else
    ElementGui.addCellLabel(cell_beacon, "beacon-"..recipe.id, Format.formatNumberFactory(beacon.limit_count))
  end
  ElementGui.addCellIcon(cell_beacon, beacon, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)

  local col_size = 1
  if display_cell_mod == "small-icon" then col_size = 5 end
  local cell_beacon_module = ElementGui.addGuiTable(cell_beacon,"beacon-modules"..recipe.name, col_size, "helmod_beacon_modules")
  -- modules
  for name, count in pairs(beacon.modules) do
    for index = 1, count, 1 do
      ElementGui.addGuiButtonSpriteSm(cell_beacon_module, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
      index = index + 1
    end
  end

  -- products
  local display_product_cols = Player.getSettings("display_product_cols")
  local cell_products = ElementGui.addCell(gui_table,"products_"..recipe.id, display_product_cols)
  for r, lua_product in pairs(RecipePrototype.getProducts()) do
    local product = Product.load(lua_product).new()
    product.count = Product.countProduct(recipe)
    if block.count > 1 then
      product.limit_count = product.count / block.count
    end
    ElementGui.addCellElement(cell_products, product, self.parent:classname().."=product-selected=ID="..block.id.."="..recipe.name.."=", false, "tooltip.product", nil)
  end

  -- ingredients
  local display_ingredient_cols = Player.getSettings("display_ingredient_cols")
  local cell_ingredients = ElementGui.addCell(gui_table,"ingredients_"..recipe.id, display_ingredient_cols)
  for r, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
    local ingredient = Product.load(lua_ingredient).new()
    ingredient.count = Product.countIngredient(recipe)
    if block.count > 1 then
      ingredient.limit_count = ingredient.count / block.count
    end
    ElementGui.addCellElement(cell_ingredients, ingredient, self.parent:classname().."=production-recipe-add=ID="..block.id.."="..recipe.name.."=", true, "tooltip.add-recipe", self.color_button_add)
  end
end
