require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module PrototypeFiltersTab
-- @extends #AbstractTab
--

PrototypeFiltersTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#PrototypeFiltersTab] getButtonCaption
--
-- @return #string
--
function PrototypeFiltersTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-prototype-filters"}
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#PrototypeFiltersTab] getButtonStyles
--
-- @return boolean
--
function PrototypeFiltersTab:getButtonStyles()
  return "helmod_button_icon_filter","helmod_button_icon_filter_selected"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#PrototypeFiltersTab] isVisible
--
-- @return boolean
--
function PrototypeFiltersTab:isVisible()
  return User.getModGlobalSetting("prototype_filters_tab")
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#PrototypeFiltersTab] isSpecial
--
-- @return boolean
--
function PrototypeFiltersTab:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#PrototypeFiltersTab] hasIndexModel
--
-- @return #boolean
--
function PrototypeFiltersTab:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#PrototypeFiltersTab] updateHeader
--
-- @param #LuaEvent event
--
function PrototypeFiltersTab:updateHeader(event)
  Logging:debug(self.classname, "updateHeader()", event)
  local resultPanel = self:getResultPanel({"helmod_result-panel.tab-title-prototype-filters"})
  local listPanel = ElementGui.addGuiFrameH(resultPanel, "list-element", helmod_frame_style.hidden)
end

local modes = nil
local filter_types = nil
local inverts = nil
local comparisons = nil

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#PrototypeFiltersTab] updateData
--
-- @param #LuaEvent event
--
function PrototypeFiltersTab:updateData(event)
  Logging:debug(self.classname, "updateData()", event)
  local scrollPanel = self:getResultScrollPanel()
  scrollPanel.clear()

  -- prepare
  PrototypeFilters.initialization()
  --Logging:debug(self.classname, "PrototypeFilters", PrototypeFilters)
  modes = PrototypeFilters.getModes()
  filter_types = PrototypeFilters.getTypes()
  inverts = PrototypeFilters.getInverts()
  comparisons = PrototypeFilters.getComparison()

  -- update
  self:updateFilter()
  self:updateResult()
end

