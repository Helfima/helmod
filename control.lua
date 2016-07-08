pcall(function()
	require "defines"
end)
require "core.class"
require "core.defines"
require "core.logging"
require "core.elementGui"
require "player.playerController"
helmod = {}


--===========================
-- trace=4
-- debug=3
-- info=2
-- erro=1
-- nothing=0
Logging:new(1)
Logging.console = true
Logging.force = true
--===========================
function helmod:on_init(event)
	self.name = "helmod"
	--self.version = "0.1.1"
	self.loaded = false;

	self.playerControllers = {}
	
	if global.beacon == nil then
		global.beacon = helmod_defines.beacon
	end

	if global.factory == nil then
		global.factory = helmod_defines.factory
	end

end

--===========================
function helmod:on_configuration_changed(data)
	if not data or not data.mod_changes then
		return
	end
	if data.mod_changes["helmod"] then
		self:on_init()
	end
end

--===========================
function helmod:on_load(event)
	if self.loaded ~= true then
		self:on_init()
	end
end

--===========================
function helmod:on_tick(event)
	if game.tick % 60 == 0 then
		--Logging:debug("tick 60")
		if self.loaded ~= true then
			self:init_playerController()
			self.loaded = true;
			Logging:debug("global=",global)
		end
	end
	if game.tick % 300 == 0 then
		Logging:write()
	end
end

--===========================
function helmod:init_playerController()
	for key, player in pairs(game.players) do
		if player.has_game_view() then
			self.playerControllers[player.index] = PlayerController:new(player)
			self.playerControllers[player.index]:bindController()
		end
	end
end

--===========================
function helmod:on_gui_click(event)
	if self.playerControllers ~= nil then
		for r, playerControllers in pairs(self.playerControllers) do
			playerControllers:on_gui_click(event)
		end
	end
end

--===========================
function helmod:on_player_created(event)
	if self.loaded ~= true then
		self:init_playerController()
		self.loaded = true;
	end
end

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
