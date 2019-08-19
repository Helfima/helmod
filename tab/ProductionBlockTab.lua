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
-- Is visible
--
-- @function [parent=#ProductionBlockTab] isVisible
--
-- @return boolean
--
function ProductionBlockTab.methods:isVisible()
  return false
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#ProductionBlockTab] hasIndexModel
--
-- @return #boolean
--
function ProductionBlockTab.methods:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Before update
--
-- @function [parent=#ProductionBlockTab] beforeUpdate
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:beforeUpdate(item, item2, item3)
  Logging:trace(self:classname(), "beforeUpdate():", item, item2, item3)
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
  local header_panel1, header_panel2,scroll_panel1, scroll_panel2 = self:getResultScrollPanel2({"helmod_result-panel.tab-button-production-block"})
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()

  local blockId = globalGui.currentBlock or "new"
  local countRecipes = Model.countBlockRecipes(blockId)

  if countRecipes > 0 then

    local block = model.blocks[blockId]

    -- input
    local input_panel = ElementGui.addGuiFrameV(scroll_panel2, "input_panel", helmod_frame_style.hidden, "Input data")
    local input_table = ElementGui.addGuiTable(input_panel,"input-data", 2 , "helmod_table-odd")
    self:addCellHeader(input_table, "title", "Input")
    self:addCellHeader(input_table, "value", {"helmod_result-panel.col-header-value"})

    if block.input ~= nil then
      for input_name,value in pairs(block.input) do
        ElementGui.addGuiLabel(input_table, input_name.."_title", input_name)
        ElementGui.addGuiLabel(input_table, input_name.."_value", value)
      end
    end

    -- product
    local product_panel = ElementGui.addGuiFrameV(scroll_panel2, "product_panel", helmod_frame_style.hidden, "Product data")
    local product_table = ElementGui.addGuiTable(product_panel,"product-data", 3 , "helmod_table-odd")
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


    if block.solver == true then
      -- *** Simplex Method ***
      if block.matrix2 ~= nil then
        -- matrix A
        local ma_panel = ElementGui.addGuiFrameV(scroll_panel2, "ma_panel", helmod_frame_style.hidden, "Matrix A")
        self:buildMatrix(ma_panel, block.matrix2.mA, block.matrix2.row_headers, block.matrix2.col_headers)

        if block.matrix2.mB then
          local col_headers2 = {}
          for _,col_header in pairs(block.matrix2.col_headers) do
            table.insert(col_headers2,col_header)
          end
          table.insert(col_headers2,{name="T", type="none"})
          for i,row_header in pairs(block.matrix2.row_headers) do
            if i > 1 and i < #block.matrix2.row_headers then
              table.insert(col_headers2,row_header)
            end
          end
          local row_headers2 = {}
          for i,row_header in pairs(block.matrix2.row_headers) do
            if i < #block.matrix2.row_headers then
              table.insert(row_headers2,row_header)
            end
          end
          for i,row_header in pairs(block.matrix2.mB) do
            if i > #block.matrix2.row_headers then
              table.insert(row_headers2,{name="", type="none"})
            end
          end
          table.insert(row_headers2,{name="Z", type="none"})

          -- matrix B
          local mb_panel = ElementGui.addGuiFrameV(scroll_panel2, "mb_panel", helmod_frame_style.hidden, "Matrix B")
          self:buildMatrix(mb_panel, block.matrix2.mB, row_headers2, col_headers2)

          -- matrix C
          row_headers2 = {}
          table.insert(row_headers2,{name="State", type="none"})
          for _,col_header in pairs(block.matrix2.row_headers) do
            table.insert(row_headers2,col_header)
          end
          
          local mc_panel = ElementGui.addGuiFrameV(scroll_panel2, "mc_panel", helmod_frame_style.hidden, "Matrix C")
          self:buildMatrix(mc_panel, block.matrix2.mC, row_headers2, block.matrix2.col_headers)
        end
      end
    else
      -- *** Normal Method ***
      if block.matrix1 ~= nil then
        -- matrix A
        local ma_panel = ElementGui.addGuiFrameV(scroll_panel2, "ma_panel", helmod_frame_style.hidden, "Matrix A")
        self:buildMatrix(ma_panel, block.matrix1.mA, block.matrix1.row_headers, block.matrix1.col_headers)

        if block.matrix1.mB then
          -- matrix B
          local mb_panel = ElementGui.addGuiFrameV(scroll_panel2, "mb_panel", helmod_frame_style.hidden, "Matrix B")
          self:buildMatrix(mb_panel, block.matrix1.mB, block.matrix1.row_headers, block.matrix1.col_headers)

          local row_headers2 = {}
          table.insert(row_headers2,{name="State", type="none"})
          for _,col_header in pairs(block.matrix1.row_headers) do
            table.insert(row_headers2,col_header)
          end

          -- matrix C
          local mc_panel = ElementGui.addGuiFrameV(scroll_panel2, "mc_panel", helmod_frame_style.hidden, "Matrix C")
          self:buildMatrix(mc_panel, block.matrix1.mC, row_headers2, block.matrix1.col_headers)
        end
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Build matrix
--
-- @function [parent=#ProductionBlockTab] buildMatrix
--
-- @param #string #ElementGui matrix_panel
-- @param #string #block block
--
function ProductionBlockTab.methods:buildMatrix(matrix_panel, matrix, row_headers, col_headers)
  Logging:debug("ProductionBlockTab", "buildMatrix()")
  if matrix ~= nil then
    local num_col = #matrix[1]
    local num_row_header = #row_headers
    local num_col_header = Model.countList(col_headers)

    local matrix_table = ElementGui.addGuiTable(matrix_panel,"matrix_data", num_col+1 , "helmod_table-odd")
    ElementGui.addGuiLabel(matrix_table, "recipes", "B")

    for col_name,col_header in pairs(col_headers) do
      if col_header.type == "none" then
        ElementGui.addGuiLabel(matrix_table, "nothing_col_"..col_name, col_header.name)
      else
        ElementGui.addGuiButtonSprite(matrix_table, "nothing_col_"..col_name, col_header.type, col_header.name, nil, col_header.tooltip)
      end
    end

    for i,row in pairs(matrix) do
      local row_header = row_headers[i]
      if row_header == nil then
        ElementGui.addGuiLabel(matrix_table, "nothing_row_"..i, "nil")
      else
        if row_header.type == "none" then
          ElementGui.addGuiLabel(matrix_table, "nothing_row_"..i, row_header.name)
        else
          ElementGui.addGuiButtonSprite(matrix_table, "nothing_row_"..i, row_header.type, row_header.name, nil, row_header.tooltip)
        end
      end
      for j,value in pairs(row) do
        ElementGui.addGuiLabel(matrix_table, i.."-"..j.."_value", Format.formatNumber(value,4))
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
  local block_id = "new"
  if globalGui.currentBlock ~= nil then
    block_id = globalGui.currentBlock
  end

  -- data panel
  local header_panel1, header_panel2,scroll_panel1, scroll_panel2 = self:getResultScrollPanel2({"helmod_result-panel.tab-button-production-block"})
  
  local back_button = ElementGui.addGuiButton(header_panel1,"HMMainMenuPanel=change-tab=ID=","HMProductionLineTab","back_button","Back")
  back_button.style.width = 70
  
  local recipe_table = ElementGui.addGuiTable(scroll_panel1,"recipe-data",1)
  recipe_table.vertical_centering = false

  local last_element = nil
  -- col recipe
  local color = "gray"
  local cell_recipe = ElementGui.addCell(recipe_table, "recipe-new")
  if block_id == "new" then
    last_element = cell_recipe
    color = "orange"
  end
  local block_new = {name = "helmod_button_icon_edit_flat2" ,count = 0,localised_name = "helmod_result-panel.add-button-production-block"}
  ElementGui.addCellProduct(cell_recipe, block_new, self:classname().."=change-tab=ID=HMProductionBlockTab=new=", true, "tooltip.edit-block", color)
  
  for _, block in spairs(model.blocks, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
    -- col recipe
    local color = "gray"
    local cell_recipe = ElementGui.addCell(recipe_table, "recipe"..block.id)
    if block_id == block.id then
      last_element = cell_recipe
      color = "orange"
    end
    ElementGui.addCellBlock(cell_recipe, block, self:classname().."=change-tab=ID=HMProductionBlockTab="..block.id.."=", true, "tooltip.edit-block", color)
  end
  if last_element ~= nil then
    scroll_panel1.scroll_to_element(last_element)
  end
  
  local countRecipes = Model.countBlockRecipes(block_id)
  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[block_id]
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
    local result_table = ElementGui.addGuiTable(scroll_panel2,"list-data",7 + extra_cols, "helmod_table-odd")
    result_table.vertical_centering = false
    self:addTableHeader(result_table)

    local last_element = nil
    for _, recipe in spairs(model.blocks[block_id].recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      last_element = self:addTableRow(result_table, element, recipe)
    end

    if globalGui["scroll_down"] then
      scroll_panel2.scroll_to_element(last_element)
      globalGui["scroll_down"] = false
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionBlockTab] updateData2
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:updateData2(item, item2, item3)
  Logging:debug("ProductionBlockTab", "updateData():", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug("ProductionBlockTab", "model:", model)
  local blockId = "new"
  if globalGui.currentBlock ~= nil then
    blockId = globalGui.currentBlock
  end

  -- data panel
  local scrollPanel = self:getResultScrollPanel({"helmod_result-panel.tab-button-production-block"})

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
    local result_table = ElementGui.addGuiTable(scrollPanel,"list-data",7 + extra_cols, "helmod_table-odd")
    result_table.vertical_centering = false
    self:addTableHeader(result_table)

    local last_element = nil
    for _, recipe in spairs(model.blocks[blockId].recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      last_element = self:addTableRow(result_table, element, recipe)
    end

    if globalGui["scroll_down"] then
      scrollPanel.scroll_to_element(last_element)
      globalGui["scroll_down"] = false
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
  local cell_action = ElementGui.addCell(gui_table, "action"..recipe.id, 2)
  ElementGui.addGuiButton(cell_action, self:classname().."=production-recipe-up=ID="..block.id.."=", recipe.id, "helmod_button_icon_arrow_top_sm", nil, ({"tooltip.up-element", Player.getSettings("row_move_step")}))
  ElementGui.addGuiButton(cell_action, self:classname().."=production-recipe-remove=ID="..block.id.."=", recipe.id, "helmod_button_icon_delete_sm_red", nil, ({"tooltip.remove-element"}))
  ElementGui.addGuiButton(cell_action, self:classname().."=production-recipe-down=ID="..block.id.."=", recipe.id, "helmod_button_icon_arrow_down_sm", nil, ({"tooltip.down-element", Player.getSettings("row_move_step")}))

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
  --  local production = recipe.production or 1
  --  local production_label = Format.formatPercent(production).."%"
  --  if block.solver == true then production_label = "" end
  local cell_recipe = ElementGui.addCell(gui_table, "recipe-"..recipe.id)
  ElementGui.addCellRecipe(cell_recipe, recipe, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", "gray")

  -- col energy
  local cell_energy = ElementGui.addCell(gui_table, "energy-"..recipe.id)
  ElementGui.addCellEnergy(cell_energy, recipe, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", "gray")

  -- col factory
  local factory = recipe.factory
  if block.count > 1 then
    factory.limit_count = factory.count / block.count
  else
    factory.limit_count = nil
  end
  local cell_factory = ElementGui.addCell(gui_table, "factory-"..recipe.id)
  ElementGui.addCellFactory(cell_factory, factory, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", false, "tooltip.edit-recipe", "gray")

  -- col beacon
  local beacon = recipe.beacon
  if block.count > 1 then
    beacon.limit_count = factory.count / block.count
  else
    beacon.limit_count = nil
  end
  local cell_beacon = ElementGui.addCell(gui_table, "beacon-"..recipe.id)
  ElementGui.addCellFactory(cell_beacon, beacon, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", false, "tooltip.edit-recipe", "gray")

  -- products
  local display_product_cols = Player.getSettings("display_product_cols")
  local cell_products = ElementGui.addCell(gui_table,"products_"..recipe.id, display_product_cols)
  for index, lua_product in pairs(RecipePrototype.getProducts()) do
    local product = Product.load(lua_product).new()
    product.count = Product.countProduct(recipe)
    if block.count > 1 then
      product.limit_count = product.count / block.count
    end
    ElementGui.addCellElement(cell_products, product, self:classname().."=product-selected=ID="..block.id.."="..recipe.name.."=", false, "tooltip.product", nil, index)
  end

  -- ingredients
  local display_ingredient_cols = Player.getSettings("display_ingredient_cols")
  local cell_ingredients = ElementGui.addCell(gui_table,"ingredients_"..recipe.id, display_ingredient_cols)
  for index, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
    local ingredient = Product.load(lua_ingredient).new()
    ingredient.count = Product.countIngredient(recipe)
    if block.count > 1 then
      ingredient.limit_count = ingredient.count / block.count
    end
    ElementGui.addCellElement(cell_ingredients, ingredient, self:classname().."=production-recipe-add=ID="..block.id.."="..recipe.name.."=", true, "tooltip.add-recipe", ElementGui.color_button_add, index)
  end

  return cell_recipe
end
