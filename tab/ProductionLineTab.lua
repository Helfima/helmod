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
-- Is visible
--
-- @function [parent=#ProductionBlockTab] isVisible
--
-- @return boolean
--
function ProductionLineTab:isVisible()
  return false
end
-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductionLineTab] getInfoPanel
--
function ProductionLineTab:getInfoPanel()
  local parent_panel = self:getFramePanel("info-model")
  local panel_name = "info"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name]["info"]["info-scroll"],parent_panel[panel_name]["output"]["output-scroll"],parent_panel[panel_name]["input"]["input-scroll"]
  end

  local model = self:getParameterObjects()

  local panel = GuiElement.add(parent_panel, GuiFlowH(panel_name))
  panel.style.horizontally_stretchable = true
  panel.style.horizontal_spacing=10
  self:setStyle(panel, "block_info", "height")

  local info_panel = GuiElement.add(panel, GuiFlowV("info"))

  local tooltip = GuiTooltipModel("tooltip.info-model"):element(model)
  GuiElement.add(info_panel, GuiLabel("label-info"):caption({"",self:getButtonCaption(), " [img=info]"}):style("heading_1_label"):tooltip(tooltip))

  self:setStyle(info_panel, "block_info", "width")
  local info_scroll = GuiElement.add(info_panel, GuiScroll("info-scroll"):style("helmod_scroll_pane"))
  info_scroll.style.horizontally_stretchable = true

  local output_panel = GuiElement.add(panel, GuiFlowV("output"))
  GuiElement.add(output_panel, GuiLabel("label-info"):caption({"helmod_common.output"}):style("helmod_label_title_frame"))
  self:setStyle(output_panel, "block_info", "height")
  local output_scroll = GuiElement.add(output_panel, GuiScroll("output-scroll"):style("helmod_scroll_pane"))


  local input_panel = GuiElement.add(panel, GuiFlowV("input"))
  GuiElement.add(input_panel, GuiLabel("label-info"):caption({"helmod_common.input"}):style("helmod_label_title_frame"))
  self:setStyle(input_panel, "block_info", "height")
  local input_scroll = GuiElement.add(input_panel, GuiScroll("input-scroll"):style("helmod_scroll_pane"))
  return info_scroll, output_scroll, input_scroll
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateInfo
--
-- @param #LuaEvent event
--
function ProductionLineTab:updateInfo(event)
  local model = self:getParameterObjects()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  info_scroll.clear()
  -- info panel

  local info_panel = GuiElement.add(info_scroll, GuiFlowV("block-info"))
  info_panel.style.horizontally_stretchable = false
  info_panel.style.vertical_spacing=4
  
  local block_info = GuiElement.add(info_panel, GuiFlowH("information"))
  block_info.style.horizontally_stretchable = false
  block_info.style.horizontal_spacing=10

  local count_block = table.size(model.blocks)
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

  self:addSharePanel(info_panel, model)
  
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductionLineTab] updateInput
--
-- @param #LuaEvent event
--
function ProductionLineTab:updateInput(event)
  local model = self:getParameterObjects()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  input_scroll.clear()
  -- input panel

  local count_block = table.size(model.blocks)
  if count_block > 0 then

    local input_table = GuiElement.add(input_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    if model.ingredients ~= nil then
      for index, element in spairs(model.ingredients, User.getProductSorter()) do
        element.time = model.time
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
  local model = self:getParameterObjects()
  -- data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel()
  output_scroll.clear()
  -- ouput panel

  -- production block result
  local count_block = table.size(model.blocks)
  if count_block > 0 then

    -- ouput panel
    local output_table = GuiElement.add(output_scroll, GuiTable("output-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    if model.products ~= nil then
      for index, element in spairs(model.products, User.getProductSorter()) do
        element.time = model.time
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
  local model = self:getParameterObjects()

  self:updateInfo(event)
  self:updateOutput(event)
  self:updateInput(event)

  -- data panel
  local scroll_panel = self:getResultScrollPanel()

  local countBlock = table.size(model.blocks)
  if countBlock > 0 then
    -- data panel
    local extra_cols = 0
    if User.getPreferenceSetting("display_pollution") then
      extra_cols = extra_cols + 1
    end
    if User.getPreferenceSetting("display_building") then
      extra_cols = extra_cols + 1
    end
    
    if User.getModGlobalSetting("display_hidden_column") == "All" then
      extra_cols = extra_cols + 2
    end
    -- col name
    if User.getModGlobalSetting("display_hidden_column") ~= "None" then
      extra_cols = extra_cols + 1
    end

    local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(5 + extra_cols):style("helmod_table_result"))
    result_table.style.horizontally_stretchable = false
    result_table.vertical_centering = false

    self:addTableHeader(result_table)

    local last_element = nil
    for _, block in spairs(model.blocks, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
      local element_cell = self:addTableRow(result_table, model, block)
      if User.getParameter("scroll_element") == block.id then last_element = element_cell end
    end

    if last_element ~= nil then
      scroll_panel.scroll_to_element(last_element)
      User.setParameter("scroll_element", nil)
    end
  else
    local empty_panel = GuiElement.add(scroll_panel, GuiFlowH("empty"))
    empty_panel.style.horizontal_spacing=10
    GuiElement.add(empty_panel, GuiButton("HMRecipeSelector", "OPEN", model.id, "new"):sprite("menu", "wrench", "wrench"):style("helmod_button_menu_actived_green"):tooltip({"helmod_result-panel.add-button-recipe"}))
    GuiElement.add(empty_panel, GuiLabel("label-explain"):caption({"helmod_label.first-recipe-explain"}):style("heading_1_label"))
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
  AbstractTab.onEvent(self, event)
  local model, block, _ = self:getParameterObjects(event)

  if block == nil then
    block = model.blocks[event.item2]
  end

  local selector_name = "HMRecipeSelector"
  if block ~= nil and block.isEnergy then
    selector_name = "HMEnergySelector"
  end
  -- user writer
  if not(User.isWriter(model)) then return end
  
  if event.action == "production-block-product-add" then
    event.item2 = "new"
    if event.button == defines.mouse_button_type.right then
      Controller:send("on_gui_open", event, "HMRecipeSelector")
    else
      local recipes = Player.searchRecipe(event.item3, true)
      if #recipes == 1 then
        local recipe = recipes[1]
        local new_block = ModelBuilder.addRecipeIntoProductionBlock(model, nil, recipe.name, recipe.type, 0)
        event.item2 = new_block.id
        ModelCompute.update(model)
        Controller:send("on_gui_open", event,"HMProductionBlockTab")
      else
        -- pour ouvrir avec le filtre ingredient
        event.button = defines.mouse_button_type.right
        Controller:send("on_gui_open", event,"HMRecipeSelector")
      end
    end
  end
  if event.action == "production-block-ingredient-add" then
    event.item2 = "new"
    if event.button == defines.mouse_button_type.right then
      Controller:send("on_gui_open", event, "HMRecipeSelector")
    else
      local recipes = Player.searchRecipe(event.item3)
      if #recipes == 1 then
        local recipe = recipes[1]
        local new_block = ModelBuilder.addRecipeIntoProductionBlock(model, nil, recipe.name, recipe.type)
        event.item2 = new_block.id
        ModelCompute.update(model)
        Controller:send("on_gui_open", event,"HMProductionBlockTab")
      else
        Controller:send("on_gui_open", event,"HMRecipeSelector")
      end
    end
  end

  if event.action == "production-block-up" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.upProductionBlock(model, block, step)
    ModelCompute.update(model)
    User.setParameter("scroll_element", block.id)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-block-down" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.downProductionBlock(model, block, step)
    ModelCompute.update(model)
    User.setParameter("scroll_element", block.id)
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
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- optionnal columns
  if User.getModGlobalSetting("display_hidden_column") == "All" then
    self:addCellHeader(itable, "index", {"helmod_result-panel.col-header-index"},"index")
    self:addCellHeader(itable, "id", {"helmod_result-panel.col-header-id"},"id")
  end
  if User.getModGlobalSetting("display_hidden_column") ~= "None" then
    self:addCellHeader(itable, "name", {"helmod_result-panel.col-header-name"},"name")
  end
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
function ProductionLineTab:addTableRow(gui_table, model, block)
  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end
  local block_by_product = not(block ~= nil and block.by_product == false)
  block.type = "recipe"
  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", block.id):column(2))

  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-up", model.id, block.id):sprite("menu", "arrow-up-sm", "arrow-up-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-remove", model.id, block.id):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-down", model.id, block.id):sprite("menu", "arrow-down-sm", "arrow-down-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  if unlinked then
    GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink", model.id, block.id):sprite("menu", "unlink-sm", "unlink-sm"):style("helmod_button_menu_sm"):tooltip({"tooltip.unlink-element"}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink", model.id, block.id):sprite("menu", "link-white-sm", "link-sm"):style("helmod_button_menu_sm_selected"):tooltip({"tooltip.unlink-element"}))
  end

  if User.getModGlobalSetting("display_hidden_column") == "All" then
    -- col index
    GuiElement.add(gui_table, GuiLabel("cell_index", block.id):caption(block.index))
    -- col id
    GuiElement.add(gui_table, GuiLabel("cell_id", block.id):caption(block.id))
  end
  if User.getModGlobalSetting("display_hidden_column") ~= "None" then
    -- col name
    GuiElement.add(gui_table, GuiLabel("cell_name", block.id):caption(block.name))
  end

  -- col recipe
  local cell_recipe = GuiElement.add(gui_table, GuiTable("recipe", block.id):column(1))

  local block_color = "gray"
  if not(block_by_product) then block_color = "orange" end
  GuiElement.add(cell_recipe, GuiCellBlock(self.classname, "change-tab", "HMProductionBlockTab", model.id, block.id):element(block):infoIcon(block.type):tooltip("tooltip.edit-block"):color(block_color))

  -- col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable(block.id, "energy"):column(1))
  local element_block = {name=block.name, power=block.power, pollution_total=block.pollution_total, summary=block.summary}
  GuiElement.add(cell_energy, GuiCellEnergy(self.classname, "change-tab", "HMProductionBlockTab", model.id, block.id):element(element_block):tooltip("tooltip.edit-block"):color(block_color))

  -- col pollution
  if User.getPreferenceSetting("display_pollution") then
    local cell_pollution = GuiElement.add(gui_table, GuiTable(block.id, "pollution"):column(1))
    GuiElement.add(cell_pollution, GuiCellPollution(self.classname, "change-tab", "HMProductionBlockTab", model.id, block.id):element(element_block):tooltip("tooltip.edit-block"):color(block_color))
  end
  
  -- col building
  if User.getPreferenceSetting("display_building") then
    local cell_building = GuiElement.add(gui_table, GuiTable(block.id, "building"):column(1))
    GuiElement.add(cell_building, GuiCellBuilding(self.classname, "change-tab", "HMProductionBlockTab", model.id, block.id):element(element_block):tooltip("tooltip.info-building"):color(block_color))
  end

  local product_sorter = User.getProductSorter()

  -- products
  local display_product_cols = User.getPreferenceSetting("display_product_cols") + 1
  local cell_products = GuiElement.add(gui_table, GuiTable("products", block.id):column(display_product_cols))
  cell_products.style.horizontally_stretchable = false
  if block.products ~= nil then
    for index, product in spairs(block.products, product_sorter) do
      if ((product.state or 0) == 1 and block_by_product)  or (product.count or 0) > ModelCompute.waste_value then
        product.time = model.time
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
        GuiElement.add(cell_products, GuiCellElement(self.classname, button_action, model.id, block.id, product.name):element(product):tooltip(button_tooltip):color(button_color):index(index))
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
        ingredient.time = model.time
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
        GuiElement.add(cell_ingredients, GuiCellElement(self.classname, button_action, model.id, block.id, ingredient.name):element(ingredient):tooltip(button_tooltip):color(button_color):index(index))
      end
    end
  end
  return cell_recipe
end
