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

  local infoPanel = self.parent:getInfoPanel()
  -- info panel
  local blockPanel = ElementGui.addGuiFrameV(infoPanel, "block", "helmod_frame_default", ({"helmod_result-panel.tab-title-production-block"}))
  local blockScroll = ElementGui.addGuiScrollPane(blockPanel, "output-scroll", "helmod_scroll_block_info", "auto", "auto")
  local blockTable = ElementGui.addGuiTable(blockScroll,"output-table",2)

  local elementPanel = ElementGui.addGuiFlowV(infoPanel, "elements", "helmod_flow_default")
  -- ouput panel
  local outputPanel = ElementGui.addGuiFrameV(elementPanel, "output", "helmod_frame_resize_row_width", ({"helmod_common.output"}))
  local outputScroll = ElementGui.addGuiScrollPane(outputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  Player.setStyle(outputScroll, "scroll_block_element", "minimal_width")
  Player.setStyle(outputScroll, "scroll_block_element", "maximal_width")
  Player.setStyle(outputScroll, "scroll_block_element", "minimal_height")
  Player.setStyle(outputScroll, "scroll_block_element", "maximal_height")

  -- input panel
  local inputPanel = ElementGui.addGuiFrameV(elementPanel, "input", "helmod_frame_resize_row_width", ({"helmod_common.input"}))
  local inputScroll = ElementGui.addGuiScrollPane(inputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  Player.setStyle(inputScroll, "scroll_block_element", "minimal_width")
  Player.setStyle(inputScroll, "scroll_block_element", "maximal_width")
  Player.setStyle(inputScroll, "scroll_block_element", "minimal_height")
  Player.setStyle(inputScroll, "scroll_block_element", "maximal_height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    -- block panel
    ElementGui.addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
    ElementGui.addGuiLabel(blockTable, "power", Format.formatNumberKilo(element.power or 0, "W"),"helmod_label_right_70")

    ElementGui.addGuiLabel(blockTable, "label-count", ({"helmod_label.block-number"}))
    ElementGui.addGuiLabel(blockTable, "count", Format.formatNumberFactory(element.count or 0),"helmod_label_right_70")

    ElementGui.addGuiLabel(blockTable, "label-sub-power", ({"helmod_label.sub-block-power"}))
    ElementGui.addGuiLabel(blockTable, "sub-power", Format.formatNumberKilo(element.sub_power or 0),"helmod_label_right_70")

    ElementGui.addGuiLabel(blockTable, "options-linked", ({"helmod_label.block-unlinked"}))
    local unlinked = element.unlinked and true or false
    if element.index == 0 then unlinked = true end
    ElementGui.addGuiCheckbox(blockTable, self.parent:classname().."=change-boolean-option=ID=unlinked", unlinked)

    ElementGui.addGuiLabel(blockTable, "options-by-factory", ({"helmod_label.compute-by-factory"}))
    local by_factory = element.by_factory and true or false
    ElementGui.addGuiCheckbox(blockTable, self.parent:classname().."=change-boolean-option=ID=by_factory", by_factory)

    if element.by_factory == true then
      local factory_number = element.factory_number or 0
      ElementGui.addGuiLabel(blockTable, "label-factory_number", ({"helmod_label.factory-number"}))
      ElementGui.addGuiText(blockTable, "factory_number", factory_number, "helmod_textfield")
      ElementGui.addGuiButton(blockTable, self.parent:classname().."=change-number-option=ID=", "factory_number", "helmod_button_default", ({"helmod_button.update"}))
    end

    -- ouput panel
    local outputTable = ElementGui.addGuiTable(outputScroll,"output-table",6)
    if element.products ~= nil then
      for r, lua_product in pairs(element.products) do
        local product = Product.load(lua_product).new()
        product.count = lua_product.count
        if element.count > 1 then
          product.limit_count = lua_product.count / element.count
        end
        if bit32.band(lua_product.state, 1) > 0 then
          if not(unlinked) or element.by_factory == true then
            ElementGui.addCellElement(outputTable, product, "HMProduct=OPEN=ID="..element.id.."=", false, "tooltip.product", nil)
          else
            ElementGui.addCellElement(outputTable, product, "HMProductEdition=OPEN=ID="..element.id.."=", true, "tooltip.edit-product", self.color_button_edit)
          end
        end
        if bit32.band(lua_product.state, 2) > 0 and bit32.band(lua_product.state, 1) == 0 then
          ElementGui.addCellElement(outputTable, product, "HMProduct=OPEN=ID="..element.id.."=", true, "tooltip.rest-product", self.color_button_rest)
        end
        if lua_product.state == 0 then
          ElementGui.addCellElement(outputTable, product, "HMProduct=OPEN=ID="..element.id.."=", false, "tooltip.other-product", nil)
        end
      end
    end

    -- input panel

    local inputTable = ElementGui.addGuiTable(inputScroll,"input-table",6)
    if element.ingredients ~= nil then
      for r, lua_product in pairs(element.ingredients) do
        local ingredient = Product.load(lua_product).new()
        ingredient.count = lua_product.count
        if element.count > 1 then
          ingredient.limit_count = lua_product.count / element.count
        end
        ElementGui.addCellElement(inputTable, ingredient, "HMIngredient=OPEN=ID="..element.id.."=", false, "tooltip.ingredient", nil)
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
-- @param #LuaGuiElement guiTable
-- @param #string blockId
-- @param #table element production recipe
--
function ProductionBlockTab.methods:addTableRow(guiTable, block, recipe)
  Logging:debug("ProductionBlockTab", "addTableRow():", guiTable, block, recipe)
  local lua_recipe = RecipePrototype.load(recipe).native()
  local display_cell_mod = Player.getSettings("display_cell_mod")

  -- col action
  local guiAction = ElementGui.addGuiFlowH(guiTable,"action"..recipe.id, "helmod_flow_default")
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-recipe-remove=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-recipe-down=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element", Player.getSettings("row_move_step")}))
  ElementGui.addGuiButton(guiAction, self.parent:classname().."=production-recipe-up=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element", Player.getSettings("row_move_step")}))

  -- col index
  if Player.getSettings("display_data_col_index", true) then
    local guiIndex = ElementGui.addGuiFlowH(guiTable,"index"..recipe.id)
    ElementGui.addGuiLabel(guiIndex, "index", recipe.index, "helmod_label_row_right_40")
  end
  -- col id
  if Player.getSettings("display_data_col_id", true) then
    local guiId = ElementGui.addGuiFlowH(guiTable,"id"..recipe.id)
    ElementGui.addGuiLabel(guiId, "id", recipe.id)
  end
  -- col name
  if Player.getSettings("display_data_col_name", true) then
    local guiName = ElementGui.addGuiFlowH(guiTable,"name"..recipe.id)
    ElementGui.addGuiLabel(guiName, "name_", recipe.name)
  end
  -- col type
  if Player.getSettings("display_data_col_type", true) then
    local guiName = ElementGui.addGuiFlowH(guiTable,"type"..recipe.id)
    ElementGui.addGuiLabel(guiName, "type_", recipe.type)
  end
  -- col recipe
  local production = recipe.production or 1
  local guiRecipe = self:addCellLabel(guiTable, "recipe-"..recipe.id, Format.formatPercent(production).."%", 35)
  self:addIconRecipeCell(guiRecipe, recipe, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)

  -- col energy
  local guiEnergy = self:addCellLabel(guiTable, "energy-"..recipe.id, Format.formatNumberKilo(recipe.energy_total, "W"), 60)

  -- col factory
  local factory = recipe.factory
  local gui_cell_factory = ElementGui.addCell(guiTable, "factory-"..recipe.id)

  if block.count > 1 then
    ElementGui.addCellLabel2(gui_cell_factory, "factory-"..recipe.id, Format.formatNumberFactory(factory.limit_count), Format.formatNumberFactory(factory.count))
  else
    ElementGui.addCellLabel(gui_cell_factory, "factory-"..recipe.id, Format.formatNumberFactory(factory.limit_count))
  end
  ElementGui.addCellIcon(gui_cell_factory, factory, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)
  local col_size = 2
  if display_cell_mod == "small-icon" then col_size = 5 end
  local guiFactoryModule = ElementGui.addGuiTable(gui_cell_factory,"factory-modules"..recipe.name, col_size, "helmod_factory_modules")
  -- modules
  for name, count in pairs(factory.modules) do
    for index = 1, count, 1 do
      ElementGui.addGuiButtonSpriteSm(guiFactoryModule, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
      index = index + 1
    end
  end

  -- col beacon
  local beacon = recipe.beacon
  local gui_cell_beacon = ElementGui.addCell(guiTable, "beacon-"..recipe.id)

  if block.count > 1 then
    ElementGui.addCellLabel2(gui_cell_beacon, "beacon-"..recipe.id, Format.formatNumberFactory(beacon.limit_count), Format.formatNumberFactory(beacon.count))
  else
    ElementGui.addCellLabel(gui_cell_beacon, "beacon-"..recipe.id, Format.formatNumberFactory(beacon.limit_count))
  end
  ElementGui.addCellIcon(gui_cell_beacon, beacon, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)

  local col_size = 1
  if display_cell_mod == "small-icon" then col_size = 5 end
  local guiBeaconModule = ElementGui.addGuiTable(gui_cell_beacon,"beacon-modules"..recipe.name, col_size, "helmod_beacon_modules")
  -- modules
  for name, count in pairs(beacon.modules) do
    for index = 1, count, 1 do
      ElementGui.addGuiButtonSpriteSm(guiBeaconModule, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
      index = index + 1
    end
  end

  -- products
  local display_product_cols = Player.getSettings("display_product_cols")
  local tProducts = ElementGui.addGuiTable(guiTable,"products_"..recipe.id, display_product_cols)
  for r, lua_product in pairs(RecipePrototype.getProducts()) do
    local product = Product.load(lua_product).new()
    product.count = Product.countProduct(recipe)
    if block.count > 1 then
      product.limit_count = product.count / block.count
    end
    ElementGui.addCellElement(tProducts, product, "HMProduct=OPEN=ID="..block.id.."="..recipe.name.."=", false, "tooltip.product", nil)
  end

  -- ingredients
  local display_ingredient_cols = Player.getSettings("display_ingredient_cols")
  local tIngredient = ElementGui.addGuiTable(guiTable,"ingredients_"..recipe.id, display_ingredient_cols)
  for r, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
    local ingredient = Product.load(lua_ingredient).new()
    ingredient.count = Product.countIngredient(recipe)
    if block.count > 1 then
      ingredient.limit_count = ingredient.count / block.count
    end
    ElementGui.addCellElement(tIngredient, ingredient, self.parent:classname().."=production-recipe-add=ID="..block.id.."="..recipe.name.."=", true, "tooltip.add-recipe", self.color_button_add)
  end
end
