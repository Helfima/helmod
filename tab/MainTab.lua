require "tab.EnergyTab"
require "tab.ProductionBlockTab"
require "tab.ProductionLineTab"
require "tab.ResourceTab"
require "tab.SummaryTab"
require "tab.StatisticTab"
require "tab.PropertiesTab"
require "tab.AdminTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module MainTab
--

MainTab = setclass("HMMainTab", Form)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#MainTab] init
--
-- @param #Controller parent parent controller
--
function MainTab.methods:init(parent)
  self.parent = parent

  local tabs = {}
  table.insert(tabs, ProductionLineTab:new(self))
  table.insert(tabs, ProductionBlockTab:new(self))
  table.insert(tabs, EnergyTab:new(self))
  table.insert(tabs, ResourceTab:new(self))
  table.insert(tabs, SummaryTab:new(self))
  table.insert(tabs, StatisticTab:new(self))
  table.insert(tabs, PropertiesTab:new(self))
  table.insert(tabs, AdminTab:new(self))

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
-- @return #LuaGuiElement
--
function MainTab.methods:getParentPanel()
  return self.parent:getDataPanel()
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#MainTab] getModelPanel
--
function MainTab.methods:getModelPanel()
  local menu_panel = self.parent:getMenuPanel()
  if menu_panel["model_panel"] ~= nil and menu_panel["model_panel"].valid then
    return menu_panel["model_panel"]["model_table"]
  end
  local panel = ElementGui.addGuiFrameV(menu_panel, "model_panel", helmod_frame_style.default)
  return ElementGui.addGuiTable(panel, "model_table", 1, helmod_table_style.list)
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#MainTab] getDebugPanel
--
function MainTab.methods:getDebugPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel["debug_panel"] ~= nil and parent_panel["debug_panel"].valid then
    return parent_panel["debug_panel"]
  end
  local panel = ElementGui.addGuiFrameH(parent_panel, "debug_panel", helmod_frame_style.panel, "Debug")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainTab] getMenuPanel
--
function MainTab.methods:getMenuPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel["menu_panel"] ~= nil and parent_panel["menu_panel"].valid then
    return parent_panel["menu_panel"]
  end
  local panel = ElementGui.addGuiFrameV(parent_panel, "menu_panel", helmod_frame_style.panel)
  return panel
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainTab] getTabMenuPanel
--
function MainTab.methods:getTabMenuPanel()
  local parent_panel = self:getMenuPanel()
  if parent_panel["tab_menu_panel"] ~= nil and parent_panel["tab_menu_panel"].valid then
    return parent_panel["tab_menu_panel"]
  end
  local panel = ElementGui.addGuiTable(parent_panel, "tab_menu_panel", 20, helmod_table_style.tab)
  return panel
end

