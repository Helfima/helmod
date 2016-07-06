SpeedController = setclass("HMSpeedController")

function SpeedController.methods:init(parent)
	self.parent = parent
	self.index = 0
	
	self.names = {}
	self.names.command = "helmod_speed-menu-command"
	self.names.speedDown = "helmod_speed-menu-down"
	self.names.speed = "helmod_speed-menu"
	self.names.speedUp = "helmod_speed-menu-up"
	
	self.default = {}
	self.default.speed = {}
	self.default.speed.max = 32
	self.default.speed.min = 1
	
	self.gui = nil
end

function SpeedController.methods:cleanController()
end

function SpeedController.methods:bindController()
	if self.parent.gui ~= nil then
		self.gui = self.parent.gui.add({type="flow", name=self.names.command, direction="horizontal"})
		self.gui.add({type="button", name=self.names.speedDown, caption=({self.names.speedDown}), style="helmod_button-small-bold-start"})
		self.gui.add({type="button", name=self.names.speed, caption=({self.names.speed}), style="helmod_button-small-bold-middle"})
		self.gui.add({type="button", name=self.names.speedUp, caption=({self.names.speedUp}), style="helmod_button-small-bold-end"})
	end
end

--------------------------------------------------------------------------------------
function SpeedController.methods:on_speed(option)
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

	self.gui[self.names.speed].caption = string.format("x%1.0f", game.speed)
end

function SpeedController.methods:on_gui_click(event)
	if event.element.name == self.names.speedDown then
		self:on_speed("-")
	elseif event.element.name == self.names.speed then
		self:on_speed(nil)
	elseif event.element.name == self.names.speedUp then
		self:on_speed("+")
	end
end

