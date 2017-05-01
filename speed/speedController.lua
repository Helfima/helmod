SpeedController = setclass("HMSpeedController")

function SpeedController.methods:init(parent)
	self.parent = parent

	self.names = {}
	self.names.command = "helmod_speed-menu-command"
	self.names.speedDown = "helmod_speed-menu-down"
	self.names.speed = "helmod_speed-menu"
	self.names.speedUp = "helmod_speed-menu-up"

	self.default = {}
	self.default.speed = {}
	self.default.speed.max = 32
	self.default.speed.min = 1

end

function SpeedController.methods:cleanController(player)
	Logging:debug("SpeedController:cleanController(player)")
	local parentGui = self.parent:getGui(player)
	if parentGui ~= nil and parentGui[self.names.command] ~= nil then
		parentGui[self.names.command].destroy()
	end
end

function SpeedController.methods:bindController(player)
	Logging:debug("SpeedController:bindController(player)")
	local globalSettings = self.parent:getGlobal(player, "settings")
	local defaultSettings = self.parent:getDefaultSettings()
	local other_speed_panel = defaultSettings.other_speed_panel
	if globalSettings.other_speed_panel ~= nil then other_speed_panel = globalSettings.other_speed_panel end

	if other_speed_panel == true and player.admin == true then
		local parentGui = self.parent:getGui(player)
		if parentGui ~= nil then
			local gui = parentGui.add({type="flow", name=self.names.command, direction="horizontal"})
			gui.add({type="button", name=self.names.speedDown, caption=({self.names.speedDown}), style="helmod_button_small_bold_start"})
			gui.add({type="button", name=self.names.speed, caption=({self.names.speed}), style="helmod_button_small_bold_middle"})
			gui.add({type="button", name=self.names.speedUp, caption=({self.names.speedUp}), style="helmod_button_small_bold_end"})
		end
	end
end

--------------------------------------------------------------------------------------
function SpeedController.methods:on_speed(option)
	Logging:trace("SpeedController:on_speed()", option)
	local speed = game.speed
	if option == nil then
		game.speed = 1
	elseif option == "+" then
		speed = speed * 2
		if speed <= self.default.speed.max then
			game.speed = speed
		end
	elseif option == "-" then
		speed = speed / 2
		if speed >= self.default.speed.min then
			game.speed = speed
		end
	end
	for key, player in pairs(game.players) do
		local parentGui = self.parent:getGui(player)
		if parentGui ~= nil then
			local gui = parentGui[self.names.command]
			if gui[self.names.speed] ~= nil and gui[self.names.speed].valid then
				gui[self.names.speed].caption = string.format("x%1.0f", game.speed)
			end
		end
	end
end

function SpeedController.methods:on_gui_click(event)
	if event.element.valid then
		if event.element.name == self.names.speedDown then
			self:on_speed("-")
		elseif event.element.name == self.names.speed then
			self:on_speed(nil)
		elseif event.element.name == self.names.speedUp then
			self:on_speed("+")
		end
	end
end

function SpeedController.methods:on_gui_text_changed(event)
	
end

function SpeedController.methods:on_gui_hotkey(event)
  
end
