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
  return {"helmod_result-panel.add-button-production-block"}
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionBlockTab] updateHeader
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:updateHeader(player, item, item2, item3)
  Logging:debug("ProductionBlockTab", "updateHeader():", player, item, item2, item3)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local menuPanel = self.parent:getMenuPanel(player)

  local blockId = globalGui.currentBlock or "new"

  local countRecipes = self.model:countBlockRecipes(player, blockId)

  local infoPanel = self.parent:getInfoPanel(player)
  -- info panel
  local blockPanel = self:addGuiFrameV(infoPanel, "block", "helmod_frame_default", ({"helmod_result-panel.tab-title-production-block"}))
  local blockScroll = self:addGuiScrollPane(blockPanel, "output-scroll", "helmod_scroll_block_info", "auto", "auto")
  local blockTable = self:addGuiTable(blockScroll,"output-table",2)

  local elementPanel = self:addGuiFlowV(infoPanel, "elements", "helmod_flow_default")
  -- ouput panel
  local outputPanel = self:addGuiFrameV(elementPanel, "output", "helmod_frame_resize_row_width", ({"helmod_common.output"}))
  local outputScroll = self:addGuiScrollPane(outputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "minimal_width")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "maximal_width")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "minimal_height")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "maximal_height")

  -- input panel
  local inputPanel = self:addGuiFrameV(elementPanel, "input", "helmod_frame_resize_row_width", ({"helmod_common.input"}))
  local inputScroll = self:addGuiScrollPane(inputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "minimal_width")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "maximal_width")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "minimal_height")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "maximal_height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    -- block panel
    self:addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
    self:addGuiLabel(blockTable, "power", self:formatNumberKilo(element.power or 0, "W"),"helmod_label_right_70")

    self:addGuiLabel(blockTable, "label-count", ({"helmod_label.block-number"}))
    self:addGuiLabel(blockTable, "count", self:formatNumberFactory(element.count or 0),"helmod_label_right_70")

    self:addGuiLabel(blockTable, "label-sub-power", ({"helmod_label.sub-block-power"}))
    self:addGuiLabel(blockTable, "sub-power", self:formatNumberKilo(element.sub_power or 0),"helmod_label_right_70")

    self:addGuiLabel(blockTable, "options-linked", ({"helmod_label.block-unlinked"}))
    local unlinked = element.unlinked and true or false
    if element.index == 0 then unlinked = true end
    self:addGuiCheckbox(blockTable, self.parent:classname().."=change-boolean-option=ID=unlinked", unlinked)

    self:addGuiLabel(blockTable, "options-by-factory", ({"helmod_label.compute-by-factory"}))
    local by_factory = element.by_factory and true or false
    self:addGuiCheckbox(blockTable, self.parent:classname().."=change-boolean-option=ID=by_factory", by_factory)

    if element.by_factory == true then
      local factory_number = element.factory_number or 0
      self:addGuiLabel(blockTable, "label-factory_number", ({"helmod_label.factory-number"}))
      self:addGuiText(blockTable, "factory_number", factory_number, "helmod_textfield")
      self:addGuiButton(blockTable, self.parent:classname().."=change-number-option=ID=", "factory_number", "helmod_button_default", ({"helmod_button.update"}))
    end

    -- ouput panel
    local outputTable = self:addGuiTable(outputScroll,"output-table",6)
    if element.products ~= nil then
      for r, product in pairs(element.products) do
        if bit32.band(product.state, 1) > 0 then
          if not(unlinked) or element.by_factory == true then
            self:addCellElement(player, outputTable, product, "HMProduct=OPEN=ID="..element.id.."=", false, "tooltip.product", nil)
          else
            self:addCellElement(player, outputTable, product, "HMProductEdition=OPEN=ID="..element.id.."=", true, "tooltip.edit-product", self.color_button_edit)
          end
        end
        if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
          self:addCellElement(player, outputTable, product, "HMProduct=OPEN=ID="..element.id.."=", true, "tooltip.rest-product", self.color_button_rest)
        end
        if product.state == 0 then
          self:addCellElement(player, outputTable, product, "HMProduct=OPEN=ID="..element.id.."=", false, "tooltip.other-product", nil)
        end
      end
    end

    -- input panel

    local inputTable = self:addGuiTable(inputScroll,"input-table",6)
    if element.ingredients ~= nil then
      for r, ingredient in pairs(element.ingredients) do
        self:addCellElement(player, inputTable, ingredient, "HMIngredient=OPEN=ID="..element.id.."=", false, "tooltip.ingredient", nil)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#ProductionBlockTab] updateData
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductionBlockTab.methods:updateData(player, item, item2, item3)
  Logging:debug("ProductionBlockTab", "updateData():", player, item, item2, item3)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  Logging:debug("ProductionBlockTab", "model:", model)
  local blockId = "new"
  if globalGui.currentBlock ~= nil then
    blockId = globalGui.currentBlock
  end

  -- data panel
  local scrollPanel = self.parent:getResultScrollPanel(player, {"helmod_common.recipes"})

  local countRecipes = self.model:countBlockRecipes(player, blockId)
  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]
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
    local resultTable = self:addGuiTable(scrollPanel,"list-data",7 + extra_cols, "helmod_table-odd")

    self:addTableHeader(player, resultTable)

    for _, recipe in spairs(model.blocks[blockId].recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addTableRow(player, resultTable, element, recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#ProductionBlockTab] addTableHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function ProductionBlockTab.methods:addTableHeader(player, itable)
  Logging:debug("ProductionBlockTab", "addTableHeader():", player, itable)

  self:addCellHeader(player, itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  self:addCellHeader(player, itable, "index", {"helmod_result-panel.col-header-index"},"index")
  self:addCellHeader(player, itable, "id", {"helmod_result-panel.col-header-id"},"id")
  self:addCellHeader(player, itable, "name", {"helmod_result-panel.col-header-name"},"name")
  -- data columns
  self:addCellHeader(player, itable, "recipe", {"helmod_result-panel.col-header-recipe"},"index")
  self:addCellHeader(player, itable, "energy", {"helmod_result-panel.col-header-factory"},"energy_total")
  self:addCellHeader(player, itable, "factory", {"helmod_result-panel.col-header-output"})
  self:addCellHeader(player, itable, "beacon", {"helmod_result-panel.col-header-beacon"})
  self:addCellHeader(player, itable, "products", {"helmod_result-panel.col-header-products"})
  self:addCellHeader(player, itable, "ingredients", {"helmod_result-panel.col-header-ingredients"})
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#ProductionBlockTab] addTableRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #string blockId
-- @param #table element production recipe
--
function ProductionBlockTab.methods:addTableRow(player, guiTable, block, recipe)
  Logging:debug("ProductionBlockTab", "addTableRow():", player, guiTable, block, recipe)
  local model = self.model:getModel(player)

  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..recipe.id, "helmod_flow_default")
  self:addGuiButton(guiAction, self.parent:classname().."=production-recipe-remove=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  self:addGuiButton(guiAction, self.parent:classname().."=production-recipe-down=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
  self:addGuiButton(guiAction, self.parent:classname().."=production-recipe-up=ID="..block.id.."=", recipe.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
  
  -- col index
  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..recipe.id)
    self:addGuiLabel(guiIndex, "index", recipe.index, "helmod_label_row_right_40")
  end
  -- col id
  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(guiTable,"id"..recipe.id)
    self:addGuiLabel(guiId, "id", recipe.id)
  end
  -- col name
  if self.player:getSettings(player, "display_data_col_name", true) then
    local guiName = self:addGuiFlowH(guiTable,"name"..recipe.id)
    self:addGuiLabel(guiName, "name_", recipe.name)
  end
  -- col recipe
  local production = recipe.production or 1
  local guiRecipe = self:addCellLabel(player, guiTable, "recipe-"..recipe.id, self:formatPercent(production).."%", 35)
  self:addIconRecipeCell(player, guiRecipe, recipe, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)

  -- col energy
  local guiEnergy = self:addCellLabel(player, guiTable, "energy-"..recipe.id, self:formatNumberKilo(recipe.energy_total, "W"), 50)

  -- col factory
  local factory = recipe.factory
  local guiFactory = self:addCellLabel(player, guiTable, "factory-"..recipe.id, self:formatNumberFactory(factory.limit_count).."/"..self:formatNumberFactory(factory.count), 60)
  self:addIconCell(player, guiFactory, factory, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)
  local col_size = 2
  if display_cell_mod == "small-icon" then col_size = 5 end
  local guiFactoryModule = self:addGuiTable(guiFactory,"factory-modules"..recipe.name, col_size, "helmod_factory_modules")
  -- modules
  for name, count in pairs(factory.modules) do
    for index = 1, count, 1 do
      local module = self.player:getItemPrototype(name)
      if module ~= nil then
        local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
        local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
        local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
        local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
        local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
        self:addGuiButtonSpriteSm(guiFactoryModule, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
      else
        self:addGuiButtonSpriteSm(guiFactoryModule, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name)
      end
      index = index + 1
    end
  end

  -- col beacon
  local beacon = recipe.beacon
  local guiBeacon = self:addCellLabel(player, guiTable, "beacon-"..recipe.id, self:formatNumberFactory(beacon.limit_count).."/"..self:formatNumberFactory(beacon.count), 60)
  self:addIconCell(player, guiBeacon, beacon, "HMRecipeEdition=OPEN=ID="..block.id.."="..recipe.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)
  local col_size = 1
  if display_cell_mod == "small-icon" then col_size = 5 end
  local guiBeaconModule = self:addGuiTable(guiBeacon,"beacon-modules"..recipe.name, col_size, "helmod_beacon_modules")
  -- modules
  for name, count in pairs(beacon.modules) do
    for index = 1, count, 1 do
      local module = self.player:getItemPrototype(name)
      if module ~= nil then
        local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
        local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
        local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
        local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
        local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
        self:addGuiButtonSpriteSm(guiBeaconModule, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
      else
        self:addGuiButtonSpriteSm(guiBeaconModule, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name)
      end
      index = index + 1
    end
  end

  -- products
  local display_product_cols = self.player:getSettings(player, "display_product_cols")
  local tProducts = self:addGuiTable(guiTable,"products_"..recipe.id, display_product_cols)
  if recipe.products ~= nil then
    for r, product in pairs(recipe.products) do
      self:addCellElement(player, tProducts, product, "HMProduct=OPEN=ID="..block.id.."="..recipe.name.."=", false, "tooltip.product", nil)
    end

  end
  -- ingredients
  local display_ingredient_cols = self.player:getSettings(player, "display_ingredient_cols")
  local tIngredient = self:addGuiTable(guiTable,"ingredients_"..recipe.id, display_ingredient_cols)
  if recipe.ingredients ~= nil then
    for r, ingredient in pairs(recipe.ingredients) do
      self:addCellElement(player, tIngredient, ingredient, self.parent:classname().."=production-recipe-add=ID="..block.id.."="..recipe.name.."=", true, "tooltip.add-recipe", self.color_button_add)
    end
  end
end