-------------------------------------------------------------------------------
-- Get or create action panel
--
-- @function [parent=#MainTab] getActionPanel
--
function MainTab.methods:getActionPanel()
  local parent_panel = self:getMenuPanel()
  if parent_panel["action_panel"] ~= nil and parent_panel["action_panel"].valid then
    return parent_panel["action_panel"]
  end
  local panel = ElementGui.addGuiTable(parent_panel, "action_panel", 10, helmod_table_style.list)
  return panel
end

-------------------------------------------------------------------------------
-- Get or create index panel
--
-- @function [parent=#MainTab] getIndexPanel
--
function MainTab.methods:getIndexPanel()
  local parent_panel = self:getMenuPanel()
  if parent_panel["index_panel"] ~= nil and parent_panel["index_panel"].valid then
    return parent_panel["index_panel"]
  end
  local panel = ElementGui.addGuiTable(parent_panel, "index_panel", 10, helmod_table_style.list)
  return panel
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#MainTab] getInfoPanel
--
function MainTab.methods:getInfoPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel["info_panel"] ~= nil and parent_panel["info_panel"].valid then
    return parent_panel["info_panel"]
  end
  local table_panel = ElementGui.addGuiTable(parent_panel, "info_panel", 2, helmod_table_style.panel)
  table_panel.style.horizontally_stretchable = true
  return table_panel
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#MainTab] getResultPanel
--
-- @param #string caption
--
function MainTab.methods:getResultPanel(caption)
  local parent_panel = self:getParentPanel()
  if parent_panel["result"] ~= nil and parent_panel["result"].valid then
    return parent_panel["result"]
  end
  local panel = ElementGui.addGuiFrameV(parent_panel, "result", helmod_frame_style.panel, caption)
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#MainTab] getResultScrollPanel
--
-- @param #string caption
--
function MainTab.methods:getResultScrollPanel(caption)
  local result_panel = self:getResultPanel(caption)
  local scroll_panel = ElementGui.addGuiScrollPane(result_panel, "scroll-data", helmod_frame_style.scroll_pane, true, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Build the parent panel
--
-- @function [parent=#MainTab] buildPanel
--
function MainTab.methods:buildPanel()
  Logging:debug("MainTab", "buildPanel()")

  local globalGui = Player.getGlobalGui()
  if globalGui.currentTab == nil then
    globalGui.order = {name="index", ascendant=true}
  end

  if globalGui.currentTab == nil or self.tabs[globalGui.currentTab] == nil then
    globalGui.currentTab = "HMProductionLineTab"
  end

  local parentPanel = self:getParentPanel()

  if parentPanel ~= nil then
    self:update()
  end
end

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#MainTab] open
-- 
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function MainTab.methods:open(event, action, item, item2, item3)
  Logging:debug(self:classname(), "open():", action, item, item2, item3)
end
-------------------------------------------------------------------------------
-- Send event
--
-- @function [parent=#MainTab] sendEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
-- 
function MainTab.methods:sendEvent(event, action, item, item2, item3)
  Logging:debug("MainTab", "sendEvent():", action, item, item2, item3)
  self:onEvent(event, action, item, item2, item3)
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)

  local globalGui = Player.getGlobalGui()

  local model = Model.getModel()
  if self.tabs[globalGui.currentTab] ~= nil then

    -- *******************************
    -- access admin only
    -- *******************************
    
    if Player.isAdmin() then
      self:onEventAccessAdmin(event, action, item, item2, item3)
    end

    -- *******************************
    -- access admin or owner or write
    -- *******************************

    if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
      self:onEventAccessWrite(event, action, item, item2, item3)
    end

    -- ***************************
    -- access admin or owner
    -- ***************************

    if Player.isAdmin() or model.owner == Player.native().name then
      self:onEventAccessRead(event, action, item, item2, item3)
    end

    -- ********************************
    -- access admin or owner or delete
    -- ********************************

    if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      self:onEventAccessDelete(event, action, item, item2, item3)
    end

    -- ***************************
    -- access for all
    -- ***************************
    self:onEventAccessAll(event, action, item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] onEventAccessAll
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:onEventAccessAll(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEventAccessAll():", action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  if action == "refresh-model" then
    ModelCompute.update()
    self:update(item, item2, item3)
  end

  if action == "change-model" then
    globalGui.model_id = item
    globalGui.currentTab = "HMProductionLineTab"
    globalGui.currentBlock = "new"
    Controller.refreshDisplay()
  end

  if action == "change-tab" then
    globalGui.currentTab = item
    if item == "HMProductionLineTab" then
      globalGui.currentBlock = "new"
    end
    globalGui.currentBlock = item2
    self.parent:refreshDisplayData()
  end

  if action == "change-sort" then
    if globalGui.order.name == item then
      globalGui.order.ascendant = not(globalGui.order.ascendant)
    else
      globalGui.order = {name=item, ascendant=true}
    end
    self:update(item, item2, item3)
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] onEventAccessRead
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:onEventAccessRead(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEventAccessRead():", action, item, item2, item3)

  local globalGui = Player.getGlobalGui()

  if action == "copy-model" then
    if globalGui.currentTab == "HMProductionBlockTab" then
      if globalGui.currentBlock ~= nil and globalGui.currentBlock ~= "new" then
        globalGui.copy_from_block_id = globalGui.currentBlock
        globalGui.copy_from_model_id = Player.getGlobalGui("model_id")
      end
    end
    if globalGui.currentTab == "HMProductionLineTab" then
      globalGui.copy_from_block_id = nil
      globalGui.copy_from_model_id = Player.getGlobalGui("model_id")
    end
  end
  if action == "share-model" then
    local models = Model.getModels(true)
    local model = models[item2]
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
    self:update(item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] onEventAccessWrite
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:onEventAccessWrite(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEventAccessWrite():", action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local model = Model.getModel()
  if action == "change-boolean-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
    local element = model.blocks[globalGui.currentBlock]
    ModelBuilder.updateProductionBlockOption(globalGui.currentBlock, item, not(element[item]))
    ModelCompute.update()
    self:update(item, item2, item3)
  end

  if action == "change-number-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
    local panel = self:getInfoPanel()["block"]["output-scroll"]["output-table"]
    if panel[item] ~= nil then
      local value = ElementGui.getInputNumber(panel[item])
      ModelBuilder.updateProductionBlockOption(globalGui.currentBlock, item, value)
      ModelCompute.update()
      self:update(item, item2, item3)
    end
  end

  if action == "change-time" then
    model.time = tonumber(item) or 1
    ModelCompute.update()
    self:update(item, item2, item3)
  end

  if action == "product-selected" then
    if event.button == defines.mouse_button_type.right then
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end

  if action == "product-edition" then
    if event.button == defines.mouse_button_type.right then
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    else
      Controller.createEvent(event, "HMProductEdition", "OPEN", item, item2, item3)
    end
  end

  if action == "production-block-unlink" then
    ModelBuilder.unlinkProductionBlock(item)
    ModelCompute.update()
    self:update(self.PRODUCTION_LINE_TAB, item, item2, item3)
  end

  if action == "production-recipe-add" then
    local recipes = Player.searchRecipe(item3)
    Logging:debug(self:classname(), "block recipes:",recipes)
    if #recipes == 1 then
      local recipe = recipes[1]
      ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
      ModelCompute.update()
      self:update(item, item2, item3)
    else
      Controller.createEvent(nil, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end

  if action == "production-block-solver" then
    if model.blocks[item] ~= nil then
      ModelBuilder.updateProductionBlockOption(item, "solver", not(model.blocks[item].solver))
      ModelCompute.update()
      self:update(item, item2, item3)
    end
  end

  if action == "production-block-remove" then
    ModelBuilder.removeProductionBlock(item)
    ModelCompute.update()
    self:update(item, item2, item3)
    globalGui.currentBlock = "new"
  end

  if globalGui.currentTab == "HMProductionLineTab" then
    if action == "production-block-add" then
      local recipes = Player.searchRecipe(item2)
      Logging:debug(self:classname(), "line recipes:",recipes)
      if #recipes == 1 then
        local recipe = recipes[1]
        ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
        ModelCompute.update()
        globalGui.currentTab = "HMProductionBlockTab"
        self:update(item, item2, item3)
      else
        globalGui.currentTab = "HMProductionBlockTab"
        Controller.createEvent(nil, "HMRecipeSelector", "OPEN", item, item2, item3)
      end
    end

    if action == "production-block-up" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionBlock(item, step)
      ModelCompute.update()
      self:update(item, item2, item3)
    end

    if action == "production-block-down" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionBlock(item, step)
      ModelCompute.update()
      self:update(item, item2, item3)
    end
  end

  if globalGui.currentTab == "HMProductionBlockTab" then
    if action == "production-recipe-remove" then
      ModelBuilder.removeProductionRecipe(item, item2)
      ModelCompute.update()
      self:update(item, item2, item3)
    end

    if action == "production-recipe-up" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionRecipe(item, item2, step)
      ModelCompute.update()
      self:update(item, item2, item3)
    end

    if action == "production-recipe-down" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionRecipe(item, item2, step)
      ModelCompute.update()
      self:update(item, item2, item3)
    end
  end

  if globalGui.currentTab == "HMEnergyTab" then
    if action == "power-remove" then
      ModelBuilder.removePower(item)
      self:update(item, item2, item3)
    end
  end

  if action == "past-model" then
    if globalGui.currentTab == "HMProductionBlockTab" then
      ModelBuilder.pastModel(globalGui.copy_from_model_id, globalGui.copy_from_block_id)
      ModelCompute.update()
      self:update(item, item2, item3)
    end
    if globalGui.currentTab == "HMProductionLineTab" then
      ModelBuilder.pastModel(globalGui.copy_from_model_id, globalGui.copy_from_block_id)
      ModelCompute.update()
      self:update(item, item2, item3)
      globalGui.currentBlock = "new"
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] onEventAccessDelete
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:onEventAccessDelete(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEventAccessDelete():", action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  if action == "remove-model" then
    ModelBuilder.removeModel(item)
    globalGui.currentTab = "HMProductionLineTab"
    globalGui.currentBlock = "new"

    self:update(item, item2, item3)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#MainTab] onEventAccessAdmin
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:onEventAccessAdmin(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEventAccessAdmin():", action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  if action == "rule-remove" then
    ModelBuilder.removeRule(item)
    self:update(item, item2, item3)
  end
  if action == "reset-rules" then
    Model.resetRules()
    self:update(item, item2, item3)
  end
  
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#MainTab] update
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:update(item, item2, item3)
  Logging:debug(self:classname(), "update():", item, item2, item3)
  Logging:debug(self:classname(), "update():global", global)
  local globalGui = Player.getGlobalGui()
  local parent_panel = self:getParentPanel()

  parent_panel.clear()

  self:updateModelPanel(item, item2, item3)
  self:updateHeaderPanel(item, item2, item3)

  if self.tabs[globalGui.currentTab] ~= nil then
    local tab = self.tabs[globalGui.currentTab]
    Logging:debug(self:classname(), "debug_mode", Player.getSettings("debug"))
    if Player.getSettings("debug", true) ~= "none" then
      tab:updateDebugPanel()
    end

    tab:beforeUpdate(item, item2, item3)
    tab:updateHeader(item, item2, item3)
    tab:updateData(item, item2, item3)
    Controller.refreshPin()
  end

end

-------------------------------------------------------------------------------
-- Update model panel
--
-- @function [parent=#MainTab] updateModelPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:updateModelPanel(item, item2, item3)
  Logging:debug("MainTab", "updateModelPanel():", item, item2, item3)
  local model_panel = self:getModelPanel()
  local model = Model.getModel()

  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    ModelCompute.update(true)
  end

  model_panel.clear()

  -- time panel
  local times = {
    { value = 1, caption = "1s", tooltip="1s"},
    { value = 60, caption = "1", tooltip="1mn"},
    { value = 300, caption = "5", tooltip="5mn"},
    { value = 600, caption = "10", tooltip="10mn"},
    { value = 1800, caption = "30", tooltip="30mn"},
    { value = 3600, caption = "1h", tooltip="1h"},
    { value = 3600*6, caption = "6h", tooltip="6h"},
    { value = 3600*12, caption = "12h", tooltip="12h"},
    { value = 3600*24, caption = "24h", tooltip="24h"}
  }
  for _,time in pairs(times) do
    local style = "helmod_button_icon_time"
    if model.time == time.value then style = "helmod_button_icon_time_selected" end
    ElementGui.addGuiButton(model_panel, self:classname().."=change-time=ID=", time.value, style, time.caption, {"helmod_data-panel.base-time", time.tooltip})
  end

end

-------------------------------------------------------------------------------
-- Update header panel
--
-- @function [parent=#MainTab] updateHeaderPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainTab.methods:updateHeaderPanel(item, item2, item3)
  Logging:debug("MainTab", "updateHeaderPanel():", item, item2, item3)
  local models = Model.getModels()
  local model = Model.getModel()
  local model_id = Player.getGlobalGui("model_id")
  local globalGui = Player.getGlobalGui()

  -- tab menu panel
  local tab_menu_panel = self:getTabMenuPanel()

  for _, tab in pairs(self.tabs) do
    if (tab:classname() ~= "HMPropertiesTab" or Player.getSettings("properties_tab", true)) and (tab:classname() ~= "HMAdminTab" or Player.isAdmin()) then
      local style = "helmod_button_tab"
      if tab:classname() == globalGui.currentTab then style = "helmod_button_tab_selected" end
      ElementGui.addGuiFrameH(tab_menu_panel,tab:classname().."_separator",helmod_frame_style.tab).style.width = 5
      ElementGui.addGuiButton(tab_menu_panel, self:classname().."=change-tab=ID=", tab:classname(), style, tab:getButtonCaption())
    end
  end
  ElementGui.addGuiFrameH(tab_menu_panel,"tab_final",helmod_frame_style.tab).style.width = 1000
  -- action panel
  local action_panel = self:getActionPanel()

  if globalGui.currentTab == "HMAdminTab" then
    ElementGui.addGuiButton(action_panel, "HMRuleEdition=", "OPEN", "helmod_button_default", ({"helmod_result-panel.add-button-rule"}))
    ElementGui.addGuiButton(action_panel, self:classname().."=reset-rules=", nil, "helmod_button_default", ({"helmod_result-panel.reset-button-rule"}))
  elseif globalGui.currentTab == "HMPropertiesTab" then
    ElementGui.addGuiButton(action_panel, "HMEntitySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
    ElementGui.addGuiButton(action_panel, "HMItemSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))
    ElementGui.addGuiButton(action_panel, "HMFluidSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-fluid"}))
    ElementGui.addGuiButton(action_panel, "HMRecipeSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-recipe"}))
    ElementGui.addGuiButton(action_panel, "HMTechnologySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-technology"}))
  else
    -- add recipe
    local block_id = globalGui.currentBlock or "new"
    ElementGui.addGuiButton(action_panel, "HMRecipeSelector=OPEN=ID=", block_id, "helmod_button_default", ({"helmod_result-panel.add-button-recipe"}))
    ElementGui.addGuiButton(action_panel, "HMTechnologySelector=OPEN=ID=", block_id, "helmod_button_default", ({"helmod_result-panel.add-button-technology"}))
    ElementGui.addGuiButton(action_panel, "HMContainerSelector=OPEN=ID=", block_id, "helmod_button_default", ({"helmod_result-panel.select-button-container"}))
    -- copy past
    ElementGui.addGuiButton(action_panel, self:classname().."=copy-model=ID=", model.id, "helmod_button_icon_copy", nil, ({"helmod_button.copy"}))
    ElementGui.addGuiButton(action_panel, self:classname().."=past-model=ID=", model.id, "helmod_button_icon_past", nil, ({"helmod_button.past"}))
    -- download
    if globalGui.currentTab == "HMProductionLineTab" then
      ElementGui.addGuiButton(action_panel, "HMDownload=OPEN=ID=", "download", "helmod_button_icon_download", nil, ({"helmod_result-panel.download-button-production-line"}))
      ElementGui.addGuiButton(action_panel, "HMDownload=OPEN=ID=", "upload", "helmod_button_icon_upload", nil, ({"helmod_result-panel.upload-button-production-line"}))
    end
    -- delete control
    if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      if globalGui.currentTab == "HMProductionLineTab" then
        ElementGui.addGuiButton(action_panel, self:classname().."=remove-model=ID=", model.id, "helmod_button_icon_delete_red", nil, ({"helmod_result-panel.remove-button-production-line"}))
      end
      if globalGui.currentTab == "HMProductionBlockTab" then
        ElementGui.addGuiButton(action_panel, self:classname().."=production-block-remove=ID=", block_id, "helmod_button_icon_delete_red", nil, ({"helmod_result-panel.remove-button-production-block"}))
      end
    end
    -- refresh control
    ElementGui.addGuiButton(action_panel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_icon_refresh", nil, ({"helmod_result-panel.refresh-button"}))
    -- pin control
    if globalGui.currentTab == "HMProductionBlockTab" then
      ElementGui.addGuiButton(action_panel, "HMPinPanel=OPEN=ID=", block_id, "helmod_button_icon_pin", nil, ({"helmod_result-panel.tab-button-pin"}))
      local block = model.blocks[block_id]
      if block ~= nil then
        local style = "helmod_button_icon_settings"
        if block.solver == true then style = "helmod_button_icon_settings_selected" end
        ElementGui.addGuiButton(action_panel, self:classname().."=production-block-solver=ID=", block_id, style, nil, ({"helmod_button.matrix-solver"}))
      end
    end
    -- pin info
    if globalGui.currentTab == "HMStatisticTab" then
      ElementGui.addGuiButton(action_panel, "HMStatusPanel=OPEN=ID=", block_id, "helmod_button_icon_pin", nil, ({"helmod_result-panel.tab-button-pin"}))
    end
    -- index panel
    local index_panel = self:getIndexPanel()

    Logging:debug("MainTab", "updateHeaderPanel():countModel", Model.countModel())
    if Model.countModel() > 0 then
      local i = 0
      for _,imodel in pairs(models) do
        i = i + 1
        local style = "helmod_button_default"
        --if imodel.id == model_id then style = "helmod_button_selected" end
        --ElementGui.addGuiButton(indexPanel, self:classname().."=change-model=ID=", imodel.id, style, i)
        local element = Model.firstRecipe(imodel.blocks)
        if imodel.id == model_id then
          if element ~= nil then
            ElementGui.addGuiButtonSprite(index_panel, self:classname().."=change-model=ID="..imodel.id.."=", Player.getIconType(element), element.name, imodel.id, RecipePrototype.load(element).getLocalisedName())
          else
            ElementGui.addGuiButton(index_panel, self:classname().."=change-model=ID=", imodel.id, "helmod_button_icon_help_selected")
          end
        else
          if element ~= nil then
            ElementGui.addGuiButtonSelectSprite(index_panel, self:classname().."=change-model=ID="..imodel.id.."=", Player.getIconType(element), element.name, imodel.id, RecipePrototype.load(element).getLocalisedName())
          else
            ElementGui.addGuiButton(index_panel, self:classname().."=change-model=ID=", imodel.id, "helmod_button_icon_help")
          end
        end

      end
    end
    ElementGui.addGuiButton(index_panel, self:classname().."=change-model=ID=", "new", "helmod_button_default", "+")
  end
end


