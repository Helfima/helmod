require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module ProductionBlockTab
-- @extends #AbstractTab
--

ProductionBlockTab = newclass(AbstractTab,function(base,classname)
  AbstractTab.init(base,classname)
end)

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
    local input_panel = GuiElement.add(scroll_panel2, GuiFrameV("input_panel"):style(helmod_frame_style.hidden):caption("Input data"))
    local input_table = GuiElement.add(input_panel, GuiTable("input-data"):column(2):style("helmod_table-odd"))
    self:addCellHeader(input_table, "title", "Input")
    self:addCellHeader(input_table, "value", {"helmod_result-panel.col-header-value"})

    if block.input ~= nil then
      for input_name,value in pairs(block.input) do
        GuiElement.add(input_table, GuiLabel(input_name, "title"):caption(input_name))
        GuiElement.add(input_table, GuiLabel(input_name, "value"):caption(value))
      end
    end

    -- product
    local product_panel = GuiElement.add(scroll_panel2, GuiFrameV("product_panel"):style(helmod_frame_style.hidden):caption("Product data"))
    local product_table = GuiElement.add(product_panel, GuiTable("product-data"):column(3):style("helmod_table-odd"))
    self:addCellHeader(product_table, "title", "Product")
    self:addCellHeader(product_table, "value", {"helmod_result-panel.col-header-value"})
    self:addCellHeader(product_table, "state", {"helmod_result-panel.col-header-state"})


    if block.products ~= nil then
      for _,product in pairs(block.products) do
        GuiElement.add(product_table, GuiLabel(product.name, "title"):caption(product.name))
        GuiElement.add(product_table, GuiLabel(product.name, "value"):caption(product.count))
        GuiElement.add(product_table, GuiLabel(product.name, "state"):caption(product.state))
      end
    end


    if block.matrix ~= nil then
      -- matrix A
      local ma_panel = GuiElement.add(scroll_panel2, GuiFrameV("ma_panel"):style(helmod_frame_style.hidden):caption("Matrix A"))
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
        local mb_panel = GuiElement.add(scroll_panel2, GuiFrameV("mb_panel"):style(helmod_frame_style.hidden):caption("Matrix B"))
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
        local mc_panel = GuiElement.add(scroll_panel2, GuiFrameV("mc_panel"):style(helmod_frame_style.hidden):caption("Matrix C"))
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
-- @param #GuiElement matrix_panel
-- @param #table matrix
-- @param #table row_headers
-- @param #table col_headers
--
function ProductionBlockTab:buildMatrix(matrix_panel, matrix, row_headers, col_headers)
  Logging:debug("ProductionBlockTab", "buildMatrix()")
  if matrix ~= nil then
    local num_col = #matrix[1]
    local num_row_header = #row_headers
    local num_col_header = Model.countList(col_headers)

    local matrix_table = GuiElement.add(matrix_panel, GuiTable("matrix_data"):column(num_col+1):style("helmod_table-odd"))
    GuiElement.add(matrix_table, GuiLabel("recipes"):caption("B"))

    for col_name,col_header in pairs(col_headers) do
      if col_header.type == "none" then
        GuiElement.add(matrix_table, GuiLabel("nothing_col", col_name):caption(col_header.name))
      else
        GuiElement.add(matrix_table, GuiButtonSprite("nothing_col", col_name):sprite(col_header.type, col_header.name):tooltip(col_header.tooltip))
      end
    end

    for i,row in pairs(matrix) do
      local row_header = row_headers[i]
      if row_header == nil then
        GuiElement.add(matrix_table, GuiLabel("nothing_row", i):caption("nil"))
      else
        if row_header.type == "none" then
          GuiElement.add(matrix_table, GuiLabel("nothing_row", i):caption(row_header.name))
        else
          GuiElement.add(matrix_table, GuiButtonSprite("nothing_row", i):sprite(row_header.type, row_header.name):tooltip(row_header.tooltip))
        end
      end
      for j,value in pairs(row) do
        GuiElement.add(matrix_table, GuiLabel(i, j, "value"):caption(Format.formatNumber(value,4)))
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

  local options_scroll, info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  options_scroll.clear()
  info_scroll.clear()
  -- info panel

  local block_table = GuiElement.add(info_scroll, GuiTable("output-table"):column(2))
  block_table.style.horizontally_stretchable = false
  block_table.vertical_centering = false
  block_table.style.horizontal_spacing=10

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[current_block]

    -- block panel
    GuiElement.add(block_table, GuiCellBlockInfo("block-count"):element(element):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(1))
    GuiElement.add(block_table, GuiCellEnergy("block-power"):element(element):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(2))

    local unlink_state = "right"
    if element.unlinked == true then unlink_state = "left" end
    local unlink_switch = GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-unlink=ID", current_block):state(unlink_state):leftLabel({"helmod_label.block-unlinked"}):rightLabel({"helmod_label.block-linked"}))
    if element.index == 0 then
      unlink_switch.enabled = false
      unlink_switch.tooltip = "First block can't link"
    end
    if element.by_factory == true then
      unlink_switch.enabled = false
      unlink_switch.tooltip = "By factory block can't link"
    end

    local element_state = "left"
    if element.by_product == false then element_state = "right" end
    GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-element=ID", current_block):state(element_state):leftLabel({"helmod_label.input-product"}):rightLabel({"helmod_label.input-ingredient"}))

    local by_factory_state = "left"
    if element.by_factory == true then by_factory_state = "right" end
    GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-factory=ID", current_block):state(by_factory_state):leftLabel({"helmod_label.compute-by-element"}):rightLabel({"helmod_label.compute-by-factory"}))

    if element.by_factory == true then
      local by_factory_panel = GuiElement.add(options_scroll, GuiFlowH("by_factory_panel"))
      by_factory_panel.style.horizontal_spacing=10
      local factory_number = element.factory_number or 0
      GuiElement.add(by_factory_panel, GuiLabel("label-factory_number"):caption({"helmod_label.factory-number"}))
      GuiElement.add(by_factory_panel, GuiTextField(self.classname, "change-number-option=ID", "factory_number"):text(factory_number):style("helmod_textfield"))
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
  local model = Model.getModel()
  -- data
  local current_block = User.getParameter("current_block") or "new"
  local block = model.blocks[current_block]
  local block_by_product = not(block ~= nil and block.by_product == false)

  local countRecipes = Model.countBlockRecipes(current_block)

  local left_label, left_tool, left_scroll = self:getLeftInfoPanel2()
  local right_label, right_tool, right_scroll = self:getRightInfoPanel2()

  local input_label = right_label
  local input_tool = right_tool
  local input_scroll = right_scroll
  if not(block_by_product) then
    input_label = left_label
    input_scroll = left_scroll
    input_tool = left_tool
  end

  input_tool.clear()
  local all_visible = User.getParameter("block_all_ingredient_visible")
  local style_visible = "helmod_button_menu_sm"
  if all_visible == true then
    style_visible = "helmod_button_menu_sm_selected"
  end
  GuiElement.add(input_tool, GuiButton(self.classname, "block-all-ingredient-visible=ID", current_block):sprite("menu", "filter-white-sm", "filter-sm"):style(style_visible):tooltip({"helmod_button.all-product-visible"}))
  --GuiElement.add(input_tool, GuiSwitch(self.classname, "block-switch-product-visible=ID", current_block):state(by_factory_state):leftLabel({"helmod_label.visible-main-product"}):rightLabel({"helmod_label.visible-other-product"}))

  -- input panel
  input_label.caption = {"helmod_common.input"}
  input_scroll.clear()

  -- production block result
  if countRecipes > 0 then

    -- input panel
    local input_table = GuiElement.add(input_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)-2):style("helmod_table_element"))
    if block.ingredients ~= nil then
      for index, lua_ingredient in pairs(block.ingredients) do
        if all_visible == true or lua_ingredient.state == 1 or lua_ingredient.count > ModelCompute.waste_value then
          Logging:debug("HMProductionBlockTab", "lua_ingredient", lua_ingredient, Product(lua_ingredient))
          local ingredient = Product(lua_ingredient):clone()
          ingredient.count = lua_ingredient.count
          if block.count > 1 then
            ingredient.limit_count = lua_ingredient.count / block.count
          end
          local button_action = "production-recipe-ingredient-add=ID"
          local button_tooltip = "tooltip.ingredient"
          local button_color = GuiElement.color_button_default_ingredient
          if block_by_product then
            button_action = "production-recipe-ingredient-add=ID"
            button_tooltip = "tooltip.add-recipe"
          else
            button_action = "product-edition=ID"
            button_tooltip = "tooltip.edit-product"
          end
          -- color
          if lua_ingredient.state == 1 then
            if not(block.unlinked) or block.by_factory == true then
              button_color = GuiElement.color_button_default_ingredient
            else
              button_color = GuiElement.color_button_edit
            end
          elseif lua_ingredient.state == 3 then
            button_color = GuiElement.color_button_rest
          else
            button_color = GuiElement.color_button_default_ingredient
          end
          GuiElement.add(input_table, GuiCellElementM(self.classname, button_action, block.id, ingredient.name):element(ingredient):tooltip(button_tooltip):index(index):color(button_color))
        end
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
  local model = Model.getModel()
  -- data
  local current_block = User.getParameter("current_block") or "new"
  local block = model.blocks[current_block]
  local block_by_product = not(block ~= nil and block.by_product == false)

  local countRecipes = Model.countBlockRecipes(current_block)

  local left_label, left_tool, left_scroll = self:getLeftInfoPanel2()
  local right_label, right_tool, right_scroll = self:getRightInfoPanel2()

  local output_label = left_label
  local output_tool = left_tool
  local output_scroll = left_scroll
  if not(block_by_product) then
    output_label = right_label
    output_scroll = right_scroll
    output_tool = right_tool
  end
  output_tool.clear()
  local all_visible = User.getParameter("block_all_product_visible")
  local style_visible = "helmod_button_menu_sm"
  if all_visible == true then
    style_visible = "helmod_button_menu_sm_selected"
  end
  GuiElement.add(output_tool, GuiButton(self.classname, "block-all-product-visible=ID", current_block):sprite("menu", "filter-white-sm", "filter-sm"):style(style_visible):tooltip({"helmod_button.all-product-visible"}))
  --GuiElement.add(output_tool, GuiSwitch(self.classname, "block-switch-product-visible=ID", current_block):state(by_factory_state):leftLabel({"helmod_label.visible-main-product"}):rightLabel({"helmod_label.visible-other-product"}))

  -- ouput panel
  output_label.caption = {"helmod_common.output"}
  output_scroll.clear()

  -- production block result
  if countRecipes > 0 then

    -- ouput panel
    local output_table = GuiElement.add(output_scroll, GuiTable("output-table"):column(GuiElement.getElementColumnNumber(50)-2):style("helmod_table_element"))
    if block.products ~= nil then
      for index, lua_product in pairs(block.products) do
        if all_visible == true or lua_product.state == 1 or lua_product.count > ModelCompute.waste_value then
          local product = Product(lua_product):clone()
          product.count = lua_product.count
          if block.count > 1 then
            product.limit_count = lua_product.count / block.count
          end
          local button_action = "production-recipe-product-add=ID"
          local button_tooltip = "tooltip.product"
          local button_color = GuiElement.color_button_default_product
          if not(block_by_product) then
            button_action = "production-recipe-product-add=ID"
            button_tooltip = "tooltip.add-recipe"
          else
            if not(block.unlinked) or block.by_factory == true then
              button_action = "product-info=ID"
              button_tooltip = "tooltip.info-product"
            else
              button_action = "product-edition=ID"
              button_tooltip = "tooltip.edit-product"
            end
          end
          -- color
          if lua_product.state == 1 then
            if not(block.unlinked) or block.by_factory == true then
              button_color = GuiElement.color_button_default_product
            else
              button_color = GuiElement.color_button_edit
            end
          elseif lua_product.state == 3 then
            button_color = GuiElement.color_button_rest
          else
            button_color = GuiElement.color_button_default_product
          end

          GuiElement.add(output_table, GuiCellElementM(self.classname, button_action, block.id, product.name):element(product):tooltip(button_tooltip):index(index):color(button_color))
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
  Logging:debug(self.classname, "updateData()", event)
  local model = Model.getModel()
  local current_block = User.getParameter("current_block") or "new"

  self:updateInfo(event)
  self:updateOutput(event)
  self:updateInput(event)

  -- data panel
  local header_panel1, header_panel2,scroll_panel1, scroll_panel2 = self:getResultScrollPanel2({"helmod_result-panel.tab-button-production-block"})

  local back_button = GuiElement.add(header_panel1, GuiButton(self.classname, "change-tab=ID", "HMProductionLineTab"):style("back_button"):caption("Back"))
  back_button.style.width = 70

  local recipe_table = GuiElement.add(scroll_panel1, GuiTable("recipe-data"):column(1):style(helmod_table_style.list))
  recipe_table.vertical_centering = false

  local last_element = nil
  -- col recipe
  local color = "gray"
  local cell_recipe = GuiElement.add(recipe_table, GuiTable("recipe-new"):column(1):style(helmod_table_style.list))
  if current_block == "new" then
    last_element = cell_recipe
    color = "orange"
  end
  local block_new = {name = "helmod_button_menu_flat", hovered = "robot-white", sprite = "robot", count = 0, localised_name = "helmod_result-panel.add-button-production-block"}
  GuiElement.add(cell_recipe, GuiCellProduct(self.classname, "change-tab=ID", "HMProductionBlockTab", "new"):element(block_new):tooltip("tooltip.edit-block"):color(color))

  for _, block in spairs(model.blocks, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
    -- col recipe
    local color = "gray"
    local cell_recipe = GuiElement.add(recipe_table, GuiTable("recipe", block.id):column(1):style(helmod_table_style.list))
    if current_block == block.id then
      last_element = cell_recipe
      color = "orange"
    end
    GuiElement.add(cell_recipe, GuiCellBlock(self.classname, "change-tab=ID", "HMProductionBlockTab", block.id):element(block):tooltip("tooltip.edit-block"):color(color))
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
    local result_table = GuiElement.add(scroll_panel2, GuiTable("list-data"):column(7 + extra_cols):style("helmod_table-odd"))
    result_table.vertical_centering = false
    self:addTableHeader(result_table)

    local sorter = function(t,a,b) return t[b]["index"] > t[a]["index"] end
    if elements.by_product == false then sorter = function(t,a,b) return t[b]["index"] < t[a]["index"] end end
    local last_element = nil
    for _, recipe in spairs(elements.recipes, sorter) do
      local recipe_cell = self:addTableRow(result_table, elements, recipe)
      if User.getParameter("scroll_element") == recipe.id then last_element = recipe_cell end
    end

    Logging:debug(self.classname, "scroll_element", User.getParameter("scroll_element"))
    if last_element ~= nil then
      scroll_panel2.scroll_to_element(last_element)
      User.setParameter("scroll_element", nil)
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
  for _,order in pairs(Model.getBlockOrder()) do
    if order == "products" then
      self:addCellHeader(itable, "products", {"helmod_result-panel.col-header-products"})
    else
      self:addCellHeader(itable, "ingredients", {"helmod_result-panel.col-header-ingredients"})
    end
  end
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
  local recipe_prototype = RecipePrototype(recipe)
  --local lua_recipe = RecipePrototype(recipe):native()

  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", recipe.id):column(2):style(helmod_table_style.list))
  if block.by_product == false then
    -- by ingredient
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-down=ID", block.id, recipe.id):sprite("menu", "arrow-up-white-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-remove=ID", block.id, recipe.id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-up=ID", block.id, recipe.id):sprite("menu", "arrow-down-white-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  else
    -- by product
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-up=ID", block.id, recipe.id):sprite("menu", "arrow-up-white-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-remove=ID", block.id, recipe.id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-down=ID", block.id, recipe.id):sprite("menu", "arrow-down-white-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  end
  -- col index
  if User.getModGlobalSetting("display_data_col_index") then
    GuiElement.add(gui_table, GuiLabel("value_index", recipe.id):caption(recipe.index):style("helmod_label_row_right_40"))
  end
  -- col id
  if User.getModGlobalSetting("display_data_col_id") then
    GuiElement.add(gui_table, GuiLabel("value_id", recipe.id):caption(recipe.id))
  end
  -- col name
  if User.getModGlobalSetting("display_data_col_name") then
    GuiElement.add(gui_table, GuiLabel("value_name", recipe.id):caption(recipe.name))
  end
  -- col type
  if User.getModGlobalSetting("display_data_col_type") then
    GuiElement.add(gui_table, GuiLabel("value_type", recipe.id):caption(recipe.type))
  end
  -- col recipe
  --  local production = recipe.production or 1
  --  local production_label = Format.formatPercent(production).."%"
  --  if block.solver == true then production_label = "" end
  local cell_recipe = GuiElement.add(gui_table, GuiTable("recipe", recipe.id):column(2):style(helmod_table_style.list))
  GuiElement.add(cell_recipe, GuiCellRecipe("HMRecipeEdition=OPEN=ID", block.id, recipe.id):element(recipe):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):broken(recipe_prototype:native() == nil))
  if recipe_prototype:native() == nil then
    Player.print("ERROR: Recipe ".. recipe.name .." not exist in game")
  end
  -- col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable("energy", recipe.id):column(2):style(helmod_table_style.list))
  GuiElement.add(cell_energy, GuiCellEnergy("HMRecipeEdition=OPEN=ID", block.id, recipe.id):element(recipe):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default))

  -- col factory
  local factory = recipe.factory
  local cell_factory = GuiElement.add(gui_table, GuiTable("factory", recipe.id):column(2):style(helmod_table_style.list))
  GuiElement.add(cell_factory, GuiCellFactory("HMRecipeEdition=OPEN=ID", block.id, recipe.id):element(factory):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default))

  -- col beacon
  local beacon = recipe.beacon
  local cell_beacon = GuiElement.add(gui_table, GuiTable("beacon", recipe.id):column(2):style(helmod_table_style.list))
  GuiElement.add(cell_beacon, GuiCellFactory("HMRecipeEdition=OPEN=ID", block.id, recipe.id):element(beacon):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default))

  for _,order in pairs(Model.getBlockOrder()) do
    if order == "products" then
      -- products
      local display_product_cols = User.getModSetting("display_product_cols")
      local cell_products = GuiElement.add(gui_table, GuiTable("products", recipe.id):column(display_product_cols):style(helmod_table_style.list))
      for index, lua_product in pairs(recipe_prototype:getProducts()) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:countProduct(recipe)
        if block.count > 1 then
          product.limit_count = product.count / block.count
        end
        GuiElement.add(cell_products, GuiCellElement(self.classname, "production-recipe-product-add=ID", block.id, recipe.name):element(product):tooltip("tooltip.add-recipe"):index(index))
      end
    else
      -- ingredients
      local display_ingredient_cols = User.getModSetting("display_ingredient_cols")
      local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients_", recipe.id):column(display_ingredient_cols):style(helmod_table_style.list))
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:countIngredient(recipe)
        if block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        GuiElement.add(cell_ingredients, GuiCellElement(self.classname, "production-recipe-ingredient-add=ID", block.id, recipe.name):element(ingredient):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index))
      end
    end
  end

  return cell_recipe
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ProductionBlockTab] onEvent
--
-- @param #LuaEvent event
--
function ProductionBlockTab:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  if not(User.isWriter()) then return end
  if event.action == "block-switch-unlink" then
    local switch_unlink_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(event.item1, "unlinked", switch_unlink_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end
  if event.action == "block-switch-element" then
    local switch_unlink_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(event.item1, "by_product", switch_unlink_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end
  if event.action == "block-switch-factory" then
    local switch_unlink_state = not(event.element.switch_state == "left")
    ModelBuilder.updateProductionBlockOption(event.item1, "by_factory", switch_unlink_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end
  if event.action == "block-all-ingredient-visible" then
    local all_visible = User.getParameter("block_all_ingredient_visible")
    User.setParameter("block_all_ingredient_visible",not(all_visible))
    Controller:send("on_gui_update", event, self.classname)
  end
  if event.action == "block-all-product-visible" then
    local all_visible = User.getParameter("block_all_product_visible")
    User.setParameter("block_all_product_visible",not(all_visible))
    Controller:send("on_gui_update", event, self.classname)
  end
end
