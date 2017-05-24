require "model.Model"
require "dialog.Dialog"
require "dialog.PinPanel"
require "dialog.Settings"
require "edition.RecipeEdition"
require "edition.ProductEdition"
require "edition.ResourceEdition"
require "edition.EnergyEdition"
require "selector.EntitySelector"
require "selector.RecipeSelector"
require "selector.TechnologySelector"
require "tab.MainTab"


PLANNER_COMMAND = "helmod_planner-command"

-------------------------------------------------------------------------------
-- Class of main controller
--
-- @module Controller
--

Controller = setclass("HMController", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlayerController] init
--
-- @param #PlayerController parent controller parent
--
function Controller.methods:init(parent)
  Logging:debug(self:classname(), "init(parent):global=", global)
  self.player = parent
  self.controllers = {}
  self.model = Model:new(self)

  self.locate = "center"
  self.pinLocate = "left"

  local controllers = {}
  table.insert(controllers, MainTab:new(self))
  table.insert(controllers, Settings:new(self))
  table.insert(controllers, EntitySelector:new(self))
  table.insert(controllers, RecipeSelector:new(self))
  table.insert(controllers, RecipeEdition:new(self))
  table.insert(controllers, ResourceEdition:new(self))
  table.insert(controllers, ProductEdition:new(self))
  table.insert(controllers, EnergyEdition:new(self))
  table.insert(controllers, PinPanel:new(self))
  table.insert(controllers, TechnologySelector:new(self))
  
  for _,controller in pairs(controllers) do
    self.controllers[controller:classname()] = controller
  end
  Logging:debug(self:classname(), "controllers", self.controllers)
end

