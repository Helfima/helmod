require "planner/plannerModelRecipe"
require "planner/plannerModelFactory"
require "planner/plannerModelBeacon"
-- model de donnees
--===========================
PlannerIngredient = setclass("HMModelIngredient")
-- initialise
function PlannerIngredient.methods:init(name, count)
	self.index = 0
	if count == nil then count = 1 end
	self.name = name
	self.count = count
end

--===========================
PlannerModel = setclass("HMModel")

--===========================
-- initialisation
-----------------------------
-- @param parent
function PlannerModel.methods:init(parent)
	self.parent = parent
	self.player = self.parent.parent
	
	self.index = 1
	-- input des recipes (la selection)
	self.input = {}
	-- data des recipes
	self.recipes = {}
	-- table des ingredients (le resultat)
	self.ingredients = {}
	self.needPrepare = false
	self.time = 60
end

--===========================
-- ajoute un recipe dans l'input
-----------------------------
-- @param key - nom du recipe
function PlannerModel.methods:addInput(key)
	if self.input[key] == nil then
		local recipe = self:getRecipe(key);
		local ModelRecipe = ModelRecipe:new(recipe.name)
		ModelRecipe.energy = recipe.energy
		ModelRecipe.category = recipe.category
		ModelRecipe.group = recipe.group.name
		ModelRecipe.ingredients = recipe.ingredients
		ModelRecipe.products = recipe.products

		self.input[key] = ModelRecipe
		self:recipeReset(ModelRecipe)
		self.needPrepare = true
	else
		self.input[key].count = count
	end
end


--===========================
-- update un recipe de l'input
-----------------------------
-- @param key - nom du recipe
-- @param products - map product/count
function PlannerModel.methods:updateInput(key, products)
	Logging:debug("updateInput:",products)
	if self.input[key] ~= nil then
		for index, product in pairs(self.input[key].products) do
			product.count = products[product.name]
		end
		self.needPrepare = true
	end
end

--===========================
-- supprime un recipe
-----------------------------
-- @param key - nom du recipe
function PlannerModel.methods:removeInput(key)
	local newInput = {}
	for k, recipe in pairs(self.input) do
		if recipe.name ~= key then newInput[recipe.name] = recipe end
	end
	self.input=newInput
	self.needPrepare = true
end

--===========================
-- active/desactive un recipe
-----------------------------
-- @param key - nom du recipe
function PlannerModel.methods:setActiveRecipe(key)
	if self.recipes[key] ~= nil then
		self.recipes[key].valid = not(self.recipes[key].valid)
	end
	self.needPrepare = true
end

--===========================
-- affecte un beacon
-----------------------------
-- @param key - nom du recipe
-- @param name - nom de la factory
function PlannerModel.methods:setBeacon(key, name)
	if self.recipes[key] ~= nil then
		local beacon = self:getEntityPrototype(name)
		if beacon ~= nil then
			self.recipes[key].beacon.name = beacon.name
			self.recipes[key].beacon.type = beacon.type
			if global.beacon[name] ~= nil then
				self.recipes[key].beacon.energy_nominal = global.beacon[name].energy_nominal
				self.recipes[key].beacon.combo = global.beacon[name].combo
				self.recipes[key].beacon.factory = global.beacon[name].factory
				self.recipes[key].beacon.efficiency = global.beacon[name].efficiency
				self.recipes[key].beacon.module_slots = global.beacon[name].module_slots
			end
		end
		self.needPrepare = true
	end
end

--===========================
-- update un beacon
-----------------------------
-- @param key - nom du recipe
-- @param options - map attribute/valeur
function PlannerModel.methods:updateBeacon(key, options)
	if self.recipes[key] ~= nil then
		if options.energy_nominal ~= nil then
			self.recipes[key].beacon.energy_nominal = options.energy_nominal
		end
		if options.combo ~= nil then
			self.recipes[key].beacon.combo = options.combo
		end
		if options.factory ~= nil then
			self.recipes[key].beacon.factory = options.factory
		end
		if options.efficiency ~= nil then
			self.recipes[key].beacon.efficiency = options.efficiency
		end
		if options.module_slots ~= nil then
			self.recipes[key].beacon.module_slots = options.module_slots
		end
		self.needPrepare = true
	end
