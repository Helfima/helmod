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
  local model = Model.getModel()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  info_scroll.clear()
  -- info panel

  local block_info = GuiElement.add(info_scroll, GuiFlowH("block-info"))
  block_info.style.horizontally_stretchable = false
  block_info.style.horizontal_spacing=10
  
  local block_table = GuiElement.add(block_info, GuiTable("output-table"):column(2))

  GuiElement.add(block_table, GuiLabel("label-owner"):caption({"helmod_result-panel.owner"}))
  GuiElement.add(block_table, GuiLabel("value-owner"):caption(model.owner))

  GuiElement.add(block_table, GuiLabel("label-share"):caption({"helmod_result-panel.share"}))

  local tableAdminPanel = GuiElement.add(block_table, GuiTable("table"):column(9))
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", "read", model.id):state(model_read):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-read"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", "write", model.id):state(model_write):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-write"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  GuiElement.add(tableAdminPanel,GuiCheckBox( self.classname, "share-model", "delete", model.id):state(model_delete):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-delete"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))

  local count_block = Model.countBlocks()
  if count_block > 0 then
    local element_block = {name=model.id, energy_total=0, pollution=0}
    if model.summary ~= nil then
      element_block.energy_total = model.summary.energy
      element_block.pollution_total = model.summary.pollution
      element_block.summary = model.summary
    end
    GuiElement.add(block_info, GuiCellEnergy("block-power"):element(element_block):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(2))
    if User.getPreferenceSetting("display_pollution") then
      GuiElement.add(block_info, GuiCellPollution("block-pollution"):element(element_block):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(2))
    end
    if User.getPreferenceSetting("display_building") then
      GuiElement.add(block_info, GuiCellBuilding("block-building"):element(element_block):tooltip("tooltip.info-building"):color(GuiElement.color_button_default):index(2))
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
  local model = Model.getModel()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  input_scroll.clear()
  -- input panel

  local count_block = Model.countBlocks()
  if count_block > 0 then

    local input_table = GuiElement.add(input_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    if model.ingredients ~= nil then
      for index, element in spairs(model.ingredients, User.getProductSorter2()) do
        GuiElement.add(input_table, GuiCellElementM(self.classname, "production-block-ingredient-add", "new", element.name):element(element):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index))
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
      for index, element in spairs(model.products, User.getProductSorter2()) do
        GuiElement.add(output_table, GuiCellElementM(self.classname, "production-block-product-add", "new", element.name):element(element):tooltip("tooltip.add-recipe"):index(index))
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
    if User.getPreferenceSetting("display_pollution") then
      extra_cols = extra_cols + 1
    end
    if User.getPreferenceSetting("display_building") then
      extra_cols = extra_cols + 1
    end
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
-- On event
--
-- @function [parent=#ProductionLineTab] onEvent
--
-- @param #LuaEvent event
--
function ProductionLineTab:onEvent(event)
  local model = Model.getModel()
  local current_block = User.getParameter("current_block")
  local selector_name = "HMRecipeSelector"
  if model.blocks[current_block] ~= nil and model.blocks[current_block].isEnergy then
    selector_name = "HMEnergySelector"
  end
  -- user writer
  if not(User.isWriter()) then return end
  
  if event.action == "production-block-product-add" then
    if event.button == defines.mouse_button_type.right then
      Controller:send("on_gui_open", event, "HMRecipeSelector")
    else
      local recipes = Player.searchRecipe(event.item2, true)
      if #recipes == 1 then
        local recipe = recipes[1]
        ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type, 0)
        ModelCompute.update()
        User.setActiveForm("HMProductionBlockTab")
        Controller:send("on_gui_refresh", event)
      else
        -- pour ouvrir avec le filtre ingredient
        event.button = defines.mouse_button_type.right
        Controller:send("on_gui_open", event,"HMRecipeSelector")
      end
    end
  end
  if event.action == "production-block-ingredient-add" then
    if event.button == defines.mouse_button_type.right then
      Controller:send("on_gui_open", event, "HMRecipeSelector")
    else
      local recipes = Player.searchRecipe(event.item2)
      if #recipes == 1 then
        local recipe = recipes[1]
        ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
        ModelCompute.update()
        User.setActiveForm("HMProductionBlockTab")
        Controller:send("on_gui_refresh", event)
      else
        Controller:send("on_gui_open", event,"HMRecipeSelector")
      end
    end
  end

  if event.action == "production-block-up" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.upProductionBlock(event.item1, step)
    ModelCompute.update()
    User.setParameter("scroll_element", event.item1)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-block-down" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.downProductionBlock(event.item1, step)
    ModelCompute.update()
    User.setParameter("scroll_element", event.item1)
    Controller:send("on_gui_update", event)
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
  local model = Model.getModel()

  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(itable, "id", {"helmod_result-panel.col-header-id"},"id")
  self:addCellHeader(itable, "name", {"helmod_result-panel.col-header-name"},"name")
  -- data columns
  self:addCellHeader(itable, "recipe", {"helmod_result-panel.col-header-production-block"},"index")
  self:addCellHeader(itable, "energy", {"helmod_common.energy-consumption"},"power")
  if User.getPreferenceSetting("display_pollution") then
    self:addCellHeader(itable, "pollution", {"helmod_common.pollution"})
  end
  if User.getPreferenceSetting("display_building") then
    self:addCellHeader(itable, "building", {"helmod_common.building"})
  end
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
  local model = Model.getModel()

  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end
  local block_by_product = not(block ~= nil and block.by_product == false)
  block.type = "recipe"
  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", block.id):column(2))

  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-up", block.id):sprite("menu", "arrow-up-white-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-remove", block.id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-down", block.id):sprite("menu", "arrow-down-white-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  if unlinked then
    GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink", block.id):sprite("menu", "unlink-white-sm", "unlink-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.unlink-element"}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink", block.id):sprite("menu", "link-white-sm", "link-sm"):style("helmod_button_menu_sm_selected"):tooltip({"tooltip.unlink-element"}))
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

  local block_color = "gray"
  if not(block_by_product) then block_color = "orange" end
  GuiElement.add(cell_recipe, GuiCellBlock(self.classname, "change-tab", "HMProductionBlockTab", block.id):element(block):infoIcon(block.type):tooltip("tooltip.edit-block"):color(block_color))

  -- col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable(block.id, "energy"):column(1))
  local element_block = {name=block.name, power=block.power, pollution_total=block.pollution_total, summary=block.summary}
  GuiElement.add(cell_energy, GuiCellEnergy(self.classname, "change-tab", "HMProductionBlockTab", block.id):element(element_block):tooltip("tooltip.edit-block"):color(block_color))

  -- col pollution
  if User.getPreferenceSetting("display_pollution") then
    local cell_pollution = GuiElement.add(gui_table, GuiTable(block.id, "pollution"):column(1))
    GuiElement.add(cell_pollution, GuiCellPollution(self.classname, "change-tab", "HMProductionBlockTab", block.id):element(element_block):tooltip("tooltip.edit-block"):color(block_color))
  end
  
  -- col building
  if User.getPreferenceSetting("display_building") then
    local cell_building = GuiElement.add(gui_table, GuiTable(block.id, "building"):column(1))
    GuiElement.add(cell_building, GuiCellBuilding(self.classname, "change-tab", "HMProductionBlockTab", block.id):element(element_block):tooltip("tooltip.info-building"):color(block_color))
  end

  local product_sorter = User.getProductSorter2()

  -- products
  local display_product_cols = User.getPreferenceSetting("display_product_cols") + 1
  local cell_products = GuiElement.add(gui_table, GuiTable("products", block.id):column(display_product_cols))
  cell_products.style.horizontally_stretchable = false
  if block.products ~= nil then
    for index, product in spairs(block.products, product_sorter) do
      if ((product.state or 0) == 1 and block_by_product)  or (product.count or 0) > ModelCompute.waste_value then
        local button_action = "production-block-product-add"
        local button_tooltip = "tooltip.product"
        local button_color = GuiElement.color_button_default_product
        if not(block_by_product) then
          button_action = "production-block-product-add"
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
        if product.state == 1 then
          if not(block.unlinked) or block.by_factory == true then
            button_color = GuiElement.color_button_default_product
          else
            button_color = GuiElement.color_button_edit
          end
        elseif product.state == 3 then
          button_color = GuiElement.color_button_rest
        else
          button_color = GuiElement.color_button_default_product
        end
        GuiElement.add(cell_products, GuiCellElement(self.classname, button_action, block.id, product.name):element(product):tooltip(button_tooltip):color(button_color):index(index))
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = User.getPreferenceSetting("display_ingredient_cols") + 2
  local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients", block.id):column(display_ingredient_cols))
  cell_ingredients.style.horizontally_stretchable = false
  if block.ingredients ~= nil then
    for index, ingredient in spairs(block.ingredients, product_sorter) do
      if ((ingredient.state or 0) == 1 and not(block_by_product)) or (ingredient.count or 0) > ModelCompute.waste_value then
        local button_action = "production-block-ingredient-add"
        local button_tooltip = "tooltip.ingredient"
        local button_color = GuiElement.color_button_default_ingredient
        if block_by_product then
          button_action = "production-block-ingredient-add"
          button_tooltip = "tooltip.add-recipe"
        else
          button_action = "product-edition"
          button_tooltip = "tooltip.edit-product"
        end
        -- color
        if ingredient.state == 1 then
          if not(block.unlinked) or block.by_factory == true then
            button_color = GuiElement.color_button_default_ingredient
          else
            button_color = GuiElement.color_button_edit
          end
        elseif ingredient.state == 3 then
          button_color = GuiElement.color_button_rest
        else
          button_color = GuiElement.color_button_default_ingredient
        end
        GuiElement.add(cell_ingredients, GuiCellElement(self.classname, button_action, block.id, ingredient.name):element(ingredient):tooltip(button_tooltip):color(button_color):index(index))
      end
    end
  end
  return cell_recipe
end
