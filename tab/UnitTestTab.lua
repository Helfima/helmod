require "tab.AbstractTab"
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

local data = {}
data.energy = {}
data.energy["base"] = {}
data.energy["base"]["offshore-pump"] = {energy_type="none", max_power=0, fluid_consumption=0, pollution=0}
data.energy["base"]["assembling-machine-1"] = {energy_type="electric", max_power=77500, fluid_consumption=0, pollution=4}
data.energy["base"]["assembling-machine-2"] = {energy_type="electric", max_power=155000, fluid_consumption=0, pollution=3}
data.energy["base"]["assembling-machine-3"] = {energy_type="electric", max_power=387500, fluid_consumption=0, pollution=2}
data.energy["base"]["boiler"] = {energy_type="burner", max_power=1800000, fluid_consumption=0, pollution=30}
data.energy["base"]["steam-engine"] = {energy_type="electric", max_power=900000, fluid_consumption=0, pollution=0}
data.energy["base"]["heat-exchanger"] = {energy_type="heat", max_power=10000000, fluid_consumption=0, pollution=0}
data.energy["base"]["steam-turbine"] = {energy_type="electric", max_power=5820000, fluid_consumption=0, pollution=0}
data.energy["base"]["nuclear-reactor"] = {energy_type="burner", max_power=40000000, fluid_consumption=0, pollution=0}


data.energy["pyanodons"] = {}
data.energy["pyanodons"]["glassworks-mk01"] = {energy_type="fluid", max_power=27000000, fluid_consumption=0, pollution=10}
data.energy["pyanodons"]["glassworks-mk02"] = {energy_type="fluid", max_power=33000000, fluid_consumption=0, pollution=10}
data.energy["pyanodons"]["glassworks-mk03"] = {energy_type="fluid", max_power=41000000, fluid_consumption=0, pollution=10}
data.energy["pyanodons"]["glassworks-mk04"] = {energy_type="fluid", max_power=48000000, fluid_consumption=0, pollution=10}
data.energy["pyanodons"]["oil-boiler-mk01"] = {energy_type="fluid", max_power=1800000, fluid_consumption=60, pollution=30}
 
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
    
    local table_panel = GuiElement.add(mod_panel, GuiTable("list-table"):column(7))
    table_panel.vertical_centering = false
    table_panel.style.horizontal_spacing = 50
    
    self:addEnergyListHeader(table_panel)

    for entity, test_data in pairs(mod_data) do
      self:addEnergyListRow(table_panel, entity, test_data)
    end
  end
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
  self:addCellHeader(itable, "header-entity", "Entity")
  -- data
  self:addCellHeader(itable, "header-type", "Type")
  self:addCellHeader(itable, "header-name", "Name")
  self:addCellHeader(itable, "header-energy-type", "Energy Type")
  self:addCellHeader(itable, "header-power", "Max Power")
  self:addCellHeader(itable, "header-fluid-consumption", "Fluid Consumption /s")
  self:addCellHeader(itable, "header-pollution", "Pollution")
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
    -- col entity
    local button = GuiElement.add(gui_table, GuiButtonSelectSprite("entity", entity):choose("entity", lua_prototype.name))
    button.locked = true
    -- col type
    GuiElement.add(gui_table, GuiLabel("type", entity):caption(lua_prototype.type))
    -- col name
    GuiElement.add(gui_table, GuiLabel("name", entity):caption(lua_prototype.name))
    -- col name
    local energy_type = prototype:getEnergyType()
    local tag_color, tooltip = self:valueEquals(energy_type, test_data.energy_type)
    GuiElement.add(gui_table, GuiLabel("energy-type", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_type, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col power
    local max_power = prototype:getEnergyConsumption()
    local tag_color, tooltip = self:valueEquals(max_power, test_data.max_power)
    GuiElement.add(gui_table, GuiLabel("power", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(max_power, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col fluid consumption
    local fluid_consumption = 0
    if energy_type == "fluid" then
      fluid_consumption = math.floor(prototype:getFluidConsumption())
    end
    local tag_color, tooltip = self:valueEquals(fluid_consumption, test_data.fluid_consumption)
    GuiElement.add(gui_table, GuiLabel("fluid-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_consumption, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    -- col pollution
    local pollution = math.floor(prototype:getPollution() * 60)
    local tag_color, tooltip = self:valueEquals(pollution, test_data.pollution)
    GuiElement.add(gui_table, GuiLabel("pollution", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumber(pollution), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
  end

end

function UnitTestTab:valueEquals(current_value, target_value)
  if current_value == target_value then
    local tag_color = helmod_tag.color.green_light
    local tooltip = {"","Success"}
    return tag_color, tooltip
  else
    local tag_color = helmod_tag.color.red_light
    local tooltip = {"",string.format("Failed, value %s must be %s", current_value, target_value)}
    return tag_color, tooltip
  end
end
