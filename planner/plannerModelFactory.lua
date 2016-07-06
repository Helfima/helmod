-- model de donnees
--===========================
ModelFactory = setclass("HMModelFactory")
-- initialise
function ModelFactory.methods:init(name, count)
	if name == nil then name = "unknown-assembling-machine" end
	if count == nil then count = 0 end
	self.name = name
	self.type = "item"
	self.count = count
	self.valid = false
	self.energy_nominal = 0
	self.energy = 0
	self.energy_total = 0
	self.speed_nominal = 1
	self.speed = 1
	self.module_slots = 0
	-- module factory
	self.modules = {}
end

-- compte des modules
function ModelFactory.methods:countModules()
	local count = 0
	for name,value in pairs(self.modules) do
		count = count + value
	end
	return count
end

-- ajoute un module
function ModelFactory.methods:addModule(name)
	if self.modules[name] == nil then self.modules[name] = 0 end
	if self:countModules() < self.module_slots then
		self.modules[name] = self.modules[name] + 1
	end
end

-- supprime un module
function ModelFactory.methods:removeModule(name)
	if self.modules[name] == nil then self.modules[name] = 0 end
	if self.modules[name] > 0 then
		self.modules[name] = self.modules[name] - 1
	end
end