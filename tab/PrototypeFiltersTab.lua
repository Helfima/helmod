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
-- Get Button Sprites
--
-- @function [parent=#PrototypeFiltersTab] getButtonSprites
--
-- @return boolean
--
function PrototypeFiltersTab:getButtonSprites()
  return "filter-edit-white","filter-edit"
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
  local listPanel = GuiElement.add(resultPanel, GuiFrameH("list-element"):style(helmod_frame_style.hidden))
end

local modes = nil
local filter_types = nil
local inverts = nil
local comparisons = nil
local collision_mask = {}
local collision_mask_mode = {}

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
  collision_mask = PrototypeFilters.getCollisionMask()
  collision_mask_mode = PrototypeFilters.getCollisionMaskMode()
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
  GuiElement.add(itable, GuiLabel("mode"):caption("Mode"))
  GuiElement.add(itable, GuiLabel("filter"):caption("Filter"))
  GuiElement.add(itable, GuiLabel("option"):caption("Option"))
  GuiElement.add(itable, GuiLabel("invert"):caption("Invert"))
  GuiElement.add(itable, GuiLabel("action"):caption("action"))
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
  GuiElement.add(itable, GuiDropDown(self.classname, "change-filter-mode", index):items(modes, prototype_filter.mode))
  -- filter
  local filters = PrototypeFilter:getFilters()
  prototype_filter.filter = prototype_filter.filter or filters[1]
  GuiElement.add(itable, GuiDropDown(self.classname, "change-prototype-filter", index):items(filters, prototype_filter.filter))

  local options = PrototypeFilter:getOptions(prototype_filter.filter)
  Logging:debug(self.classname, "options", options)
  if options == "comparison" then
    local comparaison_cell = GuiElement.add(itable, GuiTable("comparison"):column(2))
    local comparison = "<"
    local comparison_value = ""
    if prototype_filter.option ~= nil then
      comparison = prototype_filter.option.comparison
      comparison_value = prototype_filter.option.value or 0
    end
    Logging:debug(self.classname, "option", prototype_filter.option, comparison, comparison_value)
    GuiElement.add(comparaison_cell, GuiDropDown(self.classname, "change-filter-option-comparison", index):items(comparisons, comparison))
    GuiElement.add(comparaison_cell, GuiTextField(self.classname, "change-filter-option-value", index):text(comparison_value))
  elseif prototype_filter.filter == "collision-mask" then
    local collision_mask_cell = GuiElement.add(itable, GuiTable("collision-mask"):column(2))
    local mask = collision_mask[1]
    local mask_mode = collision_mask_mode[1]
    if prototype_filter.option ~= nil then
        mask = prototype_filter.option.mask
        mask_mode = prototype_filter.option.mask_mode
    end
    GuiElement.add(collision_mask_cell, GuiDropDown(self.classname, "change-filter-option-collision-mask", index):items(collision_mask, mask))
    GuiElement.add(collision_mask_cell, GuiDropDown(self.classname, "change-filter-option-collision-mask-mode", index):items(collision_mask_mode, mask_mode))
  elseif Model.countList(options) > 0 then
    prototype_filter.option = prototype_filter.option or options[1]
    GuiElement.add(itable, GuiDropDown(self.classname, "change-filter-option", index):items(options, prototype_filter.option))
  else
    GuiElement.add(itable, GuiLabel("option-none", index):caption("None"))
  end

  prototype_filter.invert = prototype_filter.invert or inverts[1]
  GuiElement.add(itable, GuiDropDown(self.classname, "change-filter-invert", index):items(inverts, prototype_filter.invert))
  if index == 0 then
    GuiElement.add(itable, GuiButton(self.classname, "add-prototype-filter", index):caption("+"):style("helmod_button_small_bold"))
  else
    GuiElement.add(itable, GuiButton(self.classname, "remove-prototype-filter", index):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"))
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
  local type_table = GuiElement.add(scrollPanel, GuiTable("type-filter"):column(5))
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  GuiElement.add(type_table, GuiLabel("prototype"):caption("Type"))
  GuiElement.add(type_table, GuiDropDown(self.classname, "change-prototype-filter-type"):items(filter_types, prototype_filter_type))


  local resultTable = GuiElement.add(scrollPanel, GuiTable("table-filter"):column(5))

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

  local resultTable = GuiElement.add(scrollPanel, GuiTable("table-filters"):column(5))
  -- prototype filter
  self:addHeaderFilter(resultTable)

  local prototype_filters = User.getParameter("prototype_filters") or {}
  for index,filter in spairs(prototype_filters) do
    self:addRowFilter(resultTable, filter, index)
  end

  local prototype_filters = User.getParameter("prototype_filters") or {}


  if Model.countList(prototype_filters) > 0 then
    local elements_table = GuiElement.add(scrollPanel, GuiTable("table-elements"):column(20))
    local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]

    local filters = {}
    for _,prototype_filter in pairs(prototype_filters) do
      local filter = {filter=prototype_filter.filter, invert=(prototype_filter.invert=="true"), mode= prototype_filter.mode}
      if prototype_filter.option ~= nil then
        if prototype_filter.option.comparison ~= nil then
          filter["comparison"] = prototype_filter.option.comparison
          filter["value"] = prototype_filter.option.value
        elseif prototype_filter.option.mask ~= nil then
          filter["mask"] = prototype_filter.option.mask
          filter["mask_mode"] = prototype_filter.option.mask_mode
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
      GuiElement.add(elements_table, GuiButtonSprite("nothing"):sprite(prototype_filter_type, element.name):tooltip(element.localised_name))
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

  if event.action == "change-filter-option-collision-mask" then
    local selected_index = event.element.selected_index
    if prototype_filter.option == nil then prototype_filter.option = {mask_mode =collision_mask_mode[1]} end
    prototype_filter.option.mask = collision_mask[selected_index]
  end

  if event.action == "change-filter-option-collision-mask-mode" then
    local selected_index = event.element.selected_index
    if prototype_filter.option == nil then prototype_filter.option = {mask=collision_mask[1]} end
    prototype_filter.option.mask_mode = collision_mask_mode[selected_index]
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
    if #prototype_filters == 1 then
      prototype_filters = nil
    else
      table.remove(prototype_filters, index)
    end
    User.setParameter("prototype_filters", prototype_filters)
    self:updateData()
  end

  if prototype_filters ~= nil and index > 0 then
    prototype_filters[index] = prototype_filter
    User.setParameter("prototype_filters", prototype_filters)
    self:updateData()
  else
    User.setParameter("prototype_filter", prototype_filter)
    self:updateData()
  end
end
