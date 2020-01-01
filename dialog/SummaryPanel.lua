-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module SummaryPanel
-- @extends #Form
--

SummaryPanel = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#SummaryPanel] onInit
--
function SummaryPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-title-summary"})
  self.otherClose = false
  self.parameterLast = string.format("%s_%s",self.classname,"last")
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
-- On before event
--
-- @function [parent=#SummaryPanel] onBeforeOpen
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function SummaryPanel:onBeforeOpen(event)
  Logging:debug(self.classname, "onBeforeEvent()", event)
  local close = (event.action == "OPEN") -- only on open event
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) then
    close = false
  end
  User.setParameter(self.parameterLast, event.item1)
  User.setParameter("summary_block_id", event.item1)
  return close
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#SummaryPanel] getInfoPanel
--
function SummaryPanel:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info-panel"] ~= nil and content_panel["info-panel"].valid then
    return content_panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = GuiElement.add(content_panel, GuiFrameV("info-panel"):style(helmod_frame_style.panel))
  mainPanel.style.horizontally_stretchable = true
  local scroll_panel = GuiElement.add(mainPanel, GuiScroll("scroll-panel"))
  return  scroll_panel
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
  Logging:debug(self.classname, "updateInfo()", event)
  local infoPanel = self:getInfoPanel()
  local model = Model.getModel()
  local summary_block_id = User.getParameter("summary_block_id")
  local order = User.getParameter("order")

  infoPanel.clear()

  if summary_block_id ~= nil and model.blocks[summary_block_id] ~= nil then
    local block = model.blocks[summary_block_id]

    
    if block.summary ~= nil then
      -- factories
      GuiElement.add(infoPanel, GuiLabel("factories_label"):caption({"helmod_common.factories"}):style("helmod_label_title_frame"))
      local resultTable = GuiElement.add(infoPanel, GuiTable("table-factory"):column(4))
      resultTable.style.horizontally_stretchable = false
      for _, element in pairs(block.summary.factories) do
        GuiElement.add(resultTable, GuiCellElementM("HMFactories=OPEN=ID", block.id):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end

      -- beacons
      GuiElement.add(infoPanel, GuiLabel("beacons_label"):caption({"helmod_common.beacons"}):style("helmod_label_title_frame"))
      local resultTable = GuiElement.add(infoPanel, GuiTable("table-beacon"):column(4))
      resultTable.style.horizontally_stretchable = false
      for _, element in pairs(block.summary.beacons) do
        GuiElement.add(resultTable, GuiCellElementM("HMBeacons=OPEN=ID", block.id):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end

      -- modules
      GuiElement.add(infoPanel, GuiLabel("modules_label"):caption({"helmod_common.modules"}):style("helmod_label_title_frame"))
      local resultTable = GuiElement.add(infoPanel, GuiTable("table-modules"):column(4))
      resultTable.style.horizontally_stretchable = false
      for _, element in pairs(block.summary.modules) do
        GuiElement.add(resultTable, GuiCellElementM("HMModules=OPEN=ID", block.id):element(element):color(GuiElement.color_button_default):tooltip("tooltip.info-factory"))
      end
    end
  end
end
