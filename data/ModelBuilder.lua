------------------------------------------------------------------------------
-- Description of the module.
-- @module ModelBuilder
--
local ModelBuilder = {
  -- single-line comment
  classname = "HMModelBuilder"
}

-------------------------------------------------------------------------------
-- Add a recipe into production block
--
-- @function [parent=#ModelBuilder] addRecipeIntoProductionBlock
--
-- @param #string key recipe name
-- @param #string type recipe type
--
-- @return recipe
--
function ModelBuilder.addRecipeIntoProductionBlock(key, type)
  Logging:debug(ModelBuilder.classname, "addRecipeIntoProductionBlock()", key, type)
  local model = Model.getModel()
  local current_block = User.getParameter("current_block")
  local recipe_prototype = RecipePrototype(key, type)
  local lua_recipe = recipe_prototype:native()

  if lua_recipe ~= nil then
    -- ajoute le bloc si il n'existe pas
    if model.blocks[current_block] == nil then
      local modelBlock = Model.newBlock(lua_recipe)
      local index = Model.countBlocks()
      modelBlock.index = index
      modelBlock.unlinked = false
      model.blocks[modelBlock.id] = modelBlock
      current_block = modelBlock.id
      User.setParameter("current_block",current_block)
      -- check si le block est independant
      ModelCompute.checkUnlinkedBlock(modelBlock)
    end

    -- ajoute le recipe si il n'existe pas
    local ModelRecipe = Model.newRecipe(lua_recipe.name, type)
    local index = Model.countBlockRecipes(current_block)
    ModelRecipe.index = index
    ModelRecipe.count = 1
    -- ajoute les produits du block
    for _, lua_product in pairs(recipe_prototype:getProducts()) do
      local product = Product(lua_product):clone()
      if model.blocks[current_block].products[lua_product.name] == nil then
        if model.blocks[current_block].ingredients[lua_product.name] ~= nil then
          product.state = 2
        else
          product.state = 1
        end
        model.blocks[current_block].products[lua_product.name] = product
      end
    end

    -- ajoute les ingredients du block
    for _, lua_ingredient in pairs(recipe_prototype:getIngredients()) do
      local ingredient = Product(lua_ingredient):clone()
      if model.blocks[current_block].ingredients[lua_ingredient.name] == nil then
        model.blocks[current_block].ingredients[lua_ingredient.name] = ingredient
        if model.blocks[current_block].products[lua_ingredient.name] ~= nil and model.blocks[current_block].products[lua_ingredient.name].state == 1 then
          model.blocks[current_block].products[lua_ingredient.name].state = 2
        end
      end
    end
    model.blocks[current_block].recipes[ModelRecipe.id] = ModelRecipe

    local default_factory = User.getDefaultFactory(ModelRecipe)
    if default_factory ~= nil then
      Model.setFactory(current_block, ModelRecipe.id, default_factory.name)
    else
      local default_factory_name = Model.getDefaultPrototypeFactory(recipe_prototype)
      if default_factory_name ~= nil then
        Model.setFactory(current_block, ModelRecipe.id, default_factory_name)
      end
    end
    local default_factory_module = User.getDefaultFactoryModule(ModelRecipe)
    if default_factory_module ~= nil then
      ModelBuilder.setFactoryModulePriority(current_block, ModelRecipe.id, default_factory_module)
    end

    local default_beacon = User.getDefaultBeacon(ModelRecipe)
    if default_beacon ~= nil then
      Model.setBeacon(current_block, ModelRecipe.id, default_beacon.name, default_beacon.combo, default_beacon.factory)
    else
      local default_beacon_name = Model.getDefaultRecipeBeacon(lua_recipe.name)
      if default_beacon_name ~= nil then
        Model.setBeacon(current_block, ModelRecipe.id, default_beacon_name)
      end
    end
    local default_beacon_module = User.getDefaultBeaconModule(ModelRecipe)
    if default_beacon_module ~= nil then
      ModelBuilder.setBeaconModulePriority(current_block, ModelRecipe.id, default_beacon_module)
    end
    
    Logging:debug(ModelBuilder.classname, "addRecipeIntoProductionBlock()", model.blocks[current_block])
    return ModelRecipe
  end
end

-------------------------------------------------------------------------------
-- Add a primary power
--
-- @function [parent=#ModelBuilder] addPrimaryPower
--
-- @param #string power_id power id
-- @param #string key generator name
--
function ModelBuilder.addPrimaryPower(power_id, key)
  Logging:debug(ModelBuilder.classname, "addPrimaryPower()", power_id, key)
  local model = Model.getModel()
  if model.powers == nil then model.powers = {} end
  local power = model.powers[power_id]
  if power == nil then
    power = Model.newPower()
    power_id = power.id
    power.primary = Model.newGenerator(key, 1)
    model.powers[power_id] = power
  end
  power.primary.name = key
  return power
end

-------------------------------------------------------------------------------
-- Add a secondary power
--
-- @function [parent=#ModelBuilder] addSecondaryPower
--
-- @param #string power_id power id
-- @param #string key generator name
--
function ModelBuilder.addSecondaryPower(power_id, key)
  Logging:debug(ModelBuilder.classname, "addSecondaryPower()", key)
  local model = Model.getModel()
  if model.powers == nil then model.powers = {} end
  local power = model.powers[power_id]
  if power == nil then
    power = Model.newPower()
    power_id = power.id
    model.powers[power_id] = power
  end
  if power.secondary == nil or power.secondary.name == nil then
    power.secondary = Model.newGenerator(key, 1)
  end
  power.secondary.name = key
  return power
end

-------------------------------------------------------------------------------
-- Remove a model
--
-- @function [parent=#ModelBuilder] removeModel
--
-- @param #number model_id
--
function ModelBuilder.removeModel(model_id)
  Logging:trace(ModelBuilder.classname, "removeModel()", model_id)
  global.models[model_id] = nil
  local models = Model.getModels()
  local model = Model.getLastModel()
  if model ~= nil then
    User.setParameter("model_id",model.id)
  else
    Model.newModel()
  end
end

-------------------------------------------------------------------------------
-- Remove a power
--
-- @function [parent=#ModelBuilder] removePower
--
-- @param #number power_id
--
function ModelBuilder.removePower(power_id)
  Logging:trace(ModelBuilder.classname, "removePower()", power_id)
  local model = Model.getModel()
  if model.powers ~= nil then
    model.powers[power_id] = nil
  end
end

-------------------------------------------------------------------------------
-- Remove a rule
--
-- @function [parent=#ModelBuilder] removeRule
--
-- @param #number power_id
--
function ModelBuilder.removeRule(rule_id)
  Logging:trace(ModelBuilder.classname, "removeRule()", rule_id)
  if global.rules ~= nil then
    Logging:debug(ModelBuilder.classname, "before remove rule", global.rules)
    table.remove(global.rules,rule_id)
    Model.reIndexList(global.rules)
    Logging:debug(ModelBuilder.classname, "after remove rule", global.rules)
  end
end

-------------------------------------------------------------------------------
-- Update a object
--
-- @function [parent=#ModelBuilder] updateObject
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options
--
function ModelBuilder.updateObject(item, key, options)
  Logging:debug(ModelBuilder.classname, "updateObject()", item, key, options)
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
-- @function [parent=#ModelBuilder] updatePower
--
-- @param #string key power id
-- @param #table options
--
function ModelBuilder.updatePower(key, options)
  Logging:debug(ModelBuilder.classname, "updatePower()", options)
  local object = Model.getPower(key)
  if object ~= nil then
    if options.power ~= nil then
      object.power = options.power*1000000
      ModelCompute.computePower(key)
    end
  end
end

-------------------------------------------------------------------------------
-- Update a factory
--
-- @function [parent=#ModelBuilder] updateFactory
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options
--
function ModelBuilder.updateFactory(item, key, options)
  Logging:debug(ModelBuilder.classname, "updateFactory()", item, key, options)
  local object = Model.getObject(item, key)
  if object ~= nil then
    object.factory.limit = options.limit or 0
  end
end

-------------------------------------------------------------------------------
-- Update a factory
--
-- @function [parent=#ModelBuilder] updateFuelFactory
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options
--
function ModelBuilder.updateFuelFactory(item, key, options)
  Logging:debug(ModelBuilder.classname, "updateFactory()", item, key, options)
  local object = Model.getObject(item, key)
  if object ~= nil then
    object.factory.fuel = options.fuel or "coal"
  end
end

-------------------------------------------------------------------------------
-- Add a module in factory
--
-- @function [parent=#ModelBuilder] addFactoryModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function ModelBuilder.addFactoryModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    ModelBuilder.addModuleModel(object.factory, name)
  end
end

-------------------------------------------------------------------------------
-- Set a module in factory
--
-- @function [parent=#ModelBuilder] setFactoryModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
-- @param #number value module number
--
function ModelBuilder.setFactoryModule(item, key, name, value)
  local object = Model.getObject(item, key)
  if object ~= nil then
    return ModelBuilder.setModuleModel(object.factory, name, value)
  end
  return false
end

-------------------------------------------------------------------------------
-- Set a module priority
--
-- @function [parent=#ModelBuilder] setModulePriority
--
-- @param #table element
-- @param #table module_priority
--
function ModelBuilder.setModulePriority(element, module_priority)
  if element ~= nil then
    for i,priority in pairs(module_priority) do
      if i == 1 then
        ModelBuilder.setModuleModel(element, priority.name, priority.value)
      else
        ModelBuilder.appendModuleModel(element, priority.name, priority.value)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set a module priority in factory
--
-- @function [parent=#ModelBuilder] setFactoryModulePriority
--
-- @param #string item
-- @param #string key object name
-- @param #table module_priority
--
function ModelBuilder.setFactoryModulePriority(item, key, module_priority)
  Logging:debug(ModelBuilder.classname, "setFactoryModulePriority()", item, key, module_priority)
  local element = Model.getObject(item, key)
  if element ~= nil then
    if module_priority == nil then
      element.factory.module_priority = nil
      element.factory.modules = {}
    else
      element.factory.module_priority = table.clone(module_priority)
      local first = true
      for i,priority in pairs(module_priority) do
        local module = ItemPrototype(priority.name)
        if Player.checkFactoryLimitationModule(module:native(), element) == true then
          Logging:debug(ModelBuilder.classname, "setFactoryModulePriority()", "ok", first)
          if first then
            ModelBuilder.setModuleModel(element.factory, priority.name, priority.value)
            first = false
          else
            ModelBuilder.appendModuleModel(element.factory, priority.name, priority.value)
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set a module priority in beacon
--
-- @function [parent=#ModelBuilder] setBeaconModulePriority
--
-- @param #string item
-- @param #string key object name
-- @param #table module_priority
--
function ModelBuilder.setBeaconModulePriority(item, key, module_priority)
  Logging:debug(ModelBuilder.classname, "setBeaconModulePriority()", item, key, module_priority)
  local element = Model.getObject(item, key)
  if element ~= nil then
    if module_priority == nil then
      element.beacon.module_priority = nil
      element.beacon.modules = {}
    else
      element.beacon.module_priority = table.clone(module_priority)
      local first = true
      for i,priority in pairs(module_priority) do
        local module = ItemPrototype(priority.name)
        if Player.checkBeaconLimitationModule(module:native(), element) == true then
          Logging:debug(ModelBuilder.classname, "setFactoryModulePriority()", "ok", first)
          if first then
            ModelBuilder.setModuleModel(element.beacon, priority.name, priority.value)
            first = false
          else
            ModelBuilder.appendModuleModel(element.beacon, priority.name, priority.value)
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set factory block
--
-- @function [parent=#ModelBuilder] setFactoryBlock
--
-- @param #string block_id
-- @param #table current_recipe recipe
--
function ModelBuilder.setFactoryBlock(block_id, current_recipe)
  if current_recipe ~= nil then
    local default_factory_mode = User.getParameter("default_factory_mode")
    local categories = EntityPrototype(current_recipe.factory.name):getCraftingCategories()
    local model = Model.getModel()
    local block = model.blocks[block_id]
    for key, recipe in pairs(block.recipes) do
      local prototype_recipe = RecipePrototype(recipe)
      if (default_factory_mode ~= "category" and categories[prototype_recipe:getCategory()]) or prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
        Model.setFactory(block_id, key, current_recipe.factory.name)
        if User.getParameter("default_factory_with_module") == true then
          ModelBuilder.setFactoryModulePriority(block_id, key, current_recipe.factory.module_priority)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set factory line
--
-- @function [parent=#ModelBuilder] setFactoryLine
--
-- @param #table current_recipe recipe
--
function ModelBuilder.setFactoryLine(current_recipe)
  if current_recipe ~= nil then
    local model = Model.getModel()
    for block_id, recipe in pairs(model.blocks) do
      ModelBuilder.setFactoryBlock(block_id, current_recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Set factory module block
--
-- @function [parent=#ModelBuilder] setFactoryModuleBlock
--
-- @param #string block_id
-- @param #table current_recipe recipe
--
function ModelBuilder.setFactoryModuleBlock(block_id, current_recipe)
  if current_recipe ~= nil then
    local default_factory_mode = User.getParameter("default_factory_mode")
    local model = Model.getModel()
    local block = model.blocks[block_id]
    for key, recipe in pairs(block.recipes) do
      local prototype_recipe = RecipePrototype(recipe)
      if default_factory_mode ~= "category" or prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
        ModelBuilder.setFactoryModulePriority(block_id, key, current_recipe.factory.module_priority)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set factory module line
--
-- @function [parent=#ModelBuilder] setFactoryModuleLine
--
-- @param #table current_recipe recipe
--
function ModelBuilder.setFactoryModuleLine(current_recipe)
  if current_recipe ~= nil then
    local model = Model.getModel()
    for block_id, recipe in pairs(model.blocks) do
      ModelBuilder.setFactoryModuleBlock(block_id, current_recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Set beacon block
--
-- @function [parent=#ModelBuilder] setBeaconBlock
--
-- @param #string block_id
-- @param #table current_recipe recipe
--
function ModelBuilder.setBeaconBlock(block_id, current_recipe)
  if current_recipe ~= nil then
    local default_beacon_mode = User.getParameter("default_beacon_mode")
    local model = Model.getModel()
    local block = model.blocks[block_id]
    for key, recipe in pairs(block.recipes) do
      local prototype_recipe = RecipePrototype(recipe)
      if default_beacon_mode ~= "category" or prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
        Model.setBeacon(block_id, key, current_recipe.beacon.name, current_recipe.beacon.combo, current_recipe.beacon.factory)
        if User.getParameter("default_beacon_with_module") == true then
          ModelBuilder.setBeaconModulePriority(block_id, key, current_recipe.beacon.module_priority)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set beacon line
--
-- @function [parent=#ModelBuilder] setBeaconLine
--
-- @param #table current_recipe recipe
--
function ModelBuilder.setBeaconLine(current_recipe)
  if current_recipe ~= nil then
    local model = Model.getModel()
    for block_id, recipe in pairs(model.blocks) do
      ModelBuilder.setBeaconBlock(block_id, current_recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Set beacon module block
--
-- @function [parent=#ModelBuilder] setBeaconModuleBlock
--
-- @param #string block_id
-- @param #table current_recipe recipe
--
function ModelBuilder.setBeaconModuleBlock(block_id, current_recipe)
  if current_recipe ~= nil then
    local default_beacon_mode = User.getParameter("default_beacon_mode")
    local model = Model.getModel()
    local block = model.blocks[block_id]
    for key, recipe in pairs(block.recipes) do
      local prototype_recipe = RecipePrototype(recipe)
      if default_beacon_mode ~= "category" or prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
        ModelBuilder.setBeaconModulePriority(block_id, key, current_recipe.beacon.module_priority)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Set beacon module line
--
-- @function [parent=#ModelBuilder] setBeaconModuleLine
--
-- @param #table current_recipe recipe
--
function ModelBuilder.setBeaconModuleLine(current_recipe)
  if current_recipe ~= nil then
    local model = Model.getModel()
    for block_id, recipe in pairs(model.blocks) do
      ModelBuilder.setBeaconModuleBlock(block_id, current_recipe)
    end
  end
end

-------------------------------------------------------------------------------
-- Remove a module from factory
--
-- @function [parent=#ModelBuilder] removeFactoryModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function ModelBuilder.removeFactoryModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    ModelBuilder.removeModuleModel(object.factory, name)
  end
end

-------------------------------------------------------------------------------
-- Remove a production block
--
-- @function [parent=#ModelBuilder] removeProductionBlock
--
-- @param #string blockId
--
function ModelBuilder.removeProductionBlock(blockId)
  Logging:debug(ModelBuilder.classname, "removeProductionBlock()", blockId)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    model.blocks[blockId] = nil
    Model.reIndexList(model.blocks)
  end
end

-------------------------------------------------------------------------------
-- Remove a production recipe
--
-- @function [parent=#ModelBuilder] removeProductionRecipe
--
-- @param #string blockId
-- @param #string key
--
function ModelBuilder.removeProductionRecipe(blockId, key)
  Logging:debug(ModelBuilder.classname, "removeProductionRecipe()", blockId, key)
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
-- Past model
--
-- @function [parent=#ModelBuilder] pastModel
--
-- @param #string from_model_id
-- @param #string from_block_id
--
function ModelBuilder.pastModel(from_model_id, from_block_id)
  local model = Model.getModel()
  local models = Model.getModels()
  local from_model = models[from_model_id]
  local from_block = from_model.blocks[from_block_id]

  if from_model ~= nil then
    if from_block ~= nil then
      ModelBuilder.copyBlock(from_model, from_block)
    else
      ModelBuilder.copyModel(from_model)
    end
  end
end

-------------------------------------------------------------------------------
-- Copy model
--
-- @function [parent=#ModelBuilder] copyModel
--
-- @param #table from_model
--
function ModelBuilder.copyModel(from_model)
  if from_model ~= nil then
    local from_block_ids = {}
    for block_id,block in spairs(from_model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
      table.insert(from_block_ids, block_id)
    end
    for _,block_id in ipairs(from_block_ids) do
      User.setParameter("current_block","new")
      local from_block = from_model.blocks[block_id]
      ModelBuilder.copyBlock(from_model, from_block)
    end
  end
end

-------------------------------------------------------------------------------
-- Copy block
--
-- @function [parent=#ModelBuilder] copyBlock
--
-- @param #table from_model_id
-- @param #table from_block_id
--
function ModelBuilder.copyBlock(from_model, from_block)
  local model = Model.getModel()
  local to_block_id = User.getParameter("current_block")

  if from_model ~= nil and from_block ~= nil then
    local from_recipe_ids = {}
    for recipe_id, recipe in spairs(from_block.recipes,function(t,a,b) return t[b].index > t[a].index end) do
      table.insert(from_recipe_ids, recipe_id)
    end
    local recipe_index = #from_recipe_ids
    for _, recipe_id in ipairs(from_recipe_ids) do
      local recipe = from_block.recipes[recipe_id]
      local recipe_prototype = RecipePrototype.find(recipe)
      if recipe_prototype:native() ~= nil then
        -- ajoute le bloc si il n'existe pas
        if model.blocks[to_block_id] == nil then
          local to_block = Model.newBlock(recipe_prototype:native())
          local index = Model.countBlocks()
          to_block.index = index
          to_block.unlinked = from_block.unlinked
          to_block.solver = from_block.solver
          -- copy input
          if from_block.input ~= nil then
            for key,value in pairs(from_block.input) do
              if to_block.input == nil then to_block.input = {} end
              to_block.input[key] = value
            end
          end

          model.blocks[to_block.id] = to_block
          to_block_id = to_block.id
          User.setParameter("current_block",to_block_id)
        end


        local recipe_model = Model.newRecipe(recipe.name, recipe_prototype:getType())
        recipe_model.index = recipe_index
        recipe_model.production = recipe.production or 1
        recipe_model.factory = Model.newFactory(recipe.factory.name)
        recipe_model.factory.limit = recipe.factory.limit
        recipe_model.factory.modules = {}
        if recipe.factory.modules ~= nil then
          for name,value in pairs(recipe.factory.modules) do
            recipe_model.factory.modules[name] = value
          end
        end
        recipe_model.beacon = Model.newBeacon(recipe.beacon.name)
        recipe_model.beacon.modules = {}
        if recipe.beacon.modules ~= nil then
          for name,value in pairs(recipe.beacon.modules) do
            recipe_model.beacon.modules[name] = value
          end
        end
        model.blocks[to_block_id].recipes[recipe_model.id] = recipe_model
        recipe_index = recipe_index + 1
      end
    end
    if model.blocks[to_block_id] ~= nil then
      Model.reIndexList(model.blocks[to_block_id].recipes)
    end
  end
end

-------------------------------------------------------------------------------
-- Add module model
--
-- @function [parent=#ModelBuilder] addModuleModel
--
-- @param #table element
-- @param #string name
--
function ModelBuilder.addModuleModel(element, name)
  local factory_prototype = EntityPrototype(element)
  if element.modules[name] == nil then element.modules[name] = 0 end
  if Model.countModulesModel(element) < factory_prototype:getModuleInventorySize() then
    element.modules[name] = element.modules[name] + 1
  end
end

-------------------------------------------------------------------------------
-- Set module model
--
-- @function [parent=#ModelBuilder] setModuleModel
--
-- @param #table element
-- @param #string name
-- @param #number value
--
function ModelBuilder.setModuleModel(element, name, value)
  Logging:debug(ModelBuilder.classname, "setModuleModel()", element, name, value)
  local element_prototype = EntityPrototype(element)
  if element.modules ~= nil and element.modules[name] == value then return false end
  element.modules = {}
  element.modules[name] = 0
  if value <= element_prototype:getModuleInventorySize() then
    element.modules[name] = value
  else
    element.modules[name] = element_prototype:getModuleInventorySize()
  end
  return true
end

-------------------------------------------------------------------------------
-- Append module model
--
-- @function [parent=#ModelBuilder] appendModuleModel
--
-- @param #table element
-- @param #string name
-- @param #number value
--
function ModelBuilder.appendModuleModel(element, name, value)
  Logging:debug(ModelBuilder.classname, "appendModuleModel()", element, name, value)
  local factory_prototype = EntityPrototype(element)
  if element.modules ~= nil and element.modules[name] == value then return false end
  local count_modules = Model.countModulesModel(element)
  if count_modules >= factory_prototype:getModuleInventorySize() then
    return false
  elseif (count_modules + value) <= factory_prototype:getModuleInventorySize() then
    element.modules[name] = value
  else
    Logging:debug(ModelBuilder.classname, "appendModuleModel()", factory_prototype:getModuleInventorySize(), count_modules, factory_prototype:getModuleInventorySize() - count_modules)
    element.modules[name] = factory_prototype:getModuleInventorySize() - count_modules
  end
  return true
end

-------------------------------------------------------------------------------
-- Remove module model
--
-- @function [parent=#ModelBuilder] removeModuleModel
--
-- @param #table element
-- @param #string name
--
function ModelBuilder.removeModuleModel(element, name)
  if element.modules[name] == nil then element.modules[name] = 0 end
  if element.modules[name] > 0 then
    element.modules[name] = element.modules[name] - 1
  end
end

-------------------------------------------------------------------------------
-- Update a beacon
--
-- @function [parent=#ModelBuilder] updateBeacon
--
-- @param #string item block_id or resource
-- @param #string key object name
-- @param #table options map attribute/valeur
--
function ModelBuilder.updateBeacon(item, key, options)
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
-- @function [parent=#ModelBuilder] addBeaconModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function ModelBuilder.addBeaconModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    ModelBuilder.addModuleModel(object.beacon, name)
  end
end

-------------------------------------------------------------------------------
-- Remove a module in beacon
--
-- @function [parent=#ModelBuilder] removeBeaconModule
--
-- @param #string item
-- @param #string key object name
-- @param #string name module name
--
function ModelBuilder.removeBeaconModule(item, key, name)
  local object = Model.getObject(item, key)
  if object ~= nil then
    ModelBuilder.removeModuleModel(object.beacon, name)
  end
end
-------------------------------------------------------------------------------
-- Unlink a production block
--
-- @function [parent=#ModelBuilder] unlinkProductionBlock
--
-- @param #string blockId
--
function ModelBuilder.unlinkProductionBlock(blockId)
  Logging:debug(ModelBuilder.classname, "unlinkProductionBlock()", blockId)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    model.blocks[blockId].unlinked = not(model.blocks[blockId].unlinked)
  end
end

-------------------------------------------------------------------------------
-- Update a product
--
-- @function [parent=#ModelBuilder] updateProduct
--
-- @param #string blockId production block id
-- @param #string key product name
-- @param #number quantity
--
function ModelBuilder.updateProduct(blockId, key, quantity)
  Logging:debug(ModelBuilder.classname, "updateProduct()", blockId, key, quantity)
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
-- @function [parent=#ModelBuilder] updateProductionBlockOption
--
-- @param #string blockId production block id
-- @param #string option
-- @param #number value
--
function ModelBuilder.updateProductionBlockOption(blockId, option, value)
  Logging:debug(ModelBuilder.classname, "updateProductionBlockOption()", blockId, option, value)
  local model = Model.getModel()

  if model.blocks[blockId] ~= nil then
    local block = model.blocks[blockId]
    block[option] = value
  end
end

-------------------------------------------------------------------------------
-- Down a production block
--
-- @function [parent=#ModelBuilder] downProductionBlock
--
-- @param #string blockId
-- @param #number step
--
function ModelBuilder.downProductionBlock(blockId, step)
  Logging:debug(ModelBuilder.classname, "downProductionBlock()", blockId, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    ModelBuilder.downProductionList(model.blocks, model.blocks[blockId].index, step)
  end
end

-------------------------------------------------------------------------------
-- Down a production recipe
--
-- @function [parent=#ModelBuilder] downProductionRecipe
--
-- @param #string blockId
-- @param #string key
-- @param #number step
--
function ModelBuilder.downProductionRecipe(blockId, key, step)
  Logging:debug(ModelBuilder.classname, "downProductionRecipe()", blockId, key, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
    ModelBuilder.downProductionList(model.blocks[blockId].recipes, model.blocks[blockId].recipes[key].index, step)
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
-- @function [parent=#ModelBuilder] downProductionList
--
-- @param #table list
-- @param #number index
-- @param #number step
--
function ModelBuilder.downProductionList(list, index, step)
  Logging:debug(ModelBuilder.classname, "downProductionList()", list, index, step)
  local model = Model.getModel()
  local list_count = Model.countList(list)
  Logging:debug(ModelBuilder.classname, "downProductionList()", list_count)
  if list ~= nil and index + 1 < Model.countList(list) then
    -- defaut step
    if step == nil then step = 1 end
    -- cap le step
    if step > (list_count - index) then step = list_count - index - 1 end
    for _,element in pairs(list) do
      if element.index == index then
        -- change l'index de l'element cible
        element.index = element.index + step
        Logging:debug(ModelBuilder.classname, "index element", element.index, element.index + step)
      elseif element.index > index and element.index <= index + step then
        -- change les index compris entre index et la fin
        element.index = element.index - 1
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Up a production block
--
-- @function [parent=#ModelBuilder] upProductionBlock
--
-- @param #string blockId
-- @param #number step
--
function ModelBuilder.upProductionBlock(blockId, step)
  Logging:debug(ModelBuilder.classname, "upProductionBlock()", blockId, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil then
    ModelBuilder.upProductionList(model.blocks, model.blocks[blockId].index, step)
  end
end

-------------------------------------------------------------------------------
-- Up a production recipe
--
-- @function [parent=#ModelBuilder] upProductionRecipe
--
-- @param #string blockId
-- @param #string key
-- @param #number step
--
function ModelBuilder.upProductionRecipe(blockId, key, step)
  Logging:debug(ModelBuilder.classname, "upProductionRecipe()", blockId, key, step)
  local model = Model.getModel()
  if model.blocks[blockId] ~= nil and model.blocks[blockId].recipes[key] ~= nil then
    ModelBuilder.upProductionList(model.blocks[blockId].recipes, model.blocks[blockId].recipes[key].index, step)
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
-- @function [parent=#ModelBuilder] upProductionList
--
-- @param #table list
-- @param #number index
-- @param #number step
--
function ModelBuilder.upProductionList(list, index, step)
  Logging:debug(ModelBuilder.classname, "upProductionList()", list, index, step)
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
-- Add rule
--
-- @function [parent=#ModelBuilder] addRule
--
-- @param #string mod
-- @param #string name
-- @param #string category
-- @param #string type
-- @param #string value
-- @param #string excluded
-- @param #string index
--
function ModelBuilder.addRule(mod, name, category, type, value, excluded, index)
  Logging:debug(ModelBuilder.classname, "addRule()", mod, name, category, type, value, excluded, index)
  local rule = Model.newRule(mod, name, category, type, value, excluded, #Model.getRules())
  local rules = Model.getRules()
  table.insert(rules, rule)
end

return ModelBuilder
