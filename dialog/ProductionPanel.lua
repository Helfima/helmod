-------------------------------------------------------------------------------
---Class to build production panel
---@class ProductionPanel
ProductionPanel = newclass(FormModel,function(base,classname)
  FormModel.init(base,classname)
  base.add_special_button = true
  base.has_tips = true
end)

-------------------------------------------------------------------------------
---On initialization
function ProductionPanel:onInit()
  self.panelCaption = string.format("%s %s","Helmod",game.active_mods["helmod"])
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function ProductionPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
  Dispatcher:bind("on_gui_pause", self, self.updateTopMenu)
end

-------------------------------------------------------------------------------
---Return button caption
---@return string
function ProductionPanel:getButtonCaption()
  local model, block, recipe = self:getParameterObjects()
  if block == nil then return {"helmod_result-panel.tab-button-production-line"} end
  return {"helmod_result-panel.tab-button-production-block"}
end

-------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function ProductionPanel:getButtonSprites()
  return "factory-white","factory"
end

-------------------------------------------------------------------------------
---Is visible
---@return boolean
function ProductionPanel:isVisible()
  return true
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function ProductionPanel:onStyle(styles, width_main, height_main)
  styles.block_info = {
    height = 50*2+40,
  }
end

-------------------------------------------------------------------------------
---Get or create result panel
---@return LuaGuiElement
function ProductionPanel:getResultPanel()
  local panel = self:getFramePanel("result", nil, "horizontal")
  local panel_name1 = "result1"
  local panel_name2 = "result2"
  if panel[panel_name1] ~= nil and panel[panel_name1].valid then
    return panel[panel_name1], panel[panel_name2]
  end
  local width_main, height_main = User.getMainSizes()
  panel.style.natural_width = width_main-25
  local panel1 = GuiElement.add(panel, GuiFlowH(panel_name1))
  panel1.style.horizontally_stretchable = true
  panel1.style.width = 90
  panel1.style.padding = 2
  local panel2 = GuiElement.add(panel, GuiFlowV(panel_name2))
  panel2.style.horizontally_stretchable = true
  panel2.style.vertically_stretchable = true
  panel2.style.padding = 2
  panel2.style.natural_width = width_main-25
  return panel1, panel2
end

