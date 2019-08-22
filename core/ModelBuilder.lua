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
function ModelBuilder.addRecipeIntoProductionBlock(key, type)
  Logging:debug(ModelBuilder.classname, "addRecipeIntoProductionBlock():", key, type)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  local blockId = globalGui.currentBlock
  local lua_recipe = RecipePrototype.load(key, type).native()

  if lua_recipe ~= nil then
    -- ajoute le bloc si il n'existe pas
    if model.blocks[blockId] == nil then
      local modelBlock = Model.newBlock(lua_recipe)
      local index = Model.countBlocks()
      modelBlock.index = index
      modelBlock.unlinked = false
      model.blocks[modelBlock.id] = modelBlock
      blockId = modelBlock.id
      globalGui.currentBlock = blockId
      -- check si le block est independant
      ModelCompute.checkUnlinkedBlock(modelBlock)
    end

    -- ajoute le recipe si il n'existe pas
    local ModelRecipe = Model.newRecipe(lua_recipe.name, type)
    local index = Model.countBlockRecipes(blockId)
    ModelRecipe.index = index
    ModelRecipe.count = 1
    -- ajoute les produits du block
    for _, lua_product in pairs(RecipePrototype.getProducts()) do
      local product = Product.load(lua_product).new()
      if model.blocks[blockId].products[lua_product.name] == nil then
        if model.blocks[blockId].ingredients[lua_product.name] ~= nil then
          product.state = 2
        else
          product.state = 1
        end
        model.blocks[blockId].products[lua_product.name] = product
      end
    end

    -- ajoute les ingredients du block
    for _, lua_ingredient in pairs(RecipePrototype.getIngredients()) do
      local ingredient = Product.load(lua_ingredient).new()
      if model.blocks[blockId].ingredients[lua_ingredient.name] == nil then
        model.blocks[blockId].ingredients[lua_ingredient.name] = ingredient
        if model.blocks[blockId].products[lua_ingredient.name] ~= nil and model.blocks[blockId].products[lua_ingredient.name].state == 1 then
          model.blocks[blockId].products[lua_ingredient.name].state = 2
        end
      end
    end
    model.blocks[blockId].recipes[ModelRecipe.id] = ModelRecipe

    local defaultFactory = Model.getDefaultPrototypeFactory(RecipePrototype.getCategory(), lua_recipe)
    if defaultFactory ~= nil then
      Model.setFactory(blockId, ModelRecipe.id, defaultFactory)
    end
    local defaultBeacon = Model.getDefaultRecipeBeacon(lua_recipe.name)
    if defaultBeacon ~= nil then
      Model.setBeacon(blockId, ModelRecipe.id, defaultBeacon)
    end
    Logging:debug(ModelBuilder.classname, "addRecipeIntoProductionBlock()", model.blocks[blockId])
    return model.blocks[blockId]
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
  Logging:debug(ModelBuilder.classname, "addPrimaryPower():", power_id, key)
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
  Logging:debug(ModelBuilder.classname, "addSecondaryPower():", key)
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
    Player.getGlobalGui()["model_id"] = model.id
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
  Logging:debug(ModelBuilder.classname, "updatePower():", options)
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
  Logging:debug(ModelBuilder.classname, "updateFactory():", item, key, options)
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
  Logging:debug(ModelBuilder.classname, "updateFactory():", item, key, options)
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
  local globalGui = Player.getGlobalGui()
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
  local globalGui = Player.getGlobalGui()

  if from_model ~= nil then
    local from_block_ids = {}
    for block_id,block in spairs(from_model.blocks,function(t,a,b) return t[b].index > t[a].index end) do
      table.insert(from_block_ids, block_id)
    end
    for _,block_id in ipairs(from_block_ids) do
      globalGui.currentBlock = "new"
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
  local globalGui = Player.getGlobalGui()
  local model = Model.getModel()
  local to_block_id = globalGui.currentBlock

  if from_model ~= nil and from_block ~= nil then
    local from_recipe_ids = {}
    for recipe_id, recipe in spairs(from_block.recipes,function(t,a,b) return t[b].index > t[a].index end) do
      table.insert(from_recipe_ids, recipe_id)
    end
    local recipe_index = #from_recipe_ids
    for _, recipe_id in ipairs(from_recipe_ids) do
      local recipe = from_block.recipes[recipe_id]
      RecipePrototype.find(recipe)
      if RecipePrototype.native() ~= nil then
        -- ajoute le bloc si il n'existe pas
        if model.blocks[to_block_id] == nil then
          local to_block = Model.newBlock(RecipePrototype.native())
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
          globalGui.currentBlock = to_block_id
        end


        local recipe_model = Model.newRecipe(recipe.name, RecipePrototype.type())
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
  local factory_prototype = EntityPrototype.load(element)
  if element.modules[name] == nil then element.modules[name] = 0 end
  if Model.countModulesModel(element) < factory_prototype.getModuleInventorySize() then
    element.modules[name] = element.modules[name] + 1
  end
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
  Logging:debug(ModelBuilder.classname, "updateProduct():", blockId, key, quantity)
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
  Logging:debug(ModelBuilder.classname, "updateProductionBlockOption():", blockId, option, value)
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
