require "planner/plannerModelGlobal"
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

-------------------------------------------------------------------------------
-- Classe model
--
-- @module PlannerModel
--
PlannerModel = setclass("HMModel")

-------------------------------------------------------------------------------
-- Initialize model
--
-- @function [parent=#PlannerModel] init
--
-- @param #PlannerController parent parent
--
function PlannerModel.methods:init(parent)
	self.parent = parent
	self.player = self.parent.parent

	self.index = 1
	-- table of inputs
	self.input = {}
	-- table of recipes
	self.recipes = {}
	-- table of ingredients (le resultat)
	self.ingredients = {}

	-- table of global for saving
	self.global = ModelGlobal:new()

	self.needPrepare = false
	self.time = 60
end

-------------------------------------------------------------------------------
-- Count recipes
--
-- @function [parent=#PlannerModel] countRepices
--
-- @return #number
--
function PlannerModel.methods:countRepices()
	local count = 0
	for key, recipe in pairs(self.recipes) do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------
-- Add a recipe
--
-- @function [parent=#PlannerModel] addInput
--
-- @param #string key recipe name
--
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


-------------------------------------------------------------------------------
-- Update a recipe
--
-- @function [parent=#PlannerModel] updateInput
--
-- @param #string key recipe name
-- @param #table products products of recipe (map product/count)
--
function PlannerModel.methods:updateInput(key, products)
	Logging:trace("updateInput:",products)
	if self.input[key] ~= nil then
		for index, product in pairs(self.input[key].products) do
			product.count = products[product.name]
		end
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a recipe
--
-- @function [parent=#PlannerModel] removeInput
--
-- @param #string key recipe name
--
function PlannerModel.methods:removeInput(key)
	local newInput = {}
	for k, recipe in pairs(self.input) do
		if recipe.name ~= key then newInput[recipe.name] = recipe end
	end
	self.input=newInput
	self.needPrepare = true
end

-------------------------------------------------------------------------------
-- Active/desactive a recipe
--
-- @function [parent=#PlannerModel] setActiveRecipe
--
-- @param #string key recipe name
--
function PlannerModel.methods:setActiveRecipe(key)
	local recipe = self.recipes[key]
	if recipe ~= nil then
		recipe.active = not(recipe.active)
	end
	self.global:setActiveRecipe(key)
	self.needPrepare = true
end

-------------------------------------------------------------------------------
-- Set the beacon
--
-- @function [parent=#PlannerModel] setBeacon
--
-- @param #string key recipe name
-- @param #string key beacon name
--
function PlannerModel.methods:setBeacon(key, name)
	if self.recipes[key] ~= nil then
		local beacon = self:getEntityPrototype(name)
		if beacon ~= nil then
			-- set global default
			self.global:setBeaconRecipe(key, beacon.name)

			self.recipes[key].beacon.name = beacon.name
			self.recipes[key].beacon.type = beacon.type
			-- copy the default parameters
			local defaultBeacon = self.global:getBeacon(beacon.name)
			if defaultBeacon ~= nil then
				self.recipes[key].beacon.energy_nominal = defaultBeacon.energy_nominal
				self.recipes[key].beacon.combo = defaultBeacon.combo
				self.recipes[key].beacon.factory = defaultBeacon.factory
				self.recipes[key].beacon.efficiency = defaultBeacon.efficiency
				self.recipes[key].beacon.module_slots = defaultBeacon.module_slots
			end
		end
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Update a beacon
--
-- @function [parent=#PlannerModel] updateBeacon
--
-- @param #string key recipe name
-- @param #table options map attribute/valeur
--
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

-------------------------------------------------------------------------------
-- Add a module in beacon
--
-- @function [parent=#PlannerModel] addBeaconModule
--
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:addBeaconModule(key, name)
	if self.recipes[key] ~= nil then
		local beacon = self.recipes[key].beacon
		beacon:addModule(name)
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a module in beacon
--
-- @function [parent=#PlannerModel] removeBeaconModule
--
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:removeBeaconModule(key, name)
	if self.recipes[key] ~= nil then
		local beacon = self.recipes[key].beacon
		beacon:removeModule(name)
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Set a factory
--
-- @function [parent=#PlannerModel] setFactory
--
-- @param #string key recipe name
-- @param #string key factory name
--
function PlannerModel.methods:setFactory(key, name)
	if self.recipes[key] ~= nil then
		local factory = self:getEntityPrototype(name)
		if factory ~= nil then
			-- set global default
			self.global:setFactoryRecipe(key, factory.name)

			self.recipes[key].factory.name = factory.name
			self.recipes[key].factory.type = factory.type
			local defaultFactory = self.global:getFactory(factory.name)
			if defaultFactory ~= nil then
				self.recipes[key].factory.energy_nominal = defaultFactory.energy_nominal
				self.recipes[key].factory.speed_nominal = defaultFactory.speed_nominal
				self.recipes[key].factory.module_slots = defaultFactory.module_slots
			end
		end
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Update a factory
--
-- @function [parent=#PlannerModel] updateFactory
--
-- @param #string key recipe name
-- @param #table options
--
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

-------------------------------------------------------------------------------
-- Add a module in factory
--
-- @function [parent=#PlannerModel] addFactoryModule
--
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:addFactoryModule(key, name)
	if self.recipes[key] ~= nil then
		local factory = self.recipes[key].factory
		factory:addModule(name)
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a module from factory
--
-- @function [parent=#PlannerModel] removeFactoryModule
--
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:removeFactoryModule(key, name)
	if self.recipes[key] ~= nil then
		local factory = self.recipes[key].factory
		factory:removeModule(name)
		self.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Reset recipes
--
-- @function [parent=#PlannerModel] recipesReset
--
function PlannerModel.methods:recipesReset()
	Logging:trace("PlannerModel:recipesReset")
	for key, recipe in pairs(self.recipes) do
		self:recipeReset(recipe)
	end
end

-------------------------------------------------------------------------------
-- Reset recipe
--
-- @function [parent=#PlannerModel] recipeReset
--
-- @param #ModelRecipe recipe
--
function PlannerModel.methods:recipeReset(recipe)
	Logging:trace("PlannerModel:recipeReset=",recipe)
	for index, product in pairs(recipe.products) do
		product.count = 0
	end
	for index, ingredient in pairs(recipe.ingredients) do
		ingredient.count = 0
	end
end

-------------------------------------------------------------------------------
-- Reset ingredients
--
-- @function [parent=#PlannerModel] ingredientsReset
--
function PlannerModel.methods:ingredientsReset()
	Logging:trace("PlannerModel:ingredientsReset")
	for k, ingredient in pairs(self.ingredients) do
		self.ingredients[ingredient.name].count = 0;
	end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#PlannerModel] update
--
function PlannerModel.methods:update()
	Logging:trace("PlannerModel:update")
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

		-- set the default factory and beacon for recipe
		for k, recipe in pairs(self.recipes) do
			local globalFactory = self.global:getFactoryRecipe(recipe.name)
			if globalFactory ~= nil then
				self:setFactory(recipe.name, globalFactory)
			end
			local globalBeacon = self.global:getBeaconRecipe(recipe.name)
			if globalBeacon ~= nil then
				self:setBeacon(recipe.name, globalBeacon)
			end
		end

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

	--	-- genere un bilan
	self:createSummary()
end

-------------------------------------------------------------------------------
-- Prepare model
--
-- @function [parent=#PlannerModel] prepare
--
-- @param #ModelRecipe recipe
-- @param #number level
--
function PlannerModel.methods:prepare(element, level)
	Logging:trace("PlannerModel:prepare=",element)
	-- incremente l'index
	self.index = self.index + 1
	if level == nil then
		level = 1
	end
	local recipes = self:searchRecipe(element.name)
	if recipes ~= nil then
		for r, recipe in pairs(recipes) do
			-- ok if recipe is active
			if self.global:isActiveRecipe(recipe.name) then
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
				if self.temp[recipe.name].ingredients ~= nil then
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
end

-------------------------------------------------------------------------------
-- Get productions list
--
-- @function [parent=#PlannerModel] getRecipeByProduct
--
-- @param #ModelRecipe recipe
--
-- @return #table
-- 
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

-------------------------------------------------------------------------------
-- Compute the model for recipes
--
-- @function [parent=#PlannerModel] craft
--
-- @param #ModelRecipe recipe
-- @param #number count number of item
-- @param #string path path of the recursive run, necessary for no infite loop
--
function PlannerModel.methods:craft(element, count, path)
	Logging:trace("PlannerModel:craft=",element, path)
	if path == nil then path = "_" end
	local recipes = self:getRecipeByProduct(element)
	local pCount = count;
	Logging:trace("rawlen(recipes)=",rawlen(recipes))
	if rawlen(recipes) > 0 then
		pCount = math.ceil(count/rawlen(recipes))
	end

	for key, recipe in pairs(recipes) do
		Logging:trace("recipe.index=",recipe.index)
		Logging:trace("recipe=",recipe)
		if not(string.find(path, "_"..recipe.index.."_")) then
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
				if recipe.beacon.valid then
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

-------------------------------------------------------------------------------
-- Compute energy, speed, number of factory for recipes
--
-- @function [parent=#PlannerModel] factoryCompute
--
-- @param #ModelRecipe recipe
--
function PlannerModel.methods:factoryCompute(recipe)
	Logging:trace("PlannerModel:factoryCompute=",recipe)

	recipe.factory.speed = recipe.factory.speed_nominal
	-- effet module factory
	for module, value in pairs(recipe.factory.modules) do
		recipe.factory.speed = recipe.factory.speed + recipe.factory.speed_nominal * value * helmod_defines.modules[module].speed
	end
	-- effet module beacon
	if recipe.beacon.valid then
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
	if recipe.beacon.valid then
		for module, value in pairs(recipe.beacon.modules) do
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
	--Logging:trace("product=",product)
	if product ~= nil then
		-- [nombre d'item] * [effort necessaire du recipe] / ([la vitesse de la factory] * [nombre produit par le recipe] * [le temps en second])
		local count = math.ceil(product.count*recipe.energy/(recipe.factory.speed*product.amount*self.time))
		recipe.factory.count = count
		if recipe.beacon.active then
			recipe.beacon.count = math.ceil(count/recipe.beacon.factory)
		else
			recipe.beacon.count = 0
		end
	end
	-- calcul des totaux
	recipe.factory.energy_total = math.ceil(recipe.factory.count*recipe.factory.energy)
	recipe.beacon.energy_total = math.ceil(recipe.factory.count*recipe.beacon.energy)
	recipe.energy_total = recipe.factory.energy_total + recipe.beacon.energy_total
	-- arrondi des valeurs
	recipe.factory.speed = math.ceil(recipe.factory.speed*100)/100
	recipe.factory.energy = math.ceil(recipe.factory.energy)
	recipe.beacon.energy = math.ceil(recipe.beacon.energy)
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number total
--
-- @function [parent=#PlannerModel] createSummary
--
function PlannerModel.methods:createSummary()
	self.summary = {}

	local energy = 0

	for k, recipe in pairs(self.recipes) do
		-- cumul de l'energie
		energy = energy + recipe.energy_total
		if recipe.name == "coal" then
			self.summary["coal"] = self:format(recipe.count)
		elseif recipe.name == "copper-ore" then
			self.summary["copper-ore"] = self:format(recipe.count)
		elseif recipe.name == "iron-ore" then
			self.summary["iron-ore"] = self:format(recipe.count)
		elseif recipe.name == "water" then
			self.summary["water"] = self:format(recipe.count)
		elseif recipe.name == "crude-oil" then
			self.summary["crude-oil"] = self:format(recipe.count)
		end
		if self.summary[recipe.factory.name] == nil then
			self.summary[recipe.factory.name] = 0
		end
		self.summary[recipe.factory.name] = self.summary[recipe.factory.name] + recipe.factory.count
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

function PlannerModel.methods:format(value)
	if value < 1000 then
		return value
	elseif (value / 1000) < 1000 then
		return math.ceil(value*10 / 1000)/10 .. " K"
	else
		return math.ceil(value*10 / (1000*1000))/10 .. " M"
	end
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
