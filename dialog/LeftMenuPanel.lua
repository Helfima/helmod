-------------------------------------------------------------------------------
-- Class to build left menu form
--
-- @module LeftMenuPanel
-- @extends #Dialog
--

LeftMenuPanel = setclass("HMLeftMenuPanel", Form)

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#LeftMenuPanel] getParentPanel
--
-- @return #LuaGuiElement
--
function LeftMenuPanel.methods:getParentPanel()
  return Controller.getLeftPanel()
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#LeftMenuPanel] getMenuPanel
--
function LeftMenuPanel.methods:getMenuPanel()
  local menu_panel = self:getPanel()
  if menu_panel["menu_panel"] ~= nil then
    return menu_panel["menu_panel"]
  end
  return ElementGui.addGuiFrameV(menu_panel, "menu_panel", helmod_frame_style.default)
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#LeftMenuPanel] getModelPanel
--
function LeftMenuPanel.methods:getModelPanel()
  local menu_panel = self:getPanel()
  if menu_panel["model_panel"] ~= nil and menu_panel["model_panel"].valid then
    return menu_panel["model_panel"]["model_table"]
  end
  local panel = ElementGui.addGuiFrameV(menu_panel, "model_panel", helmod_frame_style.default)
  return ElementGui.addGuiTable(panel, "model_table", 1, helmod_table_style.list)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#LeftMenuPanel] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function LeftMenuPanel.methods:onUpdate(event, action, item, item2, item3)
  self:updateMenu(event, action, item, item2, item3)
  self:updateModelPanel(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#LeftMenuPanel] updateMenu
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function LeftMenuPanel.methods:updateMenu(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateMenu():", action, item, item2, item3)
  -- menu
  local menuPanel = self:getMenuPanel()
  menuPanel.clear()

  ElementGui.addGuiButton(menuPanel, Controller.classname.."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
  ElementGui.addGuiButton(menuPanel, "HMSettings=OPEN", nil, "helmod_button_icon_menu", nil, ({"helmod_button.options"}))
  ElementGui.addGuiButton(menuPanel, "HMHelpPanel=OPEN", nil, "helmod_button_icon_help", nil, ({"helmod_button.help"}))
end

-------------------------------------------------------------------------------
-- Update model panel
--
-- @function [parent=#LeftMenuPanel] updateModelPanel
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function LeftMenuPanel.methods:updateModelPanel(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateModelPanel():", action, item, item2, item3)
  local model_panel = self:getModelPanel()
  local model = Model.getModel()

  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    ModelCompute.update(true)
  end

  model_panel.clear()

  -- time panel
  local times = {
    { value = 1, caption = "1s", tooltip="1s"},
    { value = 60, caption = "1", tooltip="1mn"},
    { value = 300, caption = "5", tooltip="5mn"},
    { value = 600, caption = "10", tooltip="10mn"},
    { value = 1800, caption = "30", tooltip="30mn"},
    { value = 3600, caption = "1h", tooltip="1h"},
    { value = 3600*6, caption = "6h", tooltip="6h"},
    { value = 3600*12, caption = "12h", tooltip="12h"},
    { value = 3600*24, caption = "24h", tooltip="24h"}
  }
  for _,time in pairs(times) do
    local style = "helmod_button_icon_time"
    if model.time == time.value then style = "helmod_button_icon_time_selected" end
    ElementGui.addGuiButton(model_panel, self:classname().."=change-time=ID=", time.value, style, time.caption, {"helmod_data-panel.base-time", time.tooltip})
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Form] LeftMenuPanel
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function LeftMenuPanel.methods:onEvent(event, action, item, item2, item3)
  if action == "change-time" then
    self:onUpdate(event, action, item, item2, item3)
  end
end
