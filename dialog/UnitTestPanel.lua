-------------------------------------------------------------------------------
---Class to build UnitTestPanel panel
---@class UnitTestPanel
UnitTestPanel = newclass(Form,function(base,classname)
  Form.init(base,classname)
  base.add_special_button = true
end)

local data = require "unit_test.Data"
local data_pyanodons = require "unit_test.DataPyanodons"
local data_bob_angel = require "unit_test.DataBobAngel"
local data_krastorio2 = require "unit_test.DataKrastorio2"
local data_space_ecploration = require "unit_test.DataSpaceExploration"
-------------------------------------------------------------------------------
---On initialization
function UnitTestPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-button-unittest"})
  self.help_button = false
end

-------------------------------------------------------------------------------
---Get Button Sprites
---@return boolean
function UnitTestPanel:getButtonSprites()
  return defines.sprites.database_test.white,defines.sprites.database_test.black
end

-------------------------------------------------------------------------------
---Is visible
---@return boolean
function UnitTestPanel:isVisible()
  return User.getModGlobalSetting("hidden_panels")
end

-------------------------------------------------------------------------------
---Is special
---@return boolean
function UnitTestPanel:isSpecial()
  return true
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement
function UnitTestPanel:getTabPane()
  local content_panel = self:getFrameDeepPanel("panel")
  local panel_name = "tab_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(panel_name))
  return panel
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement
function UnitTestPanel:getTab(panel_name, caption)
  local content_panel = self:getTabPane()
  local scroll_name = "scroll-" .. panel_name
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption(caption))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create energy tab panel
---@return LuaGuiElement
function UnitTestPanel:getEnergyTab()
  return self:getTab("energy-tab-panel", {"helmod_unittest.energy-title"})
end

-------------------------------------------------------------------------------
---Get or create sprite tab panel
---@return LuaGuiElement
function UnitTestPanel:getSpriteTab()
  return self:getTab("sprite-tab-panel", {"helmod_unittest.sprite-title"})
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function UnitTestPanel:onEvent(event)
  if not(User.isAdmin()) then return end
  if event.action == "reload-script" then
    game.reload_script()
    Controller:send("on_gui_update", event)
  end
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function UnitTestPanel:onUpdate(event)
  if game.active_mods["boblibrary"] then
    data = data_bob_angel
  end
  if game.active_mods["pyrawores"] then
    data = data_pyanodons
  end
  if game.active_mods["Krastorio2"] then
    data = data_krastorio2
  end
  if game.active_mods["space-exploration"] then
    data = data_space_ecploration
  end
  self:updateMenu()
  self:updateEnergy()
  self:updateSprite()
end

-------------------------------------------------------------------------------
---Update menu
function UnitTestPanel:updateMenu()
  local menu_panel = self:getMenuPanel()
  ---pin info
  local group1 = GuiElement.add(menu_panel, GuiFlowH("group1"))
  GuiElement.add(group1, GuiButton("HMUnitTestPanel", "reload-script"):sprite("menu", defines.sprites.refresh.black, defines.sprites.refresh.black):style("helmod_button_menu"):tooltip("Reload script"))
end

-------------------------------------------------------------------------------
---Update energy
function UnitTestPanel:updateSprite()
  local tab_panel = self:getSpriteTab()
  local table_panel = GuiElement.add(tab_panel, GuiTable("list-table"):column(2))
  for sprite_name, sprites in pairs(defines.sprites) do
    local col1 = GuiElement.add(table_panel, GuiFrameH("info", sprite_name):style(helmod_frame_style.hidden))
    GuiElement.add(col1, GuiLabel("label"):caption(sprite_name))
    local col2 = GuiElement.add(table_panel, GuiFrameH("buttons", sprite_name):style(helmod_frame_style.hidden))
    for color_name, sprite in pairs(sprites) do
      GuiElement.add(col2, GuiButton("do_noting", sprite_name, color_name):sprite("menu", sprite, sprite):style("helmod_button_menu"):tooltip(string.format("defines.sprites.%s.%s", sprite_name, color_name)))
    end
  end
end

-------------------------------------------------------------------------------
---Update energy
function UnitTestPanel:updateEnergy()
  local tab_panel = self:getEnergyTab()
  GuiElement.add(tab_panel, GuiLabel("label"):caption(data.mod):style("heading_1_label"))

  local table_panel = GuiElement.add(tab_panel, GuiTable("list-table"):column(23))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 10
  
  self:addEnergyListHeader(table_panel)

  for entity, test_data in spairs(data.energy, function(t,a,b) return t[b]["energy_type_input"] < t[a]["energy_type_input"] end) do
    self:addEnergyListRow(table_panel, entity, test_data)
  end
end

-------------------------------------------------------------------------------
---Add cell header with tooltip
---@param itable LuaGuiElement
---@param name string
---@param caption string
---@param tooltip table
function UnitTestPanel:addCellHeaderTooltip(itable, name, caption, tooltip)
  local cell = GuiElement.add(itable, GuiFrameH("header", name):style(helmod_frame_style.hidden))
  GuiElement.add(cell, GuiLabel("label"):caption(caption):tooltip(tooltip))
