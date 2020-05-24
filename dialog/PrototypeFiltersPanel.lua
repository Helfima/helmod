-------------------------------------------------------------------------------
-- Class to build PrototypeFiltersPanel panel
--
-- @module PrototypeFiltersPanel
-- @extends #Form
--

PrototypeFiltersPanel = newclass(Form,function(base,classname)
  Form.init(base,classname)
  base.add_special_button = true
end)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PrototypeFiltersPanel] onInit
--
function PrototypeFiltersPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-button-prototype-filters"})
  self.help_button = false
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#PrototypeFiltersPanel] getButtonSprites
--
-- @return boolean
--
function PrototypeFiltersPanel:getButtonSprites()
  return "filter-edit-white","filter-edit"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#PrototypeFiltersPanel] isVisible
--
-- @return boolean
--
function PrototypeFiltersPanel:isVisible()
  return Player.isAdmin()
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#PrototypeFiltersPanel] isSpecial
--
-- @return boolean
--
function PrototypeFiltersPanel:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#PrototypeFiltersPanel] getMenuPanel
--
function PrototypeFiltersPanel:getMenuPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "menu-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  panel.style.vertically_stretchable = true
  local width_main, height_main = GuiElement.getMainSizes()
  panel.style.minimal_height = 40
  panel.style.minimal_width = width_main
  return panel
end

-------------------------------------------------------------------------------
-- Get or create content panel
--
-- @function [parent=#PrototypeFiltersPanel] getContentPanel
--
function PrototypeFiltersPanel:getContentPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "data-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV(panel_name))
  panel.style.vertically_stretchable = true
  local width_main, height_main = GuiElement.getMainSizes()
  panel.style.minimal_height = height_main
  panel.style.minimal_width = width_main
  return panel
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PrototypeFiltersPanel] onEvent
--
-- @param #LuaEvent event
--
function PrototypeFiltersPanel:onEvent(event)
  local prototype_filter = User.getParameter("prototype_filter")
  local prototype_filters = User.getParameter("prototype_filters") or {}

  filter_types = PrototypeFilters.getTypes()
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)

  local index = tonumber(event.item1) or 0
  if index > 0 then
    prototype_filter = prototype_filters[index]
  end
  if event.action == "change-prototype-filter-type" then
    local selected_index = event.element.selected_index
    prototype_filter_type = filter_types[selected_index]
    User.setParameter("prototype_filter_type", prototype_filter_type)

    PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)
    local filters = PrototypeFilter:getFilters()
    prototype_filter.filter = filters[1]
    local options = PrototypeFilter:getOptions(prototype_filter.filter)
    prototype_filter.option = options[1] or nil

    User.setParameter("prototype_filters", {})

  end

  if event.action == "change-prototype-filter" then
    local selected_index = event.element.selected_index
    prototype_filter.filter = PrototypeFilter:getFilters()[selected_index]
    prototype_filter.option = PrototypeFilter:getOptions(prototype_filter.filter)[1] or nil
  end

  if event.action == "change-filter-option" then
    local selected_index = event.element.selected_index
    local options = PrototypeFilter:getOptions(prototype_filter.filter)
    prototype_filter.option = options[selected_index] or nil
  end

  if event.action == "change-filter-invert" then
    local selected_index = event.element.selected_index
    prototype_filter.invert = inverts[selected_index]
  end

  if event.action == "change-filter-mode" then
    local selected_index = event.element.selected_index
    prototype_filter.mode = modes[selected_index]
  end

  if event.action == "change-filter-option-comparison" then
    local selected_index = event.element.selected_index
    if prototype_filter.option == nil then prototype_filter.option = {value=0} end
    prototype_filter.option.comparison = comparisons[selected_index]
  end

  if event.action == "change-filter-option-value" then
    local text = event.element.text
    local value = tonumber(text)
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
    table.insert(prototype_filters, prototype_filter)
    User.setParameter("prototype_filters", prototype_filters)
    prototype_filter = nil
    self:updateData()
  end

  if event.action == "remove-prototype-filter" then
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

