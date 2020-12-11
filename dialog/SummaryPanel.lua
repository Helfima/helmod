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
  self:updateInfo(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#SummaryPanel] updateInfo
--
-- @param #LuaEvent event
--
function SummaryPanel:updateInfo(event)
  local info_panel = self:getScrollFramePanel("info-panel")

  info_panel.clear()

  local model, block, recipe = self:getParameterObjects()

  if block ~= nil then
    if block.summary ~= nil then
      -- factories
      GuiElement.add(info_panel, GuiLabel("factories_label"):caption({"helmod_common.factories"}):style("helmod_label_title_frame"))
      local result_table = GuiElement.add(info_panel, GuiTable("table-factory"):column(4))
      result_table.style.horizontally_stretchable = false
      for _, element in pairs(block.summary.factories) do
        GuiElement.add(result_table, GuiCellElementM("HMFactories=OPEN", block.id):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end

      -- beacons
      GuiElement.add(info_panel, GuiLabel("beacons_label"):caption({"helmod_common.beacons"}):style("helmod_label_title_frame"))
      local result_table = GuiElement.add(info_panel, GuiTable("table-beacon"):column(4))
      result_table.style.horizontally_stretchable = false
      for _, element in pairs(block.summary.beacons) do
        GuiElement.add(result_table, GuiCellElementM("HMBeacons=OPEN", block.id):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end

      -- modules
      GuiElement.add(info_panel, GuiLabel("modules_label"):caption({"helmod_common.modules"}):style("helmod_label_title_frame"))
      local result_table = GuiElement.add(info_panel, GuiTable("table-modules"):column(4))
      result_table.style.horizontally_stretchable = false
      for _, element in pairs(block.summary.modules) do
        GuiElement.add(result_table, GuiCellElementM("HMModules=OPEN", block.id):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end
    end
  end
end
