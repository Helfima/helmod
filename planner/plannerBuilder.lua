-- visiteur de donnees
PlannerBuilder = setclass("HMPlannerBuilder")
-- initialise
function PlannerBuilder.methods:init(parent)
	self.parent = parent
	self.index = 0
	self.time = 60 -- base de temps en second pour la production
	self.needPrepare = false
	return self
end
-- prepare un item
function PlannerBuilder.methods:newIData(key)
	local item = {}
	-- item
	item.name = key
	item.type = "unknown"
	item.count = 0
	item.energy_total = 0
	-- recipe
	item.recipe = {}
	item.recipe.valid = false
	item.recipe.energy = 0
	item.recipe.result = 1
	item.recipe.ingredients = nil
	-- factory item
	item.factory = {}
	item.factory.valid = false
	item.factory.name = "default-assembling-machine"
	item.factory.count = 0
	item.factory.energy_nominal = 0
	item.factory.energy = 0
	item.factory.energy_total = 0
	item.factory.speed_nominal = 1
	item.factory.speed = 1
	-- module factory
	item.factory.modules = {}
	item.factory.modules.slots = 0
	item.factory.modules.speed = 0
	item.factory.modules.productivity = 0
	item.factory.modules.effectivity = 0
	-- beacon item
	item.beacon = {}
	item.beacon.valid = false
	item.beacon.count = 0
	item.beacon.energy_nominal = 0
	item.beacon.energy = 0
	item.beacon.energy_total = 0
	item.beacon.combo = 1
	-- module factory
	item.beacon.modules = {}
	item.beacon.modules.slots = 0
	item.beacon.modules.speed = 0
	item.beacon.modules.productivity = 0
	item.beacon.modules.effectivity = 0
	return item
end
-- ajoute un item
function PlannerBuilder.methods:addItem(key, count)
	Logging:trace("PlannerBuilder:addItem="..key)
	if count == nil then count = 1 end
	self.items[key] = {name = key, count = count}
	self.needPrepare = true
	self:update()
end
-- supprime un item
function PlannerBuilder.methods:removeItem(key)
	local newItems = {}
	for k, item in pairs(self.items) do
		if item.name ~= key then newItems[item.name] = item end
	end
	self.items=newItems
	self.needPrepare = true
	self:update()
end
-- sequence de mise a jour
function PlannerBuilder.methods:update()
	Logging:trace("PlannerBuilder:update")
	if self.needPrepare then
		-- initialisation des donnees
		self.data = {}
		-- boucle recursive sur chaque item
		for k, item in pairs(self.items) do
			self:prepare(item.name)
		end
		self.needPrepare = false
	end
	-- initialise les totaux
	self:dataReset()
	-- boucle recursive de calcul
	for k, item in pairs(self.items) do
		self:craft(item.name, item.count)
	end
	-- consolide les donnees comme l'energie
	self:factory()
	-- genere un bilan
	self:createSummary()
end

-- boucle reccursive sur chaque item
function PlannerBuilder.methods:prepare(key, level)
	Logging:trace("PlannerBuilder:prepare="..key)
	self.index = self.index + 1
	if level == nil then
		level = 1
	end
	local item = self:getItem(key)
	if item ~= nil then
		if self.data[key] == nil then
			self.data[key] = self:newIData(key);
			self.data[key].index = self.index
			self:parseItem(key, item)
			self:parseRecipe(key, item)
		end
		local recipe = self:getRecipe(item.name)
		if recipe ~= nil then
			if recipe.ingredients ~=nil then
				for k, ingredient in pairs(recipe.ingredients) do
					self:prepare(ingredient.name, level+1)
				end
			end
		else
			Logging:error("No recipe:"..item.name)
		end
	else
		Logging:error("Not found item:"..key)
	end
end

