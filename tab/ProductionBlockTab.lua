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
end

-------------------------------------------------------------------------------
-- Update info
--
-- @function [parent=#ProductionBlockTab] updateInfo
--
-- @param #LuaEvent event
--
function ProductionBlockTab:updateInfo(event)
  local model = Model.getModel()
  -- data
  local current_block = User.getParameter("current_block") or "new"

  local countRecipes = Model.countBlockRecipes(current_block)

  local options_scroll, info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  options_scroll.clear()
  info_scroll.clear()
  -- info panel

  local block_table = GuiElement.add(info_scroll, GuiTable("output-table"):column(3))
  block_table.style.horizontally_stretchable = false
  block_table.vertical_centering = false
  block_table.style.horizontal_spacing=10

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[current_block]

    -- block panel
    GuiElement.add(block_table, GuiCellBlockInfo("block-count"):element(element):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(1))
    GuiElement.add(block_table, GuiCellEnergy("block-power"):element(element):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(2))
    if User.getPreferenceSetting("display_pollution") then
      GuiElement.add(block_table, GuiCellPollution("block-pollution"):element(element):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(2))
    end

    local unlink_state = "right"
    if element.unlinked == true then unlink_state = "left" end
    local unlink_switch = GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-unlink", current_block):state(unlink_state):leftLabel({"helmod_label.block-unlinked"}):rightLabel({"helmod_label.block-linked"}))
    if element.index == 0 then
      unlink_switch.enabled = false
      unlink_switch.tooltip = {"tooltip.block-cannot-link-first"}
    end
    if element.by_factory == true then
      unlink_switch.enabled = false
      unlink_switch.tooltip = {"tooltip.block-cannot-link-by-factory"}
    end

    local element_state = "left"
    if element.by_product == false then element_state = "right" end
    GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-element", current_block):state(element_state):leftLabel({"helmod_label.input-product"}):rightLabel({"helmod_label.input-ingredient"}))

    local by_factory_state = "left"
    if element.by_factory == true then by_factory_state = "right" end
    local by_factory_switch = GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-factory", current_block):state(by_factory_state):leftLabel({"helmod_label.compute-by-element"}):rightLabel({"helmod_label.compute-by-factory"}))
    if element.solver == true then
      by_factory_switch.enabled = false
      by_factory_switch.tooltip = {"tooltip.block-cannot-by-factory"}
    end

    local matrix_solver = "left"
    if element.solver == true then matrix_solver = "right" end
    local solver_switch = GuiElement.add(options_scroll, GuiSwitch(self.classname, "block-switch-solver", current_block):state(matrix_solver):leftLabel({"helmod_label.algebraic-solver"}):rightLabel({"helmod_label.matrix-solver"}))
    if element.by_factory == true then
      solver_switch.enabled = false
      solver_switch.tooltip = {"tooltip.block-cannot-matrix-solver"}
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
  GuiElement.add(input_tool, GuiButton(self.classname, "block-all-ingredient-visible", current_block):sprite("menu", "filter-white-sm", "filter-sm"):style(style_visible):tooltip({"helmod_button.all-product-visible"}))
  --GuiElement.add(input_tool, GuiSwitch(self.classname, "block-switch-product-visible", current_block):state(by_factory_state):leftLabel({"helmod_label.visible-main-product"}):rightLabel({"helmod_label.visible-other-product"}))

  -- input panel
  input_label.caption = {"helmod_common.input"}
  input_scroll.clear()

  -- production block result
  if countRecipes > 0 then

    -- input panel
    local input_table = GuiElement.add(input_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)-2):style("helmod_table_element"))
    if block.ingredients ~= nil then
      for index, lua_ingredient in pairs(block.ingredients) do
        if all_visible == true or (lua_ingredient.state == 1 and not(block_by_product)) or lua_ingredient.count > ModelCompute.waste_value then
          local ingredient = Product(lua_ingredient):clone()
          ingredient.count = lua_ingredient.count
          if block.count > 1 then
            ingredient.limit_count = lua_ingredient.count / block.count
          end
          local button_action = "production-recipe-ingredient-add"
          local button_tooltip = "tooltip.ingredient"
          local button_color = GuiElement.color_button_default_ingredient
          if block_by_product then
            button_action = "production-recipe-ingredient-add"
            button_tooltip = "tooltip.add-recipe"
          else
            button_action = "product-edition"
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
  GuiElement.add(output_tool, GuiButton(self.classname, "block-all-product-visible", current_block):sprite("menu", "filter-white-sm", "filter-sm"):style(style_visible):tooltip({"helmod_button.all-product-visible"}))
  --GuiElement.add(output_tool, GuiSwitch(self.classname, "block-switch-product-visible", current_block):state(by_factory_state):leftLabel({"helmod_label.visible-main-product"}):rightLabel({"helmod_label.visible-other-product"}))

  -- ouput panel
  output_label.caption = {"helmod_common.output"}
  output_scroll.clear()

  -- production block result
  if countRecipes > 0 then

    -- ouput panel
    local output_table = GuiElement.add(output_scroll, GuiTable("output-table"):column(GuiElement.getElementColumnNumber(50)-2):style("helmod_table_element"))
    if block.products ~= nil then
      for index, lua_product in pairs(block.products) do
        if all_visible == true or ((lua_product.state or 0) == 1 and block_by_product) or (lua_product.count or 0) > ModelCompute.waste_value then
          local product = Product(lua_product):clone()
          product.count = lua_product.count
          if block.count > 1 then
            product.limit_count = lua_product.count / block.count
          end
          local button_action = "production-recipe-product-add"
          local button_tooltip = "tooltip.product"
          local button_color = GuiElement.color_button_default_product
          if not(block_by_product) then
            button_action = "production-recipe-product-add"
            button_tooltip = "tooltip.add-recipe"
          else
            if not(block.unlinked) or block.by_factory == true then
              button_action = "product-info"
              button_tooltip = "tooltip.info-product"
            else
              button_action = "product-edition"
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
  local model = Model.getModel()
  local current_block = User.getParameter("current_block") or "new"

  self:updateInfo(event)
  self:updateOutput(event)
  self:updateInput(event)

  -- data panel
  local header_panel1, header_panel2,scroll_panel1, scroll_panel2 = self:getResultScrollPanel2({"helmod_result-panel.tab-button-production-block"})

  local back_button = GuiElement.add(header_panel1, GuiButton(self.classname, "change-tab", "HMProductionLineTab"):style("back_button"):caption("Back"))
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
  GuiElement.add(cell_recipe, GuiCellProduct(self.classname, "change-tab", "HMProductionBlockTab", "new"):element(block_new):tooltip("tooltip.edit-block"):color(color))

  for _, block in spairs(model.blocks, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
    -- col recipe
    local color = "gray"
    local cell_recipe = GuiElement.add(recipe_table, GuiTable("recipe", block.id):column(1):style(helmod_table_style.list))
    if current_block == block.id then
      last_element = cell_recipe
      color = "orange"
    end
    GuiElement.add(cell_recipe, GuiCellBlock(self.classname, "change-tab", "HMProductionBlockTab", block.id):element(block):tooltip("tooltip.edit-block"):color(color))
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
    if User.getPreferenceSetting("display_pollution") then
      extra_cols = extra_cols + 1
    end
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
  self:addCellHeader(itable, "energy", {"helmod_common.energy-consumption"},"energy_total")
  if User.getPreferenceSetting("display_pollution") then
    self:addCellHeader(itable, "pollution", {"helmod_common.pollution"})
  end
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
  local recipe_prototype = RecipePrototype(recipe)
  --local lua_recipe = RecipePrototype(recipe):native()

  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", recipe.id):column(2):style(helmod_table_style.list))
  if block.by_product == false then
    -- by ingredient
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-down", block.id, recipe.id):sprite("menu", "arrow-up-white-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-remove", block.id, recipe.id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-up", block.id, recipe.id):sprite("menu", "arrow-down-white-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  else
    -- by product
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-up", block.id, recipe.id):sprite("menu", "arrow-up-white-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-remove", block.id, recipe.id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-down", block.id, recipe.id):sprite("menu", "arrow-down-white-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  end
  -- matrix solver
  -- local style_matrix_solver = "helmod_button_menu_sm"
  -- if recipe.matrix_solver == 1 then
  --   style_matrix_solver = "helmod_button_menu_sm_selected"
  -- end
  -- GuiElement.add(cell_action, GuiButton(self.classname, "update-matrix-solver", block.id, recipe.id):sprite("menu", "settings-white-sm", "settings-sm"):style(style_matrix_solver):tooltip({"helmod_button.matrix-solver"}))
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
  GuiElement.add(cell_recipe, GuiCellRecipe("HMRecipeEdition", "OPEN", block.id, recipe.id):element(recipe):infoIcon(recipe.type):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):broken(recipe_prototype:native() == nil))
  if recipe_prototype:native() == nil then
    Player.print("ERROR: Recipe ".. recipe.name .." not exist in game")
  end
  -- col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable("energy", recipe.id):column(2):style(helmod_table_style.list))
  GuiElement.add(cell_energy, GuiCellEnergy("HMRecipeEdition", "OPEN", block.id, recipe.id):element(recipe):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default))

  -- col pollution
  if User.getPreferenceSetting("display_pollution") then
    local cell_pollution = GuiElement.add(gui_table, GuiTable("pollution", recipe.id):column(2):style(helmod_table_style.list))
    GuiElement.add(cell_pollution, GuiCellPollution("HMRecipeEdition", "OPEN", block.id, recipe.id):element(recipe):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default))
  end
  
  -- col factory
  local factory = recipe.factory
  local cell_factory = GuiElement.add(gui_table, GuiTable("factory", recipe.id):column(2):style(helmod_table_style.list))
  local gui_cell_factory = GuiCellFactory("HMRecipeEdition", "OPEN", block.id, recipe.id):element(factory):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default)
  if block.by_factory == true then
    gui_cell_factory:byFactory(self.classname, "update-factory-number", block.id, recipe.id)
  end
  GuiElement.add(cell_factory, gui_cell_factory)

  -- col beacon
  local beacon = recipe.beacon
  local cell_beacon = GuiElement.add(gui_table, GuiTable("beacon", recipe.id):column(2):style(helmod_table_style.list))
  GuiElement.add(cell_beacon, GuiCellFactory("HMRecipeEdition", "OPEN", block.id, recipe.id):element(beacon):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default))
  
  for _,order in pairs(Model.getBlockOrder()) do
    if order == "products" then
      -- products
      local display_product_cols = User.getPreferenceSetting("display_product_cols")
      local cell_products = GuiElement.add(gui_table, GuiTable("products", recipe.id):column(display_product_cols):style(helmod_table_style.list))
      for index, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:countProduct(recipe)
        if block.count > 1 then
          product.limit_count = product.count / block.count
        end
        GuiElement.add(cell_products, GuiCellElement(self.classname, "production-recipe-product-add", block.id, recipe.name):element(product):tooltip("tooltip.add-recipe"):index(index))
      end
    else
      -- ingredients
      local display_ingredient_cols = User.getPreferenceSetting("display_ingredient_cols")
      local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients_", recipe.id):column(display_ingredient_cols):style(helmod_table_style.list))
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:countIngredient(recipe)
        if block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        GuiElement.add(cell_ingredients, GuiCellElement(self.classname, "production-recipe-ingredient-add", block.id, recipe.name):element(ingredient):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index))
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

  -- user writer
  if not(User.isWriter()) then return end
  
  if event.action == "update-factory-number" then
    local value = GuiElement.getInputNumber(event.element)
    ModelBuilder.updateFactoryNumber(event.item1, event.item2, value)
    ModelCompute.update()
    Controller:send("on_gui_update", event)
  end

  if event.action == "update-matrix-solver" then
    ModelBuilder.updateMatrixSolver(event.item1, event.item2)
    ModelCompute.update()
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-block-solver" then
    ModelBuilder.updateBlockMatrixSolver(event.item1)
    ModelCompute.update()
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-recipe-remove" then
    ModelBuilder.removeProductionRecipe(event.item1, event.item2)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "production-recipe-up" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.upProductionRecipe(event.item1, event.item2, step)
    ModelCompute.update()
    User.setParameter("scroll_element", event.item2)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "production-recipe-down" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.downProductionRecipe(event.item1, event.item2, step)
    ModelCompute.update()
    User.setParameter("scroll_element", event.item2)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-unlink" then
    local switch_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(event.item1, "unlinked", switch_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-element" then
    local switch_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(event.item1, "by_product", switch_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-factory" then
    local switch_state = not(event.element.switch_state == "left")
    ModelBuilder.updateProductionBlockOption(event.item1, "by_factory", switch_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-solver" then
    local switch_state = event.element.switch_state == "right"
    ModelBuilder.updateProductionBlockOption(event.item1, "solver", switch_state)
    ModelCompute.update()
    Controller:send("on_gui_update", event, self.classname)
  end

end
