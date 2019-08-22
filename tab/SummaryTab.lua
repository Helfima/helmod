require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module SummaryTab
-- @extends #AbstractTab
--

SummaryTab = setclass("HMSummaryTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#SummaryTab] getButtonCaption
--
-- @return #string
--
function SummaryTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-summary"}
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#SummaryTab] getButtonStyles
--
-- @return boolean
--
function SummaryTab.methods:getButtonStyles()
  return "helmod_button_icon_brief","helmod_button_icon_brief_selected"
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#SummaryTab] updateData
--
function SummaryTab.methods:updateData()
  Logging:debug(self:classname(), "updateSummary()")
  local model = Model.getModel()
  -- data
  local scrollPanel = self:getResultScrollPanel({"helmod_result-panel.tab-title-summary"})
  
  -- resources
  local resourcesPanel = ElementGui.addGuiFrameV(scrollPanel, "resources", helmod_frame_style.section, ({"helmod_common.resources"}))
  ElementGui.setStyle(resourcesPanel, "data_section", "width")

  local resourcesTable = ElementGui.addGuiTable(resourcesPanel,"table-resources",4)
  ElementGui.addGuiLabel(resourcesTable, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
  ElementGui.addGuiLabel(resourcesTable, "header-block", ({"helmod_result-panel.col-header-production-block"}))
  ElementGui.addGuiLabel(resourcesTable, "header-cargo-wagon", ({"helmod_result-panel.col-header-wagon"}))
  ElementGui.addGuiLabel(resourcesTable, "header-chest", ({"helmod_result-panel.col-header-storage"}))
  --  ElementGui.addGuiLabel(resourcesTable, "header-extractor", ({"helmod_result-panel.col-header-extractor"}))
  --  ElementGui.addGuiLabel(resourcesTable, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
  --  ElementGui.addGuiLabel(resourcesTable, "header-energy", ({"helmod_result-panel.col-header-energy"}))

  for _, resource in pairs(model.resources) do
    -- ingredient
    local guiIngredient = ElementGui.addGuiFrameH(resourcesTable,"ingredient"..resource.name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiIngredient, "count", Format.formatNumberElement(resource.count), "helmod_label_right_60")
    ElementGui.addGuiButtonSprite(guiIngredient, "HMIngredient=OPEN=ID=", Player.getItemIconType(resource), resource.name, resource.name, Player.getLocalisedName(resource))

    -- col block
    local guiBlock = ElementGui.addGuiFrameH(resourcesTable,"block"..resource.name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiBlock, "count", Format.formatNumberElement(resource.blocks), "helmod_label_right_50")

    -- col wagon
    local wagon = resource.wagon
    local guiWagon = ElementGui.addGuiFrameH(resourcesTable,"wagon"..resource.name, helmod_frame_style.hidden)
    if wagon ~= nil then
      ElementGui.addGuiLabel(guiWagon, "count", Format.formatNumberElement(wagon.limit_count).."/"..Format.formatNumberElement(wagon.count), "helmod_label_right_70")
      ElementGui.addGuiButtonSprite(guiWagon, "HMWagon=OPEN=ID=", Player.getIconType(wagon), wagon.name, wagon.name, Player.getLocalisedName(wagon))
    end

    -- col storage
    local storage = resource.storage
    local guiStorage = ElementGui.addGuiFrameH(resourcesTable,"storage"..resource.name, helmod_frame_style.hidden)
    if storage ~= nil then
      ElementGui.addGuiLabel(guiStorage, "count", Format.formatNumberElement(storage.limit_count).."/"..Format.formatNumberElement(storage.count), "helmod_label_right_70")
      ElementGui.addGuiButtonSprite(guiStorage, "HMStorage=OPEN=ID=", Player.getIconType(storage), storage.name, storage.name, Player.getLocalisedName(storage))
    end
  end

  local energyPanel = ElementGui.addGuiFrameV(scrollPanel, "energy", helmod_frame_style.section, ({"helmod_common.generators"}))
  ElementGui.setStyle(energyPanel, "data_section", "width")

  local resultTable = ElementGui.addGuiTable(energyPanel,"table-energy",2)

  if model.generators ~= nil then
    for _, item in pairs(model.generators) do
      local guiCell = ElementGui.addGuiFrameH(resultTable,"cell_"..item.name, helmod_frame_style.hidden)
      ElementGui.addGuiLabel(guiCell, item.name, Format.formatNumberKilo(item.count), "helmod_label_right_50")
      ElementGui.addGuiButtonSprite(guiCell, "HMGenerator=OPEN=ID=", "item", item.name, item.name, Player.getLocalisedName(item))
    end
  end

  -- factories
  local factoryPanel = ElementGui.addGuiFrameV(scrollPanel, "factory", helmod_frame_style.section, ({"helmod_common.factories"}))
  ElementGui.setStyle(factoryPanel, "data_section", "width")

  if model.summary ~= nil then
    local resultTable = ElementGui.addGuiTable(factoryPanel,"table-factory",10)

    for _, element in pairs(model.summary.factories) do
      local guiCell = ElementGui.addGuiFrameH(resultTable,"cell_"..element.name, helmod_frame_style.hidden)
      ElementGui.addGuiLabel(guiCell, element.name, Format.formatNumberKilo(element.count), "helmod_label_right_50")
      ElementGui.addGuiButtonSprite(guiCell, "HMFactories=OPEN=ID=", "item", element.name, element.name, Player.getLocalisedName(element))
    end

    -- beacons
    local beaconPanel = ElementGui.addGuiFrameV(scrollPanel, "beacon", helmod_frame_style.section, ({"helmod_common.beacons"}))
    ElementGui.setStyle(beaconPanel, "data_section", "width")

    local resultTable = ElementGui.addGuiTable(beaconPanel,"table-beacon",10)

    for _, element in pairs(model.summary.beacons) do
      local guiCell = ElementGui.addGuiFrameH(resultTable,"cell_"..element.name, helmod_frame_style.hidden)
      ElementGui.addGuiLabel(guiCell, element.name, Format.formatNumberKilo(element.count), "helmod_label_right_50")
      ElementGui.addGuiButtonSprite(guiCell, "HMBeacons=OPEN=ID=", "item", element.name, element.name, Player.getLocalisedName(element))
    end

    -- modules
    local modulesPanel = ElementGui.addGuiFrameV(scrollPanel, "modules", helmod_frame_style.section, ({"helmod_common.modules"}))
    ElementGui.setStyle(modulesPanel, "data_section", "width")

    local resultTable = ElementGui.addGuiTable(modulesPanel,"table-modules",10)

    for _, element in pairs(model.summary.modules) do
      -- col icon
      local guiCell = ElementGui.addGuiFrameH(resultTable,"cell_"..element.name, helmod_frame_style.hidden)
      ElementGui.addGuiLabel(guiCell, element.name, Format.formatNumberKilo(element.count), "helmod_label_right_50")
      ElementGui.addGuiButtonSprite(guiCell, "HMModules=OPEN=ID=", "item", element.name, element.name, Player.getLocalisedName(element))
    end
  end
end