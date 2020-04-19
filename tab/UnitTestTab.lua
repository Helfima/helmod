require "tab.AbstractTab"
local data = require "unit_test.Data"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module UnitTestTab
-- @extends #AbstractTab
--

UnitTestTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#UnitTestTab] getButtonCaption
--
-- @return #string
--
function UnitTestTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-unittest"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#UnitTestTab] getButtonSprites
--
-- @return boolean
--
function UnitTestTab:getButtonSprites()
  return "ok-white","ok"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#UnitTestTab] isVisible
--
-- @return boolean
--
function UnitTestTab:isVisible()
  return Player.isAdmin()
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#UnitTestTab] isSpecial
--
-- @return boolean
--
function UnitTestTab:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#UnitTestTab] hasIndexModel
--
-- @return #boolean
--
function UnitTestTab:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#UnitTestTab] getTabPane
--
function UnitTestTab:getTabPane()
  local content_panel = self:getResultPanel()
  local panel_name = "tab_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(panel_name))
  return panel
end

-------------------------------------------------------------------------------
-- Get or create energy tab panel
--
-- @function [parent=#UnitTestTab] getEnergyTab
--
function UnitTestTab:getEnergyTab()
  local content_panel = self:getTabPane()
  local panel_name = "energy-tab-panel"
  local scroll_name = "energy-scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_unittest.energy-title"}))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(helmod_frame_style.scroll_pane):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#UnitTestTab] updateData
--
function UnitTestTab:updateData()
  self:updateEnergy()
end

