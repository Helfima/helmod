require "tab.EnergyTab"
require "tab.ProductionBlockTab"
require "tab.ProductionLineTab"
require "tab.ResourceTab"
require "tab.SummaryTab"
require "tab.PropertiesTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module MainTab
-- @extends #ElementGui
--

MainTab = setclass("HMMainTab", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#MainTab] init
--
-- @param #Controller parent parent controller
--
function MainTab.methods:init(parent)
  self.parent = parent
  self.player = self.parent.player
  self.model = self.parent.model

  local tabs = {}
  table.insert(tabs, ProductionBlockTab:new(self))
  table.insert(tabs, ProductionLineTab:new(self))
  table.insert(tabs, EnergyTab:new(self))
  table.insert(tabs, ResourceTab:new(self))
  table.insert(tabs, SummaryTab:new(self))
  table.insert(tabs, PropertiesTab:new(self))

  self.tabs = {}
  for _,tab in pairs(tabs) do
    self.tabs[tab:classname()] = tab
  end

  self.color_button_edit="green"
  self.color_button_add="yellow"
  self.color_button_rest="red"
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#MainTab] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function MainTab.methods:getParentPanel(player)
  return self.parent:getDataPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#MainTab] getDataPanel
--
-- @param #LuaPlayer player
--
function MainTab.methods:getDataPanel(player)
  local parentPanel = self:getParentPanel(player)
  if parentPanel["data"] ~= nil and parentPanel["data"].valid then
    return parentPanel["data"]
  end
  return self:addGuiFlowV(parentPanel, "data", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#MainTab] getModelPanel
--
-- @param #LuaPlayer player
--
function MainTab.methods:getModelPanel(player)
  local menuPanel = self.parent:getMenuPanel(player)
  if menuPanel["model"] ~= nil and menuPanel["model"].valid then
    return menuPanel["model"]
  end
  return self:addGuiFrameV(menuPanel, "model", "helmod_frame_default")
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainTab] getMenuPanel
--
-- @param #LuaPlayer player
--
function MainTab.methods:getMenuPanel(player, caption)
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
-- @function [parent=#MainTab] getInfoPanel
--
-- @param #LuaPlayer player
--
function MainTab.methods:getInfoPanel(player)
  local dataPanel = self:getDataPanel(player)
  if dataPanel["info"] ~= nil and dataPanel["info"].valid then
    return dataPanel["info"]
  end
  return self:addGuiFlowH(dataPanel, "info", "helmod_flow_full_resize_row")
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#MainTab] getResultPanel
--
-- @param #LuaPlayer player
-- @param #string caption
--
function MainTab.methods:getResultPanel(player, caption)
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
-- Get or create result scroll panel
--
-- @function [parent=#MainTab] getResultScrollPanel
--
-- @param #LuaPlayer player
-- @param #string caption
--
function MainTab.methods:getResultScrollPanel(player, caption)
  local resultPanel = self:getResultPanel(player, caption)
  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")
  return scrollPanel
end

-------------------------------------------------------------------------------
-- Build the parent panel
--
-- @function [parent=#MainTab] buildPanel
--
-- @param #LuaPlayer player
--
function MainTab.methods:buildPanel(player)
  Logging:debug("MainTab", "buildPanel():",player)

  local globalGui = self.player:getGlobalGui(player)
  if globalGui.currentTab == nil then
    globalGui.order = {name="index", ascendant=true}
  end

  if globalGui.currentTab == nil or self.tabs[globalGui.currentTab] == nil then
    globalGui.currentTab = "HMProductionLineTab"
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
-- @function [parent=#MainTab] send_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:send_event(player, element, action, item, item2, item3)
  Logging:debug("MainTab", "send_event():",player, element, action, item, item2, item3)
  self:on_event(player, element, action, item, item2, item3)
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event():", action, item, item2, item3)

  local globalGui = self.player:getGlobalGui(player)

  local model = self.model:getModel(player)
  if self.tabs[globalGui.currentTab] ~= nil then

    -- *******************************
    -- access admin or owner or write
    -- *******************************

    if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
      self:on_event_access_write(player, element, action, item, item2, item3)
    end

    -- ***************************
    -- access admin or owner
    -- ***************************

    if self.player:isAdmin(player) or model.owner == player.name then
      self:on_event_access_read(player, element, action, item, item2, item3)
    end

    -- ********************************
    -- access admin or owner or delete
    -- ********************************

    if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      self:on_event_access_delete(player, element, action, item, item2, item3)
    end

    -- ***************************
    -- access for all
    -- ***************************
    self:on_event_access_all(player, element, action, item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] on_event_access_all
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:on_event_access_all(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event_access_all():", action, item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  if action == "refresh-model" then
    self:update(player, item, item2, item3)
  end

  if action == "change-model" then
    globalGui.model_id = item
    globalGui.currentTab = "HMProductionLineTab"
    globalGui.currentBlock = "new"

    self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
    self.parent:send_event(player, "HMResourceEdition", "CLOSE")
    self.parent:send_event(player, "HMRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMProductEdition", "CLOSE")
    self.parent:send_event(player, "HMEnergyEdition", "CLOSE")
    self.parent:send_event(player, "HMSettings", "CLOSE")

    self.parent:refreshDisplay(player)
  end

  if action == "change-tab" then
    local panel_recipe = "CLOSE"
    globalGui.currentTab = item
    if item == "HMProductionLineTab" then
      globalGui.currentBlock = "new"
    end
    globalGui.currentBlock = item2
    if item == "HMProductionBlockTab" and globalGui.currentBlock == nil then
      self.parent:send_event(player, "HMRecipeSelector", "OPEN", item2)
    else
      self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
    end
    self.parent:send_event(player, "HMResourceEdition", "CLOSE")
    self.parent:send_event(player, "HMRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMProductEdition", "CLOSE")
    self.parent:send_event(player, "HMEnergyEdition", "CLOSE")
    self.parent:send_event(player, "HMSettings", "CLOSE")

    self.parent:refreshDisplayData(player)
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
    local recipes = self.player:searchRecipe(player, item3)
    Logging:debug(self:classname(), "block recipes:",recipes)
    if #recipes == 1 then
      Logging:debug(self:classname(), "recipe name:", recipes[1].name)
      local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, recipes[1].name)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    else
      self.parent:send_event(player, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] on_event_access_read
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:on_event_access_read(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event_access_read():", action, item, item2, item3)
  local model = self.model:getModel(player)
  if action == "share-model" then
    if model ~= nil then
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

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] on_event_access_write
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:on_event_access_write(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event_access_write():", action, item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  local model = self.model:getModel(player)
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

  if action == "production-block-unlink" then
    self.parent.model:unlinkProductionBlock(player, item)
    self.parent.model:update(player)
    self:update(player, self.PRODUCTION_LINE_TAB, item, item2, item3)
  end

  if globalGui.currentTab == "HMProductionLineTab" then
    if action == "production-block-add" then
      local recipes = self.player:searchRecipe(player, item2)
      Logging:debug(self:classname(), "line recipes:",recipes)
      if #recipes == 1 then
        local productionBlock = self.parent.model:addRecipeIntoProductionBlock(player, recipes[1].name)
        self.parent.model:update(player)
        globalGui.currentTab = "HMProductionBlockTab"
        self:update(player, item, item2, item3)
      else
        globalGui.currentTab = "HMProductionBlockTab"
        self.parent:send_event(player, "HMRecipeSelector", "OPEN", item, item2, item3)
      end
    end

    if action == "production-block-remove" then
      self.parent.model:removeProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    end

    if action == "production-block-up" then
      self.parent.model:upProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    end

    if action == "production-block-down" then
      self.parent.model:downProductionBlock(player, item)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    end
  end

  if globalGui.currentTab == "HMProductionBlockTab" then
    if action == "production-recipe-remove" then
      self.parent.model:removeProductionRecipe(player, item, item2)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    end

    if action == "production-recipe-up" then
      self.parent.model:upProductionRecipe(player, item, item2)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    end

    if action == "production-recipe-down" then
      self.parent.model:downProductionRecipe(player, item, item2)
      self.parent.model:update(player)
      self:update(player, item, item2, item3)
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] on_event_access_delete
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:on_event_access_delete(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event_access_delete():", action, item, item2, item3)
  local globalGui = self.player:getGlobalGui(player)
  if action == "remove-model" then
    self.model:removeModel(player, item)
    globalGui.currentTab = "HMProductionLineTab"
    globalGui.currentBlock = "new"

    self:update(player, item, item2, item3)
    self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
    self.parent:send_event(player, "HMResourceEdition", "CLOSE")
    self.parent:send_event(player, "HMRecipeEdition", "CLOSE")
    self.parent:send_event(player, "HMProductEdition", "CLOSE")
    self.parent:send_event(player, "HMEnergyEdition", "CLOSE")
    self.parent:send_event(player, "HMSettings", "CLOSE")
  end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#MainTab] update
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:update(player, item, item2, item3)
  Logging:debug("MainTab", "update():", player, item, item2, item3)
  Logging:debug("MainTab", "update():global", global)
  local globalGui = self.player:getGlobalGui(player)
  local dataPanel = self:getDataPanel(player)

  dataPanel.clear()

  self:updateModelPanel(player, item, item2, item3)
  self:updateHeaderPanel(player, item, item2, item3)

  if self.tabs[globalGui.currentTab] ~= nil then
    local tab = self.tabs[globalGui.currentTab]
    tab:beforeUpdate(player, item, item2, item3)
    tab:updateHeader(player, item, item2, item3)
    tab:updateData(player, item, item2, item3)
  end

end

-------------------------------------------------------------------------------
-- Update model panel
--
-- @function [parent=#MainTab] updateModelPanel
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:updateModelPanel(player, item, item2, item3)
  Logging:debug("MainTab", "updateModelPanel():", player, item, item2, item3)
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
-- Update header panel
--
-- @function [parent=#MainTab] updateHeaderPanel
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:updateHeaderPanel(player, item, item2, item3)
  Logging:debug("MainTab", "updateHeaderPanel():", player, item, item2, item3)
  local models = self.model:getModels(player)
  local model = self.model:getModel(player)
  local model_id = self.player:getGlobalGui(player, "model_id")
  local globalGui = self.player:getGlobalGui(player)

  -- data
  local menuPanel = self:getMenuPanel(player)

  if globalGui.currentTab == "HMProductionBlockTab" then
    local blockId = globalGui.currentBlock or "new"
    local tabPanel = self:addGuiFlowH(menuPanel, "tab", "helmod_flow_data_tab")
    self:addGuiButton(tabPanel, "HMRecipeSelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-recipe"}))
    --self:addGuiButton(tabPanel, "HMTechnologySelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-technology"}))
    self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", "HMProductionLineTab", "helmod_button_default", ({"helmod_result-panel.back-button-production-line"}))
    self:addGuiButton(tabPanel, "HMPinPanel=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.tab-button-pin"}))
    self:addGuiButton(tabPanel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.refresh-button"}))
  elseif globalGui.currentTab == "HMPropertiesTab" then
    local tabPanel = self:addGuiFlowH(menuPanel, "tab", "helmod_flow_data_tab")
    self:addGuiButton(tabPanel, "HMEntitySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
    self:addGuiButton(tabPanel, "HMItemSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))
    self:addGuiButton(tabPanel, "HMRecipeSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-recipe"}))
    self:addGuiButton(tabPanel, "HMTechnologySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-technology"}))
    self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", "HMProductionLineTab", "helmod_button_default", ({"helmod_result-panel.back-button-production-line"}))
  else
    -- action panel
    local actionPanel = self:addGuiFlowH(menuPanel, "action", "helmod_flow_resize_row_width")
    self.player:setStyle(player, actionPanel, "data", "minimal_width")
    self.player:setStyle(player, actionPanel, "data", "maximal_width")
    local tabPanel = self:addGuiFlowH(actionPanel, "tab", "helmod_flow_data_tab")
    for _, tab in pairs(self.tabs) do
      if tab:classname() ~= "HMPropertiesTab" or self.player:getSettings(player, "properties_tab", true) then
        self:addGuiButton(tabPanel, self:classname().."=change-tab=ID=", tab:classname(), "helmod_button_default", tab:getButtonCaption())
      end
    end
    self:addGuiButton(tabPanel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.refresh-button"}))

    local deletePanel = self:addGuiFlowH(actionPanel, "delete", "helmod_flow_default")
    if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      self:addGuiButton(deletePanel, self:classname().."=remove-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.remove-button-production-line"}))
    end

    -- index panel
    local indexPanel = self:addGuiFlowH(menuPanel, "index", "helmod_flow_resize_row_width")
    self.player:setStyle(player, indexPanel, "data", "minimal_width")
    self.player:setStyle(player, indexPanel, "data", "maximal_width")

    Logging:debug("MainTab", "updateHeaderPanel():countModel", self.model:countModel())
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
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#MainTab] addCellElement
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #table element production block
--
function MainTab.methods:addCellElement(player, guiTable, element, action, select, tooltip_name, color)
  Logging:debug("MainTab", "addCellElement():", player, guiTable, element, action, select, tooltip_name, color)
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
-- @function [parent=#MainTab] addIconRecipeCell
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function MainTab.methods:addIconRecipeCell(player, cell, element, action, select, tooltip_name, color)
  Logging:debug("MainTab", "addIconRecipeCell():", element, action, select, tooltip_name, color)
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
-- @function [parent=#MainTab] addIconCell
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function MainTab.methods:addIconCell(player, cell, element, action, select, tooltip_name, color)
  Logging:debug("MainTab", "addIconCell():", player, cell, element, action, select, tooltip_name, color)
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
-- @function [parent=#MainTab] addCellLabel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #string label
--
function MainTab.methods:addCellLabel(player, guiTable, name, label, minimal_width)
  Logging:debug("MainTab", "addCellLabel():", guiTable, name, label)
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
-- Update properties tab
--
-- @function [parent=#MainTab] updateProperties
--
-- @param #LuaPlayer player
--
function MainTab.methods:updateProperties(player)
  Logging:debug("MainTab", "updateProperties():", player)
  local model = self.model:getModel(player)
  local globalGui = self.player:getGlobalGui(player)

  -- data
  local resultPanel = self:getResultPanel(player, ({"helmod_result-panel.tab-title-properties"}))

  local menuPanel = self:addGuiFlowH(resultPanel,"menu")
  self:addGuiButton(menuPanel, "HMEntitySelector=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
  self:addGuiButton(menuPanel, "HMItemSelector=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))


  local scrollPanel = self:addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_width")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "minimal_height")
  self.player:setStyle(player, scrollPanel, "scroll_block_list", "maximal_height")

end

-------------------------------------------------------------------------------
-- Format number for factory
--
-- @function [parent=#MainTab] formatNumberFactory
--
-- @param #number number
--
function MainTab.methods:formatNumberFactory(number)
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
-- @function [parent=#MainTab] formatNumberElement
--
-- @param #number number
--
function MainTab.methods:formatNumberElement(number)
  local decimal = 2
  local format_number = self.player:getSettings(nil, "format_number_element", true)
  if format_number == "0" then decimal = 0 end
  if format_number == "0.0" then decimal = 1 end
  if format_number == "0.00" then decimal = 2 end
  return self:formatNumber(number, decimal)
end
