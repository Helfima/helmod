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


script.on_init(proxy_init)
script.on_load(proxy_load)
script.on_configuration_changed(proxy_configuration_changed)
script.on_event(defines.events.on_tick, proxy_tick)
script.on_event(defines.events.on_player_created, proxy_player_created)
script.on_event(defines.events.on_gui_click,proxy_gui_click)
