---
-- Description of the module.
-- @module Event
--
local Event = {
  -- single-line comment
  classname = "HMEvent"
}

-------------------------------------------------------------------------------
-- Start
--
-- @function [parent=#Event] start
--
function Event.start()
  Logging:trace(Event.classname, "start()")

  script.on_init(Event.onInit)
  script.on_load(Event.onLoad)
  script.on_configuration_changed(Event.onConfigurationChanged)
  --Event.pcallEvent("on_tick", defines.events.on_tick, Event.onTick)
  Event.pcallEvent("on_gui_click", defines.events.on_gui_click, Event.onGuiClick)
  Event.pcallEvent("on_gui_text_changed", defines.events.on_gui_text_changed, Event.onGuiTextChanged)
  -- dropdown changed
  Event.pcallEvent("on_gui_selection_state_changed", defines.events.on_gui_selection_state_changed, Event.onGuiSelectionStateChanged)
  -- checked changed
  Event.pcallEvent("on_gui_checked_state_changed", defines.events.on_gui_checked_state_changed, Event.onGuiCheckedStateChanged)
  Event.pcallEvent("on_player_created", defines.events.on_player_created, Event.onPlayerCreated)
  Event.pcallEvent("on_player_joined_game", defines.events.on_player_joined_game, Event.onPlayerJoinedGame)
  Event.pcallEvent("on_runtime_mod_setting_changed", defines.events.on_runtime_mod_setting_changed, Event.onRuntimeModSettingChanged)
  Event.pcallEvent("on_console_command", defines.events.on_console_command, Event.onConsoleCommand)
  --Event.pcallEvent("on_gui_closed", defines.events.on_gui_closed, Event.onGuiClosed)

  -- event hotkey
  Event.pcallEvent("helmod-input-valid", "helmod-input-valid", Event.onCustomInput)
  Event.pcallEvent("helmod-close", "helmod-close", Event.onCustomInput)
  Event.pcallEvent("helmod-open-close", "helmod-open-close", Event.onCustomInput)
  Event.pcallEvent("helmod-recipe-selector-open", "helmod-recipe-selector-open", Event.onCustomInput)
  Event.pcallEvent("helmod-production-line-open", "helmod-production-line-open", Event.onCustomInput)
end

-------------------------------------------------------------------------------
-- On input valid
--
-- @function [parent=#Event] onInputValid
--
-- @param  #table event
--
function Event.onCustomInput(event)
  Logging:trace(Event.classname, "onCustomInput(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    local new_event = {name=event.input_name, player_index = event.player_index}
    Controller.parseEvent(new_event, "hotkey")
  end
end

-------------------------------------------------------------------------------
-- Event callback
--
-- @function [parent=#Event] pcallEvent
--
-- @param #string name
-- @param #lua_event event
-- @param #function callback
--
function Event.pcallEvent(name, event, callback)
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
-- @function [parent=#Event] onInit
--
-- @param  #table event
--
function Event.onInit(event)
  Logging:trace(Event.classname, "onInit(event)", event)
  Command.start()
end

-------------------------------------------------------------------------------
-- On load
--
-- @function [parent=#Event] onLoad
--
-- @param #table event
--
function Event.onLoad(event)
  Logging:trace(Event.classname, "onLoad(event)", event)
  Command.start()
end

-------------------------------------------------------------------------------
-- On console command
--
-- @function [parent=#Event] onConsoleCommand
--
-- @param #table event
--
function Event.onConsoleCommand(event)
  Logging:trace(Event.classname, "onConsoleCommand(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Command.parse(event)
  end
end

-------------------------------------------------------------------------------
-- On load
--
-- @function [parent=#Event] onGuiClosed
--
-- @param #table event
--
-- @deprecated
--
function Event.onGuiClosed(event)
  Logging:trace(Event.classname, "onGuiClosed(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.onGuiClosed(event)
  end
end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#Event] onConfigurationChanged
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
function Event.onConfigurationChanged(data)
  log("Event.onConfigurationChanged(data)")
  Logging:trace(Event.classname, "onConfigurationChanged(data)", data)
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
-- @function [parent=#Event] onTick
--
-- @param #table event
--
function Event.onTick(event)
  Logging:trace(Event.classname, "onTick(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.onTick(event)
  end
end

-------------------------------------------------------------------------------
-- On click event
--
-- @function [parent=#Event] onGuiClick
--
-- @param #table event
--
function Event.onGuiClick(event)
  Logging:trace(Event.classname, "onGuiClick(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    local allowed = true
    if event.element ~= nil and event.element.valid and (event.element.type == "drop-down" or event.element.type == "checkbox" or event.element.type == "radiobutton") then
      allowed = false
    end
    if allowed then
      Controller.onGuiClick(event)
    end
  end
end

-------------------------------------------------------------------------------
-- On text changed
--
-- @function [parent=#Event] onGuiTextChanged
--
-- @param #table event
--
function Event.onGuiTextChanged(event)
  Logging:trace(Event.classname, "onGuiTextChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.parseEvent(event)
  end
end

-------------------------------------------------------------------------------
-- On hotkey event
--
-- @function [parent=#Event] onGuiHotkey
--
-- @param #table event
--
function Event.onGuiHotkey(event)
  Logging:trace(Event.classname, "onGuiHotkey(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.parseEvent(event, "hotkey")
  end
end

-------------------------------------------------------------------------------
-- On dropdown event
--
-- @function [parent=#Event] onGuiSelectionStateChanged
--
-- @param event
--
function Event.onGuiSelectionStateChanged(event)
  Logging:trace(Event.classname, "onGuiSelectionStateChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.parseEvent(event, "dropdown")
  end
end

-------------------------------------------------------------------------------
-- On checkbox event
--
-- @function [parent=#Event] onGuiCheckedStateChanged
--
-- @param event
--
function Event.onGuiCheckedStateChanged(event)
  Logging:trace(Event.classname, "onGuiCheckedStateChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.parseEvent(event, "checked")
  end
end

-------------------------------------------------------------------------------
-- On runtime mod settings
--
-- @function [parent=#Event] onRuntimeModSettingChanged
--
-- @param event
--
function Event.onRuntimeModSettingChanged(event)
  Logging:trace(Event.classname, "onRuntimeModSettingChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller.parseEvent(event, "settings")
  end
end

-------------------------------------------------------------------------------
-- On player created
--
-- @function [parent=#Event] onPlayerCreated
--
-- @param #table event
--
function Event.onPlayerCreated(event)
  --log("Event.onPlayerCreated(event)")
  Logging:trace(Event.classname, "onPlayerCreated(event)", event)
  if event ~= nil and event.player_index ~= nil then
    local player = Player.load(event).native()
    Controller.bindController(player)
  end
end

-------------------------------------------------------------------------------
-- On player join game
--
-- @function [parent=#Event] onPlayerJoinedGame
--
-- @param #table event
--
function Event.onPlayerJoinedGame(event)
  --log("Event.onPlayerJoinedGame(event)")
  Logging:trace(Event.classname, "onPlayerJoinedGame(event)", event)
  if event ~= nil and event.player_index ~= nil then
    local player = Player.load(event).native()
    Controller.bindController(player)
  end
end

return Event
