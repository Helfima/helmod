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
-- Get Button Styles
--
-- @function [parent=#StatisticTab] getButtonStyles
--
-- @return boolean
--
function StatisticTab:getButtonStyles()
  return "helmod_button_icon_chart","helmod_button_icon_chart_selected"
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
  local element_panel = ElementGui.addGuiFrameV(scroll_panel, "resources", helmod_frame_style.section, ({"helmod_common.total"}))
  ElementGui.setStyle(element_panel, "data_section", "width")

  local column = 2*8

  local result_table = ElementGui.addGuiTable(scroll_panel,"list-data",column, "helmod_table-odd")
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
  EntityPrototype.load(element).native()
  
  ElementGui.addGuiLabel(guiTable, "value_"..element.name, Format.formatNumberElement(element.value), "helmod_label_right_60")
  ElementGui.addGuiButtonSprite(guiTable, "element_"..element.name.."=", Player.getIconType(element), element.name, element.name, Player.getLocalisedName(element))

end

