-- model de donnees
--===========================
ModelBeacon = setclass("HMModelBeacon")
-- initialise
function ModelBeacon.methods:init(name, count)
	if name == nil then name = "beacon" end
	if count == nil then count = 0 end
	self.name = name
	self.type = "item"
	self.count = count
	self.valid = true
	self.active = false
	self.energy_nominal = 0
	self.energy = 0
	self.energy_total = 0
	self.combo = 1
	self.factory = 2
	self.efficiency = 0.5
	self.module_slots = 2
	-- module factory
	self.modules = {}
end

-- compte des modules
function ModelBeacon.methods:countModules()
	local count = 0
	for name,value in pairs(self.modules) do
		count = count + value
	end
	return count
end

-- ajoute un module
function ModelBeacon.methods:addModule(name)
	if self.modules[name] == nil then self.modules[name] = 0 end
	if self:countModules() < self.module_slots then
		self.modules[name] = self.modules[name] + 1
	end
	if self:countModules() > 0 then
		self.active = true
	else
		self.active = false
	end
end

-- supprime un module
function ModelBeacon.methods:removeModule(name)
	if self.modules[name] == nil then self.modules[name] = 0 end
	if self.modules[name] > 0 then
		self.modules[name] = self.modules[name] - 1
	end
	if self:countModules() > 0 then
		self.active = true
	else
		self.active = false
	end
end