end

-------------------------------------------------------------------------------
---Add energy List header
---@param itable LuaGuiElement
function UnitTestPanel:addEnergyListHeader(itable)
  ---col action
  self:addCellHeaderTooltip(itable, "entity", "Entity")
  ---data
  self:addCellHeaderTooltip(itable, "type", "Type")
  self:addCellHeaderTooltip(itable, "name", "Name")

  ---**** Attributes ***
  self:addCellHeaderTooltip(itable, "energy-type", "ET", "Energy Type")
  self:addCellHeaderTooltip(itable, "energy-usage-min", "EUmin", "Min Energy Usage")
  self:addCellHeaderTooltip(itable, "energy-usage-max", "EUmax", "Max Energy Usage")
  self:addCellHeaderTooltip(itable, "energy-usage-priority", "EUP", "Energy Usage Priority")
  self:addCellHeaderTooltip(itable, "fluid-usage", "FU", "Fluid Usage /s")
  self:addCellHeaderTooltip(itable, "fluid-burns", "FB", "Fluid Burns")
  self:addCellHeaderTooltip(itable, "effectivity", "E", "Effectivity")
  self:addCellHeaderTooltip(itable, "target-temperature", "TT", "Target Temperature")
  self:addCellHeaderTooltip(itable, "maximum-temperature", "MT", "Maximum Temperature")
    ---**** Computed ***
  self:addCellHeaderTooltip(itable, "energy-type-input", "ETI", "Energy Type Input")
  self:addCellHeaderTooltip(itable, "energy-consumption", "EC", "Energy Consumption")
  self:addCellHeaderTooltip(itable, "fluid-consumption", "FC", "Fluid Consumption /s")
  self:addCellHeaderTooltip(itable, "fluid-fuel", "FF", "Fluid Fuel")
  self:addCellHeaderTooltip(itable, "fluid-capacity", "FJ", "Fluid Capacity J")
  self:addCellHeaderTooltip(itable, "energy-type-output", "ETO", "Energy Type Output")
  self:addCellHeaderTooltip(itable, "fluid-production", "FP", "Fluid Production /s")
  self:addCellHeaderTooltip(itable, "fluid-production-prototype", "FPP", "Fluid Production Prototype")
  self:addCellHeaderTooltip(itable, "energy-production", "EP", "Energy Production")
  self:addCellHeaderTooltip(itable, "pollution", "P", "Pollution")
  self:addCellHeaderTooltip(itable, "speed", "S", "Speed")
end