-------------------------------------------------------------------------------
---Get or create result scroll panel
---@return LuaGuiElement
function ProductionPanel:getNavigatorPanel()
  local panel1, panel2 = self:getResultPanel()
  local panel_name = "panel-navigator"
  local scroll_name = "scroll-navigator"
  if panel1[panel_name] ~= nil and panel1[panel_name].valid then
    return panel1[panel_name][scroll_name]
  end
  local panel = GuiElement.add(panel1, GuiFrameV(panel_name):style("helmod_deep_frame"))
  panel.style.padding = 0
  local scroll_panel = GuiElement.add(panel, GuiScroll(scroll_name):style("helmod_scroll_pane"))
  panel.style.vertically_stretchable = true
  

  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.margin = 0
  return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create result scroll panel
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement
function ProductionPanel:getDataPanel()
  local panel1, panel2 = self:getResultPanel()
  local menu_name = "menu-data"
  local header_name = "header-data"
  local panel_name = "panel-data"
  local scroll_name = "scroll-data"
  if panel2[menu_name] ~= nil and panel2[menu_name].valid then
    return panel2[menu_name],panel2[header_name],panel2[panel_name][scroll_name]
  end
  local menu_panel = GuiElement.add(panel2, GuiFlowH(menu_name))
  menu_panel.style.horizontally_stretchable = true

  local header_panel = GuiElement.add(panel2, GuiFlowH(header_name))
  header_panel.style.horizontally_stretchable = true
  header_panel.style.top_padding = 6
  header_panel.style.bottom_padding = 6

  local data_panel = GuiElement.add(panel2, GuiFrameV(panel_name):style("helmod_deep_frame"))
  data_panel.style.padding = 0
  local scroll_panel = GuiElement.add(data_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"))
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return menu_panel, header_panel, scroll_panel
end

-------------------------------------------------------------------------------
---Get or create info panel
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement
function ProductionPanel:getInfoPanel2()
  local menu_panel, header_panel, scroll_panel = self:getDataPanel()
  local info_name = "info"
  local info_scroll_name = "info-scroll"
  local left_name = "left-info"
  local right_name = "right-info"
  if header_panel[info_name] ~= nil and header_panel[info_name].valid then
    return header_panel[info_name][info_scroll_name],header_panel[left_name],header_panel[right_name]
  end
  local model = self:getParameterObjects()

  header_panel.style.horizontal_spacing=10
  self:setStyle(header_panel, "block_info", "height")

  local tooltip = GuiTooltipModel("tooltip.info-model"):element(model)

  local info_panel = GuiElement.add(header_panel, GuiFlowV(info_name))
  GuiElement.add(info_panel, GuiLabel("label-info"):caption({"",self:getButtonCaption(), " [img=info]"}):style("heading_1_label"):tooltip(tooltip))
  local info_scroll = GuiElement.add(info_panel, GuiScroll(info_scroll_name):style("helmod_scroll_pane"))
  info_scroll.style.width = 300

  local left_panel = GuiElement.add(header_panel, GuiFlowV(left_name))
  self:setStyle(left_panel, "block_info", "height")

  local right_panel = GuiElement.add(header_panel, GuiFlowV(right_name))
  self:setStyle(right_panel, "block_info", "height")

  return info_scroll, left_panel, right_panel
end

-------------------------------------------------------------------------------
---Get or create left info panel
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement
function ProductionPanel:getLeftInfoPanel2()
  local _, parent_panel, _ = self:getInfoPanel2()
  local panel_name = "left-scroll"
  local header_name = "left-header"
  local label_name = "left-label"
  local tool_name = "left-tool"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[header_name][label_name], parent_panel[header_name][tool_name], parent_panel[panel_name]
  end
  local header_panel = GuiElement.add(parent_panel, GuiFlowH(header_name))
  local label_panel = GuiElement.add(header_panel, GuiLabel(label_name):caption({"helmod_common.output"}):style("helmod_label_title_frame"))
  local tool_panel = GuiElement.add(header_panel, GuiFlowH(tool_name))
  --tool_panel.style.horizontally_stretchable = true
  --tool_panel.style.horizontal_align = "right"
  local scroll_panel = GuiElement.add(parent_panel, GuiScroll(panel_name):style("helmod_scroll_pane"))
  scroll_panel.style.horizontally_stretchable = true

  return label_panel, tool_panel, scroll_panel
end

-------------------------------------------------------------------------------
---Get or create right info panel
---@return LuaGuiElement, LuaGuiElement, LuaGuiElement
function ProductionPanel:getRightInfoPanel2()
  local _,  _, parent_panel = self:getInfoPanel2()
  local panel_name = "right-scroll"
  local header_name = "right-header"
  local label_name = "right-label"
  local tool_name = "right-tool"
  if parent_panel[panel_name] ~= nil and parent_panel[panel_name].valid then
    return parent_panel[header_name][label_name], parent_panel[header_name][tool_name], parent_panel[panel_name]
  end
  local header_panel = GuiElement.add(parent_panel, GuiFlowH(header_name))
  local label_panel = GuiElement.add(header_panel, GuiLabel(label_name):caption({"helmod_common.input"}):style("helmod_label_title_frame"))
  local tool_panel = GuiElement.add(header_panel, GuiFlowH(tool_name))
  --tool_panel.style.horizontally_stretchable = true
  --tool_panel.style.horizontal_align = "right"
  local scroll_panel = GuiElement.add(parent_panel, GuiScroll(panel_name):style("helmod_scroll_pane"))
  scroll_panel.style.horizontally_stretchable = true

  return label_panel, tool_panel, scroll_panel
end

-------------------------------------------------------------------------------
---Get the menu panel
---@return LuaGuiElement, LuaGuiElement
function ProductionPanel:getSubMenuPanel()
  local menu_panel, header_panel, scroll_panel = self:getDataPanel()
  local panel_name = "menu"
  local left_name = "left_menu"
  local right_name = "right_menu"
  if menu_panel[panel_name] ~= nil and menu_panel[panel_name].valid then
    return menu_panel[panel_name][left_name], menu_panel[panel_name][right_name]
  end
  local panel = GuiElement.add(menu_panel, GuiFrameH(panel_name):style("helmod_deep_frame"))
  panel.style.horizontally_stretchable = true
  panel.style.height = 38

  local left_panel = GuiElement.add(panel, GuiFlowH(left_name))
  left_panel.style.horizontal_spacing = 10

  local right_panel = GuiElement.add(panel, GuiFlowH(right_name))
  right_panel.style.horizontal_spacing = 10
  right_panel.style.horizontally_stretchable = true
  right_panel.style.horizontal_align = "right"
  return left_panel, right_panel
end

-------------------------------------------------------------------------------
---Update
---@param event LuaEvent
function ProductionPanel:onUpdate(event)
  local model, block, _ = self:getParameterObjects()
  self:updateIndexPanel(model)

  self:updateSubMenuPanel(model, block)

  self:updateData(event)
end

-------------------------------------------------------------------------------
---Update index panel
---@param model table
function ProductionPanel:updateIndexPanel(model)
  local sorter = function(t,a,b) return t[b]["index"] > t[a]["index"] end
  local models_by_owner = Model.getModelsByOwner()
  ---index panel
  local index_panel = self:getFrameDeepPanel("model_index")
  index_panel.style.padding = 2
  index_panel.clear()
  local table_index = GuiElement.add(index_panel, GuiTable("table_index"):column(GuiElement.getIndexColumnNumber()):style("helmod_table_list"))
  GuiElement.add(table_index, GuiButton(self.classname, "new-model"):sprite("menu", defines.sprites.add_table.black, defines.sprites.add_table.black):style("helmod_button_menu_actived_green"):tooltip({"helmod_button.add-production-line"}))
  if table.size(models_by_owner) > 0 then
    local i = 0
    for _,models in pairs(models_by_owner) do
      local is_first = true
      table.reindex_list(models)
      for _,imodel in spairs(models, sorter) do
        i = i + 1
        local element = Model.firstRecipe(imodel.blocks)
        local button = nil
        if imodel.id == model.id then
          if element ~= nil and element.name ~= "" then
            local tooltip = GuiTooltipModel("tooltip.info-model"):element(imodel)
            button = GuiElement.add(table_index, GuiButtonSprite(self.classname, "change-model", imodel.id):sprite(element.type, element.name):style("helmod_button_menu_selected"):tooltip(tooltip))
            button.style.width = 36
            button.style.height = 36
            button.style.padding = {-2,-2,-2,-2}
          else
            button = GuiElement.add(table_index, GuiButton(self.classname, "change-model", imodel.id):sprite("menu", defines.sprites.status_help.white, defines.sprites.status_help.black):style("helmod_button_menu_selected"))
            button.style.width = 36
          end
        else
          if element ~= nil then
            local tooltip = GuiTooltipModel("tooltip.info-model"):element(imodel)
            button = GuiElement.add(table_index, GuiButtonSelectSprite(self.classname, "change-model", imodel.id):sprite(element.type, element.name):tooltip(tooltip):color())
          else
            button = GuiElement.add(table_index, GuiButton(self.classname, "change-model", imodel.id):sprite("menu", defines.sprites.status_help.black, defines.sprites.status_help.black):style("helmod_button_menu"))
            button.style.width = 36
          end
        end
        if button ~= nil and is_first then
          button.style.left_margin = 3
          is_first = false
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
---Update menu panel
---@param model table
---@param block table
function ProductionPanel:updateSubMenuPanel(model, block)
  self:updateSubMenuLeftPanel(model, block)
  self:updateSubMenuRightPanel(model, block)
end
-------------------------------------------------------------------------------
---Update menu panel
---@param model table
---@param block table
function ProductionPanel:updateSubMenuLeftPanel(model, block)
  if model == nil then return end
  ---action panel
  local left_panel, right_panel = self:getSubMenuPanel()
  left_panel.clear()

  local button_spacing = 2

  ---add recipe
  local group_selector = GuiElement.add(left_panel, GuiFlowH("group_selector"))
  group_selector.style.horizontal_spacing = button_spacing
  local block_id = "new"
  if block ~= nil then block_id = block.id end
  GuiElement.add(group_selector, GuiButton("HMRecipeSelector", "OPEN", model.id, block_id):sprite("menu", defines.sprites.script.black, defines.sprites.script.black):style("helmod_button_menu_actived_green"):tooltip({"helmod_result-panel.add-button-recipe"}))
  GuiElement.add(group_selector, GuiButton("HMTechnologySelector", "OPEN", model.id, block_id):sprite("menu", defines.sprites.education.black, defines.sprites.education.black):style("helmod_button_menu_actived_green"):tooltip({"helmod_result-panel.add-button-technology"}))

  ---delete button
  local group_delete = GuiElement.add(left_panel, GuiFlowH("group_delete"))
  local delete_action = "remove-block"
  if block == nil then delete_action = "remove-model" end
  local delete_button = GuiElement.add(group_delete, GuiButton(self.classname, delete_action, model.id, block_id):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_actived_red"):tooltip({"helmod_result-panel.remove-button-production-block"}))
  if not(User.isDeleter(model)) then
      delete_button.enabled = false
  end

  ---Model Debug
  if User.getModGlobalSetting("debug_solver") == true then
    local group_debug = GuiElement.add(left_panel, GuiFlowH("group_debug"))
    group_debug.style.horizontal_spacing = button_spacing
    GuiElement.add(group_debug, GuiButton("HMModelDebug", "OPEN", model.id, block_id):sprite("menu", defines.sprites.run_test.black, defines.sprites.run_test.black):style("helmod_button_menu"):tooltip("Open Debug"))
    local solver_selected = User.getParameter("solver_selected") or "normal"
    GuiElement.add(group_debug, GuiButton(self.classname, "solver_switch"):style("helmod_button_default"):caption(solver_selected))
  end

  ---group tool
  local group_tool = GuiElement.add(left_panel, GuiFlowH("group_tool"))
  group_tool.style.horizontal_spacing = button_spacing
  GuiElement.add(group_tool, GuiButton("HMSummaryPanel", "OPEN", model.id, block_id):sprite("menu", defines.sprites.list_view.black,defines.sprites.list_view.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.tab-button-summary"}))
  GuiElement.add(group_tool, GuiButton("HMPinPanel", "OPEN", model.id, block_id):sprite("menu", defines.sprites.push_pin.black, defines.sprites.push_pin.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.tab-button-pin"}))
  if block ~= nil then
    ---unlinked button
    local linked_button
    local unlinked = block.unlinked and true or false
    if unlinked or block.index == 0 then
      linked_button = GuiElement.add(group_tool, GuiButton(self.classname, "production-block-unlink", model.id, block.id):sprite("menu", defines.sprites.unplugged.black, defines.sprites.unplugged.black):style("helmod_button_menu"):tooltip({"tooltip.unlink-element"}))
    else
      linked_button = GuiElement.add(group_tool, GuiButton(self.classname, "production-block-unlink", model.id, block.id):sprite("menu", defines.sprites.plugged.white, defines.sprites.plugged.black):style("helmod_button_menu_selected"):tooltip({"tooltip.unlink-element"}))
    end
    if block.index == 0 then
      linked_button.enabled = false
      linked_button.tooltip = {"tooltip.block-cannot-link-first"}
    end
    if block.by_factory == true then
      linked_button.enabled = false
      linked_button.tooltip = {"tooltip.block-cannot-link-by-factory"}
    end

    
    ---by limit
    if block.by_limit == true then
      GuiElement.add(group_tool, GuiButton(self.classname, "block-limit", model.id, block_id):sprite("menu", defines.sprites.gauge_round.white, defines.sprites.gauge_round.black):style("helmod_button_menu_selected"):tooltip({"helmod_label.assembler-limitation"}))
    else
      GuiElement.add(group_tool, GuiButton(self.classname, "block-limit", model.id, block_id):sprite("menu", defines.sprites.gauge_round.black, defines.sprites.gauge_round.black):style("helmod_button_menu"):tooltip({"helmod_label.assembler-limitation"}))
    end

    ---by product
    if block.by_product == false then
      GuiElement.add(group_tool, GuiButton(self.classname, "block-by-product", model.id, block_id):sprite("menu", defines.sprites.graph_bottom_to_top.white, defines.sprites.graph_bottom_to_top.black):style("helmod_button_menu_selected"):tooltip({"helmod_label.input-product"}))
    else
      GuiElement.add(group_tool, GuiButton(self.classname, "block-by-product", model.id, block_id):sprite("menu", defines.sprites.graph_top_to_bottom.black, defines.sprites.graph_top_to_bottom.black):style("helmod_button_menu"):tooltip({"helmod_label.input-ingredient"}))
    end


    ---computing
    local block_compunting = GuiElement.add(group_tool, GuiFlowH("block-computing"))
    block_compunting.style.horizontal_spacing=10
    local default_compunting = ""
    local items = {}
    table.insert(items,{"helmod_label.compute-by-element"})
    table.insert(items,{"helmod_label.compute-by-factory"})
    table.insert(items,{"helmod_label.matrix-solver"})
    if block.solver == true then
      default_compunting = items[3]
    elseif block.by_factory == true then
      default_compunting = items[2]
    else
      default_compunting = items[1]
    end

    local selector = GuiElement.add(block_compunting, GuiDropDown(self.classname, "change-computing", model.id, block.id):items(items, default_compunting))
    selector.style.font = "helmod_font_default"
    selector.style.height = 32
  end

end

-------------------------------------------------------------------------------
---Update menu panel
---@param model table
---@param block table
function ProductionPanel:updateSubMenuRightPanel(model, block)
  if model == nil then return end
  ---action panel
  local left_panel, right_panel = self:getSubMenuPanel()
  right_panel.clear()

  local button_spacing = 2
  local block_id = "new"
  if block ~= nil then block_id = block.id end

  ---logistics
  local display_logistic_row = User.getParameter("display_logistic_row")
  if display_logistic_row == true then
    local logistic_row_item = User.getParameter("logistic_row_item") or "belt"
    local logistic2 = GuiElement.add(right_panel, GuiFlowH("logistic2"))
    logistic2.style.horizontal_spacing = button_spacing
    for _,type in pairs({"inserter", "belt", "container", "transport"}) do
      local item_logistic = Player.getDefaultItemLogistic(type)
      local style = "helmod_button_menu"
      if logistic_row_item == type then style = "helmod_button_menu_selected" end
      local button = GuiElement.add(logistic2, GuiButton(self.classname, "change-logistic-item", type):sprite("sprite", item_logistic):style(style):tooltip({"tooltip.logistic-row-choose"}))
      button.style.padding = {0,0,0,0}
    end

    local logistic_row_fluid = User.getParameter("logistic_row_fluid") or "pipe"
    local logistic3 = GuiElement.add(right_panel, GuiFlowH("logistic3"))
    logistic3.style.horizontal_spacing = button_spacing
    for _,type in pairs({"pipe", "container", "transport"}) do
      local fluid_logistic = Player.getDefaultFluidLogistic(type)
      local style = "helmod_button_menu"
      if logistic_row_fluid == type then style = "helmod_button_menu_selected" end
      local button = GuiElement.add(logistic3, GuiButton(self.classname, "change-logistic-fluid", type):sprite("sprite", fluid_logistic):style(style):tooltip({"tooltip.logistic-row-choose"}))
      button.style.padding = {0,0,0,0}
    end
  end

  local group_pref = GuiElement.add(right_panel, GuiFlowH("group_pref"))
  group_pref.style.horizontal_spacing = button_spacing
  if display_logistic_row == true then
    GuiElement.add(group_pref, GuiButton(self.classname, "change-logistic"):sprite("menu", defines.sprites.transport.white, defines.sprites.transport.black):style("helmod_button_menu_selected"):tooltip({"tooltip.display-logistic-row"}))
  else
    GuiElement.add(group_pref, GuiButton(self.classname, "change-logistic"):sprite("menu", defines.sprites.transport.black, defines.sprites.transport.black):style("helmod_button_menu"):tooltip({"tooltip.display-logistic-row"}))
  end
  GuiElement.add(group_pref, GuiButton("HMPreferenceEdition", "OPEN", model.id, block_id):sprite("menu", defines.sprites.process.black, defines.sprites.process.black):style("helmod_button_menu"):tooltip({"helmod_button.preferences"}))

  local group_models = GuiElement.add(right_panel, GuiFlowH("group_models"))
  group_models.style.horizontal_spacing = button_spacing
  GuiElement.add(group_models, GuiButton("HMModelEdition", "OPEN", model.id, block_id):sprite("menu", defines.sprites.edit_document.black, defines.sprites.edit_document.black):style("helmod_button_menu"):tooltip({"helmod_panel.model-edition"}))
  local button_model_up = GuiElement.add(group_models, GuiButton(self.classname, "model-index-up", model.id, block_id):sprite("menu", defines.sprites.arrow_left.black, defines.sprites.arrow_left.black):style("helmod_button_menu"):tooltip({"helmod_panel.model-index-up"}))
  button_model_up.enabled = model.owner == Player.native().name
  local button_model_down = GuiElement.add(group_models, GuiButton(self.classname, "model-index-down", model.id, block_id):sprite("menu", defines.sprites.arrow_right.black, defines.sprites.arrow_right.black):style("helmod_button_menu"):tooltip({"helmod_panel.model-index-down"}))
  button_model_down.enabled = model.owner == Player.native().name

  local group_action = GuiElement.add(right_panel, GuiFlowH("group_action"))
  group_action.style.horizontal_spacing = button_spacing
  ---copy past
  GuiElement.add(group_action, GuiButton(self.classname, "copy-model", model.id, block_id):sprite("menu", defines.sprites.copy.black, defines.sprites.copy.black):style("helmod_button_menu"):tooltip({"helmod_button.copy"}))
  GuiElement.add(group_action, GuiButton(self.classname, "past-model", model.id, block_id):sprite("menu", defines.sprites.paste.black, defines.sprites.paste.black):style("helmod_button_menu"):tooltip({"helmod_button.past"}))
  ---download
  if self.classname == "HMProductionPanel" then
    GuiElement.add(group_action, GuiButton("HMDownload", "OPEN", model.id, "download"):sprite("menu", defines.sprites.download_document.black, defines.sprites.download_document.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.download-button-production-line"}))
    GuiElement.add(group_action, GuiButton("HMDownload", "OPEN", model.id, "upload"):sprite("menu", defines.sprites.upload_document.black, defines.sprites.upload_document.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.upload-button-production-line"}))
  end
  ---refresh control
  GuiElement.add(group_action, GuiButton(self.classname, "refresh-model", model.id):sprite("menu", defines.sprites.refresh.black, defines.sprites.refresh.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.refresh-button"}))

  local items = {}
  local default_time = 1
  for index,base_time in pairs(defines.constant.base_times) do
    table.insert(items,base_time.tooltip)
    if model.time == base_time.value then
      default_time = base_time.tooltip
    end
  end

  local group_time = GuiElement.add(right_panel, GuiFlowH("group_time"))
  GuiElement.add(group_time, GuiLabel("label_time"):caption({"helmod_data-panel.base-time", ""}):style("helmod_label_title_frame"))

  GuiElement.add(group_time, GuiDropDown(self.classname, "change-time", model.id):items(items, default_time))
end

-------------------------------------------------------------------------------
---Update info
---@param model table
---@param block table
function ProductionPanel:updateInfoBlock(model, block)
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  info_scroll.clear()
  ---info panel

  ---production block result
  if block ~= nil and table.size(block.recipes) > 0 then

    ---block informations
    local block_table = GuiElement.add(info_scroll, GuiTable("output-table"):column(5))
    block_table.style.horizontally_stretchable = false
    block_table.vertical_centering = false
    block_table.style.horizontal_spacing=10

    GuiElement.add(block_table, GuiCellBlockInfo("block-count"):element(block):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(1):byLimit(block.by_limit))
    GuiElement.add(block_table, GuiCellEnergy("block-power"):element(block):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(2):byLimit(block.by_limit))
    if User.getPreferenceSetting("display_pollution") then
      GuiElement.add(block_table, GuiCellPollution("block-pollution"):element(block):tooltip("tooltip.info-block"):color(GuiElement.color_button_default):index(3):byLimit(block.by_limit))
    end
    if User.getPreferenceSetting("display_building") then
      GuiElement.add(block_table, GuiCellBuilding("block-building"):element(block):tooltip("tooltip.info-building"):color(GuiElement.color_button_default):index(4):byLimit(block.by_limit))
    end
  end
end

-------------------------------------------------------------------------------
---Update header
---@param model table
---@param block table
function ProductionPanel:updateInputBlock(model, block)
  ---data
  local block_by_product = not(block ~= nil and block.by_product == false)

  local left_label, left_tool, left_scroll = self:getLeftInfoPanel2()
  local right_label, right_tool, right_scroll = self:getRightInfoPanel2()

  local input_label = right_label
  local input_tool = right_tool
  local input_scroll = right_scroll
  if not(block_by_product) then
    input_label = left_label
    input_scroll = left_scroll
    input_tool = left_tool
  end

  input_tool.clear()
  local all_visible = User.getParameter("block_all_ingredient_visible")
  if all_visible == true then
    GuiElement.add(input_tool, GuiButton(self.classname, "block-all-ingredient-visible", model.id, block.id):sprite("menu", defines.sprites.filter.white, defines.sprites.filter.black):style("helmod_button_menu_sm_selected"):tooltip({"helmod_button.all-product-visible"}))
  else
    GuiElement.add(input_tool, GuiButton(self.classname, "block-all-ingredient-visible", model.id, block.id):sprite("menu", defines.sprites.filter.black, defines.sprites.filter.black):style("helmod_button_menu_sm"):tooltip({"helmod_button.all-product-visible"}))
  end

  ---input panel
  input_label.caption = {"helmod_common.input"}
  input_scroll.clear()

  ---production block result
  if block ~= nil and table.size(block.recipes) > 0 then

    ---input panel
    local input_table = GuiElement.add(input_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)-2):style("helmod_table_element"))
    if block.ingredients ~= nil then
      for index, lua_ingredient in spairs(block.ingredients, User.getProductSorter()) do
        if all_visible == true or ((lua_ingredient.state or 0) == 1 and not(block_by_product)) or (lua_ingredient.count or 0) > ModelCompute.waste_value then
          local contraint_type = nil
          local ingredient = Product(lua_ingredient):clone()
          ingredient.time = model.time
          ingredient.count = lua_ingredient.count
          if block.count > 1 then
            ingredient.limit_count = lua_ingredient.count / block.count
          end
          local button_action = "production-recipe-ingredient-add"
          local button_tooltip = "tooltip.ingredient"
          local button_color = GuiElement.color_button_default_ingredient
          local control_info = "link-intermediate"
          if block_by_product then
            button_action = "production-recipe-ingredient-add"
            button_tooltip = "tooltip.add-recipe"
            control_info = nil
          else
            if not(block.unlinked) or block.by_factory == true then
              button_action = "product-info"
              button_tooltip = "tooltip.info-product"
              if block.products_linked ~= nil and block.products_linked[Product(lua_ingredient):getTableKey()] then
                contraint_type = "linked"
              end
            else
              button_action = "product-edition"
              button_tooltip = "tooltip.edit-product"
            end
          end
          ---color
          if lua_ingredient.state == 1 then
            if not(block.unlinked) or block.by_factory == true then
              button_color = GuiElement.color_button_default_ingredient
            else
              button_color = GuiElement.color_button_edit
            end
          elseif lua_ingredient.state == 3 then
            button_color = GuiElement.color_button_rest
          else
            button_color = GuiElement.color_button_default_ingredient
          end
          GuiElement.add(input_table, GuiCellElementM(self.classname, button_action, model.id, block.id, "none"):element(ingredient):tooltip(button_tooltip):index(index):color(button_color):byLimit(block.by_limit):contraintIcon(contraint_type):controlInfo(control_info))
        end
      end
    end

  end
end

-------------------------------------------------------------------------------
---Update header
---@param model table
---@param block table
function ProductionPanel:updateOutputBlock(model, block)
  ---data
  local block_by_product = not(block ~= nil and block.by_product == false)

  local left_label, left_tool, left_scroll = self:getLeftInfoPanel2()
  local right_label, right_tool, right_scroll = self:getRightInfoPanel2()

  local output_label = left_label
  local output_tool = left_tool
  local output_scroll = left_scroll
  if not(block_by_product) then
    output_label = right_label
    output_scroll = right_scroll
    output_tool = right_tool
  end

  output_tool.clear()
  local all_visible = User.getParameter("block_all_product_visible")
  if all_visible == true then
    GuiElement.add(output_tool, GuiButton(self.classname, "block-all-product-visible", model.id, block.id):sprite("menu", defines.sprites.filter.white, defines.sprites.filter.black):style("helmod_button_menu_sm_selected"):tooltip({"helmod_button.all-product-visible"}))
  else
    GuiElement.add(output_tool, GuiButton(self.classname, "block-all-product-visible", model.id, block.id):sprite("menu", defines.sprites.filter.black, defines.sprites.filter.black):style("helmod_button_menu_sm"):tooltip({"helmod_button.all-product-visible"}))
  end

  ---ouput panel
  output_label.caption = {"helmod_common.output"}
  output_scroll.clear()

  ---production block result
  if block ~= nil and table.size(block.recipes) > 0 then

    ---ouput panel
    local output_table = GuiElement.add(output_scroll, GuiTable("output-table"):column(GuiElement.getElementColumnNumber(50)-2):style("helmod_table_element"))
    if block.products ~= nil then
      for index, lua_product in spairs(block.products, User.getProductSorter()) do
        if all_visible == true or ((lua_product.state or 0) == 1 and block_by_product) or (lua_product.count or 0) > ModelCompute.waste_value then
          local contraint_type = nil
          local product = Product(lua_product):clone()
          product.time = model.time
          product.count = lua_product.count
          if block.count > 1 then
            product.limit_count = lua_product.count / block.count
          end
          local button_action = "production-recipe-product-add"
          local button_tooltip = "tooltip.product"
          local button_color = GuiElement.color_button_default_product
          local control_info = "link-intermediate"
          if not block_by_product then
            button_action = "production-recipe-product-add"
            button_tooltip = "tooltip.add-recipe"
            control_info = nil
          elseif not(block.unlinked) or block.by_factory == true then
            button_action = "product-info"
            button_tooltip = "tooltip.info-product"
            if block.products_linked ~= nil and block.products_linked[Product(lua_product):getTableKey()] then
              contraint_type = "linked"
            end
          else
            button_action = "product-edition"
            button_tooltip = "tooltip.edit-product"
          end
          ---color
          if lua_product.state == 1 then
            if not(block.unlinked) or block.by_factory == true then
              button_color = GuiElement.color_button_default_product
            else
              button_color = GuiElement.color_button_edit
            end
          elseif lua_product.state == 3 then
            button_color = GuiElement.color_button_rest
          else
            button_color = GuiElement.color_button_default_product
          end
          GuiElement.add(output_table, GuiCellElementM(self.classname, button_action, model.id, block.id, "none"):element(product):tooltip(button_tooltip):index(index):color(button_color):byLimit(block.by_limit):contraintIcon(contraint_type):controlInfo(control_info))
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
---Update header
---@param model table
function ProductionPanel:updateInfoModel(model)
  ---data
  local info_scroll, output_scroll, input_scroll = self:getInfoPanel2()
  info_scroll.clear()
  ---info panel

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
end

-------------------------------------------------------------------------------
---Update header
---@param model table
function ProductionPanel:updateInputModel(model)
  ---data
  local right_label, right_tool, right_scroll = self:getRightInfoPanel2()
  right_scroll.clear()
  ---input panel

  local count_block = table.size(model.blocks)
  if count_block > 0 then

    local input_table = GuiElement.add(right_scroll, GuiTable("input-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    if model.ingredients ~= nil then
      for index, element in spairs(model.ingredients, User.getProductSorter()) do
        element.time = model.time
        GuiElement.add(input_table, GuiCellElementM(self.classname, "production-recipe-ingredient-add", model.id, "new", element.name):element(element):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index))
      end
    end

  end
end

-------------------------------------------------------------------------------
---Update header
---@param model table
function ProductionPanel:updateOutputModel(model)
  ---data
  local left_label, left_tool, left_scroll = self:getLeftInfoPanel2()
  left_scroll.clear()
  ---ouput panel

  ---production block result
  local count_block = table.size(model.blocks)
  if count_block > 0 then

    ---ouput panel
    local output_table = GuiElement.add(left_scroll, GuiTable("output-table"):column(GuiElement.getElementColumnNumber(50)):style("helmod_table_element"))
    if model.products ~= nil then
      for index, element in spairs(model.products, User.getProductSorter()) do
        element.time = model.time
        GuiElement.add(output_table, GuiCellElementM(self.classname, "production-recipe-product-add", model.id, "new", element.name):element(element):tooltip("tooltip.add-recipe"):index(index))
      end
    end

  end
end
-------------------------------------------------------------------------------
---Update data
---@param event LuaEvent
function ProductionPanel:updateData(event)
  local model, block, recipe = self:getParameterObjects()

  self:bluidNavigator(model, block)

  local last_element = nil
  ---col recipe
  if block == nil then
    self:updateDataModel(model)
  else
    self:updateDataBlock(model, block)
  end

  --self:updateTips("test tips, non mé ho!!!")
end

-------------------------------------------------------------------------------
---Update data
---@param model table
---@param block table
function ProductionPanel:updateDataBlock(model, block)
  if block == nil then return end
  
  self:updateInfoBlock(model, block)

  self:updateOutputBlock(model, block)

  self:updateInputBlock(model, block)

  ---data panel
  local menu_panel, header_panel, scroll_panel = self:getDataPanel()
  ---production block result
  if block ~= nil and table.size(block.recipes) > 0 then
    ---data panel
    local extra_cols = 0
    if User.getPreferenceSetting("display_pollution") then
      extra_cols = extra_cols + 1
    end
    if User.getModGlobalSetting("display_hidden_column") == "All" then
      extra_cols = extra_cols + 2
    end
    if User.getModGlobalSetting("display_hidden_column") ~= "None" then
      extra_cols = extra_cols + 2
    end

    local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(7 + extra_cols):style("helmod_table_result"))
    result_table.vertical_centering = false
    self:addTableHeader(result_table, block)

    local sorter = function(t,a,b) return t[b]["index"] > t[a]["index"] end
    if block.by_product == false then sorter = function(t,a,b) return t[b]["index"] < t[a]["index"] end end
    local last_element = nil
    for _, recipe in spairs(block.recipes, sorter) do
      local recipe_cell = self:addTableRowRecipe(result_table, model, block, recipe)
      if User.getParameter("scroll_element") == recipe.id then last_element = recipe_cell end
    end

    if last_element ~= nil then
      scroll_panel.scroll_to_element(last_element)
      User.setParameter("scroll_element", nil)
    end

  end
end
-------------------------------------------------------------------------------
---Update data
---@param model table
function ProductionPanel:updateDataModel(model)
  if model == nil then return end
  
  self:updateInfoModel(model)

  self:updateOutputModel(model)

  self:updateInputModel(model)

  ---data panel
  local menu_panel, header_panel, scroll_panel = self:getDataPanel()
  ---production block result
  if table.size(model.blocks) > 0 then
    ---data panel
    local extra_cols = 0
    if User.getPreferenceSetting("display_pollution") then
      extra_cols = extra_cols + 1
    end
    if User.getModGlobalSetting("display_hidden_column") == "All" then
      extra_cols = extra_cols + 2
    end
    if User.getModGlobalSetting("display_hidden_column") ~= "None" then
      extra_cols = extra_cols + 2
    end
    if User.getPreferenceSetting("display_building") then
      extra_cols = extra_cols + 1
    end

    local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(5 + extra_cols):style("helmod_table_result"))
    result_table.vertical_centering = false
    self:addTableHeader(result_table)

    local sorter = function(t,a,b) return t[b]["index"] > t[a]["index"] end
    local last_element = nil
    for _, block in spairs(model.blocks, sorter) do
      local block_cell = self:addTableRowBlock(result_table, model, block)
    end

  end

  --self:updateTips("test tips, non mé ho!!!")
end
-------------------------------------------------------------------------------
---Build Navigator
---@param model table
---@param current_block table
function ProductionPanel:bluidNavigator(model, current_block)
  local scroll_panel = self:getNavigatorPanel()
  local last_element = nil

  ---bluid tree
  if model.blocks ~= nil then
    self:bluidRootLeaf(scroll_panel, model, current_block, 0)
    self:bluidTree(scroll_panel, model, model.blocks, current_block, 1)
    if last_element ~= nil then
      scroll_panel.scroll_to_element(last_element)
    end
  end
end

-------------------------------------------------------------------------------
---Build Tree
---@param tree_panel LuaGuiElement
---@param model table
---@param blocks table
---@param current_block table
---@param level number
function ProductionPanel:bluidTree(tree_panel, model, blocks, current_block, level)
  if blocks ~= nil then
    for _, block in spairs(blocks, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
      self:bluidLeaf(tree_panel, model, block, current_block, level)
    end
  end
end

-------------------------------------------------------------------------------
---Build Tree
---@param tree_panel LuaGuiElement
---@param model table
---@param block table
---@param current_block table
---@param level number
function ProductionPanel:bluidLeaf(tree_panel, model, block, current_block, level)
  if block ~= nil then
      local color = "gray"
      local cell_tree = GuiElement.add(tree_panel, GuiTable("block", block.id):column(1):style("helmod_table_list"))
      if current_block ~= nil and current_block.id == block.id then
        --last_element = cell_tree
        color = "orange"
      end
      if block.name == nil then
        local cell_block = GuiElement.add(cell_tree, GuiButton(self.classname, "HMProductionPanel", model.id, block.id):sprite("menu", defines.sprites.hangar.black, defines.sprites.hangar.black):style("helmod_button_menu"):tooltip("tooltip.edit-block"))
      else
        local cell_block = GuiElement.add(cell_tree, GuiCellBlock(self.classname, "change-block", model.id, block.id):element(block):tooltip("tooltip.edit-block"):color(color))
        cell_block.style.left_padding = 10 * level
      end
  end
end

-------------------------------------------------------------------------------
---Build Tree
---@param tree_panel LuaGuiElement
---@param model table
---@param current_block table
---@param level number
function ProductionPanel:bluidRootLeaf(tree_panel, model, current_block, level)
  if model ~= nil then
      local color = "gray"
      local cell_tree = GuiElement.add(tree_panel, GuiTable("model", model.id):column(1):style("helmod_table_list"))
      if current_block == nil then
        --last_element = cell_tree
        color = "orange"
      end
      local cell_block = GuiElement.add(cell_tree, GuiCellModel(self.classname, "change-block", model.id):element(model):tooltip("tooltip.info-model"):color(color))
      cell_block.style.left_padding = 10 * level
  end
end

-------------------------------------------------------------------------------
---Add table header
---@param itable LuaGuiElement
---@param block table
function ProductionPanel:addTableHeader(itable, block)
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  ---optionnal columns
  if User.getModGlobalSetting("display_hidden_column") == "All" then
    self:addCellHeader(itable, "index", {"helmod_result-panel.col-header-index"},"index")
    self:addCellHeader(itable, "id", {"helmod_result-panel.col-header-id"},"id")
  end
  if User.getModGlobalSetting("display_hidden_column") ~= "None" then
    self:addCellHeader(itable, "name", {"helmod_result-panel.col-header-name"},"name")
    self:addCellHeader(itable, "type", {"helmod_result-panel.col-header-type"},"type")
  end
  ---data columns
  self:addCellHeader(itable, "recipe", {"helmod_result-panel.col-header-recipe"},"index")
  self:addCellHeader(itable, "energy", {"helmod_common.energy-consumption"},"energy_total")
  if User.getPreferenceSetting("display_pollution") then
    self:addCellHeader(itable, "pollution", {"helmod_common.pollution"})
  end
  ---col building
  if User.getPreferenceSetting("display_building") or block ~= nil then
    self:addCellHeader(itable, "factory", {"helmod_result-panel.col-header-factory"})
  end
  if block ~= nil then
    self:addCellHeader(itable, "beacon", {"helmod_result-panel.col-header-beacon"})
  end
  if block ~= nil then
    for _,order in pairs(Model.getBlockOrder(block)) do
      if order == "products" then
        self:addCellHeader(itable, "products", {"helmod_result-panel.col-header-products"})
      else
        self:addCellHeader(itable, "ingredients", {"helmod_result-panel.col-header-ingredients"})
      end
    end
  else
    self:addCellHeader(itable, "products", {"helmod_result-panel.col-header-products"})
    self:addCellHeader(itable, "ingredients", {"helmod_result-panel.col-header-ingredients"})
  end
end

-------------------------------------------------------------------------------
---Add table row
---@param gui_table LuaGuiElement
---@param element table
function ProductionPanel:addTableRowCommon(gui_table, element)
  if User.getModGlobalSetting("display_hidden_column") == "All" then
    ---col index
    GuiElement.add(gui_table, GuiLabel("value_index", element.id):caption(element.index))
    ---col id
    GuiElement.add(gui_table, GuiLabel("value_id", element.id):caption(element.id))
  end
  if User.getModGlobalSetting("display_hidden_column") ~= "None" then
    ---col name
    GuiElement.add(gui_table, GuiLabel("value_name", element.id):caption(element.name))
    ---col type
    GuiElement.add(gui_table, GuiLabel("value_type", element.id):caption(element.type))
  end
end
-------------------------------------------------------------------------------
---Add table row
---@param gui_table LuaGuiElement
---@param model table
---@param block table
---@param recipe table
---@return LuaGuiElement
function ProductionPanel:addTableRowRecipe(gui_table, model, block, recipe)
  local recipe_prototype = RecipePrototype(recipe)
  --local lua_recipe = RecipePrototype(recipe):native()

  ---col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", recipe.id):column(2):style("helmod_table_list"))
  if block.by_product == false then
    ---by ingredient
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-down", model.id, block.id, recipe.id):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-remove", model.id, block.id, recipe.id):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-up", model.id, block.id, recipe.id):sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  else
    ---by product
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-up", model.id, block.id, recipe.id):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-remove", model.id, block.id, recipe.id):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
    GuiElement.add(cell_action, GuiButton(self.classname, "production-recipe-down", model.id, block.id, recipe.id):sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  end
  ---conversion block
  if recipe.index > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "conversion-recipe-block", model.id, block.id, recipe.id):sprite("menu", defines.sprites.hangar.black, defines.sprites.hangar.black):style("helmod_button_menu_sm"):tooltip({"tooltip.conversion-recipe-block"}))
  end

  ---common cols
  self:addTableRowCommon(gui_table, recipe)
  ---col recipe
  --- local production = recipe.production or 1
  --- local production_label = Format.formatPercent(production).."%"
  --- if block.solver == true then production_label = "" end
  local cell_recipe = GuiElement.add(gui_table, GuiTable("recipe", recipe.id):column(2):style("helmod_table_list"))
  GuiElement.add(cell_recipe, GuiCellRecipe("HMRecipeEdition", "OPEN", model.id, block.id, recipe.id):element(recipe):infoIcon(recipe.type):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):broken(recipe_prototype:native() == nil):byLimit(block.by_limit))
  if recipe_prototype:native() == nil then
    Player.print("ERROR: Recipe ".. recipe.name .." not exist in game")
  end
  ---col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable("energy", recipe.id):column(2):style("helmod_table_list"))
  GuiElement.add(cell_energy, GuiCellEnergy("HMRecipeEdition", "OPEN", model.id, block.id, recipe.id):element(recipe):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):byLimit(block.by_limit))

  ---col pollution
  if User.getPreferenceSetting("display_pollution") then
    local cell_pollution = GuiElement.add(gui_table, GuiTable("pollution", recipe.id):column(2):style("helmod_table_list"))
    GuiElement.add(cell_pollution, GuiCellPollution("HMRecipeEdition", "OPEN", model.id, block.id, recipe.id):element(recipe):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):byLimit(block.by_limit))
  end
  
  ---col factory
  local factory = recipe.factory
  local cell_factory = GuiElement.add(gui_table, GuiTable("factory", recipe.id):column(2):style("helmod_table_list"))
  local gui_cell_factory = GuiCellFactory(self.classname, "factory-action", model.id, block.id, recipe.id):element(factory):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):byLimit(block.by_limit):controlInfo("crafting-add")
  if block.by_limit == true then
    gui_cell_factory:byLimitUri(self.classname, "update-factory-limit", model.id, block.id, recipe.id)
  end
  if block.by_factory == true then
    gui_cell_factory:byFactory(self.classname, "update-factory-number", model.id, block.id, recipe.id)
  end
  GuiElement.add(cell_factory, gui_cell_factory)

  ---col beacon
  local beacon = recipe.beacon
  local cell_beacon = GuiElement.add(gui_table, GuiTable("beacon", recipe.id):column(2):style("helmod_table_list"))
  local gui_cell_beacon = GuiCellFactory(self.classname, "beacon-action", model.id, block.id, recipe.id):element(beacon):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):byLimit(block.by_limit):controlInfo("crafting-add")
  GuiElement.add(cell_beacon, gui_cell_beacon)

  for _,order in pairs(Model.getBlockOrder(block)) do
    if order == "products" then
      ---products
      local display_product_cols = User.getPreferenceSetting("display_product_cols")
      local cell_products = GuiElement.add(gui_table, GuiTable("products", recipe.id):column(display_product_cols):style("helmod_table_list"))
      for index, lua_product in spairs(recipe_prototype:getProducts(recipe.factory), User.getProductSorter()) do
        local contraint_type = nil
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.time = model.time
        product.count = product_prototype:countProduct(model, recipe)
        if block.count > 1 then
          product.limit_count = product.count / block.count
        end
        if block.by_product ~= false and recipe.contraint ~= nil and recipe.contraint.name == product.name then
          contraint_type = recipe.contraint.type
        end
        local control_info = "contraint"
        if not(block.solver ~= true and block.by_product ~= false) then
          control_info = nil
        end
        GuiElement.add(cell_products, GuiCellElement(self.classname, "production-recipe-product-add", model.id, block.id, recipe.id):element(product):tooltip("tooltip.add-recipe"):index(index):byLimit(block.by_limit):contraintIcon(contraint_type):controlInfo(control_info))
      end
    else
      ---ingredients
      local display_ingredient_cols = User.getPreferenceSetting("display_ingredient_cols")
      local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients_", recipe.id):column(display_ingredient_cols):style("helmod_table_list"))
      for index, lua_ingredient in spairs(recipe_prototype:getIngredients(recipe.factory), User.getProductSorter()) do
        local contraint_type = nil
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.time = model.time
        ingredient.count = ingredient_prototype:countIngredient(model, recipe)
        ---si constant compte comme un produit (recipe rocket)
        if ingredient.constant == true then
          ingredient.count = ingredient_prototype:countProduct(model, recipe)
        end
        if block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        if block.by_product == false and recipe.contraint ~= nil and recipe.contraint.name == ingredient.name then
          contraint_type = recipe.contraint.type
        end
        local control_info = "contraint"
        if not(block.solver ~= true and block.by_product == false) then
          control_info = nil
        end
        GuiElement.add(cell_ingredients, GuiCellElement(self.classname, "production-recipe-ingredient-add", model.id, block.id, recipe.id):element(ingredient):tooltip("tooltip.add-recipe"):color(GuiElement.color_button_add):index(index):byLimit(block.by_limit):contraintIcon(contraint_type):controlInfo(control_info))
      end
    end
  end

  return cell_recipe
end

-------------------------------------------------------------------------------
---Add row data tab
---@param gui_table LuaGuiElement
---@param model table
---@param block table
---@return LuaGuiElement
function ProductionPanel:addTableRowBlock(gui_table, model, block)
  local unlinked = block.unlinked and true or false
  if block.index == 0 then unlinked = true end
  local block_by_product = not(block ~= nil and block.by_product == false)
  ---col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", block.id):column(2))

  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-up", model.id, block.id):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"):tooltip({"tooltip.up-element", User.getModSetting("row_move_step")}))
  GuiElement.add(cell_action, GuiButton(self.classname, "remove-block", model.id, block.id):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
  GuiElement.add(cell_action, GuiButton(self.classname, "production-block-down", model.id, block.id):sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black):style("helmod_button_menu_sm"):tooltip({"tooltip.down-element", User.getModSetting("row_move_step")}))
  local linked_button
  if unlinked then
    linked_button = GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink", model.id, block.id):sprite("menu", defines.sprites.unplugged.black, defines.sprites.unplugged.black):style("helmod_button_menu_sm"):tooltip({"tooltip.unlink-element"}))
  else
    linked_button = GuiElement.add(cell_action, GuiButton(self.classname, "production-block-unlink", model.id, block.id):sprite("menu", defines.sprites.plugged.white, defines.sprites.plugged.black):style("helmod_button_menu_sm_selected"):tooltip({"tooltip.unlink-element"}))
  end
  if block.index == 0 then
    linked_button.enabled = false
    linked_button.tooltip = {"tooltip.block-cannot-link-first"}
  end
  if block.by_factory == true then
    linked_button.enabled = false
    linked_button.tooltip = {"tooltip.block-cannot-link-by-factory"}
  end

  ---common cols
  self:addTableRowCommon(gui_table, block)

  ---col recipe
  local cell_recipe = GuiElement.add(gui_table, GuiTable("recipe", block.id):column(1):style("helmod_table_list"))

  local block_color = "gray"
  if not(block_by_product) then block_color = "orange" end
  GuiElement.add(cell_recipe, GuiCellBlock(self.classname, "change-block", model.id, block.id):element(block):infoIcon(block.type):tooltip("tooltip.edit-block"):color(block_color))

  ---col energy
  local cell_energy = GuiElement.add(gui_table, GuiTable(block.id, "energy"):column(1):style("helmod_table_list"))
  local element_block = {name=block.name, power=block.power, pollution_total=block.pollution_total, summary=block.summary}
  GuiElement.add(cell_energy, GuiCellEnergy(self.classname, "change-block", model.id, block.id):element(element_block):tooltip("tooltip.edit-block"):color(block_color))

  ---col pollution
  if User.getPreferenceSetting("display_pollution") then
    local cell_pollution = GuiElement.add(gui_table, GuiTable(block.id, "pollution"):column(1):style("helmod_table_list"))
    GuiElement.add(cell_pollution, GuiCellPollution(self.classname, "change-block", model.id, block.id):element(element_block):tooltip("tooltip.edit-block"):color(block_color))
  end
  
  ---col building
  if User.getPreferenceSetting("display_building") then
    local cell_building = GuiElement.add(gui_table, GuiTable(block.id, "building"):column(1):style("helmod_table_list"))
    GuiElement.add(cell_building, GuiCellBuilding(self.classname, "change-block", model.id, block.id):element(element_block):tooltip("tooltip.info-building"):color(block_color))
  end

  ---col beacon
  --local cell_beacon = GuiElement.add(gui_table, GuiTable("beacon", block.id):column(2):style("helmod_table_list"))
  
  local product_sorter = User.getProductSorter()

  ---products
  local display_product_cols = User.getPreferenceSetting("display_product_cols") + 1
  local cell_products = GuiElement.add(gui_table, GuiTable("products", block.id):column(display_product_cols):style("helmod_table_list"))
  cell_products.style.horizontally_stretchable = false
  if block.products ~= nil then
    for index, product in spairs(block.products, product_sorter) do
      if ((product.state or 0) == 1 and block_by_product)  or (product.count or 0) > ModelCompute.waste_value then
        local block_id = "new"
        local button_action = "production-recipe-product-add"
        local button_tooltip = "tooltip.product"
        local button_color = GuiElement.color_button_default_product
        product.time = model.time
        if not(block_by_product) then
          button_action = "production-recipe-product-add"
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
        ---color
        if product.state == 1 then
          if not(block.unlinked) or block.by_factory == true then
            button_color = GuiElement.color_button_default_product
          else
            block_id = block.id
            button_color = GuiElement.color_button_edit
          end
        elseif product.state == 3 then
          block_id = block.id
          button_color = GuiElement.color_button_rest
        else
          button_color = GuiElement.color_button_default_product
        end
        GuiElement.add(cell_products, GuiCellElement(self.classname, button_action, model.id, block_id, product.name):element(product):tooltip(button_tooltip):color(button_color):index(index))
      end
    end
  end
  ---ingredients
  local display_ingredient_cols = User.getPreferenceSetting("display_ingredient_cols") + 2
  local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients", block.id):column(display_ingredient_cols))
  cell_ingredients.style.horizontally_stretchable = false
  if block.ingredients ~= nil then
    for index, ingredient in spairs(block.ingredients, product_sorter) do
      if ((ingredient.state or 0) == 1 and not(block_by_product)) or (ingredient.count or 0) > ModelCompute.waste_value then
        local block_id = "new"
        local button_action = "production-recipe-ingredient-add"
        local button_tooltip = "tooltip.ingredient"
        local button_color = GuiElement.color_button_default_ingredient
        ingredient.time = model.time
        if block_by_product then
          button_action = "production-recipe-ingredient-add"
          button_tooltip = "tooltip.add-recipe"
        else
          button_action = "product-edition"
          button_tooltip = "tooltip.edit-product"
        end
        ---color
        if ingredient.state == 1 then
          if not(block.unlinked) or block.by_factory == true then
            button_color = GuiElement.color_button_default_ingredient
          else
            block_id = block.id
            button_color = GuiElement.color_button_edit
          end
        elseif ingredient.state == 3 then
          button_color = GuiElement.color_button_rest
        else
          button_color = GuiElement.color_button_default_ingredient
        end
        GuiElement.add(cell_ingredients, GuiCellElement(self.classname, button_action, model.id, block_id, ingredient.name):element(ingredient):tooltip(button_tooltip):color(button_color):index(index))
      end
    end
  end
  return cell_recipe
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function ProductionPanel:onEvent(event)
  local model, block, _ = self:getParameterObjects()

  if block == nil then
    block = model.blocks[event.item2]
  end
  ---***************************
  ---access for all
  ---***************************
  self:onEventAccessAll(event, model, block)

  ---***************************
  ---access admin or owner
  ---***************************

  if User.isReader(model) then
    self:onEventAccessRead(event, model, block)
  end

  ---*******************************
  ---access admin or owner or write
  ---*******************************

  if User.isWriter(model) then
    self:onEventAccessWrite(event, model, block)
  end

  ---********************************
  ---access admin or owner or delete
  ---********************************

  if User.isDeleter(model) then
    self:onEventAccessDelete(event, model, block)
  end

  ---*******************************
  ---access admin only
  ---*******************************

  if User.isAdmin() then
    self:onEventAccessAdmin(event, model, block)
  end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
