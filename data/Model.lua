------------------------------------------------------------------------------
-- Description of the module.
-- @module Model
--
-- @field [parent=#Model] #number time base time
--
local Model = {
  -- single-line comment
  classname = "HMModel",
  version = "0.9.3",
  capEnergy = -0.8,
  capSpeed = -0.8,
  -- 15°c
  initial_temp = 15,
  -- 200J/unit/°c
  fluid_energy_per_unit = 200,
  beacon_combo = 4,
  beacon_factory = 1.2

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
  local model_id = User.getParameter("model_id")
  local display_all_sheet = User.getModGlobalSetting("display_all_sheet")
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
    User.setParameter("model_id",first_id)
  end
  return models
end

-------------------------------------------------------------------------------
-- Get rules
--
-- @function [parent=#Model] getRules
--
-- @return #table
--
function Model.getRules()
  Logging:trace(Model.classname, "getRules()", global.rules)
  if global.rules == nil then
    Model.resetRules()
  end
  return global.rules
end

-------------------------------------------------------------------------------
-- Reset rules
--
-- @function [parent=#Model] resetRules
--
function Model.resetRules()
  Logging:trace(Model.classname, "resetRules()", global.rules)
  global.rules = {}
  table.insert(global.rules, {index=0, mod="base", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="extraction-machine", excluded = false})
  table.insert(global.rules, {index=1, mod="base", name="production-crafting", category="extraction-machine", type="entity-type", value="mining-drill", excluded = false})
  table.insert(global.rules, {index=2, mod="base", name="production-crafting", category="energy", type="entity-subgroup", value="energy", excluded = false})
  table.insert(global.rules, {index=3, mod="base", name="production-crafting", category="technology", type="entity-type", value="lab", excluded = false})
  table.insert(global.rules, {index=4, mod="base", name="module-limitation", category="extraction-machine", type="entity-type", value="mining-drill", excluded = true})
  table.insert(global.rules, {index=5, mod="base", name="module-limitation", category="technology", type="entity-type", value="lab", excluded = true})
  table.insert(global.rules, {index=6, mod="ShinyIcons", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="shinyminer1", excluded = false})
  table.insert(global.rules, {index=7, mod="ShinyIcons", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="shinyminer2", excluded = false})
  table.insert(global.rules, {index=8, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="dyworld-extraction-burner", excluded = false})
  table.insert(global.rules, {index=9, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="dyworld-drills-electric", excluded = false})
  table.insert(global.rules, {index=10, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="dyworld-drills-burner", excluded = false})
  table.insert(global.rules, {index=11, mod="DyWorld", name="production-crafting", category="standard", type="entity-name", value="assembling-machine-1", excluded = true})
  table.insert(global.rules, {index=12, mod="DyWorld", name="production-crafting", category="standard", type="entity-name", value="assembling-machine-2", excluded = true})
  table.insert(global.rules, {index=13, mod="DyWorld", name="production-crafting", category="standard", type="entity-name", value="assembling-machine-3", excluded = true})
  table.insert(global.rules, {index=14, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-group", value="production", excluded = true})
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
  User.setParameter("model_id",model.id)
  return model
end

-------------------------------------------------------------------------------
-- Get and initialize the model
--
-- @function [parent=#Model] getModel
--
-- @return #Model
--
function Model.getModel()
  Logging:trace(Model.classname, "getModel()")
  local model_id = User.getParameter("model_id")
  if model_id == "new" then
    Model.newModel()
  end

  model_id = User.getParameter("model_id")
  local models = Model.getModels()
  local model = models[model_id]
  if model == nil then return Model.newModel() end

  return model
end

-------------------------------------------------------------------------------
-- Get last model
--
-- @function [parent=#Model] getLastModel
--
-- @return #Model
--
function Model.getLastModel()
  Logging:trace(Model.classname, "getLastModel()")
  local last_model = nil
  local models = Model.getModels()
  for _,model in pairs(models) do
    last_model = model
  end
  return last_model
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
  Logging:trace(Model.classname, "getObject()", item, key)
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
-- Get Recipe
--
-- @function [parent=#Model] getRecipe
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
  return RecipePrototype(object)
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
  Logging:trace(Model.classname, "getPower()", key)
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
  beaconModel.combo = Model.beacon_combo
  beaconModel.factory = Model.beacon_factory
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
  local model = User.get("model")

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
-- Create model Rule
--
-- @function [parent=#Model] newRule
--
-- @param #string mod
-- @param #string name
-- @param #string category
-- @param #string type
-- @param #string value
-- @param #boolean excluded
-- @param #number index
--
-- @return #Table
--
function Model.newRule(mod, name, category, type, value, excluded, index)
  Logging:debug(Model.classname, "newRule()", mod, name, category, type, value, excluded, index)
  local rule_model = {}
  rule_model.mod = mod
  rule_model.name = name
  rule_model.category = category
  rule_model.type = type
  rule_model.value = value
  rule_model.excluded = excluded
  rule_model.index = index

  return rule_model
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
  if element ~= nil and element.modules ~= nil then
    for name, value in pairs(element.modules) do
      count = count + value
    end
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
  return Model.countList(model.recipes)
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
  return Model.countList(model.ingredients)
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
  return Model.countList(model.blocks)
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
  return Model.countList(model.powers)
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
function Model.countBlockRecipes(blockId)
  local model = Model.getModel()
  if model.blocks[blockId] == nil then return 0 end
  return Model.countList(model.blocks[blockId].recipes)
end

-------------------------------------------------------------------------------
-- Count in list
--
-- @function [parent=#Model] countModel
--
-- @return #number
--
function Model.countModel()
  return Model.countList(global.models)
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
  if list == nil then return 0 end
  return table_size(list)
end

-------------------------------------------------------------------------------
-- Set the beacon
--
-- @function [parent=#Model] setBeacon
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #string name beacon name
-- @param #number combo beacon combo
-- @param #number factory beacon factory
--
function Model.setBeacon(item, key, name, combo, factory)
  local object = Model.getObject(item, key)
  if object ~= nil then
    local beacon_prototype = EntityPrototype(name)
    if beacon_prototype:native() ~= nil then
      object.beacon.name = name
      object.beacon.combo = combo or Model.beacon_combo
      object.beacon.factory = factory or Model.beacon_factory
      if Model.countModulesModel(object.beacon) >= beacon_prototype:getModuleInventorySize() then
        object.beacon.modules = {}
      end
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
  Logging:debug(Model.classname, "setFactory()", item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    local factory_prototype = EntityPrototype(name)
    if factory_prototype:native() ~= nil then
      object.factory.name = name
      if Model.countModulesModel(object.factory) >= factory_prototype:getModuleInventorySize() then
        object.factory.modules = {}
      end
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
  local default = User.get("default")

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
  local entity_prototype = EntityPrototype(key)
  local crafting_speed = entity_prototype:getCraftingSpeed()
  if crafting_speed ~= 0 then return crafting_speed end
  local mining_speed = entity_prototype:getMiningSpeed()
  if mining_speed ~= 0 then return mining_speed end
  return 1
end

-------------------------------------------------------------------------------
-- Get the factory of prototype
--
-- @function [parent=#Model] getDefaultPrototypeFactory
--
-- @param #RecipePrototype recipe_prototype
--
-- @return #string
--
function Model.getDefaultPrototypeFactory(recipe_prototype)
  local category = recipe_prototype:getCategory()
  if category ~= nil then
    local factories = Player.getProductionsCrafting(category, recipe_prototype:native())
    local default_factory_level = User.getModGlobalSetting("default_factory_level")
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
