require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module PrototypeFiltersTab
-- @extends #AbstractTab
--

PrototypeFiltersTab = setclass("HMPrototypeFiltersTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#PrototypeFiltersTab] getButtonCaption
--
-- @return #string
--
function PrototypeFiltersTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-prototype-filters"}
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#PrototypeFiltersTab] isVisible
--
-- @return boolean
--
function PrototypeFiltersTab.methods:isVisible()
  return Player.getSettings("prototype_filters_tab", true)
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#PrototypeFiltersTab] hasIndexModel
--
-- @return #boolean
--
function PrototypeFiltersTab.methods:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#PrototypeFiltersTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function PrototypeFiltersTab.methods:addTableHeader(itable)
  Logging:debug(self:classname(), "addTableHeader():", itable)

  -- data columns
  self:addCellHeader(itable, "property", {"helmod_result-panel.col-header-name"})
  self:addCellHeader(itable, "chmod", {"helmod_result-panel.col-header-chmod"})
  self:addCellHeader(itable, "value", {"helmod_result-panel.col-header-value"})
end

-------------------------------------------------------------------------------
-- Add table row
--
-- @function [parent=#PrototypeFiltersTab] addTableRow
--
-- @param #LuaGuiElement gui_table container for element
-- @param #table property
--
function PrototypeFiltersTab.methods:addTableRow(gui_table, property)
  Logging:debug(self:classname(), "addTableRow():", gui_table, property)
  -- col property
  local cell_name = ElementGui.addGuiFrameH(gui_table,property.name.."_name", helmod_frame_style.hidden)
  ElementGui.addGuiLabel(cell_name, "label", property.name)

  -- col chmod
  local cell_chmod = ElementGui.addGuiFrameH(gui_table,property.name.."_chmod", helmod_frame_style.hidden)
  ElementGui.addGuiLabel(cell_chmod, "label", property.chmod or "")

  -- col value
  local cell_value = ElementGui.addGuiFrameH(gui_table,property.name.."_value", helmod_frame_style.hidden)
  local label_value = ElementGui.addGuiLabel(cell_value, "label", property.value, "helmod_label_max_600", nil, false)
  label_value.style.width = 600

end

local prototype_filter_types = nil
local prototype_filter_type = nil
local prototype_filters = nil
local prototype_filter = nil
local prototype_filter_options = nil
local prototype_filter_option = nil
local prototype_filter_inverts = {"True", "False"}
local prototype_filter_invert = "False"

local drop_down_prototype_filter_type = nil
local drop_down_prototype_filter = nil
local drop_down_filter_option = nil
local drop_down_filter_invert = nil

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#PrototypeFiltersTab] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PrototypeFiltersTab.methods:updateHeader(item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
  local resultPanel = self:getResultPanel({"helmod_result-panel.tab-title-prototype-filters"})
  local listPanel = ElementGui.addGuiFrameH(resultPanel, "list-element", helmod_frame_style.hidden)
end
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#PrototypeFiltersTab] updateData
--
function PrototypeFiltersTab.methods:updateData()
  Logging:debug(self:classname(), "updateData()")
  local globalGui = Player.getGlobalGui()
  -- data

  local scrollPanel = self:getResultScrollPanel()
  scrollPanel.clear()
  local resultTable = ElementGui.addGuiTable(scrollPanel,"table-filters",4)
  prototype_filter_types = PrototypeFilter.getTypes()
  prototype_filter_type = prototype_filter_type or prototype_filter_types[1]
  -- prototype filter
  ElementGui.addGuiLabel(resultTable, "prototype", "Prototype Filter")
  ElementGui.addGuiLabel(resultTable, "filter", "Filter")
  ElementGui.addGuiLabel(resultTable, "option", "Option")
  ElementGui.addGuiLabel(resultTable, "invert", "Invert")


  drop_down_prototype_filter_type = ElementGui.addGuiDropDown(resultTable, self:classname().."=change-prototype-filter-type", nil, prototype_filter_types, prototype_filter_type)

  if prototype_filter_type ~= nil then
    local filters = PrototypeFilter.getFilters(prototype_filter_type)
    prototype_filters = {}
    for key,options in spairs(filters,function(t,a,b) return b > a end) do
      table.insert(prototype_filters,key)
    end
    prototype_filter = prototype_filter or "type"
    Logging:debug(self:classname(),"prototype_filters", prototype_filters)
    drop_down_prototype_filter = ElementGui.addGuiDropDown(resultTable, self:classname().."=change-prototype-filter", nil, prototype_filters, prototype_filter)

    if filters[prototype_filter] ~= nil then
      prototype_filter_options = {}
      for key,options in spairs(filters[prototype_filter],function(t,a,b) return b > a end) do
        table.insert(prototype_filter_options,key)
      end
      if Model.countList(prototype_filter_options) > 0 then
        prototype_filter_option = prototype_filter_option or prototype_filter_options[1]
        drop_down_filter_option = ElementGui.addGuiDropDown(resultTable, self:classname().."=change-filter-option", nil, prototype_filter_options, prototype_filter_option)
      else
        ElementGui.addGuiLabel(resultTable, "option-none", "None")
      end
    else
      ElementGui.addGuiLabel(resultTable, "filter-none", "None")
      ElementGui.addGuiLabel(resultTable, "option-none", "None")
    end
  end

  if prototype_filter_type ~= nil and prototype_filter ~= nil then
    local elements_table = ElementGui.addGuiTable(scrollPanel,"table-elements",20)
    local filter = {filter=prototype_filter, invert=prototype_filter_invert == "True"}
    if prototype_filter_option ~= nil then
      filter[prototype_filter] = prototype_filter_option
    end
    Logging:debug(self:classname(),"filter", filter)
    local elements = PrototypeFilter.getElements(prototype_filter_type ,filter)
    for key,element in pairs(elements) do
      ElementGui.addGuiButtonSprite(elements_table, "nothing", prototype_filter_type, element.name, element.name, element.localised_name)
    end
  end

  drop_down_filter_invert = ElementGui.addGuiDropDown(resultTable, self:classname().."=change-filter-invert", nil, prototype_filter_inverts, prototype_filter_invert)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PrototypeFiltersTab] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PrototypeFiltersTab.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local globalPlayer = Player.getGlobal()
  if action == "change-prototype-filter-type" and drop_down_prototype_filter_type ~= nil then
    local index = drop_down_prototype_filter_type.selected_index
    Logging:debug(self:classname(), "--> change-prototype-filter-type", prototype_filter_types[index])
    prototype_filter_type = prototype_filter_types[index]
    prototype_filter = nil
    prototype_filter_option= nil
    self:updateData()
  end

  if action == "change-prototype-filter" and drop_down_prototype_filter ~= nil then
    local index = drop_down_prototype_filter.selected_index
    Logging:debug(self:classname(), "--> change-prototype-filter", prototype_filters[index])
    prototype_filter = prototype_filters[index]
    prototype_filter_option= nil
    self:updateData()
  end

  if action == "change-filter-option" and drop_down_filter_option ~= nil then
    local index = drop_down_filter_option.selected_index
    Logging:debug(self:classname(), "--> change-filter-option", prototype_filter_options[index])
    prototype_filter_option = prototype_filter_options[index]
    self:updateData()
  end

  if action == "change-filter-invert" and drop_down_filter_invert ~= nil then
    local index = drop_down_filter_invert.selected_index
    Logging:debug(self:classname(), "--> change-filter-invert", prototype_filter_inverts[index])
    prototype_filter_invert = prototype_filter_inverts[index]
    self:updateData()
  end
end
