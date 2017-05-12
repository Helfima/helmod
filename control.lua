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

function proxy_player_joined_game(event)
  helmod:on_player_joined_game(event)
end

function proxy_gui_click(event)
	helmod:on_gui_click(event)
end

function proxy_gui_text_changed(event)
  helmod:on_gui_text_changed(event)
end

function proxy_gui_selection_state_changed(event)
  helmod:on_gui_selection_state_changed(event)
end

function proxy_runtime_mod_setting_changed(event)
  helmod:on_runtime_mod_setting_changed(event)
end

function proxy_close_open(event)
  local new_event = {name="helmod-open-close", player_index = event.player_index}
  helmod:on_gui_hotkey(new_event)
end

function proxy_recipe_selector_open(event)
  local new_event = {name="helmod-recipe-selector-open", player_index = event.player_index}
  helmod:on_gui_hotkey(new_event)
end

function proxy_production_line_open(event)
  local new_event = {name="helmod-production-line-open", player_index = event.player_index}
  helmod:on_gui_hotkey(new_event)
end


script.on_init(proxy_init)
script.on_load(proxy_load)
script.on_configuration_changed(proxy_configuration_changed)
script.on_event(defines.events.on_tick, proxy_tick)
script.on_event(defines.events.on_player_created, proxy_player_created)
script.on_event(defines.events.on_gui_click,proxy_gui_click)
script.on_event(defines.events.on_gui_text_changed,proxy_gui_text_changed)
script.on_event(defines.events.on_gui_selection_state_changed,proxy_gui_selection_state_changed)
script.on_event(defines.events.on_runtime_mod_setting_changed,proxy_runtime_mod_setting_changed)

script.on_event(defines.events.on_player_joined_game, proxy_player_joined_game)

-- event hotkey
script.on_event("helmod-open-close",proxy_close_open)
script.on_event("helmod-recipe-selector-open",proxy_recipe_selector_open)
script.on_event("helmod-production-line-open",proxy_production_line_open)