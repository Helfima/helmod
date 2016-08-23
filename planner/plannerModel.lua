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
	Logging:trace("PlannerModel:getModel():",player)
	local model = self.player:getGlobal(player, "model")

	if model.blocks == nil then model.blocks = {} end

	if model.ingredients == nil then model.ingredients = {} end

	if model.time == nil then model.time = 60 end

	-- delete the old version item
	if model.products ~= nil then model.products = nil end
	if model.input ~= nil then model.input = nil end
	if model.recipes ~= nil then model.recipes = nil end
	if model.needPrepare ~= nil then model.needPrepare = nil end

	return model
end

-------------------------------------------------------------------------------
-- Create Production Block model
--
-- @function [parent=#PlannerModel] createProductionBlockModel
--
-- @param #LuaPlayer player
-- @param #LuaRecipePrototype recipe
--
-- @return #table
--
function PlannerModel.methods:createProductionBlockModel(player, recipe)
	Logging:debug("PlannerModel:createProductionBlockModel():",player, recipe)
	local model = self.player:getGlobal(player, "model")

	if model.block_id == nil then model.block_id = 0 end
	model.block_id = model.block_id + 1

	local inputModel = {}
	inputModel.id = "block_"..model.block_id
	inputModel.name = recipe.name
	inputModel.count = 1
	inputModel.active = true
	inputModel.power = 0
	inputModel.ingredients = {}
	inputModel.products = {}
	inputModel.recipes = {}

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
	-- limit infini = 0
	factoryModel.limit = 0
	factoryModel.limit_count = count
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
	if count == nil then count = 0 end

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
-- Count blocks
--
-- @function [parent=#PlannerModel] countBlocks
--
-- @param #LuaPlayer player
--
-- @return #number
--
function PlannerModel.methods:countBlocks(player)
	local model = self:getModel(player)
	local count = 0
	for key, recipe in pairs(model.blocks) do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------
-- Count block recipes
--
-- @function [parent=#PlannerModel] countBlockRecipes
--
-- @param #LuaPlayer player
-- @param #string blockId
--
-- @return #number
--
function PlannerModel.methods:countBlockRecipes(player, blockId)
	Logging:debug("PlannerModel:countBlockRecipes():",player, blockId)
	local model = self:getModel(player)
	local count = 0
	if model.blocks[blockId] ~= nil then
		for key, recipe in pairs(model.blocks[blockId].recipes) do
			count = count + 1
		end
	end
	return count
end

-------------------------------------------------------------------------------
-- Count in list
--
-- @function [parent=#PlannerModel] countList
--
-- @param #table list
--
-- @return #number
--
function PlannerModel.methods:countList(list)
	local count = 0
	for key, recipe in pairs(list) do
		count = count + 1
	end
	return count
end

-------------------------------------------------------------------------------
-- Add a recipe into production block
--
-- @function [parent=#PlannerModel] addRecipeIntoProductionBlock
--
-- @param #LuaPlayer player
-- @param #string blockId production block id
-- @param #string key recipe name
--
function PlannerModel.methods:addRecipeIntoProductionBlock(player, blockId, key)
	Logging:debug("PlannerModel:addRecipeIntoProductionBlock():",player, blockId, key)
	local model = self:getModel(player)
	local recipe = self.player:getRecipe(player, key);

	if model.blocks[blockId] == nil then
		local modelBlock = self:createProductionBlockModel(player, recipe)
		local index = self:countBlocks(player)
		modelBlock.index = index
		model.blocks[modelBlock.id] = modelBlock
		blockId = modelBlock.id
	end

	if model.blocks[blockId].recipes[key] == nil then
		local ModelRecipe = self:createRecipeModel(player, recipe.name, 0)
		local index = self:countBlockRecipes(player, blockId)
		ModelRecipe.energy = recipe.energy
		ModelRecipe.category = recipe.category
		ModelRecipe.group = recipe.group.name
		ModelRecipe.ingredients = recipe.ingredients
		ModelRecipe.products = recipe.products
		ModelRecipe.index = index
		self:recipeReset(ModelRecipe)
		-- ajoute les produits du block
		for _, product in pairs(ModelRecipe.products) do
			model.blocks[blockId].products[product.name] = product
		end

		-- ajoute les ingredients du block
		for _, ingredient in pairs(ModelRecipe.ingredients) do
			model.blocks[blockId].ingredients[ingredient.name] = ingredient
		end
		model.blocks[blockId].recipes[key] = ModelRecipe
	end

	local defaultFactory = self:getDefaultRecipeFactory(player, recipe.name)
	if defaultFactory ~= nil then
		self:setFactory(player, blockId, recipe.name, defaultFactory)
	end
	local defaultBeacon = self:getDefaultRecipeBeacon(player, recipe.name)
	if defaultBeacon ~= nil then
		self:setBeacon(player, blockId, recipe.name, defaultBeacon)
	end
	return model.blocks[blockId]
end

-------------------------------------------------------------------------------
-- Update a product
--
-- @function [parent=#PlannerModel] updateProduct
--
-- @param #LuaPlayer player
-- @param #string blockId production block id
-- @param #string key product name
-- @param #number quantity
--
function PlannerModel.methods:updateProduct(player, blockId, key, quantity)
	Logging:debug("PlannerModel:updateProduct():",player, blockId, key, quantity)
	local model = self:getModel(player)

	if model.blocks[blockId] ~= nil then
		local product = nil
		for _, product in pairs(model.blocks[blockId].products) do
			if product.name == key then
				product.count = quantity
			end
		end
	end
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
-- @param #string blockId
-- @param #string key recipe name
-- @param #string name beacon name
--
function PlannerModel.methods:setBeacon(player, blockId, key, name)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		local beacon = self.player:getEntityPrototype(name)
		if beacon ~= nil then
			-- set global default
			self:setDefaultRecipeBeacon(player, key, beacon.name)

			recipe.beacon.name = beacon.name
			recipe.beacon.type = beacon.type
			-- copy the default parameters
			local defaultBeacon = self:getDefaultBeacon(player, beacon.name)
			if defaultBeacon ~= nil then
				recipe.beacon.energy_nominal = defaultBeacon.energy_nominal
				recipe.beacon.combo = defaultBeacon.combo
				recipe.beacon.factory = defaultBeacon.factory
				recipe.beacon.efficiency = defaultBeacon.efficiency
				recipe.beacon.module_slots = defaultBeacon.module_slots
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
-- @param #string blockId
-- @param #string key recipe name
-- @param #table options map attribute/valeur
--
function PlannerModel.methods:updateBeacon(player, blockId, key, options)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		if options.energy_nominal ~= nil then
			recipe.beacon.energy_nominal = options.energy_nominal
		end
		if options.combo ~= nil then
			recipe.beacon.combo = options.combo
		end
		if options.factory ~= nil then
			recipe.beacon.factory = options.factory
		end
		if options.efficiency ~= nil then
			recipe.beacon.efficiency = options.efficiency
		end
		if options.module_slots ~= nil then
			recipe.beacon.module_slots = options.module_slots
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
-- @param #string blockId
-- @param #string key recipe name
-- @param #string name module name
--
function PlannerModel.methods:addBeaconModule(player, blockId, key, name)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		self:addModuleModel(recipe.beacon, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a module in beacon
--
-- @function [parent=#PlannerModel] removeBeaconModule
--
-- @param #LuaPlayer player
-- @param #string blockId
-- @param #string key recipe name
-- @param #string name module name
--
function PlannerModel.methods:removeBeaconModule(player, blockId, key, name)
	local model = self:getModel(player)
	if model.blocks[blockId].recipes[key] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		self:removeModuleModel(recipe.beacon, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Set a factory
--
-- @function [parent=#PlannerModel] setFactory
--
-- @param #LuaPlayer player
-- @param #string blockId
-- @param #string key recipe name
-- @param #string name factory name
--
function PlannerModel.methods:setFactory(player, blockId, key, name)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		local factory = self.player:getEntityPrototype(name)
		if factory ~= nil then
			-- set global default
			self:setDefaultRecipeFactory(player, key, factory.name)

			recipe.factory.name = factory.name
			recipe.factory.type = factory.type
			local defaultFactory = self:getDefaultFactory(player, factory.name)
			if defaultFactory ~= nil then
				recipe.factory.energy_nominal = defaultFactory.energy_nominal
				recipe.factory.speed_nominal = defaultFactory.speed_nominal
				recipe.factory.module_slots = defaultFactory.module_slots
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
-- @param #string blockId
-- @param #string key recipe name
-- @param #table options
--
function PlannerModel.methods:updateFactory(player, blockId, key, options)
	Logging:debug("PlannerModel:updateFactory():",player, blockId, key, options)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		if options.energy_nominal ~= nil then
			recipe.factory.energy_nominal = options.energy_nominal
		end
		if options.speed_nominal ~= nil then
			recipe.factory.speed_nominal = options.speed_nominal
		end
		if options.module_slots ~= nil then
			recipe.factory.module_slots = options.module_slots
		end
		if options.limit ~= nil then
			recipe.factory.limit = options.limit
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
-- @param #string blockId
-- @param #string key recipe name
-- @param #string name module name
--
function PlannerModel.methods:addFactoryModule(player, blockId, key, name)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		self:addModuleModel(recipe.factory, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a module from factory
--
-- @function [parent=#PlannerModel] removeFactoryModule
--
-- @param #LuaPlayer player
-- @param #string blockId
-- @param #string key recipe name
-- @param #string name module name
--
function PlannerModel.methods:removeFactoryModule(player, blockId, key, name)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		local recipe = model.blocks[blockId].recipes[key]
		self:removeModuleModel(recipe.factory, name)
		model.needPrepare = true
	end
end

-------------------------------------------------------------------------------
-- Remove a production block
--
-- @function [parent=#PlannerModel] removeProductionBlock
--
-- @param #LuaPlayer player
-- @param #string blockId
--
function PlannerModel.methods:removeProductionBlock(player, blockId)
	Logging:debug("PlannerModel:removeProductionBlock()",player, blockId)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil then
		model.blocks[blockId] = nil
		self:reIndexList(model.blocks)
	end
end

-------------------------------------------------------------------------------
-- Remove a production recipe
--
-- @function [parent=#PlannerModel] removeProductionRecipe
--
-- @param #LuaPlayer player
-- @param #string blockId
-- @param #string key
--
function PlannerModel.methods:removeProductionRecipe(player, blockId, key)
	Logging:debug("PlannerModel:removeProductionRecipe()",player, blockId, key)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		model.blocks[blockId].recipes[key] = nil
		self:reIndexList(model.blocks[blockId].recipes)
	end
end

-------------------------------------------------------------------------------
-- Reindex list
--
-- @function [parent=#PlannerModel] reIndexList
--
-- @param #table list
--
function PlannerModel.methods:reIndexList(list)
	Logging:debug("PlannerModel:reIndexList()",list)
	local index = 0
	for _,element in spairs(list,function(t,a,b) return t[b].index > t[a].index end) do
		element.index = index
		index = index + 1
	end
end

-------------------------------------------------------------------------------
-- Up a production block
--
-- @function [parent=#PlannerModel] upProductionBlock
--
-- @param #LuaPlayer player
-- @param #string blockId
--
function PlannerModel.methods:upProductionBlock(player, blockId)
	Logging:debug("PlannerModel:upProductionBlock()",player, blockId)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil then
		self:upProductionList(player, model.blocks, model.blocks[blockId].index)
	end
end

-------------------------------------------------------------------------------
-- Up a production recipe
--
-- @function [parent=#PlannerModel] upProductionRecipe
--
-- @param #LuaPlayer player
-- @param #string blockId
-- @param #string key
--
function PlannerModel.methods:upProductionRecipe(player, blockId, key)
	Logging:debug("PlannerModel:upProductionRecipe()",player, blockId, key)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		self:upProductionList(player, model.blocks[blockId].recipes, model.blocks[blockId].recipes[key].index)
	end
end

-------------------------------------------------------------------------------
-- Up in the list
--
-- @function [parent=#PlannerModel] upProductionList
--
-- @param #LuaPlayer player
-- @param #table list
-- @param #number index
--
function PlannerModel.methods:upProductionList(player, list, index)
	Logging:debug("PlannerModel:upProductionList()",player, list, index)
	local model = self:getModel(player)
	if list ~= nil and index > 0 then
		for _,element in pairs(list) do
			if element.index == index then
				element.index = element.index - 1
			elseif element.index == index - 1 then
				element.index = element.index + 1
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Down a production block
--
-- @function [parent=#PlannerModel] downProductionBlock
--
-- @param #LuaPlayer player
-- @param #string blockId
--
function PlannerModel.methods:downProductionBlock(player, blockId)
	Logging:debug("PlannerModel:downProductionBlock()",player, blockId)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil then
		self:downProductionList(player, model.blocks, model.blocks[blockId].index)
	end
end

-------------------------------------------------------------------------------
-- Down a production recipe
--
-- @function [parent=#PlannerModel] downProductionRecipe
--
-- @param #LuaPlayer player
-- @param #string blockId
-- @param #string key
--
function PlannerModel.methods:downProductionRecipe(player, blockId, key)
	Logging:debug("PlannerModel:downProductionRecipe()",player, blockId, key)
	local model = self:getModel(player)
	if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
		self:downProductionList(player, model.blocks[blockId].recipes, model.blocks[blockId].recipes[key].index)
	end
end

-------------------------------------------------------------------------------
-- Down in the list
--
-- @function [parent=#PlannerModel] downProductionList
--
-- @param #LuaPlayer player
-- @param #table list
-- @param #number index
--
function PlannerModel.methods:downProductionList(player, list, index)
	Logging:debug("PlannerModel:downProductionList()",player, list, index)
	local model = self:getModel(player)
	Logging:debug("PlannerModel:downProductionList()",self:countList(list))
	if list ~= nil and index + 1 < self:countList(list) then
		for _,element in pairs(list) do
			if element.index == index then
				element.index = element.index + 1
			elseif element.index == index + 1 then
				element.index = element.index - 1
			end
		end
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
-- @function [parent=#PlannerModel] update2
--
-- @param #LuaPlayer player
-- @param #boolean force
--
function PlannerModel.methods:update2(player, force)
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
-- Update model
--
-- @function [parent=#PlannerModel] update
--
-- @param #LuaPlayer player
-- @param #boolean force
--
function PlannerModel.methods:update(player, force)
	Logging:debug("**********PlannerModel:update():",player)

	local model = self:getModel(player)
	local globalSettings = self.player:getGlobal(player, "settings")
	local defaultSettings = self.player:getDefaultSettings()

	if model.blocks ~= nil then
		-- calcul les blocks
		local input = {}
		for _, productBlock in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
			Logging:debug("**********PlannerModel:update():",input)
			Logging:debug("**********PlannerModel:update():",productBlock.products)
			for _,product in pairs(productBlock.products) do
				if input[product.name] ~= nil then
					product.count = input[product.name]
				end
			end

			self:computeProductionBlock(player, productBlock)

			for _,ingredient in pairs(productBlock.ingredients) do
				if input[ingredient.name] == nil then
					input[ingredient.name] = ingredient.count
				else
					input[ingredient.name] = input[ingredient.name] + ingredient.count
				end
			end
		end


		self:computeIngredients(player)



		Logging:debug("PlannerModel:update():","Factory compute OK")
		-- genere un bilan
		self:createSummary(player)
		Logging:debug("PlannerModel:update():","Summary OK")

	end

end

-------------------------------------------------------------------------------
-- Prepare model
--
-- @function [parent=#PlannerModel] computeProductionBlock
--
-- @param #LuaPlayer player
-- @param #table element production block model
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function PlannerModel.methods:computeProductionBlock(player, element, maxLoop, level, path)
	Logging:debug("PlannerModel:computeProductionBlock():",player, element, maxLoop, level, path)
	local model = self:getModel(player)

	local recipes = element.recipes
	if recipes ~= nil then
		-- initialisation
		element.products = {}
		element.ingredients = {}
		element.power = 0

		-- preparation produits et ingredients du block
		local products = {}
		local ingredients = {}
		for _, recipe in pairs(recipes) do
			-- construit la list des produits
			for _, product in pairs(recipe.products) do
				products[product.name] = product
			end
			-- construit la list des ingredients
			for _, ingredient in pairs(recipe.ingredients) do
				ingredients[ingredient.name] = ingredient
			end
		end

		-- ajoute les produits du block
		for _, product in pairs(products) do
			if ingredients[product.name] == nil then
				element.products[product.name] = product
			end
		end

		-- ajoute les ingredients du block
		for _, ingredient in pairs(ingredients) do
			if products[ingredient.name] == nil then
				element.ingredients[ingredient.name] = ingredient
			end
		end

		-- ratio pour le calcul du nombre de block
		local ratio = 1
		local ratioRecipe = nil
		-- calcul ordonnee sur les recipes du block
		local ingredients = nil
		for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
			for _, product in pairs(recipe.products) do
				local pCount = 0
				if ingredients ~= nil and ingredients[product.name] ~= nil then
					product.count = ingredients[product.name]
				end
				pCount = product.count;
				for k, ingredient in pairs(recipe.ingredients) do
					local productNominal = product.amount
					local productUsage = product.amount
					-- calcul production module factory
					for module, value in pairs(recipe.factory.modules) do
						local bonus = self.player:getModuleBonus(module, "productivity")
						productUsage = productUsage + productNominal * value * bonus
					end
					if recipe.beacon.active then
						for module, value in pairs(recipe.beacon.modules) do
							local bonus = self.player:getModuleBonus(module, "productivity")
							productUsage = productUsage + productNominal * value * bonus * recipe.beacon.efficiency * recipe.beacon.combo
						end
					end
					local nextCount = math.ceil(pCount*(ingredient.amount/productUsage))
					ingredient.count = nextCount

					if ingredients == nil then ingredients = {} end
					if ingredients[ingredient.name] == nil then
						ingredients[ingredient.name] = nextCount
					else
						ingredients[ingredient.name] = ingredients[ingredient.name] + nextCount
					end
				end
			end

			self:computeFactory(player, recipe)

			element.power = element.power + recipe.energy_total
			
			if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
				local currentRatio = recipe.factory.limit/recipe.factory.count
				if currentRatio < ratio then
					ratio = currentRatio
					ratioRecipe = recipe.index
					-- block number
					element.count = math.ceil(recipe.factory.count/recipe.factory.limit)
				end
			end
		end
		
		-- calcul ratio
		for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
			recipe.factory.limit_count = math.ceil(recipe.factory.count*ratio)
			if ratioRecipe ~= nil and ratioRecipe == recipe.index then recipe.factory.limit_count = recipe.factory.limit end
		end
	end
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
	model.ingredients = {}

	local index = 1
	for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
		for _, ingredient in pairs(element.ingredients) do
			if model.ingredients[ingredient.name] == nil then
				model.ingredients[ingredient.name] = self:createIngredientModel(player, ingredient.name, ingredient.type)
				model.ingredients[ingredient.name].index = index
				index = index + 1
			end
			model.ingredients[ingredient.name].count = model.ingredients[ingredient.name].count + ingredient.count
		end
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
			extractor.energy_total = extractor.energy * extractor.count * 1000
			ingredient.extractor = extractor
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
			if #recipe.products > 1 then
				-- met a jour le produit
				local productCount = 0
				-- precalul
				for index, product in pairs(recipe.products) do
					if product.name == element.name then
						productCount = product.count + pCount
						currentProduct = product
					end
				end
				-- check les autres produits
				local check = false
				for index, product in pairs(recipe.products) do
					if product.name ~= element.name then
						if product.count < productCount*product.amount/currentProduct.amount then check = true end
					end
				end
				-- applique les valeurs si ok
				if check == true then
					for index, product in pairs(recipe.products) do
						if product.name == element.name then
							product.count = productCount
						else
							product.count = productCount*product.amount/currentProduct.amount
						end
					end
				end
			else
				for index, product in pairs(recipe.products) do
					if product.name == element.name then
						product.count = product.count + pCount
						currentProduct = product
					end
				end
			end

			path = path..recipe.index.."_"

			for k, ingredient in pairs(recipe.ingredients) do
				local productNominal = currentProduct.amount
				local productUsage = currentProduct.amount
				-- calcul production module factory
				for module, value in pairs(recipe.factory.modules) do
					local bonus = self.player:getModuleBonus(module, "productivity")
					productUsage = productUsage + productNominal * value * bonus
				end
				if recipe.beacon.active then
					for module, value in pairs(recipe.beacon.modules) do
						local bonus = self.player:getModuleBonus(module, "productivity")
						productUsage = productUsage + productNominal * value * bonus * recipe.beacon.efficiency * recipe.beacon.combo
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
		local bonus = self.player:getModuleBonus(module, "speed")
		recipe.factory.speed = recipe.factory.speed + recipe.factory.speed_nominal * value * bonus
	end
	-- effet module beacon
	if recipe.beacon.active then
		for module, value in pairs(recipe.beacon.modules) do
			local bonus = self.player:getModuleBonus(module, "speed")
			recipe.factory.speed = recipe.factory.speed + recipe.factory.speed_nominal * value * bonus * recipe.beacon.efficiency * recipe.beacon.combo
		end
	end

	-- effet module factory
	recipe.factory.energy = recipe.factory.energy_nominal
	for module, value in pairs(recipe.factory.modules) do
		local bonus = self.player:getModuleBonus(module, "consumption")
		recipe.factory.energy = recipe.factory.energy + recipe.factory.energy_nominal * value * bonus
	end
	if recipe.beacon.active then
		-- effet module beacon
		for module, value in pairs(recipe.beacon.modules) do
			local bonus = self.player:getModuleBonus(module, "consumption")
			recipe.factory.energy = recipe.factory.energy + recipe.factory.energy_nominal * value * bonus * recipe.beacon.efficiency * recipe.beacon.combo
		end
	end

	-- cap l'energy a 20%
	if recipe.factory.energy < recipe.factory.energy_nominal*0.2  then recipe.factory.energy = recipe.factory.energy_nominal*0.2 end
	-- compte le nombre de machines necessaires
	local product = nil
	for k, element in pairs(recipe.products) do
		product = element
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
	recipe.factory.energy_total = math.ceil(recipe.factory.count*recipe.factory.energy)*1000
	recipe.beacon.energy_total = math.ceil(recipe.beacon.count*recipe.beacon.energy)*1000
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
	model.summary.factories = {}
	model.summary.beacons = {}
	model.summary.modules = {}

	local energy = 0

	for _, block in pairs(model.blocks) do
		-- cumul de l'energie
		energy = energy + block.power
		for _, recipe in pairs(block.recipes) do
			-- calcul nombre factory
			local factory = recipe.factory
			if model.summary.factories[factory.name] == nil then model.summary.factories[factory.name] = {name = factory.name, count = 0} end
			model.summary.factories[factory.name].count = model.summary.factories[factory.name].count + factory.count
			-- calcul nombre de module factory
			for module, value in pairs(factory.modules) do
				if model.summary.modules[module] == nil then model.summary.modules[module] = {name = module, count = 0} end
				model.summary.modules[module].count = model.summary.modules[module].count + value * factory.count
			end
			-- calcul nombre beacon
			local beacon = recipe.beacon
			if model.summary.beacons[beacon.name] == nil then model.summary.beacons[beacon.name] = {name = beacon.name, count = 0} end
			model.summary.beacons[beacon.name].count = model.summary.beacons[beacon.name].count + beacon.count
			-- calcul nombre de module beacon
			for module, value in pairs(beacon.modules) do
				if model.summary.modules[module] == nil then model.summary.modules[module] = {name = module, count = 0} end
				model.summary.modules[module].count = model.summary.modules[module].count + value * beacon.count
			end
		end
	end

	-- calcul minig-drill
	for k, ingredient in pairs(model.ingredients) do
		if ingredient.extractor ~= nil then
			energy = energy + ingredient.extractor.energy_total
		end
	end


	model.summary.energy = energy



	model.generators = {}
	model.generators["solar-panel"] = {name = "solar-panel", count = math.ceil(energy/(60*1000))}
	model.generators["steam-engine"] = {name = "steam-engine", count = math.ceil(energy/(510*1000))}

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
