-------------------------------------------------------------------------------
---Class to build summary dialog
---@class SummaryPanel
SummaryPanel = newclass(FormModel)

-------------------------------------------------------------------------------
---On initialization
function SummaryPanel:onInit()
  self.panelCaption = ({"helmod_summary-panel.title"})
  self.otherClose = false
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function SummaryPanel:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 100,
    maximal_width = 800,
    minimal_height = 500,
    maximal_height = height_main
  }
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function SummaryPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement
function SummaryPanel:getTabPane()
  local content_panel = self:getFrameDeepPanel("panel")
  local panel_name = "tab_panel"
  local name = table.concat({self.classname, "change-tab", panel_name},"=")
  if content_panel[name] ~= nil and content_panel[name].valid then
    return content_panel[name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(self.classname, "change-tab", panel_name))
  return panel
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@param panel_name string
---@param caption string
---@return LuaGuiElement
function SummaryPanel:getTab(panel_name, caption)
  local content_panel = self:getTabPane()
  local scroll_name = "scroll-" .. panel_name
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption(caption))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create global tab panel
---@return LuaGuiElement
function SummaryPanel:getGlobalTab()
  return self:getTab("global-tab-panel", {"helmod_summary-panel.tab-global"})
end

-------------------------------------------------------------------------------
---Get or create global tab panel
---@return LuaGuiElement
function SummaryPanel:getLocalTab()
  return self:getTab("local-tab-panel", {"helmod_summary-panel.tab-local"})
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function SummaryPanel:onUpdate(event)
  local model, block, recipe = self:getParameterObjects()
  if block ~= nil then
    local panel_global = self:getGlobalTab()
    self:updateSummary(panel_global, block.summary_global)
    local panel_local = self:getLocalTab()
    self:updateSummary(panel_local, block.summary)
  end
end

-------------------------------------------------------------------------------
---Update Summary
---@param summary table
function SummaryPanel:updateSummary(parent, summary)
  parent.clear()

  if summary ~= nil then
    ---factories
    GuiElement.add(parent, GuiLabel("factories_label"):caption({"helmod_common.factories"}):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(parent, GuiTable("table-factory"):column(4))
    result_table.style.horizontally_stretchable = false
    for _, element in pairs(summary.factories) do
      GuiElement.add(result_table, GuiCellElementM("HMFactories=OPEN"):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
    end

    ---beacons
    if table_size(summary.beacons) > 0 then
      GuiElement.add(parent, GuiLabel("beacons_label"):caption({"helmod_common.beacons"}):style("helmod_label_title_frame"))
      local result_table = GuiElement.add(parent, GuiTable("table-beacon"):column(4))
      result_table.style.horizontally_stretchable = false
      for _, element in pairs(summary.beacons) do
        GuiElement.add(result_table, GuiCellElementM("HMBeacons=OPEN"):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end
    end

    ---modules
    GuiElement.add(parent, GuiLabel("modules_label"):caption({"helmod_common.modules"}):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(parent, GuiTable("table-modules"):column(4))
    result_table.style.horizontally_stretchable = false
    for _, element in pairs(summary.modules) do
      GuiElement.add(result_table, GuiCellElementM("HMModules=OPEN"):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
    end
  end
end

-------------------------------------------------------------------------------
---Update data
---@param model table
function SummaryPanel:updateData(parent, model)
  parent.clear()

  if model ~= nil then
    local resourcesPanel = GuiElement.add(parent, GuiFlowV("resources"))
    GuiElement.add(resourcesPanel, GuiLabel("label"):caption({"helmod_common.resources"}):style("helmod_label_title_frame"))

    local resourcesTable = GuiElement.add(resourcesPanel, GuiTable("table-resources"):column(4))
    GuiElement.add(resourcesTable, GuiLabel("header-ingredient"):caption({"helmod_result-panel.col-header-ingredient"}))
    GuiElement.add(resourcesTable, GuiLabel("header-cargo-wagon"):caption({"helmod_result-panel.col-header-wagon"}))
    GuiElement.add(resourcesTable, GuiLabel("header-chest"):caption({"helmod_result-panel.col-header-storage"}))

    for _, resource in pairs(model.resources) do
      ---ingredient
      local guiIngredient = GuiElement.add(resourcesTable, GuiFrameH("ingredient", resource.name):style(helmod_frame_style.hidden))
      GuiElement.add(guiIngredient, GuiLabel("count"):caption(Format.formatNumberElement(resource.count)):style("helmod_label_right_60"))
      GuiElement.add(guiIngredient, GuiButtonSprite("HMIngredient", "OPEN"):sprite(Player.getItemIconType(resource), resource.name):tooltip(Player.getLocalisedName(resource)))

      ---col wagon
      local wagon = resource.wagon
      local guiWagon = GuiElement.add(resourcesTable, GuiFrameH("wagon", resource.name):style(helmod_frame_style.hidden))
      if wagon ~= nil then
        GuiElement.add(guiWagon, GuiLabel("count"):caption(Format.formatNumberElement(wagon.limit_count).."/"..Format.formatNumberElement(wagon.count)):style("helmod_label_right_70"))
        GuiElement.add(guiWagon, GuiButtonSprite("HMWagon", "OPEN"):sprite(wagon.type, wagon.name):style(Player.getLocalisedName(wagon)))
      end

      ---col storage
      local storage = resource.storage
      local guiStorage = GuiElement.add(resourcesTable, GuiFrameH("storage", resource.name):style(helmod_frame_style.hidden))
      if storage ~= nil then
        GuiElement.add(guiStorage, GuiLabel("count"):caption(Format.formatNumberElement(storage.limit_count).."/"..Format.formatNumberElement(storage.count)):style("helmod_label_right_70"))
        GuiElement.add(guiStorage, GuiButtonSprite("HMStorage", "OPEN"):sprite(storage.type, storage.name):tooltip(Player.getLocalisedName(storage)))
      end
    end
    ---generators
    local energyPanel = GuiElement.add(parent, GuiFlowV("energy"))
    GuiElement.add(energyPanel, GuiLineH("line"))
    GuiElement.add(energyPanel, GuiLabel("label"):caption({"helmod_common.generators"}):style("helmod_label_title_frame"))

    local resultTable = GuiElement.add(energyPanel, GuiTable("table-energy"):column(2))

    if model.generators ~= nil then
      for _, item in pairs(model.generators) do
        local guiCell = GuiElement.add(resultTable, GuiFrameH("cell", item.name):style(helmod_frame_style.hidden))
        GuiElement.add(guiCell, GuiLabel(item.name):caption(Format.formatNumberKilo(item.count)):style("helmod_label_right_50"))
        GuiElement.add(guiCell, GuiButtonSprite("HMGenerator", "OPEN"):sprite("item", item.name):tooltip(Player.getLocalisedName(item)))
      end
    end
  end
end