------------------------------------------------------------------------------
---Description of the module.
---@class Model
local Model = {
  ---single-line comment
  classname = "HMModel",
  version = 2,
  beacon_combo = 4,
  beacon_factory = 0.5,
  beacon_factory_constant = 3
}

-------------------------------------------------------------------------------
---Get models
---@param bypass boolean
---@return table
function Model.getModels(bypass)
  local display_all_sheet = User.getModGlobalSetting("display_all_sheet")
  local first_id = nil
  local models = {}
  if Model.countModel() > 0 then
    for _,model in pairs(storage.models) do
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
---Get models
---@param bypass boolean
---@return table
function Model.getModelsByOwner(bypass)
  local models = Model.getModels(bypass)
  local models_by_owner = {}
  for _, model in pairs(models) do
    if models_by_owner[model.owner] == nil then models_by_owner[model.owner] = {} end
    table.insert(models_by_owner[model.owner], model)
  end
  return models_by_owner
end

-------------------------------------------------------------------------------
---Get models
---@return table
function Model.getModelsOwner()
  local models = Model.getModels()
  local models_owner = {}
  for _, model in pairs(models) do
    if model.owner == Player.native().name then
      table.insert(models_owner, model)
    end
  end
  return models_owner
end

-------------------------------------------------------------------------------
---Get block order
---@param block table
---@return table
function Model.getBlockOrder(block)
  local order = {"products", "ingredients"}
  if block.by_product == false then order = {"ingredients", "products"} end
  return order
end

-------------------------------------------------------------------------------
---Get rules
---@return table
function Model.getRules()
  if storage.rules == nil then
    Model.resetRules()
  end
  return storage.rules
end