end

--===========================
-- ajoute un module
-----------------------------
-- @param key - nom du recipe
-- @param name - nom du module
function PlannerModel.methods:addBeaconModule(key, name)
	if self.recipes[key] ~= nil then
		local beacon = self.recipes[key].beacon
		beacon:addModule(name)
		self.needPrepare = true
	end
end

--===========================
-- supprime un module
-----------------------------
-- @param key - nom du recipe
-- @param name - nom du module
function PlannerModel.methods:removeBeaconModule(key, name)
	if self.recipes[key] ~= nil then
		local beacon = self.recipes[key].beacon
		beacon:removeModule(name)
		self.needPrepare = true
	end
end

--===========================
-- affecte une factory
-----------------------------
-- @param key - nom du recipe
-- @param name - nom de la factory
function PlannerModel.methods:setFactory(key, name)
	if self.recipes[key] ~= nil then
		local factory = self:getEntityPrototype(name)
		if factory ~= nil then
			self.recipes[key].factory.name = factory.name
			self.recipes[key].factory.type = factory.type
			if global.factory[name] ~= nil then
				self.recipes[key].factory.energy_nominal = global.factory[name].energy_nominal
				self.recipes[key].factory.speed_nominal = global.factory[name].speed_nominal
				self.recipes[key].factory.module_slots = global.factory[name].module_slots
			end
		end
		self.needPrepare = true
	end
end

--===========================
-- update une factory
-----------------------------
-- @param key - nom du recipe
-- @param options - map attribute/valeur
function PlannerModel.methods:updateFactory(key, options)
	if self.recipes[key] ~= nil then
		if options.energy_nominal ~= nil then
			self.recipes[key].factory.energy_nominal = options.energy_nominal
		end
		if options.speed_nominal ~= nil then
			self.recipes[key].factory.speed_nominal = options.speed_nominal
		end
		if options.module_slots ~= nil then
			self.recipes[key].factory.module_slots = options.module_slots
		end
		self.needPrepare = true
	end
end

--===========================
-- ajoute un module
-----------------------------
-- @param key - nom du recipe
-- @param name - nom du module
function PlannerModel.methods:addFactoryModule(key, name)
	if self.recipes[key] ~= nil then
		local factory = self.recipes[key].factory
		factory:addModule(name)
		self.needPrepare = true
	end
end

--===========================
-- supprime un module
-----------------------------
-- @param key - nom du recipe
-- @param name - nom du module
function PlannerModel.methods:removeFactoryModule(key, name)
	if self.recipes[key] ~= nil then
		local factory = self.recipes[key].factory
		factory:removeModule(name)
		self.needPrepare = true
	end
end
--===========================
-- initialise les compteurs
function PlannerModel.methods:recipesReset()
	Logging:trace("PlannerModel:recipesReset")
	for key, recipe in pairs(self.recipes) do
		self:recipeReset(recipe)
	end
end

--===========================
-- initialise les compteurs
function PlannerModel.methods:recipeReset(recipe)
	Logging:trace("PlannerModel:recipeReset=",recipe)
	for index, product in pairs(recipe.products) do
		product.count = 0
	end
	for index, ingredient in pairs(recipe.ingredients) do
		ingredient.count = 0
	end
end

--===========================
-- initialise les compteurs
function PlannerModel.methods:ingredientsReset()
	Logging:trace("PlannerModel:ingredientsReset")
	for k, ingredient in pairs(self.ingredients) do
		self.ingredients[ingredient.name].count = 0;
	end
end

