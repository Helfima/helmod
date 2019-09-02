require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ProductionBlockTab
-- @extends #AbstractTab
--

ProductionBlockTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#ProductionBlockTab] getButtonCaption
--
-- @return #string
--
function ProductionBlockTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-production-block"}
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#ProductionBlockTab] isVisible
--
-- @return boolean
--
function ProductionBlockTab:isVisible()
  return false
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#ProductionBlockTab] hasIndexModel
--
-- @return #boolean
--
function ProductionBlockTab:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Before update
--
-- @function [parent=#ProductionBlockTab] beforeUpdate
--
-- @param #LuaEvent event
--
function ProductionBlockTab:beforeUpdate(event)
  Logging:trace(self.classname, "beforeUpdate()", event)
end

-------------------------------------------------------------------------------
-- Update debug panel
--
-- @function [parent=#ProductionBlockTab] updateDebugPanel
--
-- @param #LuaEvent event
--
function ProductionBlockTab:updateDebugPanel(event)
  Logging:debug("ProductionBlockTab", "updateDebugPanel()", event)
  local header_panel1, header_panel2,scroll_panel1, scroll_panel2 = self:getResultScrollPanel2({"helmod_result-panel.tab-button-production-block"})
  local model = Model.getModel()

  local current_block = User.getParameter("current_block") or "new"

  local countRecipes = Model.countBlockRecipes(current_block)

  if countRecipes > 0 then

    local block = model.blocks[current_block]

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


    if block.matrix ~= nil then
      -- matrix A
      local ma_panel = ElementGui.addGuiFrameV(scroll_panel2, "ma_panel", helmod_frame_style.hidden, "Matrix A")
      self:buildMatrix(ma_panel, block.matrix.mA, block.matrix.row_headers, block.matrix.col_headers)

      if block.matrix.mB then
        local col_headers2 = {}
        for _,col_header in pairs(block.matrix.col_headers) do
          table.insert(col_headers2,col_header)
        end
        if block.solver == true then
          table.insert(col_headers2,{name="T", type="none"})
          for i,row_header in pairs(block.matrix.row_headers) do
            if i > 1 and i < #block.matrix.row_headers then
              table.insert(col_headers2,row_header)
            end
          end
        end

        local row_headers2 = {}
        if block.solver == true then
          table.insert(row_headers2,{name="input", type="none"})
          for i=1, (#block.matrix.mB - 3) do
            table.insert(row_headers2,{name="", type="none"})
          end
          table.insert(row_headers2,{name="T", type="none"})
        else
          for i,row_header in pairs(block.matrix.row_headers) do
            if i < #block.matrix.row_headers then
              table.insert(row_headers2,row_header)
            end
          end
        end
        table.insert(row_headers2,{name="Z", type="none"})

        -- matrix B
        local mb_panel = ElementGui.addGuiFrameV(scroll_panel2, "mb_panel", helmod_frame_style.hidden, "Matrix B")
        self:buildMatrix(mb_panel, block.matrix.mB, row_headers2, col_headers2)

        local row_headers2 = {}
        table.insert(row_headers2,{name="State", type="none"})
        for i,row_header in pairs(block.matrix.row_headers) do
          if i < #block.matrix.row_headers then
            table.insert(row_headers2,row_header)
          end
        end
        table.insert(row_headers2,{name="Z", type="none"})

        -- matrix C
        local mc_panel = ElementGui.addGuiFrameV(scroll_panel2, "mc_panel", helmod_frame_style.hidden, "Matrix C")
        self:buildMatrix(mc_panel, block.matrix.mC, row_headers2, block.matrix.col_headers)
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
function ProductionBlockTab:buildMatrix(matrix_panel, matrix, row_headers, col_headers)
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
-- Update info
--
-- @function [parent=#ProductionBlockTab] updateInfo
--
-- @param #LuaEvent event
--
function ProductionBlockTab:updateInfo(event)
  Logging:debug(self.classname, "updateInfo", event)
  local model = Model.getModel()
  Logging:debug(self.classname, "model:", model)
  -- data
  local current_block = User.getParameter("current_block") or "new"

  local countRecipes = Model.countBlockRecipes(current_block)

  local info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  info_scroll.clear()
  -- info panel

  local block_table = ElementGui.addGuiTable(info_scroll,"output-table",4)
  block_table.style.horizontal_spacing=10

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[current_block]

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
    ElementGui.addGuiCheckbox(block_table, self.classname.."=change-boolean-option=ID=unlinked", unlinked)

    ElementGui.addGuiLabel(block_table, "options-by-factory", ({"helmod_label.compute-by-factory"}))
    local by_factory = element.by_factory and true or false
    ElementGui.addGuiCheckbox(block_table, self.classname.."=change-boolean-option=ID=by_factory", by_factory)

    if element.by_factory == true then
      local factory_number = element.factory_number or 0
      ElementGui.addGuiLabel(block_table, "label-factory_number", ({"helmod_label.factory-number"}))
      ElementGui.addGuiText(block_table, self.classname.."=change-number-option=ID=factory_number", factory_number, "helmod_textfield")
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionBlockTab] updateInput
--
-- @param #LuaEvent event
--
function ProductionBlockTab:updateInput(event)
  Logging:debug(self.classname, "updateInput", event)
  local model = Model.getModel()
  Logging:debug(self.classname, "model:", model)
  -- data
  local current_block = User.getParameter("current_block") or "new"

  local countRecipes = Model.countBlockRecipes(current_block)

  local info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  input_scroll.clear()
  -- input panel

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[current_block]
    -- input panel
    local input_table = ElementGui.addGuiTable(input_scroll,"input-table", ElementGui.getElementColumnNumber(50)-2, "helmod_table_element")
    if element.ingredients ~= nil then
      for index, lua_product in pairs(element.ingredients) do
        local ingredient = Product.load(lua_product).new()
        ingredient.count = lua_product.count
        if element.count > 1 then
          ingredient.limit_count = lua_product.count / element.count
        end
        ElementGui.addCellElementM(input_table, ingredient, self.classname.."=production-recipe-add=ID="..current_block.."="..element.name.."=", true, "tooltip.ingredient", ElementGui.color_button_add, index)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionBlockTab] updateOutput
--
-- @param #LuaEvent event
--
function ProductionBlockTab:updateOutput(event)
  Logging:debug(self.classname, "updateOutput", event)
  local model = Model.getModel()
  Logging:debug(self.classname, "model:", model)
  -- data
  local current_block = User.getParameter("current_block") or "new"

  local countRecipes = Model.countBlockRecipes(current_block)

  local info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  output_scroll.clear()
  -- ouput panel

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[current_block]

    -- ouput panel
    local output_table = ElementGui.addGuiTable(output_scroll,"output-table", ElementGui.getElementColumnNumber(50)-2, "helmod_table_element")
    if element.products ~= nil then
      for index, lua_product in pairs(element.products) do
        local product = Product.load(lua_product).new()
        product.count = lua_product.count
        if element.count > 1 then
          product.limit_count = lua_product.count / element.count
        end
        if lua_product.state == 1 then
          if not(element.unlinked) or element.by_factory == true then
            ElementGui.addCellElementM(output_table, product, self.classname.."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.product", nil, index)
          else
            ElementGui.addCellElementM(output_table, product, self.classname.."=product-edition=ID="..element.id.."="..product.name.."=", true, "tooltip.edit-product", ElementGui.color_button_edit, index)
          end
        elseif lua_product.state == 3 then
          ElementGui.addCellElementM(output_table, product, self.classname.."=product-selected=ID="..element.id.."="..product.name.."=", true, "tooltip.rest-product", ElementGui.color_button_rest, index)
        else
          ElementGui.addCellElementM(output_table, product, self.classname.."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.other-product", nil, index)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionBlockTab] updateData
--
-- @param #LuaEvent event
--
function ProductionBlockTab:updateData(event)
  Logging:debug("ProductionBlockTab", "updateData()", event)
  local model = Model.getModel()
  Logging:debug("ProductionBlockTab", "model:", model)
  local current_block = User.getParameter("current_block") or "new"

  self:updateInfo(event)
  self:updateOutput(event)
  self:updateInput(event)

  -- data panel
  local header_panel1, header_panel2,scroll_panel1, scroll_panel2 = self:getResultScrollPanel2({"helmod_result-panel.tab-button-production-block"})

  local back_button = ElementGui.addGuiButton(header_panel1,self.classname.."=change-tab=ID=","HMProductionLineTab","back_button","Back")
  back_button.style.width = 70

  local recipe_table = ElementGui.addGuiTable(scroll_panel1,"recipe-data",1)
  recipe_table.vertical_centering = false

  local last_element = nil
  -- col recipe
  local color = "gray"
  local cell_recipe = ElementGui.addCell(recipe_table, "recipe-new")
  if current_block == "new" then
    last_element = cell_recipe
    color = "orange"
  end
  local block_new = {name = "helmod_button_icon_robot_flat2" ,count = 0,localised_name = "helmod_result-panel.add-button-production-block"}
  ElementGui.addCellProduct(cell_recipe, block_new, self.classname.."=change-tab=ID=HMProductionBlockTab=new=", true, "tooltip.edit-block", color)

  for _, block in spairs(model.blocks, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
    -- col recipe
    local color = "gray"
    local cell_recipe = ElementGui.addCell(recipe_table, "recipe"..block.id)
    if current_block == block.id then
      last_element = cell_recipe
      color = "orange"
    end
    ElementGui.addCellBlock(cell_recipe, block, self.classname.."=change-tab=ID=HMProductionBlockTab="..block.id.."=", true, "tooltip.edit-block", color)
  end
  if last_element ~= nil then
    scroll_panel1.scroll_to_element(last_element)
  end

  local countRecipes = Model.countBlockRecipes(current_block)
  -- production block result
  if countRecipes > 0 then

    local elements = model.blocks[current_block]
    -- data panel

    local extra_cols = 0
    for _,parameter in pairs({"display_data_col_index","display_data_col_id","display_data_col_name","display_data_col_type"}) do
      if User.getModGlobalSetting(parameter) then
        extra_cols = extra_cols + 1
      end
    end
    local result_table = ElementGui.addGuiTable(scroll_panel2,"list-data",7 + extra_cols, "helmod_table-odd")
    result_table.vertical_centering = false
    self:addTableHeader(result_table)

    local last_element = nil
    for _, recipe in spairs(elements.recipes, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
      last_element = self:addTableRow(result_table, elements, recipe)
    end

    if User.getParameter("scroll_down") then
      scroll_panel2.scroll_to_element(last_element)
      User.setParameter("scroll_down", false)
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
function ProductionBlockTab:addTableHeader(itable)
  Logging:debug("ProductionBlockTab", "addTableHeader()", itable)

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
function ProductionBlockTab:addTableRow(gui_table, block, recipe)
  Logging:debug("ProductionBlockTab", "addTableRow()", gui_table, block, recipe)
  local lua_recipe = RecipePrototype.load(recipe).native()

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..recipe.id, 2)
  ElementGui.addGuiButton(cell_action, self.classname.."=production-recipe-up=ID="..block.id.."=", recipe.id, "helmod_button_icon_arrow_top_sm", nil, ({"tooltip.up-element", User.getModSetting("row_move_step")}))
  ElementGui.addGuiButton(cell_action, self.classname.."=production-recipe-remove=ID="..block.id.."=", recipe.id, "helmod_button_icon_delete_sm_red", nil, ({"tooltip.remove-element"}))
  ElementGui.addGuiButton(cell_action, self.classname.."=production-recipe-down=ID="..block.id.."=", recipe.id, "helmod_button_icon_arrow_down_sm", nil, ({"tooltip.down-element", User.getModSetting("row_move_step")}))

  -- col index
  if User.getModGlobalSetting("display_data_col_index") then
    ElementGui.addGuiLabel(gui_table, "value_index"..recipe.id, recipe.index, "helmod_label_row_right_40")
  end
  -- col id
  if User.getModGlobalSetting("display_data_col_id") then
    ElementGui.addGuiLabel(gui_table, "value_id"..recipe.id, recipe.id)
  end
  -- col name
  if User.getModGlobalSetting("display_data_col_name") then
    ElementGui.addGuiLabel(gui_table, "value_name"..recipe.id, recipe.name)
  end
  -- col type
  if User.getModGlobalSetting("display_data_col_type") then
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
  local display_product_cols = User.getModSetting("display_product_cols")
  local cell_products = ElementGui.addCell(gui_table,"products_"..recipe.id, display_product_cols)
  for index, lua_product in pairs(RecipePrototype.getProducts()) do
    local product = Product.load(lua_product).new()
    product.count = Product.countProduct(recipe)
    if block.count > 1 then
      product.limit_count = product.count / block.count
    end
    ElementGui.addCellElement(cell_products, product, self.classname.."=product-selected=ID="..block.id.."="..recipe.name.."=", false, "tooltip.product", nil, index)
  end

  -- ingredients
  local display_ingredient_cols = User.getModSetting("display_ingredient_cols")
  local cell_ingredients = ElementGui.addCell(gui_table,"ingredients_"..recipe.id, display_ingredient_cols)
  for index, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
    local ingredient = Product.load(lua_ingredient).new()
    ingredient.count = Product.countIngredient(recipe)
    if block.count > 1 then
      ingredient.limit_count = ingredient.count / block.count
    end
    ElementGui.addCellElement(cell_ingredients, ingredient, self.classname.."=production-recipe-add=ID="..block.id.."="..recipe.name.."=", true, "tooltip.add-recipe", ElementGui.color_button_add, index)
  end

  return cell_recipe
end
