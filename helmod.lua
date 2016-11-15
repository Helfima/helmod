require "core.global"
require "core.class"
require "core.defines"
require "core.logging"
require "core.elementGui"
require "player.playerController"

--===========================
-- trace=4
-- debug=3
-- info=2
-- erro=1
-- nothing=0

Logging:new(3)
Logging.console = false

-------------------------------------------------------------------------------
-- Classe de mod
--
-- @module helmod
--

helmod = {}


-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] on_init
--
-- @param  #table event
--
function helmod:on_init(event)
	Logging:trace("helmod:on_init(event)", event)
	Logging:debug("helmod_data", global)
	self.name = "helmod"
	self.version = "0.2.16"

	self.playerController = PlayerController:new()
end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] on_configuration_changed
--
-- @param #table data
--
-- Data sample:
-- data = {
-- 	"old_version":"0.14.17","new_version":"0.14.20",
-- 	"mod_changes":{
-- 		"base":{"old_version":"0.14.17","new_version":"0.14.20"},
-- 		"helmod":{"old_version":"0.2.14","new_version":"0.2.16"}
-- 	}
-- }
--
function helmod:on_configuration_changed(data)
	Logging:trace("helmod:on_configuration_changed(data)", data)
	if not data or not data.mod_changes then
		return
	end
	if data.mod_changes["helmod"] then
		local old_version = data.mod_changes["helmod"].old_version
		-- Upgrade 0.2.17
		if old_version ~= nil and old_version < "0.2.17" then
			helmod:upgrade_0_2_17()
		end

		if global["HMModel"] ~= nil then
			for _,player in pairs(global["HMModel"]) do
				player.isActive = false;
			end
		end
		self:on_init()
	end
end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] on_load
--
-- @param #table event
--
function helmod:on_load(event)

end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] on_tick
--
-- @param #table event
--
function helmod:on_tick(event)
	if game.tick ~= 0 and game.tick % 60 == 0 then
		for key, player in pairs(game.players) do
			self:init_playerController(player)
		end
	end
end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] init_playerController
--
-- @param #LuaPlayer player
--
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

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] on_gui_click
--
-- @param #table event
--
function helmod:on_gui_click(event)
	if self.playerController ~= nil then
		local player = game.players[event.player_index]
		if self.playerController ~= nil then
			self.playerController:on_gui_click(event)
		end
	end
end

-------------------------------------------------------------------------------
-- On configuration changed
--
-- @function [parent=#helmod] on_player_created
--
-- @param #table event
--
function helmod:on_player_created(event)
	local player = game.players[event.player_index]
	self:init_playerController(player)
end

-------------------------------------------------------------------------------
-- Upgrade 0.2.17
--
-- @function [parent=#helmod] upgrade_0_2_17
--
-- @param #table event
--
function helmod:upgrade_0_2_17()
	if global["HMModel"] ~= nil then
		for _,data in pairs(global["HMModel"]) do
			-- remove old field
			data.model.page = nil
			data.model.step = nil
			data.model.maxPage = nil
			data.model.needPrepare = nil
			data.model.products = nil
			data.model.input = nil
			data.model.recipes = nil
			-- move gui value
			data.gui = {}
			if data.model.order ~= nil then
				data.gui.order = data.model.order
			end
			if data.model.currentTab ~= nil then
				data.gui.currentTab = data.model.currentTab
			end
			if data.model.moduleListRefresh ~= nil then
				data.gui.moduleListRefresh = data.model.moduleListRefresh
			end
			if data.model.module_panel ~= nil then
				data.gui.module_panel = data.model.module_panel
			end
			if data.recipeGroupSelected ~= nil then
				data.gui.recipeGroupSelected = data.recipeGroupSelected
			end
		end
	end
end