--===========================
-- sequence de mise a jour
function PlannerModel.methods:update()
	Logging:debug("PlannerModel:update")
	if self.needPrepare then
		self.index = 1
		-- initialisation des donnees
		self.temp = {}
		self.ingredients = {}
		-- boucle recursive sur chaque recipe
		for k, item in pairs(self.input) do
			self:prepare(item)
		end
		self.recipes = self.temp
		self.needPrepare = false
	end
	-- initialise les totaux
	self:ingredientsReset()
	self:recipesReset()
	-- boucle recursive de calcul
	for k, input in pairs(self.input) do
		for index, product in pairs(input.products) do
			self:craft(product, product.count)
		end
	end

	-- calcul factory
	for k, recipe in pairs(self.recipes) do
		self:factoryCompute(recipe)
	end
	--	for k, recipe in pairs(self.recipes) do
	--		self:craft(recipe.name, recipe.count)
	--	end
	--	-- consolide les donnees comme l'energie
	--	self:factory()
	--	-- genere un bilan
	--	self:createSummary()
end

--===========================
-- boucle reccursive sur chaque recipe
-----------------------------
-- @param element - recipe
-- @param level - profondeur
function PlannerModel.methods:prepare(element, level)
	Logging:debug("PlannerModel:prepare=",element)
	-- incremente l'index
	self.index = self.index + 1
	if level == nil then
		level = 1
	end
	local recipes = self:searchRecipe(element.name)
	if recipes ~= nil then
		for r, recipe in pairs(recipes) do
			if self.recipes[recipe.name] ~= nil then
				-- le recipe existe deja on le copie
				self.temp[recipe.name] = self.recipes[recipe.name]
			else
				-- le recipe n'existe pas on le cree
				local ModelRecipe = ModelRecipe:new(recipe.name)
				ModelRecipe.energy = recipe.energy
				ModelRecipe.category = recipe.category
				ModelRecipe.group = recipe.group.name
				ModelRecipe.ingredients = recipe.ingredients
				ModelRecipe.products = recipe.products

				self.temp[recipe.name] = ModelRecipe
			end
			if self.temp[recipe.name].ingredients ~= nil and self.temp[recipe.name].valid then
				Logging:trace("ingredients:",self.temp[recipe.name].ingredients)
				for k, ingredient in pairs(self.temp[recipe.name].ingredients) do
					if self.ingredients[ingredient.name] == nil then
						self.ingredients[ingredient.name] = PlannerIngredient:new(ingredient.name)
						self:prepare(ingredient, level)
					end
				end
			end
		end
	end
end

--===========================
-- Retourne la liste des recipe des production
function PlannerModel.methods:getRecipeByProduct(element)
	Logging:trace("PlannerModel:getRecipeByProduct=",element)
	local recipes = {}
	for key, recipe in pairs(self.recipes) do
		for index, product in pairs(recipe.products) do
			if product.name == element.name then
				table.insert(recipes,recipe)
			end
		end
	end
	return recipes
end
--===========================
-- boucle reccursive sur chaque item et calcul les parametres
function PlannerModel.methods:craft(element, count, path)
	Logging:debug("PlannerModel:craft=",element, path)
	if path == nil then path = "_" end
	local recipes = self:getRecipeByProduct(element)
	local pCount = count;
	Logging:trace("rawlen(recipes)=",rawlen(recipes))
	if rawlen(recipes) > 0 then
		pCount = math.ceil(count/rawlen(recipes))
	end
	for key, recipe in pairs(recipes) do
		Logging:trace("recipe.index=",recipe.index)
		Logging:debug("recipe=",recipe)
		if recipe.valid and not(string.find(path, "_"..recipe.index.."_")) then
			local currentProduct = nil
			-- met a jour le produit
			for index, product in pairs(recipe.products) do
				if product.name == element.name then
					product.count = product.count + pCount
					currentProduct = product
				end
			end
			path = path..recipe.index.."_"

			for k, ingredient in pairs(recipe.ingredients) do
				local productNominal = currentProduct.amount
				local productUsage = currentProduct.amount
				-- calcul production module factory
				for module, value in pairs(recipe.factory.modules) do
					productUsage = productUsage + productNominal * value * helmod_defines.modules[module].productivity
				end
				if recipe.beacon.active then
					for module, value in pairs(recipe.beacon.modules) do
						productUsage = productUsage + productNominal * value * helmod_defines.modules[module].productivity * recipe.beacon.efficiency * recipe.beacon.combo
					end
				end
				local nextCount = math.ceil(pCount*(ingredient.amount/productUsage))
				ingredient.count = ingredient.count + nextCount
				self:craft(ingredient, nextCount, path)
			end
		end
	end
