-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AbstractTab
--

AbstractTab = newclass(FormModel,function(base,classname)
  FormModel.init(base,classname)
  base.add_special_button = true
end)

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#AbstractTab] onBind
--
function AbstractTab:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
  Dispatcher:bind("on_gui_pause", self, self.updateTopMenu)
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#AbstractTab] onInit
--
function AbstractTab:onInit()
  self.panelCaption = string.format("%s %s","Helmod",game.active_mods["helmod"])
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#AbstractTab] getButtonSprites
--
-- @return boolean
--
function AbstractTab:getButtonSprites()
  return "help-white","help"
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
-- Get or create result panel
--
-- @function [parent=#AbstractTab] getResultPanel
--
function AbstractTab:getResultPanel()
  local panel = self:getFrameDeepPanel("result")
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#AbstractTab] getResultScrollPanel
--
function AbstractTab:getResultScrollPanel()
  local parent_panel = self:getResultPanel()
  local scroll_name = "scroll-data"
  if parent_panel[scroll_name] ~= nil and parent_panel[scroll_name].valid then
    return parent_panel[scroll_name]
  end
  local scroll_panel = GuiElement.add(parent_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"))
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#AbstractTab] onUpdate
--
-- @param #LuaEvent event
--
function AbstractTab:onUpdate(event)
  self:beforeUpdate(event)

  self:updateMenuPanel(event)

  self:updateIndexPanel(event)

  self:updateHeader(event)

  self:updateData(event)
end

-------------------------------------------------------------------------------
-- Update menu panel
--
-- @function [parent=#AbstractTab] updateMenuPanel
--
-- @param #LuaEvent event
--
function AbstractTab:updateMenuPanel(event)
  local model, block = self:getParameterObjects()

  -- action panel
  local left_panel, right_panel = self:getMenuPanel()
  left_panel.clear()
  right_panel.clear()

  local button_spacing = 2
  local group0 = GuiElement.add(left_panel, GuiFlowH("group0"))
  group0.style.horizontal_spacing = button_spacing
  for _, form in pairs(Controller.getViews()) do
    if string.find(form.classname, "Tab") and form:isVisible() and not(form:isSpecial()) then
      local icon_hovered, icon = form:getButtonSprites()
      if User.isActiveForm(form.classname) then
        GuiElement.add(group0, GuiButton(self.classname, "change-tab", form.classname, model.id):sprite("menu", icon_hovered, icon_hovered):style("helmod_button_menu_selected"):tooltip(form:getButtonCaption()))
      else
        GuiElement.add(group0, GuiButton(self.classname, "change-tab", form.classname, model.id):sprite("menu", icon, icon):style("helmod_button_menu"):tooltip(form:getButtonCaption()))
      end
    end
  end

  -- add recipe
  local block_id = "new"
  if block ~= nil then block_id = block.id end

  local group2 = GuiElement.add(left_panel, GuiFlowH("group2"))
  group2.style.horizontal_spacing = button_spacing
  -- copy past
  GuiElement.add(group2, GuiButton(self.classname, "copy-model", model.id):sprite("menu", "copy", "copy"):style("helmod_button_menu"):tooltip({"helmod_button.copy"}))
  GuiElement.add(group2, GuiButton(self.classname, "past-model", model.id):sprite("menu", "paste", "paste"):style("helmod_button_menu"):tooltip({"helmod_button.past"}))
  -- download
  if self.classname == "HMProductionBlockTab" then
    GuiElement.add(group2, GuiButton("HMDownload", "OPEN", "download"):sprite("menu", "download", "download"):style("helmod_button_menu"):tooltip({"helmod_result-panel.download-button-production-line"}))
    GuiElement.add(group2, GuiButton("HMDownload", "OPEN", "upload"):sprite("menu", "upload", "upload"):style("helmod_button_menu"):tooltip({"helmod_result-panel.upload-button-production-line"}))
  end
  -- refresh control
  GuiElement.add(group2, GuiButton(self.classname, "refresh-model", model.id):sprite("menu", "refresh", "refresh"):style("helmod_button_menu"):tooltip({"helmod_result-panel.refresh-button"}))

  local group3 = GuiElement.add(left_panel, GuiFlowH("group3"))
  group3.style.horizontal_spacing = button_spacing
  -- pin info
  if self.classname == "HMStatisticTab" then
    GuiElement.add(group3, GuiButton("HMStatusPanel", "OPEN", model.id, block_id):sprite("menu", "pin", "pin"):style("helmod_button_menu"):tooltip({"helmod_result-panel.tab-button-pin"}))
  end

  -- preferences
  local groupPref = GuiElement.add(left_panel, GuiFlowH("groupPref"))
  groupPref.style.horizontal_spacing = button_spacing
  GuiElement.add(groupPref, GuiButton("HMModelEdition", "OPEN", model.id, block_id):sprite("menu", "edit", "edit"):style("helmod_button_menu"):tooltip({"helmod_panel.model-edition"}))
  GuiElement.add(groupPref, GuiButton("HMPreferenceEdition", "OPEN", model.id, block_id):sprite("menu", "services", "services"):style("helmod_button_menu"):tooltip({"helmod_button.preferences"}))
  
  local display_logistic_row = User.getParameter("display_logistic_row")
  if display_logistic_row == true then
    GuiElement.add(groupPref, GuiButton(self.classname, "change-logistic"):sprite("menu", "container-white", "container"):style("helmod_button_menu_selected"):tooltip({"tooltip.display-logistic-row"}))
  else
    GuiElement.add(groupPref, GuiButton(self.classname, "change-logistic"):sprite("menu", "container", "container"):style("helmod_button_menu"):tooltip({"tooltip.display-logistic-row"}))
  end
  
  -- logistics
  if display_logistic_row == true then
    local logistic_row_item = User.getParameter("logistic_row_item") or "belt"
    local logistic2 = GuiElement.add(left_panel, GuiFlowH("logistic2"))
    logistic2.style.horizontal_spacing = button_spacing
    for _,type in pairs({"inserter", "belt", "container", "transport"}) do
      local item_logistic = Player.getDefaultItemLogistic(type)
      local style = "helmod_button_menu"
      if logistic_row_item == type then style = "helmod_button_menu_selected" end
      local button = GuiElement.add(logistic2, GuiButton(self.classname, "change-logistic-item", type):sprite("sprite", item_logistic):style(style):tooltip({"tooltip.logistic-row-choose"}))
      button.style.padding = {0,0,0,0}
    end
    
    local logistic_row_fluid = User.getParameter("logistic_row_fluid") or "pipe"
    local logistic3 = GuiElement.add(left_panel, GuiFlowH("logistic3"))
    logistic3.style.horizontal_spacing = button_spacing
    for _,type in pairs({"pipe", "container", "transport"}) do
      local fluid_logistic = Player.getDefaultFluidLogistic(type)
      local style = "helmod_button_menu"
      if logistic_row_fluid == type then style = "helmod_button_menu_selected" end
      local button = GuiElement.add(logistic3, GuiButton(self.classname, "change-logistic-fluid", type):sprite("sprite", fluid_logistic):style(style):tooltip({"tooltip.logistic-row-choose"}))
      button.style.padding = {0,0,0,0}
    end
  end


  local items = {}
  local default_time = 1
  for index,base_time in pairs(helmod_base_times) do
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
-- @param #LuaEvent event
--
function AbstractTab:updateIndexPanel(event)
  if self:hasIndexModel() then
    local models = Model.getModels()
    local model = self:getParameterObjects()
  
      -- index panel
    local index_panel = self:getFramePanel("model_index")
    index_panel.style.padding = 2
    index_panel.clear()
    local table_index = GuiElement.add(index_panel, GuiTable("table_index"):column(GuiElement.getIndexColumnNumber()):style("helmod_table_list"))
    if table.size(models) > 0 then
      local i = 0
      for _,imodel in pairs(models) do
        i = i + 1
        local style = "helmod_button_default"
        local element = Model.firstRecipe(imodel.blocks)
        if imodel.id == model.id then
          if element ~= nil then
            local tooltip = GuiTooltipModel("tooltip.info-model"):element(imodel)
            local button = GuiElement.add(table_index, GuiButtonSprite(self.classname, "change-model", imodel.id):sprite(element.type, element.name):style("helmod_button_menu_selected"):tooltip(tooltip))
            button.style.width = 36
            button.style.height = 36
            button.style.padding = {-2,-2,-2,-2}
          else
            local button = GuiElement.add(table_index, GuiButton(self.classname, "change-model", imodel.id):sprite("menu", "help-white", "help"):style("helmod_button_menu_selected"))
            button.style.width = 36
            --button.style.height = 36
          end
        else
          if element ~= nil then
            local tooltip = GuiTooltipModel("tooltip.info-model"):element(imodel)
            GuiElement.add(table_index, GuiButtonSelectSprite(self.classname, "change-model", imodel.id):sprite(element.type, element.name):tooltip(tooltip):color())
          else
            local button = GuiElement.add(table_index, GuiButton(self.classname, "change-model", imodel.id):sprite("menu", "help", "help"):style("helmod_button_menu"))
            button.style.width = 36
            --button.style.height = 36
          end
        end

      end
    end
    GuiElement.add(table_index, GuiButton(self.classname, "new-model"):sprite("menu", "plus", "plus"):style("helmod_button_menu_green"):tooltip({"helmod_button.add-production-line"}))
    --GuiElement.add(table_index, GuiButton("HMArrangeModels", "OPEN"):sprite("menu", "menu", "menu"):style("helmod_button_menu"):tooltip({"helmod_button.add-production-line"}))
  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#AbstractTab] updateInfo
--
-- @param #LuaEvent event
--
function AbstractTab:addSharePanel(parent, model)

  local block_table = GuiElement.add(parent, GuiTable("share-table"):column(2))

  GuiElement.add(block_table, GuiLabel("label-owner"):caption({"helmod_result-panel.owner"}))
  GuiElement.add(block_table, GuiLabel("value-owner"):caption(model.owner))

  GuiElement.add(block_table, GuiLabel("label-share"):caption({"helmod_result-panel.share"}))

  local share_panel = GuiElement.add(block_table, GuiTable("table"):column(9))
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  GuiElement.add(share_panel, GuiCheckBox(self.classname, "share-model", model.id, "read"):state(model_read):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  GuiElement.add(share_panel, GuiLabel(self.classname, "share-model-read"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  GuiElement.add(share_panel, GuiCheckBox(self.classname, "share-model", model.id, "write"):state(model_write):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  GuiElement.add(share_panel, GuiLabel(self.classname, "share-model-write"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  GuiElement.add(share_panel,GuiCheckBox( self.classname, "share-model", model.id, "delete"):state(model_delete):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  GuiElement.add(share_panel, GuiLabel(self.classname, "share-model-delete"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))

end
-------------------------------------------------------------------------------
-- Before update
--
-- @function [parent=#AbstractTab] beforeUpdate
--
-- @param #LuaEvent event
--
function AbstractTab:beforeUpdate(event)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#AbstractTab] updateHeader
--
-- @param #LuaEvent event
--
function AbstractTab:updateHeader(event)
end
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AbstractTab] updateData
--
-- @param #LuaEvent event
--
function AbstractTab:updateData(event)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractTab] onEvent
--
-- @param #LuaEvent event
--
function AbstractTab:onEvent(event)
  local model, block, _ = self:getParameterObjects()

  if block == nil then
    block = model.blocks[event.item2]
  end
  -- ***************************
  -- access for all
  -- ***************************
  self:onEventAccessAll(event, model, block)

  -- ***************************
  -- access admin or owner
  -- ***************************

  if User.isReader(model) then
    self:onEventAccessRead(event, model, block)
  end

  -- *******************************
  -- access admin or owner or write
  -- *******************************

  if User.isWriter(model) then
    self:onEventAccessWrite(event, model, block)
  end

  -- ********************************
  -- access admin or owner or delete
  -- ********************************

  if User.isDeleter(model) then
    self:onEventAccessDelete(event, model, block)
  end

  -- *******************************
  -- access admin only
  -- *******************************

  if User.isAdmin() then
    self:onEventAccessAdmin(event, model, block)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractTab] onEventAccessAll
--
-- @param #LuaEvent event
--
function AbstractTab:onEventAccessAll(event, model, block)
  if event.action == "refresh-model" then
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
  end

  if event.action == "change-model" then
    local current_tab = event.classname
    ModelCompute.check(model)
    Controller:send("on_gui_open", event, current_tab)
  end
  
  if event.action == "new-model" then
    local current_tab = "HMProductionBlockTab"
    local new_model = Model.newModel()
    User.setParameter(self.parameter_objects, {name=self.parameter_objects, model=new_model.id})
    Controller:send("on_gui_open", event, current_tab)
  end
  
  if event.action == "new-block" then
    Controller:send("on_gui_open", event, "HMRecipeSelector")
  end
  
  if event.action == "change-tab" then
    local current_tab = event.item1
    local new_event = {classname = current_tab, item1 = event.item2}
    new_event.item2 = event.item3
    Controller:closeEditionOrSelector()
    Controller:send("on_gui_open", new_event, current_tab)
  end

  if event.action == "close-tab" then
    Controller:closeTab()
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

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractTab] onEventAccessRead
--
-- @param #LuaEvent event
--
function AbstractTab:onEventAccessRead(event, model, block)
  if event.action == "copy-model" then
    if User.isActiveForm("HMProductionBlockTab") then
      if block ~= nil then
        User.setParameter("copy_from_block_id", block.id)
        User.setParameter("copy_from_model_id", model.id)
      else
        User.setParameter("copy_from_block_id", nil)
        User.setParameter("copy_from_model_id", model.id)
        end
    end
    Controller:send("on_gui_update", event)
  end
  if event.action == "share-model" then
    local access = event.item2
    if model ~= nil then
      if access == "read" then
        if model.share == nil or not(bit32.band(model.share, 1) > 0) then
          model.share = 1
        else
          model.share = 0
        end
      end
      if access == "write" then
        if model.share == nil or not(bit32.band(model.share, 2) > 0) then
          model.share = 3
        else
          model.share = 1
        end
      end
      if access == "delete" then
        if model.share == nil or not(bit32.band(model.share, 4) > 0) then
          model.share = 7
        else
          model.share = 3
        end
      end
    end
    Controller:send("on_gui_refresh", event)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractTab] onEventAccessWrite
--
-- @param #LuaEvent event
--
function AbstractTab:onEventAccessWrite(event, model, block)
  local selector_name = "HMRecipeSelector"
  if block ~= nil and block.isEnergy then
    selector_name = "HMEnergySelector"
  end

  if event.action == "change-tab" then
    if event.item1 == "HMProductionBlockTab" and event.item2 == "new" then
      Controller:send("on_gui_open", event,"HMRecipeSelector")
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
    model.time = helmod_base_times[index].value or 1
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
    Controller:send("on_gui_close", event, "HMProductEdition")
  end

  if event.action == "product-selected" then
    if event.button == defines.mouse_button_type.right then
      Controller:send("on_gui_open", event,"HMRecipeSelector")
    end
  end

  if event.action == "product-edition" then
    if event.button == defines.mouse_button_type.right then
      Controller:send("on_gui_open", event, selector_name)
    else
      Controller:send("on_gui_open", event, "HMProductEdition")
    end
  end

  if event.action == "production-block-remove" then
    ModelBuilder.removeProductionBlock(model, block)
    ModelCompute.update(model)
    Controller:send("on_gui_update", event)
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

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractTab] onEventAccessDelete
--
-- @param #LuaEvent event
--
function AbstractTab:onEventAccessDelete(event, model, block)
  if event.action == "remove-model" then
    ModelBuilder.removeModel(event.item1)
    User.setActiveForm("HMProductionBlockTab")
    Controller:send("on_gui_update", event)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AbstractTab] onEventAccessAdmin
--
-- @param #LuaEvent event
--
function AbstractTab:onEventAccessAdmin(event, model, block)
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