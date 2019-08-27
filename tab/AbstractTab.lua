-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AbstractTab
--

AbstractTab = class(Form,function(base,classname)
  Form.init(base,classname)
end)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#AbstractTab] onInit
--
-- @param #Controller parent parent controller
--
function AbstractTab:onInit(parent)
  self.panelCaption = string.format("%s %s","Helmod",game.active_mods["helmod"])
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#AbstractTab] getButtonStyles
--
-- @return boolean
--
function AbstractTab:getButtonStyles()
  return "helmod_button_default","helmod_button_selected"
end

-------------------------------------------------------------------------------
-- Get panel name
--
-- @function [parent=#AbstractTab] getPanelName
--
-- @return #LuaGuiElement
--
function AbstractTab:getPanelName()
  return "HMTab"
end

-------------------------------------------------------------------------------
-- Get or create index panel
--
-- @function [parent=#AbstractTab] getIndexPanel
--
function AbstractTab:getIndexPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "index_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]["table_index"]
  end
  local panel = ElementGui.addGuiFrameH(content_panel, panel_name, helmod_frame_style.panel)
  panel.style.horizontally_stretchable = true
  local table_index = ElementGui.addGuiTable(panel, "table_index", ElementGui.getIndexColumnNumber(), helmod_table_style.list)
  return table_index
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#AbstractTab] getDebugPanel
--
function AbstractTab:getDebugPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "debug_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = ElementGui.addGuiFrameH(content_panel, panel_name, helmod_frame_style.panel, "Debug")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#AbstractTab] getInfoPanel
--
function AbstractTab:getInfoPanel()
  local parent_panel = self:getResultPanel()
  local panel_name = "info"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name]["info"]["info-scroll"],parent_panel[panel_name]["output"]["output-scroll"],parent_panel[panel_name]["input"]["input-scroll"]
  end
  local panel = ElementGui.addGuiFlowH(parent_panel, panel_name, helmod_flow_style.horizontal)
  panel.style.horizontally_stretchable = true
  panel.style.horizontal_spacing=10
  ElementGui.setStyle(panel, "block_info", "height")

  local info_panel = ElementGui.addGuiFlowV(panel, "info", helmod_flow_style.vertical)
  ElementGui.addGuiLabel(info_panel, "label-info", ({"helmod_common.information"}), "helmod_label_title_frame")
  ElementGui.setStyle(info_panel, "block_info", "width")
  local info_scroll = ElementGui.addGuiScrollPane(info_panel, "info-scroll", helmod_frame_style.scroll_pane, true)
  info_scroll.style.horizontally_stretchable = true

  local output_panel = ElementGui.addGuiFlowV(panel, "output", helmod_flow_style.vertical)
  ElementGui.addGuiLabel(output_panel, "label-info", ({"helmod_common.output"}), "helmod_label_title_frame")
  ElementGui.setStyle(output_panel, "block_info", "height")
  local output_scroll = ElementGui.addGuiScrollPane(output_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  --output_scroll.style.horizontally_stretchable = true


  local input_panel = ElementGui.addGuiFlowV(panel, "input", helmod_flow_style.vertical)
  ElementGui.addGuiLabel(input_panel, "label-info", ({"helmod_common.input"}), "helmod_label_title_frame")
  ElementGui.setStyle(input_panel, "block_info", "height")
  local input_scroll = ElementGui.addGuiScrollPane(input_panel, "input-scroll", helmod_frame_style.scroll_pane, true)
  --input_scroll.style.horizontally_stretchable = true
  return info_scroll, output_scroll, input_scroll
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#AbstractTab] getInfoPanel2
--
function AbstractTab:getInfoPanel2()
  local _,parent_panel = self:getResultPanel2()
  local panel_name = "info"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[panel_name]["info"]["info-scroll"],parent_panel[panel_name]["output"]["output-scroll"],parent_panel[panel_name]["input"]["input-scroll"]
  end
  local panel = ElementGui.addGuiFlowH(parent_panel, panel_name, helmod_flow_style.horizontal)
  panel.style.horizontally_stretchable = true
  panel.style.horizontal_spacing=10
  ElementGui.setStyle(panel, "block_info", "height")

  local info_panel = ElementGui.addGuiFlowV(panel, "info", helmod_flow_style.vertical)
  ElementGui.addGuiLabel(info_panel, "label-info", ({"helmod_common.information"}), "helmod_label_title_frame")
  ElementGui.setStyle(info_panel, "block_info", "width")
  local info_scroll = ElementGui.addGuiScrollPane(info_panel, "info-scroll", helmod_frame_style.scroll_pane, true)
  info_scroll.style.horizontally_stretchable = true

  local output_panel = ElementGui.addGuiFlowV(panel, "output", helmod_flow_style.vertical)
  ElementGui.addGuiLabel(output_panel, "label-info", ({"helmod_common.output"}), "helmod_label_title_frame")
  ElementGui.setStyle(output_panel, "block_info", "height")
  local output_scroll = ElementGui.addGuiScrollPane(output_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  output_scroll.style.horizontally_stretchable = true


  local input_panel = ElementGui.addGuiFlowV(panel, "input", helmod_flow_style.vertical)
  ElementGui.addGuiLabel(input_panel, "label-info", ({"helmod_common.input"}), "helmod_label_title_frame")
  ElementGui.setStyle(input_panel, "block_info", "height")
  local input_scroll = ElementGui.addGuiScrollPane(input_panel, "input-scroll", helmod_frame_style.scroll_pane, true)
  input_scroll.style.horizontally_stretchable = true
  return info_scroll, output_scroll, input_scroll
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#AbstractTab] getResultPanel
--
function AbstractTab:getResultPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "result"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = ElementGui.addGuiFrameV(content_panel, panel_name, helmod_frame_style.default, self:getButtonCaption())
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#AbstractTab] getResultPanel2
--
function AbstractTab:getResultPanel2()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "result2"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]["result1"],content_panel[panel_name]["result2"]
  end
  local panel = ElementGui.addGuiTable(content_panel,panel_name,2, helmod_table_style.panel)
  --ElementGui.setStyle(panel, "block_data", "height")
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true

  local panel1 = ElementGui.addGuiFrameV(panel, "result1", helmod_frame_style.default)
  local panel2 = ElementGui.addGuiFrameV(panel, "result2", helmod_frame_style.default, self:getButtonCaption())
  panel2.style.horizontally_stretchable = true
  panel2.style.vertically_stretchable = true
  return panel1,panel2
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#AbstractTab] getResultScrollPanel
--
function AbstractTab:getResultScrollPanel()
  local parent_panel = self:getResultPanel()
  if parent_panel["scroll-data"] ~= nil and parent_panel["scroll-data"].valid then
    return parent_panel["scroll-data"]
  end
  local scroll_panel = ElementGui.addGuiScrollPane(parent_panel, "scroll-data", helmod_frame_style.scroll_pane, true, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#AbstractTab] getResultScrollPanel2
--
function AbstractTab:getResultScrollPanel2()
  local parent_panel1,parent_panel2 = self:getResultPanel2()
  if parent_panel1["header-data1"] ~= nil and parent_panel1["header-data1"].valid then
    return parent_panel1["header-data1"],parent_panel2["header-data2"],parent_panel1["scroll-data1"],parent_panel2["scroll-data2"]
  end
  local header_panel1 = ElementGui.addGuiFlowV(parent_panel1, "header-data1", helmod_flow_style.vertical)
  local header_panel2 = ElementGui.addGuiFlowV(parent_panel2, "header-data2", helmod_flow_style.vertical)
  local scroll_panel1 = ElementGui.addGuiScrollPane(parent_panel1, "scroll-data1", helmod_frame_style.scroll_pane, true, true)
  --scroll_panel1.style.horizontally_stretchable = true
  scroll_panel1.style.vertically_stretchable = true
  scroll_panel1.style.width = 70
  local scroll_panel2 = ElementGui.addGuiScrollPane(parent_panel2, "scroll-data2", helmod_frame_style.scroll_pane, true, true)
  scroll_panel2.style.horizontally_stretchable = true
  scroll_panel2.style.vertically_stretchable = true
  return header_panel1,header_panel2,scroll_panel1,scroll_panel2
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#AbstractTab] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:onUpdate(event, action, item, item2, item3)
  Logging:debug(self.classname, "update():", item, item2, item3)

  self:beforeUpdate(item, item2, item3)
  self:updateMenuPanel(item, item2, item3)
  self:updateIndexPanel(item, item2, item3)

  self:updateHeader(item, item2, item3)
  self:updateData(item, item2, item3)

  Logging:debug(self.classname, "debug_mode", User.getModGlobalSetting("debug"))
  if User.getModGlobalSetting("debug") ~= "none" then
    self:updateDebugPanel()
  end

end

-------------------------------------------------------------------------------
-- Update menu panel
--
-- @function [parent=#AbstractTab] updateMenuPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:updateMenuPanel(item, item2, item3)
  Logging:debug(self.classname, "updateMenuPanel():", item, item2, item3)
  local models = Model.getModels()
  local model = Model.getModel()
  local model_id = User.getParameter("model_id")
  local current_block = User.getParameter("current_block")

  -- action panel
  local action_panel = self:getLeftMenuPanel()
  action_panel.clear()

  local group4 = ElementGui.addGuiFlowH(action_panel,"group4",helmod_flow_style.horizontal)
  for _, form in pairs(Controller.getViews()) do
    if string.find(form.classname, "Tab") and form:isVisible() and not(form:isSpecial()) then
      local style, selected_style = form:getButtonStyles()
      if User.isActiveForm(form.classname) then style = selected_style end
      ElementGui.addGuiButton(group4, self.classname.."=change-tab=ID=", form.classname, style, nil, form:getButtonCaption())
    end
  end

  if self.classname == "HMAdminTab" then
    ElementGui.addGuiButton(action_panel, "HMRuleEdition=", "OPEN", "helmod_button_default", ({"helmod_result-panel.add-button-rule"}))
    ElementGui.addGuiButton(action_panel, self.classname.."=reset-rules=", nil, "helmod_button_default", ({"helmod_result-panel.reset-button-rule"}))
  elseif self.classname == "HMPropertiesTab" then
    ElementGui.addGuiButton(action_panel, "HMEntitySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-entity"}))
    ElementGui.addGuiButton(action_panel, "HMItemSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-item"}))
    ElementGui.addGuiButton(action_panel, "HMFluidSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-fluid"}))
    ElementGui.addGuiButton(action_panel, "HMRecipeSelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-recipe"}))
    ElementGui.addGuiButton(action_panel, "HMTechnologySelector=", "OPEN", "helmod_button_default", ({"helmod_result-panel.select-button-technology"}))
  elseif self.classname == "HMPrototypeFiltersTab" then
  else
    -- add recipe
    local group1 = ElementGui.addGuiFlowH(action_panel,"group1",helmod_flow_style.horizontal)
    local block_id = current_block or "new"
    ElementGui.addGuiButton(group1, "HMRecipeSelector=OPEN=ID=", block_id, "helmod_button_icon_wrench",nil, ({"helmod_result-panel.add-button-recipe"}))
    ElementGui.addGuiButton(group1, "HMTechnologySelector=OPEN=ID=", block_id, "helmod_button_icon_graduation",nil, ({"helmod_result-panel.add-button-technology"}))
    ElementGui.addGuiButton(group1, "HMContainerSelector=OPEN=ID=", block_id, "helmod_button_icon_container",nil, ({"helmod_result-panel.select-button-container"}))

    local group2 = ElementGui.addGuiFlowH(action_panel,"group2",helmod_flow_style.horizontal)
    -- copy past
    ElementGui.addGuiButton(group2, self.classname.."=copy-model=ID=", model.id, "helmod_button_icon_copy", nil, ({"helmod_button.copy"}))
    ElementGui.addGuiButton(group2, self.classname.."=past-model=ID=", model.id, "helmod_button_icon_past", nil, ({"helmod_button.past"}))
    -- download
    if self.classname == "HMProductionLineTab" then
      ElementGui.addGuiButton(group2, "HMDownload=OPEN=ID=", "download", "helmod_button_icon_download", nil, ({"helmod_result-panel.download-button-production-line"}))
      ElementGui.addGuiButton(group2, "HMDownload=OPEN=ID=", "upload", "helmod_button_icon_upload", nil, ({"helmod_result-panel.upload-button-production-line"}))
    end
    -- delete control
    if User.isAdmin() or model.owner == User.name() or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
      if self.classname == "HMProductionLineTab" then
        ElementGui.addGuiButton(group2, self.classname.."=remove-model=ID=", model.id, "helmod_button_icon_delete_red", nil, ({"helmod_result-panel.remove-button-production-line"}))
      end
      if self.classname == "HMProductionBlockTab" then
        ElementGui.addGuiButton(group2, self.classname.."=production-block-remove=ID=", block_id, "helmod_button_icon_delete_red", nil, ({"helmod_result-panel.remove-button-production-block"}))
      end
    end
    -- refresh control
    ElementGui.addGuiButton(group2, self.classname.."=refresh-model=ID=", model.id, "helmod_button_icon_refresh", nil, ({"helmod_result-panel.refresh-button"}))

    local group3 = ElementGui.addGuiFlowH(action_panel,"group3",helmod_flow_style.horizontal)
    -- pin control
    if self.classname == "HMProductionBlockTab" then
      ElementGui.addGuiButton(group3, "HMPinPanel=OPEN=ID=", block_id, "helmod_button_icon_pin", nil, ({"helmod_result-panel.tab-button-pin"}))
      local block = model.blocks[block_id]
      if block ~= nil then
        local style = "helmod_button_icon_settings"
        if block.solver == true then style = "helmod_button_icon_settings_selected" end
        ElementGui.addGuiButton(group3, self.classname.."=production-block-solver=ID=", block_id, style, nil, ({"helmod_button.matrix-solver"}))
      end
    end
    -- pin info
    if self.classname == "HMStatisticTab" then
      ElementGui.addGuiButton(group3, "HMStatusPanel=OPEN=ID=", block_id, "helmod_button_icon_pin", nil, ({"helmod_result-panel.tab-button-pin"}))
    end
  end


  local time_panel = self:getRightMenuPanel()
  time_panel.clear()

  local group_special = ElementGui.addGuiFlowH(time_panel,"group_special",helmod_flow_style.horizontal)
  ElementGui.addGuiButton(group_special, "HMCalculator=OPEN=ID=", nil, "helmod_button_icon_calculator", nil, ({"helmod_calculator-panel.title"}))
  
  local items = {}
  local default_time = 1
  for index,base_time in pairs(helmod_base_times) do
    table.insert(items,base_time.tooltip)
    if model.time == base_time.value then
      default_time = base_time.tooltip
    end
  end

  local group_time = ElementGui.addGuiFlowH(time_panel,"group_time",helmod_flow_style.horizontal)
  ElementGui.addGuiLabel(group_time,"label_time",{"helmod_data-panel.base-time", ""}, "helmod_label_title_frame")
  
  ElementGui.addGuiDropDown(group_time, self.classname.."=change-time=ID=", model_id, items, default_time)