end
--===========================
-----------------------------
-- @param key - nom du prototype
function PlannerModel.methods:factoryCompute(recipe)
	Logging:debug("PlannerModel:factoryCompute=",recipe)
	recipe.factory.speed = recipe.factory.speed_nominal
	-- effet module factory
	for module, value in pairs(recipe.factory.modules) do
		recipe.factory.speed = recipe.factory.speed + recipe.factory.speed_nominal * value * helmod_defines.modules[module].speed
	end
	-- effet module beacon
	if recipe.beacon.active then
		for module, value in pairs(recipe.beacon.modules) do
			recipe.factory.speed = recipe.factory.speed + recipe.factory.speed_nominal * value * helmod_defines.modules[module].speed * recipe.beacon.efficiency * recipe.beacon.combo
		end
	end

	-- effet module factory
	recipe.factory.energy = recipe.factory.energy_nominal
	for module, value in pairs(recipe.factory.modules) do
		recipe.factory.energy = recipe.factory.energy + recipe.factory.energy_nominal * value * helmod_defines.modules[module].consumption
	end
	-- effet module beacon
	if recipe.beacon.active then
		for module, value in pairs(recipe.factory.modules) do
			recipe.factory.energy = recipe.factory.energy + recipe.factory.energy_nominal * value * helmod_defines.modules[module].consumption * recipe.beacon.efficiency * recipe.beacon.combo
		end
	end

	-- cap l'energy a 20%
	if recipe.factory.energy < recipe.factory.energy_nominal*0.2  then recipe.factory.energy = recipe.factory.energy_nominal*0.2 end
	-- compte le nombre de machines necessaires
	local product = nil
	for k, element in pairs(recipe.products) do
		if element.count > 0 then product = element end
	end
	Logging:debug("product=",product)
	if product ~= nil then
		-- [nombre d'item] * [effort necessaire du recipe] / ([la vitesse de la factory] * [nombre produit par le recipe] * [le temps en second])
		local count = math.ceil(product.count*recipe.energy/(recipe.factory.speed*product.amount*self.time))
		recipe.factory.count = count
		if recipe.beacon.active then
			recipe.beacon.count = count/recipe.beacon.factory
		else
			recipe.beacon.count = 0
		end
	end
	--	-- calcul des totaux
	--	idata.factory.energy_total = math.ceil(idata.factory.count*idata.factory.energy)
	--	idata.beacon.energy_total = math.ceil(idata.factory.count*idata.beacon.energy)
	--	idata.energy_total = idata.factory.energy_total + idata.beacon.energy_total
	--	-- arrondi des valeurs
	--	idata.factory.speed = math.ceil(idata.factory.speed*100)/100
	--	idata.factory.energy = math.ceil(idata.factory.energy)
	--	idata.beacon.energy = math.ceil(idata.beacon.energy)
end

--===========================
-----------------------------
-- @param key - nom du prototype
function PlannerModel.methods:getEntityPrototype(key)
	return self.parent.parent:getEntityPrototype(key)
end

--===========================
-----------------------------
-- @param key - nom du prototype
function PlannerModel.methods:getItemPrototype(key)
	return self.parent.parent:getItemPrototype(key)
end

--===========================
-----------------------------
-- @param key - nom du prototype
function PlannerModel.methods:getFluidPrototype(key)
	return self.parent.parent:getFluidPrototype(key)
end

--===========================
-----------------------------
-- @param key - nom du recipe
function PlannerModel.methods:getRecipe(key)
	return self.parent.parent:getRecipe(key)
end

--===========================
-----------------------------
-- @param key - nom du recipe
function PlannerModel.methods:searchRecipe(key)
	return self.parent.parent:searchRecipe(key)
end
