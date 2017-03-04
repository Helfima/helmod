------------------------------------------------------------------------------
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

	self.capEnergy = -0.8
end

-------------------------------------------------------------------------------
-- Get models
--
-- @function [parent=#PlannerModel] getModels
--
-- @param #LuaPlayer player
--
-- @return #table
--
function PlannerModel.methods:getModels(player)
	Logging:trace("PlannerModel:getModels():",player)
	local models = self.player:getGlobal(player, "model")
	Logging:debug("PlannerModel:getModels():models:",models)
	if #models == 0 then table.insert(models, {}) end
	return models
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
	local model_index = self.player:getGlobalGui(player, "model_index")
	if model_index == nil then model_index = 1 end
	
	local models = self:getModels(player)
	local model = models[model_index]
	
	if model == nil then
		model = {}
		models[model_index] = model
	end
	
	if model.blocks == nil then model.blocks = {} end

	if model.ingredients == nil then model.ingredients = {} end

	if model.resources == nil then model.resources = {} end

	if model.time == nil then model.time = 1 end

	return model
end

-------------------------------------------------------------------------------
-- Get and initialize the model
--
-- @function [parent=#PlannerModel] getModel
--
-- @param #LuaPlayer player
-- @param #number model_index
--
function PlannerModel.methods:removeModel(player,model_index)
	Logging:trace("PlannerModel:getModel():",player)
	local globalGui = self.player:getGlobalGui(player)
	globalGui.model_index = 1
	
	local models = self:getModels(player)
	table.remove(models, model_index)
	
end

-------------------------------------------------------------------------------
-- Get Object
--
-- @function [parent=#PlannerModel] getObject
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
--
-- @return #table
--
function PlannerModel.methods:getObject(player, item, key)
	Logging:trace("PlannerModel:getObject():",player, item, key)
	local object = nil
	local model = self:getModel(player)
	if item == "resource" then
		object = model.resources[key]
	elseif model.blocks[item] ~= nil and model.blocks[item].recipes[key] ~= nil then
		object = model.blocks[item].recipes[key]
	end
	return object
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
	beaconModel.name = "beacon"
	beaconModel.type = "item"
	beaconModel.active = false
	beaconModel.count = count
	beaconModel.energy_nominal = "480"
	beaconModel.energy = 0
	beaconModel.energy_total = 0
	beaconModel.combo = 4
	beaconModel.factory = 1.2
	beaconModel.efficiency = 0.5
	beaconModel.module_slots = 2
	-- limit infini = 0
	beaconModel.limit = 0
	beaconModel.limit_count = count
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
-- @param #string type
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
	recipeModel.energy = 0.5
	recipeModel.production = 1
	recipeModel.ingredients = {}
	recipeModel.products = {}
	recipeModel.factory = self:createFactoryModel(player)
	recipeModel.beacon = self:createBeaconModel(player)

	return recipeModel
end

-------------------------------------------------------------------------------
-- Create resource model
--
-- @function [parent=#PlannerModel] createResourceModel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #number count
--
-- @return #table
--
function PlannerModel.methods:createResourceModel(player, name, type, count)
	Logging:debug("PlannerModel:createResourceModel():",player, name, type, count)
	local model = self:getModel(player)
	if model.resource_id == nil then model.resource_id = 0 end
	model.resource_id = model.resource_id + 1

	if count == nil then count = 1 end

	local resourceModel = {}
	resourceModel.id = model.resource_id
	resourceModel.index = 1
	resourceModel.type = type
	resourceModel.name = name
	resourceModel.count = count
	resourceModel.factory = self:createFactoryModel(player)
	resourceModel.beacon = self:createBeaconModel(player)

	return resourceModel
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
function PlannerModel.methods:addRecipeIntoProductionBlock(player, key)
	Logging:debug("PlannerModel:addRecipeIntoProductionBlock():",player, key)
	local model = self:getModel(player)
	local globalGui = self.player:getGlobalGui(player)
	local blockId = globalGui.currentBlock
	local recipe = self.player:getRecipe(player, key);

	if model.blocks[blockId] == nil then
		local modelBlock = self:createProductionBlockModel(player, recipe)
		local index = self:countBlocks(player)
		modelBlock.index = index
		model.blocks[modelBlock.id] = modelBlock
		blockId = modelBlock.id
		globalGui.currentBlock = blockId
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
-- Set the beacon
--
-- @function [parent=#PlannerModel] setBeacon
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #string name beacon name
--
function PlannerModel.methods:setBeacon(player, item, key, name)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		local beacon = self.player:getEntityPrototype(name)
		if beacon ~= nil then
			-- set global default
			self:setDefaultRecipeBeacon(player, key, beacon.name)

			object.beacon.name = beacon.name
			--object.beacon.type = beacon.type
			-- copy the default parameters
			object.beacon.energy_nominal = self.player:getItemProperty(beacon.name, "energy_usage")
			object.beacon.module_slots = self.player:getItemProperty(beacon.name, "module_slots")
			object.beacon.efficiency = self.player:getItemProperty(beacon.name, "efficiency")
			object.beacon.combo = 4
			object.beacon.factory = 1.2
		end
	end
end

-------------------------------------------------------------------------------
-- Update a beacon
--
-- @function [parent=#PlannerModel] updateBeacon
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #table options map attribute/valeur
--
function PlannerModel.methods:updateBeacon(player, item, key, options)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		if options.energy_nominal ~= nil then
			object.beacon.energy_nominal = options.energy_nominal
		end
		if options.combo ~= nil then
			object.beacon.combo = options.combo
		end
		if options.factory ~= nil then
			object.beacon.factory = options.factory
		end
		if options.efficiency ~= nil then
			object.beacon.efficiency = options.efficiency
		end
		if options.module_slots ~= nil then
			object.beacon.module_slots = options.module_slots
		end
	end
end

-------------------------------------------------------------------------------
-- Add a module in beacon
--
-- @function [parent=#PlannerModel] addBeaconModule
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function PlannerModel.methods:addBeaconModule(player, item, key, name)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		self:addModuleModel(object.beacon, name)
	end
end

-------------------------------------------------------------------------------
-- Remove a module in beacon
--
-- @function [parent=#PlannerModel] removeBeaconModule
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function PlannerModel.methods:removeBeaconModule(player, item, key, name)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		self:removeModuleModel(object.beacon, name)
	end
end

-------------------------------------------------------------------------------
-- Set a factory
--
-- @function [parent=#PlannerModel] setFactory
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #string name factory name
--
function PlannerModel.methods:setFactory(player, item, key, name)
	Logging:debug("PlannerModel:setFactory():",player, item, key, options)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		local factory = self.player:getEntityPrototype(name)
		if factory ~= nil then
			-- set global default
			self:setDefaultRecipeFactory(player, key, factory.name)

			object.factory.name = factory.name
			--object.factory.type = factory.type
			object.factory.energy_nominal = self.player:getItemProperty(factory.name, "energy_usage")
			
			object.factory.module_slots = self.player:getItemProperty(factory.name, "module_slots")
			local speed_nominal = self.player:getItemProperty(factory.name, "crafting_speed")
			local mining_speed = self.player:getItemProperty(factory.name, "mining_speed")
			local mining_power = self.player:getItemProperty(factory.name, "mining_power")
			if mining_speed ~= 0 then
				speed_nominal = mining_power * mining_speed
			end
			object.factory.speed_nominal = speed_nominal
		end
	end
end

-------------------------------------------------------------------------------
-- Update a object
--
-- @function [parent=#PlannerModel] updateObject
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #table options
--
function PlannerModel.methods:updateObject(player, item, key, options)
	Logging:debug("PlannerModel:updateObject():",player, item, key, options)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		if options.production ~= nil then
			object.production = options.production
		end
	end
end

-------------------------------------------------------------------------------
-- Update a factory
--
-- @function [parent=#PlannerModel] updateFactory
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #table options
--
function PlannerModel.methods:updateFactory(player, item, key, options)
	Logging:debug("PlannerModel:updateFactory():",player, item, key, options)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		if options.energy_nominal ~= nil then
			object.factory.energy_nominal = options.energy_nominal
		end
		if options.speed_nominal ~= nil then
			object.factory.speed_nominal = options.speed_nominal
		end
		if options.module_slots ~= nil then
			object.factory.module_slots = options.module_slots
		end
		if options.limit ~= nil then
			object.factory.limit = options.limit
		end
	end
end

-------------------------------------------------------------------------------
-- Add a module in factory
--
-- @function [parent=#PlannerModel] addFactoryModule
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function PlannerModel.methods:addFactoryModule(player, item, key, name)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		self:addModuleModel(object.factory, name)
	end
end

-------------------------------------------------------------------------------
-- Remove a module from factory
--
-- @function [parent=#PlannerModel] removeFactoryModule
--
-- @param #LuaPlayer player
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function PlannerModel.methods:removeFactoryModule(player, item, key, name)
	local object = self:getObject(player, item, key)
	if object ~= nil then
		self:removeModuleModel(object.factory, name)
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

		self:computeResources(player)

		Logging:debug("PlannerModel:update():","Factory compute OK")
		-- genere un bilan
		self:createSummary(player)
		Logging:debug("PlannerModel:update():","Summary OK")

		Logging:debug("**********model updated:",model)
	end

end

-------------------------------------------------------------------------------
-- Get amount of element
--
-- @function [parent=#PlannerModel] getElementAmount
--
-- @param #table element
--
-- @return #number
--
-- @see http://lua-api.factorio.com/latest/Concepts.html#Product
--
function PlannerModel.methods:getElementAmount(element)
	if element.amount ~= nil then
		return element.amount
	end

	if element.probability ~= nil and element.amount_min ~= nil and  element.amount_max ~= nil then
		return ((element.amount_min + element.amount_max) * element.probability / 2)
	end

	return 0
end
-------------------------------------------------------------------------------
-- Compute production block
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
		local oldProducts = element.products
		-- initialisation
		element.products = {}
		element.ingredients = {}
		element.power = 0
		element.count = 1

		local initProduct = false
		-- preparation produits et ingredients du block
		for _, recipe in pairs(recipes) do
			-- construit la list des produits
			for _, product in pairs(recipe.products) do
				element.products[product.name] = {
					name = product.name,
					type = product.type,
					count = 0,
					state = 0,
					amount = self:getElementAmount(product)
				}
				if initProduct == false then
					if oldProducts[product.name] ~= nil and oldProducts[product.name].count > 0 then
						product.count = oldProducts[product.name].count
					else
						product.count = 0
					end
					element.products[product.name].count = product.count
					element.products[product.name].state = 1
				else
					product.count = 0
				end
			end
			-- limit les produits au premier recipe
			initProduct = true
			-- construit la list des ingredients
			for _, ingredient in pairs(recipe.ingredients) do
				element.ingredients[ingredient.name] = {
					name = ingredient.name,
					type = ingredient.type,
					amount = ingredient.amount,
					count = 0
				}
				-- initialise ingredient
				ingredient.count = 0
			end
		end

		-- ratio pour le calcul du nombre de block
		local ratio = 1
		local ratioRecipe = nil
		-- calcul ordonnee sur les recipes du block
		for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
			local mainProduct = nil
			local production = 1
			if recipe.production ~= nil then production = recipe.production end
			-- prepare les produits
			for _, product in pairs(recipe.products) do
				if element.ingredients[product.name] ~= nil then
					product.count = element.ingredients[product.name].count*production
				end
			end
			-- check produit pilotant
			-- @see http://lua-api.factorio.com/latest/Concepts.html#Product
			for _, product in pairs(recipe.products) do
				if mainProduct == nil then
					mainProduct = product
				elseif product.count/self:getElementAmount(product) > mainProduct.count/self:getElementAmount(mainProduct) then
					mainProduct = product
				end
			end
			-- consolide les produits
			if #recipe.products > 1 then
				-- met a jour le produit
				for index, product in pairs(recipe.products) do
					if product.name ~= mainProduct.name then
						product.count = (mainProduct.count*self:getElementAmount(product)/self:getElementAmount(mainProduct))
					end
				end
			end

			self:computeModuleEffects(player, recipe)

			local pCount = mainProduct.count;
			for k, ingredient in pairs(recipe.ingredients) do
				local productNominal = self:getElementAmount(mainProduct)
				local productUsage = self:getElementAmount(mainProduct)
				-- calcul factory productivity effect
				productUsage = productUsage + productNominal * recipe.factory.effects.productivity
				
				local nextCount = math.ceil(pCount*(ingredient.amount/productUsage))
				ingredient.count = nextCount

				element.ingredients[ingredient.name].count = element.ingredients[ingredient.name].count + nextCount
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

      -- state = 0 => produit
      -- state = 1 => produit pilotant
      -- state = 2 => produit restant
			for _, product in pairs(recipe.products) do
				-- compte les produits
        if element.products[product.name] ~= nil and element.products[product.name].state == 0 then
          element.products[product.name].count = element.products[product.name].count + product.count
        end
        -- consomme les produits
				if element.ingredients[product.name] ~= nil then
					element.ingredients[product.name].count = element.ingredients[product.name].count - product.count
				end
			end

		end
		if element.count < 1 then
			element.count = 1
		end

		for _, recipe in pairs(recipes) do
			for _, ingredient in pairs(recipe.ingredients) do
				-- consomme les ingredients
				if element.products[ingredient.name] ~= nil then
					element.products[ingredient.name].count = element.products[ingredient.name].count - ingredient.count
				end
			end
		end

		-- reduit les produits du block
		for _, product in pairs(element.products) do
			if element.ingredients[product.name] ~= nil then
				product.state = product.state + 2
			end
			if element.products[product.name].count < 0.9 and not(bit32.band(product.state, 1) > 0) then
				element.products[product.name] = nil
			end
		end

		-- reduit les ingredients du block
		for _, ingredient in pairs(element.ingredients) do
			if element.ingredients[ingredient.name].count < 0.9 then
				element.ingredients[ingredient.name] = nil
			end
		end

		-- calcul ratio
		for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
			recipe.factory.limit_count = math.ceil(recipe.factory.count*ratio)
			recipe.beacon.limit_count = math.ceil(recipe.beacon.count*ratio)
			if ratioRecipe ~= nil and ratioRecipe == recipe.index then
				recipe.factory.limit_count = recipe.factory.limit
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Compute ingredients
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
	Logging:debug("PlannerModel:computeIngredients():",player)
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
end

-------------------------------------------------------------------------------
-- Compute resources
--
-- @function [parent=#PlannerModel] computeResources
--
-- @param #LuaPlayer player
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function PlannerModel.methods:computeResources(player)
	Logging:debug("PlannerModel:computeResources():",player)
	local model = self:getModel(player)
	local resources = {}

	-- calcul resource
	for k, ingredient in pairs(model.ingredients) do
		if ingredient.resource_category ~= nil or ingredient.name == "water" then
			local resource = model.resources[ingredient.name]
			if resource ~= nil then
				resource.count = ingredient.count
			else
				resource = self:createResourceModel(player, ingredient.name, ingredient.type, ingredient.count)
				if ingredient.resource_category == "basic-solid" then
					resource.factory.name = "electric-mining-drill"
					resource.category = "basic-solid"
					resource.factory.speed = 1
					resource.factory.energy = 90
				end
				if ingredient.name == "water" then
					resource.factory.name = "offshore-pump"
					resource.category = "basic-fluid"
					resource.factory.speed = 1
					resource.factory.energy = 0
				end
				if ingredient.name == "crude-oil" then
					resource.factory.name = "pumpjack"
					resource.category = "basic-fluid"
					resource.factory.speed = 2
					resource.factory.energy = 90
				end
			end

			self:computeModuleEffects(player, resource)
			self:computeFactory(player, resource)

			resource.factory.limit_count = resource.factory.count
			resource.blocks = 1
			resource.wagon = nil
			resource.storage = nil

			local ratio = 1
			if resource.factory.limit ~= nil and resource.factory.limit ~= 0 then
				if resource.factory.limit < resource.factory.count then
					resource.factory.limit_count = resource.factory.limit
				else
					resource.factory.limit_count = resource.factory.count
				end
				resource.blocks = math.ceil(resource.factory.count/resource.factory.limit)
				ratio = 1/resource.blocks
			end

			-- compute storage
			if resource.category == "basic-solid" then
				resource.wagon = {type="item", name="cargo-wagon"}
				resource.wagon.count = math.ceil(resource.count/2000)
				resource.wagon.limit_count = math.ceil(resource.wagon.count * ratio)

				resource.storage = {type="item", name="steel-chest"}
				resource.storage.count = math.ceil(resource.count/(48*50))
				resource.storage.limit_count = math.ceil(resource.storage.count * ratio)
			elseif resource.category == "basic-fluid" then
				--resource.wagon = {type="item", name="cargo-wagon"}
				--resource.wagon.count = math.ceil(resource.count/2000)

				resource.storage = {type="item", name="storage-tank"}
				resource.storage.count = math.ceil(resource.count/2400)
				resource.storage.limit_count = math.ceil(resource.storage.count * ratio)
			end

			resources[resource.name] = resource
		end
	end
	model.resources = resources
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
-- Compute module effects of factory
--
-- @function [parent=#PlannerModel] computeModuleEffects
--
-- @param #LuaPlayer player
-- @param #ModelObject object
--
function PlannerModel.methods:computeModuleEffects(player, object)
	Logging:debug("PlannerModel:computeModuleEffects()",object)

	local factory = object.factory
	factory.effects = {speed = 0, productivity = 0, consumption = 0}
	-- effet module factory
	for module, value in pairs(factory.modules) do
		local speed_bonus = self.player:getModuleBonus(module, "speed")
		local productivity_bonus = self.player:getModuleBonus(module, "productivity")
		local consumption_bonus = self.player:getModuleBonus(module, "consumption")
		factory.effects.speed = factory.effects.speed + value * speed_bonus
		factory.effects.productivity = factory.effects.productivity + value * productivity_bonus
		factory.effects.consumption = factory.effects.consumption + value * consumption_bonus
	end
	-- effet module beacon
	if object.beacon.active then
		for module, value in pairs(object.beacon.modules) do
			local speed_bonus = self.player:getModuleBonus(module, "speed")
			local productivity_bonus = self.player:getModuleBonus(module, "productivity")
			local consumption_bonus = self.player:getModuleBonus(module, "consumption")
			factory.effects.speed = factory.effects.speed + value * speed_bonus * object.beacon.efficiency * object.beacon.combo
			factory.effects.productivity = factory.effects.productivity + value * productivity_bonus * object.beacon.efficiency * object.beacon.combo
			factory.effects.consumption = factory.effects.consumption + value * consumption_bonus * object.beacon.efficiency * object.beacon.combo
		end
	end

	-- cap l'energy a self.capEnergy
	if factory.effects.consumption < self.capEnergy  then factory.effects.consumption = self.capEnergy end

end

-------------------------------------------------------------------------------
-- Compute energy, speed, number of factory for recipes
--
-- @function [parent=#PlannerModel] computeFactory
--
-- @param #LuaPlayer player
-- @param #ModelObject object
--
function PlannerModel.methods:computeFactory(player, object)
	Logging:debug("PlannerModel:computeFactory()",object)

	-- effet speed
	object.factory.speed = object.factory.speed_nominal * (1 + object.factory.effects.speed)
	-- effet consumption
	object.factory.energy = object.factory.energy_nominal * (1 + object.factory.effects.consumption)
	
	-- compte le nombre de machines necessaires
	if object.products ~= nil then
		local product = nil
		for k, element in pairs(object.products) do
			product = element
		end
		--Logging:trace("product=",product)
		if product ~= nil then
			local model = self:getModel(player)
			-- [nombre d'item] * [effort necessaire du recipe] / ([la vitesse de la factory] * [nombre produit par le recipe] * [le temps en second])
			local count = math.ceil(product.count*object.energy/(object.factory.speed*self:getElementAmount(product)*(1 + object.factory.effects.productivity)*model.time))
			object.factory.count = count
			if object.beacon.active then
				object.beacon.count = math.ceil(count/object.beacon.factory)
			else
				object.beacon.count = 0
			end
		end
	else
		local product = object
		local model = self:getModel(player)
		-- [nombre d'item] / ([la vitesse de la factory] * [le temps en second])
		local count = math.ceil(product.count/(object.factory.speed*model.time))
		object.factory.count = count
		if object.beacon.active then
			object.beacon.count = math.ceil(count/object.beacon.factory)
		else
			object.beacon.count = 0
		end
	end

	object.beacon.energy = object.beacon.energy_nominal
	-- calcul des totaux
	object.factory.energy_total = math.ceil(object.factory.count*object.factory.energy)*1000
	object.beacon.energy_total = math.ceil(object.beacon.count*object.beacon.energy)*1000
	object.energy_total = object.factory.energy_total + object.beacon.energy_total
	-- arrondi des valeurs
	object.factory.speed = math.ceil(object.factory.speed*100)/100
	object.factory.energy = math.ceil(object.factory.energy)
	object.beacon.energy = math.ceil(object.beacon.energy)
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number total
--
-- @function [parent=#PlannerModel] createSummary
--
-- @param #LuaPlayer player
--
function PlannerModel.methods:createSummary(player)
	local model = self:getModel(player)
	model.summary = {}
	model.summary.factories = {}
	model.summary.beacons = {}
	model.summary.modules = {}

	local energy = 0

	-- cumul de l'energie des blocks
	for _, block in pairs(model.blocks) do
		energy = energy + block.power
		for _, recipe in pairs(block.recipes) do
			self:computeSummaryFactory(player, recipe)
		end
	end

	-- cumul de l'energie des resources
	for k, resource in pairs(model.resources) do
		if resource.energy_total ~= nil then
			energy = energy + resource.energy_total
			self:computeSummaryFactory(player, resource)
		end
	end


	model.summary.energy = energy

	model.generators = {}
	-- formule 20 accumulateur /24 panneau solaire/1 MW
	model.generators["accumulator"] = {name = "accumulator", type = "item", count = 20*math.ceil(energy/(1000*1000))}
	model.generators["solar-panel"] = {name = "solar-panel", type = "item", count = 24*math.ceil(energy/(1000*1000))}
	model.generators["steam-engine"] = {name = "steam-engine", type = "item", count = math.ceil(energy/(510*1000))}

end

-------------------------------------------------------------------------------
-- Compute summary factory
--
-- @function [parent=#PlannerModel] computeSummaryFactory
--
-- @param #LuaPlayer player
-- @param object object
--
function PlannerModel.methods:computeSummaryFactory(player, object)
	local model = self:getModel(player)
	-- calcul nombre factory
	local factory = object.factory
	if model.summary.factories[factory.name] == nil then model.summary.factories[factory.name] = {name = factory.name, type = "item", count = 0} end
	model.summary.factories[factory.name].count = model.summary.factories[factory.name].count + factory.count
	-- calcul nombre de module factory
	for module, value in pairs(factory.modules) do
		if model.summary.modules[module] == nil then model.summary.modules[module] = {name = module, type = "item", count = 0} end
		model.summary.modules[module].count = model.summary.modules[module].count + value * factory.count
	end
	-- calcul nombre beacon
	local beacon = object.beacon
	if model.summary.beacons[beacon.name] == nil then model.summary.beacons[beacon.name] = {name = beacon.name, type = "item", count = 0} end
	model.summary.beacons[beacon.name].count = model.summary.beacons[beacon.name].count + beacon.count
	-- calcul nombre de module beacon
	for module, value in pairs(beacon.modules) do
		if model.summary.modules[module] == nil then model.summary.modules[module] = {name = module, type = "item", count = 0} end
		model.summary.modules[module].count = model.summary.modules[module].count + value * beacon.count
	end
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
			factory = nil,
			beacon = nil
		}
	end
	return default.recipes[key]
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
