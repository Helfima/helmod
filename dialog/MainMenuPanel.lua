-------------------------------------------------------------------------------
-- Class to build main menu form
--
-- @module MainMenuPanel
-- @extends #Form
--

MainMenuPanel = setclass("HMMainMenuPanel", Form)

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#MainMenuPanel] getParentPanel
--
-- @return #LuaGuiElement
--
function MainMenuPanel.methods:getParentPanel()
  return Controller.getMenuPanel()
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#MainMenuPanel] getMenuPanel
--
function MainMenuPanel.methods:getMenuPanel()
  local parent_panel = self:getPanel()
  if parent_panel["menu_panel"] ~= nil then
    return parent_panel["menu_panel"]
  end
  local panel = ElementGui.addGuiFrameV(parent_panel, "menu_panel", helmod_frame_style.panel)
  ElementGui.setStyle(panel, "data", "width")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#MainMenuPanel] getTabPanel
--
function MainMenuPanel.methods:getTabPanel()
  local parent_panel = self:getMenuPanel()
  if parent_panel["tab_panel"] ~= nil and parent_panel["tab_panel"].valid then
    return parent_panel["tab_panel"]
  end
  local panel = ElementGui.addGuiTable(parent_panel, "tab_panel", 20, helmod_table_style.tab)
  return panel
end

-------------------------------------------------------------------------------
-- Get or create action panel
--
-- @function [parent=#MainMenuPanel] getActionPanel
--
function MainMenuPanel.methods:getActionPanel()
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
-- @function [parent=#MainMenuPanel] getIndexPanel
--
function MainMenuPanel.methods:getIndexPanel()
  local parent_panel = self:getMenuPanel()
  if parent_panel["index_panel"] ~= nil and parent_panel["index_panel"].valid then
    return parent_panel["index_panel"]
  end
  local panel = ElementGui.addGuiTable(parent_panel, "index_panel", ElementGui.getIndexColumnNumber(), helmod_table_style.list)
  return panel
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#MainMenuPanel] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainMenuPanel.methods:onUpdate(event, action, item, item2, item3)
  self:updateMenuPanel(item, item2, item3)
  self:updateIndexPanel(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update menu panel
--
-- @function [parent=#MainMenuPanel] updateMenuPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainMenuPanel.methods:updateMenuPanel(item, item2, item3)
  Logging:debug(self:classname(), "updateMenuPanel():", item, item2, item3)
  local models = Model.getModels()
  local model = Model.getModel()
  local model_id = Player.getGlobalGui("model_id")
  local globalGui = Player.getGlobalGui()
  local current_tab = Player.getGlobalUI("data")

  -- tab menu panel
  local menu_panel = self:getTabPanel()
  menu_panel.clear()

  for _, form in pairs(Controller.getViews()) do
    if string.find(form:classname(), "Tab") and form:isVisible() then
      local style = "helmod_button_tab"
      if form:classname() == current_tab then style = "helmod_button_tab_selected" end
      ElementGui.addGuiFrameH(menu_panel,form:classname().."_separator",helmod_frame_style.tab).style.width = 5
      ElementGui.addGuiButton(menu_panel, self:classname().."=change-tab=ID=", form:classname(), style, form:getButtonCaption())
    end
  end
  -- action panel
  local action_panel = self:getActionPanel()
  action_panel.clear()

  if current_tab == "HMAdminTab" then
    ElementGui.addGuiButton(action_panel, "HMRuleEdition=", "OPEN", "helmod_button_default", ({"helmod_result-panel.add-button-rule"}))
    ElementGui.addGuiButton(action_panel, self:classname().."=reset-rules=", nil, "helmod_button_default", ({"helmod_result-panel.reset-button-rule"}))
  elseif current_tab == "HMPropertiesTab" then
    ElementGui.addGuiButton(action_panel, "HMEntitySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
    ElementGui.addGuiButton(action_panel, "HMItemSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))
    ElementGui.addGuiButton(action_panel, "HMFluidSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-fluid"}))
    ElementGui.addGuiButton(action_panel, "HMRecipeSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-recipe"}))
    ElementGui.addGuiButton(action_panel, "HMTechnologySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-technology"}))
  elseif current_tab == "HMPrototypeFiltersTab" then
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
    if current_tab == "HMProductionLineTab" then
      ElementGui.addGuiButton(action_panel, "HMDownload=OPEN=ID=", "download", "helmod_button_icon_download", nil, ({"helmod_result-panel.download-button-production-line"}))
      ElementGui.addGuiButton(action_panel, "HMDownload=OPEN=ID=", "upload", "helmod_button_icon_upload", nil, ({"helmod_result-panel.upload-button-production-line"}))
    end
    -- delete control
    if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      if current_tab == "HMProductionLineTab" then
        ElementGui.addGuiButton(action_panel, self:classname().."=remove-model=ID=", model.id, "helmod_button_icon_delete_red", nil, ({"helmod_result-panel.remove-button-production-line"}))
      end
      if current_tab == "HMProductionBlockTab" then
        ElementGui.addGuiButton(action_panel, self:classname().."=production-block-remove=ID=", block_id, "helmod_button_icon_delete_red", nil, ({"helmod_result-panel.remove-button-production-block"}))
      end
    end
    -- refresh control
    ElementGui.addGuiButton(action_panel, self:classname().."=refresh-model=ID=", model.id, "helmod_button_icon_refresh", nil, ({"helmod_result-panel.refresh-button"}))
    -- pin control
    if current_tab == "HMProductionBlockTab" then
      ElementGui.addGuiButton(action_panel, "HMPinPanel=OPEN=ID=", block_id, "helmod_button_icon_pin", nil, ({"helmod_result-panel.tab-button-pin"}))
      local block = model.blocks[block_id]
      if block ~= nil then
        local style = "helmod_button_icon_settings"
        if block.solver == true then style = "helmod_button_icon_settings_selected" end
        ElementGui.addGuiButton(action_panel, self:classname().."=production-block-solver=ID=", block_id, style, nil, ({"helmod_button.matrix-solver"}))
      end
    end
    -- pin info
    if current_tab == "HMStatisticTab" then
      ElementGui.addGuiButton(action_panel, "HMStatusPanel=OPEN=ID=", block_id, "helmod_button_icon_pin", nil, ({"helmod_result-panel.tab-button-pin"}))
    end
  end
end

-------------------------------------------------------------------------------
-- Update index panel
--
-- @function [parent=#MainMenuPanel] updateIndexPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function MainMenuPanel.methods:updateIndexPanel(item, item2, item3)
  Logging:debug(self:classname(), "updateIndexPanel():", item, item2, item3)
  local models = Model.getModels()
  local model = Model.getModel()
  local model_id = Player.getGlobalGui("model_id")
  local current_tab = Player.getGlobalUI("data")
  local view = Controller.getView(current_tab)
  
  if view:hasIndexModel() then
    -- index panel
    local index_panel = self:getIndexPanel()
    index_panel.clear()
    Logging:debug(self:classname(), "updateIndexPanel():countModel", Model.countModel())
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
    ElementGui.addGuiShortButton(index_panel, self:classname().."=change-model=ID=", "new", "helmod_button_default", "+")
  else
    local index_panel = self:getIndexPanel()
    index_panel.clear()
  end
end
