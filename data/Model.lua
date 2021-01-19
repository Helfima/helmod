------------------------------------------------------------------------------
-- Description of the module.
-- @module Model
--
-- @field [parent=#Model] #number time base time
--
local Model = {
  -- single-line comment
  classname = "HMModel",
  version = "0.9.35",
  -- 15°c
  initial_temp = 15,
  -- 200J/unit/°c
  fluid_energy_per_unit = 200,
  beacon_combo = 4,
  beacon_factory = 0.5,
  beacon_factory_constant = 3
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
  local display_all_sheet = User.getModGlobalSetting("display_all_sheet")
  local first_id = nil
  local models = {}
  if Model.countModel() > 0 then
    for _,model in pairs(global.models) do
      if Player.isAdmin() and ( display_all_sheet or model.owner == "admin" or bypass ) then
        models[model.id] = model
        if first_id == nil then first_id = model.id end
      elseif model.owner == Player.native().name or (model.share ~= nil and model.share > 0) then
        models[model.id] = model
        if first_id == nil then first_id = model.id end
      end
    end
  end
  return models
end

-------------------------------------------------------------------------------
-- Get block order
--
-- @function [parent=#Model] getBlockOrder
--
-- @return #table
--
function Model.getBlockOrder(block)
  local order = {"products", "ingredients"}
  if block.by_product == false then order = {"ingredients", "products"} end
  return order
end

-------------------------------------------------------------------------------
-- Get rules
--
-- @function [parent=#Model] getRules
--
-- @return #table
--
function Model.getRules()
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
  model.time = 1
  model.version = Model.version
  global.models[model.id] = model
  return model
end

-------------------------------------------------------------------------------
-- Get model
--
-- @function [parent=#Model] getModelById
--
-- @return #Model
--
function Model.getModelById(model_id)
  if model_id ~= nil and global.models ~= nil then
    return global.models[model_id]
  end
end

-------------------------------------------------------------------------------
-- Get model
--
-- @function [parent=#Model] getModelByParameter
--
-- @return #Model
--
function Model.getParameterObjects(parameter)
  if parameter ~= nil then
    if global.models == nil then
      -- initialisation
      global.models = {}
      local model = Model.newModel()
      User.setParameter(parameter.name, {name=parameter.name, model=model.id})
      return model
    end
    if parameter.model ~= nil and global.models[parameter.model] ~= nil then
      local model = global.models[parameter.model]
      local block, recipe
      if model ~= nil and parameter.block ~= nil and model.blocks ~= nil then
        block = model.blocks[parameter.block]
        if block ~= nil and parameter.recipe ~= nil and block.recipes ~= nil then
          recipe = block.recipes[parameter.recipe]
        end
      end
      return model, block, recipe
    else
      -- initialisation parameter
      local model = Model.getLastModel()
      if model == nil then model = Model.newModel() end
      User.setParameter(parameter.name, {name=parameter.name, model=model.id})
      return model
    end
  end
end

-------------------------------------------------------------------------------
-- Get last model
--
-- @function [parent=#Model] getLastModel
--
-- @return #Model
--
function Model.getLastModel()
  local last_model = nil
  local models = Model.getModels()
  for _,model in pairs(models) do
    last_model = model
  end
  return last_model
end

-------------------------------------------------------------------------------
-- Create model Production Block
--
-- @function [parent=#Model] newBlock
--
-- @param #table model
-- @param #table recipe
--
-- @return #table
--
function Model.newBlock(model, recipe)
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
  local beaconModel = {}
  beaconModel.name = name or "beacon"
  beaconModel.type = "item"
  beaconModel.count = count or 0
  beaconModel.energy = 0
  beaconModel.combo = Model.beacon_combo
  beaconModel.per_factory = Model.beacon_factory
  beaconModel.per_factory_constant = Model.beacon_factory_constant
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
  local factoryModel = {}
  factoryModel.name = name or "assembling-machine-1"
  factoryModel.type = "entity"
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
    for _, value in pairs(element.modules) do
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
-- @param #table model
-- @param #string name
-- @param #string type
--
-- @return #table
--
function Model.newRecipe(model, name, type)
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
-- @param #table model
-- @param #string name
-- @param #number count
--
-- @return #table
--
function Model.newResource(model, name, type, count)
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
-- Count in list
--
-- @function [parent=#Model] countModel
--
-- @return #number
--
function Model.countModel()
  return table.size(global.models)
end

-------------------------------------------------------------------------------
-- Set the beacon
--
-- @function [parent=#Model] setBeacon
--
-- @param #table recipe
-- @param #string beacon_name
-- @param #number combo
-- @param #number per_factory
-- @param #number per_factory_constant
--
function Model.setBeacon(recipe, name, combo, per_factory, per_factory_constant)
  if recipe ~= nil then
    local beacon_prototype = EntityPrototype(name)
    if beacon_prototype:native() ~= nil then
      recipe.beacon.name = name
      recipe.beacon.combo = combo or Model.beacon_combo
      recipe.beacon.per_factory = per_factory or Model.beacon_factory
      recipe.beacon.per_factory_constant = per_factory_constant or Model.beacon_factory_constant
      if Model.countModulesModel(recipe.beacon) >= beacon_prototype:getModuleInventorySize() then
        recipe.beacon.modules = {}
      end
      
    end
  end
end

-------------------------------------------------------------------------------
-- Set a factory
--
-- @function [parent=#Model] setFactory
--
-- @param #table recipe
-- @param #string factory_name
-- @param #string factory_fuel
--
function Model.setFactory(recipe, factory_name, factory_fuel)
  if recipe ~= nil then
    local factory_prototype = EntityPrototype(factory_name)
    if factory_prototype:native() ~= nil then
      recipe.factory.name = factory_name
      recipe.factory.fuel = factory_fuel
      if Model.countModulesModel(recipe.factory) >= factory_prototype:getModuleInventorySize() then
        recipe.factory.modules = {}
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
-- Return last recipe of block
--
-- @function [parent=#Model] lastRecipe
--
-- @param #table recipes
--
function Model.lastRecipe(recipes)
  for _, recipe in spairs(recipes,function(t,a,b) return t[b].index < t[a].index end) do
    return recipe
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
    local default_factory_level = User.getPreferenceSetting("default_factory_level")
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
    end
    if lua_factory ~= nil then return lua_factory.name end
    if last_factory ~= nil then return last_factory.name end
  end
  return nil
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
