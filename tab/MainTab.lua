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
--

MainTab = setclass("HMMainTab")

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
-- @return #LuaGuiElement
--
function MainTab.methods:getParentPanel()
  return self.parent:getDataPanel()
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#MainTab] getDataPanel
--
function MainTab.methods:getDataPanel()
  local parentPanel = self:getParentPanel()
  if parentPanel["data"] ~= nil and parentPanel["data"].valid then
    return parentPanel["data"]
  end
  return ElementGui.addGuiFlowV(parentPanel, "data", "helmod_flow_default")
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#MainTab] getModelPanel
--
function MainTab.methods:getModelPanel()
  local menuPanel = self.parent:getMenuPanel()
  if menuPanel["model"] ~= nil and menuPanel["model"].valid then
    return menuPanel["model"]
  end
  return ElementGui.addGuiFrameV(menuPanel, "model", "helmod_frame_default")
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainTab] getMenuPanel
--
function MainTab.methods:getMenuPanel(caption)
  local dataPanel = self:getDataPanel()
  if dataPanel["menu"] ~= nil and dataPanel["menu"].valid then
    return dataPanel["menu"]
  end
  local panel = ElementGui.addGuiFrameV(dataPanel, "menu", "helmod_frame_data_menu", caption)
  Player.setStyle(panel, "data", "minimal_width")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#MainTab] getInfoPanel