-- boucle reccursive sur cahque item et calcul les parametres
function PlannerBuilder.methods:craft(key, count)
	Logging:trace("PlannerBuilder:craft="..key)
	if self.data[key] ~= nil then
		-- cumul d'item
		self.data[key].count = self.data[key].count + count
		if self.data[key].recipe.valid and self.data[key].recipe.ingredients ~= nil then
			-- ingredient = {type="item", name="steel-plate", amount=8}
			for k, ingredient in pairs(self.data[key].recipe.ingredients) do
				local resultNominal = self.data[key].recipe.result
				local resultUsage = self.data[key].recipe.result

				if self.data[key].factory.valid then
					local modules = self.data[key].factory.modules;
					resultUsage = resultUsage + resultNominal * modules.speed * helmod_defines.module["speed"].productivity
					resultUsage = resultUsage + resultNominal * modules.productivity * helmod_defines.module["productivity"].productivity
					resultUsage = resultUsage + resultNominal * modules.effectivity * helmod_defines.module["effectivity"].productivity
				end

				if self.data[key].beacon.valid then
					local modules = self.data[key].beacon.modules
					resultUsage = resultUsage + resultNominal * modules.speed * helmod_defines.module["speed"].productivity * 0.5
					resultUsage = resultUsage + resultNominal * modules.productivity * helmod_defines.module["productivity"].productivity * 0.5
					resultUsage = resultUsage + resultNominal * modules.effectivity * helmod_defines.module["effectivity"].productivity * 0.5
				end
				local nextCount = math.ceil(ingredient.amount*count/(resultUsage))
				self:craft(ingredient.name, nextCount)
			end
		end
	end
end

