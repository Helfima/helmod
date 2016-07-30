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

end

-------------------------------------------------------------------------------
-- Get and initialize the model
--
-- @function [parent=#PlannerModel] getModel
--
-- @param #LuaPlayer player
--
-- @return #table
--
function PlannerModel.methods:getModel(player)
	Logging:debug("PlannerModel:getModel():",player)
	local model = self.player:getGlobal(player, "model")

	if model.input == nil then model.input = {} end
	if model.recipes == nil then model.recipes = {} end
	if model.ingredients == nil then model.ingredients = {} end
	if model.products == nil then model.products = {} end

	if model.time == nil then model.time = 60 end
	if model.needPrepare == nil then model.needPrepare = true end

	return model
end

-------------------------------------------------------------------------------
-- Create input model
--
-- @function [parent=#PlannerModel] createInputModel
--
-- @param #LuaPlayer player
--
-- @return #table
--
function PlannerModel.methods:createInputModel(player, key)
	Logging:debug("PlannerModel:createInputModel():",player, key)
	local model = self.player:getGlobal(player, "model")
	local recipe = self.player:getRecipe(player, key);

	local inputModel = {}
	inputModel.name = recipe.name
	inputModel.count = 0
	inputModel.active = true
	inputModel.energy = recipe.energy
	inputModel.category = recipe.category
	inputModel.group = recipe.group.name
	inputModel.ingredients = recipe.ingredients
	inputModel.products = recipe.products
	self:recipeReset(inputModel)

	return inputModel
end

-------------------------------------------------------------------------------
-- Create beacon model
--
-- @function [parent=#PlannerModel] createBeaconModel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #number count
--
-- @return #table
--
function PlannerModel.methods:createBeaconModel(player, name, count)
	Logging:debug("PlannerModel:createFactoryModel():",player, name, count)
	if name == nil then name = "beacon" end
	if count == nil then count = 0 end

	local beaconModel = {}
	beaconModel.name = name
	beaconModel.type = "item"
	beaconModel.active = false
	beaconModel.count = count
	beaconModel.energy_nominal = 480
	beaconModel.energy = 0
	beaconModel.energy_total = 0
	beaconModel.combo = 3
	beaconModel.factory = 2
	beaconModel.efficiency = 0.5
	beaconModel.module_slots = 2
	-- modules
	beaconModel.modules = {}

	return beaconModel
end

-------------------------------------------------------------------------------
-- Create factory model
--
-- @function [parent=#PlannerModel] createFactoryModel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #number count
--
-- @return #table
--
function PlannerModel.methods:createFactoryModel(player, name, count)
	Logging:debug("PlannerModel:createFactoryModel():",player, name, count)
	if name == nil then name = "assembling-machine-1" end
	if count == nil then count = 0 end

	local factoryModel = {}
	factoryModel.name = name
	factoryModel.type = "item"
	factoryModel.count = count
	factoryModel.energy_nominal = 90
	factoryModel.energy = 0
	factoryModel.energy_total = 0
	factoryModel.speed_nominal = 0.5
	factoryModel.speed = 0
	factoryModel.module_slots = 2
	-- modules
	factoryModel.modules = {}

	return factoryModel
end

-------------------------------------------------------------------------------
-- Create ingredient model
--
-- @function [parent=#PlannerModel] createIngredientModel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #number count
--
-- @return #table
--
function PlannerModel.methods:createIngredientModel(player, name, type, count)
	Logging:debug("PlannerModel:createIngredientModel():",player, name, count)
	if count == nil then count = 1 end

	local ingredientModel = {}
	ingredientModel.index = 1
	ingredientModel.name = name
	ingredientModel.weight = 0
	ingredientModel.type = type
	ingredientModel.count = count
	ingredientModel.recipes = {}
	ingredientModel.resource_category = nil

	local entity = self.player:getEntityPrototype(name)
	if entity ~= nil then
		ingredientModel.resource_category = entity.resource_category
	end

	return ingredientModel
end

-------------------------------------------------------------------------------
-- Count modules model
--
-- @function [parent=#PlannerModel] countModulesModel
--
-- @param #table element
--
-- @return #number
--
function PlannerModel.methods:countModulesModel(element)
	local count = 0
	for name,value in pairs(element.modules) do
		count = count + value
	end
	return count
end

-------------------------------------------------------------------------------
-- Add module model
--
-- @function [parent=#PlannerModel] addModuleModel
--
-- @param #table element
-- @param #string name
--
function PlannerModel.methods:addModuleModel(element, name)
	if element.modules[name] == nil then element.modules[name] = 0 end
	if self:countModulesModel(element) < element.module_slots then
		element.modules[name] = element.modules[name] + 1
	end
	if self:countModulesModel(element) > 0 then element.active = true end
end

-------------------------------------------------------------------------------
-- Remove module model
--
-- @function [parent=#PlannerModel] removeModuleModel
--
-- @param #table element
-- @param #string name
--
function PlannerModel.methods:removeModuleModel(element, name)
	if element.modules[name] == nil then element.modules[name] = 0 end
	if element.modules[name] > 0 then
		element.modules[name] = element.modules[name] - 1
	end
	if self:countModulesModel(element) == 0 then element.active = false end
end

-------------------------------------------------------------------------------
-- Create recipe model
--
-- @function [parent=#PlannerModel] createRecipeModel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #number count
--
-- @return #table
--
function PlannerModel.methods:createRecipeModel(player, name, count)
	Logging:debug("PlannerModel:createRecipeModel():",player, name, count)
	local model = self:getModel(player)
	if model.recipe_id == nil then model.recipe_id = 0 end
	model.recipe_id = model.recipe_id + 1

	if count == nil then count = 1 end

	local recipeModel = {}
	recipeModel.id = model.recipe_id
	recipeModel.index = 1
	recipeModel.weight = 0
	recipeModel.name = name
	recipeModel.count = count
	recipeModel.active = true
	recipeModel.energy = 0.5
	recipeModel.ingredients = {}
	recipeModel.products = {}
	recipeModel.factory = self:createFactoryModel(player)
	recipeModel.beacon = self:createBeaconModel(player)

	return recipeModel
end

-------------------------------------------------------------------------------
-- Count recipes
--
-- @function [parent=#PlannerModel] countRepices
--
-- @param #LuaPlayer player
--
-- @return #number
--
function PlannerModel.methods:countRepices(player)
	local model = self:getModel(player)
	local count = 0
	for key, recipe in pairs(model.recipes) do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------
-- Count ingredients
--
-- @function [parent=#PlannerModel] countIngredients
--
-- @param #LuaPlayer player
--
-- @return #number
--
function PlannerModel.methods:countIngredients(player)
	local model = self:getModel(player)
	local count = 0
	for key, recipe in pairs(model.ingredients) do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------
-- Count disabled recipes
--
-- @function [parent=#PlannerModel] countDisabledRecipes
--
-- @param #LuaPlayer player
--
-- @return #number
--
function PlannerModel.methods:countDisabledRecipes(player)
	local default = self:getDefault(player)
	local count = 0
	for key, recipe in pairs(default.recipes) do
		if recipe.active == false then
			count = count + 1
		end
	end
	return count
end

-------------------------------------------------------------------------------
-- Add a recipe
--
-- @function [parent=#PlannerModel] addInput
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
function PlannerModel.methods:addInput(player, key)
	Logging:debug("PlannerModel:addInput():",player, key)
	local model = self:getModel(player)

	if model.input[key] == nil then
		local ModelRecipe = self:createInputModel(player, key)
		model.input[key] = ModelRecipe
		model.needPrepare = true
	end
end


-------------------------------------------------------------------------------
-- Update a recipe
--
-- @function [parent=#PlannerModel] updateInput
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #table products products of recipe (map product/count)
--
function PlannerModel.methods:updateInput(player, key, products)
	Logging:debug("PlannerModel:updateInput():",player, key, products)
	local model = self:getModel(player)

	if model.input[key] ~= nil then
		for index, product in pairs(model.input[key].products) do
			product.count = products[product.name]
		end
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a recipe
--
-- @function [parent=#PlannerModel] removeInput
--
-- @param #string key recipe name
--
function PlannerModel.methods:removeInput(player, key)
	Logging:debug("PlannerModel:removeInput():",player, key)
	local model = self:getModel(player)

	local newInput = {}
	for k, recipe in pairs(model.input) do
		if recipe.name ~= key then newInput[recipe.name] = recipe end
	end
	model.input=newInput
	model.needPrepare = true
end

-------------------------------------------------------------------------------
-- Active/desactive a recipe
--
-- @function [parent=#PlannerModel] setActiveRecipe
--
-- @param #string key recipe name
--
function PlannerModel.methods:setActiveRecipe(player, key)
	Logging:debug("PlannerModel:setActiveRecipe():",player, key)
	local model = self:getModel(player)

	local recipe = model.recipes[key]
	if recipe ~= nil then
		recipe.active = not(recipe.active)
	end
	self:setDefaultActiveRecipe(player, key)
	model.needPrepare = true
end

-------------------------------------------------------------------------------
-- Set the beacon
--
-- @function [parent=#PlannerModel] setBeacon
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string key beacon name
--
function PlannerModel.methods:setBeacon(player, key, name)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		local beacon = self.player:getEntityPrototype(name)
		if beacon ~= nil then
			-- set global default
			self:setDefaultRecipeBeacon(player, key, beacon.name)

			model.recipes[key].beacon.name = beacon.name
			model.recipes[key].beacon.type = beacon.type
			-- copy the default parameters
			local defaultBeacon = self:getDefaultBeacon(player, beacon.name)
			if defaultBeacon ~= nil then
				model.recipes[key].beacon.energy_nominal = defaultBeacon.energy_nominal
				model.recipes[key].beacon.combo = defaultBeacon.combo
				model.recipes[key].beacon.factory = defaultBeacon.factory
				model.recipes[key].beacon.efficiency = defaultBeacon.efficiency
				model.recipes[key].beacon.module_slots = defaultBeacon.module_slots
			end
		end
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Update a beacon
--
-- @function [parent=#PlannerModel] updateBeacon
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #table options map attribute/valeur
--
function PlannerModel.methods:updateBeacon(player, key, options)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		if options.energy_nominal ~= nil then
			model.recipes[key].beacon.energy_nominal = options.energy_nominal
		end
		if options.combo ~= nil then
			model.recipes[key].beacon.combo = options.combo
		end
		if options.factory ~= nil then
			model.recipes[key].beacon.factory = options.factory
		end
		if options.efficiency ~= nil then
			model.recipes[key].beacon.efficiency = options.efficiency
		end
		if options.module_slots ~= nil then
			model.recipes[key].beacon.module_slots = options.module_slots
		end
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Add a module in beacon
--
-- @function [parent=#PlannerModel] addBeaconModule
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:addBeaconModule(player, key, name)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		local beacon = model.recipes[key].beacon
		self:addModuleModel(beacon, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a module in beacon
--
-- @function [parent=#PlannerModel] removeBeaconModule
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:removeBeaconModule(player, key, name)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		local beacon = model.recipes[key].beacon
		self:removeModuleModel(beacon, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Set a factory
--
-- @function [parent=#PlannerModel] setFactory
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string key factory name
--
function PlannerModel.methods:setFactory(player, key, name)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		local factory = self.player:getEntityPrototype(name)
		if factory ~= nil then
			-- set global default
			self:setDefaultRecipeFactory(player, key, factory.name)

			model.recipes[key].factory.name = factory.name
			model.recipes[key].factory.type = factory.type
			local defaultFactory = self:getDefaultFactory(player, factory.name)
			if defaultFactory ~= nil then
				model.recipes[key].factory.energy_nominal = defaultFactory.energy_nominal
				model.recipes[key].factory.speed_nominal = defaultFactory.speed_nominal
				model.recipes[key].factory.module_slots = defaultFactory.module_slots
			end
		end
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Update a factory
--
-- @function [parent=#PlannerModel] updateFactory
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #table options
--
function PlannerModel.methods:updateFactory(player, key, options)
	Logging:debug("PlannerModel:updateFactory():",player, key, options)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		if options.energy_nominal ~= nil then
			model.recipes[key].factory.energy_nominal = options.energy_nominal
		end
		if options.speed_nominal ~= nil then
			model.recipes[key].factory.speed_nominal = options.speed_nominal
		end
		if options.module_slots ~= nil then
			model.recipes[key].factory.module_slots = options.module_slots
		end
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Add a module in factory
--
-- @function [parent=#PlannerModel] addFactoryModule
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:addFactoryModule(player, key, name)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		local factory = model.recipes[key].factory
		self:addModuleModel(factory, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a module from factory
--
-- @function [parent=#PlannerModel] removeFactoryModule
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string key module name
--
function PlannerModel.methods:removeFactoryModule(player, key, name)
	local model = self:getModel(player)
	if model.recipes[key] ~= nil then
		local factory = model.recipes[key].factory
		self:removeModuleModel(factory, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Reset recipes
--
-- @function [parent=#PlannerModel] recipesReset
--
-- @param #LuaPlayer player
--
function PlannerModel.methods:recipesReset(player)
	Logging:debug("PlannerModel:recipesReset")
	local model = self:getModel(player)
	for key, recipe in pairs(model.recipes) do
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
	Logging:debug("PlannerModel:recipeReset=",recipe)
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
-- @param #LuaPlayer player
--
function PlannerModel.methods:ingredientsReset(player)
	Logging:debug("PlannerModel:ingredientsReset()", player)
	local model = self:getModel(player)
	for k, ingredient in pairs(model.ingredients) do
		model.ingredients[ingredient.name].count = 0;
	end
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#PlannerModel] update
--
-- @param #LuaPlayer player
-- @param #boolean force
--
function PlannerModel.methods:update(player, force)
	Logging:debug("PlannerModel:update():",player)

	local model = self:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")
	local defaultSettings = self.player:getDefaultSettings()

	if force ~= nil and force == true then
		model.needPrepare = true
	end

	local maxLoop = defaultSettings.model_loop_limit
	if globalSettings.model_loop_limit ~= nil then
		maxLoop = globalSettings.model_loop_limit
	end


	if model.needPrepare then
		model.version = helmod.version
		-- initialisation des donnees
		model.temp = {}
		-- initialisation ingredients pour les boucles
		model.ingredients = {}
		model.products = {}
		model.index = 1

		-- boucle recursive sur chaque recipe
		for k, item in pairs(model.input) do
			self:computePrepare(player, item, maxLoop)
		end
		model.recipes = model.temp

		self:computeIngredients(player)

		-- set the default factory and beacon for recipe
		for k, recipe in pairs(model.recipes) do
			local defaultFactory = self:getDefaultRecipeFactory(player, recipe.name)
			if defaultFactory ~= nil then
				self:setFactory(player, recipe.name, defaultFactory)
			end
			local defaultBeacon = self:getDefaultRecipeBeacon(player, recipe.name)
			if defaultBeacon ~= nil then
				self:setBeacon(player, recipe.name, defaultBeacon)
			end
		end

		model.needPrepare = false
	end
	Logging:debug("PlannerModel:update():","Prepare OK")
	-- initialise les totaux
	self:ingredientsReset(player)
	self:recipesReset(player)
	Logging:debug("PlannerModel:update():","Reset OK")
	model.temp = {}
	Logging:debug("model:",model)
	-- boucle recursive de calcul
	for k, input in pairs(model.input) do
		for index, product in pairs(input.products) do
			self:computeProducts(player, product, product.count)
		end
	end

	Logging:debug("PlannerModel:update():","Craft OK")
	-- calcul factory
	for k, recipe in pairs(model.recipes) do
		self:computeFactory(player, recipe)
	end

	-- calcul minig-drill
	for k, ingredient in pairs(model.ingredients) do
		if ingredient.resource_category ~= nil or ingredient.name == "water" then
			local extractor = {}
			if ingredient.resource_category == "basic-solid" then
				extractor.name = "electric-mining-drill"
				extractor.speed = 0.5
				extractor.energy = 90
			end
			if ingredient.name == "water" then
				extractor.name = "offshore-pump"
				extractor.speed = 10
				extractor.energy = 0
			end
			if ingredient.name == "crude-oil" then
				extractor.name = "pumpjack"
				extractor.speed = 1
				extractor.energy = 90
			end
			extractor.count = math.ceil(ingredient.count / (model.time * extractor.speed))
			extractor.energy_total = extractor.energy * extractor.count
			ingredient.extractor = extractor
		end
	end

	Logging:debug("PlannerModel:update():","Factory compute OK")
	-- genere un bilan
	self:createSummary(player)
	Logging:debug("PlannerModel:update():","Summary OK")
end

-------------------------------------------------------------------------------
-- Prepare model
--
-- @function [parent=#PlannerModel] computePrepare
--
-- @param #LuaPlayer player
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function PlannerModel.methods:computePrepare(player, element, maxLoop, level, path)
	Logging:debug("PlannerModel:computePrepare():",player, element, maxLoop, level, path)
	local model = self:getModel(player)
	-- stop la boucle pour les recherche trop longue
	if model.index > maxLoop then return end

	if path == nil then path = "_" end

	if level == nil then
		level = 1
	end
	-- recherche le recipe par le nom
	local recipes = self.player:searchRecipe(player, element.name)
	Logging:debug("PlannerModel:computePrepare():number recipes=",#recipes)
	if recipes ~= nil then
		Logging:debug("model.temp:",model.temp)
		for _, recipe in pairs(recipes) do
			-- ok if recipe is active
			if self:isDefaultActiveRecipe(player, recipe.name) then
				local ModelRecipe = nil
				if model.recipes[recipe.name] ~= nil then
					-- le recipe existe deja on le copie
					ModelRecipe = model.recipes[recipe.name]
				elseif model.temp[recipe.name] == nil then
					-- le recipe n'existe pas on le cree
					ModelRecipe = self:createRecipeModel(player, recipe.name)
					ModelRecipe.energy = recipe.energy
					ModelRecipe.category = recipe.category
					ModelRecipe.group = recipe.group.name
					ModelRecipe.ingredients = recipe.ingredients
					ModelRecipe.products = recipe.products
					ModelRecipe.index = model.index
				else
					ModelRecipe = model.temp[recipe.name]
				end

				-- incrementation de l'index pour pousser au plus loin le recipe
				model.index = model.index + 1
				ModelRecipe.level = level
				--ModelRecipe.index = model.index
				Logging:debug("modelRecipe reindex:",ModelRecipe)

				-- stop la boucle pour les recherche trop longue
				if model.index > maxLoop then break end

				model.temp[recipe.name] = ModelRecipe
				Logging:debug("modelRecipe:",ModelRecipe)
				-- controle dans le chemin qu'on ne boucle pas a l'infini
				-- chaque noeud de la branche creer un chemin different
				if not(string.find(path, "_"..ModelRecipe.id.."_")) then

					path = path..ModelRecipe.id.."_"

					if ModelRecipe.ingredients ~= nil then
						Logging:debug("ingredients:",ModelRecipe.ingredients)
						for k, ingredient in pairs(ModelRecipe.ingredients) do
							local entity = self.player:getEntityPrototype(ingredient.name)
							if entity == nil or entity.resource_category == nil then
								self:computePrepare(player, ingredient, maxLoop, level + 1, path)
							end
						end
					end
				end
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Prepare model
--
-- @function [parent=#PlannerModel] computeIngredients
--
-- @param #LuaPlayer player
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function PlannerModel.methods:computeIngredients(player)
	Logging:debug("PlannerModel:prepare():",player, element, maxLoop, level, path)
	local model = self:getModel(player)

	local index = 1
	for _, recipe in spairs(model.recipes, function(t,a,b) return t[b].level > t[a].level end) do
		for _, ingredient in pairs(recipe.ingredients) do
			if model.ingredients[ingredient.name] == nil then
				model.ingredients[ingredient.name] = self:createIngredientModel(player, ingredient.name, ingredient.type)
				model.ingredients[ingredient.name].index = index
				index = index + 1
			end
			local weight = recipe.level * recipe.level
			if weight > model.ingredients[ingredient.name].weight then
				model.ingredients[ingredient.name].weight = weight
			end
			table.insert(model.ingredients[ingredient.name].recipes,recipe.name)
		end
		for _, product in pairs(recipe.products) do
			if model.products[product.name] == nil then
				model.products[product.name] = self:createIngredientModel(player, product.name, product.type)
			end
			--model.products[product.name].weight = model.products[product.name].weight + recipe.level * recipe.index
			table.insert(model.products[product.name].recipes,recipe.name)
		end
	end

	for _, product in pairs(model.products) do
		if  model.ingredients[product.name] then
			product.weight = model.ingredients[product.name].weight
		end
		for _, recipe in pairs(product.recipes) do
			if product.weight > model.recipes[recipe].weight then
				model.recipes[recipe].weight = product.weight
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
function PlannerModel.methods:getRecipeByProduct(player, element)
	Logging:trace("PlannerModel:getRecipeByProduct=",element)
	local model = self:getModel(player)
	local recipes = {}
	for key, recipe in pairs(model.recipes) do
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
-- @function [parent=#PlannerModel] computeProducts
--
-- @param #LuaPlayer player
-- @param #ModelRecipe recipe
-- @param #number count number of item
-- @param #string path path of the recursive run, necessary for no infite loop
--
function PlannerModel.methods:computeProducts(player, element, count, path)
	Logging:debug("PlannerModel:computeRecipes():",element, path)
	local model = self:getModel(player)

	if path == nil then path = "_" end
	local recipes = self:getRecipeByProduct(player, element)
	local pCount = count;
	Logging:trace("rawlen(recipes)=",rawlen(recipes))
	if rawlen(recipes) > 0 then
		pCount = math.ceil(count/rawlen(recipes))
	end

	for key, recipe in pairs(recipes) do
		Logging:debug("recipe.index=",recipe.index)
		Logging:debug("recipe=",recipe)
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
				if recipe.beacon.active then
					for module, value in pairs(recipe.beacon.modules) do
						productUsage = productUsage + productNominal * value * helmod_defines.modules[module].productivity * recipe.beacon.efficiency * recipe.beacon.combo
					end
				end
				local nextCount = math.ceil(pCount*(ingredient.amount/productUsage))
				ingredient.count = ingredient.count + nextCount
				if model.ingredients[ingredient.name] == nil or model.ingredients[ingredient.name].count == nil then
					Logging:error("ingredient not found=", ingredient, "_", model.ingredients)
				end
				model.ingredients[ingredient.name].count = model.ingredients[ingredient.name].count + nextCount
				self:computeProducts(player, ingredient, nextCount, path)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number of factory for recipes
--
-- @function [parent=#PlannerModel] computeFactory
--
-- @param #LuaPlayer player
-- @param #ModelRecipe recipe
--
function PlannerModel.methods:computeFactory(player, recipe)
	Logging:trace("PlannerModel:computeFactory()",recipe)

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
	if recipe.beacon.active then
		-- effet module beacon
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
		local model = self:getModel(player)
		-- [nombre d'item] * [effort necessaire du recipe] / ([la vitesse de la factory] * [nombre produit par le recipe] * [le temps en second])
		local count = math.ceil(product.count*recipe.energy/(recipe.factory.speed*product.amount*model.time))
		recipe.factory.count = count
		if recipe.beacon.active then
			recipe.beacon.count = math.ceil(count/recipe.beacon.factory)
		else
			recipe.beacon.count = 0
		end
	end

	recipe.beacon.energy = recipe.beacon.energy_nominal
	-- calcul des totaux
	recipe.factory.energy_total = math.ceil(recipe.factory.count*recipe.factory.energy)
	recipe.beacon.energy_total = math.ceil(recipe.beacon.count*recipe.beacon.energy)
	recipe.energy_total = recipe.factory.energy_total + recipe.beacon.energy_total
	-- arrondi des valeurs
	recipe.factory.speed = math.ceil(recipe.factory.speed*100)/100
	recipe.factory.energy = math.ceil(recipe.factory.energy)
	recipe.beacon.energy = math.ceil(recipe.beacon.energy)
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number total
--
-- @param #LuaPlayer player
-- @function [parent=#PlannerModel] createSummary
--
function PlannerModel.methods:createSummary(player)
	local model = self:getModel(player)
	model.summary = {}

	local energy = 0

	for k, recipe in pairs(model.recipes) do
		-- cumul de l'energie
		energy = energy + recipe.energy_total
	end

	-- calcul minig-drill
	for k, ingredient in pairs(model.ingredients) do
		if ingredient.extractor ~= nil then
			energy = energy + ingredient.extractor.energy_total
		end
	end


	model.summary.energy = energy * 1000

	model.generators = {}
	model.generators["solar-panel"] = {name = "solar-panel", count = math.ceil(energy/60)}
	model.generators["steam-engine"] = {name = "steam-engine", count = math.ceil(energy/510)}

end

-------------------------------------------------------------------------------
-- Get and initialize the default
--
-- @function [parent=#PlannerModel] getDefault
--
-- @param #LuaPlayer player
--
-- @return #table
--
function PlannerModel.methods:getDefault(player)
	local default = self.player:getGlobal(player, "default")

	if default.factories == nil then default.factories = {} end
	if default.beacons == nil then default.beacons = {} end
	if default.recipes == nil then default.recipes = {} end

	return default
end

-------------------------------------------------------------------------------
-- Get the default recipe
--
-- @function [parent=#PlannerModel] getDefaultRecipe
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
function PlannerModel.methods:getDefaultRecipe(player, key)
	local default = self:getDefault(player)
	if default.recipes[key] == nil then
		default.recipes[key] = {
			name = key,
			active = true,
			factory = nil,
			beacon = nil
		}
	end
	return default.recipes[key]
end

-------------------------------------------------------------------------------
-- Active/desactive a recipe
--
-- @function [parent=#PlannerModel] setDefaultActiveRecipe
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
function PlannerModel.methods:setDefaultActiveRecipe(player, key)
	local recipe = self:getDefaultRecipe(player, key)
	recipe.active = not(recipe.active)
end

-------------------------------------------------------------------------------
-- Check is active recipe
--
-- @function [parent=#PlannerModel] isDefaultActiveRecipe
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
-- @return #boolean
--
function PlannerModel.methods:isDefaultActiveRecipe(player, key)
	local default = self:getDefault(player)
	if default.recipes[key] == nil then
		return true
	end
	return default.recipes[key].active
end

-------------------------------------------------------------------------------
-- Get default beacon
--
-- @function [parent=#PlannerModel] getDefaultBeacon
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
-- @return #table
--
function PlannerModel.methods:getDefaultBeacon(player, name)
	local default = self:getDefault(player)
	if default.beacons[name] == nil then
		default.beacons = helmod_defines.beacon
	end
	return default.beacons[name]
end

-------------------------------------------------------------------------------
-- Get default factory
--
-- @function [parent=#PlannerModel] getDefaultFactory
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
-- @return #table
--
function PlannerModel.methods:getDefaultFactory(player, name)
	local default = self:getDefault(player)
	if default.factories[name] == nil then
		default.factories = helmod_defines.factory
	end
	return default.factories[name]
end

-------------------------------------------------------------------------------
-- Set a factory for recipe
--
-- @function [parent=#PlannerModel] setDefaultRecipeFactory
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string name factory name
--
function PlannerModel.methods:setDefaultRecipeFactory(player, key, name)
	local recipe = self:getDefaultRecipe(player, key)
	recipe.factory = name
end

-------------------------------------------------------------------------------
-- Get the factory of recipe
--
-- @function [parent=#PlannerModel] getDefaultRecipeFactory
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
-- @return #string
--
function PlannerModel.methods:getDefaultRecipeFactory(player, key)
	local default = self:getDefault(player)
	if default.recipes[key] == nil then
		return nil
	end
	return default.recipes[key].factory
end

-------------------------------------------------------------------------------
-- Set a beacon for recipe
--
-- @function [parent=#PlannerModel] setDefaultRecipeBeacon
--
-- @param #LuaPlayer player
-- @param #string key recipe name
-- @param #string name factory name
--
function PlannerModel.methods:setDefaultRecipeBeacon(player, key, name)
	local recipe = self:getDefaultRecipe(player, key)
	recipe.beacon = name
end

-------------------------------------------------------------------------------
-- Get the beacon of recipe
--
-- @function [parent=#PlannerModel] getDefaultRecipeBeacon
--
-- @param #LuaPlayer player
-- @param #string key recipe name
--
-- @return #string
--
function PlannerModel.methods:getDefaultRecipeBeacon(player, key)
	local default = self:getDefault(player)
	if default.recipes[key] == nil then
		return nil
	end
	return default.recipes[key].beacon
end
