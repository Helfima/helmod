---
---Description of the module.
---@class EventController
local EventController = {
  ---single-line comment
  classname = "HMEventController"
}

defines.events.on_prepare=script.generate_event_name()
-------------------------------------------------------------------------------
---Start
function EventController.start()
  script.on_init(EventController.onInit)
  script.on_load(EventController.onLoad)
  script.on_configuration_changed(EventController.onConfigurationChanged)
  EventController.pcallEvent(defines.events.on_tick, EventController.onTick)
  EventController.pcallEvent(defines.events.on_gui_click, EventController.onGuiClickButton)
  EventController.pcallEvent(defines.events.on_gui_text_changed, EventController.onGuiTextChanged)
  EventController.pcallEvent(defines.events.on_prepare, EventController.onPrepare)

  EventController.pcallEvent(defines.events.on_gui_confirmed, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_value_changed, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_selection_state_changed, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_switch_state_changed, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_elem_changed, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_checked_state_changed, EventController.onGuiClick)
  EventController.pcallEvent(defines.events.on_gui_selected_tab_changed, EventController.onGuiClick)

  EventController.pcallEvent(defines.events.on_player_created, EventController.onPlayerCreated)
  EventController.pcallEvent(defines.events.on_player_joined_game, EventController.onPlayerJoinedGame)
  EventController.pcallEvent(defines.events.on_runtime_mod_setting_changed, EventController.onRuntimeModSettingChanged)
  EventController.pcallEvent(defines.events.on_console_command, EventController.onConsoleCommand)
  EventController.pcallEvent(defines.events.on_gui_location_changed, EventController.onGuiLocationChanged)

  EventController.pcallEvent(defines.events.on_string_translated, EventController.onStringTranslated)

  EventController.pcallEvent(defines.events.on_lua_shortcut, EventController.onShortcut)

  --EventController.pcallNthTick(10, EventController.onNthTick)
  ---event hotkey
  EventController.pcallEvent("helmod-close", EventController.onCustomInput)
  EventController.pcallEvent("helmod-open-close", EventController.onCustomInput)
  EventController.pcallEvent("helmod-recipe-selector-open", EventController.onCustomInput)
  EventController.pcallEvent("helmod-production-line-open", EventController.onCustomInput)
  EventController.pcallEvent("helmod-recipe-explorer-open", EventController.onCustomInput)
  EventController.pcallEvent("helmod-richtext-open", EventController.onCustomInput)
end

-------------------------------------------------------------------------------
---On input valid
---@param  event LuaEvent
function EventController.onCustomInput(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_hotkey", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
---On shortcut clicked
---@param  event LuaEvent
function EventController.onShortcut(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_shortcut", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
---EventController callback
---@param tick number
---@param callback function
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
---EventController callback
---@param event_type string
---@param callback function
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
---On init
function EventController.onInit()
  Command.start()
  Controller:on_init()
end

-------------------------------------------------------------------------------
---On load
---@param event LuaEvent
function EventController.onLoad(event)
  Command.start()
end

-------------------------------------------------------------------------------
---On Research Finished
---@param event LuaEvent
function EventController.onResearchFinished(event)
  --Cache.reset()
  --Player.print("Caches are reseted!")
end

-------------------------------------------------------------------------------
---On console command
---@param event LuaEvent
function EventController.onConsoleCommand(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Command.parse(event)
  end
end

-------------------------------------------------------------------------------
---On load
---@deprecated
---@param event LuaEvent
function EventController.onGuiClosed(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Controller:onGuiClosed(event)
  end
end

-------------------------------------------------------------------------------
---On configuration changed
---@param data table
---Data sample:
---data = {
--- "old_version":"0.14.17",
--- "new_version":"0.14.20",
--- "mod_changes":{
---   "base":{"old_version":"0.14.17","new_version":"0.14.20"},
---   "helmod":{"old_version":"0.2.14","new_version":"0.2.16"}
--- }
---}
--
function EventController.onConfigurationChanged(data)
  log("EventController.onConfigurationChanged(data)")
  if not data or not data.mod_changes then
    return
  end
  if data.mod_changes["helmod"] then
    --initialise au chargement d'une partie existante
    for _,player in pairs(game.players) do
      Player.set(player)
      Controller:cleanController(player)
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
---On Location Changed
---@param event LuaEvent
function EventController.onGuiLocationChanged(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_location", event)
  end
end

-------------------------------------------------------------------------------
---On tick
---@param event LuaEvent
function EventController.onTick(event)
  Controller:onTick(event)
end

-------------------------------------------------------------------------------
---On nth tick
---@param NthTickEvent table {tick=number, nth_tick=number}
function EventController.onNthTick(NthTickEvent)
  Controller:onNthTick(NthTickEvent)
end

-------------------------------------------------------------------------------
---On string translated
---@param event table {player_index=number, localised_ string=string, result=string, translated=boolean}
function EventController.onStringTranslated(event)
  Player.load(event)
  Controller:onStringTranslated(event)
end


-------------------------------------------------------------------------------
---On click button
---@param event LuaEvent
---Filter allowed element: "button", "sprite-button", "choose-elem-button"
---Bypass: add bypass in element.name
function EventController.onGuiClickButton(event)
  if event ~= nil and event.player_index ~= nil and event.element ~= nil and (table.contains({"button", "sprite-button", "choose-elem-button"}, event.element.type) or string.find(event.element.name, "bypass")) then
    Player.load(event)
    Dispatcher:send("on_gui_action", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
---On click event
---@param event LuaEvent
function EventController.onGuiClick(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_action", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
---On text changed
---@param event LuaEvent
function EventController.onGuiTextChanged(event)
  if event ~= nil and event.player_index ~= nil and event.element ~= nil then
    Player.load(event)
    if string.find(event.element.name, "onchange") then
      Dispatcher:send("on_gui_action", event, Controller.classname)
    end
    if string.find(event.element.name, "onqueue") then
      Dispatcher:send("on_gui_queue", event, Controller.classname)
    end
  end
end

-------------------------------------------------------------------------------
---On runtime mod settings
---@param event LuaEvent
function EventController.onRuntimeModSettingChanged(event)
  if event ~= nil and event.player_index ~= nil then
    Player.load(event)
    Dispatcher:send("on_gui_setting", event, Controller.classname)
  end
end

-------------------------------------------------------------------------------
---On player created
---@param event LuaEvent
function EventController.onPlayerCreated(event)
  if event ~= nil and event.player_index ~= nil then
    local player = Player.load(event).native()
    Controller:bindController(player)
    User.setParameter("next_event", nil)
  end
end

-------------------------------------------------------------------------------
---On player join game
---@param event LuaEvent
function EventController.onPlayerJoinedGame(event)
  if event ~= nil and event.player_index ~= nil then
    local player = Player.load(event).native()
    Controller:bindController(player)
    User.setParameter("next_event", nil)
  end
end

-------------------------------------------------------------------------------
---On prepare
---@param event LuaEvent
function EventController.onPrepare(event)
  if event ~= nil and event.player_index ~= nil then
    event.tick = game.tick
    Player.load(event)
    Dispatcher:send("on_gui_event", event, Controller.classname)
  end
end

return EventController
