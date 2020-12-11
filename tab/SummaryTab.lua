require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module SummaryTab
-- @extends #AbstractTab
--

SummaryTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#SummaryTab] getButtonCaption
--
-- @return #string
--
function SummaryTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-summary"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#SummaryTab] getButtonSprites
--
-- @return boolean
--
function SummaryTab:getButtonSprites()
  return "brief-white","brief"
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#SummaryTab] updateData
--
-- @param #LuaEvent event
--
function SummaryTab:updateData(event)
  local model = self:getParameterObjects()
  -- data
  local scrollPanel = self:getResultScrollPanel({"helmod_result-panel.tab-title-summary"})
  
  -- resources
  local resourcesPanel = GuiElement.add(scrollPanel, GuiFlowV("resources"))
  GuiElement.add(resourcesPanel, GuiLabel("label"):caption({"helmod_common.resources"}):style("helmod_label_title_frame"))

  local resourcesTable = GuiElement.add(resourcesPanel, GuiTable("table-resources"):column(4))
  GuiElement.add(resourcesTable, GuiLabel("header-ingredient"):caption({"helmod_result-panel.col-header-ingredient"}))
  GuiElement.add(resourcesTable, GuiLabel("header-block"):caption({"helmod_result-panel.col-header-production-block"}))
  GuiElement.add(resourcesTable, GuiLabel("header-cargo-wagon"):caption({"helmod_result-panel.col-header-wagon"}))
  GuiElement.add(resourcesTable, GuiLabel("header-chest"):caption({"helmod_result-panel.col-header-storage"}))

  for _, resource in pairs(model.resources) do
    -- ingredient
    local guiIngredient = GuiElement.add(resourcesTable, GuiFrameH("ingredient", resource.name):style(helmod_frame_style.hidden))
    GuiElement.add(guiIngredient, GuiLabel("count"):caption(Format.formatNumberElement(resource.count)):style("helmod_label_right_60"))
    GuiElement.add(guiIngredient, GuiButtonSprite("HMIngredient", "OPEN"):sprite(Player.getItemIconType(resource), resource.name):tooltip(Player.getLocalisedName(resource)))

    -- col block
    local guiBlock = GuiElement.add(resourcesTable, GuiFrameH("block", resource.name):style(helmod_frame_style.hidden))
    GuiElement.add(guiBlock, GuiLabel("count"):caption(Format.formatNumberElement(resource.blocks)):style("helmod_label_right_50"))

    -- col wagon
    local wagon = resource.wagon
    local guiWagon = GuiElement.add(resourcesTable, GuiFrameH("wagon", resource.name):style(helmod_frame_style.hidden))
    if wagon ~= nil then
      GuiElement.add(guiWagon, GuiLabel("count"):caption(Format.formatNumberElement(wagon.limit_count).."/"..Format.formatNumberElement(wagon.count)):style("helmod_label_right_70"))
      GuiElement.add(guiWagon, GuiButtonSprite("HMWagon", "OPEN"):sprite(wagon.type, wagon.name):style(Player.getLocalisedName(wagon)))
    end

    -- col storage
    local storage = resource.storage
    local guiStorage = GuiElement.add(resourcesTable, GuiFrameH("storage", resource.name):style(helmod_frame_style.hidden))
    if storage ~= nil then
      GuiElement.add(guiStorage, GuiLabel("count"):caption(Format.formatNumberElement(storage.limit_count).."/"..Format.formatNumberElement(storage.count)):style("helmod_label_right_70"))
      GuiElement.add(guiStorage, GuiButtonSprite("HMStorage", "OPEN"):sprite(storage.type, storage.name):tooltip(Player.getLocalisedName(storage)))
    end
  end
  -- generators
  local energyPanel = GuiElement.add(scrollPanel, GuiFlowV("energy"))
  GuiElement.add(energyPanel, GuiLineH("line"))
  GuiElement.add(energyPanel, GuiLabel("label"):caption({"helmod_common.generators"}):style("helmod_label_title_frame"))

  local resultTable = GuiElement.add(energyPanel, GuiTable("table-energy"):column(2))

  if model.generators ~= nil then
    for _, item in pairs(model.generators) do
      local guiCell = GuiElement.add(resultTable, GuiFrameH("cell", item.name):style(helmod_frame_style.hidden))
      GuiElement.add(guiCell, GuiLabel(item.name):caption(Format.formatNumberKilo(item.count)):style("helmod_label_right_50"))
      GuiElement.add(guiCell, GuiButtonSprite("HMGenerator", "OPEN"):sprite("item", item.name):tooltip(Player.getLocalisedName(item)))
    end
  end

  if model.summary ~= nil then
    -- factories
    local factoryPanel = GuiElement.add(scrollPanel, GuiFlowV("factory"))
    GuiElement.add(factoryPanel, GuiLineH("line"))
    GuiElement.add(factoryPanel, GuiLabel("label"):caption({"helmod_common.factories"}):style("helmod_label_title_frame"))

    local resultTable = GuiElement.add(factoryPanel, GuiTable("table-factory"):column(10))

    for _, element in pairs(model.summary.factories) do
      local guiCell = GuiElement.add(resultTable, GuiFrameH("cell", element.name):style(helmod_frame_style.hidden))
      GuiElement.add(guiCell, GuiLabel(element.name):caption(Format.formatNumberKilo(element.count)):style("helmod_label_right_50"))
      GuiElement.add(guiCell, GuiButtonSprite("HMFactories", "OPEN"):sprite("item", element.name):tooltip(Player.getLocalisedName(element)))
    end

    -- beacons
    local beaconPanel = GuiElement.add(scrollPanel, GuiFlowV("beacon"))
    GuiElement.add(beaconPanel, GuiLineH("line"))
    GuiElement.add(beaconPanel, GuiLabel("label"):caption({"helmod_common.beacons"}):style("helmod_label_title_frame"))

    local resultTable = GuiElement.add(beaconPanel, GuiTable("table-beacon"):column(10))

    for _, element in pairs(model.summary.beacons) do
      local guiCell = GuiElement.add(resultTable, GuiFrameH("cell", element.name):style(helmod_frame_style.hidden))
      GuiElement.add(guiCell, GuiLabel(element.name):caption(Format.formatNumberKilo(element.count)):style("helmod_label_right_50"))
      GuiElement.add(guiCell, GuiButtonSprite("HMBeacons", "OPEN"):sprite("item", element.name):tooltip(Player.getLocalisedName(element)))
    end

    -- modules
    local modulesPanel = GuiElement.add(scrollPanel, GuiFlowV("modules"))
    GuiElement.add(modulesPanel, GuiLineH("line"))
    GuiElement.add(modulesPanel, GuiLabel("label"):caption({"helmod_common.modules"}):style("helmod_label_title_frame"))

    local resultTable = GuiElement.add(modulesPanel, GuiTable("table-modules"):column(10))

    for _, element in pairs(model.summary.modules) do
      -- col icon
      local guiCell = GuiElement.add(resultTable, GuiFrameH("cell", element.name):style(helmod_frame_style.hidden))
      GuiElement.add(guiCell, GuiLabel(element.name):caption(Format.formatNumberKilo(element.count)):style("helmod_label_right_50"))
      GuiElement.add(guiCell, GuiButtonSprite("HMModules", "OPEN"):sprite("item", element.name):tooltip(Player.getLocalisedName(element)))
    end
  end
end