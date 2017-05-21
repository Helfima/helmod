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
  self.player = self.parent.player
  self.model = self.parent.model

  self.PRODUCTION_BLOCK_TAB = "product-block"
  self.PRODUCTION_LINE_TAB = "product-line"
  self.SUMMARY_TAB = "summary"
  self.RESOURCES_TAB = "resources"
  self.POWER_TAB = "power"
  self.PROPERTIES_TAB = "properties"

  self.color_button_edit="green"
  self.color_button_add="yellow"
  self.color_button_rest="red"
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
  Logging:debug("HMPlannerData", "buildPanel():",player)
  local model = self.model:getModel(player)

  local globalGui = self.player:getGlobalGui(player)
  if globalGui.currentTab == nil then
    globalGui.currentTab = self.PRODUCTION_LINE_TAB
  end
  if globalGui.currentTab == nil then
    globalGui.order = {name="index", ascendant=true}
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
  Logging:debug("HMPlannerData", "send_event():",player, element, action, item, item2, item3)
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
  Logging:debug("HMPlannerData", "on_event():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)

  local globalGui = self.player:getGlobalGui(player)

  -- *******************************
  -- access admin or owner or write
  -- *******************************

  if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then

    if action == "change-boolean-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
      local element = model.blocks[globalGui.currentBlock]
      self.model:updateProductionBlockOption(player, globalGui.currentBlock, item, not(element[item]))
      self.model:update(player)
      self:update(player, item, item2, item3)
    end

    if action == "change-number-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
      local panel = self:getInfoPanel(player)["block"]["output-scroll"]["output-table"]
      if panel[item] ~= nil then
        local value = self:getInputNumber(panel[item])
        self.model:updateProductionBlockOption(player, globalGui.currentBlock, item, value)
        self.model:update(player)
        self:update(player, item, item2, item3)
      end
    end

    if action == "change-time" then
      model.time = tonumber(item) or 1
      self.model:update(player)
      self:update(player, item, item2, item3)
    end

    if action == "production-block-add" then
      if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
        local recipes = self.player:searchRecipe(player, item2)
        Logging:debug("HMPlannerData", "line recipes:",recipes)
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

    if action == "production-block-unlink" then
      self.parent.model:unlinkProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
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

    if action == "power-remove" then
      if globalGui.currentTab == self.POWER_TAB then
        self.parent.model:removePower(player, item)
        self:update(player, self.POWER_TAB, item, item2, item3)
      end
    end
  end

  -- ***************************
  -- access admin or owner
  -- ***************************

  if action == "share-model" then
    if model ~= nil then
      if self.player:isAdmin(player) or model.owner == player.name then
        if item == "read" then
          if model.share == nil or not(bit32.band(model.share, 1) > 0) then
            model.share = 1
          else
            model.share = 0
          end
        end
        if item == "write" then
          if model.share == nil or not(bit32.band(model.share, 2) > 0) then
            model.share = 3
          else
            model.share = 1
          end
        end
        if item == "delete" then
          if model.share == nil or not(bit32.band(model.share, 4) > 0) then
            model.share = 7
          else
            model.share = 3
          end
        end
      end
      self:update(player, item, item2, item3)
    end
  end

  -- ********************************
  -- access admin or owner or delete
  -- ********************************

  if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
    if action == "remove-model" then
      self.model:removeModel(player, item)
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
  end

  -- ***************************
  -- access for all
  -- ***************************
  if action == "refresh-model" then
    self:update(player, item, item2, item3)
  end

  if action == "change-model" then
    globalGui.model_id = item
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

  if action == "change-tab" then
    local panel_recipe = "CLOSE"
    globalGui.currentTab = item
    if globalGui.currentTab == self.PRODUCTION_LINE_TAB then
      globalGui.currentBlock = "new"
    end
    globalGui.currentBlock = item2
    self:update(player, item, item2, item3)
    if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB and globalGui.currentBlock == nil then
      self.parent:send_event(player, "HMPlannerRecipeSelector", "OPEN", item2)
    else
      self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
    end
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

  if action == "production-recipe-add" then
    if globalGui.currentTab == self.PRODUCTION_BLOCK_TAB then
      local recipes = self.player:searchRecipe(player, item3)
      Logging:debug("HMPlannerData", "block recipes:",recipes)
      if #recipes == 1 then
        Logging:debug("HMPlannerData", "recipe name:", recipes[1].name)
        local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, recipes[1].name)
        self.parent.model:update(player)
        self:update(player, self.PRODUCTION_LINE_TAB)
      else
        self.parent:send_event(player, "HMPlannerRecipeSelector", "OPEN", item, item2, item3)
      end
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
  Logging:debug("HMPlannerData", "update():", player, item, item2, item3)
  Logging:debug("HMPlannerData", "update():global", global)
  local globalGui = self.player:getGlobalGui(player)
  local dataPanel = self:getDataPanel(player)

  dataPanel.clear()

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
  if globalGui.currentTab == self.PROPERTIES_TAB then
    self:updateProperties(player, item, item2, item3)
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
  Logging:debug("HMPlannerData", "updateModelPanel():", player, item, item2, item3)
  local modelPanel = self:getModelPanel(player)
  local model = self.model:getModel(player)

  if model ~= nil and (model.version == nil or model.version ~= self.model.version) then
    self.model:update(player, true)
  end

  for k,guiName in pairs(modelPanel.children_names) do
    modelPanel[guiName].destroy()
  end

  -- time panel
  self:addGuiButton(modelPanel, self:classname().."=base-time", nil, "helmod_button_icon_time", nil, ({"helmod_data-panel.base-time"}))

  local times = {
    { value = 1, name = "1s"},
    { value = 60, name = "1mn"},
    { value = 300, name = "5mn"},
    { value = 600, name = "10mn"},
    { value = 1800, name = "30mn"},
    { value = 3600, name = "1h"},
    { value = 3600*6, name = "6h"},
    { value = 3600*12, name = "12h"},
    { value = 3600*24, name = "24h"}
  }
  for _,time in pairs(times) do
    local style = "helmod_button_time"
    if model.time == time.value then style = "helmod_button_time_selected" end
    self:addGuiButton(modelPanel, self:classname().."=change-time=ID=", time.value, style, time.name)
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
  Logging:debug("HMPlannerData", "updateProductionHeader():", player, item, item2, item3)
  local models = self.model:getModels(player)
  local model = self.model:getModel(player)
  local model_id = self.player:getGlobalGui(player, "model_id")
  -- data
  local menuPanel = self:getMenuPanel(player)

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
  --self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.PROPERTIES_TAB, "helmod_button_default", ({"helmod_result-panel.tab-button-properties"}))
  self:addGuiButton(tabPanel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.refresh-button"}))

  local deletePanel = self:addGuiFlowH(actionPanel, "delete", "helmod_flow_default")
  if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
    self:addGuiButton(deletePanel, self:classname().."=remove-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.remove-button-production-line"}))
  end

  -- index panel
  local indexPanel = self:addGuiFlowH(menuPanel, "index", "helmod_flow_resize_row_width")
  self.player:setStyle(player, indexPanel, "data", "minimal_width")
  self.player:setStyle(player, indexPanel, "data", "maximal_width")

  Logging:debug("HMPlannerData", "updateProductionHeader():countModel", self.model:countModel())
  if self.model:countModel() > 0 then
    local i = 0
    for _,imodel in pairs(models) do
      i = i + 1
      local style = "helmod_button_default"
      if imodel.id == model_id then style = "helmod_button_selected" end
      self:addGuiButton(indexPanel, self:classname().."=change-model=ID=", imodel.id, style, i)
    end
  end
  self:addGuiButton(indexPanel, self:classname().."=change-model=ID=", "new", "helmod_button_default", "+")

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
  Logging:debug("HMPlannerData", "updateProductionLine():", player, item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  local model = self.model:getModel(player)

  local infoPanel = self:getInfoPanel(player)
  -- info panel
  local blockPanel = self:addGuiFrameH(infoPanel, "block", "helmod_frame_default", ({"helmod_result-panel.tab-title-production-line"}))
  local blockScroll = self:addGuiScrollPane(blockPanel, "output-scroll", "helmod_scroll_block_info", "auto", "auto")
  local blockTable = self:addGuiTable(blockScroll,"output-table",2)


  local elementPanel = self:addGuiFlowV(infoPanel, "elements", "helmod_flow_default")
  -- ouput panel
  local outputPanel = self:addGuiFrameV(elementPanel, "output", "helmod_frame_resize_row_width", ({"helmod_common.output"}))
  local outputScroll = self:addGuiScrollPane(outputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "minimal_width")
  self.player:setStyle(player, outputScroll, "scroll_block_element", "maximal_width")

  -- input panel
  local inputPanel = self:addGuiFrameV(elementPanel, "input", "helmod_frame_resize_row_width", ({"helmod_common.input"}))
  local inputScroll = self:addGuiScrollPane(inputPanel, "output-scroll", "helmod_scroll_block_element", "auto", "auto")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "minimal_width")
  self.player:setStyle(player, inputScroll, "scroll_block_element", "maximal_width")

  -- production line result
  local resultPanel = self:getResultPanel(player, ({"helmod_common.blocks"}))
  -- data panel
  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

  -- admin panel
  self:addGuiLabel(blockTable, "label-owner", ({"helmod_result-panel.owner"}))
  self:addGuiLabel(blockTable, "value-owner", model.owner)

  self:addGuiLabel(blockTable, "label-share", ({"helmod_result-panel.share"}))

  local tableAdminPanel = self:addGuiTable(blockTable, "table" , 9)
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  self:addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=read="..model.id, model_read, nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))
  self:addGuiLabel(tableAdminPanel, self:classname().."=share-model-read", "R", nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  self:addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=write="..model.id, model_write, nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))
  self:addGuiLabel(tableAdminPanel, self:classname().."=share-model-write", "W", nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  self:addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=delete="..model.id, model_delete, nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))
  self:addGuiLabel(tableAdminPanel, self:classname().."=share-model-delete", "X", nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))

  local countBlock = self.model:countBlocks(player)
  if countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")

    -- info panel
    self:addGuiLabel(blockTable, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      self:addGuiLabel(blockTable, "power", self:formatNumberKilo(model.summary.energy or 0, "W"))
    end

    -- ouput panel
    local inputTable = self:addGuiTable(outputScroll,"output-table",6)
    if model.products ~= nil then
      for r, element in pairs(model.products) do
        self:addCellElement(player, inputTable, element, "HMPlannerIngredient=OPEN=ID="..element.name.."=", false, "tooltip.product", nil)
      end
    end

    -- input panel
    local inputTable = self:addGuiTable(inputScroll,"input-table",6)
    if model.ingredients ~= nil then
      for r, element in pairs(model.ingredients) do
        self:addCellElement(player, inputTable, element, "HMPlannerIngredient=OPEN=ID="..element.name.."=", false, "tooltip.ingredient", nil)
      end
    end

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
    local resultTable = self:addGuiTable(scrollPanel,"list-data",5 + extra_cols, "helmod_table-odd")

    self:addProductionLineHeader(player, resultTable)

    local i = 0
    for _, element in spairs(model.blocks, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addProductionLineRow(player, resultTable, element)
    end
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
  Logging:debug("HMPlannerData", "updateProductionBlock():", player, item, item2, item3)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  Logging:debug("HMPlannerData", "model:", model)
  -- data
  local menuPanel = self:getMenuPanel(player)

  local blockId = "new"
  if globalGui.currentBlock ~= nil then
    blockId = globalGui.currentBlock
  end
  local tabPanel = self:addGuiFlowH(menuPanel, "tab", "helmod_flow_data_tab")
  self:addGuiButton(tabPanel, "HMPlannerRecipeSelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-recipe"}))
  self:addGuiButton(tabPanel, "HMPlannerTechnologySelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-technology"}))
  self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", self.PRODUCTION_LINE_TAB, "helmod_button_default", ({"helmod_result-panel.back-button-production-line"}))
  self:addGuiButton(tabPanel, "HMPlannerPinPanel=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.tab-button-pin"}))
  self:addGuiButton(tabPanel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.refresh-button"}))

  local countRecipes = self.model:countBlockRecipes(player, blockId)

  local infoPanel = self:getInfoPanel(player)
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

  local resultPanel = self:getResultPanel(player, ({"helmod_common.recipes"}))
  -- data panel
  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

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
    self:addGuiCheckbox(blockTable, self:classname().."=change-boolean-option=ID=unlinked", unlinked)

    self:addGuiLabel(blockTable, "options-by-factory", ({"helmod_label.compute-by-factory"}))
    local by_factory = element.by_factory and true or false
    self:addGuiCheckbox(blockTable, self:classname().."=change-boolean-option=ID=by_factory", by_factory)

    if element.by_factory == true then
      local factory_number = element.factory_number or 0
      self:addGuiLabel(blockTable, "label-factory_number", ({"helmod_label.factory-number"}))
      self:addGuiText(blockTable, "factory_number", factory_number, "helmod_textfield")
      self:addGuiButton(blockTable, self:classname().."=change-number-option=ID=", "factory_number", "helmod_button_default", ({"helmod_button.update"}))
    end

    -- ouput panel
    local outputTable = self:addGuiTable(outputScroll,"output-table",6)
    if element.products ~= nil then
      for r, product in pairs(element.products) do
        if bit32.band(product.state, 1) > 0 then
          if not(unlinked) or element.by_factory == true then
            self:addCellElement(player, outputTable, product, "HMPlannerProduct=OPEN=ID="..element.id.."=", false, "tooltip.product", nil)
          else
            self:addCellElement(player, outputTable, product, "HMPlannerProductEdition=OPEN=ID="..element.id.."=", true, "tooltip.edit-product", self.color_button_edit)
          end
        end
        if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
          self:addCellElement(player, outputTable, product, "HMPlannerProduct=OPEN=ID="..element.id.."=", true, "tooltip.rest-product", self.color_button_rest)
        end
        if product.state == 0 then
          self:addCellElement(player, outputTable, product, "HMPlannerProduct=OPEN=ID="..element.id.."=", false, "tooltip.other-product", nil)
        end
      end
    end

    -- input panel

    local inputTable = self:addGuiTable(inputScroll,"input-table",6)
    if element.ingredients ~= nil then
      for r, ingredient in pairs(element.ingredients) do
        self:addCellElement(player, inputTable, ingredient, "HMPlannerIngredient=OPEN=ID="..element.id.."=", false, "tooltip.ingredient", nil)
      end
    end

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

    self:addProductionBlockHeader(player, resultTable)

    for _, recipe in spairs(model.blocks[blockId].recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addProductionBlockRow(player, resultTable, element, recipe)
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
  Logging:debug("HMPlannerData", "addHeader():", player, itable)
  local model = self.model:getModel(player)

  local guiAction = self:addGuiFlowH(itable,"header-action")
  self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(itable,"header-index")
    self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
    self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))
  end

  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end
  if self.player:getSettings(player, "display_data_col_name", true) then
    local guiName = self:addGuiFlowH(itable,"header-name")
    self:addGuiLabel(guiName, "label", ({"helmod_result-panel.col-header-name"}))
    self:addGuiButton(guiName, self:classname().."=change-sort=ID=", "name", self.player:getSortedStyle(player, "name"))

  end

  local guiRecipe = self:addGuiFlowH(itable,"header-recipe")
  self:addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
  self:addGuiButton(guiRecipe, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))

  local guiEnergy = self:addGuiFlowH(itable,"header-energy")
  self:addGuiLabel(guiEnergy, "header-energy", ({"helmod_result-panel.col-header-energy"}))
  self:addGuiButton(guiEnergy, self:classname().."=change-sort=ID=", "energy_total", self.player:getSortedStyle(player, "energy_total"))

  local guiFactory = self:addGuiFlowH(itable,"header-factory")
  self:addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))

  local guiBeacon = self:addGuiFlowH(itable,"header-beacon")
  self:addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))

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
  Logging:debug("HMPlannerData", "addHeader():", player, itable)
  local model = self.model:getModel(player)

  local guiAction = self:addGuiFlowH(itable,"header-action")
  self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(itable,"header-index")
    self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
    self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))
  end

  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end
  if self.player:getSettings(player, "display_data_col_name", true) then
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
  Logging:debug("HMPlannerData", "addHeader():", player, itable)
  local model = self.model:getModel(player)
  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(itable,"header-index")
    self:addGuiLabel(guiIndex, "label", ({"helmod_result-panel.col-header-index"}))
    self:addGuiButton(guiIndex, self:classname().."=change-sort=ID=", "index", self.player:getSortedStyle(player, "index"))
  end

  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(itable,"header-id")
    self:addGuiLabel(guiId, "label", ({"helmod_result-panel.col-header-id"}))
    self:addGuiButton(guiId, self:classname().."=change-sort=ID=", "id", self.player:getSortedStyle(player, "id"))

  end
  if self.player:getSettings(player, "display_data_col_name", true) then
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
function PlannerData.methods:addProductionBlockRow(player, guiTable, block, recipe)
  Logging:debug("HMPlannerData", "addProductionBlockRow():", player, guiTable, block, recipe)
  local model = self.model:getModel(player)

  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..recipe.name, "helmod_flow_default")
  if recipe.index ~= 0 then
    self:addGuiButton(guiAction, self:classname().."=production-recipe-remove=ID="..block.id.."=", recipe.name, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
    self:addGuiButton(guiAction, self:classname().."=production-recipe-down=ID="..block.id.."=", recipe.name, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
  end
  if recipe.index > 1 then
    self:addGuiButton(guiAction, self:classname().."=production-recipe-up=ID="..block.id.."=", recipe.name, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
  end
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
  local guiRecipe = self:addCellLabel(player, guiTable, "recipe-"..recipe.name, self:formatPercent(production).."%", 35)
  self:addIconRecipeCell(player, guiRecipe, recipe, "HMPlannerRecipeEdition=OPEN=ID="..block.id.."=", true, "tooltip.edit-recipe", self.color_button_edit)
  --self:addGuiButtonSelectSprite(guiRecipe, "HMPlannerRecipeEdition=OPEN=ID="..block.id.."=", self.player:getRecipeIconType(player, recipe), recipe.name, recipe.name, ({"tooltip.edit-recipe", self.player:getRecipeLocalisedName(player, recipe)}))

  -- col energy
  local guiEnergy = self:addCellLabel(player, guiTable, "energy-"..recipe.name, self:formatNumberKilo(recipe.energy_total, "W"), 50)

  -- col factory
  local factory = recipe.factory
  local guiFactory = self:addCellLabel(player, guiTable, "factory-"..recipe.name, self:formatNumberFactory(factory.limit_count).."/"..self:formatNumberFactory(factory.count), 60)
  self:addIconCell(player, guiFactory, factory, "HMPlannerRecipeEdition=OPEN=ID="..block.id.."="..recipe.name.."=", true, "tooltip.edit-recipe", self.color_button_edit)
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
        self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
      else
        self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name)
      end
      index = index + 1
    end
  end

  -- col beacon
  local beacon = recipe.beacon
  local guiBeacon = self:addCellLabel(player, guiTable, "beacon-"..recipe.name, self:formatNumberFactory(beacon.limit_count).."/"..self:formatNumberFactory(beacon.count), 60)
  self:addIconCell(player, guiBeacon, beacon, "HMPlannerRecipeEdition=OPEN=ID="..block.id.."="..recipe.name.."=", true, "tooltip.edit-recipe", self.color_button_edit)
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
        self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
      else
        self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name)
      end
      index = index + 1
    end
  end

  -- products
  local display_product_cols = self.player:getSettings(player, "display_product_cols")
  local tProducts = self:addGuiTable(guiTable,"products_"..recipe.name, display_product_cols)
  if recipe.products ~= nil then
    for r, product in pairs(recipe.products) do
      self:addCellElement(player, tProducts, product, "HMPlannerProduct=OPEN=ID="..block.id.."="..recipe.name.."=", false, "tooltip.product", nil)
    end

  end
  -- ingredients
  local display_ingredient_cols = self.player:getSettings(player, "display_ingredient_cols")
  local tIngredient = self:addGuiTable(guiTable,"ingredients_"..recipe.name, display_ingredient_cols)
  if recipe.ingredients ~= nil then
    for r, ingredient in pairs(recipe.ingredients) do
      self:addCellElement(player, tIngredient, ingredient, "=production-recipe-add=ID="..block.id.."="..recipe.name.."=", true, "tooltip.add-recipe", self.color_button_add)
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
-- @param #table block production block
--
function PlannerData.methods:addProductionLineRow(player, guiTable, block)
  Logging:debug("HMPlannerData", "addProductionLineRow():", player, guiTable, block)
  local model = self.model:getModel(player)

  local globalSettings = self.player:getGlobal(player, "settings")
  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..block.id, "helmod_flow_default")
  self:addGuiButton(guiAction, self:classname().."=production-block-remove=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))
  self:addGuiButton(guiAction, self:classname().."=production-block-down=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-down"}), ({"tooltip.down-element"}))
  self:addGuiButton(guiAction, self:classname().."=production-block-up=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-up"}), ({"tooltip.up-element"}))
  if unlinked then
    self:addGuiButton(guiAction, self:classname().."=production-block-unlink=ID=", block.id, "helmod_button_default", ({"helmod_result-panel.row-button-unlink"}), ({"tooltip.unlink-element"}))
  else
    self:addGuiButton(guiAction, self:classname().."=production-block-unlink=ID=", block.id, "helmod_button_selected", ({"helmod_result-panel.row-button-unlink"}), ({"tooltip.unlink-element"}))
  end

  -- col index
  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..block.id)
    self:addGuiLabel(guiIndex, "index", block.index, "helmod_label_row_right_40")
  end
  -- col id
  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(guiTable,"id"..block.id)
    self:addGuiLabel(guiId, "id", block.id)
  end
  -- col name
  if self.player:getSettings(player, "display_data_col_name", true) then
    local guiName = self:addGuiFlowH(guiTable,"name"..block.id)
    self:addGuiLabel(guiName, "name_", block.name)
  end

  -- col recipe
  local guiRecipe = self:addGuiFlowH(guiTable,"recipe"..block.id)
  self:addIconRecipeCell(player, guiRecipe, block, self:classname().."=change-tab=ID="..self.PRODUCTION_BLOCK_TAB.."="..block.id.."=", true, "tooltip.edit-block", self.color_button_edit)

  -- col energy
  local guiEnergy = self:addCellLabel(player, guiTable, block.id, self:formatNumberKilo(block.power, "W"), 60)

  -- products
  local display_product_cols = self.player:getSettings(player, "display_product_cols") + 1
  local tProducts = self:addGuiTable(guiTable,"products_"..block.id, display_product_cols)
  if block.products ~= nil then
    for r, product in pairs(block.products) do
      if bit32.band(product.state, 1) > 0 then
        if not(unlinked) or block.by_factory == true then
         self:addCellElement(player, tProducts, product, "HMPlannerProduct=OPEN=ID=", false, "tooltip.product", nil)
        else
          self:addCellElement(player, tProducts, product, "HMPlannerProductEdition=OPEN=ID="..block.id.."=", true, "tooltip.edit-product", self.color_button_edit)
        end
      end
      if bit32.band(product.state, 2) > 0 and bit32.band(product.state, 1) == 0 then
        self:addCellElement(player, tProducts, product, "HMPlannerProduct=OPEN=ID=", true, "tooltip.rest-product", self.color_button_rest)
      end
      if product.state == 0 then
        self:addCellElement(player, tProducts, product, "HMPlannerProduct=OPEN=ID=", false, "tooltip.other-product", nil)
      end
    end
  end
  -- ingredients
  local display_ingredient_cols = self.player:getSettings(player, "display_ingredient_cols") + 2
  local tIngredient = self:addGuiTable(guiTable,"ingredients_"..block.id, display_ingredient_cols)
  if block.ingredients ~= nil then
    for r, ingredient in pairs(block.ingredients) do
      self:addCellElement(player, tIngredient, ingredient, "=production-block-add=ID="..block.id.."="..ingredient.name.."=", true, "tooltip.add-recipe", self.color_button_add)
    end
  end
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#PlannerData] addCellElement
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #table element production block
--
function PlannerData.methods:addCellElement(player, guiTable, element, action, select, tooltip_name, color)
  Logging:debug("HMPlannerData", "addCellElement():", player, guiTable, element, action, select, tooltip_name, color)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local cell = nil
  local button = nil

  if display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = self:addCellLabel(player, guiTable, element.name, self:formatNumberKilo(element.count))
  else
    cell = self:addCellLabel(player, guiTable, element.name, self:formatNumberElement(element.count))
  end

  self:addIconCell(player, cell, element, action, select, tooltip_name, color)
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#PlannerData] addIconRecipeCell
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function PlannerData.methods:addIconRecipeCell(player, cell, element, action, select, tooltip_name, color)
  Logging:debug("HMPlannerData", "addIconRecipeCell():", element, action, select, tooltip_name, color)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSpriteM(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSpriteM(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    end
  else
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSprite(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSprite(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#PlannerData] addIconCell
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function PlannerData.methods:addIconCell(player, cell, element, action, select, tooltip_name, color)
  Logging:debug("HMPlannerData", "addIconCell():", player, cell, element, action, select, tooltip_name, color)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSpriteM(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSpriteM(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    end
  else
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSprite(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSprite(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add cell label
--
-- @function [parent=#PlannerData] addCellLabel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #string label
--
function PlannerData.methods:addCellLabel(player, guiTable, name, label, minimal_width)
  Logging:debug("HMPlannerData", "addCellLabel():", guiTable, name, label)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  local cell = nil

  if display_cell_mod == "small-text"then
    -- small
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_icon_text_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "small-icon" then
    -- small
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_icon_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 50
  else
    -- default
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 60

  end
  return cell
end

-------------------------------------------------------------------------------
-- Add row resources tab
--
-- @function [parent=#PlannerData] addResourcesRow
--
-- @param #LuaPlayer player
--
function PlannerData.methods:addResourcesRow(player, guiTable, ingredient)
  Logging:debug("HMPlannerData", "addRow():", player, guiTable, ingredient)
  local model = self.model:getModel(player)

  -- col index
  if self.player:getSettings(player, "display_data_col_index", true) then
    local guiIndex = self:addGuiFlowH(guiTable,"index"..ingredient.id)
    self:addGuiLabel(guiIndex, "index", ingredient.index, "helmod_label_row_right_40")
  end
  -- col id
  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(guiTable,"id"..ingredient.id)
    self:addGuiLabel(guiId, "id", ingredient.id)
  end
  -- col name
  if self.player:getSettings(player, "display_data_col_name", true) then
    local guiName = self:addGuiFlowH(guiTable,"name"..ingredient.id)
    self:addGuiLabel(guiName, "name_", ingredient.name)
  end
  -- col count
  local guiCount = self:addGuiFlowH(guiTable,"count"..ingredient.name)
  self:addGuiLabel(guiCount, ingredient.name, self:formatNumberElement(ingredient.count), "helmod_label_right_60")

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
  Logging:debug("HMPlannerData", "updateResources():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)
  -- data
  local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-resources"}))
  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")


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
  Logging:debug("HMPlannerData", "updateSummary():", player)
  local model = self.model:getModel(player)
  -- data
  local menuPanel = self:getMenuPanel(player, ({"helmod_result-panel.tab-title-summary"}))
  local dataPanel = self:getDataPanel(player)

  -- resources
  local resourcesPanel = self:addGuiFrameV(dataPanel, "resources", "helmod_frame_resize_row_width", ({"helmod_common.resources"}))
  self.player:setStyle(player, resourcesPanel, "data", "minimal_width")
  self.player:setStyle(player, resourcesPanel, "data", "maximal_width")

  local resourcesTable = self:addGuiTable(resourcesPanel,"table-resources",4)
  self:addGuiLabel(resourcesTable, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
  self:addGuiLabel(resourcesTable, "header-block", ({"helmod_result-panel.col-header-production-block"}))
  self:addGuiLabel(resourcesTable, "header-cargo-wagon", ({"helmod_result-panel.col-header-wagon"}))
  self:addGuiLabel(resourcesTable, "header-chest", ({"helmod_result-panel.col-header-storage"}))
  --  self:addGuiLabel(resourcesTable, "header-extractor", ({"helmod_result-panel.col-header-extractor"}))
  --  self:addGuiLabel(resourcesTable, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
  --  self:addGuiLabel(resourcesTable, "header-energy", ({"helmod_result-panel.col-header-energy"}))

  for _, resource in pairs(model.resources) do
    -- ingredient
    local guiIngredient = self:addGuiFlowH(resourcesTable,"ingredient"..resource.name)
    self:addGuiLabel(guiIngredient, "count", self:formatNumberElement(resource.count), "helmod_label_right_60")
    self:addGuiButtonSprite(guiIngredient, "HMPlannerIngredient=OPEN=ID=", self.player:getItemIconType(resource), resource.name, resource.name, self.player:getLocalisedName(player, resource))

    -- col block
    local guiBlock = self:addGuiFlowH(resourcesTable,"block"..resource.name)
    self:addGuiLabel(guiBlock, "count", self:formatNumberElement(resource.blocks), "helmod_label_right_50")

    -- col wagon
    local wagon = resource.wagon
    local guiWagon = self:addGuiFlowH(resourcesTable,"wagon"..resource.name)
    if wagon ~= nil then
      self:addGuiLabel(guiWagon, "count", self:formatNumberElement(wagon.limit_count).."/"..self:formatNumberElement(wagon.count), "helmod_label_right_70")
      self:addGuiButtonSprite(guiWagon, "HMPlannerWagon=OPEN=ID=", self.player:getIconType(wagon), wagon.name, wagon.name, self.player:getLocalisedName(player, wagon))
    end

    -- col storage
    local storage = resource.storage
    local guiStorage = self:addGuiFlowH(resourcesTable,"storage"..resource.name)
    if storage ~= nil then
      self:addGuiLabel(guiStorage, "count", self:formatNumberElement(storage.limit_count).."/"..self:formatNumberElement(storage.count), "helmod_label_right_70")
      self:addGuiButtonSprite(guiStorage, "HMPlannerStorage=OPEN=ID=", self.player:getIconType(storage), storage.name, storage.name, self.player:getLocalisedName(player, storage))
    end

    --    -- factory
    --    local guiFactory = self:addGuiFlowH(resourcesTable,"extractor"..resource.name)
    --    local factory = resource.factory
    --    if factory ~= nil then
    --      self:addGuiLabel(guiFactory, "factory", self:formatNumber(factory.limit_count).."/"..self:formatNumber(factory.count), "helmod_label_right_70")
    --      self:addGuiButtonSelectSprite(guiFactory, "HMPlannerResourceEdition=OPEN=ID=resource="..resource.name.."=", self.player:getIconType(factory), factory.name, factory.name, ({"tooltip.edit-resource", self.player:getLocalisedName(player, resource)}))
    --      local guiFactoryModule = self:addGuiTable(guiFactory,"factory-modules"..resource.name, 2, "helmod_factory_modules")
    --      -- modules
    --      for name, count in pairs(factory.modules) do
    --        for index = 1, count, 1 do
    --          local module = self.player:getItemPrototype(name)
    --          if module ~= nil then
    --            local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
    --            local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
    --            local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
    --            local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
    --            local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
    --            self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, tooltip)
    --          else
    --            self:addGuiButtonSpriteSm(guiFactoryModule, "HMPlannerFactorySelector_factory-module_"..name.."_"..index, "item", name)
    --          end
    --          index = index + 1
    --        end
    --      end
    --    else
    --      self:addGuiLabel(guiFactory, "factory", "Data need update")
    --    end
    --
    --    -- beacon
    --    local guiBeacon = self:addGuiFlowH(resourcesTable,"beacon"..resource.name)
    --    local beacon = resource.beacon
    --    if beacon ~= nil then
    --      self:addGuiLabel(guiBeacon, "beacon", self:formatNumberKilo(resource.beacon.count), "helmod_label_right_70")
    --      self:addGuiButtonSelectSprite(guiBeacon, "HMPlannerResourceEdition=OPEN=ID=resource="..resource.name.."=", self.player:getIconType(beacon), beacon.name, beacon.name, ({"tooltip.edit-resource", self.player:getLocalisedName(player, resource)}))
    --      local guiBeaconModule = self:addGuiTable(guiBeacon,"beacon-modules"..resource.name, 1, "helmod_beacon_modules")
    --      -- modules
    --      for name, count in pairs(beacon.modules) do
    --        for index = 1, count, 1 do
    --          local module = self.player:getItemPrototype(name)
    --          if module ~= nil then
    --            local consumption = self:formatPercent(self.player:getModuleBonus(module.name, "consumption"))
    --            local speed = self:formatPercent(self.player:getModuleBonus(module.name, "speed"))
    --            local productivity = self:formatPercent(self.player:getModuleBonus(module.name, "productivity"))
    --            local pollution = self:formatPercent(self.player:getModuleBonus(module.name, "pollution"))
    --            local tooltip = ({"tooltip.module-description" , module.localised_name, consumption, speed, productivity, pollution})
    --            self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, tooltip)
    --          else
    --            self:addGuiButtonSpriteSm(guiBeaconModule, "HMPlannerFactorySelector_beacon-module_"..name.."_"..index, "item", name)
    --          end
    --          index = index + 1
    --        end
    --      end
    --    else
    --      self:addGuiLabel(guiBeacon, "beacon", "Data need update")
    --    end
    --
    --    -- col energy
    --    local guiEnergy = self:addGuiFlowH(resourcesTable,"energy"..resource.name)
    --    self:addGuiLabel(guiEnergy, resource.name, self:formatNumberKilo(resource.energy_total, "W"), "helmod_label_right_70")
  end

  local energyPanel = self:addGuiFrameV(dataPanel, "energy", "helmod_frame_resize_row_width", ({"helmod_common.generators"}))
  self.player:setStyle(player, energyPanel, "data", "minimal_width")
  self.player:setStyle(player, energyPanel, "data", "maximal_width")

  local resultTable = self:addGuiTable(energyPanel,"table-energy",2)

  if model.generators ~= nil then
    for _, item in pairs(model.generators) do
      local guiCell = self:addGuiFlowH(resultTable,"cell_"..item.name)
      self:addGuiLabel(guiCell, item.name, self:formatNumberKilo(item.count), "helmod_label_right_50")
      self:addGuiButtonSprite(guiCell, "HMPlannerGenerator=OPEN=ID=", "item", item.name, item.name, self.player:getLocalisedName(player, item))
    end
  end

  -- factories
  local factoryPanel = self:addGuiFrameV(dataPanel, "factory", "helmod_frame_resize_row_width", ({"helmod_common.factories"}))
  self.player:setStyle(player, factoryPanel, "data", "minimal_width")
  self.player:setStyle(player, factoryPanel, "data", "maximal_width")

  if model.summary ~= nil then
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
end


-------------------------------------------------------------------------------
-- Update power tab
--
-- @function [parent=#PlannerData] updatePowers
--
-- @param #LuaPlayer player
--
function PlannerData.methods:updatePowers(player)
  Logging:debug("HMPlannerData", "updatePowers():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)

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
  if model.powers ~= nil and countBlock > 0 then
    local globalSettings = self.player:getGlobal(player, "settings")

    local extra_cols = 0
    if self.player:getSettings(player, "display_data_col_id", true) then
      extra_cols = extra_cols + 1
    end
    local resultTable = self:addGuiTable(scrollPanel,"list-data",4 + extra_cols, "helmod_table-odd")

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
  Logging:debug("HMPlannerData", "addPowersHeader():", player, itable)
  local model = self.model:getModel(player)

  local guiAction = self:addGuiFlowH(itable,"header-action")
  self:addGuiLabel(guiAction, "label", ({"helmod_result-panel.col-header-action"}))

  if self.player:getSettings(player, "display_data_col_id", true) then
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
  Logging:debug("HMPlannerData", "addPowersRow():", player, guiTable, power)
  local model = self.model:getModel(player)

  -- col action
  local guiAction = self:addGuiFlowH(guiTable,"action"..power.id, "helmod_flow_default")
  self:addGuiButton(guiAction, self:classname().."=power-remove=ID=", power.id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))

  -- col id
  if self.player:getSettings(player, "display_data_col_id", true) then
    local guiId = self:addGuiFlowH(guiTable,"id"..power.id)
    self:addGuiLabel(guiId, "id", power.id)
  end
  -- col power
  local guiPower = self:addGuiFlowH(guiTable,"power"..power.id)
  self:addGuiLabel(guiPower, power.id, self:formatNumberKilo(power.power, "W"), "helmod_label_right_70")

  -- col primary
  local guiPrimary = self:addGuiFlowH(guiTable,"primary"..power.id)
  local primary = power.primary
  if primary.name ~= nil then
    self:addGuiLabel(guiPrimary, primary.name, self:formatNumberFactory(primary.count), "helmod_label_right_60")
    self:addGuiButtonSelectSprite(guiPrimary, "HMPlannerEnergyEdition=OPEN=ID="..power.id.."=", self.player:getIconType(primary), primary.name, "X"..self:formatNumberFactory(primary.count), ({"tooltip.edit-energy", self.player:getLocalisedName(player, primary)}))
  end
  -- col secondary
  local guiSecondary = self:addGuiFlowH(guiTable,"secondary"..power.id)
  local secondary = power.secondary
  if secondary.name ~= nil then
    self:addGuiLabel(guiSecondary, secondary.name, self:formatNumberFactory(secondary.count), "helmod_label_right_60")
    self:addGuiButtonSelectSprite(guiSecondary, "HMPlannerEnergyEdition=OPEN=ID="..power.id.."=", self.player:getIconType(secondary), secondary.name, "X"..self:formatNumberFactory(secondary.count), ({"tooltip.edit-energy", self.player:getLocalisedName(player, secondary)}))
  end
end

-------------------------------------------------------------------------------
-- Update properties tab
--
-- @function [parent=#PlannerData] updateProperties
--
-- @param #LuaPlayer player
--
function PlannerData.methods:updateProperties(player)
  Logging:debug("HMPlannerData", "updateProperties():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)

  -- data
  local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-properties"}))

  local menuPanel = self:addGuiFlowH(resultPanel,"menu")
  self:addGuiButton(menuPanel, "HMPlannerEntitySelector=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
  self:addGuiButton(menuPanel, "HMPlannerItemSelector=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))


  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

end

-------------------------------------------------------------------------------
-- Format number for factory
--
-- @function [parent=#PlannerData] formatNumberFactory
--
-- @param #number number
--
function PlannerData.methods:formatNumberFactory(number)
  local decimal = 2
  local format_number = self.player:getSettings(nil, "format_number_factory", true)
  if format_number == "0" then decimal = 0 end
  if format_number == "0.0" then decimal = 1 end
  if format_number == "0.00" then decimal = 2 end
  return self:formatNumber(number, decimal)
end


-------------------------------------------------------------------------------
-- Format number for element product or ingredient
--
-- @function [parent=#PlannerData] formatNumberElement
--
-- @param #number number
--
function PlannerData.methods:formatNumberElement(number)
  local decimal = 2
  local format_number = self.player:getSettings(nil, "format_number_element", true)
  if format_number == "0" then decimal = 0 end
  if format_number == "0.0" then decimal = 1 end
  if format_number == "0.00" then decimal = 2 end
  return self:formatNumber(number, decimal)
end