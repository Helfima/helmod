require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module StatisticTab
-- @extends #AbstractTab
--

StatisticTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#StatisticTab] getButtonCaption
--
-- @return #string
--
function StatisticTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-statistic"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#StatisticTab] getButtonSprites
--
-- @return boolean
--
function StatisticTab:getButtonSprites()
  return "chart-white","chart"
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#StatisticTab] updateData
--
-- @param #LuaEvent event
--
function StatisticTab:updateData(event)
  Logging:debug(self.classname, "updateSummary()", event)
  local model = Model.getModel()
  -- data
  local scroll_panel = self:getResultScrollPanel({"helmod_result-panel.tab-title-statistic"})
  
  -- resources
  local element_panel = GuiElement.add(scroll_panel, GuiFrameV("resources"):style(helmod_frame_style.section):tooltip({"helmod_common.total"}))
  GuiElement.setStyle(element_panel, "data_section", "width")

  local column = 2*8

  local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(column):style("helmod_table-odd"))
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
    self:addElementRow(result_table, element)
  end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#StatisticTab] addElementRow
--
-- @param #LuaGuiElement guiTable
-- @param #table element
--
function StatisticTab:addElementRow(guiTable, element)
  Logging:debug(self.classname, "addProductionBlockRow()", guiTable, element)
  GuiElement.add(guiTable, GuiLabel("value", element.name):caption(Format.formatNumberElement(element.value)):style("helmod_label_right_60"))
  GuiElement.add(guiTable, GuiButtonSprite("element", element.name):sprite(element.type, element.name):tooltip(Player.getLocalisedName(element)))
end

