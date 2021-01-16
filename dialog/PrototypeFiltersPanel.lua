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

local modes = nil
local filter_types = nil
local inverts = nil
local comparisons = nil
local collision_mask = {}
local collision_mask_mode = {}
local samples = {}
local sample = {name="list of production machines", type="entity", value={}}
table.insert(sample.value, { mode="and", filter="crafting-machine", invert="false"})
table.insert(sample.value, { mode="and", filter="hidden", invert="true"})
table.insert(sample.value, { mode="or", filter="type", invert="false", option="lab"})
table.insert(sample.value, { mode="or", filter="type", invert="false", option="mining-drill"})
table.insert(sample.value, { mode="or", filter="type", invert="false", option="rocket-silo"})
table.insert(samples, sample)

sample = {name="list of beacons", type="entity", value={}}
table.insert(sample.value, { mode="and", filter="type", invert="false", option="beacon"})
table.insert(sample.value, { mode="and", filter="hidden", invert="true"})
table.insert(samples, sample)

sample = {name="list of offshore-pumps", type="entity", value={}}
table.insert(sample.value, { mode="and", filter="type", invert="false", option="offshore-pump"})
table.insert(sample.value, { mode="and", filter="hidden", invert="true"})
table.insert(samples, sample)

sample = {name="list of modules", type="item", value={}}
table.insert(sample.value, { mode="and", filter="type", invert="false", option="module"})
table.insert(sample.value, { mode="and", filter="flag", invert="true", option="hidden"})
table.insert(samples, sample)

sample = {name="list of power machines", type="entity", value={}}
for _,type in pairs({"generator", "solar-panel", "boiler", "accumulator", "reactor", "offshore-pump", "seafloor-pump"}) do
  table.insert(sample.value, { mode="or", filter="type", invert="false", option=type})
end
table.insert(samples, sample)

sample = {name="list of fuels", type="item", value={}}
table.insert(sample.value, { mode="or", filter="fuel-value", invert="false", option={value=0,comparison=">"}})
table.insert(samples, sample)

sample = {name="Item logistic list of inserters", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="inserter"})
table.insert(samples, sample)

sample = {name="Item logistic list of belts", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="transport-belt"})
table.insert(samples, sample)

sample = {name="Item logistic list of containers", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="container"})
table.insert(sample.value, { mode="and", filter="minable", invert="false", option=nil})
table.insert(sample.value, { mode="or", filter="type", invert="false", option="logistic-container"})
table.insert(sample.value, { mode="and", filter="minable", invert="false", option=nil})
table.insert(samples, sample)

sample = {name="Item logistic list of transports", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="cargo-wagon"})
table.insert(sample.value, { mode="or", filter="type", invert="false", option="logistic-robot"})
table.insert(sample.value, { mode="or", filter="type", invert="false", option="car"})
table.insert(samples, sample)

sample = {name="Fluid logistic list of pipes", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="pipe"})
table.insert(samples, sample)

sample = {name="Fluid logistic list of containers", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="storage-tank"})
table.insert(sample.value, { mode="and", filter="minable", invert="false", option=nil})
table.insert(samples, sample)

