---
-- Description of the module.
-- @module EventController
--
local EventController = {
  -- single-line comment
  classname = "HMEventController"
}

Event = require "core.Event"
-------------------------------------------------------------------------------
-- Start
--
-- @function [parent=#EventController] start
--
function EventController.start()
  Logging:trace(EventController.classname, "start()")

  script.on_init(EventController.onInit)
  script.on_load(EventController.onLoad)
  script.on_configuration_changed(EventController.onConfigurationChanged)
  EventController.pcallEvent("on_tick", defines.events.on_tick, EventController.onTick)
  EventController.pcallEvent("on_gui_click", defines.events.on_gui_click, EventController.onGuiClick)
  EventController.pcallEvent("on_gui_text_changed", defines.events.on_gui_text_changed, EventController.onGuiTextChanged)
  -- dropdown changed
  EventController.pcallEvent("on_gui_selection_state_changed", defines.events.on_gui_selection_state_changed, EventController.onGuiSelectionStateChanged)
  -- checked changed
  EventController.pcallEvent("on_gui_checked_state_changed", defines.events.on_gui_checked_state_changed, EventController.onGuiCheckedStateChanged)
  EventController.pcallEvent("on_player_created", defines.events.on_player_created, EventController.onPlayerCreated)
  EventController.pcallEvent("on_player_joined_game", defines.events.on_player_joined_game, EventController.onPlayerJoinedGame)
  EventController.pcallEvent("on_runtime_mod_setting_changed", defines.events.on_runtime_mod_setting_changed, EventController.onRuntimeModSettingChanged)
  EventController.pcallEvent("on_console_command", defines.events.on_console_command, EventController.onConsoleCommand)
  EventController.pcallEvent("on_research_finished", defines.events.on_research_finished, EventController.onResearchFinished)
  --EventController.pcallEvent("on_gui_closed", defines.events.on_gui_closed, EventController.onGuiClosed)

  -- event hotkey
  EventController.pcallEvent("helmod-input-valid", "helmod-input-valid", EventController.onCustomInput)
  EventController.pcallEvent("helmod-close", "helmod-close", EventController.onCustomInput)
  EventController.pcallEvent("helmod-open-close", "helmod-open-close", EventController.onCustomInput)
  EventController.pcallEvent("helmod-recipe-selector-open", "helmod-recipe-selector-open", EventController.onCustomInput)
  EventController.pcallEvent("helmod-production-line-open", "helmod-production-line-open", EventController.onCustomInput)
end

-------------------------------------------------------------------------------
-- On input valid
--
-- @function [parent=#EventController] onInputValid
--
-- @param  #table event
--
function EventController.onCustomInput(event)
  Logging:trace(EventController.classname, "onCustomInput(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    local new_event = {name=event.input_name, player_index = event.player_index}
    Event.load(new_event, "hotkey")
    Controller.parseEvent()
  end
end

-------------------------------------------------------------------------------
-- EventController callback
--
-- @function [parent=#EventController] pcallEvent
--
-- @param #string name
-- @param #lua_event event
-- @param #function callback
--
function EventController.pcallEvent(name, event, callback)
  local ok , err = pcall(function()
    script.on_event(event,callback)
  end)
  if not(ok) then
    log("Helmod: defined event "..name.." is not valid!")
    log(err)
  end
end

-------------------------------------------------------------------------------
-- On init
--
-- @function [parent=#EventController] onInit
--
-- @param  #table event
--
function EventController.onInit(event)
  Logging:trace(EventController.classname, "onInit(event)", event)
  Command.start()
end

-------------------------------------------------------------------------------
-- On load
--
-- @function [parent=#EventController] onLoad
--
-- @param #table event
--
function EventController.onLoad(event)
  Logging:trace(EventController.classname, "onLoad(event)", event)
  Command.start()
end

-------------------------------------------------------------------------------
-- On console command
--
-- @function [parent=#EventController] onConsoleCommand
--
-- @param #table event
--
function EventController.onResearchFinished(event)
  Logging:trace(EventController.classname, "onResearchFinished(event)", event)
  Controller.resetCaches()
  --Player.print("Caches are reseted!")
end

-------------------------------------------------------------------------------
-- On console command
--
-- @function [parent=#EventController] onConsoleCommand
--
-- @param #table event
--
function EventController.onConsoleCommand(event)
  Logging:trace(EventController.classname, "onConsoleCommand(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Command.parse(event)
  end
end

-------------------------------------------------------------------------------
-- On load
--
-- @function [parent=#EventController] onGuiClosed
--
-- @param #table event
--
-- @deprecated
--
function EventController.onGuiClosed(event)
  Logging:trace(EventController.classname, "onGuiClosed(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.onGuiClosed(event)
  end
end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#EventController] onConfigurationChanged
--
-- @param #table data
--
-- Data sample:
-- data = {
--  "old_version":"0.14.17","new_version":"0.14.20",
--  "mod_changes":{
--    "base":{"old_version":"0.14.17","new_version":"0.14.20"},
--    "helmod":{"old_version":"0.2.14","new_version":"0.2.16"}
--  }
-- }
--
function EventController.onConfigurationChanged(data)
  log("EventController.onConfigurationChanged(data)")
  Logging:trace(EventController.classname, "onConfigurationChanged(data)", data)
  if not data or not data.mod_changes then
    return
  end
  if data.mod_changes["helmod"] then
    --initialise au chargement d'une partie existante
    for _,player in pairs(game.players) do
      Player.set(player)
      Controller.bindController(player)
    end
  end
end

-------------------------------------------------------------------------------
-- On tick
--
-- @function [parent=#EventController] onTick
--
-- @param #table event
--
function EventController.onTick(event)
  Logging:trace(EventController.classname, "onTick(event)", event)
  Controller.onTick(event)
end

-------------------------------------------------------------------------------
-- On click event
--
-- @function [parent=#EventController] onGuiClick
--
-- @param #table event
--
function EventController.onGuiClick(event)
  Logging:debug(EventController.classname, "onGuiClick(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    local allowed = true
    if event.element ~= nil and event.element.valid and (event.element.type == "drop-down" or event.element.type == "checkbox" or event.element.type == "radiobutton") then
      allowed = false
    end
    if allowed then
      Event.load(event)
    end
  end
end

-------------------------------------------------------------------------------
-- On text changed
--
-- @function [parent=#EventController] onGuiTextChanged
--
-- @param #table event
--
function EventController.onGuiTextChanged(event)
  Logging:trace(EventController.classname, "onGuiTextChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Event.load(event)
  end
end

-------------------------------------------------------------------------------
-- On hotkey event
--
-- @function [parent=#EventController] onGuiHotkey
--
-- @param #table event
--
function EventController.onGuiHotkey(event)
  Logging:trace(EventController.classname, "onGuiHotkey(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Event.load(event, "hotkey")
  end
end

-------------------------------------------------------------------------------
-- On dropdown event
--
-- @function [parent=#EventController] onGuiSelectionStateChanged
--
-- @param event
--
function EventController.onGuiSelectionStateChanged(event)
  Logging:trace(EventController.classname, "onGuiSelectionStateChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Event.load(event, "dropdown")
  end
end

-------------------------------------------------------------------------------
-- On checkbox event
--
-- @function [parent=#EventController] onGuiCheckedStateChanged
--
-- @param event
--
function EventController.onGuiCheckedStateChanged(event)
  Logging:trace(EventController.classname, "onGuiCheckedStateChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Event.load(event, "checked")
  end
end

-------------------------------------------------------------------------------
-- On runtime mod settings
--
-- @function [parent=#EventController] onRuntimeModSettingChanged
--
-- @param event
--
function EventController.onRuntimeModSettingChanged(event)
  Logging:trace(EventController.classname, "onRuntimeModSettingChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Event.load(event, "settings")
  end
end

-------------------------------------------------------------------------------
-- On player created
--
-- @function [parent=#EventController] onPlayerCreated
--
-- @param #table event
--
function EventController.onPlayerCreated(event)
  --log("EventController.onPlayerCreated(event)")
  Logging:trace(EventController.classname, "onPlayerCreated(event)", event)
  if event ~= nil and event.player_index ~= nil then
    local player = Player.load(event).native()
    Controller.bindController(player)
  end
end

-------------------------------------------------------------------------------
-- On player join game
--
-- @function [parent=#EventController] onPlayerJoinedGame
--
-- @param #table event
--
function EventController.onPlayerJoinedGame(event)
  --log("EventController.onPlayerJoinedGame(event)")
  Logging:trace(EventController.classname, "onPlayerJoinedGame(event)", event)
  if event ~= nil and event.player_index ~= nil then
    local player = Player.load(event).native()
    Controller.bindController(player)
  end
end

return EventController