-------------------------------------------------------------------------------
-- Update energy
--
-- @function [parent=#UnitTestTab] updateEnergy
--
function UnitTestTab:updateEnergy()
  local tab_panel = self:getEnergyTab()
  
  for mod, mod_data in pairs(data.energy) do
    local mod_panel = GuiElement.add(tab_panel, GuiFlowV("mod", mod))
    GuiElement.add(mod_panel, GuiLabel("mod-label"):caption(mod):style("helmod_label_title_frame"))
    
    local table_panel = GuiElement.add(mod_panel, GuiTable("list-table"):column(22))
    table_panel.vertical_centering = false
    table_panel.style.horizontal_spacing = 10
    
    self:addEnergyListHeader(table_panel)

    for entity, test_data in pairs(mod_data) do
      self:addEnergyListRow(table_panel, entity, test_data)
    end
  end
end

-------------------------------------------------------------------------------
-- Add cell header with tooltip
--
-- @function [parent=#UnitTestTab] addCellHeaderTooltip
--
-- @param #LuaGuiElement guiTable
-- @param #string name
-- @param #string caption
-- @param #string sorted
--
function UnitTestTab:addCellHeaderTooltip(guiTable, name, caption, tooltip)
  local cell = GuiElement.add(guiTable, GuiFrameH("header", name):style(helmod_frame_style.hidden))
  GuiElement.add(cell, GuiLabel("label"):caption(caption):tooltip(tooltip))
end

-------------------------------------------------------------------------------
-- Add energy List header
--
-- @function [parent=#UnitTestTab] addEnergyListHeader
--
-- @param #LuaGuiElement itable container for element
--
function UnitTestTab:addEnergyListHeader(itable)
  -- col action
  self:addCellHeaderTooltip(itable, "entity", "Entity")
  -- data
  self:addCellHeaderTooltip(itable, "type", "Type")
  self:addCellHeaderTooltip(itable, "name", "Name")

  -- **** Attributes ***
  self:addCellHeaderTooltip(itable, "energy-usage-min", "EUmin", "Attribut Min Energy Usage")
  self:addCellHeaderTooltip(itable, "energy-usage-max", "EUmax", "Attribut Max Energy Usage")
  self:addCellHeaderTooltip(itable, "fluid-usage", "FU", "Attribut Fluid Usage /s")
  self:addCellHeaderTooltip(itable, "effectivity", "E", "Attribut Effectivity")
  self:addCellHeaderTooltip(itable, "target-temperature", "TT", "Attribut Target Temperature")
  self:addCellHeaderTooltip(itable, "maximum-temperature", "MT", "Attribut Maximum Temperature")
    -- **** Computed ***
  self:addCellHeaderTooltip(itable, "energy-type-input", "ETI", "Energy Type Input")
  self:addCellHeaderTooltip(itable, "energy-consumption", "EC", "Energy Consumption")
  self:addCellHeaderTooltip(itable, "fluid-consumption", "FC", "Fluid Consumption /s")
  self:addCellHeaderTooltip(itable, "fluid-fuel", "FF", "Fluid Fuel")
  self:addCellHeaderTooltip(itable, "fluid-capacity", "FJ", "Fluid Capacity J")
  self:addCellHeaderTooltip(itable, "water-consumption", "WC", "Water Consumption /s")
  self:addCellHeaderTooltip(itable, "steam-consumption", "SC", "Steam Consumption /s")
  self:addCellHeaderTooltip(itable, "energy-type-output", "ETO", "Energy Type Output")
  self:addCellHeaderTooltip(itable, "fluid-production", "FP", "Fluid Production /s")
  self:addCellHeaderTooltip(itable, "steam-production", "SP", "Steam Production /s")
  self:addCellHeaderTooltip(itable, "energy-production", "EP", "Energy Production")
  self:addCellHeaderTooltip(itable, "pollution", "P", "Pollution")
  self:addCellHeaderTooltip(itable, "speed", "S", "Speed")
end

-------------------------------------------------------------------------------
-- Add row energy List
--
-- @function [parent=#UnitTestTab] addEnergyListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function UnitTestTab:addEnergyListRow(gui_table, entity, test_data)
  local prototype = EntityPrototype(entity)
  local lua_prototype = prototype:native()
  if lua_prototype ~= nil then
    -- col Entity
    local button = GuiElement.add(gui_table, GuiButtonSelectSprite("entity", entity):choose("entity", lua_prototype.name))
    button.locked = true
    -- col Type
    GuiElement.add(gui_table, GuiLabel("type", entity):caption(lua_prototype.type))
    -- col Name
    GuiElement.add(gui_table, GuiLabel("name", entity):caption(lua_prototype.name))

    -- **** Attributes ***
    -- col Energy Usage Min
    local energy_usage_min = prototype:getMinEnergyUsage()
    local tag_color, tooltip = self:valueEquals(energy_usage_min, test_data.energy_usage_min, true)
    GuiElement.add(gui_table, GuiLabel("energy-usage-min", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_usage_min, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Energy Usage Max
    local energy_usage_max = prototype:getMaxEnergyUsage()
    local tag_color, tooltip = self:valueEquals(energy_usage_max, test_data.energy_usage_max, true)
    GuiElement.add(gui_table, GuiLabel("energy-usage-max", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_usage_max, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Fluid V /s
    local fluid_usage = math.floor(prototype:getFluidUsage())
    local tag_color, tooltip = self:valueEquals(fluid_usage, test_data.fluid_usage, true)
    GuiElement.add(gui_table, GuiLabel("fluid-usage", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_usage, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Effectivity
    local effectivity = prototype:getEffectivity()
    local tag_color, tooltip = self:valueEquals(effectivity, test_data.effectivity, true)
    GuiElement.add(gui_table, GuiLabel("effectivity", entity):caption({"", helmod_tag.font.default_bold, tag_color, effectivity, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Target Temperature
    local target_temperature = prototype:getTargetTemperature()
    local tag_color, tooltip = self:valueEquals(target_temperature, test_data.target_temperature, true)
    GuiElement.add(gui_table, GuiLabel("target-temperature", entity):caption({"", helmod_tag.font.default_bold, tag_color, target_temperature, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Maximum Temperature
    local maximum_temperature = prototype:getMaximumTemperature()
    local tag_color, tooltip = self:valueEquals(maximum_temperature, test_data.maximum_temperature, true)
    GuiElement.add(gui_table, GuiLabel("maximum-temperature", entity):caption({"", helmod_tag.font.default_bold, tag_color, maximum_temperature, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))

    -- **** Computed ***
    -- col Energy Type
    local energy_type_input = prototype:getEnergyTypeInput()
    local tag_color, tooltip = self:valueEquals(energy_type_input, test_data.energy_type_input)
    GuiElement.add(gui_table, GuiLabel("energy-type-input", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_type_input, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Energy Consumption
    local energy_consumption = math.floor(prototype:getEnergyConsumption())
    local tag_color, tooltip = self:valueEquals(energy_consumption, test_data.energy_consumption)
    GuiElement.add(gui_table, GuiLabel("energy-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_consumption, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Fluid Consumption /s
    local fluid_consumption = math.floor(prototype:getFluidConsumption())
    local tag_color, tooltip = self:valueEquals(fluid_consumption, test_data.fluid_consumption)
    GuiElement.add(gui_table, GuiLabel("fluid-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_consumption, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Fluid Fuel
    local fuel_prototype = prototype:getFluidUsagePrototype()
    local fluid_fuel = {name="none", capacity=0}
    if fuel_prototype ~= nil then 
      fluid_fuel = {name=fuel_prototype:native().name, capacity=fuel_prototype:getHeatCapacity()}
    end
    local tag_color, tooltip = self:valueEquals(fluid_fuel.name, test_data.fluid_fuel.name)
    GuiElement.add(gui_table, GuiLabel("fluid-fuel", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_fuel.name, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Fluid Capacity
    local tag_color, tooltip = self:valueEquals(fluid_fuel.capacity, test_data.fluid_fuel.capacity)
    GuiElement.add(gui_table, GuiLabel("fluid-capacity", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_fuel.capacity, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Water Consumption /s
    local water_consumption = math.floor(prototype:getWaterConsumption())
    local tag_color, tooltip = self:valueEquals(water_consumption, test_data.water_consumption)
    GuiElement.add(gui_table, GuiLabel("water-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, water_consumption, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Steam Consumption /s
    local steam_consumption = math.floor(prototype:getSteamConsumption())
    local tag_color, tooltip = self:valueEquals(steam_consumption, test_data.steam_consumption)
    GuiElement.add(gui_table, GuiLabel("steam-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, steam_consumption, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Energy Type Output
    local energy_type_output = prototype:getEnergyTypeOutput()
    local tag_color, tooltip = self:valueEquals(energy_type_output, test_data.energy_type_output)
    GuiElement.add(gui_table, GuiLabel("energy-type-output", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_type_output, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Fluid Production /s
    local fluid_production = math.floor(prototype:getFluidProduction())
    local tag_color, tooltip = self:valueEquals(fluid_production, test_data.fluid_production)
    GuiElement.add(gui_table, GuiLabel("fluid-production", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_production, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Steam Production /s
    local steam_production = math.floor(prototype:getSteamProduction())
    local tag_color, tooltip = self:valueEquals(steam_production, test_data.steam_production)
    GuiElement.add(gui_table, GuiLabel("steam-production", entity):caption({"", helmod_tag.font.default_bold, tag_color, steam_production, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Energy Production
    local energy_production = math.floor(prototype:getEnergyProduction())
    local tag_color, tooltip = self:valueEquals(energy_production, test_data.energy_production)
    GuiElement.add(gui_table, GuiLabel("energy-production", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_production, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Pollution
    local pollution = Format.round(prototype:getPollution() * 60, -2)
    local tag_color, tooltip = self:valueEquals(pollution, test_data.pollution)
    GuiElement.add(gui_table, GuiLabel("pollution", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumber(pollution), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col Speed
    local speed = prototype:speedFactory(test_data.recipe)
    local tag_color, tooltip = self:valueEquals(speed, test_data.speed)
    GuiElement.add(gui_table, GuiLabel("speed", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumber(speed), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
  end

end

function UnitTestTab:valueEquals(current_value, target_value, attribute)
  if current_value == target_value then
    local tag_color = helmod_tag.color.green_light
    if attribute then
      tag_color = helmod_tag.color.blue_light
    end
    local tooltip = {"","Success"}
    return tag_color, tooltip
  else
    local tag_color = helmod_tag.color.red_light
    if attribute then
      tag_color = helmod_tag.color.orange
    end
    local display_current = current_value
    if type(current_value) == "number" then
      display_current = Format.formatNumber(current_value)
    end
    local display_target = target_value
    if type(target_value) == "number" then
      display_target = Format.formatNumber(target_value)
    end
    local tooltip = {"",string.format("Failed, value %s must be %s", display_current, display_target)}
    return tag_color, tooltip
  end
end