---@param model table
---@param block table
function ProductionPanel:onEventAccessAll(event, model, block)
  if event.action == "refresh-model" then
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "change-model" then
    ModelCompute.check(model)
    Controller:send("on_gui_open", event, self.classname)
  end
  
  if event.action == "new-model" then
    local new_model = Model.newModel()
    User.setParameter(self.parameter_objects, {name=self.parameter_objects, model=new_model.id})
    Controller:send("on_gui_open", event, self.classname)
  end
  
  if event.action == "new-block" then
    Controller:send("on_gui_open", event, "HMRecipeSelector")
  end
  
  if event.action == "change-block" then
    Controller:closeEditionOrSelector()
    Controller:send("on_gui_open", event, self.classname)
  end

  if event.action == "change-logistic" then
    local display_logistic_row = User.getParameter("display_logistic_row")
    User.setParameter("display_logistic_row", not(display_logistic_row))
    Controller:send("on_gui_update", event)
  end

  if event.action == "change-logistic-item" then
    User.setParameter("logistic_row_item", event.item1)
    Controller:send("on_gui_update", event)
  end

  if event.action == "change-logistic-fluid" then
    User.setParameter("logistic_row_fluid", event.item1)
    Controller:send("on_gui_update", event)
  end

  if event.action == "block-all-ingredient-visible" then
    local all_visible = User.getParameter("block_all_ingredient_visible")
    User.setParameter("block_all_ingredient_visible",not(all_visible))
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-all-product-visible" then
    local all_visible = User.getParameter("block_all_product_visible")
    User.setParameter("block_all_product_visible",not(all_visible))
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "solver_switch" then
    local solver_selected = User.getParameter("solver_selected") or "normal"
    if solver_selected == "normal" then
      User.setParameter("solver_selected", "matrix")
    else
      User.setParameter("solver_selected", "normal")
    end
    Controller:send("on_gui_update", event, self.classname)
  end

