pcall(function()
	require "defines"
end)
require "helmod"

--===========================
function proxy_init(event)
	helmod:on_init(event)
end

function proxy_load(event)
	helmod:on_load(event)
end

function proxy_configuration_changed(data)
	helmod:on_configuration_changed(data)
end

function proxy_tick(event)
	helmod:on_tick(event)
end

function proxy_player_created(event)
	helmod:on_player_created(event)
end

function proxy_gui_click(event)
	helmod:on_gui_click(event)
end

function proxy_gui_text_changed(event)
  helmod:on_gui_text_changed(event)
end

function proxy_close_open(event)
  local new_event = {name="helmod-open-close", player_index = event.player_index}
  helmod:on_gui_hotkey(new_event)
end

function proxy_settings_open(event)
  local new_event = {name="helmod-settings-open", player_index = event.player_index}
  helmod:on_gui_hotkey(new_event)
end

function proxy_settings_display_next(event)
  local new_event = {name="helmod-settings-display-next", player_index = event.player_index}
  helmod:on_gui_hotkey(new_event)
end


script.on_init(proxy_init)
script.on_load(proxy_load)
script.on_configuration_changed(proxy_configuration_changed)
script.on_event(defines.events.on_tick, proxy_tick)
script.on_event(defines.events.on_player_created, proxy_player_created)
script.on_event(defines.events.on_gui_click,proxy_gui_click)
script.on_event(defines.events.on_gui_text_changed,proxy_gui_text_changed)

-- event hotkey
script.on_event("helmod-open-close",proxy_close_open)
script.on_event("helmod-settings-open",proxy_settings_open)
script.on_event("helmod-settings-display-next",proxy_settings_display_next)