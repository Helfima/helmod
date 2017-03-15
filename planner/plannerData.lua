-------------------------------------------------------------------------------
-- Classe to build result dialog
--
-- @module PlannerData
-- @extends #ElementGui
--

PlannerData = setclass("HMPlannerData", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlannerData] init
--
-- @param #PlannerController parent parent controller
--
function PlannerData.methods:init(parent)
  self.parent = parent
  self.player = self.parent.parent
  self.model = self.parent.model

  self.PRODUCTION_BLOCK_TAB = "product-block"
  self.PRODUCTION_LINE_TAB = "product-line"
  self.SUMMARY_TAB = "summary"
  self.RESOURCES_TAB = "resources"
  self.POWER_TAB = "power"

end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerData] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerData.methods:getParentPanel(player)
  return self.parent:getDataPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#PlannerData] getDataPanel
--
-- @param #LuaPlayer player
--
function PlannerData.methods:getDataPanel(player)
  local parentPanel = self:getParentPanel(player)
  if parentPanel["data"] ~= nil and parentPanel["data"].valid then
    return parentPanel["data"]
  end
  return self:addGuiFlowV(parentPanel, "data", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#PlannerData] getModelPanel
--
-- @param #LuaPlayer player
--
function PlannerData.methods:getModelPanel(player)
  local menuPanel = self.parent:getMenuPanel(player)
  if menuPanel["model"] ~= nil and menuPanel["model"].valid then
    return menuPanel["model"]
  end
  return self:addGuiFrameV(menuPanel, "model", "helmod_frame_default")
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#PlannerData] getMenuPanel
--
-- @param #LuaPlayer player
--
function PlannerData.methods:getMenuPanel(player, caption)
  local dataPanel = self:getDataPanel(player)
  if dataPanel["menu"] ~= nil and dataPanel["menu"].valid then
    return dataPanel["menu"]
  end
  local panel = self:addGuiFrameV(dataPanel, "menu", "helmod_frame_data_menu", caption)
  self.player:setStyle(player, panel, "data", "minimal_width")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerData] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerData.methods:getInfoPanel(player)
  local dataPanel = self:getDataPanel(player)
  if dataPanel["info"] ~= nil and dataPanel["info"].valid then
    return dataPanel["info"]
  end
  return self:addGuiFlowH(dataPanel, "info", "helmod_flow_full_resize_row")
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#PlannerData] getResultPanel
--
-- @param #LuaPlayer player
-- @param #string caption
--
function PlannerData.methods:getResultPanel(player, caption)
  local dataPanel = self:getDataPanel(player)
  if dataPanel["result"] ~= nil and dataPanel["result"].valid then
    return dataPanel["result"]
  end
  local panel = self:addGuiFrameV(dataPanel, "result", "helmod_frame_resize_row_width", caption)
  self.player:setStyle(player, panel, "data", "minimal_width")
  self.player:setStyle(player, panel, "data", "maximal_width")
  return panel
end