--
function MainTab.methods:getInfoPanel()
  local dataPanel = self:getDataPanel()
  if dataPanel["info"] ~= nil and dataPanel["info"].valid then
    return dataPanel["info"]
  end
  return ElementGui.addGuiFlowH(dataPanel, "info", "helmod_flow_full_resize_row")
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#MainTab] getResultPanel
--
-- @param #string caption
--
function MainTab.methods:getResultPanel(caption)
  local dataPanel = self:getDataPanel()
  if dataPanel["result"] ~= nil and dataPanel["result"].valid then
    return dataPanel["result"]
  end
  local panel = ElementGui.addGuiFrameV(dataPanel, "result", "helmod_frame_resize_row_width", caption)
  Player.setStyle(panel, "data", "minimal_width")
  Player.setStyle(panel, "data", "maximal_width")
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
  local resultPanel = self:getResultPanel(caption)
  local scrollPanel = ElementGui.addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  Player.setStyle(scrollPanel, "scroll_block_list", "minimal_width")
  Player.setStyle(scrollPanel, "scroll_block_list", "maximal_width")
  Player.setStyle(scrollPanel, "scroll_block_list", "minimal_height")
  Player.setStyle(scrollPanel, "scroll_block_list", "maximal_height")
  return scrollPanel
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
    self:getDataPanel()
    self:update()
  end
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
    self:update(item, item2, item3)
  end

  if action == "change-model" then
    globalGui.model_id = item
    globalGui.currentTab = "HMProductionLineTab"
    globalGui.currentBlock = "new"

    Controller.sendEvent(nil, "HMRecipeSelector", "CLOSE")
    Controller.sendEvent(nil, "HMResourceEdition", "CLOSE")
    Controller.sendEvent(nil, "HMRecipeEdition", "CLOSE")
    Controller.sendEvent(nil, "HMProductEdition", "CLOSE")
    Controller.sendEvent(nil, "HMEnergyEdition", "CLOSE")
    Controller.sendEvent(nil, "HMSettings", "CLOSE")

    Controller.refreshDisplay()
  end

  if action == "change-tab" then
    local panel_recipe = "CLOSE"
    globalGui.currentTab = item
    if item == "HMProductionLineTab" then
      globalGui.currentBlock = "new"
    end
    globalGui.currentBlock = item2
    if item == "HMProductionBlockTab" and globalGui.currentBlock == nil then
      Controller.sendEvent(nil, "HMRecipeSelector", "OPEN", item2)
    else
      Controller.sendEvent(nil, "HMRecipeSelector", "CLOSE")
    end
    Controller.sendEvent(nil, "HMResourceEdition", "CLOSE")
    Controller.sendEvent(nil, "HMRecipeEdition", "CLOSE")
    Controller.sendEvent(nil, "HMProductEdition", "CLOSE")
    Controller.sendEvent(nil, "HMEnergyEdition", "CLOSE")
    Controller.sendEvent(nil, "HMSettings", "CLOSE")

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
  local model = Model.getModel()
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
    Model.updateProductionBlockOption(globalGui.currentBlock, item, not(element[item]))
    Model.update()
    self:update(item, item2, item3)
  end

  if action == "change-number-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
    local panel = self:getInfoPanel()["block"]["output-scroll"]["output-table"]
    if panel[item] ~= nil then
      local value = ElementGui.getInputNumber(panel[item])
      Model.updateProductionBlockOption(globalGui.currentBlock, item, value)
      Model.update()
      self:update(item, item2, item3)
    end
  end

  if action == "change-time" then
    model.time = tonumber(item) or 1
    Model.update()
    self:update(item, item2, item3)
  end

  if action == "production-block-unlink" then
    Model.unlinkProductionBlock(item)
    Model.update()
    self:update(self.PRODUCTION_LINE_TAB, item, item2, item3)
  end

  if action == "production-recipe-add" then
    local recipes = Player.searchRecipe(item3)
    Logging:debug(self:classname(), "block recipes:",recipes)
    if #recipes == 1 then
      local recipe = recipes[1]
      local productionBlock = Model.addRecipeIntoProductionBlock(recipe.name, recipe.type)
      Model.update()
      self:update(item, item2, item3)
    else
      Controller.sendEvent(nil, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end

  if globalGui.currentTab == "HMProductionLineTab" then
    if action == "production-block-add" then
      local recipes = Player.searchRecipe(item2)
      Logging:debug(self:classname(), "line recipes:",recipes)
      if #recipes == 1 then
        local recipe = recipes[1]
        local productionBlock = Model.addRecipeIntoProductionBlock(recipe.name, recipe.type)
        Model.update()
        globalGui.currentTab = "HMProductionBlockTab"
        self:update(item, item2, item3)
      else
        globalGui.currentTab = "HMProductionBlockTab"
        Controller.sendEvent(nil, "HMRecipeSelector", "OPEN", item, item2, item3)
      end
    end

    if action == "production-block-remove" then
      Model.removeProductionBlock(item)
      Model.update()
      self:update(item, item2, item3)
    end

    if action == "production-block-up" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      Model.upProductionBlock(item, step)
      Model.update()
      self:update(item, item2, item3)
    end

    if action == "production-block-down" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      Model.downProductionBlock(item, step)
      Model.update()
      self:update(item, item2, item3)
    end
  end

  if globalGui.currentTab == "HMProductionBlockTab" then
    if action == "production-recipe-remove" then
      Model.removeProductionRecipe(item, item2)
      Model.update()
      self:update(item, item2, item3)
    end

    if action == "production-recipe-up" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      Model.upProductionRecipe(item, item2, step)
      Model.update()
      self:update(item, item2, item3)
    end

    if action == "production-recipe-down" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      Model.downProductionRecipe(item, item2, step)
      Model.update()
      self:update(item, item2, item3)
    end
  end

  if globalGui.currentTab == "HMEnergyTab" then
    if action == "power-remove" then
      Model.removePower(item)
      self:update(item, item2, item3)
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
    Model.removeModel(item)
    globalGui.currentTab = "HMProductionLineTab"
    globalGui.currentBlock = "new"

    self:update(item, item2, item3)
    Controller.sendEvent(nil, "HMRecipeSelector", "CLOSE")
    Controller.sendEvent(nil, "HMResourceEdition", "CLOSE")
    Controller.sendEvent(nil, "HMRecipeEdition", "CLOSE")
    Controller.sendEvent(nil, "HMProductEdition", "CLOSE")
    Controller.sendEvent(nil, "HMEnergyEdition", "CLOSE")
    Controller.sendEvent(nil, "HMSettings", "CLOSE")
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
  Logging:debug("MainTab", "update():", item, item2, item3)
  Logging:debug("MainTab", "update():global", global)
  local globalGui = Player.getGlobalGui()
  local dataPanel = self:getDataPanel()

  dataPanel.clear()

  self:updateModelPanel(item, item2, item3)
  self:updateHeaderPanel(item, item2, item3)

  if self.tabs[globalGui.currentTab] ~= nil then
    local tab = self.tabs[globalGui.currentTab]
    tab:beforeUpdate(item, item2, item3)
    tab:updateHeader(item, item2, item3)
    tab:updateData(item, item2, item3)
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
  local modelPanel = self:getModelPanel()
  local model = Model.getModel()

  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    Model.update(true)
  end

  for k,guiName in pairs(modelPanel.children_names) do
    modelPanel[guiName].destroy()
  end

  -- time panel
  ElementGui.addGuiButton(modelPanel, self:classname().."=base-time", nil, "helmod_button_icon_time", nil, ({"helmod_data-panel.base-time"}))

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
    ElementGui.addGuiButton(modelPanel, self:classname().."=change-time=ID=", time.value, style, time.name)
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

  -- data
  local menuPanel = self:getMenuPanel()

  if globalGui.currentTab == "HMProductionBlockTab" then
    local blockId = globalGui.currentBlock or "new"
    local tabPanel = ElementGui.addGuiFlowH(menuPanel, "tab", "helmod_flow_data_tab")
    ElementGui.addGuiButton(tabPanel, "HMRecipeSelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-recipe"}))
    ElementGui.addGuiButton(tabPanel, "HMTechnologySelector=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.add-button-technology"}))
    ElementGui.addGuiButton(tabPanel, self:classname().."=change-tab=ID=", "HMProductionLineTab", "helmod_button_default", ({"helmod_result-panel.back-button-production-line"}))
    ElementGui.addGuiButton(tabPanel, "HMPinPanel=OPEN=ID=", blockId, "helmod_button_default", ({"helmod_result-panel.tab-button-pin"}))
    ElementGui.addGuiButton(tabPanel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.refresh-button"}))
  elseif globalGui.currentTab == "HMPropertiesTab" then
    local tabPanel = ElementGui.addGuiFlowH(menuPanel, "tab", "helmod_flow_data_tab")
    ElementGui.addGuiButton(tabPanel, "HMEntitySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
    ElementGui.addGuiButton(tabPanel, "HMItemSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))
    ElementGui.addGuiButton(tabPanel, "HMFluidSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-fluid"}))
    ElementGui.addGuiButton(tabPanel, "HMRecipeSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-recipe"}))
    ElementGui.addGuiButton(tabPanel, "HMTechnologySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-technology"}))
    ElementGui.addGuiButton(tabPanel, self:classname().."=change-tab=ID=", "HMProductionLineTab", "helmod_button_default", ({"helmod_result-panel.back-button-production-line"}))
  else
    -- action panel
    local actionPanel = ElementGui.addGuiFlowH(menuPanel, "action", "helmod_flow_resize_row_width")
    Player.setStyle(actionPanel, "data", "minimal_width")
    Player.setStyle(actionPanel, "data", "maximal_width")
    local tabPanel = ElementGui.addGuiFlowH(actionPanel, "tab", "helmod_flow_data_tab")
    for _, tab in pairs(self.tabs) do
      if tab:classname() ~= "HMPropertiesTab" or Player.getSettings("properties_tab", true) then
        ElementGui.addGuiButton(tabPanel, self:classname().."=change-tab=ID=", tab:classname(), "helmod_button_default", tab:getButtonCaption())
      end
    end
    ElementGui.addGuiButton(tabPanel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.refresh-button"}))

    local deletePanel = ElementGui.addGuiFlowH(actionPanel, "delete", "helmod_flow_default")
    if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      ElementGui.addGuiButton(deletePanel, self:classname().."=remove-model=ID=", model.id, "helmod_button_default", ({"helmod_result-panel.remove-button-production-line"}))
    end

    -- index panel
    local indexPanel = ElementGui.addGuiFlowH(menuPanel, "index", "helmod_flow_resize_row_width")
    Player.setStyle(indexPanel, "data", "minimal_width")
    Player.setStyle(indexPanel, "data", "maximal_width")

    Logging:debug("MainTab", "updateHeaderPanel():countModel", Model.countModel())
    if Model.countModel() > 0 then
      local i = 0
      for _,imodel in pairs(models) do
        i = i + 1
        local style = "helmod_button_default"
        if imodel.id == model_id then style = "helmod_button_selected" end
        ElementGui.addGuiButton(indexPanel, self:classname().."=change-model=ID=", imodel.id, style, i)
      end
    end
    ElementGui.addGuiButton(indexPanel, self:classname().."=change-model=ID=", "new", "helmod_button_default", "+")
  end
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#MainTab] addCellElement
--
-- @param #LuaGuiElement guiTable
-- @param #table element production block
--
function MainTab.methods:addCellElement(guiTable, element, action, select, tooltip_name, color)
  Logging:debug("MainTab", "addCellElement():", guiTable, element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local cell = nil
  local button = nil

  if display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = self:addCellLabel(guiTable, element.name, Format.formatNumberKilo(element.count))
  else
    cell = self:addCellLabel(guiTable, element.name, Format.formatNumberElement(element.count))
  end

  self:addIconCell(cell, element, action, select, tooltip_name, color)
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#MainTab] addIconRecipeCell
--
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function MainTab.methods:addIconRecipeCell(cell, element, action, select, tooltip_name, color)
  Logging:debug("MainTab", "addIconRecipeCell():", element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSpriteM(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    else
      ElementGui.addGuiButtonSpriteM(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    end
  else
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSprite(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    else
      ElementGui.addGuiButtonSprite(cell, self:classname()..action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#MainTab] addIconCell
--
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function MainTab.methods:addIconCell(cell, element, action, select, tooltip_name, color)
  Logging:debug("MainTab", "addIconCell():", cell, element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSpriteM(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    else
      ElementGui.addGuiButtonSpriteM(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    end
  else
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSprite(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    else
      ElementGui.addGuiButtonSprite(cell, self:classname()..action, self.player:getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add cell label
--
-- @function [parent=#MainTab] addCellLabel
--
-- @param #string name
-- @param #string label
--
function MainTab.methods:addCellLabel(guiTable, name, label, minimal_width)
  Logging:debug("MainTab", "addCellLabel():", guiTable, name, label)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  local cell = nil

  if display_cell_mod == "small-text"then
    -- small
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_icon_text_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "small-icon" then
    -- small
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_icon_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 50
  else
    -- default
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 60

  end
  return cell
end

-------------------------------------------------------------------------------
-- Update properties tab
--
-- @function [parent=#MainTab] updateProperties
--
function MainTab.methods:updateProperties()
  Logging:debug("MainTab", "updateProperties()")
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()

  -- data
  local resultPanel = self:getResultPanel({"helmod_result-panel.tab-title-properties"})

  local menuPanel = ElementGui.addGuiFlowH(resultPanel,"menu")
  ElementGui.addGuiButton(menuPanel, "HMEntitySelector=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
  ElementGui.addGuiButton(menuPanel, "HMItemSelector=OPEN=ID=", "new", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))


  local scrollPanel = ElementGui.addGuiScrollPane(resultPanel, "scroll-data", "scroll_pane_style", "auto", "auto")
  Player.setStyle(scrollPanel, "scroll_block_list", "minimal_width")
  Player.setStyle(scrollPanel, "scroll_block_list", "maximal_width")
  Player.setStyle(scrollPanel, "scroll_block_list", "minimal_height")
  Player.setStyle(scrollPanel, "scroll_block_list", "maximal_height")

end