-- consolide les donnees
function PlannerBuilder.methods:factory()
	-- consolide l'energie et les speeds
	for k, idata in pairs(self.data) do
		if idata.factory.valid then
			local factoryModules = idata.factory.modules
			idata.factory.speed = idata.factory.speed_nominal
			idata.factory.speed = idata.factory.speed + idata.factory.speed_nominal * factoryModules.speed * helmod_defines.module["speed"].speed
			idata.factory.speed = idata.factory.speed + idata.factory.speed_nominal * factoryModules.productivity * helmod_defines.module["productivity"].speed
			idata.factory.speed = idata.factory.speed + idata.factory.speed_nominal * factoryModules.effectivity * helmod_defines.module["effectivity"].speed

			idata.factory.energy = idata.factory.energy_nominal
			idata.factory.energy = idata.factory.energy + idata.factory.energy_nominal * factoryModules.speed * helmod_defines.module["speed"].consumption
			idata.factory.energy = idata.factory.energy + idata.factory.energy_nominal * factoryModules.productivity * helmod_defines.module["productivity"].consumption
			idata.factory.energy = idata.factory.energy + idata.factory.energy_nominal * factoryModules.effectivity * helmod_defines.module["effectivity"].consumption

			local speedBeaconEffect = 0;
			local energyBeaconEffect = 0;
			local energyBeacon = 0;

			if idata.beacon.valid then
				local beaconModules = idata.beacon.modules
				idata.factory.speed = idata.factory.speed + idata.factory.speed_nominal * beaconModules.speed * helmod_defines.module["speed"].speed * 0.5
				idata.factory.speed = idata.factory.speed + idata.factory.speed_nominal * beaconModules.productivity * helmod_defines.module["productivity"].speed * 0.5
				idata.factory.speed = idata.factory.speed + idata.factory.speed_nominal * beaconModules.effectivity * helmod_defines.module["effectivity"].speed * 0.5

				idata.factory.energy = idata.factory.energy + idata.factory.energy_nominal * beaconModules.speed * helmod_defines.module["speed"].consumption * 0.5
				idata.factory.energy = idata.factory.energy + idata.factory.energy_nominal * beaconModules.productivity * helmod_defines.module["productivity"].consumption * 0.5
				idata.factory.energy = idata.factory.energy + idata.factory.energy_nominal * beaconModules.effectivity * helmod_defines.module["effectivity"].consumption * 0.5

				-- compte le nombre de beacon
				if beaconModules.slots > 0 then
					idata.beacon.count = math.ceil((beaconModules.speed + beaconModules.productivity + beaconModules.effectivity)/2)
				end
				if idata.beacon.combo ~= nil then
					idata.beacon.energy = idata.beacon.count * idata.beacon.energy_nominal / idata.beacon.combo
				else
					idata.beacon.energy = idata.beacon.count * idata.beacon.energy_nominal
					Logging:debug("no beacon combo for "..idata.name)
				end
			end
			-- cap l'energy a 20%
			if idata.factory.energy < idata.factory.energy_nominal*0.2  then idata.factory.energy = idata.factory.energy_nominal*0.2 end
			-- compte le nombre de machines necessaires
			-- [nombre d'item] * [effort necessaire du recipe] / ([la vitesse de la factory] * [nombre produit par le recipe] * [le temps en second])
			local count = math.ceil(idata.count*idata.recipe.energy/(idata.factory.speed*idata.recipe.result*self.time))
			idata.factory.count = count

			-- calcul des totaux
			idata.factory.energy_total = math.ceil(idata.factory.count*idata.factory.energy)
			idata.beacon.energy_total = math.ceil(idata.factory.count*idata.beacon.energy)
			idata.energy_total = idata.factory.energy_total + idata.beacon.energy_total
			-- arrondi des valeurs
			idata.factory.speed = math.ceil(idata.factory.speed*100)/100
			idata.factory.energy = math.ceil(idata.factory.energy)
			idata.beacon.energy = math.ceil(idata.beacon.energy)
		end
	end
end

function PlannerBuilder.methods:createSummary()
	self.summary = {}

	local energy = 0

	for k, idata in pairs(self.data) do
		-- cumul de l'energie
		energy = energy + idata.energy_total
		if idata.name == "coal" then
			self.summary["coal"] = self:format(idata.count)
		elseif idata.name == "copper-ore" then
			self.summary["copper-ore"] = self:format(idata.count)
		elseif idata.name == "iron-ore" then
			self.summary["iron-ore"] = self:format(idata.count)
		elseif idata.name == "water" then
			self.summary["water"] = self:format(idata.count)
		elseif idata.name == "crude-oil" then
			self.summary["crude-oil"] = self:format(idata.count)
		end
		if self.summary[idata.factory.name] == nil then
			self.summary[idata.factory.name] = 0
		end
		self.summary[idata.factory.name] = self.summary[idata.factory.name] + idata.factory.count
	end
	if energy < 1000 then
		self.summary.energy = energy .. " KW"
	elseif (energy / 1000) < 1000 then
		self.summary.energy = math.ceil(energy*10 / 1000)/10 .. " MW"
	else
		self.summary.energy = math.ceil(energy*10 / (1000*1000))/10 .. " GW"
	end
	self.summary["solar-panel"] = self:format(math.ceil(energy/60))
	self.summary["steam-engine"] = self:format(math.ceil(energy/510))

end

function PlannerBuilder.methods:format(value)
	if value < 1000 then
		return value
	elseif (value / 1000) < 1000 then
		return math.ceil(value*10 / 1000)/10 .. " K"
	else
		return math.ceil(value*10 / (1000*1000))/10 .. " M"
	end
end

function PlannerBuilder.methods:dataReset()
	for k, idata in pairs(self.data) do
		self.data[idata.name].count = 0;
	end
end


-- parcours l'item
function PlannerBuilder.methods:parseItem(key, idata)
	--Logging:trace("PlannerBuilder:parseItem="..key)
	self.data[key].name = idata.name
	self.data[key].type = idata.type
end

-- parcours le parchemin
function PlannerBuilder.methods:parseRecipe(key, idata)
	--Logging:trace("PlannerBuilder:parseRecipe="..key)
	local recipe = self:getRecipe(idata.name)
	if recipe ~= nil then
		self.data[key].recipe.valid = true
		self.data[key].recipe.energy = recipe.energy
		self.data[key].recipe.result = 1
		self:parseAssembly(key, recipe)
		-- ingredient = {type="item", name="steel-plate", amount=8}
		if self.data[key].recipe.ingredients == nil then
			self.data[key].recipe.ingredients = recipe.ingredients
		end
		-- product = {type="item", name="steel-plate", amount=8}
		if self.data[key].products == nil then
			self.data[key].products = recipe.products
			for k, product in pairs(self.data[key].products) do
				if product.name == key then
					self.data[key].recipe.result = product.amount
				end
			end
		end
	end
end

-- parcours l'usine
function PlannerBuilder.methods:parseAssembly(key, idata)
	Logging:trace("PlannerBuilder:parseAssembly="..key)
	local factory = nil
	local beacon = nil
	if idata.category ~= nil then
		-- recuperation de la factory
		factory = helmod_defines.factory[idata.category]
		beacon = helmod_defines.beacon[idata.category]
	end
	-- sinon on prend la factory defaut
	if factory == nil then
		Logging:debug("No factory for "..key)
		factory = helmod_defines.factory["unknown-assembling-machine"]
	end
	self.data[key].factory.name = factory.name
	self.data[key].factory.energy_nominal = factory.energy_usage
	self.data[key].factory.modules.slots = factory.module_slots
	self.data[key].factory.speed_nominal = factory.crafting_speed
	self.data[key].factory.valid = true
	-- sinon on prend la factory defaut
	if beacon == nil then
		beacon = helmod_defines.beacon["default-assembling-machine"]
	end

	self.data[key].beacon.name = beacon.name
	self.data[key].beacon.energy_nominal = beacon.energy_usage
	self.data[key].beacon.modules.slots = beacon.module_slots
	self.data[key].beacon.combo = beacon.combo
	self.data[key].beacon.valid = true
end

function PlannerBuilder.methods:getForce()
	return self.parent.parent:getForce()
end

function PlannerBuilder.methods:getRecipe(key)
	Logging:trace("PlannerBuilder:getRecipe="..key)
	local recipe = self:getForce().recipes[key]
	-- recipe pour le fonctionnement
	--if key == "petroleum-gas" or key == "light-oil" or key == "heavy-oil" then
	--	recipe = self:getForce().recipes["advanced-oil-processing"]
	--end
	--if key == "light-oil" then
	--	recipe = self:getForce().recipes["heavy-oil-cracking"]
	--end
	--if key == "solid-fuel" then
	--	recipe = self:getForce().recipes["solid-fuel-from-light-oil"]
	--end


	if recipe == nil then
		recipe = helmod_defines.recipes[key]
	end
	return recipe
end

function PlannerBuilder.methods:setEffect(effect, key)
	Logging:debug("PlannerBuilder:setEffect="..key)
	if self.data[key] ~= nil and self.data[key].factory.valid then
		local factoryModules= self.data[key].factory.modules
		local beaconModules= self.data[key].beacon.modules

		local factoryModule = factoryModules.speed + factoryModules.productivity + factoryModules.effectivity
		local beaconModule = beaconModules.speed + beaconModules.productivity + beaconModules.effectivity

		if effect == "factory-module-speed" then
			if factoryModule < self.data[key].factory.modules.slots then
				factoryModules.speed = factoryModules.speed + 1
			else
				factoryModules.speed = 0
			end
		elseif effect == "factory-module-productivity" then
			if factoryModule < self.data[key].factory.modules.slots then
				factoryModules.productivity = factoryModules.productivity + 1
			else
				factoryModules.productivity = 0
			end
		elseif effect == "factory-module-effectivity" then
			if factoryModule < self.data[key].factory.modules.slots then
				factoryModules.effectivity = factoryModules.effectivity + 1
			else
				factoryModules.effectivity = 0
			end
		elseif effect == "beacon-module-speed" then
			if beaconModule < self.data[key].beacon.modules.slots then
				beaconModules.speed = beaconModules.speed + 1
			else
				beaconModules.speed = 0
			end
		elseif effect == "beacon-module-productivity" then
			if beaconModule < self.data[key].beacon.modules.slots then
				beaconModules.productivity = beaconModules.productivity + 1
			else
				beaconModules.productivity = 0
			end
		elseif effect == "beacon-module-effectivity" then
			if beaconModule < self.data[key].beacon.modules.slots then
				beaconModules.effectivity = beaconModules.effectivity + 1
			else
				beaconModules.effectivity = 0
			end
		end
		self:update()
	end
end

function PlannerBuilder.methods:getItem(key)
	Logging:trace("search item:"..key)
	local item = game.get_item_prototype(key)
	if item == nil then
		item = helmod_defines.items[key]
	end
	return item
end