-------------------------------------------------------------------------------
-- Build the parent panel
--
-- @function [parent=#PlannerData] buildPanel
--
-- @param #LuaPlayer player
--
function PlannerData.methods:buildPanel(player)
  Logging:debug("PlannerData:buildPanel():",player)
  local model = self.model:getModel(player)

  local globalGui = self.player:getGlobalGui(player)
  if globalGui.currentTab == nil then
    globalGui.currentTab = self.PRODUCTION_LINE_TAB
  end
  if globalGui.currentTab == nil then
    globalGui.order = {name="index", ascendant=true}
  end

  Logging:debug("test version:", model.version, helmod.version)
  if model.version == nil or model.version ~= helmod.version then
    self.model:update(player, true)
  end

  local parentPanel = self:getParentPanel(player)

  if parentPanel ~= nil then
    self:getDataPanel(player)
    self:update(player)
  end
end

-------------------------------------------------------------------------------
-- Send event
--
-- @function [parent=#PlannerData] send_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:send_event(player, element, action, item, item2, item3)
  Logging:debug("PlannerDialog:send_event():",player, element, action, item, item2, item3)
  self:on_event(player, element, action, item, item2, item3)
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerData] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug("PlannerData:on_event():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  local globalGui = self.player:getGlobalGui(player)

  if action == "change-model-index" then
    globalGui.model_index = tonumber(item)
    globalGui.currentTab = self.PRODUCTION_LINE_TAB
    globalGui.currentBlock = "new"

    self:update(player, item, item2, item3)
    self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
    self.parent:send_event(player, "HMPlannerResourceEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerEnergyEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
  end

  if action == "remove-model-index" then
    local model_index = tonumber(item)
    self.model:removeModel(player, model_index)
    globalGui.currentTab = self.PRODUCTION_LINE_TAB
    globalGui.currentBlock = "new"

    self:update(player, item, item2, item3)
    self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
    self.parent:send_event(player, "HMPlannerResourceEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerEnergyEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
  end

  if action == "change-time" then
    model.time = tonumber(item)
    self.model:update(player)
    self:update(player, item, item2, item3)
  end

  if action == "change-tab" then
    globalGui.currentTab = item
    if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
      globalGui.currentBlock = "new"
    end
    globalGui.currentBlock = item2
    self:update(player, item, item2, item3)
    self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
    self.parent:send_event(player, "HMPlannerResourceEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerEnergyEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
  end

  if action == "change-sort" then
    if globalGui.order.name == item then
      globalGui.order.ascendant = not(globalGui.order.ascendant)
    else
      globalGui.order = {name=item, ascendant=true}
    end
    self:update(player, item, item2, item3)
  end

  if action == "production-block-add" then
    if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
      local recipes = self.player:searchRecipe(player, item2)
      Logging:debug("line recipes:",recipes)
      if #recipes == 1 then
        local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, recipes[1].name)
        self.parent.model:update(player)
        globalGui.currentTab = self.PRODUCTION_BLOCK_TAB
        self:update(player, self.PRODUCTION_BLOCK_TAB)
      else
        globalGui.currentTab = self.PRODUCTION_BLOCK_TAB
        self.parent:send_event(player, "HMPlannerRecipeSelector", "OPEN", item, item2, item3)
      end
    end
  end

  if action == "production-block-remove" then
    if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
      self.parent.model:removeProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
    end
  end

  if action == "production-block-up" then
    if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
      self.parent.model:upProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
    end
  end

  if action == "production-block-down" then
    if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
      self.parent.model:downProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
    end
  end

  if action == "production-recipe-add" then
    if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB then
      local recipes = self.player:searchRecipe(player, item3)
      Logging:debug("block recipes:",recipes)
      if #recipes == 1 then
        Logging:debug("recipe name:", recipes[1].name)
        local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, recipes[1].name)
        self.parent.model:update(player)
        self:update(player, self.PRODUCTION_LINE_TAB)
      else
        self.parent:send_event(player, "HMPlannerRecipeSelector", "OPEN", item, item2, item3)
      end
    end
  end

  if action == "production-recipe-remove" then
    if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB then
      self.parent.model:removeProductionRecipe(player, item, item2)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_BLOCK_TAB, item, item2, item3)
    end
  end

  if action == "production-recipe-up" then
    if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB then
      self.parent.model:upProductionRecipe(player, item, item2)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_BLOCK_TAB, item, item2, item3)
    end
  end

  if action == "production-recipe-down" then
    if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB then
      self.parent.model:downProductionRecipe(player, item, item2)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_BLOCK_TAB, item, item2, item3)
    end
  end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerData] update
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:update(player, item, item2, item3)
  Logging:debug("PlannerData:update():", player, item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  local dataPanel = self:getDataPanel(player)

  for k,guiName in pairs(dataPanel.children_names) do
    dataPanel[guiName].destroy()
  end

  self:updateModelPanel(player, item, item2, item3)

  if globalGui.currentTab ~= self.PRODUCTION_BLOCK_TAB then
    self:updateProductionHeader(player, item, item2, item3)
  end

  if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
    self.parent:send_event(player, "HMPlannerProductEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
    self:updateProductionLine(player, item, item2, item3)
  end
  if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB then
    self:updateProductionBlock(player, item, item2, item3)
  end
  if globalGui.currentTab == self.SUMMARY_TAB then
    self:updateSummary(player, item, item2, item3)
  end
  if globalGui.currentTab == self.RESOURCES_TAB then
    self:updateResources(player, item, item2, item3)
  end
  if globalGui.currentTab == self.POWER_TAB then
    self:updatePowers(player, item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- Update model panel
--
-- @function [parent=#PlannerData] updateModelPanel
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:updateModelPanel(player, item, item2, item3)
  Logging:debug("PlannerData:updateModelPanel():", player, item, item2, item3)
  local modelPanel = self:getModelPanel(player)
  local model = self.model:getModel(player)

  for k,guiName in pairs(modelPanel.children_names) do
    modelPanel[guiName].destroy()
  end

  -- time panel
  self:addGuiButton(modelPanel, self:classname().."=base-time", nil, "helmod_button_icon_time", nil, ({"helmod_data-panel.base-time"}))

  local times = {
    { value = 1, name = "1s"},
    { value = 60, name = "1m"},
    { value = 300, name = "5m"},
    { value = 600, name = "10m"},
    { value = 1800, name = "30m"},
    { value = 3600, name = "1h"}
  }
  for _,time in pairs(times) do
    if model.time == time.value then
      self:addGuiLabel(modelPanel, self:classname().."=change-time="..time.value, time.name, "helmod_label_time")
    else
      self:addGuiButton(modelPanel, self:classname().."=change-time=ID=", time.value, "helmod_button_time", time.name)
    end
  end

end

-------------------------------------------------------------------------------
-- Update production header
--
-- @function [parent=#PlannerData] updateProductionHeader
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:updateProductionHeader(player, item, item2, item3)
  Logging:debug("PlannerData:updateLine():", player, item, item2, item3)
  local models = self.model:getModels(player)
  local model_index = self.player:getGlobalGui(player, "model_index")
  if model_index == nil then model_index = 1 end
  -- data
  local menuPanel = self:getMenuPanel(player, ({"helmod_result-panel.tab-title-production-line"}))

  -- index panel
  local indexPanel = self:addGuiFlowH(menuPanel, "index", "helmod_flow_resize_row_width")
  self.player:setStyle(player, indexPanel, "data", "minimal_width")
  self.player:setStyle(player, indexPanel, "data", "maximal_width")

  if #models > 0 then
    for i,model in ipairs(models) do
      if i == model_index then
        self:addGuiLabel(indexPanel, self:classname().."=change-model-index="..i, i, "helmod_label_time")
      else
        self:addGuiButton(indexPanel, self:classname().."=change-model-index=ID=", i, "helmod_button_default", i)
      end
    end
  end
  self:addGuiButton(indexPanel, self:classname().."=change-model-index=ID=", (#models + 1), "helmod_button_default", "+")

  -- action panel
  local actionPanel = self:addGuiFlowH(menuPanel, "action", "helmod_flow_resize_row_width")
  self.player:setStyle(player, actionPanel, "data", "minimal_width")
  self.player:setStyle(player, actionPanel, "data", "maximal_width")
  local tabPanel = self:addGuiFlowH(actionPanel, "tab", "helmod_flow_data_tab")
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_BLOCK_TAB, "helmod_button_default", ({"helmod_result-panel.add-button-production-block"}))
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_LINE_TAB, "helmod_button_default", ({"helmod_result-panel.tab-button-production-line"}))
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.SUMMARY_TAB, "helmod_button_default", ({"helmod_result-panel.tab-button-summary"}))
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.RESOURCES_TAB, "helmod_button_default", ({"helmod_result-panel.tab-button-resources"}))
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.POWER_TAB, "helmod_button_default", ({"helmod_result-panel.tab-button-energy"}))
  local deletePanel = self:addGuiFlowH(actionPanel, "delete", "helmod_flow_default")
  self:addGuiButton(deletePanel, self:classname().."=remove-model-index=ID=", model_index, "helmod_button_default", ({"helmod_result-panel.remove-button-production-line"}))
end
-------------------------------------------------------------------------------
-- Update production line tab
--
-- @function [parent=#PlannerData] updateProductionLine
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:updateProductionLine(player, item, item2, item3)
  Logging:debug("PlannerData:updateProductionLine():", player, item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  local model = self.model:getModel(player)

  -- production line result
  local resultPanel = self:getResultPanel(player, ({"helmod_common.blocks"}))
  -- data panel
  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

  local countBlock = self.model:countBlocks(player)
  if countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")

    local extra_cols = 0
    if globalSettings.display_data_col_name then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_id then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_index then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_level then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_weight then
      extra_cols = extra_cols + 1
    end
    local resultTable = self:addGuiTable(scrollPanel,"list-data",5 + extra_cols, "helmod_table-odd")

    self:addProductionLineHeader(player, resultTable)

    local i = 0
    for _, element in spairs(model.blocks, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addProductionLineRow(player, resultTable, element)
    end

    for i = 1, 1 + extra_cols, 1 do
      self:addGuiLabel(resultTable, "blank-"..i, "")
    end
    self:addGuiLabel(resultTable, "foot-1", ({"helmod_result-panel.col-header-total"}))
    if model.summary ~= nil then
      self:addGuiLabel(resultTable, "energy", self:formatNumberKilo(model.summary.energy, "W"),"helmod_label_right_70")
    end
    self:addGuiLabel(resultTable, "blank-pro", "")
    self:addGuiLabel(resultTable, "blank-ing", "")
  end
end

-------------------------------------------------------------------------------
-- Update production block tab
--
-- @function [parent=#PlannerData] updateProductionBlock
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerData.methods:updateProductionBlock(player, item, item2, item3)
  Logging:debug("PlannerData:updateProductionBlock():", player, item, item2, item3)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  Logging:debug("model:", model)
  -- data
  local menuPanel = self:getMenuPanel(player, ({"helmod_result-panel.tab-title-production-block"}))

  local blockId = "new"
  if globalGui.currentBlock ~= nil then
    blockId = globalGui.currentBlock
  end
  local tabPanel = self:addGuiFlowH(menuPanel, "tab", "helmod_flow_data_tab")
  self:addGuiButton(tabPanel, "HMPlannerRecipeSelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-recipe"}))
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_LINE_TAB, "helmod_button_default", ({"helmod_result-panel.back-button-production-line"}))
  self:addGuiButton(tabPanel, "HMPlannerPinPanel=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.tab-button-pin"}))

  local countRecipes = self.model:countBlockRecipes(player, blockId)
  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    local infoPanel = self:getInfoPanel(player)

    -- info panel
    local blockPanel = self:addGuiFrameV(infoPanel, "block", "helmod_frame_default", ({"helmod_common.block"}))
    local blockScroll = self:addGuiScrollPane(blockPanel, "output-scroll", "helmod_scroll_block_info", "auto", "auto")
    local blockTable = self:addGuiTable(blockScroll,"output-table",2)

    self:addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      self:addGuiLabel(blockTable, "power", self:formatNumberKilo(element.power, "W"),"helmod_label_right_70")
    end

    self:addGuiLabel(blockTable, "label-count", ({"helmod_label.block-number"}))
    if model.summary ~= nil then
      self:addGuiLabel(blockTable, "count", element.count,"helmod_label_right_70")
    end

    local elementPanel = self:addGuiFlowV(infoPanel, "elements", "helmod_flow_default")
    -- ouput panel
    local outputPanel = self:addGuiFrameV(elementPanel, "output", "helmod_frame_resize_row_width", ({"helmod_common.output"}))
    local outputScroll = self:addGuiScrollPane(outputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
    self.player:setStyle(player, outputScroll, "scroll_block_element", "minimal_width")
    self.player:setStyle(player, outputScroll, "scroll_block_element", "maximal_width")

    local outputTable = self:addGuiTable(outputScroll,"output-table",6)
    if element.products ~= nil then
      for r, product in pairs(element.products) do
        if bit32.band(product.state, 1) > 0 then
          -- product = {type="item", name="steel-plate", amount=8}
          local cell = self:addGuiFlowH(outputTable,"production_cell_"..product.name)
          self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
          self:addGuiButtonSelectSprite(cell, "HMPlannerProductEdition=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), ({"tooltip.edit-product", self.player:getLocalisedName(player, product)}))
        end
      end
      for r, product in pairs(element.products) do
        if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
          -- product = {type="item", name="steel-plate", amount=8}
          local cell = self:addGuiFlowH(outputTable,"rest_cell_"..product.name)
          self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
          self:addGuiButtonSelectSprite(cell, "HMPlannerProduct=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), ({"tooltip.rest-product", self.player:getLocalisedName(player, product)}), "red")
        end
      end
      for r, product in pairs(element.products) do
        if product.state == 0 then
          -- product = {type="item", name="steel-plate", amount=8}
          local cell = self:addGuiFlowH(outputTable,"other_cell_"..product.name)
          self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
          self:addGuiButtonSprite(cell, "HMPlannerProduct=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), ({"tooltip.other-product", self.player:getLocalisedName(player, product)}))
        end
      end
    end

    -- input panel
    local inputPanel = self:addGuiFrameV(elementPanel, "input", "helmod_frame_resize_row_width", ({"helmod_common.input"}))
    local outputScroll = self:addGuiScrollPane(inputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
    self.player:setStyle(player, outputScroll, "scroll_block_element", "minimal_width")
    self.player:setStyle(player, outputScroll, "scroll_block_element", "maximal_width")

    local inputTable = self:addGuiTable(outputScroll,"input-table",6)
    if element.ingredients ~= nil then
      for r, ingredient in pairs(element.ingredients) do
        -- ingredient = {type="item", name="steel-plate", amount=8}
        local cell = self:addGuiFlowH(inputTable,"cell_"..ingredient.name)
        self:addGuiLabel(cell, ingredient.name, self:formatNumber(ingredient.count), "helmod_label_right_60")
        self:addGuiButtonSprite(cell, "HMPlannerResourceInfo=OPEN=ID="..element.id.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount, self.player:getLocalisedName(player, ingredient))
      end
    end

    local resultPanel = self:getResultPanel(player, ({"helmod_common.recipes"}))
    -- data panel
    local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
    self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
    self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
    self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
    self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

    local globalSettings = self.player:getGlobal(player, "settings")

    local extra_cols = 0
    if globalSettings.display_data_col_name then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_id then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_index then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_level then
      extra_cols = extra_cols + 1
    end
    if globalSettings.display_data_col_weight then
      extra_cols = extra_cols + 1
    end
    local resultTable = self:addGuiTable(scrollPanel,"list-data",7 + extra_cols, "helmod_table-odd")

    self:addProductionBlockHeader(player, resultTable)

    for _, recipe in spairs(model.blocks[blockId].recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addProductionBlockRow(player, resultTable, blockId, recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PlannerData] addProductionBlockHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerData.methods:addProductionBlockHeader(player, itable)
  Logging:debug("PlannerData:addHeader():", player, itable)
  local model = self.model:getModel(player)
  local globalSettings = self.player:getGlobal(player, "settings")

  local guiAction = self:addGuiFlowH(itable,"header-action")
  self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

  if globalSettings.display_data_col_index then
    local guiIndex = self:addGuiFlowH(itable,"header-index")
    self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
    self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))
  end

  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end
  if globalSettings.display_data_col_name then
    local guiName = self:addGuiFlowH(itable,"header-name")
    self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
    self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", self.player:getSortedStyle(player, "name"))

  end

  local guiRecipe = self:addGuiFlowH(itable,"header-recipe")
  self:addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
  self:addGuiButton(guiRecipe, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))

  local guiFactory = self:addGuiFlowH(itable,"header-factory")
  self:addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))


  local guiBeacon = self:addGuiFlowH(itable,"header-beacon")
  self:addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))

  local guiEnergy = self:addGuiFlowH(itable,"header-energy")
  self:addGuiLabel(guiEnergy, "header-energy", ({"helmod_result-panel.col-header-energy"}))
  self:addGuiButton(guiEnergy, self:classname().."=change-sort=ID=", "energy_total", self.player:getSortedStyle(player, "energy_total"))


  local guiProducts = self:addGuiFlowH(itable,"header-products")
  self:addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-products"}))

  local guiIngredients = self:addGuiFlowH(itable,"header-ingredients")
  self:addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PlannerData] addProductionLineHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerData.methods:addProductionLineHeader(player, itable)
  Logging:debug("PlannerData:addHeader():", player, itable)
  local model = self.model:getModel(player)
  local globalSettings = self.player:getGlobal(player, "settings")

  local guiAction = self:addGuiFlowH(itable,"header-action")
  self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

  if globalSettings.display_data_col_index then
    local guiIndex = self:addGuiFlowH(itable,"header-index")
    self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
    self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))
  end

  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end
  if globalSettings.display_data_col_name then
    local guiName = self:addGuiFlowH(itable,"header-name")
    self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
    self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", self.player:getSortedStyle(player, "name"))

  end

  local guiRecipe = self:addGuiFlowH(itable,"header-recipe")
  self:addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-production-block"}))
  self:addGuiButton(guiRecipe, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))

  local guiEnergy = self:addGuiFlowH(itable,"header-energy")
  self:addGuiLabel(guiEnergy, "header-energy", ({"helmod_result-panel.col-header-energy"}))
  self:addGuiButton(guiEnergy, self:classname().."=change-sort=ID=", "power", self.player:getSortedStyle(player, "power"))

  local guiProducts = self:addGuiFlowH(itable,"header-products")
  self:addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-output"}))

  local guiIngredients = self:addGuiFlowH(itable,"header-ingredients")
  self:addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-input"}))
