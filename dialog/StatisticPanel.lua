-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module StatisticPanel
-- @extends #Form
--

StatisticPanel = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#StatisticPanel] onInit
--
function StatisticPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-button-statistic"})
end

------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#StatisticPanel] getButtonSprites
--
-- @return boolean
--
function StatisticPanel:getButtonSprites()
  return "chart-white","chart"
end

-------------------------------------------------------------------------------
-- Is tool
--
-- @function [parent=#StatisticPanel] isTool
--
-- @return boolean
--
function StatisticPanel:isTool()
  return true
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#StatisticPanel] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function StatisticPanel:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 322,
    maximal_height = height_main
  }
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#StatisticPanel] onUpdate
--
-- @param #LuaEvent event
--
function StatisticPanel:onUpdate(event)
  self:updateInfo(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#StatisticPanel] updateInfo
--
-- @param #LuaEvent event
--
function StatisticPanel:updateInfo(event)
  local info_panel = self:getFramePanel("info_panel")
  info_panel.style.vertically_stretchable = true
  info_panel.clear()

  local column = 20

  local resultTable = GuiElement.add(info_panel, GuiTable("list-data"):column(column))
  --self:addProductionBlockHeader(resultTable)
  local elements = {}
  
  table.insert(elements, {name = "locomotive", type = "entity", value = #Player.getForce().get_trains()})
  
  local entities = {"logistic-robot", "construction-robot", "straight-rail", "curved-rail", "electric-furnace",
                    "assembling-machine-3", "chemical-plant", "oil-refinery", "beacon", "lab", "electric-mining-drill",
                    "express-transport-belt", "express-underground-belt", "express-splitter"
                    , "medium-electric-pole", "big-electric-pole"}
  for _, element in pairs(entities) do
    table.insert(elements, {name = element, type = "entity", value = Player.getForce().get_entity_count(element)})
  end
  
  for _, element in pairs(elements) do
    self:addRow(resultTable, element)
  end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#StatisticPanel] addRow
--
-- @param #LuaGuiElement guiTable
-- @param #table element
--
function StatisticPanel:addRow(guiTable, element)
  GuiElement.add(guiTable, GuiLabel("value", element.name):caption(Format.formatNumberElement(element.value)):style("helmod_label_right_60"))
  GuiElement.add(guiTable, GuiButtonSprite("element", element.name):sprite(element.type, element.name):tooltip(Player.getLocalisedName(element)))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#StatisticPanel] onEvent
--
-- @param #LuaEvent event
--
function StatisticPanel:onEvent(event)
end
