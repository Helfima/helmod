require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module SummaryTab
-- @extends #ElementGui
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
-- Update data
--
-- @function [parent=#SummaryTab] updateData
--
-- @param #LuaPlayer player
--
function SummaryTab.methods:updateData(player)
  Logging:debug(self:classname(), "updateSummary():", player)
  local model = self.model:getModel(player)
  -- data
  local scrollPanel = self.parent:getResultScrollPanel(player, {"helmod_result-panel.tab-title-summary"})
  
  -- resources
  local resourcesPanel = self:addGuiFrameV(scrollPanel, "resources", "helmod_frame_resize_row_width", ({"helmod_common.resources"}))
  self.player:setStyle(player, resourcesPanel, "data", "minimal_width")
  self.player:setStyle(player, resourcesPanel, "data", "maximal_width")

  local resourcesTable = self:addGuiTable(resourcesPanel,"table-resources",4)
  self:addGuiLabel(resourcesTable, "header-ingredient", ({"helmod_result-panel.col-header-ingredient"}))
  self:addGuiLabel(resourcesTable, "header-block", ({"helmod_result-panel.col-header-production-block"}))
  self:addGuiLabel(resourcesTable, "header-cargo-wagon", ({"helmod_result-panel.col-header-wagon"}))
  self:addGuiLabel(resourcesTable, "header-chest", ({"helmod_result-panel.col-header-storage"}))
  --  self:addGuiLabel(resourcesTable, "header-extractor", ({"helmod_result-panel.col-header-extractor"}))
  --  self:addGuiLabel(resourcesTable, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
  --  self:addGuiLabel(resourcesTable, "header-energy", ({"helmod_result-panel.col-header-energy"}))

  for _, resource in pairs(model.resources) do
    -- ingredient
    local guiIngredient = self:addGuiFlowH(resourcesTable,"ingredient"..resource.name)
    self:addGuiLabel(guiIngredient, "count", self:formatNumberElement(resource.count), "helmod_label_right_60")
    self:addGuiButtonSprite(guiIngredient, "HMIngredient=OPEN=ID=", self.player:getItemIconType(resource), resource.name, resource.name, self.player:getLocalisedName(player, resource))

    -- col block
    local guiBlock = self:addGuiFlowH(resourcesTable,"block"..resource.name)
    self:addGuiLabel(guiBlock, "count", self:formatNumberElement(resource.blocks), "helmod_label_right_50")

    -- col wagon
    local wagon = resource.wagon
    local guiWagon = self:addGuiFlowH(resourcesTable,"wagon"..resource.name)
    if wagon ~= nil then
      self:addGuiLabel(guiWagon, "count", self:formatNumberElement(wagon.limit_count).."/"..self:formatNumberElement(wagon.count), "helmod_label_right_70")
      self:addGuiButtonSprite(guiWagon, "HMWagon=OPEN=ID=", self.player:getIconType(wagon), wagon.name, wagon.name, self.player:getLocalisedName(player, wagon))
    end

    -- col storage
    local storage = resource.storage
    local guiStorage = self:addGuiFlowH(resourcesTable,"storage"..resource.name)
    if storage ~= nil then
      self:addGuiLabel(guiStorage, "count", self:formatNumberElement(storage.limit_count).."/"..self:formatNumberElement(storage.count), "helmod_label_right_70")
      self:addGuiButtonSprite(guiStorage, "HMStorage=OPEN=ID=", self.player:getIconType(storage), storage.name, storage.name, self.player:getLocalisedName(player, storage))
    end
  end

  local energyPanel = self:addGuiFrameV(scrollPanel, "energy", "helmod_frame_resize_row_width", ({"helmod_common.generators"}))
  self.player:setStyle(player, energyPanel, "data", "minimal_width")
  self.player:setStyle(player, energyPanel, "data", "maximal_width")

  local resultTable = self:addGuiTable(energyPanel,"table-energy",2)

  if model.generators ~= nil then
    for _, item in pairs(model.generators) do
      local guiCell = self:addGuiFlowH(resultTable,"cell_"..item.name)
      self:addGuiLabel(guiCell, item.name, self:formatNumberKilo(item.count), "helmod_label_right_50")
      self:addGuiButtonSprite(guiCell, "HMGenerator=OPEN=ID=", "item", item.name, item.name, self.player:getLocalisedName(player, item))
    end
  end

  -- factories
  local factoryPanel = self:addGuiFrameV(scrollPanel, "factory", "helmod_frame_resize_row_width", ({"helmod_common.factories"}))
  self.player:setStyle(player, factoryPanel, "data", "minimal_width")
  self.player:setStyle(player, factoryPanel, "data", "maximal_width")

  if model.summary ~= nil then
    local resultTable = self:addGuiTable(factoryPanel,"table-factory",10)

    for _, element in pairs(model.summary.factories) do
      local guiCell = self:addGuiFlowH(resultTable,"cell_"..element.name)
      self:addGuiLabel(guiCell, element.name, self:formatNumberKilo(element.count), "helmod_label_right_50")
      self:addGuiButtonSprite(guiCell, "HMFactories=OPEN=ID=", "item", element.name, element.name, self.player:getLocalisedName(player, element))
    end

    -- beacons
    local beaconPanel = self:addGuiFrameV(scrollPanel, "beacon", "helmod_frame_resize_row_width", ({"helmod_common.beacons"}))
    self.player:setStyle(player, beaconPanel, "data", "minimal_width")
    self.player:setStyle(player, beaconPanel, "data", "maximal_width")

    local resultTable = self:addGuiTable(beaconPanel,"table-beacon",10)

    for _, element in pairs(model.summary.beacons) do
      local guiCell = self:addGuiFlowH(resultTable,"cell_"..element.name)
      self:addGuiLabel(guiCell, element.name, self:formatNumberKilo(element.count), "helmod_label_right_50")
      self:addGuiButtonSprite(guiCell, "HMBeacons=OPEN=ID=", "item", element.name, element.name, self.player:getLocalisedName(player, element))
    end

    -- modules
    local modulesPanel = self:addGuiFrameV(scrollPanel, "modules", "helmod_frame_resize_row_width", ({"helmod_common.modules"}))
    self.player:setStyle(player, modulesPanel, "data", "minimal_width")
    self.player:setStyle(player, modulesPanel, "data", "maximal_width")

    local resultTable = self:addGuiTable(modulesPanel,"table-modules",10)

    for _, element in pairs(model.summary.modules) do
      -- col icon
      local guiCell = self:addGuiFlowH(resultTable,"cell_"..element.name)
      self:addGuiLabel(guiCell, element.name, self:formatNumberKilo(element.count), "helmod_label_right_50")
      self:addGuiButtonSprite(guiCell, "HMModules=OPEN=ID=", "item", element.name, element.name, self.player:getLocalisedName(player, element))
    end
  end
end