end

-------------------------------------------------------------------------------
-- Add header resources tab
--
-- @function [parent=#PlannerData] addResourcesHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerData.methods:addResourcesHeader(player, itable)
  Logging:debug("PlannerData:addHeader():", player, itable)
  local model = self.model:getModel(player)
  local globalSettings = self.player:getGlobal(player, "settings")
  if globalSettings.display_data_col_index then
    local guiIndex = self:addGuiFlowH(itable,"header-index")
    self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
    self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))
  end

  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end
  if globalSettings.display_data_col_name then
    local guiName = self:addGuiFlowH(itable,"header-name")
    self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
    self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", self.player:getSortedStyle(player, "name"))

  end

  local guiCount = self:addGuiFlowH(itable,"header-count")
  self:addGuiLabel(guiCount, "header-count", ({"helmod_result-panel.col-header-total"}))
  self:addGuiButton(guiCount, self:classname().."=change-sort=ID=", "count", self.player:getSortedStyle(player, "count"))

  local guiIngredient = self:addGuiFlowH(itable,"header-ingredient")
  self:addGuiLabel(guiIngredient, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
  self:addGuiButton(guiIngredient, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))

  local guiType = self:addGuiFlowH(itable,"header-type")
  self:addGuiLabel(guiType, "header-type", ({"helmod_result-panel.col-header-type"}))
  self:addGuiButton(guiType, self:classname().."=change-sort=ID=", "resource_category", self.player:getSortedStyle(player, "resource_category"))