end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#Form] hasIndexModel
--
-- @return #boolean
--
function AbstractTab:hasIndexModel()
  return true
end

-------------------------------------------------------------------------------
-- Update index panel
--
-- @function [parent=#AbstractTab] updateIndexPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:updateIndexPanel(item, item2, item3)
  Logging:debug(self.classname, "updateIndexPanel():", item, item2, item3)
  local models = Model.getModels()
  local model_id = User.getParameter("model_id")

  if self:hasIndexModel() then
    -- index panel
    local index_panel = self:getIndexPanel()
    index_panel.clear()
    Logging:debug(self.classname, "updateIndexPanel():countModel", Model.countModel())
    if Model.countModel() > 0 then
      local i = 0
      for _,imodel in pairs(models) do
        i = i + 1
        local style = "helmod_button_default"
        --if imodel.id == model_id then style = "helmod_button_selected" end
        --ElementGui.addGuiButton(indexPanel, self.classname.."=change-model=ID=", imodel.id, style, i)
        local element = Model.firstRecipe(imodel.blocks)
        if imodel.id == model_id then
          if element ~= nil then
            ElementGui.addGuiButtonSprite(index_panel, self.classname.."=change-model=ID="..imodel.id.."=", Player.getIconType(element), element.name, imodel.id, RecipePrototype.load(element).getLocalisedName())
          else
            ElementGui.addGuiButton(index_panel, self.classname.."=change-model=ID=", imodel.id, "helmod_button_icon_help_selected")
          end
        else
          if element ~= nil then
            ElementGui.addGuiButtonSelectSprite(index_panel, self.classname.."=change-model=ID="..imodel.id.."=", Player.getIconType(element), element.name, imodel.id, RecipePrototype.load(element).getLocalisedName())
          else
            ElementGui.addGuiButton(index_panel, self.classname.."=change-model=ID=", imodel.id, "helmod_button_icon_help")
          end
        end

      end
    end
    ElementGui.addGuiShortButton(index_panel, self.classname.."=change-model=ID=", "new", "helmod_button_default", "+")
  else
    local index_panel = self:getIndexPanel()
    index_panel.clear()
  end
end

-------------------------------------------------------------------------------
-- Before update
--
-- @function [parent=#AbstractTab] beforeUpdate
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:beforeUpdate(item, item2, item3)
  Logging:trace(self.classname, "beforeUpdate():", item, item2, item3)
end

-------------------------------------------------------------------------------
-- Add cell header
--
-- @function [parent=#AbstractTab] addCellHeader
--
-- @param #LuaGuiElement guiTable
-- @param #string name
-- @param #string caption
-- @param #string sorted
--
function AbstractTab:addCellHeader(guiTable, name, caption, sorted)
  Logging:trace(self.classname, "addCellHeader():", guiTable, name, caption, sorted)

  if (name ~= "index" and name ~= "id" and name ~= "name" and name ~= "type") or User.getModGlobalSetting("display_data_col_"..name) then
    local cell = ElementGui.addGuiFrameH(guiTable,"header-"..name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(cell, "label", caption)
  end
end

-------------------------------------------------------------------------------
-- Update debug panel
--
-- @function [parent=#AbstractTab] updateDebugPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:updateDebugPanel(item, item2, item3)
  Logging:debug("AbstractTab", "updateDebugPanel():", item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#AbstractTab] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:updateHeader(item, item2, item3)
  Logging:debug("AbstractTab", "updateHeader():", item, item2, item3)
end
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AbstractTab] updateData
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab:updateData(item, item2, item3)
  Logging:debug("AbstractTab", "updateData():", item, item2, item3)
end