-------------------------------------------------------------------------------
-- Update header filter
--
-- @function [parent=#PrototypeFiltersTab] addHeaderFilter
--
-- @param #LuaGuiElement itable container for element
--
function PrototypeFiltersTab:addHeaderFilter(itable)
  Logging:debug(self.classname, "addHeaderFilter()")
  ElementGui.addGuiLabel(itable, "mode", "Mode")
  ElementGui.addGuiLabel(itable, "filter", "Filter")
  ElementGui.addGuiLabel(itable, "option", "Option")
  ElementGui.addGuiLabel(itable, "invert", "Invert")
  ElementGui.addGuiLabel(itable, "action", "action")
end

-------------------------------------------------------------------------------
-- Update row filter
--
-- @function [parent=#PrototypeFiltersTab] addRowFilter
--
-- @param #LuaGuiElement itable container for element
--
function PrototypeFiltersTab:addRowFilter(itable, prototype_filter, index)
  Logging:debug(self.classname, "addRowFilter()",prototype_filter, index)
  index = index or 0
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)
  -- mode
  prototype_filter.mode = prototype_filter.mode or modes[1]
  ElementGui.addGuiDropDown(itable, self.classname.."=change-filter-mode=ID=", index, modes, prototype_filter.mode)
  -- filter
  local filters = PrototypeFilter:getFilters()
  prototype_filter.filter = prototype_filter.filter or filters[1]
  ElementGui.addGuiDropDown(itable, self.classname.."=change-prototype-filter=ID=", index, filters, prototype_filter.filter)

  local options = PrototypeFilter:getOptions(prototype_filter.filter)
  Logging:debug(self.classname, "options", options)
  if options == "comparison" then
      local comparaison_cell = ElementGui.addCell(itable, "comparison", 2, index)
      local comparison = "<"
      local comparison_value = ""
      if prototype_filter.option ~= nil then
        comparison = prototype_filter.option.comparison
        comparison_value = prototype_filter.option.value
      end
      Logging:debug(self.classname, "option", prototype_filter.option, comparison, comparison_value)
      ElementGui.addGuiDropDown(comparaison_cell, self.classname.."=change-filter-option-comparison=ID=", index, comparisons, comparison)
      ElementGui.addGuiText(comparaison_cell, self.classname.."=change-filter-option-value=ID="..index, comparison_value)
  elseif Model.countList(options) > 0 then
      prototype_filter.option = prototype_filter.option or options[1]
      ElementGui.addGuiDropDown(itable, self.classname.."=change-filter-option=ID=", index, options, prototype_filter.option)
  else
    ElementGui.addGuiLabel(itable, "option-none_"..index, "None")
  end

  prototype_filter.invert = prototype_filter.invert or inverts[1]
  ElementGui.addGuiDropDown(itable, self.classname.."=change-filter-invert=ID=", index, inverts, prototype_filter.invert)
  if index == 0 then
    ElementGui.addGuiButton(itable, self.classname.."=add-prototype-filter=ID=",index, nil, "+")
  else
    ElementGui.addGuiButton(itable, self.classname.."=remove-prototype-filter=ID=",index, nil, "-")
  end
end

-------------------------------------------------------------------------------
-- Update filter
--
-- @function [parent=#PrototypeFiltersTab] updateFilter
--
function PrototypeFiltersTab:updateFilter()
  Logging:debug(self.classname, "updateFilter()")
  -- data

  local scrollPanel = self:getResultScrollPanel()
  -- type
  local type_table = ElementGui.addGuiTable(scrollPanel,"type-filter",5)
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  ElementGui.addGuiLabel(type_table, "prototype", "Type")
  ElementGui.addGuiDropDown(type_table, self.classname.."=change-prototype-filter-type=ID=", nil, filter_types, prototype_filter_type)


  local resultTable = ElementGui.addGuiTable(scrollPanel,"table-filter",5)

  local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)

  local prototype_filter = User.getParameter("prototype_filter")
  if prototype_filter == nil then
    prototype_filter = {}
    prototype_filter.mode = modes[1]
    prototype_filter.filter = PrototypeFilter:getFilters()[1]
    prototype_filter.option = PrototypeFilter:getOptions(prototype_filter.filter)[1] or nil
    prototype_filter.invert = inverts[1]
    User.setParameter("prototype_filter", prototype_filter)
  end
  self:addRowFilter(resultTable, prototype_filter, 0)

end

-------------------------------------------------------------------------------
-- Update result
--
-- @function [parent=#PrototypeFiltersTab] updateResult
--
function PrototypeFiltersTab:updateResult()
  Logging:debug(self.classname, "updateResult()")
  -- data
  local scrollPanel = self:getResultScrollPanel()

  local resultTable = ElementGui.addGuiTable(scrollPanel,"table-filters",5)
  -- prototype filter
  self:addHeaderFilter(resultTable)

  local prototype_filters = User.getParameter("prototype_filters") or {}
  for index,filter in spairs(prototype_filters) do
    self:addRowFilter(resultTable, filter, index)
  end

  local prototype_filters = User.getParameter("prototype_filters") or {}


  if Model.countList(prototype_filters) > 0 then
    local elements_table = ElementGui.addGuiTable(scrollPanel,"table-elements",20)
    local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]

    local filters = {}
    for _,prototype_filter in pairs(prototype_filters) do
      local filter = {filter=prototype_filter.filter, invert=(prototype_filter.invert=="true"), mode= prototype_filter.mode}
      if prototype_filter.option ~= nil then
        if prototype_filter.option.comparison ~= nil then
          filter["comparison"] = prototype_filter.option.comparison
          filter["value"] = prototype_filter.option.value
        else
          filter[prototype_filter.filter] = prototype_filter.option
        end
      end
      table.insert(filters, filter)
    end

    local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)
    Logging:debug(self.classname,"result filters", filters)
    local elements = PrototypeFilter:getElements(filters)
    for key,element in pairs(elements) do
      ElementGui.addGuiButtonSprite(elements_table, "nothing", prototype_filter_type, element.name, element.name, element.localised_name)
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PrototypeFiltersTab] onEvent
--
-- @param #LuaEvent event
--
function PrototypeFiltersTab:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local prototype_filter = User.getParameter("prototype_filter")
  local prototype_filters = User.getParameter("prototype_filters") or {}

  Logging:debug(self.classname, "prototype_filter", prototype_filter)
  Logging:debug(self.classname, "prototype_filters", prototype_filters)
  filter_types = PrototypeFilters.getTypes()
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)

  local index = tonumber(event.item1) or 0
  if index > 0 then
    prototype_filter = prototype_filters[index]
  end
  if event.action == "change-prototype-filter-type" then
    local selected_index = event.element.selected_index
    Logging:debug(self.classname, "--> change-prototype-filter-type", filter_types[selected_index], selected_index, filter_types)
    prototype_filter_type = filter_types[selected_index]
    User.setParameter("prototype_filter_type", prototype_filter_type)

    PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)
    local filters = PrototypeFilter:getFilters()
    Logging:debug(self.classname, "--> filters", filters)
    prototype_filter.filter = filters[1]
    local options = PrototypeFilter:getOptions(prototype_filter.filter)
    Logging:debug(self.classname, "--> options", options)
    prototype_filter.option = options[1] or nil
    Logging:debug(self.classname, "--> prototype_filter", prototype_filter)

    User.setParameter("prototype_filters", {})

  end

  if event.action == "change-prototype-filter" then
    local selected_index = event.element.selected_index
    Logging:debug(self.classname, "--> change-prototype-filter", prototype_filters, selected_index)
    Logging:debug(self.classname, "--> change-prototype-filter", prototype_filters[selected_index])
    prototype_filter.filter = PrototypeFilter:getFilters()[selected_index]
    prototype_filter.option = PrototypeFilter:getOptions(prototype_filter.filter)[1] or nil
  end

  if event.action == "change-filter-option" then
    local selected_index = event.element.selected_index
    local options = PrototypeFilter:getOptions(prototype_filter.filter)
    Logging:debug(self.classname, "--> change-filter-option", options[selected_index])
    prototype_filter.option = options[selected_index] or nil
  end

  if event.action == "change-filter-invert" then
    local selected_index = event.element.selected_index
    Logging:debug(self.classname, "--> change-filter-invert", inverts[selected_index])
    prototype_filter.invert = inverts[selected_index]
  end

  if event.action == "change-filter-mode" then
    local selected_index = event.element.selected_index
    Logging:debug(self.classname, "--> change-filter-mode", modes[selected_index])
    prototype_filter.mode = modes[selected_index]
  end

  if event.action == "change-filter-option-comparison" then
    local selected_index = event.element.selected_index
    Logging:debug(self.classname, "--> change-filter-option-comparison", comparisons[selected_index])
    if prototype_filter.option == nil then prototype_filter.option = {value=0} end
    prototype_filter.option.comparison = comparisons[selected_index]
  end

  if event.action == "change-filter-option-value" then
    local text = event.element.text
    local value = tonumber(text)
    Logging:debug(self.classname, "--> change-filter-mode", value)
    if prototype_filter.option == nil then prototype_filter.option = {comparison="<"} end
    prototype_filter.option.value = value
  end

  if event.action == "add-prototype-filter" then
    Logging:debug(self.classname, "--> add-prototype-filter", prototype_filter)
    table.insert(prototype_filters, prototype_filter)
    User.setParameter("prototype_filters", prototype_filters)
    prototype_filter = nil
    self:updateData()
  end

  if event.action == "remove-prototype-filter" then
    Logging:debug(self.classname, "--> remove-prototype-filter", #prototype_filters, index)
    table.remove(prototype_filters, index)
    User.setParameter("prototype_filters", prototype_filters)
    self:updateData()
  end

  if index > 0 then
    prototype_filters[index] = prototype_filter
    User.setParameter("prototype_filters", prototype_filters)
    self:updateData()
  else
    User.setParameter("prototype_filter", prototype_filter)
    self:updateData()
  end
end