sample = {name="Fluid logistic list of transports", type="entity", value={}}
table.insert(sample.value, { mode="or", filter="type", invert="false", option="fluid-wagon"})
table.insert(samples, sample)

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
  return User.getModGlobalSetting("hidden_panels")
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
  local width_main, height_main = User.getMainSizes()
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
  local width_main, height_main = User.getMainSizes()
  panel.style.minimal_height = height_main-300
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

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PrototypeFiltersPanel] onUpdate
--
-- @param #LuaEvent event
--
function PrototypeFiltersPanel:onUpdate(event)
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
  GuiElement.add(itable, GuiLabel("invert"):caption("Invert"))
  GuiElement.add(itable, GuiLabel("filter"):caption("Filter"))
  GuiElement.add(itable, GuiLabel("option"):caption("Option"))
  GuiElement.add(itable, GuiLabel("result"):caption("String"))
  GuiElement.add(itable, GuiLabel("action"):caption("Action"))
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
  -- type col
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  local PrototypeFilter = PrototypeFilters.getFilterType(prototype_filter_type)
  -- mode col
  prototype_filter.mode = prototype_filter.mode or modes[1]
  local button_mode = GuiElement.add(itable, GuiDropDown(self.classname, "change-filter-mode", index):items(modes, prototype_filter.mode))
  button_mode.style.width = 80
  -- invert col
  prototype_filter.invert = prototype_filter.invert or inverts[1]
  local button_invert = GuiElement.add(itable, GuiDropDown(self.classname, "change-filter-invert", index):items(inverts, prototype_filter.invert))
  button_invert.style.width = 80
  -- filter col
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
  elseif table.size(options) > 0 then
    prototype_filter.option = prototype_filter.option or options[1]
    GuiElement.add(itable, GuiDropDown(self.classname, "change-filter-option", index):items(options, prototype_filter.option))
  else
    GuiElement.add(itable, GuiLabel("option-none", index):caption("None"))
  end
  -- result col
  local filter_value = PrototypeFiltersPanel:convertFilter(prototype_filter)
  local string_value = PrototypeFiltersPanel:tableToString(filter_value)
  local text_field = GuiElement.add(itable, GuiTextField(self.classname, "change-textfield", index):text(string_value))
  text_field.style.width = 400
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
  local content_panel = self:getMenuPanel()
  content_panel.clear()
  -- type
  local choose_panel = GuiElement.add(content_panel, GuiFlowH("choose-filter"))
  choose_panel.style.horizontal_spacing = 5
  local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]
  GuiElement.add(choose_panel, GuiLabel("prototype"):caption("Type"))
  GuiElement.add(choose_panel, GuiDropDown(self.classname, "change-prototype-filter-type"):items(filter_types, prototype_filter_type))
  GuiElement.add(choose_panel, GuiLabel("sample"):caption("Sample"))
  local items = {}
  table.insert(items, "Choose a sample")
  for _,sample in pairs(samples) do
    table.insert(items, sample.name)
  end
  GuiElement.add(choose_panel, GuiDropDown(self.classname, "choose-sample"):items(items))


  local resultTable = GuiElement.add(content_panel, GuiTable("table-filter"):column(6))
  self:addHeaderFilter(resultTable)

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
function PrototypeFiltersPanel:convertFilter(prototype_filter)
  local filter = {mode= prototype_filter.mode, invert=(prototype_filter.invert=="true"), filter=prototype_filter.filter  }
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
    return filter
end

-------------------------------------------------------------------------------
-- Table to string
--
-- @function [parent=#PrototypeFiltersPanel] tableToString
--
-- @param #table value
--
function PrototypeFiltersPanel:tableToString(value)
  local string_value = serpent.line(value)
  string_value = string.gsub(string_value, "},", "},\n")
  return string_value
end

-------------------------------------------------------------------------------
-- Update result
--
-- @function [parent=#PrototypeFiltersPanel] updateResult
--
function PrototypeFiltersPanel:updateResult()
  -- data
  local content_panel = self:getContentPanel()
  content_panel.clear()
  GuiElement.add(content_panel, GuiLabel("data-label"):caption({"helmod_common.filter"}):style("helmod_label_title_frame"))

  local prototype_filters = User.getParameter("prototype_filters") or {}

  if table.size(prototype_filters) > 0 then
    local resultTable = GuiElement.add(content_panel, GuiTable("table-filters"):column(6))
    -- prototype filter
    self:addHeaderFilter(resultTable)

    for index,filter in spairs(prototype_filters) do
      self:addRowFilter(resultTable, filter, index)
    end

    local data_panel = GuiElement.add(content_panel, GuiFlowH("data"))
    -- elements list

    local filters = {}
    for _,prototype_filter in pairs(prototype_filters) do
      local filter = PrototypeFiltersPanel:convertFilter(prototype_filter)
      table.insert(filters, filter)
    end

    -- text filter
    local string_data = PrototypeFiltersPanel:tableToString(filters)
    local text_box = GuiElement.add(data_panel, GuiTextBox("string-data"):text(string_data))
    text_box.read_only=true
    text_box.style.width = 400
    text_box.style.height = 300

    -- result filter
    local elements_table = GuiElement.add(data_panel, GuiTable("table-elements"):column(20))
    local prototype_filter_type = User.getParameter("prototype_filter_type") or filter_types[1]

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

  if event.action == "choose-sample" then
    local selected_index = event.element.selected_index - 1
    if selected_index > 0 and samples[selected_index] ~= nil then
      local sample = samples[selected_index]
      User.setParameter("prototype_filter_type", sample.type)
      User.setParameter("prototype_filters", sample.value)
      self:onUpdate()
    end
    return
  end

  if event.action == "add-prototype-filter" then
    table.insert(prototype_filters, table.deepcopy(prototype_filter))
    User.setParameter("prototype_filters", prototype_filters)
    self:onUpdate()
    return
  end

  if event.action == "remove-prototype-filter" then
    if #prototype_filters == 1 then
      prototype_filters = nil
    else
      table.remove(prototype_filters, index)
    end
    User.setParameter("prototype_filters", prototype_filters)
    self:onUpdate()
    return
  end

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

  if prototype_filters ~= nil and index > 0 then
    prototype_filters[index] = prototype_filter
    User.setParameter("prototype_filters", prototype_filters)
    self:onUpdate()
  else
    User.setParameter("prototype_filter", prototype_filter)
    self:onUpdate()
  end
end
