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

function pcall_event(name, event, callback)
  local ok , err = pcall(function()
    script.on_event(event,callback)
  end)
  if not(ok) then
    log("Helmod: defined event "..name.." is not valid!")
    log(err)
  end
end

script.on_init(proxy_init)
script.on_load(proxy_load)
script.on_configuration_changed(proxy_configuration_changed)
pcall_event("on_tick", defines.events.on_tick, proxy_tick)
pcall_event("on_player_created", defines.events.on_player_created, proxy_player_created)
pcall_event("on_gui_click", defines.events.on_gui_click, proxy_gui_click)
pcall_event("on_gui_text_changed", defines.events.on_gui_text_changed, proxy_gui_text_changed)
pcall_event("on_gui_selection_state_changed", defines.events.on_gui_selection_state_changed, proxy_gui_selection_state_changed)
pcall_event("on_runtime_mod_setting_changed", defines.events.on_runtime_mod_setting_changed, proxy_runtime_mod_setting_changed)
pcall_event("on_player_joined_game", defines.events.on_player_joined_game, proxy_player_joined_game)

-- event hotkey
pcall_event("helmod-open-close", "helmod-open-close", proxy_close_open)
pcall_event("helmod-recipe-selector-open", "helmod-recipe-selector-open", proxy_recipe_selector_open)
pcall_event("helmod-production-line-open", "helmod-production-line-open", proxy_production_line_open)