-------------------------------------------------------------------------------
---Add row energy List
---@param itable LuaGuiElement
---@param entity table
---@param test_data table
function UnitTestPanel:addEnergyListRow(itable, entity, test_data)
  local prototype = EntityPrototype(entity)
  local lua_prototype = prototype:native()
  if lua_prototype ~= nil then
    ---col Entity
    local button = GuiElement.add(itable, GuiButtonSelectSprite("entity", entity):choose("entity", lua_prototype.name))
    button.locked = true
    ---col Type
    GuiElement.add(itable, GuiLabel("type", entity):caption(lua_prototype.type))
    ---col Name
    GuiElement.add(itable, GuiLabel("name", entity):caption(lua_prototype.name))

    local energy_source = prototype:getEnergySource()
    ---**** Attributes ***
    ---col Energy Type
    local energy_type = "none"
    if energy_source ~= nil then
      energy_type = energy_source:getType()
    end
    local tag_color, tooltip = self:valueEquals(energy_type, test_data.energy_type, true)
    GuiElement.add(itable, GuiLabel("energy-type", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_type, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Energy Usage Min
    local energy_usage_min = math.floor(prototype:getMinEnergyUsage())
    local tag_color, tooltip = self:valueEquals(energy_usage_min, test_data.energy_usage_min, true)
    GuiElement.add(itable, GuiLabel("energy-usage-min", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_usage_min, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Energy Usage Max
    local energy_usage_max = math.floor(prototype:getMaxEnergyUsage())
    local tag_color, tooltip = self:valueEquals(energy_usage_max, test_data.energy_usage_max, true)
    GuiElement.add(itable, GuiLabel("energy-usage-max", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_usage_max, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Energy Usage Priority
    local energy_usage_priority = "none"
    if energy_source ~= nil then
      energy_usage_priority = energy_source:getUsagePriority()
    end
    local tag_color, tooltip = self:valueEquals(energy_usage_priority, test_data.energy_usage_priority, true)
    GuiElement.add(itable, GuiLabel("energy-usage-priority", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_usage_priority, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Usage /s
    local fluid_usage = math.floor(prototype:getFluidUsage())
    local tag_color, tooltip = self:valueEquals(fluid_usage, test_data.fluid_usage, true)
    GuiElement.add(itable, GuiLabel("fluid-usage", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_usage, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Burns
    local fluid_burns = "none"
    if energy_source ~= nil and prototype:getEnergyTypeInput() == "fluid" then
      fluid_burns = prototype:getBurnsFluid()
    end
    local tag_color, tooltip = self:valueEquals(fluid_burns, test_data.fluid_burns, true)
    GuiElement.add(itable, GuiLabel("fluid-burns", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_burns, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Effectivity
    local effectivity = prototype:getEffectivity()
    local tag_color, tooltip = self:valueEquals(effectivity, test_data.effectivity, true)
    GuiElement.add(itable, GuiLabel("effectivity", entity):caption({"", helmod_tag.font.default_bold, tag_color, effectivity, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Target Temperature
    local target_temperature = prototype:getTargetTemperature()
    local tag_color, tooltip = self:valueEquals(target_temperature, test_data.target_temperature, true)
    GuiElement.add(itable, GuiLabel("target-temperature", entity):caption({"", helmod_tag.font.default_bold, tag_color, target_temperature, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Maximum Temperature
    local maximum_temperature = prototype:getMaximumTemperature()
    local tag_color, tooltip = self:valueEquals(maximum_temperature, test_data.maximum_temperature, true)
    GuiElement.add(itable, GuiLabel("maximum-temperature", entity):caption({"", helmod_tag.font.default_bold, tag_color, maximum_temperature, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))

    ---**** Computed ***
    ---col Energy Type
    local energy_type_input = prototype:getEnergyTypeInput()
    local tag_color, tooltip = self:valueEquals(energy_type_input, test_data.energy_type_input)
    GuiElement.add(itable, GuiLabel("energy-type-input", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_type_input, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Energy Consumption
    local energy_consumption = math.floor(prototype:getEnergyConsumption() + prototype:getMinEnergyUsage())
    local tag_color, tooltip = self:valueEquals(energy_consumption, test_data.energy_consumption)
    GuiElement.add(itable, GuiLabel("energy-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_consumption, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Consumption /s
    local fluid_consumption = Format.round(prototype:getFluidConsumption(),-2)
    local tag_color, tooltip = self:valueEquals(fluid_consumption, test_data.fluid_consumption)
    GuiElement.add(itable, GuiLabel("fluid-consumption", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_consumption, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Fuel
    local fuel_prototype = prototype:getFluidFuelPrototype()
    local fluid_fuel = {name="none", capacity=0}
    if fuel_prototype ~= nil and fuel_prototype:native() ~= nil then 
      fluid_fuel = {name=fuel_prototype:native().name, capacity=fuel_prototype:getHeatCapacity()}
    end
    local tag_color, tooltip = self:valueEquals(fluid_fuel.name, test_data.fluid_fuel.name)
    GuiElement.add(itable, GuiLabel("fluid-fuel", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_fuel.name, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Capacity
    local tag_color, tooltip = self:valueEquals(fluid_fuel.capacity, test_data.fluid_fuel.capacity)
    GuiElement.add(itable, GuiLabel("fluid-capacity", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_fuel.capacity, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Energy Type Output
    local energy_type_output = prototype:getEnergyTypeOutput()
    local tag_color, tooltip = self:valueEquals(energy_type_output, test_data.energy_type_output)
    GuiElement.add(itable, GuiLabel("energy-type-output", entity):caption({"", helmod_tag.font.default_bold, tag_color, energy_type_output, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Production /s
    local fluid_production = {name="none", amount=math.floor(prototype:getFluidProduction())}
    local fluid_production_filter = prototype:getFluidProductionFilter()
    if fluid_production_filter ~= nil then fluid_production.name =  fluid_production_filter.name end
    local tag_color, tooltip = self:valueEquals(fluid_production.amount, test_data.fluid_production.amount)
    GuiElement.add(itable, GuiLabel("fluid-production", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_production.amount, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Fluid Production Prototype
    local tag_color, tooltip = self:valueEquals(fluid_production.name, test_data.fluid_production.name)
    GuiElement.add(itable, GuiLabel("fluid-production-prototype", entity):caption({"", helmod_tag.font.default_bold, tag_color, fluid_production.name, helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Energy Production
    local energy_production = math.floor(prototype:getEnergyProduction())
    local tag_color, tooltip = self:valueEquals(energy_production, test_data.energy_production)
    GuiElement.add(itable, GuiLabel("energy-production", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumberKilo(energy_production, "W"), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Pollution
    local pollution = Format.round(prototype:getPollution() * 60, -2)
    local tag_color, tooltip = self:valueEquals(pollution, test_data.pollution)
    GuiElement.add(itable, GuiLabel("pollution", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumber(pollution), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
    ---col Speed
    local speed = Format.round(prototype:speedFactory(test_data.recipe), -2)
    local tag_color, tooltip = self:valueEquals(speed, test_data.speed)
    GuiElement.add(itable, GuiLabel("speed", entity):caption({"", helmod_tag.font.default_bold, tag_color, Format.formatNumber(speed), helmod_tag.color.close, helmod_tag.font.close}):tooltip(tooltip))
  end

end

function UnitTestPanel:valueEquals(current_value, target_value, attribute)
  if current_value == target_value then
    local tag_color = helmod_tag.color.green_light
    if attribute then
      tag_color = helmod_tag.color.blue_light
    end
    if current_value == "none" then
      tag_color = helmod_tag.color.white
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