-------------------------------------------------------------------------------
---Reset rules
function Model.resetRules()
  local rules = {}
  table.insert(rules, {index=0, mod="base", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="extraction-machine", excluded = false})
  table.insert(rules, {index=1, mod="base", name="production-crafting", category="extraction-machine", type="entity-type", value="mining-drill", excluded = false})
  table.insert(rules, {index=2, mod="base", name="production-crafting", category="energy", type="entity-subgroup", value="energy", excluded = false})
  table.insert(rules, {index=3, mod="base", name="production-crafting", category="technology", type="entity-type", value="lab", excluded = false})
  table.insert(rules, {index=4, mod="base", name="module-limitation", category="extraction-machine", type="entity-type", value="mining-drill", excluded = true})
  table.insert(rules, {index=5, mod="base", name="module-limitation", category="technology", type="entity-type", value="lab", excluded = true})
  table.insert(rules, {index=6, mod="ShinyIcons", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="shinyminer1", excluded = false})
  table.insert(rules, {index=7, mod="ShinyIcons", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="shinyminer2", excluded = false})
  table.insert(rules, {index=8, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="dyworld-extraction-burner", excluded = false})
  table.insert(rules, {index=9, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="dyworld-drills-electric", excluded = false})
  table.insert(rules, {index=10, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-subgroup", value="dyworld-drills-burner", excluded = false})
  table.insert(rules, {index=11, mod="DyWorld", name="production-crafting", category="standard", type="entity-name", value="assembling-machine-1", excluded = true})
  table.insert(rules, {index=12, mod="DyWorld", name="production-crafting", category="standard", type="entity-name", value="assembling-machine-2", excluded = true})
  table.insert(rules, {index=13, mod="DyWorld", name="production-crafting", category="standard", type="entity-name", value="assembling-machine-3", excluded = true})
  table.insert(rules, {index=14, mod="DyWorld", name="production-crafting", category="extraction-machine", type="entity-group", value="production", excluded = true})
  table.insert(rules, {index=15, mod="Transport_Drones", name="production-crafting", category="standard", type="entity-name", value="supply-depot", excluded = true})
  table.insert(rules, {index=16, mod="Transport_Drones", name="production-crafting", category="standard", type="entity-name", value="request-depot", excluded = true})
  table.insert(rules, {index=17, mod="Transport_Drones", name="production-crafting", category="standard", type="entity-name", value="buffer-depot", excluded = true})
  storage.rules = rules
end


---Return effects on a table
---@return ModuleEffectsData
function Model.newEffects()
  return { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
end

-------------------------------------------------------------------------------
---Get and initialize the model
---@return table
function Model.newModel()
  if storage.model_id == nil then storage.model_id = 1 end
  if storage.models == nil then storage.models = {} end
  local owner = Player.native().name
  if owner == nil or owner == "" then owner = "admin" end
  storage.model_id = storage.model_id + 1
  local model = {}
  model.class = "Model"
  model.id = "model_"..storage.model_id
  model.owner = owner
  model.block_root = Model.newBlock(model, { name = model.id, energy_total = 0, pollution = 0, summary = {} })
  model.block_root.parent_id = model.id
  model.blocks = {}
  model.ingredients = {}
  model.resources = {}
  model.time = 1
  model.version = Model.version
  model.index = table.size(storage.models)
  Model.appendParameters(model)
  storage.models[model.id] = model
  return model
end

---Append parameters
---@param model ModelData
function Model.appendParameters(model)
  if model ~= nil then
    if model.parameters == nil then
      model.parameters = {}
    end
    if model.parameters.effects == nil then
      model.parameters.effects = Model.newEffects()
    end
  end
end

-------------------------------------------------------------------------------
---Get model
---@return table
function Model.getModelById(model_id)
  if model_id ~= nil and storage.models ~= nil then
    return storage.models[model_id]
  end
end

-------------------------------------------------------------------------------
---Get parameter objects
---@param parameter table --{name=parameter.name, model=model.id, block=block.id, recipe=recipe.id}
---@return ModelData, BlockData, RecipeData
function Model.getParameterObjects(parameter)
  if parameter ~= nil then
    if storage.models == nil then
      ---initialisation
      storage.models = {}
      local model = Model.newModel()
      User.setParameter(parameter.name, {name=parameter.name, model=model.id})
      return model
    end
    if parameter.model ~= nil and storage.models[parameter.model] ~= nil then
      local model = storage.models[parameter.model]
      local block, recipe
      if parameter.block ~= nil and model ~= nil and model.blocks ~= nil then
        block = model.blocks[parameter.block]
        if block == nil and model.block_root ~= nil and parameter.block == model.block_root.id then
          block = model.block_root
        end
      end
      if block == nil and model.block_root ~= nil then
        block = model.block_root
      end
      if block == nil and model.block_root == nil then
        block = Model.newBlock(model, { name = model.id, energy_total = 0, pollution = 0, summary = {} })
        model.block_root = block
      end
      if parameter.recipe ~= nil and block ~= nil and  block.children ~= nil then
        recipe = block.children[parameter.recipe]
      end
      return model, block, recipe
    else
      ---initialisation parameter
      local model = Model.getLastModel()
      if model == nil then model = Model.newModel() end
      if model.block_root == nil then
        local block = Model.newBlock(model, { name = model.id, energy_total = 0, pollution = 0, summary = {} })
        model.block_root = block
      end
      local parameterObjects = {name=parameter.name, model=model.id, block = model.block_root.id}
      User.setParameter(parameter.name, parameterObjects)
      return model, model.block_root, nil
    end
  end
end

-------------------------------------------------------------------------------
---Get last model
---@return table
function Model.getLastModel()
  local last_model = nil
  local models = Model.getModels()
  for _,model in pairs(models) do
    last_model = model
  end
  return last_model
end

-------------------------------------------------------------------------------
---Create model Production Block
---@param model ModelData
---@param child RecipeData | BlockData
---@return BlockData
function Model.newBlock(model, child)
  if model.block_id == nil then model.block_id = 0 end
  model.block_id = model.block_id + 1

  local blockModel = {}
  blockModel.class = "Block"
  blockModel.id = "block_"..model.block_id
  blockModel.index = 0
  blockModel.name = child.name
  blockModel.type = child.type
  if Player.native() == nil then
    blockModel.owner = model.owner
  else
    blockModel.owner = Player.native().name
  end
  blockModel.count = 1
  blockModel.power = 0
  blockModel.ingredients = {}
  blockModel.products = {}
  blockModel.children = {}
  blockModel.pollution = 0

  return blockModel
end

-------------------------------------------------------------------------------
---Retrun true if is a unlinked block
---@param block BlockData
---@return boolean
function Model.isUnlinkedBlock(block)
  if block == nil or block.class ~= "Block" then
    return false
  end
  return block.unlinked and true or false
end

-------------------------------------------------------------------------------
---Retrun true if is a block
---@param child RecipeData | BlockData
---@return boolean
function Model.isBlock(child)
  if child.class == "Block" then
    return true
  else
    return child.children ~= nil
  end
end

-------------------------------------------------------------------------------
---Retrun true if is expand block for this player
---@param block BlockData
---@return boolean
function Model.isExpandBlock(block)
  if block.class == "Block" then
    local player_name = Player.getName()
    if type(block.expanded) ~= "table" then
      block.expanded = {}
      block.expanded[player_name] = false
    end
    return block.expanded[player_name]
  end
  return false
end

-------------------------------------------------------------------------------
---Set expand block for this player
---@param block BlockData
---@param value boolean
function Model.setExpandBlock(block, value)
  if block.class == "Block" then
    local player_name = Player.getName()
    if type(block.expanded) ~= "table" then
      block.expanded = {}
      block.expanded[player_name] = false
    end
    block.expanded[player_name] = value
  end
end

-------------------------------------------------------------------------------
---Create model element
---@param type string
---@param name string
---@param quality? string
---@return table
function Model.newElement(type, name, quality)
  return {type=type, name=name, quality=quality or "normal"}
end

-------------------------------------------------------------------------------
---Create model Beacon
---@param name string
---@param amount number
---@return table
function Model.newBeacon(name, amount)
  local beaconModel = {}
  beaconModel.class = "Beacon"
  beaconModel.name = name or "beacon"
  beaconModel.type = "entity"
  beaconModel.amount = amount or 0
  beaconModel.energy = 0
  beaconModel.combo = User.getPreferenceSetting("beacon_affecting_one")
  beaconModel.per_factory = User.getPreferenceSetting("beacon_by_factory")
  beaconModel.per_factory_constant = User.getPreferenceSetting("beacon_constant")
  ---limit infini = 0
  beaconModel.limit = 0
  ---modules
  beaconModel.modules = {}
  return beaconModel
end

-------------------------------------------------------------------------------
---Create model Factory
---@param name string
---@param amount number
---@return table
function Model.newFactory(name, amount)
  local factoryModel = {}
  factoryModel.class = "Factory"
  factoryModel.name = name or "assembling-machine-1"
  factoryModel.type = "entity"
  factoryModel.amount = amount or 0
  factoryModel.energy = 0
  factoryModel.speed = 0
  ---limit infini = 0
  factoryModel.limit = 0
  ---modules
  factoryModel.modules = {}
  return factoryModel
end

-------------------------------------------------------------------------------
---Create model Ingredient
---@param name string
---@param type string
---@param count number
---@return table
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
---Create model Rule
---@param mod string
---@param name string
---@param category string
---@param type string
---@param value string
---@param excluded boolean
---@param index number
---@return table
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
---Count modules model
---@param element table
---@return number
function Model.countModulesModel(element)
  local count = 0
  if element ~= nil and element.modules ~= nil then
    for _, module in pairs(element.modules) do
      count = count + module.amount
    end
  end
  return count
end

-------------------------------------------------------------------------------
---Return quality element key
---@param model ModelData
---@return ModelInfosData
function Model.getModelInfos(model)
  if model.infos == nil then
    model.infos = {}
  end
  return model.infos
end

-------------------------------------------------------------------------------
---Return quality element key
---@param element table
---@return string
function Model.getQualityElementKey(element)
  if element.quality == nil then
    return element.name
  end
  return string.format("%s-%s", element.name, element.quality)
end

-------------------------------------------------------------------------------
---Compare modules
---@param module1 ModuleData
---@param module2 ModuleData
---@param with_amount? boolean
---@return boolean
function Model.compareModules(module1, module2, with_amount)
  if with_amount == true then
    return module1.name == module2.name and module1.quality == module2.quality and module1.amount == module2.amount
  else
    return module1.name == module2.name and module1.quality == module2.quality
  end
end
-------------------------------------------------------------------------------
---Create model Recipe
---@param model ModelData
---@param name string
---@param type string
---@return table
function Model.newRecipe(model, name, type)
  if model.recipe_id == nil then model.recipe_id = 0 end
  model.recipe_id = model.recipe_id + 1

  local recipeModel = {}
  recipeModel.class = "Recipe"
  recipeModel.id = "R"..model.recipe_id
  recipeModel.index = 1
  recipeModel.name = name
  recipeModel.type = type or "recipe"
  recipeModel.count = 0
  recipeModel.production = 1
  --recipeModel.factory = Model.newFactory()
  recipeModel.beacons = {}
  --table.insert(recipeModel.beacons, Model.newBeacon())

  return recipeModel
end

-------------------------------------------------------------------------------
---Create model Resource
---@param model ModelData
---@param name string
---@param type string
---@param count number
---@return table
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

  return resourceModel
end

-------------------------------------------------------------------------------
---Count in list
---@return number
function Model.countModel()
  return table.size(storage.models)
end

-------------------------------------------------------------------------------
---Set the beacon
---@param recipe RecipeData
---@param name string
---@param quality string
---@param combo number
---@param per_factory number
---@param per_factory_constant number
---@return BeaconData
function Model.addBeacon(recipe, name, quality, combo, per_factory, per_factory_constant)
  if recipe ~= nil then
    local beacon_prototype = EntityPrototype(name)
    if beacon_prototype:native() ~= nil then
      local beacon = Model.newBeacon(name, 0)
      beacon.quality = quality
      beacon.combo = combo or User.getPreferenceSetting("beacon_affecting_one")
      beacon.per_factory = per_factory or User.getPreferenceSetting("beacon_by_factory")
      beacon.per_factory_constant = per_factory_constant or User.getPreferenceSetting("beacon_constant")
      if recipe.beacons == nil then recipe.beacons = {} end
      table.insert(recipe.beacons, beacon)
      return beacon
    end
  end
end

-------------------------------------------------------------------------------
---Set the beacon
---@param recipe RecipeData
---@param index number
---@param name string
---@param combo number
---@param per_factory number
---@param per_factory_constant number
function Model.setBeacon(recipe, index, name, combo, per_factory, per_factory_constant)
  if recipe ~= nil and recipe.beacons ~= nil then
    local beacon_prototype = EntityPrototype(name)
    if beacon_prototype:native() ~= nil then
      local beacon = {}
      local beacon = Model.newBeacon(name, 0)
      beacon.combo = combo or User.getPreferenceSetting("beacon_affecting_one")
      beacon.per_factory = per_factory or User.getPreferenceSetting("beacon_by_factory")
      beacon.per_factory_constant = per_factory_constant or User.getPreferenceSetting("beacon_constant")
      if recipe.beacons[index] ~= nil then
        local old_beacon = recipe.beacons[index]
        local module_priority = old_beacon.module_priority
        beacon.module_priority = module_priority
        recipe.beacons[index] = beacon
      end
    end
  end
end

-------------------------------------------------------------------------------
---Set a factory
---@param recipe RecipeData
---@param factory_name string
---@param factory_quality? string
---@param factory_fuel? string | FuelData
function Model.setFactory(recipe, factory_name, factory_quality, factory_fuel)
  if recipe ~= nil then
    if factory_quality == "" then
      factory_quality = nil
    end
    local factory_prototype = EntityPrototype(factory_name)
    if factory_prototype:native() ~= nil then
      if recipe.factory == nil then
        recipe.factory = Model.newFactory()
        if recipe.beacons == nil or #recipe.beacons == 0 then
          recipe.beacons = {}
          table.insert(recipe.beacons, Model.newBeacon())
        end
      end
      recipe.factory.name = factory_name
      recipe.factory.quality = factory_quality
      recipe.factory.fuel = factory_fuel
      if Model.countModulesModel(recipe.factory) >= factory_prototype:getModuleInventorySize() then
        recipe.factory.modules = {}
      end
    end
  end
end

-------------------------------------------------------------------------------
---Return first recipe of block
---@param children {[string] : RecipeData | BlockData}
---@return RecipeData | BlockData
function Model.firstChild(children)
  for _, child in spairs(children, defines.sorters.block.sort) do
    return child
  end
end

-------------------------------------------------------------------------------
---Return last recipe of block
---@param children {[string] : RecipeData | BlockData}
---@return RecipeData | BlockData
function Model.lastChild(children)
  for _, child in spairs(children, defines.sorters.block.sort) do
    return child
  end
end

-------------------------------------------------------------------------------
---Get and initialize the default
---@return table
function Model.getDefault()
  local default = User.get("default")
  if default.recipes == nil then default.recipes = {} end
  return default
end

-------------------------------------------------------------------------------
---Get the default recipe
---@param key string --recipe name
---@return table
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
---Get speed of the factory
---@param key string --factory name
---@return number
function Model.getSpeedFactory(key)
  local entity_prototype = EntityPrototype(key)
  local crafting_speed = entity_prototype:getCraftingSpeed()
  if crafting_speed ~= 0 then return crafting_speed end
  local mining_speed = entity_prototype:getMiningSpeed()
  if mining_speed ~= 0 then return mining_speed end
  return 1
end

-------------------------------------------------------------------------------
---Get the factory of prototype
---@param recipe_prototype table
---@return string
function Model.getDefaultPrototypeFactory(recipe_prototype)
  local category = recipe_prototype:getCategory()
  if category ~= nil then
    local factories = {}
    if recipe_prototype:getType() == "boiler" then
      factories = Player.getBoilersForRecipe(recipe_prototype)
    elseif recipe_prototype:getType() == "fluid" then
      factories = Player.getProductionsCrafting("fluid", recipe_prototype:native())
    elseif recipe_prototype:getType() == "agricultural" then
      factories = Player.getAgriculturalTowers()
    else
      factories = Player.getProductionsCrafting(category, recipe_prototype:native())
    end
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
---Get the beacon of recipe
---@param key string --recipe name
---@return string
function Model.getDefaultRecipeBeacon(key)
  local default = Model.getDefault()
  if default.recipes[key] == nil then
    return nil
  end
  return default.recipes[key].beacon
end

---Check if factory has module
---@param factory FactoryData
---@return boolean
function Model.factoryHasModule(factory)
  if factory == nil then return false end
  if factory.modules == nil then return false end
  if factory.modules ~= nil and table.size(factory.modules) == 0 then return false end
  return true
end

---Compare module priorities
---@param module_priorities1 {[uint] : ModulePriorityData}
---@param module_priorities2 {[uint] : ModulePriorityData}
function Model.compareModulePriorities(module_priorities1, module_priorities2)
  if module_priorities1 == nil or module_priorities2 == nil then return false end
  if #module_priorities1 ~= #module_priorities2 then return false end
    for i = 1, #module_priorities1, 1 do
      local module_priority1 = module_priorities1[i]
      local module_priority2 = module_priorities2[i]
      if module_priority1.name ~= module_priority2.name then return false end
      if module_priority1.value ~= module_priority2.value then return false end
    end
  return true
end

---Compare 2 factories
---@param factory1 FactoryData
---@param factory2 FactoryData
---@param with_priority boolean
---@return boolean
function Model.compareFactory(factory1, factory2, with_priority)
  if factory1 == nil or factory2 == nil then return false end
  if factory1.name ~= factory2.name then return false end
  if factory1.fuel ~= factory2.fuel then return false end
  if with_priority and Model.compareModulePriorities(factory1.module_priority, factory2.module_priority) == false then return false end
  return true
end

---Compare 2 factories
---@param beacon1 BeaconData
---@param beacon2 BeaconData
---@param with_priority boolean
---@return boolean
function Model.compareBeacon(beacon1, beacon2, with_priority)
  if beacon1 == nil or beacon2 == nil then return false end
  if beacon1.name ~= beacon2.name then return false end
  if beacon1.fuel ~= beacon2.fuel then return false end
  if beacon1.combo ~= beacon2.combo then return false end
  if beacon1.per_factory ~= beacon2.per_factory then return false end
  if beacon1.per_factory_constant ~= beacon2.per_factory_constant then return false end
  if with_priority and Model.compareModulePriorities(beacon1.module_priority, beacon2.module_priority) == false then return false end
  return true
end

---Compare 2 factories
---@param beacons1 {[uint] : BeaconData}
---@param beacons2 {[uint] : BeaconData}
---@return boolean
function Model.compareBeacons(beacons1, beacons2)
  if beacons1 == nil or beacons2 == nil then return false end
  if #beacons1 ~= #beacons2 then return false end
  for i = 1, #beacons1, 1 do
    local beacon1 = beacons1[i]
    local beacon2 = beacons2[i]
    local with_priority = Model.factoryHasModule(beacon1) or Model.factoryHasModule(beacon2)
    if Model.compareBeacon(beacon1, beacon2, with_priority) == false then return false end
  end
  return true
end

return Model