end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PlannerData] addProductionBlockRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #string blockId
-- @param #table element production recipe
--
function PlannerData.methods:addProductionBlockRow(player, guiTable, blockId, recipe)
  Logging:debug("PlannerData:addProductionBlockRow():", player, guiTable, blockId, recipe)
  local model = self.model:getModel(player)

  local globalSettings = self.player:getGlobal(player, "settings")

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..recipe.name, "helmod_flow_default")
  if recipe.index ~= 0 then
    self:addGuiButton(guiAction, self:classname().."=production-recipe-remove=ID="..blockId.."=", recipe.name, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
    self:addGuiButton(guiAction, self:classname().."=production-recipe-down=ID="..blockId.."=", recipe.name, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
  end
  if recipe.index > 1 then
    self:addGuiButton(guiAction, self:classname().."=production-recipe-up=ID="..blockId.."=", recipe.name, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
  end
  -- col index
  if globalSettings.display_data_col_index then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..recipe.name)
    self:addGuiLabel(guiIndex, "index", recipe.index, "helmod_label_right_40")
  end
  -- col id
  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(guiTable,"id"..recipe.name)
    self:addGuiLabel(guiId, "id", recipe.id)
  end
  -- col name
  if globalSettings.display_data_col_name then
    local guiName = self:addGuiFlowH(guiTable,"name"..recipe.name)
    self:addGuiLabel(guiName, "name", recipe.name)
  end
  -- col recipe
  local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..recipe.name, "helmod_flow_default")
  self:addGuiButtonSelectSprite(guiRecipe, "HMPlannerRecipeEdition=OPEN=ID="..blockId.."=", self.player:getRecipeIconType(player, recipe), recipe.name, recipe.name, ({"tooltip.edit-recipe", self.player:getRecipeLocalisedName(player, recipe)}))
  local production = 1
  if recipe.production ~= nil then production = recipe.production end
  self:addGuiLabel(guiRecipe, "production", self:formatPercent(production).."%", "helmod_label_right_40")

  -- col factory
  local guiFactory = self:addGuiFlowH(guiTable,"factory"..recipe.name, "helmod_flow_default")
  local factory = recipe.factory
  self:addGuiLabel(guiFactory, factory.name, self:formatNumber(factory.limit_count).."/"..self:formatNumber(factory.count), "helmod_label_right_70")
  self:addGuiButtonSelectSprite(guiFactory, "HMPlannerRecipeEdition=OPEN=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(factory), factory.name, factory.name, ({"tooltip.edit-recipe", self.player:getRecipeLocalisedName(player, recipe)}))
  local guiFactoryModule = self:addGuiTable(guiFactory,"factory-modules"..recipe.name, 2, "helmod_factory_modules")
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
        self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
      else
        self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name)
      end
      index = index + 1
    end
  end

  -- col beacon
  local guiBeacon = self:addGuiFlowH(guiTable,"beacon"..recipe.name, "helmod_flow_default")
  local beacon = recipe.beacon
  self:addGuiLabel(guiBeacon, beacon.name, self:formatNumber(beacon.limit_count).."/"..self:formatNumber(beacon.count), "helmod_label_right_70")
  self:addGuiButtonSelectSprite(guiBeacon, "HMPlannerRecipeEdition=OPEN=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, ({"tooltip.edit-recipe", self.player:getRecipeLocalisedName(player, recipe)}))
  local guiBeaconModule = self:addGuiTable(guiBeacon,"beacon-modules"..recipe.name, 1, "helmod_beacon_modules")
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
        self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
      else
        self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name)
      end
      index = index + 1
    end
  end

  -- col energy
  local guiEnergy = self:addGuiFlowH(guiTable,"energy"..recipe.name)
  self:addGuiLabel(guiEnergy, recipe.name, self:formatNumberKilo(recipe.energy_total, "W"), "helmod_label_right_70")

  -- products
  local display_product_cols = self.player:getGlobalSettings(player, "display_product_cols")
  local tProducts = self:addGuiTable(guiTable,"products_"..recipe.name, display_product_cols)
  if recipe.products ~= nil then
    for r, product in pairs(recipe.products) do
      local cell = self:addGuiFlowH(tProducts,"cell_"..product.name, "helmod_flow_default")
      self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
      -- product = {type="item", name="steel-plate", amount=8}
      self:addGuiButtonSprite(cell, "HMPlannerResourceInfo=OPEN=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), self.player:getLocalisedName(player, product))
    end
  end
  -- ingredients
  local display_ingredient_cols = self.player:getGlobalSettings(player, "display_ingredient_cols")
  local tIngredient = self:addGuiTable(guiTable,"ingredients_"..recipe.name, display_ingredient_cols)
  if recipe.ingredients ~= nil then
    for r, ingredient in pairs(recipe.ingredients) do
      local cell = self:addGuiFlowH(tIngredient,"cell_"..ingredient.name, "helmod_flow_default")
      self:addGuiLabel(cell, ingredient.name, self:formatNumber(ingredient.count), "helmod_label_right_60")
      -- ingredient = {type="item", name="steel-plate", amount=8}
      self:addGuiButtonSelectSprite(cell, self:classname().."=production-recipe-add=ID="..blockId.."="..recipe.name.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount, ({"tooltip.add-recipe", self.player:getLocalisedName(player, ingredient)}), "yellow")
    end
  end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PlannerData] addProductionLineRow
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #table element production block
--
function PlannerData.methods:addProductionLineRow(player, guiTable, element)
  Logging:debug("PlannerData:addProductionLineRow():", player, guiTable, element)
  local model = self.model:getModel(player)

  local globalSettings = self.player:getGlobal(player, "settings")

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..element.id, "helmod_flow_default")
  self:addGuiButton(guiAction, self:classname().."=production-block-remove=ID=", element.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  self:addGuiButton(guiAction, self:classname().."=production-block-down=ID=", element.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
  self:addGuiButton(guiAction, self:classname().."=production-block-up=ID=", element.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
  -- col index
  if globalSettings.display_data_col_index then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..element.id)
    self:addGuiLabel(guiIndex, "index", element.index, "helmod_label_right_40")
  end
  -- col id
  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(guiTable,"id"..element.id)
    self:addGuiLabel(guiId, "id", element.id)
  end
  -- col name
  if globalSettings.display_data_col_name then
    local guiName = self:addGuiFlowH(guiTable,"name"..element.id)
    self:addGuiLabel(guiName, "name", element.id)
  end
  -- col recipe
  local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..element.id)
  self:addGuiButtonSelectSprite(guiRecipe, self:classname().."=change-tab=ID="..self.PRODUCTION_BLOCK_TAB.."="..element.id.."=", self.player:getRecipeIconType(player, element), element.name, element.name, ({"tooltip.edit-block"}))

  -- col energy
  local guiEnergy = self:addGuiFlowH(guiTable,"energy"..element.id)
  self:addGuiLabel(guiEnergy, element.id, self:formatNumberKilo(element.power, "W"), "helmod_label_right_70")

  -- products
  local display_product_cols = self.player:getGlobalSettings(player, "display_product_cols") + 1
  local tProducts = self:addGuiTable(guiTable,"products_"..element.id, display_product_cols)
  if element.products ~= nil then
    for r, product in pairs(element.products) do
      if bit32.band(product.state, 1) > 0 then
        -- product = {type="item", name="steel-plate", amount=8}
        local cell = self:addGuiFlowH(tProducts,"production_cell_"..product.name, "helmod_flow_default")
        self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
        self:addGuiButtonSelectSprite(cell, "HMPlannerProductEdition=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), ({"tooltip.edit-product", self.player:getLocalisedName(player, product)}))
      end
    end
    for r, product in pairs(element.products) do
      if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
        -- product = {type="item", name="steel-plate", amount=8}
        local cell = self:addGuiFlowH(tProducts,"rest_cell_"..product.name, "helmod_flow_default")
        self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
        self:addGuiButtonSelectSprite(cell, "HMPlannerProduct=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), ({"tooltip.rest-product", self.player:getLocalisedName(player, product)}), "red")
      end
    end
    for r, product in pairs(element.products) do
      if product.state == 0 then
        -- product = {type="item", name="steel-plate", amount=8}
        local cell = self:addGuiFlowH(tProducts,"other_cell_"..product.name, "helmod_flow_default")
        self:addGuiLabel(cell, product.name, self:formatNumber(product.count), "helmod_label_right_60")
        self:addGuiButtonSprite(cell, "HMPlannerProduct=OPEN=ID="..element.id.."=", self.player:getIconType(product), product.name, "X"..self.model:getElementAmount(product), ({"tooltip.other-product", self.player:getLocalisedName(player, product)}))
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = self.player:getGlobalSettings(player, "display_ingredient_cols") + 2
  local tIngredient = self:addGuiTable(guiTable,"ingredients_"..element.id, display_ingredient_cols)
  if element.ingredients ~= nil then
    for r, ingredient in pairs(element.ingredients) do
      -- ingredient = {type="item", name="steel-plate", amount=8}
      local cell = self:addGuiFlowH(tIngredient,"cell_"..ingredient.name, "helmod_flow_default")
      self:addGuiLabel(cell, ingredient.name, self:formatNumber(ingredient.count), "helmod_label_right_60")
      self:addGuiButtonSelectSprite(cell, self:classname().."=production-block-add=ID="..element.id.."="..ingredient.name.."=", self.player:getIconType(ingredient), ingredient.name, "X"..ingredient.amount, ({"tooltip.add-recipe", self.player:getLocalisedName(player, ingredient)}), "yellow")
    end
  end
end

-------------------------------------------------------------------------------
-- Add row resources tab
--
-- @function [parent=#PlannerData] addResourcesRow
--
-- @param #LuaPlayer player
--
function PlannerData.methods:addResourcesRow(player, guiTable, ingredient)
  Logging:debug("PlannerData:addRow():", player, guiTable, ingredient)
  local model = self.model:getModel(player)

  local globalSettings = self.player:getGlobal(player, "settings")
  -- col index
  if globalSettings.display_data_col_index then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..ingredient.name)
    self:addGuiLabel(guiIndex, "index", ingredient.index)
  end
  -- col level
  if globalSettings.display_data_col_level then
    local guiLevel = self:addGuiFlowH(guiTable,"level"..ingredient.name)
    self:addGuiLabel(guiLevel, "level", ingredient.level)
  end
  -- col weight
  if globalSettings.display_data_col_weight then
    local guiLevel = self:addGuiFlowH(guiTable,"weight"..ingredient.name)
    self:addGuiLabel(guiLevel, "weight", ingredient.weight)
  end
  -- col id
  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(guiTable,"id"..ingredient.name)
    self:addGuiLabel(guiId, "id", ingredient.id)
  end
  -- col name
  if globalSettings.display_data_col_name then
    local guiName = self:addGuiFlowH(guiTable,"name"..ingredient.name)
    self:addGuiLabel(guiName, "name", ingredient.name)
  end
  -- col count
  local guiCount = self:addGuiFlowH(guiTable,"count"..ingredient.name)
  self:addGuiLabel(guiCount, ingredient.name, self:formatNumber(ingredient.count), "helmod_label_right_60")

  -- col ingredient
  local guiIngredient = self:addGuiFlowH(guiTable,"ingredient"..ingredient.name)
  self:addGuiButtonSprite(guiIngredient, "HMPlannerIngredient=OPEN=ID=", self.player:getIconType(ingredient), ingredient.name, ingredient.name, self.player:getLocalisedName(player, ingredient))

  -- col type
  local guiType = self:addGuiFlowH(guiTable,"type"..ingredient.name)
  self:addGuiLabel(guiType, ingredient.name, ingredient.resource_category)

end

-------------------------------------------------------------------------------
-- Update resources tab
--
-- @function [parent=#PlannerData] updateResources
--
-- @param #LuaPlayer player
--
function PlannerData.methods:updateResources(player)
  Logging:debug("PlannerData:updateResources():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  -- data
  local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-resources"}))
  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")


  local globalSettings = self.player:getGlobal(player, "settings")

  local extra_cols = 0
  if globalSettings.display_data_col_name then
    extra_cols = extra_cols + 1
  end
  if globalSettings.display_data_col_id then
    extra_cols = extra_cols + 1
  end
  if globalSettings.display_data_col_index then
    extra_cols = extra_cols + 1
  end
  if globalSettings.display_data_col_level then
    extra_cols = extra_cols + 1
  end
  if globalSettings.display_data_col_weight then
    extra_cols = extra_cols + 1
  end
  local resultTable = self:addGuiTable(scrollPanel,"table-resources",3 + extra_cols)

  self:addResourcesHeader(player, resultTable)


  for _, recipe in spairs(model.ingredients, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
    self:addResourcesRow(player, resultTable, recipe)
  end
end

-------------------------------------------------------------------------------
-- Update summary tab
--
-- @function [parent=#PlannerData] updateSummary
--
-- @param #LuaPlayer player
--
function PlannerData.methods:updateSummary(player)
  Logging:debug("PlannerData:updateSummary():", player)
  local model = self.model:getModel(player)
  -- data
  local menuPanel = self:getMenuPanel(player, ({"helmod_result-panel.tab-title-summary"}))
  local dataPanel = self:getDataPanel(player)

  -- resources
  local resourcesPanel = self:addGuiFrameV(dataPanel, "resources", "helmod_frame_resize_row_width", ({"helmod_common.resources"}))
  self.player:setStyle(player, resourcesPanel, "data", "minimal_width")
  self.player:setStyle(player, resourcesPanel, "data", "maximal_width")

  local resourcesTable = self:addGuiTable(resourcesPanel,"table-resources",7)
  self:addGuiLabel(resourcesTable, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
  self:addGuiLabel(resourcesTable, "header-block", ({"helmod_result-panel.col-header-production-block"}))
  self:addGuiLabel(resourcesTable, "header-cargo-wagon", ({"helmod_result-panel.col-header-wagon"}))
  self:addGuiLabel(resourcesTable, "header-chest", ({"helmod_result-panel.col-header-storage"}))
  self:addGuiLabel(resourcesTable, "header-extractor", ({"helmod_result-panel.col-header-extractor"}))
  self:addGuiLabel(resourcesTable, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
  self:addGuiLabel(resourcesTable, "header-energy", ({"helmod_result-panel.col-header-energy"}))

  for _, resource in pairs(model.resources) do
    -- ingredient
    local guiIngredient = self:addGuiFlowH(resourcesTable,"ingredient"..resource.name)
    self:addGuiLabel(guiIngredient, "count", self:formatNumber(resource.count), "helmod_label_right_60")
    self:addGuiButtonSprite(guiIngredient, "HMPlannerIngredient=OPEN=ID=", self.player:getItemIconType(resource), resource.name, resource.name, self.player:getLocalisedName(player, resource))

    -- col block
    local guiBlock = self:addGuiFlowH(resourcesTable,"block"..resource.name)
    self:addGuiLabel(guiBlock, "count", self:formatNumber(resource.blocks), "helmod_label_right_50")

    -- col wagon
    local wagon = resource.wagon
    local guiWagon = self:addGuiFlowH(resourcesTable,"wagon"..resource.name)
    if wagon ~= nil then
      self:addGuiLabel(guiWagon, "count", self:formatNumber(wagon.limit_count).."/"..self:formatNumber(wagon.count), "helmod_label_right_70")
      self:addGuiButtonSprite(guiWagon, "HMPlannerWagon=OPEN=ID=", self.player:getIconType(wagon), wagon.name, wagon.name, self.player:getLocalisedName(player, wagon))
    end

    -- col storage
    local storage = resource.storage
    local guiStorage = self:addGuiFlowH(resourcesTable,"storage"..resource.name)
    if storage ~= nil then
      self:addGuiLabel(guiStorage, "count", self:formatNumber(storage.limit_count).."/"..self:formatNumber(storage.count), "helmod_label_right_70")
      self:addGuiButtonSprite(guiStorage, "HMPlannerStorage=OPEN=ID=", self.player:getIconType(storage), storage.name, storage.name, self.player:getLocalisedName(player, storage))
    end

    -- factory
    local guiFactory = self:addGuiFlowH(resourcesTable,"extractor"..resource.name)
    local factory = resource.factory
    if factory ~= nil then
      self:addGuiLabel(guiFactory, "factory", self:formatNumber(factory.limit_count).."/"..self:formatNumber(factory.count), "helmod_label_right_70")
      self:addGuiButtonSelectSprite(guiFactory, "HMPlannerResourceEdition=OPEN=ID=resource="..resource.name.."=", self.player:getIconType(factory), factory.name, factory.name, ({"tooltip.edit-resource", self.player:getLocalisedName(player, resource)}))
      local guiFactoryModule = self:addGuiTable(guiFactory,"factory-modules"..resource.name, 2, "helmod_factory_modules")
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
            self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
          else
            self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name)
          end
          index = index + 1
        end
      end
    else
      self:addGuiLabel(guiFactory, "factory", "Data need update")
    end

    -- beacon
    local guiBeacon = self:addGuiFlowH(resourcesTable,"beacon"..resource.name)
    local beacon = resource.beacon
    if beacon ~= nil then
      self:addGuiLabel(guiBeacon, "beacon", self:formatNumberKilo(resource.beacon.count), "helmod_label_right_70")
      self:addGuiButtonSelectSprite(guiBeacon, "HMPlannerResourceEdition=OPEN=ID=resource="..resource.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, ({"tooltip.edit-resource", self.player:getLocalisedName(player, resource)}))
      local guiBeaconModule = self:addGuiTable(guiBeacon,"beacon-modules"..resource.name, 1, "helmod_beacon_modules")
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
            self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
          else
            self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name)
          end
          index = index + 1
        end
      end
    else
      self:addGuiLabel(guiBeacon, "beacon", "Data need update")
    end

    -- col energy
    local guiEnergy = self:addGuiFlowH(resourcesTable,"energy"..resource.name)
    self:addGuiLabel(guiEnergy, resource.name, self:formatNumberKilo(resource.energy_total, "W"), "helmod_label_right_70")
  end

  local energyPanel = self:addGuiFrameV(dataPanel, "energy", "helmod_frame_resize_row_width", ({"helmod_common.generators"}))
  self.player:setStyle(player, energyPanel, "data", "minimal_width")
  self.player:setStyle(player, energyPanel, "data", "maximal_width")

  local resultTable = self:addGuiTable(energyPanel,"table-energy",2)

  for _, item in pairs(model.generators) do
    local guiCell = self:addGuiFlowH(resultTable,"cell_"..item.name)
    self:addGuiLabel(guiCell, item.name, self:formatNumberKilo(item.count), "helmod_label_right_50")
    self:addGuiButtonSprite(guiCell, "HMPlannerGenerator=OPEN=ID=", "item", item.name, item.name, self.player:getLocalisedName(player, item))
  end

  -- factories
  local factoryPanel = self:addGuiFrameV(dataPanel, "factory", "helmod_frame_resize_row_width", ({"helmod_common.factories"}))
  self.player:setStyle(player, factoryPanel, "data", "minimal_width")
  self.player:setStyle(player, factoryPanel, "data", "maximal_width")

  local resultTable = self:addGuiTable(factoryPanel,"table-factory",10)

  for _, element in pairs(model.summary.factories) do
    local guiCell = self:addGuiFlowH(resultTable,"cell_"..element.name)
    self:addGuiLabel(guiCell, element.name, self:formatNumberKilo(element.count), "helmod_label_right_50")
    self:addGuiButtonSprite(guiCell, "HMPlannerFactories=OPEN=ID=", "item", element.name, element.name, self.player:getLocalisedName(player, element))
  end

  -- beacons
  local beaconPanel = self:addGuiFrameV(dataPanel, "beacon", "helmod_frame_resize_row_width", ({"helmod_common.beacons"}))
  self.player:setStyle(player, beaconPanel, "data", "minimal_width")
  self.player:setStyle(player, beaconPanel, "data", "maximal_width")

  local resultTable = self:addGuiTable(beaconPanel,"table-beacon",10)

  for _, element in pairs(model.summary.beacons) do
    local guiCell = self:addGuiFlowH(resultTable,"cell_"..element.name)
    self:addGuiLabel(guiCell, element.name, self:formatNumberKilo(element.count), "helmod_label_right_50")
    self:addGuiButtonSprite(guiCell, "HMPlannerBeacons=OPEN=ID=", "item", element.name, element.name, self.player:getLocalisedName(player, element))
  end

  -- modules
  local modulesPanel = self:addGuiFrameV(dataPanel, "modules", "helmod_frame_resize_row_width", ({"helmod_common.modules"}))
  self.player:setStyle(player, modulesPanel, "data", "minimal_width")
  self.player:setStyle(player, modulesPanel, "data", "maximal_width")

  local resultTable = self:addGuiTable(modulesPanel,"table-modules",10)

  for _, element in pairs(model.summary.modules) do
    -- col icon
    local guiCell = self:addGuiFlowH(resultTable,"cell_"..element.name)
    self:addGuiLabel(guiCell, element.name, self:formatNumberKilo(element.count), "helmod_label_right_50")
    self:addGuiButtonSprite(guiCell, "HMPlannerModules=OPEN=ID=", "item", element.name, element.name, self.player:getLocalisedName(player, element))
  end
end


-------------------------------------------------------------------------------
-- Update power tab
--
-- @function [parent=#PlannerData] updatePowers
--
-- @param #LuaPlayer player
--
function PlannerData.methods:updatePowers(player)
  Logging:debug("PlannerData:updateSummary():", player)
  local model = self.model:getModel(player)

  -- data
  local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-energy"}))

  local menuPanel = self:addGuiFlowH(resultPanel,"menu")
  self:addGuiButton(menuPanel, "HMPlannerEnergyEdition=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.add-button-power"}))


  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

  local countBlock = self.model:countPowers(player)
  if countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")

    local extra_cols = 0
    if globalSettings.display_data_col_id then
      extra_cols = extra_cols + 1
    end
    local resultTable = self:addGuiTable(scrollPanel,"list-data",3 + extra_cols, "helmod_table-odd")

    self:addPowersHeader(player, resultTable)

    local i = 0
    for _, element in spairs(model.powers, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addPowersRow(player, resultTable, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add header powers tab
--
-- @function [parent=#PlannerData] addPowersHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement itable container for element
--
function PlannerData.methods:addPowersHeader(player, itable)
  Logging:debug("PlannerData:addHeader():", player, itable)
  local model = self.model:getModel(player)
  local globalSettings = self.player:getGlobal(player, "settings")

  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end

  -- col power
  local guiPower = self:addGuiFlowH(itable,"header-power")
  self:addGuiLabel(guiPower, "header-power", ({"helmod_result-panel.col-header-energy"}))

  -- col primary
  local guiCount = self:addGuiFlowH(itable,"header-primary")
  self:addGuiLabel(guiCount, "header-primary", ({"helmod_result-panel.col-header-primary"}))

  -- col secondary
  local guiCount = self:addGuiFlowH(itable,"header-secondary")
  self:addGuiLabel(guiCount, "header-secondary", ({"helmod_result-panel.col-header-secondary"}))

end

-------------------------------------------------------------------------------
-- Add row powers tab
--
-- @function [parent=#PlannerData] addPowersRow
--
-- @param #LuaPlayer player
--
function PlannerData.methods:addPowersRow(player, guiTable, power)
  Logging:debug("PlannerData:addRow():", player, guiTable, power)
  local model = self.model:getModel(player)

  local globalSettings = self.player:getGlobal(player, "settings")
  -- col id
  if globalSettings.display_data_col_id then
    local guiId = self:addGuiFlowH(guiTable,"id"..power.id)
    self:addGuiLabel(guiId, "id", power.id)
  end
  -- col power
  local guiPower = self:addGuiFlowH(guiTable,"power"..power.id)
  self:addGuiLabel(guiPower, power.id, self:formatNumberKilo(power.power, "W"), "helmod_label_right_70")

  -- col primary
  local guiPrimary = self:addGuiFlowH(guiTable,"primary"..power.id)
  local primary = power.primary
  self:addGuiLabel(guiPrimary, primary.name, self:formatNumber(primary.count), "helmod_label_right_60")
  self:addGuiButtonSelectSprite(guiPrimary, "HMPlannerEnergyEdition=OPEN=ID="..power.id.."=", self.player:getIconType(primary), primary.name, "X"..self:formatNumber(primary.count), ({"tooltip.edit-energy", self.player:getLocalisedName(player, primary)}))

  -- col secondary
  local guiSecondary = self:addGuiFlowH(guiTable,"secondary"..power.id)
  local secondary = power.secondary
  if secondary.name ~= nil then
    self:addGuiLabel(guiSecondary, secondary.name, self:formatNumber(secondary.count), "helmod_label_right_60")
    self:addGuiButtonSelectSprite(guiSecondary, "HMPlannerEnergyEdition=OPEN=ID="..power.id.."=", self.player:getIconType(secondary), secondary.name, "X"..self:formatNumber(secondary.count), ({"tooltip.edit-energy", self.player:getLocalisedName(player, secondary)}))
  end
end
