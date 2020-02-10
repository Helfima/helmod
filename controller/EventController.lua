---
-- Description of the module.
-- @module EventController
--
local EventController = {
  -- single-line comment
  classname = "HMEventController"
}

defines.events.on_prepare=script.generate_event_name()
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
  EventController.pcallEvent(defines.events.on_tick, EventController.onTick)
  EventController.pcallEvent(defines.events.on_gui_click, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_text_changed, EventController.onGuiTextChanged)
  EventController.pcallEvent(defines.events.on_prepare, EventController.onPrepare)
  
  EventController.pcallEvent(defines.events.on_gui_confirmed, EventController.onGuiConfirmed)
  EventController.pcallEvent(defines.events.on_gui_value_changed, EventController.onGuiValueChanged)
  -- dropdown changed
  EventController.pcallEvent(defines.events.on_gui_selection_state_changed, EventController.onGuiSelectionStateChanged)
  -- checked changed
  EventController.pcallEvent(defines.events.on_gui_checked_state_changed, EventController.onGuiCheckedStateChanged)
  EventController.pcallEvent(defines.events.on_player_created, EventController.onPlayerCreated)
  EventController.pcallEvent(defines.events.on_player_joined_game, EventController.onPlayerJoinedGame)
  EventController.pcallEvent(defines.events.on_runtime_mod_setting_changed, EventController.onRuntimeModSettingChanged)
  EventController.pcallEvent(defines.events.on_console_command, EventController.onConsoleCommand)
  --EventController.pcallEvent(defines.events.on_research_finished, EventController.onResearchFinished)
  --EventController.pcallEvent(defines.events.on_gui_closed, EventController.onGuiClosed)
  
  EventController.pcallEvent(defines.events.on_string_translated, EventController.onStringTranslated)

  --EventController.pcallNthTick(10, EventController.onNthTick)
  -- event hotkey
  EventController.pcallEvent("helmod-close", EventController.onCustomInput)
  EventController.pcallEvent("helmod-open-close", EventController.onCustomInput)
  EventController.pcallEvent("helmod-recipe-selector-open", EventController.onCustomInput)
  EventController.pcallEvent("helmod-production-line-open", EventController.onCustomInput)
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
    Dispatcher:send("on_gui_hotkey", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
-- EventController callback
--
-- @function [parent=#EventController] pcallNthTick
--
-- @param #number tick
-- @param #function callback
--
function EventController.pcallNthTick(tick, callback)
  local ok , err = pcall(function()
    script.on_nth_tick(tick,callback)
  end)
  if not(ok) then
    log("Helmod: defined on_nth_tick is not valid!")
    log(err)
  end
end

-------------------------------------------------------------------------------
-- EventController callback
--
-- @function [parent=#EventController] pcallEvent
--
-- @param #event_type event
-- @param #function callback
--
function EventController.pcallEvent(event_type, callback)
  local ok , err = pcall(function()
    script.on_event(event_type,callback)
  end)
  if not(ok) then
    log("Helmod: defined event "..event_type.." is not valid!")
    log(err)
  end
end

-------------------------------------------------------------------------------
-- On init
--
-- @function [parent=#EventController] onInit
--
function EventController.onInit()
  Logging:trace(EventController.classname, "onInit()")
  Command.start()
  Controller:on_init()
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
  --Cache.reset()
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
    Controller:onGuiClosed(event)
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
      Controller:bindController(player)
    end
  end
  
  Cache.reset()

  for _,player in pairs(game.players) do
    Player.set(player)
    User.resetCache()
    User.resetTranslate()
  end
  
  Controller:on_init()
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
  Controller:onTick(event)
end

-------------------------------------------------------------------------------
-- On nth tick
--
-- @function [parent=#EventController] onNthTick
--
-- @param #table NthTickEvent {tick=#number, nth_tick=#number}
--
function EventController.onNthTick(NthTickEvent)
  Logging:trace(EventController.classname, "on_nth_tick(NthTickEvent)", NthTickEvent)
  Controller:onNthTick(NthTickEvent)
end

-------------------------------------------------------------------------------
-- On string translated
--
-- @function [parent=#EventController] onStringTranslated
--
-- @param #table event {player_index=number, localised_ string=#string,result=#string, translated=#boolean}
--
function EventController.onStringTranslated(event)
  Logging:debug(EventController.classname, "onStringTranslated(event)", event)
  Player.load(event)
  Controller:onStringTranslated(event)
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
    if event.element ~= nil and event.element.valid and (event.element.type == "textfield" or event.element.type == "drop-down" or event.element.type == "checkbox" or event.element.type == "radiobutton") then
      allowed = false
    end
    if allowed then
      Logging:debug(EventController.classname, "allowed", allowed)
      --Event.load(event)
      Dispatcher:send("on_gui_action", event, Controller.classname)
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
  if event ~= nil and event.player_index ~= nil and event.element ~= nil and string.find(event.element.name, "onchange") then
    Player.load(event)
    Dispatcher:send("on_gui_action", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
-- On confirmed
--
-- @function [parent=#EventController] onGuiConfirmed
--
-- @param #table event
--
function EventController.onGuiConfirmed(event)
  Logging:trace(EventController.classname, "onGuiConfirmed(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_action", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
-- On value changed
--
-- @function [parent=#EventController] onGuiValueChanged
--
-- @param #table event
--
function EventController.onGuiValueChanged(event)
  Logging:trace(EventController.classname, "onGuiValueChanged(event)", event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_action", event, Controller.classname)
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
    Dispatcher:send("on_gui_action", event, Controller.classname)
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
    --Event.load(event, "checked")
    Dispatcher:send("on_gui_action", event, Controller.classname)
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
    Logging:updateLevel()
    Player.load(event)
    Dispatcher:send("on_gui_setting", event, Controller.classname)
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
    Controller:bindController(player)
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
    Controller:bindController(player)
  end
end

-------------------------------------------------------------------------------
-- On prepare
--
-- @function [parent=#EventController] onPrepare
--
-- @param #table event
--
function EventController.onPrepare(event)
  Logging:trace(EventController.classname, "onPrepare(event)", event)
  if event ~= nil and event.player_index ~= nil then
    event.tick = game.tick
    Player.load(event)
    Dispatcher:send("on_gui_event", event, Controller.classname)
  end
end

return EventController