end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
---@param model table
---@param block table
function ProductionPanel:onEventAccessRead(event, model, block)
  if event.action == "copy-model" then
    if block ~= nil then
      User.setParameter("copy_from_block_id", block.id)
      User.setParameter("copy_from_model_id", model.id)
    else
      User.setParameter("copy_from_block_id", nil)
      User.setParameter("copy_from_model_id", model.id)
    end
    Controller:send("on_gui_update", event)
  end

  if event.action == "factory-action" then
    local recipe = block.recipes[event.item3]
    if event.control == true then
      if recipe ~= nil and recipe.factory ~= nil then
        local factory = recipe.factory
        Player.beginCrafting(factory.name, factory.count)
      end
    else
      event.action = "OPEN"
      Controller:send("on_gui_open", event,"HMRecipeEdition")
    end
  end

  if event.action == "beacon-action" then
    if event.control == true then
      local recipe = block.recipes[event.item3]
      if recipe ~= nil and recipe.beacon ~= nil then
        local beacon = recipe.beacon
        Player.beginCrafting(beacon.name, beacon.count)
      end
    else
      event.action = "OPEN"
      Controller:send("on_gui_open", event,"HMRecipeEdition")
    end
  end

end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
---@param model table
---@param block table
function ProductionPanel:onEventAccessWrite(event, model, block)
  local selector_name = "HMRecipeSelector"
  
  if event.action == "model-index-up" and model ~= nil then
    if model.owner == Player.native().name then
      local models = Model.getModelsOwner()
      table.up_indexed_list(models, model.index, 1)
      self:updateIndexPanel(model)
    end
  end

  if event.action == "model-index-down" and model ~= nil then
    if model.owner == Player.native().name then
      local models = Model.getModelsOwner()
      table.down_indexed_list(models, model.index, 1)
      self:updateIndexPanel(model)
    end
  end

  if event.action == "change-boolean-option" and block ~= nil then
    ModelBuilder.updateProductionBlockOption(block, event.item1, not(block[event.item1]))
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "change-number-option" and block ~= nil then
    local value = GuiElement.getInputNumber(event.element)
    ModelBuilder.updateProductionBlockOption(block, event.item1, value)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "change-time" then
    local index = event.element.selected_index
    model.time = defines.constant.base_times[index].value or 1
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
    Controller:send("on_gui_close", event, "HMProductEdition")
  end

  if event.action == "product-selected" then
    if event.button == defines.mouse_button_type.right then
      -- Set Parameter Target for the selector return
      User.setParameter("HMRecipeSelector_target", self.classname)
      Controller:send("on_gui_open", event,"HMRecipeSelector")
    end
  end

  if event.action == "product-edition" then
    if event.button == defines.mouse_button_type.right then
      -- Set Parameter Target for the selector return
      User.setParameter("HMRecipeSelector_target", self.classname)
      Controller:send("on_gui_open", event, selector_name)
    else
      Controller:send("on_gui_open", event, "HMProductEdition")
    end
  end

  if event.action == "production-block-unlink" then
    ModelBuilder.unlinkProductionBlock(block)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "past-model" then
    local from_model_id = User.getParameter("copy_from_model_id")
    local from_model = global.models[from_model_id]
    if from_model ~= nil then
      local from_block_id = User.getParameter("copy_from_block_id")
      local from_block = from_model.blocks[from_block_id]
      ModelBuilder.pastModel(model, block, from_model, from_block)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    end
  end

  if event.action == "change-computing" then
    local index = event.element.selected_index
    if index == 3 then
      ModelBuilder.updateProductionBlockOption(block, "by_factory", false)
      ModelBuilder.updateProductionBlockOption(block, "solver", true)
    elseif index == 2 then
      ModelBuilder.updateProductionBlockOption(block, "by_factory", true)
      ModelBuilder.updateProductionBlockOption(block, "solver", false)
    else
      ModelBuilder.updateProductionBlockOption(block, "by_factory", false)
      ModelBuilder.updateProductionBlockOption(block, "solver", false)
    end
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-block-up" then
    if block == nil then
      block = model.blocks[event.item2]
    end
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.upProductionBlock(model, block, step)
    ModelCompute.update(model)
    User.setParameter("scroll_element", block.id)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-block-down" then
    if block == nil then
      block = model.blocks[event.item2]
    end
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    ModelBuilder.downProductionBlock(model, block, step)
    ModelCompute.update(model)
    User.setParameter("scroll_element", block.id)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-recipe-product-add" then
    if event.control == false and event.shift == false then
      if event.button == defines.mouse_button_type.right then
        -- Set Parameter Target for the selector return
        User.setParameter("HMRecipeSelector_target", self.classname)
        Controller:send("on_gui_open", event, selector_name)
      else
        local recipes = Player.searchRecipe(event.item4, true)
        if #recipes == 1 then
          local recipe = recipes[1]
          local _,new_recipe = ModelBuilder.addRecipeIntoProductionBlock(model, block, recipe.name, recipe.type, 0)
          ModelCompute.update(model)
          User.setParameter("scroll_element", new_recipe.id)
          Controller:send("on_gui_update", event)
        else
          -- Set Parameter Target for the selector return
          User.setParameter("HMRecipeSelector_target", self.classname)
          ---pour ouvrir avec le filtre ingredient
          event.button = defines.mouse_button_type.right
          Controller:send("on_gui_open", event, selector_name)
        end
      end
    elseif block ~= nil and event.control == true and event.item3 ~= "none" then
      local contraint = {type="master", name=event.item4}
      local recipe = block.recipes[event.item3]
      ModelBuilder.updateRecipeContraint(recipe, contraint)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    elseif block ~= nil and event.shift == true and event.item3 ~= "none" then
      local contraint = {type="exclude", name=event.item4}
      local recipe = block.recipes[event.item3]
      ModelBuilder.updateRecipeContraint(recipe, contraint)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    end
  end

  if event.action == "production-recipe-ingredient-add" then
    if event.control == false and event.shift == false then
      if event.button == defines.mouse_button_type.right then
        -- Set Parameter Target for the selector return
        User.setParameter("HMRecipeSelector_target", self.classname)
        Controller:send("on_gui_open", event, selector_name)
      else
        local recipes = Player.searchRecipe(event.item4)
        if #recipes == 1 then
          local recipe = recipes[1]
          local _,new_recipe = ModelBuilder.addRecipeIntoProductionBlock(model, block, recipe.name, recipe.type)
          ModelCompute.update(model)
          User.setParameter("scroll_element", new_recipe.id)
          Controller:send("on_gui_update", event)
        else
          -- Set Parameter Target for the selector return
          User.setParameter("HMRecipeSelector_target", self.classname)
          Controller:send("on_gui_open", event, selector_name)
        end
      end
    elseif block ~= nil and event.control == true and event.item4 ~= "none" then
      local contraint = {type="master", name=event.item4}
      local recipe = block.recipes[event.item3]
      ModelBuilder.updateRecipeContraint(recipe, contraint)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    elseif block ~= nil and event.shift == true and event.item4 ~= "none" then
      local contraint = {type="exclude", name=event.item4}
      local recipe = block.recipes[event.item3]
      ModelBuilder.updateRecipeContraint(recipe, contraint)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    end
  end

  if block ~= nil and event.action == "conversion-recipe-block" then
    local recipe = block.recipes[event.item3]
    ModelBuilder.convertRecipeToblock(model, block, recipe, event.control)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if block ~= nil and event.action == "product-info" then
    if block.products_linked == nil then block.products_linked = {} end
    if event.control == true and event.item5 ~= "none" then
      block.products_linked[event.item5] = not(block.products_linked[event.item5])
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    end
  end

  if event.action == "update-factory-number" then
    local text = event.element.text
    local ok , err = pcall(function()
      local value = formula(text) or 0
      local recipe = block.recipes[event.item3]
      ModelBuilder.updateFactoryNumber(recipe, value)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    end)
    if not(ok) then
      Player.print("Formula is not valid!")
    end
  end

  if event.action == "update-factory-limit" then
    local text = event.element.text
    local ok , err = pcall(function()
      local value = formula(text) or 0
      local recipe = block.recipes[event.item3]
      ModelBuilder.updateFactoryLimit(recipe, value)
      ModelCompute.update(model)
      Controller:send("on_gui_update", event)
    end)
    if not(ok) then
      Player.print("Formula is not valid!")
    end
  end

  if event.action == "update-matrix-solver" then
    local recipe = block.recipes[event.item3]
    ModelBuilder.updateMatrixSolver(block, recipe)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-block-solver" then
    ModelBuilder.updateBlockMatrixSolver(block)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "production-recipe-remove" then
    local recipe = block.recipes[event.item3]
    ModelBuilder.removeProductionRecipe(block, recipe)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "production-recipe-up" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    local recipe = block.recipes[event.item3]
    ModelBuilder.upProductionRecipe(block, recipe, step)
    ModelCompute.update(model)
    User.setParameter("scroll_element", recipe.id)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "production-recipe-down" then
    local step = 1
    if event.shift then step = User.getModSetting("row_move_step") end
    if event.control then step = 1000 end
    local recipe = block.recipes[event.item3]
    ModelBuilder.downProductionRecipe(block, recipe, step)
    ModelCompute.update(model)
    User.setParameter("scroll_element", recipe.id)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-unlink" then
    local switch_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(block, "unlinked", switch_state)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-element" then
    local switch_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(block, "by_product", switch_state)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-factory" then
    local switch_state = not(event.element.switch_state == "left")
    ModelBuilder.updateProductionBlockOption(block, "by_factory", switch_state)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-solver" then
    local switch_state = event.element.switch_state == "right"
    ModelBuilder.updateProductionBlockOption(block, "solver", switch_state)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-switch-limit" then
    local switch_state = event.element.switch_state == "left"
    ModelBuilder.updateProductionBlockOption(block, "by_limit", switch_state)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-by-product" then
    local by_product = block.by_product ~= false
    ModelBuilder.updateProductionBlockOption(block, "by_product", not(by_product))
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end

  if event.action == "block-limit" then
    ModelBuilder.updateProductionBlockOption(block, "by_limit", not(block.by_limit))
    ModelCompute.update(model)
    Controller:send("on_gui_update", event, self.classname)
  end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
---@param model table
---@param block table
function ProductionPanel:onEventAccessDelete(event, model, block)
  if event.action == "remove-model" then
    ModelBuilder.removeModel(event.item1)
    Controller:send("on_gui_update", event)
  end

  if event.action == "remove-block" then
    ModelBuilder.removeProductionBlock(model, block)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
---@param model table
---@param block table
function ProductionPanel:onEventAccessAdmin(event, model, block)
  if event.action == "game-pause" then
    if not(game.is_multiplayer()) then
      User.setParameter("auto-pause", true)
      game.tick_paused = true
      Controller:send("on_gui_pause", event)
    end
  end

  if event.action == "game-play" then
    User.setParameter("auto-pause", false)
    game.tick_paused = false
    Controller:send("on_gui_pause", event)
  end
end
