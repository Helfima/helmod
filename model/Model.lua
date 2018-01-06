------------------------------------------------------------------------------
-- Description of the module.
-- @module Model
--
local Model = {
  -- single-line comment
  classname = "HMModel",
  version = "0.6.0",
  capEnergy = -0.8,
  capSpeed = -0.8,
  -- 15°c
  initial_temp = 15,
  -- 200J/unit/°c
  fluid_energy_per_unit = 200
}

-------------------------------------------------------------------------------
-- Get models
--
-- @function [parent=#Model] getModels
--
-- @param #boolean bypass
--
-- @return #table
--
function Model.getModels(bypass)
  Logging:trace(Model.classname, "getModels()", bypass ,global.models)
  local model_id = Player.getGlobalGui("model_id")
  local display_all_sheet = Player.getSettings("display_all_sheet", true)
  local first_id = nil
  local reset_model_id = true
  local models = {}
  local global_models = global.models
  if Model.countModel() > 0 then
    for _,model in pairs(global.models) do
      if Player.isAdmin() and ( display_all_sheet or model.owner == "admin" or bypass ) then
        models[model.id] = model
        if first_id == nil then first_id = model.id end
        if model_id == model.id then reset_model_id = false end
      elseif model.owner == Player.native().name or (model.share ~= nil and model.share > 0) then
        models[model.id] = model
        if first_id == nil then first_id = model.id end
        if model_id == model.id then reset_model_id = false end
      end
    end
  end
  if reset_model_id == true then
    Player.getGlobalGui()["model_id"] = first_id
  end
  return models
end

-------------------------------------------------------------------------------
-- Get and initialize the model
--
-- @function [parent=#Model] newModel
--
-- @return #table
--
function Model.newModel()
  Logging:trace(Model.classname, "getModel()")
  if global.model_id == nil then global.model_id = 1 end
  if global.models == nil then global.models = {} end
  local owner = Player.native().name
  if owner == nil or owner == "" then owner = "admin" end
  global.model_id = global.model_id + 1
  local model = {}
  model.id = "model_"..global.model_id
  model.owner = owner
  model.blocks = {}
  model.ingredients = {}
  model.resources = {}
  model.powers = {}
  model.time = 1
  model.version = Model.version
  global.models[model.id] = model

  Player.getGlobalGui()["model_id"] = model.id
  return model
end

-------------------------------------------------------------------------------
-- Get and initialize the model
--
-- @function [parent=#Model] getModel
--
-- @return #table
--
function Model.getModel()
  Logging:trace(Model.classname, "getModel()")
  local model_id = Player.getGlobalGui("model_id")
  if model_id == "new" then
    Model.newModel()
  end

  model_id = Player.getGlobalGui("model_id")
  local models = Model.getModels()
  local model = models[model_id]
  if model == nil then return Model.newModel() end

  return model
end

-------------------------------------------------------------------------------
-- Get Object
--
-- @function [parent=#Model] getObject
--
-- @param #string item block_id or resource
-- @param #string key object name
--
-- @return #table
--
function Model.getObject(item, key)
  Logging:trace(Model.classname, "getObject():", item, key)
  local object = nil
  local model = Model.getModel()
  if item == "resource" then
    object = model.resources[key]
  elseif model.blocks[item] ~= nil and model.blocks[item].recipes[key] ~= nil then
    object = model.blocks[item].recipes[key]
  end
  return object
end

-------------------------------------------------------------------------------
-- Get Object
--
-- @function [parent=#Model] getObject
--
-- @param #string block_id block id
-- @param #string key object name
--
-- @return #Prototype
--
function Model.getRecipe(block_id, key)
  Logging:trace(Model.classname, "getRecipe()", block_id, key)
  local object = nil
  local model = Model.getModel()
  if model.blocks[block_id] ~= nil and model.blocks[block_id].recipes[key] ~= nil then
    object = model.blocks[block_id].recipes[key]
  end
  return RecipePrototype.load(object)
end

-------------------------------------------------------------------------------
-- Get power
--
-- @function [parent=#Model] getPower
--
-- @param #string key power id
--
-- @return #table
--
function Model.getPower(key)
  Logging:trace(Model.classname, "getPower():", key)
  local object = nil
  local model = Model.getModel()
  if model.powers ~= nil and model.powers[key] ~= nil then
    object = model.powers[key]
  end
  return object
end



-------------------------------------------------------------------------------
-- Create model Production Block
--
-- @function [parent=#Model] newBlock
--
-- @param #LuaRecipePrototype recipe
--
-- @return #table
--
function Model.newBlock(recipe)
  Logging:debug(Model.classname, "newBlock()", recipe)
  local model = Model.getModel()

  if model.block_id == nil then model.block_id = 0 end
  model.block_id = model.block_id + 1

  local inputModel = {}
  inputModel.id = "block_"..model.block_id
  inputModel.name = recipe.name
  inputModel.owner = Player.native().name
  inputModel.count = 1
  inputModel.power = 0
  inputModel.ingredients = {}
  inputModel.products = {}
  inputModel.recipes = {}

  return inputModel
end

-------------------------------------------------------------------------------
-- Create model Beacon
--
-- @function [parent=#Model] newBeacon
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.newBeacon(name, count)
  Logging:debug(Model.classname, "newBeacon()", name, count)
  local beaconModel = {}
  beaconModel.name = name or "beacon"
  beaconModel.type = "item"
  beaconModel.count = count or 0
  beaconModel.energy = 0
  beaconModel.combo = 4
  beaconModel.factory = 1.2
  -- limit infini = 0
  beaconModel.limit = 0
  -- modules
  beaconModel.modules = {}
  return beaconModel
end

-------------------------------------------------------------------------------
-- Create model Factory
--
-- @function [parent=#Model] newFactory
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.newFactory(name, count)
  Logging:debug(Model.classname, "newFactory()", name, count)
  local factoryModel = {}
  factoryModel.name = name or "assembling-machine-1"
  factoryModel.type = "item"
  factoryModel.count = count or 0
  factoryModel.energy = 0
  factoryModel.speed = 0
  -- limit infini = 0
  factoryModel.limit = 0
  -- modules
  factoryModel.modules = {}
  return factoryModel
end

-------------------------------------------------------------------------------
-- Create model Power
--
-- @function [parent=#Model] newPower
--
-- @return #table
--
function Model.newPower()
  Logging:debug(Model.classname, "newPower()")
  local model = Player.getGlobal("model")

  if model.power_id == nil then model.power_id = 0 end
  model.power_id = model.power_id + 1

  local inputModel = {}
  inputModel.id = "power_"..model.power_id
  inputModel.power = 0
  inputModel.primary = {}
  inputModel.secondary = {}

  return inputModel
end

-------------------------------------------------------------------------------
-- Create model Generator
--
-- @function [parent=#Model] newGenerator
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.newGenerator(name, count)
  Logging:debug(Model.classname, "newGenerator()", name, count)
  local itemModel = {}
  itemModel.name = name or "steam-engine"
  itemModel.type = "item"
  itemModel.count = count or 0
  return itemModel
end

-------------------------------------------------------------------------------
-- Create model Ingredient
--
-- @function [parent=#Model] newIngredient
--
-- @param #string name
-- @param #string type
-- @param #number count
--
-- @return #table
--
function Model.newIngredient(name, type, count)
  Logging:debug(Model.classname, "newIngredient()", name, count)
  if count == nil then count = 0 end

  local ingredientModel = {}
  ingredientModel.index = 1
  ingredientModel.name = name
  ingredientModel.type = type
  ingredientModel.count = count

  return ingredientModel
end

-------------------------------------------------------------------------------
-- Count modules model
--
-- @function [parent=#Model] countModulesModel
--
-- @param #table element
--
-- @return #number
--
function Model.countModulesModel(element)
  local count = 0
  for name,value in pairs(element.modules) do
    count = count + value
  end
  return count
end

-------------------------------------------------------------------------------
-- Create model Recipe
--
-- @function [parent=#Model] newRecipe
--
-- @param #string name
-- @param #string type
--
-- @return #table
--
function Model.newRecipe(name, type)
  Logging:debug(Model.classname, "newRecipe()", name, type)
  local model = Model.getModel()
  if model.recipe_id == nil then model.recipe_id = 0 end
  model.recipe_id = model.recipe_id + 1

  local recipeModel = {}
  recipeModel.id = "R"..model.recipe_id
  recipeModel.index = 1
  recipeModel.name = name
  recipeModel.type = type or "recipe"
  recipeModel.count = 0
  recipeModel.production = 1
  recipeModel.factory = Model.newFactory()
  recipeModel.beacon = Model.newBeacon()

  return recipeModel
end

-------------------------------------------------------------------------------
-- Create model Resource
--
-- @function [parent=#Model] newResource
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.newResource(name, type, count)
  Logging:debug(Model.classname, "newResource()", name, type, count)
  local model = Model.getModel()
  if model.resource_id == nil then model.resource_id = 0 end
  model.resource_id = model.resource_id + 1

  if count == nil then count = 1 end

  local resourceModel = {}
  resourceModel.id = model.resource_id
  resourceModel.index = 1
  resourceModel.type = type
  resourceModel.name = name
  resourceModel.count = count
  resourceModel.factory = Model.newFactory()
  resourceModel.beacon = Model.newBeacon()

  return resourceModel
end

-------------------------------------------------------------------------------
-- Count recipes
--
-- @function [parent=#Model] countRepices
--
-- @return #number
--
function Model.countRepices()
  local model = Model.getModel()
  local count = 0
  for key, recipe in pairs(model.recipes) do
    count = count + 1
  end
  return count
end

-------------------------------------------------------------------------------
-- Count ingredients
--
-- @function [parent=#Model] countIngredients
--
-- @return #number
--
function Model.countIngredients()
  local model = Model.getModel()
  local count = 0
  for key, recipe in pairs(model.ingredients) do
    count = count + 1
  end
  return count
end

-------------------------------------------------------------------------------
-- Count blocks
--
-- @function [parent=#Model] countBlocks
--
-- @return #number
--
function Model.countBlocks()
  local model = Model.getModel()
  local count = 0
  for key, recipe in pairs(model.blocks) do
    count = count + 1
  end
  return count
end

-------------------------------------------------------------------------------
-- Count powers
--
-- @function [parent=#Model] countPowers
--
-- @return #number
--
function Model.countPowers()
  local model = Model.getModel()
  local count = 0
  if model.powers ~= nil then
    for key, recipe in pairs(model.powers) do
      count = count + 1
    end
  end
  return count
end

-------------------------------------------------------------------------------
-- Count block recipes
--
-- @function [parent=#Model] countBlockRecipes
--
-- @param #string blockId
--
-- @return #number
--
function Model.countBlockRecipes( blockId)
  Logging:debug(Model.classname, "countBlockRecipes():", blockId)
  local model = Model.getModel()
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
-- @function [parent=#Model] countModel
--
-- @return #number
--
function Model.countModel()
  local count = 0
  if global.models ~= nil then
    for key, element in pairs(global.models) do
      count = count + 1
    end
  end
  return count
end

-------------------------------------------------------------------------------
-- Count in list
--
-- @function [parent=#Model] countList
--
-- @param #table list
--
-- @return #number
--
function Model.countList(list)
  local count = 0
  for key, element in pairs(list) do
    count = count + 1
  end
  return count
end

-------------------------------------------------------------------------------
-- Set the beacon
--
-- @function [parent=#Model] setBeacon
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #string name beacon name
--
function Model.setBeacon(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    local beacon = Player.getEntityPrototype(name)
    if beacon ~= nil then
      -- set global default
      Model.setDefaultRecipeBeacon(item, key, beacon.name)
      object.beacon.name = beacon.name
    end
  end
end

-------------------------------------------------------------------------------
-- Set a factory
--
-- @function [parent=#Model] setFactory
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #string name factory name
--
function Model.setFactory(item, key, name)
  Logging:debug(Model.classname, "setFactory():", item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    local factory = Player.getEntityPrototype(name)
    if factory ~= nil then
      object.factory.name = factory.name
    end
  end
end

-------------------------------------------------------------------------------
-- Reindex list
--
-- @function [parent=#Model] reIndexList
--
-- @param #table list
--
function Model.reIndexList(list)
  Logging:debug(Model.classname, "reIndexList()",list)
  local index = 0
  for _,element in spairs(list,function(t,a,b) return t[b].index > t[a].index end) do
    element.index = index
    index = index + 1
  end
end

-------------------------------------------------------------------------------
-- Reset recipes
--
-- @function [parent=#Model] recipesReset
--
function Model.recipesReset()
  Logging:debug(Model.classname, "recipesReset")
  local model = Model.getModel()
  for key, recipe in pairs(model.recipes) do
    Model.recipeReset(recipe)
  end
end

-------------------------------------------------------------------------------
-- Reset recipe
--
-- @function [parent=#Model] recipeReset
--
-- @param #ModelRecipe recipe
--
function Model.recipeReset(recipe)
  Logging:debug(Model.classname, "recipeReset=",recipe)
  if recipe.products ~= nil then
    for index, product in pairs(recipe.products) do
      product.count = 0
    end
  end
  if recipe.ingredients ~= nil then
    for index, ingredient in pairs(recipe.ingredients) do
      ingredient.count = 0
    end
  end
end

-------------------------------------------------------------------------------
-- Reset ingredients
--
-- @function [parent=#Model] ingredientsReset
--
function Model.ingredientsReset()
  Logging:debug(Model.classname, "ingredientsReset()", player)
  local model = Model.getModel()
  for k, ingredient in pairs(model.ingredients) do
    model.ingredients[ingredient.name].count = 0;
  end
end

-------------------------------------------------------------------------------
-- Return first recipe of block
--
-- @function [parent=#Model] firstRecipe
--
-- @param #table recipes
--
function Model.firstRecipe(recipes)
  for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
    return recipe
  end
end

-------------------------------------------------------------------------------
-- Get productions list
--
-- @function [parent=#Model] getRecipeByProduct
--
-- @param #ModelRecipe recipe
--
-- @return #table
--
function Model.getRecipeByProduct(player, element)
  Logging:trace(Model.classname, "getRecipeByProduct=",element)
  local model = Model.getModel(player)
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
-- Get and initialize the default
--
-- @function [parent=#Model] getDefault
--
-- @return #table
--
function Model.getDefault()
  local default = Player.getGlobal("default")

  if default.recipes == nil then default.recipes = {} end

  return default
end

-------------------------------------------------------------------------------
-- Get the default recipe
--
-- @function [parent=#Model] getDefaultRecipe
--
-- @param #string key recipe name
--
function Model.getDefaultRecipe(key)
  local default = Model.getDefault()
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
-- Get speed of the factory
--
-- @function [parent=#Model] getSpeedFactory
--
-- @param #string key factory name
--
-- @return #string
--
function Model.getSpeedFactory(key)
  local crafting_speed = EntityPrototype.load(key).getCraftingSpeed()
  if crafting_speed ~= 0 then return crafting_speed end
  local mining_speed = EntityPrototype.load(key).getMiningSpeed()
  local mining_power = EntityPrototype.load(key).getMiningPower()
  if mining_speed ~= 0 and mining_power ~= 0 then return mining_speed * mining_power end
  return 1
end

-------------------------------------------------------------------------------
-- Get the factory of prototype
--
-- @function [parent=#Model] getDefaultPrototypeFactory
--
-- @param #string category
-- @param #string recipe
--
-- @return #string
--
function Model.getDefaultPrototypeFactory(category, recipe)
  if category ~= nil then
    local factories = Player.getProductionsCrafting(category, recipe)
    local default_factory_level = Player.getSettings("default_factory_level")
    local factory_level = 1
    if default_factory_level == "fast" then
      factory_level = 100
    else
      factory_level = tonumber(default_factory_level)
    end
    local level = 1
    local lua_factory = nil
    local last_factory = nil
    for _, factory in spairs(factories, function(t,a,b) return Model.getSpeedFactory(t[b].name) > Model.getSpeedFactory(t[a].name) end) do
      if level == factory_level then lua_factory = factory end
      last_factory = factory
      level = level + 1
      Logging:debug(Model.classname, "default factory:", last_factory.name, Model.getSpeedFactory(last_factory.name))
    end
    if lua_factory ~= nil then return lua_factory.name end
    if last_factory ~= nil then return last_factory.name end
  end
  return nil
end

-------------------------------------------------------------------------------
-- Set a beacon for recipe
--
-- @function [parent=#Model] setDefaultRecipeBeacon
--
-- @param #string item block_id or resource
-- @param #string key recipe name
-- @param #string name factory name
--
function Model.setDefaultRecipeBeacon(item, key, name)
  local object = Model.getObject(item, key)
  local recipe = Model.getDefaultRecipe(object.name)
  recipe.beacon = name
end

-------------------------------------------------------------------------------
-- Get the beacon of recipe
--
-- @function [parent=#Model] getDefaultRecipeBeacon
--
-- @param #string key recipe name
--
-- @return #string
--
function Model.getDefaultRecipeBeacon(key)
  local default = Model.getDefault()
  if default.recipes[key] == nil then
    return nil
  end
  return default.recipes[key].beacon
end

return Model