-------------------------------------------------------------------------------
-- Cleanup
--
-- @function [parent=#Controller] cleanController
--
-- @param #LuaPlayer player
--
function Controller.methods:cleanController(player)
  Logging:trace(self:classname(), "cleanController(player)")
  for _,location in pairs(helmod_settings_mod.display_location.allowed_values) do
    if player.gui[location]["helmod_planner_main"] ~= nil then
      player.gui[location]["helmod_planner_main"].destroy()
    end
  end
end

-------------------------------------------------------------------------------
-- Bind all controllers
--
-- @function [parent=#Controller] bindController
--
-- @param #LuaPlayer player
--
function Controller.methods:bindController(player)
  Logging:trace(self:classname(), "bindController(player)")
  local parentGui = self.player:getGui(player)
  if parentGui ~= nil then
    local guiButton = self:addGuiFrameH(parentGui, PLANNER_COMMAND, "helmod_frame_default")
    guiButton.add({type="button", name=PLANNER_COMMAND, tooltip=({PLANNER_COMMAND}), style="helmod_icon"})
  end
end

-------------------------------------------------------------------------------
-- On click event
--
-- @function [parent=#Controller] on_gui_click
--
-- @param event
--
function Controller.methods:on_gui_click(event)
  Logging:debug(self:classname(), "on_gui_click(event)")
  if event.element then
    if event.element.name == PLANNER_COMMAND then
      local player = game.players[event.player_index]
      self:main(player)
    end

    if event.element.name == self:classname().."=CLOSE" then
      local player = game.players[event.player_index]
      self:cleanController(player)
    end
    self:parse_event(event)
  end
end

-------------------------------------------------------------------------------
-- On text changed event
--
-- @function [parent=#Controller] on_gui_text_changed
--
-- @param event
--
function Controller.methods:on_gui_text_changed(event)
  self:parse_event(event)
end

-------------------------------------------------------------------------------
-- On hotkey event
--
-- @function [parent=#Controller] on_gui_hotkey
--
-- @param event
--
function Controller.methods:on_gui_hotkey(event)
  self:parse_event(event, "hotkey")
end

-------------------------------------------------------------------------------
-- On dropdown event
--
-- @function [parent=#Controller] on_gui_selection_state_changed
--
-- @param event
--
function Controller.methods:on_gui_selection_state_changed(event)
  self:parse_event(event, "dropdown")
end

-------------------------------------------------------------------------------
-- On runtime mod settings
--
-- @function [parent=#Controller] on_runtime_mod_setting_changed
--
-- @param event
--
function Controller.methods:on_runtime_mod_setting_changed(event)
  self:parse_event(event, "settings")
end

-------------------------------------------------------------------------------
-- Parse event
--
-- @function [parent=#Controller] parse_event
--
-- @param event
-- @param type event type
--
function Controller.methods:parse_event(event, type)
  Logging:trace(self:classname(), "parse_event(event)")
  if self.controllers ~= nil then
    -- settings action
    if type == "settings" and event.element == nil then
      Logging:trace(self:classname(), "parse_event(event): settings=", event.name)
      local player = game.players[event.player_index]
      if self:isOpened(player) then
        self:main(player)
        self:main(player)
      end
    end
    -- hotkey action
    if type == "hotkey" and event.element == nil then
      Logging:trace(self:classname(), "parse_event(event): hotkey=", event.name)
      local player = game.players[event.player_index]
      if event.name == "helmod-open-close" then
        self:main(player)
      end
      if event.name == "helmod-production-line-open" then
        if not(self:isOpened(player)) then
          self:main(player)
        end
        self:send_event(player, "HMMainTab", "change-tab", "HMProductionLineTab")
      end
      if event.name == "helmod-recipe-selector-open" then
        if not(self:isOpened(player)) then
          self:main(player)
        end
        self:send_event(player, "HMRecipeSelector", "OPEN")
      end
    end
    -- button action
    if type == nil and event.element ~= nil and event.element.valid then
      local eventController = nil
      for _, controller in pairs(self.controllers) do
        Logging:debug(self:classname(), "match:", event.element.name, controller:classname())
        if string.find(event.element.name, controller:classname()) then
          Logging:debug(self:classname(), "match ok:", controller:classname())
          eventController = controller
        end
      end
      if eventController ~= nil then
        local player = game.players[event.player_index]
        local patternAction = eventController:classname().."=([^=]*)"
        local patternItem = eventController:classname()..".*=ID=([^=]*)"
        local patternItem2 = eventController:classname()..".*=ID=[^=]*=([^=]*)"
        local patternItem3 = eventController:classname()..".*=ID=[^=]*=[^=]*=([^=]*)"
        
        Logging:debug(self:classname(), "pattern:", patternAction, patternItem, patternItem2, patternItem3)
        
        local action = string.match(event.element.name,patternAction,1)
        local item = string.match(event.element.name,patternItem,1)
        local item2 = string.match(event.element.name,patternItem2,1)
        local item3 = string.match(event.element.name,patternItem3,1)
        Logging:debug(self:classname(), "parse_event:", event.element.name, action, item, item2, item3)
        eventController:send_event(player, event.element, action, item, item2, item3)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Send event dialog
--
-- @function [parent=#Controller] send_event
--
-- @param #LuaPlayer player
-- @param #string classname controller name
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.methods:send_event(player, classname, action, item, item2, item3)
  Logging:debug(self:classname(), "send_event(player, classname, action, item, item2, item3)", classname, action, item, item2, item3)
  if self.controllers ~= nil then
    for r, controller in pairs(self.controllers) do
      if controller:classname() == classname then
        controller:send_event(player, nil, action, item, item2, item3)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Prepare main display
--
-- @function [parent=#Controller] main
--
-- @param #LuaPlayer player
--
function Controller.methods:main(player)
  Logging:trace(self:classname(), "main(player)")
  local location = self.player:getSettings(player, "display_location")
  local guiMain = player.gui[location]
  if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
    guiMain["helmod_planner_main"].destroy()
  else
    -- main panel
    local mainPanel = self:getMainPanel(player)
    -- menu
    local menuPanel = self:getMenuPanel(player)
    local actionPanel = self:addGuiFrameV(menuPanel, "settings", "helmod_frame_left_menu")
    self:addGuiButton(actionPanel, self:classname().."=CLOSE", nil, "helmod_button_icon_cancel", nil, ({"helmod_button.close"}))
    self:addGuiButton(actionPanel, "HMSettings=OPEN", nil, "helmod_button_icon_options", nil, ({"helmod_button.options"}))
    -- info
    local infoPanel = self:getInfoPanel(player)
    -- data
    local dataPanel = self:getDataPanel(player)
    -- dialogue
    local dialogPanel = self:getDialogPanel(player)

    -- tab
    self.controllers["HMMainTab"]:buildPanel(player)
  end
end

-------------------------------------------------------------------------------
-- Get or create main panel
--
-- @function [parent=#Controller] getMainPanel
--
-- @param #LuaPlayer player
--
function Controller.methods:getMainPanel(player)
  Logging:trace(self:classname(), "getMainPanel(player):",player)
  local location = self.player:getSettings(player, "display_location")
  local guiMain = player.gui[location]
  if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
    return guiMain["helmod_planner_main"]
  end
  local panel = self:addGuiFlowH(guiMain, "helmod_planner_main", "helmod_flow_resize_row_width")
  --local panel = self:addGuiFrameH(guiMain, "helmod_planner_main", "helmod_frame_main")
  self.player:setStyle(player, panel, "main", "minimal_width")
  self.player:setStyle(player, panel, "main", "minimal_height")
  return panel
end

-------------------------------------------------------------------------------
-- Is opened main panel
--
-- @function [parent=#Controller] isOpened
--
-- @param #LuaPlayer player
--
function Controller.methods:isOpened(player)
  Logging:trace(self:classname(), "isOpened(player):",player)
  local location = self.player:getSettings(player, "display_location")
  local guiMain = player.gui[location]
  if guiMain["helmod_planner_main"] ~= nil then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Get or create pin tab panel
--
-- @function [parent=#Controller] getPinTabPanel
--
-- @param #LuaPlayer player
--
function Controller.methods:getPinTabPanel(player)
  Logging:trace(self:classname(), "getPinTabPanel(player):",player)
  local guiMain = player.gui[self.pinLocate]
  if guiMain["helmod_planner_pin_tab"] ~= nil and guiMain["helmod_planner_pin_tab"].valid then
    return guiMain["helmod_planner_pin_tab"]
  end
  return self:addGuiFlowH(guiMain, "helmod_planner_pin_tab", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#Controller] getInfoPanel
--
-- @param #LuaPlayer player
--
function Controller.methods:getInfoPanel(player)
  local mainPanel = self:getMainPanel(player)
  if mainPanel["helmod_planner_info"] ~= nil and mainPanel["helmod_planner_info"].valid then
    return mainPanel["helmod_planner_info"]
  end
  return self:addGuiFlowV(mainPanel, "helmod_planner_info", "helmod_flow_info")
end

-------------------------------------------------------------------------------
-- Get or create dialog panel
--
-- @function [parent=#Controller] getDialogPanel
--
-- @param #LuaPlayer player
--
function Controller.methods:getDialogPanel(player)
  local mainPanel = self:getMainPanel(player)
  if mainPanel["helmod_planner_dialog"] ~= nil and mainPanel["helmod_planner_dialog"].valid then
    return mainPanel["helmod_planner_dialog"]
  end
  return self:addGuiFlowH(mainPanel, "helmod_planner_dialog", "helmod_flow_dialog")
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#Controller] getMenuPanel
--
-- @param #LuaPlayer player
--
function Controller.methods:getMenuPanel(player)
  local menuPanel = self:getMainPanel(player)
  if menuPanel["helmod_planner_settings"] ~= nil and menuPanel["helmod_planner_settings"].valid then
    return menuPanel["helmod_planner_settings"]
  end
  return self:addGuiFlowV(menuPanel, "helmod_planner_settings", "helmod_flow_left_menu")
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#Controller] getDataPanel
--
-- @param #LuaPlayer player
--
function Controller.methods:getDataPanel(player)
  local infoPanel = self:getInfoPanel(player)
  if infoPanel["helmod_planner_data"] ~= nil and infoPanel["helmod_planner_data"].valid then
    return infoPanel["helmod_planner_data"]
  end
  local panel = self:addGuiFlowV(infoPanel, "helmod_planner_data", "helmod_flow_resize_row_width")
  self.player:setStyle(player, panel, "data", "minimal_width")
  self.player:setStyle(player, panel, "data", "maximal_width")
  return panel
end

-------------------------------------------------------------------------------
-- Refresh display data
--
-- @function [parent=#Controller] refreshDisplayData
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.methods:refreshDisplayData(player, item, item2, item3)
  Logging:debug(self:classname(), "refreshDisplayData():",player, item, item2, item3)
  self.controllers["HMMainTab"]:update(player, item, item2, item3)
  if item == "other_speed_panel" then
    local speed_panel = self.player:getSettings(player, "speed_panel", true)
    local controller = self.player.controllers["speed-controller"]
    if speed_panel == true then
      controller:cleanController(player)
      controller:bindController(player)
    else
      controller:cleanController(player)
      game.speed = 1
    end
  end
end

-------------------------------------------------------------------------------
-- Refresh display
--
-- @function [parent=#Controller] refreshDisplay
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.methods:refreshDisplay(player, item, item2, item3)
  Logging:debug(self:classname(), "refreshDisplay():",player, item, item2, item3)
  self:main(player)
  self:main(player)
end
