require "core.global"
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

Logging:new(0)
Logging.console = false

--===========================
function helmod:on_init(event)
	self.name = "helmod"
	self.version = "0.2.2"
	self.loaded = false;

	self.playerController = PlayerController:new()

end

--===========================
function helmod:on_configuration_changed(data)
	if not data or not data.mod_changes then
		return
	end
	if data.mod_changes["helmod"] then
		if global["HMModel"] ~= nil then
			for _,player in pairs(global["HMModel"]) do
				player.isActive = false;
			end
		end
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
	if game.tick ~= 0 and game.tick % 60 == 0 then
		for key, player in pairs(game.players) do
			self:init_playerController(player)
		end
	end
end

function helmod:init_playerController(player)
	Logging:trace("helmod:init_playerController(player)")
	local globalPlayer = self.playerController:getGlobal(player)
	if globalPlayer.isActive == nil or globalPlayer.isActive == false then
		if player.valid then
			Logging:trace("bindController(player)")
			self.playerController:bindController(player)
		end
		globalPlayer.isActive = true;
	end
end

--===========================
function helmod:on_gui_click(event)
	if self.playerController ~= nil then
		local player = game.players[event.player_index]
		if self.playerController ~= nil then
			self.playerController:on_gui_click(event)
		end
	end
end

--===========================
function helmod:on_player_created(event)
	local player = game.players[event.player_index]
	self:init_playerController(player)
end
