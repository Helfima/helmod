------------------------------------------------------------------------------
-- Description of the module.
-- @module Model
--
local Model = {
  -- single-line comment
  classname = "HMModel",
  version = "0.6.0",
  capEnergy = -0.8,
  capSpeed = -0.8
}

-------------------------------------------------------------------------------
-- Get models
--
-- @function [parent=#Model] getModels
--
-- @return #table
--
function Model.getModels()
  Logging:trace(Model.classname, "getModels():global.models:",global.models)
  local model_id = Player.getGlobalGui("model_id")
  local display_all_sheet = Player.getSettings("display_all_sheet", true)
  local first_id = nil
  local reset_model_id = true
  local models = {}
  local global_models = global.models
  if Model.countModel() > 0 then
    for _,model in pairs(global.models) do
      if Player.isAdmin() and ( display_all_sheet or model.owner == "admin" ) then
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
-- Remove a model
--
-- @function [parent=#Model] removeModel
--
-- @param #number model_id
--
function Model.removeModel(model_id)
  Logging:trace(Model.classname, "removeModel():", model_id)
  global.models[model_id] = nil
  local models = Model.getModels()
  local _,model = next(models)
  if model ~= nil then
    Player.getGlobalGui()["model_id"] = model.id
  else
    Model.newModel()
  end
end

-------------------------------------------------------------------------------
-- Remove a power
--
-- @function [parent=#Model] removePower
--
-- @param #number power_id
--
function Model.removePower(power_id)
  Logging:trace(Model.classname, "removePower():", power_id)
  local model = Model.getModel()
  if model.powers ~= nil then
    model.powers[power_id] = nil
  end
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
-- Create Production Block model
--
-- @function [parent=#Model] createProductionBlockModel
--
-- @param #LuaRecipePrototype recipe
--
-- @return #table
--
function Model.createProductionBlockModel(recipe)
  Logging:debug(Model.classname, "createProductionBlockModel():", recipe)
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
-- Create beacon model
--
-- @function [parent=#Model] createBeaconModel
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.createBeaconModel(name, count)
  Logging:debug(Model.classname, "createBeaconModel():", name, count)
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
-- Create factory model
--
-- @function [parent=#Model] createFactoryModel
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.createFactoryModel(name, count)
  Logging:debug(Model.classname, "createFactoryModel():", name, count)
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
-- Create Power model
--
-- @function [parent=#Model] createPowerModel
--
-- @return #table
--
function Model.createPowerModel()
  Logging:debug(Model.classname, "createPowerModel():")
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
-- Create generator model
--
-- @function [parent=#Model] createGeneratorModel
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.createGeneratorModel(name, count)
  Logging:debug(Model.classname, "createGeneratorModel():", name, count)
  local itemModel = {}
  itemModel.name = name or "steam-engine"
  itemModel.type = "item"
  itemModel.count = count or 0
  return itemModel
end

-------------------------------------------------------------------------------
-- Create ingredient model
--
-- @function [parent=#Model] createIngredientModel
--
-- @param #string name
-- @param #string type
-- @param #number count
--
-- @return #table
--
function Model.createIngredientModel(name, type, count)
  Logging:debug(Model.classname, "createIngredientModel():", name, count)
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
-- Add module model
--
-- @function [parent=#Model] addModuleModel
--
-- @param #table element
-- @param #string name
--
function Model.addModuleModel(element, name)
  local factory_prototype = EntityPrototype.load(element)
  if element.modules[name] == nil then element.modules[name] = 0 end
  if Model.countModulesModel(element) < factory_prototype.moduleInventorySize() then
    element.modules[name] = element.modules[name] + 1
  end
end

-------------------------------------------------------------------------------
-- Remove module model
--
-- @function [parent=#Model] removeModuleModel
--
-- @param #table element
-- @param #string name
--
function Model.removeModuleModel(element, name)
  if element.modules[name] == nil then element.modules[name] = 0 end
  if element.modules[name] > 0 then
    element.modules[name] = element.modules[name] - 1
  end
end

-------------------------------------------------------------------------------
-- Create recipe model
--
-- @function [parent=#Model] createRecipeModel
--
-- @param #string name
-- @param #string type
--
-- @return #table
--
function Model.createRecipeModel(name, type)
  Logging:debug(Model.classname, "createRecipeModel():", name, type)
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
  recipeModel.factory = Model.createFactoryModel()
  recipeModel.beacon = Model.createBeaconModel()

  return recipeModel
end

-------------------------------------------------------------------------------
-- Create resource model
--
-- @function [parent=#Model] createResourceModel
--
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.createResourceModel(name, type, count)
  Logging:debug(Model.classname, "createResourceModel():", name, type, count)
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
  resourceModel.factory = Model.createFactoryModel()
  resourceModel.beacon = Model.createBeaconModel()

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
-- Check and valid unlinked all blocks
--
-- @function [parent=#Model] checkUnlinkedBlocks
--
function Model.checkUnlinkedBlocks()
  Logging:debug(Model.classname, "checkUnlinkedBlocks()")
  local model = Model.getModel()
  if model.blocks ~= nil then
    for _,block in spairs(model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
      Model.checkUnlinkedBlock( block)
    end
  end
end

-------------------------------------------------------------------------------
-- Check and valid unlinked block
--
-- @function [parent=#Model] checkUnlinkedBlock
--
-- @param #table block
--
function Model.checkUnlinkedBlock(block)
  Logging:debug(Model.classname, "checkUnlinkedBlock():", block)
  local model = Model.getModel()
  local unlinked = true
  local recipe = Player.getRecipe(block.name)
  if recipe ~= nil then
    if model.blocks ~= nil then
      for _, current_block in spairs(model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
        if current_block.id == block.id then
          Logging:debug(Model.classname, "checkUnlinkedBlock():break",block.id)
          break
        end
        for _,ingredient in pairs(current_block.ingredients) do
          for _,product in pairs(recipe.products) do
            if product.name == ingredient.name then
              unlinked = false
            end
          end
        end
        if current_block.id ~= block.id and current_block.name == block.name then
          unlinked = true
        end
      end
    end
    block.unlinked = unlinked
  end
end

-------------------------------------------------------------------------------
-- Add a recipe into production block
--
-- @function [parent=#Model] addRecipeIntoProductionBlock
--
-- @param #string key recipe name
-- @param #string type recipe type
--
function Model.addRecipeIntoProductionBlock(key, type)
  Logging:debug(Model.classname, "addRecipeIntoProductionBlock():", key, type)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  local blockId = globalGui.currentBlock
  local lua_recipe = RecipePrototype.load(key, type).native()

  if lua_recipe ~= nil then
    -- ajoute le bloc si il n'existe pas
    if model.blocks[blockId] == nil then
      local modelBlock = Model.createProductionBlockModel(lua_recipe)
      local index = Model.countBlocks()
      modelBlock.index = index
      modelBlock.unlinked = false
      model.blocks[modelBlock.id] = modelBlock
      blockId = modelBlock.id
      globalGui.currentBlock = blockId
      -- check si le block est independant
      Model.checkUnlinkedBlock(modelBlock)
    end

    -- ajoute le recipe si il n'existe pas
    local ModelRecipe = Model.createRecipeModel(lua_recipe.name, type)
    local index = Model.countBlockRecipes(blockId)
    ModelRecipe.index = index
    ModelRecipe.count = 1
    -- ajoute les produits du block
    for _, lua_product in pairs(RecipePrototype.getProducts()) do
      local product = Product.load(lua_product).new()
      model.blocks[blockId].products[lua_product.name] = product
    end

    -- ajoute les ingredients du block
    for _, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
      local ingredient = Product.load(lua_ingredient).new()
      model.blocks[blockId].ingredients[lua_ingredient.name] = ingredient
    end
    model.blocks[blockId].recipes[ModelRecipe.id] = ModelRecipe

    local defaultFactory = Model.getDefaultPrototypeFactory(RecipePrototype.getCategory(), lua_recipe.name)
    if defaultFactory ~= nil then
      Model.setFactory(blockId, ModelRecipe.id, defaultFactory)
    end
    local defaultBeacon = Model.getDefaultRecipeBeacon(lua_recipe.name)
    if defaultBeacon ~= nil then
      Model.setBeacon(blockId, ModelRecipe.id, defaultBeacon)
    end
    Logging:debug(Model.classname, "addRecipeIntoProductionBlock()", model.blocks[blockId])
    return model.blocks[blockId]
  end
end

-------------------------------------------------------------------------------
-- Add a primary power
--
-- @function [parent=#Model] addPrimaryPower
--
-- @param #string power_id power id
-- @param #string key generator name
--
function Model.addPrimaryPower(power_id, key)
  Logging:debug(Model.classname, "addPrimaryPower():", power_id, key)
  local model = Model.getModel()
  if model.powers == nil then model.powers = {} end
  local power = model.powers[power_id]
  if power == nil then
    power = Model.createPowerModel()
    power_id = power.id
    power.primary = Model.createGeneratorModel(key, 1)
    model.powers[power_id] = power
  end
  power.primary.name = key
  return power
end

-------------------------------------------------------------------------------
-- Add a secondary power
--
-- @function [parent=#Model] addSecondaryPower
--
-- @param #string power_id power id
-- @param #string key generator name
--
function Model.addSecondaryPower(power_id, key)
  Logging:debug(Model.classname, "addSecondaryPower():", key)
  local model = Model.getModel()
  if model.powers == nil then model.powers = {} end
  local power = model.powers[power_id]
  if power == nil then
    power = Model.createPowerModel()
    power_id = power.id
    model.powers[power_id] = power
  end
  if power.secondary == nil or power.secondary.name == nil then
    power.secondary = Model.createGeneratorModel(key, 1)
  end
  power.secondary.name = key
  return power
end
-------------------------------------------------------------------------------
-- Update a product
--
-- @function [parent=#Model] updateProduct
--
-- @param #string blockId production block id
-- @param #string key product name
-- @param #number quantity
--
function Model.updateProduct(blockId, key, quantity)
  Logging:debug(Model.classname, "updateProduct():", blockId, key, quantity)
  local model = Model.getModel()

  if model.blocks[blockId] ~= nil then
    local block = model.blocks[blockId]
    if block.input == nil then block.input = {} end
    block.input[key] = quantity
  end
end

-------------------------------------------------------------------------------
-- Update a production block option
--
-- @function [parent=#Model] updateProductionBlockOption
--
-- @param #string blockId production block id
-- @param #string option
-- @param #number value
--
function Model.updateProductionBlockOption(blockId, option, value)
  Logging:debug(Model.classname, "updateProductionBlockOption():", blockId, option, value)
  local model = Model.getModel()

  if model.blocks[blockId] ~= nil then
    local block = model.blocks[blockId]
    block[option] = value
  end
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
-- Update a beacon
--
-- @function [parent=#Model] updateBeacon
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options map attribute/valeur
--
function Model.updateBeacon(item, key, options)
  local object = Model.getObject(item, key)
  if object ~= nil then
    if options.combo ~= nil then
      object.beacon.combo = options.combo
    end
    if options.factory ~= nil then
      object.beacon.factory = options.factory
    end
  end
end

-------------------------------------------------------------------------------
-- Add a module in beacon
--
-- @function [parent=#Model] addBeaconModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function Model.addBeaconModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    Model.addModuleModel(object.beacon, name)
  end
end

-------------------------------------------------------------------------------
-- Remove a module in beacon
--
-- @function [parent=#Model] removeBeaconModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function Model.removeBeaconModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    Model.removeModuleModel(object.beacon, name)
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
-- Update a object
--
-- @function [parent=#Model] updateObject
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options
--
function Model.updateObject(item, key, options)
  Logging:debug(Model.classname, "updateObject():", item, key, options)
  local object = Model.getObject(item, key)
  if object ~= nil then
    if options.production ~= nil then
      object.production = options.production
    end
  end
end

-------------------------------------------------------------------------------
-- Update a power
--
-- @function [parent=#Model] updatePower
--
-- @param #string key power id
-- @param #table options
--
function Model.updatePower(key, options)
  Logging:debug(Model.classname, "updatePower():", options)
  local object = Model.getPower(key)
  if object ~= nil then
    if options.power ~= nil then
      object.power = options.power*1000000
      Model.computePower(key)
    end
  end
end

-------------------------------------------------------------------------------
-- Update a factory
--
-- @function [parent=#Model] updateFactory
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options
--
function Model.updateFactory(item, key, options)
  Logging:debug(Model.classname, "updateFactory():", item, key, options)
  local object = Model.getObject(item, key)
  if object ~= nil then
    object.factory.limit = options.limit or 0
  end
end

-------------------------------------------------------------------------------
-- Add a module in factory
--
-- @function [parent=#Model] addFactoryModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function Model.addFactoryModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    Model.addModuleModel(object.factory, name)
  end
end

-------------------------------------------------------------------------------
-- Remove a module from factory
--
-- @function [parent=#Model] removeFactoryModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function Model.removeFactoryModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    Model.removeModuleModel(object.factory, name)
  end
end

-------------------------------------------------------------------------------
-- Remove a production block
--
-- @function [parent=#Model] removeProductionBlock
--
-- @param #string blockId
--
function Model.removeProductionBlock(blockId)
  Logging:debug(Model.classname, "removeProductionBlock()", blockId)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    model.blocks[blockId] = nil
    Model.reIndexList(model.blocks)
  end
end

-------------------------------------------------------------------------------
-- Remove a production recipe
--
-- @function [parent=#Model] removeProductionRecipe
--
-- @param #string blockId
-- @param #string key
--
function Model.removeProductionRecipe(blockId, key)
  Logging:debug(Model.classname, "removeProductionRecipe()", blockId, key)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
    model.blocks[blockId].recipes[key] = nil
    Model.reIndexList(model.blocks[blockId].recipes)
    -- change block name
    local first_recipe = Model.firstRecipe(model.blocks[blockId].recipes)
    if first_recipe ~= nil then
      model.blocks[blockId].name = first_recipe.name
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
-- Unlink a production block
--
-- @function [parent=#Model] unlinkProductionBlock
--
-- @param #string blockId
--
function Model.unlinkProductionBlock(blockId)
  Logging:debug(Model.classname, "unlinkProductionBlock()", blockId)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    model.blocks[blockId].unlinked = not(model.blocks[blockId].unlinked)
  end
end

-------------------------------------------------------------------------------
-- Up a production block
--
-- @function [parent=#Model] upProductionBlock
--
-- @param #string blockId
-- @param #number step
--
function Model.upProductionBlock(blockId, step)
  Logging:debug(Model.classname, "upProductionBlock()", blockId, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    Model.upProductionList(model.blocks, model.blocks[blockId].index, step)
  end
end

-------------------------------------------------------------------------------
-- Up a production recipe
--
-- @function [parent=#Model] upProductionRecipe
--
-- @param #string blockId
-- @param #string key
-- @param #number step
--
function Model.upProductionRecipe(blockId, key, step)
  Logging:debug(Model.classname, "upProductionRecipe()", blockId, key, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
    Model.upProductionList(model.blocks[blockId].recipes, model.blocks[blockId].recipes[key].index, step)
    -- change block name
    local first_recipe = Model.firstRecipe(model.blocks[blockId].recipes)
    if first_recipe ~= nil then
      model.blocks[blockId].name = first_recipe.name
    end
  end
end

-------------------------------------------------------------------------------
-- Up in the list
--
-- @function [parent=#Model] upProductionList
--
-- @param #table list
-- @param #number index
-- @param #number step
--
function Model.upProductionList(list, index, step)
  Logging:debug(Model.classname, "upProductionList()", list, index, step)
  local model = Model.getModel()
  if list ~= nil and index > 0 then
    -- defaut step
    if step == nil then step = 1 end
    -- cap le step
    if step > index then step = index end
    for _,element in pairs(list) do
      if element.index == index then
        -- change l'index de l'element cible
        element.index = element.index - step
      elseif element.index >= index - step and element.index <= index then
        -- change les index compris entre index et index -step
        element.index = element.index + 1
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Down a production block
--
-- @function [parent=#Model] downProductionBlock
--
-- @param #string blockId
-- @param #number step
--
function Model.downProductionBlock(blockId, step)
  Logging:debug(Model.classname, "downProductionBlock()", blockId, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    Model.downProductionList(model.blocks, model.blocks[blockId].index, step)
  end
end

-------------------------------------------------------------------------------
-- Down a production recipe
--
-- @function [parent=#Model] downProductionRecipe
--
-- @param #string blockId
-- @param #string key
-- @param #number step
--
function Model.downProductionRecipe(blockId, key, step)
  Logging:debug(Model.classname, "downProductionRecipe()", blockId, key, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
    Model.downProductionList(model.blocks[blockId].recipes, model.blocks[blockId].recipes[key].index, step)
    -- change block name
    local first_recipe = Model.firstRecipe(model.blocks[blockId].recipes)
    if first_recipe ~= nil then
      model.blocks[blockId].name = first_recipe.name
    end
  end
end

-------------------------------------------------------------------------------
-- Down in the list
--
-- @function [parent=#Model] downProductionList
--
-- @param #table list
-- @param #number index
-- @param #number step
--
function Model.downProductionList(list, index, step)
  Logging:debug(Model.classname, "downProductionList()", list, index, step)
  local model = Model.getModel()
  local list_count = Model.countList(list)
  Logging:debug(Model.classname, "downProductionList()", list_count)
  if list ~= nil and index + 1 < Model.countList(list) then
    -- defaut step
    if step == nil then step = 1 end
    -- cap le step
    if step > (list_count - index) then step = list_count - index - 1 end
    for _,element in pairs(list) do
      if element.index == index then
        -- change l'index de l'element cible
        element.index = element.index + step
        Logging:debug(Model.classname, "index element", element.index, element.index + step)
      elseif element.index > index and element.index <= index + step then
        -- change les index compris entre index et la fin
        element.index = element.index - 1
      end
    end
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
-- Update model
--
-- @function [parent=#Model] update
--
function Model.update()
  Logging:debug(Model.classname , "********** update()")
  Model.updateVersion_0_5_4()
  Model.updateVersion_0_6_0()

  local model = Model.getModel()

  -- reset all factories
  if model ~= nil and (model.version == nil or model.version ~= Model.version) then
    Logging:debug(Model.classname , "********** version",Model.version)

    if model.blocks ~= nil then
      for _, productBlock in pairs(model.blocks) do
        for _, recipe in pairs(productBlock.recipes) do
          local factory = recipe.factory
          local beacon = recipe.beacon
          local _recipe = Player.getRecipe(recipe.name)
          Model.setFactory(productBlock.id, recipe.name, factory.name)
          Model.setBeacon(productBlock.id, recipe.name, beacon.name)
          if _recipe ~= nil then
            recipe.is_resource = not(_recipe.force)
            if recipe.is_resource then recipe.category = "extraction-machine" end
          end
        end
      end
    end
  end

  if model.blocks ~= nil then
    -- calcul les blocks
    local input = {}
    for _, block in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
      -- premiere recette
      local _,recipe = next(block.recipes)
      if recipe ~= nil then
        local lua_recipe = RecipePrototype.load(recipe).native()
        if not(block.unlinked) and RecipePrototype.getProducts() ~= nil then
          for _,product in pairs(RecipePrototype.getProducts()) do
            if input[product.name] ~= nil then
              -- block linked
              if block.input == nil then block.input = {} end
              block.input[product.name] = input[product.name]
            end
          end
        end

        Model.computeBlock(block)

        -- compte les ingredients
        for _,ingredient in pairs(block.ingredients) do
          if input[ingredient.name] == nil then
            input[ingredient.name] = ingredient.count
          else
            input[ingredient.name] = input[ingredient.name] + ingredient.count
          end
        end
        -- consomme les ingredients
        for _,product in pairs(block.products) do
          if input[product.name] ~= nil then
            input[product.name] = input[product.name] - product.count
          end
        end
      end
    end


    Model.computeInputOutput()

    Model.computeResources()

    Logging:debug(Model.classname, "update():","Factory compute OK")
    -- genere un bilan
    Model.createSummary()
    Logging:debug(Model.classname, "update():","Summary OK")

    Logging:debug(Model.classname , "********** model updated:",model)
  end
  model.version = Model.version
end

-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#Model] updateVersion_0_6_0
--
function Model.updateVersion_0_6_0()
  local model = Model.getModel()
  if model.version == nil or model.version < "0.6.0" then
    Logging:debug(Model.classname , "********** updating version 0.6.0")
    local globalGui = Player.getGlobalGui()
    for _, block in pairs(model.blocks) do
      globalGui.currentBlock = block.id
      for _, recipe in pairs(block.recipes) do
        local recipe_type = "recipe"
        if recipe.is_resource then recipe_type = "resource" end

        local recipeModel = {}
        recipeModel.id = recipe.id
        recipeModel.index = recipe.index
        recipeModel.name = recipe.name
        recipeModel.type = recipe_type
        recipeModel.count = 0
        recipeModel.production = 1
        recipeModel.factory = Model.createFactoryModel(recipe.factory.name)
        recipeModel.factory.limit = recipe.factory.limit
        recipeModel.factory.modules = recipe.factory.modules
        recipeModel.beacon = Model.createBeaconModel(recipe.beacon.name)
        recipeModel.beacon.modules = recipe.beacon.modules
        block.recipes[recipe.id] = recipeModel
      end
    end
    Model.checkUnlinkedBlocks()
    Logging:debug(Model.classname , "********** updated version 0.6.0")
    Player.print("Helmod information: Model is updated to version 0.6.0")
  end
end
-------------------------------------------------------------------------------
-- Update model
--
-- @function [parent=#Model] updateVersion_0_5_4
--
function Model.updateVersion_0_5_4()
  local model = Model.getModel()
  if model.version == nil or model.version < "0.5.4" then
    Logging:debug(Model.classname , "********** updating version 0.5.4")
    model.resources = {}
    for _, productBlock in pairs(model.blocks) do
      -- modify recipe id
      local recipes = {}
      for _, recipe in pairs(productBlock.recipes) do
        recipe.id = "R"..recipe.id
        recipes[recipe.id] = recipe
      end
      productBlock.recipes = recipes
      -- modify input
      if productBlock.input ~= nil and productBlock.input.key ~= nil then
        local key = productBlock.input.key
        local quantity = productBlock.input.quantity
        productBlock.input = {}
        productBlock.input[key] = quantity or 0
      end
    end
    Model.checkUnlinkedBlocks()
    Logging:debug(Model.classname , "********** updated version 0.5.4")
  end
end
-------------------------------------------------------------------------------
-- Compute recipe block
--
-- @function [parent=#Model] computeBlockRecipe
--
-- @param #table element production block model
--
function Model.computeBlockRecipe(block, recipe)
  Logging:debug(Model.classname, "computeBlockRecipe()", block.name, recipe.name, recipe.type)
  if recipe ~= nil then
    local lua_recipe = RecipePrototype.load(recipe).native()

    local production = 1
    if recipe.production ~= nil then production = recipe.production end

    -- recipe classique
    -- prepare le recipe
    for _, lua_product in pairs(RecipePrototype.getProducts()) do
      if block.ingredients[lua_product.name] ~= nil then
        local product = Product.load(lua_product).new()
        local p_amount = Product.getAmount(recipe)
        local count = block.ingredients[lua_product.name].count*production / p_amount
        if recipe.count < count then recipe.count = count end
      end
    end
    Logging:debug(Model.classname, "recipe.count=", recipe.count)

    -- compute ingredients
    for k, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
      local ingredient = Product.load(lua_ingredient).new()
      -- consolide la production
      local i_amount = ingredient.amount
      -- exclus le type ressource ou fluid
      if recipe.type ~= "resource" and recipe.type ~= "fluid" then
        for k, lua_product in pairs(RecipePrototype.getProducts()) do
          if lua_ingredient.name == lua_product.name then
            local product = Product.load(lua_product).new()
            i_amount = i_amount - product.amount
          end
        end
      end

      local nextCount = i_amount * recipe.count
      block.ingredients[lua_ingredient.name].count = block.ingredients[lua_ingredient.name].count + nextCount
      Logging:debug(Model.classname, "lua_ingredient.name", lua_ingredient.name, "nextCount=", nextCount)
    end
    Logging:debug(Model.classname, "block.ingredients=", block.ingredients)
  end
end

-------------------------------------------------------------------------------
-- Compute recipe block
--
-- @function [parent=#Model] computeBlockTechnology
--
-- @param #table element production block model
--
function Model.computeBlockTechnology(block, recipe)
  Logging:debug(Model.classname, "computeBlockTechnology()", block.name)
  local lua_recipe = RecipePrototype.load(recipe).native()
  local production = 1
  if recipe.production ~= nil then production = recipe.production end

  local productNominal = lua_recipe.research_unit_count
  if recipe.research_unit_count_formula ~= nil then
    productNominal = loadstring("local L = " .. lua_recipe.level .. " return " .. recipe.research_unit_count_formula)()
  end
  -- calcul factory productivity effect
  recipe.count = (productNominal - productNominal * recipe.factory.effects.productivity)*production

  -- compute ingredients
  for k, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
    local ingredient = Product.load(lua_ingredient).new()
    local i_amount = ingredient.amount
    local nextCount = i_amount * recipe.count
    block.ingredients[ingredient.name].count = block.ingredients[ingredient.name].count + nextCount
  end
end
-------------------------------------------------------------------------------
-- Compute production block
--
-- @function [parent=#Model] computeBlock
--
-- @param #table element production block model
--
function Model.computeBlock(block)
  Logging:debug(Model.classname, "computeBlock():", block.name)
  local model = Model.getModel()

  local recipes = block.recipes
  if recipes ~= nil then
    -- initialisation
    block.products = {}
    block.ingredients = {}
    block.power = 0
    block.count = 1

    -- preparation produits et ingredients du block
    for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
      local lua_recipe = RecipePrototype.load(recipe).native()
      -- construit la list des ingredients
      for _, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
        if block.ingredients[lua_ingredient.name] == nil then
          block.ingredients[lua_ingredient.name] = Product.load(lua_ingredient).new()
        end
        block.ingredients[lua_ingredient.name].count = 0
      end
      -- construit la list des produits
      for _, lua_product in pairs(RecipePrototype.getProducts()) do
        if block.products[lua_product.name] == nil then
          block.products[lua_product.name] = Product.load(lua_product).new()
          if not(block.ingredients[lua_product.name]) then
            block.products[lua_product.name].state = 1
          else
            block.products[lua_product.name].state = 0
          end
        end
        block.products[lua_product.name].count = 0
      end
      -- initialise le recipe
      recipe.count = 0
    end


    -- calcul selon la factory
    if block.by_factory == true then
      -- initialise la premiere recette avec le nombre d'usine
      local first_recipe = Model.firstRecipe(recipes)
      if first_recipe ~= nil then
        Logging:debug(Model.classname, "first_recipe",first_recipe)
        first_recipe.factory.count = block.factory_number
        Model.computeModuleEffects(first_recipe)
        Model.computeFactory(first_recipe)

        if first_recipe.type == "technology" then
          first_recipe.count = 1
        else
          local _,lua_product = next(RecipePrototype.load(first_recipe).getProducts())
          if block.input == nil then block.input = {} end
          -- formula [product amount] * (1 + [productivity]) *[assembly speed]*[time]/[recipe energy]
          block.input[lua_product.name] = Product.load(lua_product).getAmount(first_recipe) * (1 + first_recipe.factory.effects.productivity) * ( block.factory_number or 0 ) * first_recipe.factory.speed * model.time / RecipePrototype.getEnergy()
        end
      end
    end

    if block.input ~= nil then
      local input_computed = {}
      for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
        local lua_recipe = RecipePrototype.load(recipe).native()
        -- prepare le taux de production
        local production = 1
        if recipe.production ~= nil then production = recipe.production end
        -- initialise la premiere recette avec le input
        for _, lua_product in pairs(RecipePrototype.getProducts()) do
          local product = Product.load(lua_product).new()
          if input_computed[product.name] == nil and block.input[product.name] ~= nil then
            local p_amount = product.amount
            local i_amount = 0

            -- consolide product.count
            -- exclus le type ressource ou fluid
            if recipe.type ~= "resource" and recipe.type ~= "fluid" then
              for k, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
                if lua_ingredient.name == product.name then
                  local ingredient = Product.load(lua_ingredient).new()
                  i_amount = ingredient.amount
                end
              end
            end

            if block.ingredients[product.name] == nil then
              block.ingredients[product.name] = {
                name = product.name,
                type = "fake",
                amount = 0,
                count = 0
              }
            end
            block.ingredients[product.name].count = block.input[product.name] * (p_amount/(p_amount-i_amount))
            input_computed[product.name] = true
          end
        end
      end
    end

    Logging:debug(Model.classname , "********** initialized:", block)

    -- ratio pour le calcul du nombre de block
    local ratio = 1
    local ratioRecipe = nil
    -- calcul ordonnee sur les recipes du block
    for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
      Model.computeModuleEffects(recipe)

      if recipe.type == "technology" then
        Model.computeBlockTechnology(block, recipe)
      else
        Model.computeBlockRecipe(block, recipe)
      end

      Model.computeFactory(recipe)

      block.power = block.power + recipe.energy_total

      if type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
        local currentRatio = recipe.factory.limit/recipe.factory.count
        if currentRatio < ratio then
          ratio = currentRatio
          ratioRecipe = recipe.index
          -- block number
          block.count = recipe.factory.count/recipe.factory.limit
          -- subblock energy
          block.sub_power = 0
          if block.count ~= nil and block.count > 0 then
            block.sub_power = math.ceil(block.power/block.count)
          end
        end
      end

      Logging:debug(Model.classname , "********** Compute before clean:", block)

      local lua_recipe = RecipePrototype.load(recipe).native()
      -- reduit les produits du block
      -- state = 0 => produit
      -- state = 1 => produit pilotant
      -- state = 2 => produit restant
      for _, lua_product in pairs(RecipePrototype.getProducts()) do
        local count = Product.load(lua_product).countProduct(recipe)
        -- compte les produits
        if block.products[lua_product.name] ~= nil then
          block.products[lua_product.name].count = block.products[lua_product.name].count + count
        end
        -- consomme les produits
        if block.ingredients[lua_product.name] ~= nil then
          block.ingredients[lua_product.name].count = block.ingredients[lua_product.name].count - count
        end
      end
      Logging:debug(Model.classname , "********** Compute after clean product:", block)
      for _, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
        local count = Product.load(lua_ingredient).countIngredient(recipe)
        -- consomme les ingredients
        -- exclus le type ressource ou fluid
        if recipe.type ~= "resource" and recipe.type ~= "fluid" and block.products[lua_ingredient.name] ~= nil then
          block.products[lua_ingredient.name].count = block.products[lua_ingredient.name].count - count
        end
      end
      Logging:debug(Model.classname , "********** Compute after clean ingredient:", block)
    end

    if block.count < 1 then
      block.count = 1
    end

    -- reduit les engredients fake du block
    for _, ingredient in pairs(block.ingredients) do
      if ingredient.type == "fake" then block.ingredients[ingredient.name] = nil end
    end

    -- reduit les produits du block
    for _, product in pairs(block.products) do
      if block.ingredients[product.name] ~= nil then
        product.state = product.state + 2
      end
      if block.products[product.name].count < 0.01 and not(bit32.band(product.state, 1) > 0) then
        block.products[product.name] = nil
      end
    end

    -- reduit les ingredients du block
    for _, ingredient in pairs(block.ingredients) do
      if block.ingredients[ingredient.name].count < 0.01 then
        block.ingredients[ingredient.name] = nil
      end
    end

    -- calcul ratio
    for _, recipe in spairs(recipes,function(t,a,b) return t[b].index > t[a].index end) do
      recipe.factory.limit_count = recipe.factory.count*ratio
      recipe.beacon.limit_count = recipe.beacon.count*ratio
      if ratioRecipe ~= nil and ratioRecipe == recipe.index then
        recipe.factory.limit_count = recipe.factory.limit
      end
    end
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
-- Compute input and output
--
-- @function [parent=#Model] computeInputOutput
--
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function Model.computeInputOutput()
  Logging:debug(Model.classname, "computeInputOutput()")
  local model = Model.getModel()
  model.products = {}
  model.ingredients = {}

  local index = 1
  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- count product
    for _, product in pairs(element.products) do
      if model.products[product.name] == nil then
        model.products[product.name] = Model.createIngredientModel(product.name, product.type)
        model.products[product.name].index = index
        index = index + 1
      end
      model.products[product.name].count = model.products[product.name].count + product.count
    end
    -- count ingredient
    for _, ingredient in pairs(element.ingredients) do
      if model.ingredients[ingredient.name] == nil then
        model.ingredients[ingredient.name] = Model.createIngredientModel(ingredient.name, ingredient.type)
        model.ingredients[ingredient.name].index = index
        index = index + 1
      end
      model.ingredients[ingredient.name].count = model.ingredients[ingredient.name].count + ingredient.count
    end
  end

  for _, element in spairs(model.blocks, function(t,a,b) return t[b].index > t[a].index end) do
    -- consomme les produits
    for _, ingredient in pairs(element.ingredients) do
      if model.products[ingredient.name] ~= nil then
        model.products[ingredient.name].count = model.products[ingredient.name].count - ingredient.count
        if model.products[ingredient.name].count < 0.01 then model.products[ingredient.name] = nil end
      end
    end
    -- consomme les ingredients
    for _, product in pairs(element.products) do
      if model.ingredients[product.name] ~= nil then
        model.ingredients[product.name].count = model.ingredients[product.name].count - product.count
        if model.ingredients[product.name].count < 0.01 then model.ingredients[product.name] = nil end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Compute resources
--
-- @function [parent=#Model] computeResources
--
-- @param #ModelRecipe recipe
-- @param #number maxLoop
-- @param #number level
-- @param #string path
--
function Model.computeResources()
  Logging:debug(Model.classname, "computeResources()")
  local model = Model.getModel()
  local resources = {}

  -- calcul resource
  for k, ingredient in pairs(model.ingredients) do
    if ingredient.resource_category ~= nil or ingredient.name == "water" then
      local resource = model.resources[ingredient.name]
      if resource ~= nil then
        resource.count = ingredient.count
      else
        resource = Model.createResourceModel(ingredient.name, ingredient.type, ingredient.count)
      end

      if ingredient.resource_category == "basic-solid" then
        resource.category = "basic-solid"
      end
      if ingredient.name == "water" then
        resource.category = "basic-fluid"
      end
      if ingredient.name == "crude-oil" then
        resource.category = "basic-fluid"
      end

      resource.blocks = 1
      resource.wagon = nil
      resource.storage = nil
      local ratio = 1

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
-- Compute module effects of factory
--
-- @function [parent=#Model] computeModuleEffects
--
-- @param #table recipe
--
function Model.computeModuleEffects(recipe)
  Logging:debug(Model.classname, "computeModuleEffects()",recipe.name)

  local factory = recipe.factory
  factory.effects = {speed = 0, productivity = 0, consumption = 0}
  -- effet module factory
  if factory.modules ~= nil then
    for module, value in pairs(factory.modules) do
      local speed_bonus = Player.getModuleBonus(module, "speed")
      local productivity_bonus = Player.getModuleBonus(module, "productivity")
      local consumption_bonus = Player.getModuleBonus(module, "consumption")
      factory.effects.speed = factory.effects.speed + value * speed_bonus
      factory.effects.productivity = factory.effects.productivity + value * productivity_bonus
      factory.effects.consumption = factory.effects.consumption + value * consumption_bonus
    end
  end
  -- effet module beacon
  local beacon = recipe.beacon
  if beacon.modules ~= nil then
    for module, value in pairs(beacon.modules) do
      local speed_bonus = Player.getModuleBonus(module, "speed")
      local productivity_bonus = Player.getModuleBonus(module, "productivity")
      local consumption_bonus = Player.getModuleBonus(module, "consumption")
      local distribution_effectivity = EntityPrototype.load(beacon).distributionEffectivity()
      factory.effects.speed = factory.effects.speed + value * speed_bonus * distribution_effectivity * beacon.combo
      factory.effects.productivity = factory.effects.productivity + value * productivity_bonus * distribution_effectivity * beacon.combo
      factory.effects.consumption = factory.effects.consumption + value * consumption_bonus * distribution_effectivity * beacon.combo
    end
  end

  -- cap la vitesse a self.capSpeed
  if factory.effects.speed < Model.capSpeed  then factory.effects.speed = Model.capSpeed end

  -- cap l'energy a self.capEnergy
  if factory.effects.consumption < Model.capEnergy  then factory.effects.consumption = Model.capEnergy end

end

-------------------------------------------------------------------------------
-- Return spped factory for recipe
--
-- @function [parent=#Model] speedFactory
--
-- @param #table recipe
--
function Model.speedFactory(recipe)
  Logging:debug(Model.classname, "speedFactory()", recipe.name)
  if recipe.name == "steam" then
    -- @see https://wiki.factorio.com/Boiler
    return 60
  elseif recipe.type == "resource" then
    -- (mining power - ore mining hardness) * mining speed
    -- @see https://wiki.factorio.com/Mining
    local mining_speed = EntityPrototype.load(recipe.factory).miningSpeed()
    local mining_power = EntityPrototype.load(recipe.factory).miningPower()
    local hardness = EntityPrototype.load(recipe.name).mineableHardness()
    local mining_time = EntityPrototype.load(recipe.name).mineableMiningTime()
    local bonus = Player.getForce().mining_drill_productivity_bonus
    return (mining_power - hardness) * mining_speed * (1 + bonus) / mining_time
  else
    return EntityPrototype.load(recipe.factory).craftingSpeed()
  end
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number of factory for recipes
--
-- @function [parent=#Model] computeFactory
--
-- @param #table recipe
--
function Model.computeFactory(recipe)
  Logging:debug(Model.classname, "computeFactory()", recipe.name)
  local recipe_energy = RecipePrototype.load(recipe).getEnergy()
  -- effet speed
  recipe.factory.speed = Model.speedFactory(recipe) * (1 + recipe.factory.effects.speed)
  -- cap speed creation maximum de 1 cycle par tick
  if recipe_energy/recipe.factory.speed < 1/60 then recipe.factory.speed = 60*recipe_energy end

  -- effet consumption
  local energy_type = EntityPrototype.load(recipe.factory).energyType()
  if energy_type ~= "burner" then
    recipe.factory.energy = EntityPrototype.load(recipe.factory).energyUsage() * (1 + recipe.factory.effects.consumption)
  else
    recipe.factory.energy = 0
  end

  -- compte le nombre de machines necessaires
  local model = Model.getModel()
  -- [ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory] * [le temps en second])
  local count = recipe.count*recipe_energy/(recipe.factory.speed * model.time)
  Logging:debug(Model.classname, "computeFactory()", "recipe.count=" , recipe.count, "lua_recipe.energy=", recipe_energy, "recipe.factory.speed=", recipe.factory.speed, "model.time=", model.time)
  if recipe.factory.speed == 0 then count = 0 end
  recipe.factory.count = count
  if Model.countModulesModel(recipe.beacon) > 0 then
    recipe.beacon.count = count/recipe.beacon.factory
  else
    recipe.beacon.count = 0
  end

  recipe.beacon.energy = EntityPrototype.load(recipe.beacon).energyUsage()
  -- calcul des totaux
  recipe.factory.energy_total = math.ceil(recipe.factory.count*recipe.factory.energy)
  recipe.beacon.energy_total = math.ceil(recipe.beacon.count*recipe.beacon.energy)
  recipe.energy_total = recipe.factory.energy_total + recipe.beacon.energy_total
  -- arrondi des valeurs
  recipe.factory.speed = recipe.factory.speed
  recipe.factory.energy = math.ceil(recipe.factory.energy)
  recipe.beacon.energy = math.ceil(recipe.beacon.energy)
end

-------------------------------------------------------------------------------
-- Compute energy, speed, number total
--
-- @function [parent=#Model] createSummary
--
function Model.createSummary()
  local model = Model.getModel()
  model.summary = {}
  model.summary.factories = {}
  model.summary.beacons = {}
  model.summary.modules = {}

  local energy = 0

  -- cumul de l'energie des blocks
  for _, block in pairs(model.blocks) do
    energy = energy + block.power
    for _, recipe in pairs(block.recipes) do
      Model.computeSummaryFactory(recipe)
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
-- @function [parent=#Model] computeSummaryFactory
--
-- @param object object
--
function Model.computeSummaryFactory(object)
  local model = Model.getModel()
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
-- Compute power
--
-- @function [parent=#Model] computePower
--
-- @param key power id
--
function Model.computePower(key)
  local power = Model.getPower(key)
  Logging:debug(Model.classname, "computePower():", key, power)
  if power ~= nil then
    if EntityPrototype.load(power.primary.name).type() == EntityType.generator then
      -- calcul primary
      local count = math.ceil( power.power / EntityPrototype.load(power.primary.name).getEnergyNominal() )
      power.primary.count = count or 0
      -- calcul secondary
      if EntityPrototype.load(power.secondary.name).native() ~= nil and EntityPrototype.load(power.secondary.name).type() == EntityType.boiler then
        local count = math.ceil( power.power / EntityPrototype.load(power.secondary.name).getEnergyNominal() )
        power.secondary.count = count or 0
      else
        power.secondary.count = 0
      end
    end
    if EntityPrototype.load(power.primary.name).type() == EntityType.solar_panel then
      -- calcul primary
      local count = math.ceil( power.power / EntityPrototype.load(power.primary.name).getEnergyNominal() )
      power.primary.count = count or 0
      -- calcul secondary
      if EntityPrototype.load(power.secondary.name).native() ~= nil and EntityPrototype.load(power.secondary.name).type() == EntityType.accumulator then
        local factor = 2
        -- ajout energy pour accumulateur
        local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
        -- selon les aires il faut de l'accu en dehors du jour selon le trapese journalier
        local accu= (gameDay.dust/factor + gameDay.night + gameDay.dawn / factor ) / ( gameDay.day )
        -- puissance nominale la nuit
        local count1 = power.power/ EntityPrototype.load(power.secondary.name).electricOutputFlowLimit()
        -- puissance durant la penombre
        -- formula (puissance*durree_penombre)/(60s*capacite)
        local count2 = power.power*( gameDay.dust / factor + gameDay.night + gameDay.dawn / factor ) / ( 60 * EntityPrototype.load(power.secondary.name).electricBufferCapacity() )

        Logging:debug(Model.classname , "********** computePower result:", accu, count1, count2)
        if count1 > count2 then
          power.secondary.count = count1 or 0
        else
          power.secondary.count = count2 or 0
        end
        power.primary.count = count*(1+accu) or 0
      else
        power.secondary.count = 0
      end
    end
  end
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
  local crafting_speed = EntityPrototype.load(key).craftingSpeed()
  if crafting_speed ~= 0 then return crafting_speed end
  local mining_speed = EntityPrototype.load(key).miningSpeed()
  local mining_power = EntityPrototype.load(key).miningPower()
  if mining_speed ~= 0 and mining_power ~= 0 then return mining_speed * mining_power end
  return 1
end

-------------------------------------------------------------------------------
-- Get the factory of prototype
--
-- @function [parent=#Model] getDefaultPrototypeFactory
--
-- @param #string category
-- @param #string name
--
-- @return #string
--
function Model.getDefaultPrototypeFactory(category, name)
  if category ~= nil then
    local factories = Player.getProductionsCrafting(category, name)
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