local modes = nil
local filter_types = nil
local inverts = nil
local comparisons = nil
local collision_mask = {}
local collision_mask_mode = {}
-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PrototypeFiltersPanel] onUpdate
--
-- @param #LuaEvent event
--
function PrototypeFiltersPanel:onUpdate(event)
  local content_panel = self:getContentPanel()
  content_panel.clear()

  -- prepare
  PrototypeFilters.initialization()
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
-- @function [parent=#PrototypeFiltersPanel] addHeaderFilter
--
-- @param #LuaGuiElement itable container for element
--
function PrototypeFiltersPanel:addHeaderFilter(itable)
  GuiElement.add(itable, GuiLabel("mode"):caption("Mode"))
  GuiElement.add(itable, GuiLabel("filter"):caption("Filter"))
  GuiElement.add(itable, GuiLabel("option"):caption("Option"))
  GuiElement.add(itable, GuiLabel("invert"):caption("Invert"))
  GuiElement.add(itable, GuiLabel("action"):caption("action"))
end

-------------------------------------------------------------------------------
-- Update row filter
--
-- @function [parent=#PrototypeFiltersPanel] addRowFilter
--
-- @param #LuaGuiElement itable container for element
--
function PrototypeFiltersPanel:addRowFilter(itable, prototype_filter, index)
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
  if options == "comparison" then
    local comparaison_cell = GuiElement.add(itable, GuiTable("comparison"):column(2))
    local comparison = "<"
    local comparison_value = ""
    if prototype_filter.option ~= nil then
      comparison = prototype_filter.option.comparison
      comparison_value = prototype_filter.option.value or 0
    end
    GuiElement.add(comparaison_cell, GuiDropDown(self.classname, "change-filter-option-comparison", index):items(comparisons, comparison))
    GuiElement.add(comparaison_cell, GuiTextField(self.classname, "change-filter-option-value", index):text(comparison_value))
  elseif prototype_filter.filter == "name" then
    local name_cell = GuiElement.add(itable, GuiTable("names"):column(2))
    local names_value = ""
    if prototype_filter.option ~= nil then
      names_value = prototype_filter.option or ""
    end
    GuiElement.add(name_cell, GuiTextField(self.classname, "change-filter-option-value", index):text(names_value))
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
-- @function [parent=#PrototypeFiltersPanel] updateFilter
--
function PrototypeFiltersPanel:updateFilter()
  -- data
  local content_panel = self:getContentPanel()
  -- type
  local type_table = GuiElement.add(content_panel, GuiTable("type-filter"):column(5))
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  GuiElement.add(type_table, GuiLabel("prototype"):caption("Type"))
  GuiElement.add(type_table, GuiDropDown(self.classname, "change-prototype-filter-type"):items(filter_types, prototype_filter_type))


  local resultTable = GuiElement.add(content_panel, GuiTable("table-filter"):column(5))

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
-- @function [parent=#PrototypeFiltersPanel] updateResult
--
function PrototypeFiltersPanel:updateResult()
  -- data
  local scrollPanel = self:getContentPanel()

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
    local elements = PrototypeFilter:getElements(filters)
    for key,element in pairs(elements) do
      GuiElement.add(elements_table, GuiButtonSprite("nothing"):sprite(prototype_filter_type, element.name):tooltip(element.localised_name))
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PrototypeFiltersPanel] onEvent
--
-- @param #LuaEvent event
--
function PrototypeFiltersPanel:onEvent(event)
  local prototype_filter = User.getParameter("prototype_filter")
  local prototype_filters = User.getParameter("prototype_filters") or {}

  filter_types = PrototypeFilters.getTypes()
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)

  local index = tonumber(event.item1) or 0
  if index > 0 then
    prototype_filter = prototype_filters[index]
  end
  if event.action == "change-prototype-filter-type" then
    local selected_index = event.element.selected_index
    prototype_filter_type = filter_types[selected_index]
    User.setParameter("prototype_filter_type", prototype_filter_type)

    PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)
    local filters = PrototypeFilter:getFilters()
    prototype_filter.filter = filters[1]
    local options = PrototypeFilter:getOptions(prototype_filter.filter)
    prototype_filter.option = options[1] or nil

    User.setParameter("prototype_filters", {})

  end

  if event.action == "change-prototype-filter" then
    local selected_index = event.element.selected_index
    prototype_filter.filter = PrototypeFilter:getFilters()[selected_index]
    prototype_filter.option = PrototypeFilter:getOptions(prototype_filter.filter)[1] or nil
  end

  if event.action == "change-filter-option" then
    local selected_index = event.element.selected_index
    local options = PrototypeFilter:getOptions(prototype_filter.filter)
    prototype_filter.option = options[selected_index] or nil
  end

  if event.action == "change-filter-invert" then
    local selected_index = event.element.selected_index
    prototype_filter.invert = inverts[selected_index]
  end

  if event.action == "change-filter-mode" then
    local selected_index = event.element.selected_index
    prototype_filter.mode = modes[selected_index]
  end

  if event.action == "change-filter-option-comparison" then
    local selected_index = event.element.selected_index
    if prototype_filter.option == nil then prototype_filter.option = {value=0} end
    prototype_filter.option.comparison = comparisons[selected_index]
  end

  if event.action == "change-filter-option-value" then
    local text = event.element.text
    if prototype_filter.filter == "name" then
      prototype_filter.option = text
    else
      local value = tonumber(text)
      if prototype_filter.option == nil then prototype_filter.option = {comparison="<"} end
      prototype_filter.option.value = value
    end
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
    table.insert(prototype_filters, prototype_filter)
    User.setParameter("prototype_filters", prototype_filters)
    prototype_filter = nil
    self:onUpdate()
  end

  if event.action == "remove-prototype-filter" then
    if #prototype_filters == 1 then
      prototype_filters = nil
    else
      table.remove(prototype_filters, index)
    end
    User.setParameter("prototype_filters", prototype_filters)
    self:onUpdate()
  end

  if prototype_filters ~= nil and index > 0 then
    prototype_filters[index] = prototype_filter
    User.setParameter("prototype_filters", prototype_filters)
    self:onUpdate()
  else
    User.setParameter("prototype_filter", prototype_filter)
    self:onUpdate()
  end
end
