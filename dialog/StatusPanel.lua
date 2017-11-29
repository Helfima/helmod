-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module StatusPanel
-- @extends #Dialog
--

StatusPanel = setclass("HMStatusPanel", Dialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#StatusPanel] onInit
--
-- @param #Controller parent parent controller
--
function StatusPanel.methods:onInit(parent)
  self.panelCaption = ({"helmod_status-tab-panel.title"})
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#StatusPanel] getParentPanel
--
-- @return #LuaGuiElement
--
function StatusPanel.methods:getParentPanel()
  return self.parent:getPinTabPanel()
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#StatusPanel] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function StatusPanel.methods:onOpen( event, action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local close = true
  if globalGui.pinBlock == nil or globalGui.pinBlock ~= item then
    close = false
  end
  globalGui.pinBlock = item
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#StatusPanel] onClose
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function StatusPanel.methods:onClose(event, action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  globalGui.pinBlock = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#StatusPanel] getInfoPanel
--
function StatusPanel.methods:getInfoPanel()
  local panel = self:getPanel(player)
  if panel["info-panel"] ~= nil and panel["info-panel"].valid then
    return panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = ElementGui.addGuiFrameV(panel, "info-panel", "helmod_frame_resize_row_width")
  return ElementGui.addGuiScrollPane(mainPanel, "scroll-panel", "helmod_scroll_block_pin_tab", "auto", "auto")
end

-------------------------------------------------------------------------------
-- Get or create header panel
--
-- @function [parent=#StatusPanel] getHeaderPanel
--
function StatusPanel.methods:getHeaderPanel()
  local panel = self:getPanel()
  if panel["header"] ~= nil and panel["header"].valid then
    return panel["header"]
  end
  return ElementGui.addGuiFrameH(panel, "header", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#StatusPanel] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function StatusPanel.methods:afterOpen(event, action, item, item2, item3)
  self:updateHeader(event, action, item, item2, item3)
  self:getInfoPanel()
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#StatusPanel] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function StatusPanel.methods:onUpdate(event, action, item, item2, item3)
  self:updateInfo(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#StatusPanel] updateInfo
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function StatusPanel.methods:updateHeader(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", action, item, item2, item3)
  local header_panel = self:getHeaderPanel()
  local model = Model.getModel()

  ElementGui.addGuiButton(header_panel, self:classname().."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=UPDATE", nil, "helmod_button_icon_refresh", nil, ({"helmod_result-panel.refresh-button"}))
  --  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=down", nil, "helmod_button_icon_arrow_left", nil, ({"helmod_button.minimize"}))
  --  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=up", nil, "helmod_button_icon_arrow_right", nil, ({"helmod_button.minimize"}))
  --  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=min", nil, "helmod_button_icon_minimize", nil, ({"helmod_button.minimize"}))
  --  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=max", nil, "helmod_button_icon_maximize", nil, ({"helmod_button.maximize"}))

end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#StatusPanel] updateInfo
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function StatusPanel.methods:updateInfo(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateInfo():", action, item, item2, item3)
  local infoPanel = self:getInfoPanel()
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  local column = 2

  local resultTable = ElementGui.addGuiTable(infoPanel,"list-data",column, "helmod_table-odd")
  --self:addProductionBlockHeader(resultTable)
  local elements = {}
  
  table.insert(elements, {name = "locomotive", type = "entity", value = #Player.getForce().get_trains()})
  
  local entities = {"logistic-robot", "construction-robot", "straight-rail", "curved-rail", "electric-furnace",
                    "assembling-machine-3", "chemical-plant", "oil-refinery", "beacon", "lab", "electric-mining-drill",
                    "express-transport-belt", "express-underground-belt", "express-splitter"
                    , "medium-electric-pole", "big-electric-pole"}
  for _, element in pairs(entities) do
    table.insert(elements, {name = element, type = "entity", value = Player.getForce().get_entity_count(element)})
  end
  
  for _, element in pairs(elements) do
    self:addProductionBlockRow(resultTable, element)
  end
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#StatusPanel] addProductionBlockHeader
--
-- @param #LuaGuiElement itable container for element
--
function StatusPanel.methods:addProductionBlockHeader(itable)
  Logging:debug(self:classname(), "addProductionBlockHeader():", itable)
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#StatusPanel] addProductionBlockRow
--
-- @param #LuaGuiElement guiTable
-- @param #table element
--
function StatusPanel.methods:addProductionBlockRow(guiTable, element)
  Logging:debug(self:classname(), "addProductionBlockRow():", guiTable, element)
  EntityPrototype.load(element).native()
  
  ElementGui.addGuiButtonSprite(guiTable, "element_"..element.name.."=", Player.getIconType(element), element.name, element.name, Player.getLocalisedName(element))
  ElementGui.addGuiLabel(guiTable, "value_"..element.name, element.value)

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#StatusPanel] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function StatusPanel.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  local global_settings = Player.getGlobalSettings()
  local global_gui = Player.getGlobalGui()

  if action == "change-level" then
    local display_pin_level = Player.getGlobalSettings("display_pin_level")
    Logging:debug(self:classname(), "display_pin_level", display_pin_level)
    if item == "down" and display_pin_level > display_pin_level_min  then global_settings["display_pin_level"] = display_pin_level - 1 end
    if item == "up" and display_pin_level < display_pin_level_max  then global_settings["display_pin_level"] = display_pin_level + 1 end
    if item == "min" then global_settings["display_pin_level"] = display_pin_level_min end
    if item == "max" then global_settings["display_pin_level"] = display_pin_level_max end
    self:updateInfo(event, action, global_gui.pinBlock, item2, item3)
  end
end
