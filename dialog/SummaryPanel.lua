-------------------------------------------------------------------------------
-- Class to build summary dialog
--
-- @module SummaryPanel
-- @extends #FormModel
--

SummaryPanel = newclass(FormModel)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#SummaryPanel] onInit
--
function SummaryPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-title-summary"})
  self.otherClose = false
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#SummaryPanel] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function SummaryPanel:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 100,
    maximal_width = 800,
    minimal_height = 0,
    maximal_height = height_main
  }
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#SummaryPanel] onBind
--
function SummaryPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#SummaryPanel] onUpdate
--
-- @param #LuaEvent event
--
function SummaryPanel:onUpdate(event)
  local model, block, recipe = self:getParameterObjects()
  if block ~= nil then
    self:updateSummary(block.summary)
  else
    self:updateData(model)
    self:updateSummary(model.summary)
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#SummaryPanel] updateData
--
-- @param #LuaEvent event
--
function SummaryPanel:updateData(model)
  local data_panel = self:getScrollFramePanel("data-panel")
  data_panel.clear()

  if model ~= nil then
    local resourcesPanel = GuiElement.add(data_panel, GuiFlowV("resources"))
    GuiElement.add(resourcesPanel, GuiLabel("label"):caption({"helmod_common.resources"}):style("helmod_label_title_frame"))

    local resourcesTable = GuiElement.add(resourcesPanel, GuiTable("table-resources"):column(4))
    GuiElement.add(resourcesTable, GuiLabel("header-ingredient"):caption({"helmod_result-panel.col-header-ingredient"}))
    GuiElement.add(resourcesTable, GuiLabel("header-cargo-wagon"):caption({"helmod_result-panel.col-header-wagon"}))
    GuiElement.add(resourcesTable, GuiLabel("header-chest"):caption({"helmod_result-panel.col-header-storage"}))

    for _, resource in pairs(model.resources) do
      -- ingredient
      local guiIngredient = GuiElement.add(resourcesTable, GuiFrameH("ingredient", resource.name):style(helmod_frame_style.hidden))
      GuiElement.add(guiIngredient, GuiLabel("count"):caption(Format.formatNumberElement(resource.count)):style("helmod_label_right_60"))
      GuiElement.add(guiIngredient, GuiButtonSprite("HMIngredient", "OPEN"):sprite(Player.getItemIconType(resource), resource.name):tooltip(Player.getLocalisedName(resource)))

      -- col wagon
      local wagon = resource.wagon
      local guiWagon = GuiElement.add(resourcesTable, GuiFrameH("wagon", resource.name):style(helmod_frame_style.hidden))
      if wagon ~= nil then
        GuiElement.add(guiWagon, GuiLabel("count"):caption(Format.formatNumberElement(wagon.limit_count).."/"..Format.formatNumberElement(wagon.count)):style("helmod_label_right_70"))
        GuiElement.add(guiWagon, GuiButtonSprite("HMWagon", "OPEN"):sprite(wagon.type, wagon.name):style(Player.getLocalisedName(wagon)))
      end

      -- col storage
      local storage = resource.storage
      local guiStorage = GuiElement.add(resourcesTable, GuiFrameH("storage", resource.name):style(helmod_frame_style.hidden))
      if storage ~= nil then
        GuiElement.add(guiStorage, GuiLabel("count"):caption(Format.formatNumberElement(storage.limit_count).."/"..Format.formatNumberElement(storage.count)):style("helmod_label_right_70"))
        GuiElement.add(guiStorage, GuiButtonSprite("HMStorage", "OPEN"):sprite(storage.type, storage.name):tooltip(Player.getLocalisedName(storage)))
      end
    end
    -- generators
    local energyPanel = GuiElement.add(data_panel, GuiFlowV("energy"))
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

-------------------------------------------------------------------------------
-- Update Summary
--
-- @function [parent=#SummaryPanel] updateSummary
--
-- @param #LuaEvent event
--
function SummaryPanel:updateSummary(summary)
  local info_panel = self:getScrollFramePanel("summary-panel")
  info_panel.clear()

  if summary ~= nil then
    -- factories
    GuiElement.add(info_panel, GuiLabel("factories_label"):caption({"helmod_common.factories"}):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(info_panel, GuiTable("table-factory"):column(4))
    result_table.style.horizontally_stretchable = false
    for _, element in pairs(summary.factories) do
      GuiElement.add(result_table, GuiCellElementM("HMFactories=OPEN"):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
    end

    -- beacons
    GuiElement.add(info_panel, GuiLabel("beacons_label"):caption({"helmod_common.beacons"}):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(info_panel, GuiTable("table-beacon"):column(4))
    result_table.style.horizontally_stretchable = false
    for _, element in pairs(summary.beacons) do
      GuiElement.add(result_table, GuiCellElementM("HMBeacons=OPEN"):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
    end

    -- modules
    GuiElement.add(info_panel, GuiLabel("modules_label"):caption({"helmod_common.modules"}):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(info_panel, GuiTable("table-modules"):column(4))
    result_table.style.horizontally_stretchable = false
    for _, element in pairs(summary.modules) do
      GuiElement.add(result_table, GuiCellElementM("HMModules=OPEN"):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
    end
  end
end
