------------------------------------------------------------------------------
---Description of the module.
---@class ModelBuilder
local ModelBuilder = {
    ---single-line comment
    classname = "HMModelBuilder"
}

-------------------------------------------------------------------------------
---Add a recipe into production block
---@param model table
---@param block table
---@param recipe_name string
---@param recipe_type string
---@param index number
---@return table, table
function ModelBuilder.addRecipeIntoProductionBlock(model, block, recipe_name, recipe_type, index)
    local recipe_prototype = RecipePrototype(recipe_name, recipe_type)
    local lua_recipe = recipe_prototype:native()

    if lua_recipe ~= nil then
        local block_types = true
        ---ajoute le bloc si il n'existe pas
        if block == nil then
            local modelBlock = Model.newBlock(model, lua_recipe)
            local block_index = table.size(model.blocks)
            modelBlock.index = block_index
            modelBlock.unlinked = false
            block = modelBlock
            model.blocks[modelBlock.id] = modelBlock
            ---check si le block est independant
            ModelCompute.checkUnlinkedBlock(model, modelBlock)
            block_types = false
        end

        ---ajoute le recipe si il n'existe pas
        local ModelRecipe = Model.newRecipe(model, lua_recipe.name, recipe_type)
        local icon_name, icon_type = recipe_prototype:getIcon()
        if not (block_types) then
            block.type = icon_type
        end
        if index == nil then
            local recipe_index = table.size(block.recipes)
            ModelRecipe.index = recipe_index
        else
            ModelRecipe.index = index
            for _, recipe in pairs(block.recipes) do
                if recipe.index >= index then
                    recipe.index = recipe.index + 1
                end
            end
        end
        if ModelRecipe.index == 0 then
            ---change block name
            block.name = icon_name
            block.type = icon_type
        end
        ModelRecipe.count = 1

        if recipe_type ~= "energy" then
            local default_factory = User.getDefaultFactory(ModelRecipe)
            if default_factory ~= nil then
                Model.setFactory(ModelRecipe, default_factory.name, default_factory.fuel)
                ModelBuilder.setFactoryModulePriority(ModelRecipe, default_factory.module_priority)
            else
                local default_factory_name = Model.getDefaultPrototypeFactory(recipe_prototype)
                if default_factory_name ~= nil then
                    Model.setFactory(ModelRecipe, default_factory_name)
                end
            end

            local default_beacons = User.getDefaultBeacons(ModelRecipe)
            if default_beacons ~= nil then
                for _, default_beacon in pairs(default_beacons) do
                    local beacon = Model.addBeacon(ModelRecipe, default_beacon.name, default_beacon.combo, default_beacon.per_factory, default_beacon.per_factory_constant)
                    ModelBuilder.setBeaconModulePriority(beacon, ModelRecipe, default_beacon.module_priority)
                end
            end
        else
            Model.setFactory(ModelRecipe, recipe_name)
        end

        local recipe_products
        local recipe_ingredients
        local block_products
        local block_ingredients

        if block.by_product == false then
            recipe_products = recipe_prototype:getIngredients(ModelRecipe.factory)
            recipe_ingredients = recipe_prototype:getProducts()
            block_products = block.ingredients
            block_ingredients = block.products
        else
            recipe_products = recipe_prototype:getProducts()
            recipe_ingredients = recipe_prototype:getIngredients(ModelRecipe.factory)
            block_products = block.products
            block_ingredients = block.ingredients
        end

        ---ajoute les produits du block
        for _, lua_product in pairs(recipe_products) do
            local product = Product(lua_product):clone()
            local element_key = Product(lua_product):getTableKey()
            if block_products[element_key] == nil then
                if block_ingredients[element_key] ~= nil then
                    product.state = 2
                else
                    product.state = 1
                end
                block_products[element_key] = product
            end
        end

        ---ajoute les ingredients du block
        for _, lua_ingredient in pairs(recipe_ingredients) do
            local ingredient = Product(lua_ingredient):clone()
            local element_key = Product(lua_ingredient):getTableKey()
            if block_ingredients[element_key] == nil then
                block_ingredients[element_key] = ingredient
                if block_products[element_key] ~= nil and block_products[element_key].state == 1 then
                    block_products[element_key].state = 2
                end
            end
        end
        block.recipes[ModelRecipe.id] = ModelRecipe

        return block, ModelRecipe
    end
end

-------------------------------------------------------------------------------
---Move down block in the tree
---@param model ModelData
---@param parent BlockData
---@param block BlockData
---@param with_below boolean
function ModelBuilder.updateTreeBlockDown(model, parent, block, with_below)
end

-------------------------------------------------------------------------------
---Move down block in the tree
---@param model ModelData
---@param parent BlockData
---@param block BlockData
---@param with_below boolean
function ModelBuilder.updateTreeBlockUp(model, parent, block, with_below)
end

-------------------------------------------------------------------------------
---Move down recipe in the tree
---@param model ModelData
---@param block BlockData
---@param recipe RecipeData
---@param with_below boolean
function ModelBuilder.updateTreeRecipeDown(model, block, recipe, with_below)
end

-------------------------------------------------------------------------------
---Move up recipe in the tree
---@param model ModelData
---@param block BlockData
---@param recipe RecipeData
---@param with_below boolean
function ModelBuilder.updateTreeRecipeUp(model, block, recipe, with_below)
    local new_block = Model.newBlock(model, recipe)
    local block_index = table.size(model.blocks)
    new_block.index = block_index
    new_block.type = block.type
    new_block.unlinked = block.by_factory and true or false
    new_block.by_factory = block.by_factory
    new_block.by_product = block.by_product
    new_block.by_limit = block.by_limit
    model.blocks[new_block.id] = new_block

    local sorter = defines.sorters.block.sort
    if block.by_product == false then sorter = defines.sorters.block.reverse end
    local start_index = recipe.index
    local started = false
    for _, child in spairs(block.recipes, sorter) do
        if started == true then
            if with_below ~= true then
                break
            end
            -- update index
            child.index = table.size(new_block.recipes)
            -- clean block
            block.recipes[child.id] = nil
            -- add child
            new_block.recipes[child.id] = child
        end
        if child == recipe and started == false then
            -- clean block
            block.recipes[child.id] = nil
            -- update index
            new_block.index = child.index
            child.index = table.size(new_block.recipes)
            -- add block
            block.recipes[new_block.id] = new_block
            new_block.recipes[child.id] = child
            started = true
        end
    end

    ModelCompute.prepareBlockElements(new_block)
    ---check si le block est independant
    ModelCompute.checkUnlinkedBlock(model, new_block)
end

-------------------------------------------------------------------------------
---Remove a model
---@param model_id string
function ModelBuilder.removeModel(model_id)
    global.models[model_id] = nil
end

-------------------------------------------------------------------------------
---Update recipe production
---@param recipe table
---@param production number
function ModelBuilder.updateRecipeProduction(recipe, production)
    if recipe ~= nil then
        recipe.production = production
    end
end

-------------------------------------------------------------------------------
---Update a factory number
---@param recipe table
---@param value any
function ModelBuilder.updateFactoryNumber(recipe, value)
    if recipe ~= nil then
        if value == 0 then
            recipe.factory.input = nil
        else
            recipe.factory.input = value
        end
    end
end

-------------------------------------------------------------------------------
---Update a factory limit
---@param recipe table
---@param value any
function ModelBuilder.updateFactoryLimit(recipe, value)
    if recipe ~= nil then
        if value == 0 then
            recipe.factory.limit = nil
        else
            recipe.factory.limit = value
        end
    end
end

-------------------------------------------------------------------------------
---Update block matrix solver
---@param block table
---@param value any
function ModelBuilder.updateBlockMatrixSolver(block, value)
    if block ~= nil then
        block.solver = value
    end
end

-------------------------------------------------------------------------------
---Update recipe matrix solver
---@param block table
---@param recipe table
function ModelBuilder.updateMatrixSolver(block, recipe)
    if block ~= nil then
        local recipes = block.recipes
        local sorter = function(t, a, b) return t[b].index > t[a].index end
        if block.by_product == false then
            sorter = function(t, a, b) return t[b].index < t[a].index end
        end
        local apply = false
        local matrix_solver = 0
        for _, current_recipe in spairs(recipes, sorter) do
            if apply == true and current_recipe.matrix_solver == matrix_solver then
                apply = false
            end
            if apply == true and current_recipe.matrix_solver ~= matrix_solver then
                current_recipe.matrix_solver = matrix_solver
            end
            if current_recipe.id == recipe.id then
                if current_recipe.matrix_solver == 0 then
                    matrix_solver = 1
                else
                    matrix_solver = 0
                end
                current_recipe.matrix_solver = matrix_solver
                apply = true
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update a factory
---@param recipe RecipeData
---@param fuel string | FuelData
function ModelBuilder.updateFuelFactory(recipe, fuel)
    if recipe ~= nil and fuel ~= nil then
        recipe.factory.fuel = fuel
    end
end

-------------------------------------------------------------------------------
---Convert factory modules to a prority module
---@param factory table
---@return table
function ModelBuilder.convertModuleToPriority(factory)
    local module_priority = {}
    for name, value in pairs(factory.modules or {}) do
        table.insert(module_priority, { name = name, value = value })
    end
    return module_priority
end

-------------------------------------------------------------------------------
---Add a module to prority module
---@param factory table
---@param module_name string
---@param module_max number
---@return table
function ModelBuilder.addModulePriority(factory, module_name, module_max)
    local module_priority = ModelBuilder.convertModuleToPriority(factory)
    local factory_prototype = EntityPrototype(factory)
    if Model.countModulesModel(factory) < factory_prototype:getModuleInventorySize() then
        local count = 1
        if module_max then
            count = factory_prototype:getModuleInventorySize() - Model.countModulesModel(factory)
        end
        local success = false
        ---parcours la priorite
        for i, priority in pairs(module_priority) do
            if priority.name == module_name then
                priority.value = priority.value + count
                success = true
            end
        end
        if success == false then
            table.insert(module_priority, { name = module_name, value = count })
        end
    end
    return module_priority
end

-------------------------------------------------------------------------------
---Remove module priority
---@param factory table
---@param module_name string
---@param module_max number
---@return table
function ModelBuilder.removeModulePriority(factory, module_name, module_max)
    local module_priority = ModelBuilder.convertModuleToPriority(factory)
    ---parcours la priorite
    local index = nil
    for i, priority in pairs(module_priority) do
        if priority.name == module_name then
            if priority.value > 1 and not (module_max) then
                priority.value = priority.value - 1
            else
                index = i
            end
        end
    end
    if index ~= nil then
        table.remove(module_priority, index)
    end
    return module_priority
end

-------------------------------------------------------------------------------
---Add a module in factory
---@param recipe RecipeData
---@param module_name string
---@param module_max number
function ModelBuilder.addFactoryModule(recipe, module_name, module_max)
    local module = ItemPrototype(module_name)
    if recipe ~= nil and module:native() ~= nil then
        if Player.checkFactoryLimitationModule(module:native(), recipe) == true then
            local module_priority = ModelBuilder.addModulePriority(recipe.factory, module_name, module_max or false)
            ModelBuilder.setFactoryModulePriority(recipe, module_priority)
        end
    end
end

-------------------------------------------------------------------------------
---Set a module in factory
---@param recipe RecipeData
---@param module_name string
---@param module_value number
---@return boolean
function ModelBuilder.setFactoryModule(recipe, module_name, module_value)
    if recipe ~= nil then
        return ModelBuilder.setModuleModel(recipe.factory, module_name, module_value)
    end
    return false
end

-------------------------------------------------------------------------------
---Set a module priority
---@param element table
---@param module_priority table
function ModelBuilder.setModulePriority(element, module_priority)
    if element ~= nil then
        for i, priority in pairs(module_priority) do
            if i == 1 then
                ModelBuilder.setModuleModel(element, priority.name, priority.value)
            else
                ModelBuilder.appendModuleModel(element, priority.name, priority.value)
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set a module priority in factory
---@param recipe RecipeData
---@param module_priority table
function ModelBuilder.setFactoryModulePriority(recipe, module_priority)
    if recipe ~= nil then
        recipe.factory.modules = {}
        if module_priority == nil then
            recipe.factory.module_priority = nil
        else
            recipe.factory.module_priority = table.clone(module_priority)
            local first = true
            for i, priority in pairs(module_priority) do
                local module = ItemPrototype(priority.name)
                if Player.checkFactoryLimitationModule(module:native(), recipe) == true then
                    if first then
                        ModelBuilder.setModuleModel(recipe.factory, priority.name, priority.value)
                        first = false
                    else
                        ModelBuilder.appendModuleModel(recipe.factory, priority.name, priority.value)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Apply a module priority in factory
---@param recipe RecipeData
function ModelBuilder.applyFactoryModulePriority(recipe)
    if recipe ~= nil then
        local module_priority = recipe.factory.module_priority
        if module_priority == nil then
            recipe.factory.modules = {}
        else
            local first = true
            for i, priority in pairs(module_priority) do
                local module = ItemPrototype(priority.name)
                if Player.checkFactoryLimitationModule(module:native(), recipe) == true then
                    if first then
                        ModelBuilder.setModuleModel(recipe.factory, priority.name, priority.value)
                        first = false
                    else
                        ModelBuilder.appendModuleModel(recipe.factory, priority.name, priority.value)
                    end
                end
            end
        end
    end
end

---Set a module priority in beacons
---@param recipe RecipeData
---@param modules_priority {[uint] : {[uint] : ModulePriorityData}}
function ModelBuilder.setBeaconsModulesPriority(recipe, modules_priority)
    if recipe ~= nil then
        local beacons = recipe.beacons
        for index, beacon in ipairs(beacons) do
            local module_priority = modules_priority[index]
            ModelBuilder.setBeaconModulePriority(beacon, recipe, module_priority)
        end
    end
end

-------------------------------------------------------------------------------
---Set a module priority in beacon
---@param beacon FactoryData
---@param recipe RecipeData
---@param module_priority {[uint] : ModulePriorityData}
function ModelBuilder.setBeaconModulePriority(beacon, recipe, module_priority)
    if beacon ~= nil then
        beacon.modules = {}
        if module_priority == nil then
            beacon.module_priority = nil
        else
            beacon.module_priority = table.clone(module_priority)
            local first = true
            for _, priority in pairs(module_priority) do
                local module = ItemPrototype(priority.name)
                if Player.checkBeaconLimitationModule(beacon, recipe, module:native()) == true then
                    if first then
                        ModelBuilder.setModuleModel(beacon, priority.name, priority.value)
                        first = false
                    else
                        ModelBuilder.appendModuleModel(beacon, priority.name, priority.value)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set factory block
---@param block table
---@param current_recipe RecipeData
function ModelBuilder.setFactoryBlock(block, current_recipe)
    if current_recipe ~= nil then
        local factory_prototype = EntityPrototype(current_recipe.factory.name)
        local factory_ingredient_count = factory_prototype:getIngredientCount()
        for _, recipe in pairs(block.recipes) do
            local prototype_recipe = RecipePrototype(recipe)
            local recipe_ingredient_count = prototype_recipe:getIngredientCount()
            --- check ingredient limitation
            if factory_ingredient_count < recipe_ingredient_count then
                -- Skip
            elseif prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
                Model.setFactory(recipe, current_recipe.factory.name, current_recipe.factory.fuel)
                ModelBuilder.setFactoryModulePriority(recipe, current_recipe.factory.module_priority)
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set factory line
---@param model table
---@param current_recipe RecipeData
function ModelBuilder.setFactoryLine(model, current_recipe)
    if current_recipe ~= nil then
        for _, block in pairs(model.blocks) do
            ModelBuilder.setFactoryBlock(block, current_recipe)
        end
    end
end

-------------------------------------------------------------------------------
---Set factory module block
---@param block table
---@param current_recipe RecipeData
function ModelBuilder.setFactoryModuleBlock(block, current_recipe)
    if current_recipe ~= nil then
        for key, recipe in pairs(block.recipes) do
            local prototype_recipe = RecipePrototype(recipe)
            if prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
                ModelBuilder.setFactoryModulePriority(recipe, current_recipe.factory.module_priority)
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set factory module line
---@param model table
---@param current_recipe RecipeData
function ModelBuilder.setFactoryModuleLine(model, current_recipe)
    if current_recipe ~= nil then
        for _, block in pairs(model.blocks) do
            ModelBuilder.setFactoryModuleBlock(block, current_recipe)
        end
    end
end

-------------------------------------------------------------------------------
---Set beacon block
---@param block table
---@param current_recipe RecipeData
function ModelBuilder.setBeaconBlock(block, current_recipe)
    if current_recipe ~= nil then
        for key, recipe in pairs(block.recipes) do
            if recipe ~= current_recipe then
                local prototype_recipe = RecipePrototype(recipe)
                if prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
                    recipe.beacons = {}
                    if current_recipe.beacons ~= nil then
                        for key, current_beacon in pairs(current_recipe.beacons) do
                            local beacon = Model.addBeacon(recipe, current_beacon.name, current_beacon.combo,current_beacon.per_factory, current_beacon.per_factory_constant)
                            ModelBuilder.setBeaconModulePriority(beacon, current_recipe, current_beacon.module_priority)
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set beacon line
---@param model table
---@param current_recipe RecipeData
function ModelBuilder.setBeaconLine(model, current_recipe)
    if current_recipe ~= nil then
        for _, block in pairs(model.blocks) do
            ModelBuilder.setBeaconBlock(block, current_recipe)
        end
    end
end

-------------------------------------------------------------------------------
---Set beacon module block
---@param block table
---@param current_recipe RecipeData
function ModelBuilder.setBeaconModuleBlock(block, current_recipe)
    if current_recipe ~= nil then
        for key, recipe in pairs(block.recipes) do
            if recipe ~= current_recipe and recipe.beacons ~= nil then
                local prototype_recipe = RecipePrototype(recipe)
                if prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory()
                    and #recipe.beacons == #current_recipe.beacons then
                    for index, current_beacon in pairs(current_recipe.beacons) do
                        local beacon = recipe.beacons[index]
                        ModelBuilder.setBeaconModulePriority(beacon, current_recipe, current_beacon.module_priority)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set beacon module line
---@param model table
---@param current_recipe RecipeData
function ModelBuilder.setBeaconModuleLine(model, current_recipe)
    if current_recipe ~= nil then
        for _, block in pairs(model.blocks) do
            ModelBuilder.setBeaconModuleBlock(block, current_recipe)
        end
    end
end

-------------------------------------------------------------------------------
---Remove a module from factory
---@param recipe RecipeData
---@param module_name string
---@param module_max number
function ModelBuilder.removeFactoryModule(recipe, module_name, module_max)
    local module = ItemPrototype(module_name)
    if recipe ~= nil and module:native() ~= nil then
        local module_priority = ModelBuilder.removeModulePriority(recipe.factory, module_name, module_max or false)
        ModelBuilder.setFactoryModulePriority(recipe, module_priority)
    end
end

-------------------------------------------------------------------------------
---Remove a production block
---@param model table
---@param block table
function ModelBuilder.removeProductionBlock(model, block)
    if block ~= nil then
        model.blocks[block.id] = nil
        table.reindex_list(model.blocks)
        for _, block in pairs(model.blocks) do
            if block.index == 0 then
                block.unlinked = true
                break
            end
        end
    end
end

-------------------------------------------------------------------------------
---Remove a production recipe
---@param block table
---@param recipe RecipeData
function ModelBuilder.removeProductionRecipe(block, recipe)
    if block ~= nil and block.recipes[recipe.id] ~= nil then
        block.recipes[recipe.id] = nil
        table.reindex_list(block.recipes)
        ---change block name
        local first_recipe = Model.firstRecipe(block.recipes)
        if first_recipe ~= nil then
            local recipe_prototype = RecipePrototype(first_recipe)
            local icon_name, icon_type = recipe_prototype:getIcon()
            block.name = icon_name
            block.type = icon_type
        else
            block.name = ""
        end
    end
end

-------------------------------------------------------------------------------
---Past model
---@param into_model table
---@param into_block table
---@param from_model table
---@param from_block table
function ModelBuilder.pastModel(into_model, into_block, from_model, from_block)
    if from_model ~= nil then
        if from_block ~= nil then
            ModelBuilder.copyBlock(into_model, into_block, from_model, from_block)
        else
            ModelBuilder.copyModel(into_model, from_model)
        end
    end
end

-------------------------------------------------------------------------------
---Copy model
---@param into_model table
---@param from_model table
function ModelBuilder.copyModel(into_model, from_model)
    if from_model ~= nil then
        if from_model.parameters ~= nil then
            into_model.parameters = table.deepcopy(from_model.parameters)
        end
        for _, from_block in spairs(from_model.blocks, function(t, a, b) return t[b].index > t[a].index end) do
            ModelBuilder.copyBlock(into_model, nil, from_model, from_block)
        end
    end
end

-------------------------------------------------------------------------------
---Copy block
---@param into_model table
---@param into_block table
---@param from_model table
---@param from_block table
function ModelBuilder.copyBlock(into_model, into_block, from_model, from_block)
    if from_model ~= nil and from_block ~= nil then
        local from_recipe_ids = {}
        for recipe_id, recipe in spairs(from_block.recipes, function(t, a, b) return t[b].index > t[a].index end) do
            table.insert(from_recipe_ids, recipe_id)
        end
        local recipe_index = #from_recipe_ids
        for _, recipe_id in ipairs(from_recipe_ids) do
            local recipe = from_block.recipes[recipe_id]
            local recipe_prototype = RecipePrototype(recipe)
            if recipe_prototype:native() ~= nil then
                ---ajoute le bloc si il n'existe pas
                if into_block == nil then
                    into_block = Model.newBlock(into_model, recipe_prototype:native())
                    local index = table.size(into_model.blocks)
                    into_block.index = index
                    if index == 0 then
                        into_block.unlinked = true
                    else
                        into_block.unlinked = from_block.unlinked
                    end
                    into_block.solver = from_block.solver
                    into_block.by_product = from_block.by_product
                    into_block.type = from_block.type

                    ---copy input
                    if from_block.products ~= nil then
                        into_block.products = table.deepcopy(from_block.products)
                    end
                    if from_block.ingredients ~= nil then
                        into_block.ingredients = table.deepcopy(from_block.ingredients)
                    end

                    into_model.blocks[into_block.id] = into_block
                end

                local recipe_model = Model.newRecipe(into_model, recipe.name, recipe_prototype:getType())
                recipe_model.index = recipe_index
                recipe_model.production = recipe.production or 1
                recipe_model.factory = ModelBuilder.cloneFactory(recipe.factory)
                if recipe.beacons ~= nil then
                    recipe_model.beacons = {}
                    for _, beacon in pairs(recipe.beacons) do
                        table.insert(recipe_model.beacons, ModelBuilder.cloneBeacon(beacon))
                    end
                end

                if recipe.contraint ~= nil then
                    recipe_model.contraint = table.deepcopy(recipe.contraint)
                end
                into_block.recipes[recipe_model.id] = recipe_model
                recipe_index = recipe_index + 1
            end
        end
        if into_block ~= nil then
            table.reindex_list(into_block.recipes)
            if from_block.products_linked ~= nil then
                into_block.products_linked = table.deepcopy(from_block.products_linked)
            end
        end
    end
end

---Clone factory
---@param factory FactoryData
---@return FactoryData
function ModelBuilder.cloneFactory(factory)
    local new_factory = Model.newFactory(factory.name)
    new_factory.limit = factory.limit
    new_factory.fuel = factory.fuel
    new_factory.input = factory.input
    new_factory.modules = {}
    if factory.modules ~= nil then
        for name, value in pairs(factory.modules) do
            new_factory.modules[name] = value
        end
    end
    if factory.module_priority ~= nil then
        new_factory.module_priority = table.clone(factory.module_priority)
    end
    return new_factory
end

---Clone beacon
---@param beacon FactoryData
---@return FactoryData
function ModelBuilder.cloneBeacon(beacon)
    local new_beacon = Model.newBeacon(beacon.name)
    new_beacon.combo = beacon.combo
    new_beacon.per_factory = beacon.per_factory
    new_beacon.per_factory_constant = beacon.per_factory_constant
    new_beacon.modules = {}
    if beacon.modules ~= nil then
        for name, value in pairs(beacon.modules) do
            new_beacon.modules[name] = value
        end
    end
    if beacon.module_priority ~= nil then
        new_beacon.module_priority = table.clone(beacon.module_priority)
    end
    return new_beacon
end

-------------------------------------------------------------------------------
---Set module model
---@param factory FactoryData
---@param module_name string
---@param module_value number
---@return boolean
function ModelBuilder.setModuleModel(factory, module_name, module_value)
    local element_prototype = EntityPrototype(factory)
    if factory.modules ~= nil and factory.modules[module_name] == module_value then return false end
    factory.modules = {}
    factory.modules[module_name] = 0
    if module_value <= element_prototype:getModuleInventorySize() then
        factory.modules[module_name] = module_value
    else
        factory.modules[module_name] = element_prototype:getModuleInventorySize()
    end
    return true
end

-------------------------------------------------------------------------------
---Append module model
---@param factory FactoryData
---@param module_name string
---@param module_value number
---@return boolean
function ModelBuilder.appendModuleModel(factory, module_name, module_value)
    local factory_prototype = EntityPrototype(factory)
    if factory.modules ~= nil and factory.modules[module_name] == module_value then return false end
    local count_modules = Model.countModulesModel(factory)
    if count_modules >= factory_prototype:getModuleInventorySize() then
        return false
    elseif (count_modules + module_value) <= factory_prototype:getModuleInventorySize() then
        factory.modules[module_name] = module_value
    else
        factory.modules[module_name] = 0
        local delta = factory_prototype:getModuleInventorySize() - Model.countModulesModel(factory)
        factory.modules[module_name] = delta
    end
    return true
end

-------------------------------------------------------------------------------
---Return current beacon if not exist initialise
---@param recipe RecipeData
---@return BeaconData
function ModelBuilder.getCurrentBeacon(recipe)
    if recipe.beacons == nil or #recipe.beacons == 0 then
        recipe.beacons = {}
        if recipe.beacon ~= nil then
            table.insert(recipe.beacons, recipe.beacon)
        else
            local new_beacon = Model.newBeacon()
            table.insert(recipe.beacons, new_beacon)
        end
    end
    local beacons = recipe.beacons
    local current_beacon_selection = User.getParameter("current_beacon_selection") or 1
    local beacon = nil
    if #beacons >= current_beacon_selection then
        beacon = beacons[current_beacon_selection]
    else
        User.setParameter("current_beacon_selection", 1)
        beacon = beacons[1]
    end
    return beacon
end

-------------------------------------------------------------------------------
---Update a beacon
---@param beacon BeaconData
---@param recipe RecipeData
---@param options table
function ModelBuilder.updateBeacon(beacon, recipe, options)
    if recipe ~= nil then
        if options.combo ~= nil then
            beacon.combo = options.combo
        end
        if options.per_factory ~= nil then
            beacon.per_factory = options.per_factory
        end
        if options.per_factory_constant ~= nil then
            beacon.per_factory_constant = options.per_factory_constant
        end
    end
end

-------------------------------------------------------------------------------
---Add a module in beacon
---@param beacon BeaconData
---@param recipe RecipeData
---@param module_name string
---@param module_max number
function ModelBuilder.addBeaconModule(beacon, recipe, module_name, module_max)
    local module = ItemPrototype(module_name)
    if recipe ~= nil and module:native() ~= nil then
        if Player.checkFactoryLimitationModule(module:native(), recipe) == true then
            local module_priority = ModelBuilder.addModulePriority(beacon, module_name, module_max or false)
            ModelBuilder.setBeaconModulePriority(beacon, recipe, module_priority)
        end
    end
end

-------------------------------------------------------------------------------
---Remove a module in beacon
---@param beacon BeaconData
---@param recipe RecipeData
---@param module_name string
---@param module_max number
function ModelBuilder.removeBeaconModule(beacon, recipe, module_name, module_max)
    local module = ItemPrototype(module_name)
    if recipe ~= nil and module:native() ~= nil then
        local module_priority = ModelBuilder.removeModulePriority(beacon, module_name, module_max or false)
        ModelBuilder.setBeaconModulePriority(beacon, recipe, module_priority)
    end
end

-------------------------------------------------------------------------------
---Unlink a production block
---@param block table
function ModelBuilder.unlinkProductionBlock(block)
    if block ~= nil then
        block.unlinked = not (block.unlinked)
        if not block.unlinked then
            for i, ingredient in pairs(block.ingredients) do
                ingredient.input = 0
                ingredient.count = 0
            end
            for i, product in pairs(block.products) do
                product.input = 0
                product.count = 0
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update a product
---@param block table
---@param product_name string
---@param quantity number
function ModelBuilder.updateProduct(block, product_name, quantity)
    if block ~= nil then
        local block_elements = block.products
        if block.by_product == false then
            block_elements = block.ingredients
        end
        if block_elements ~= nil and block_elements[product_name] ~= nil then
            block_elements[product_name].input = quantity
        end
    end
end

-------------------------------------------------------------------------------
---Update a production block option
---@param block table
---@param option string
---@param value any
function ModelBuilder.updateProductionBlockOption(block, option, value)
    if block ~= nil then
        block[option] = value
        ---reset states
        for _, product in pairs(block.products) do
            product.state = 1
        end
        for _, ingredient in pairs(block.ingredients) do
            ingredient.state = 1
        end
    end
end

-------------------------------------------------------------------------------
---Up a production block
---@param model table
---@param block table
---@param step number
function ModelBuilder.upProductionBlock(model, block, step)
    if model ~= nil and block ~= nil then
        table.up_indexed_list(model.blocks, block.index, step)
        if block.index == 0 then
            block.unlinked = true
        end
    end
end

-------------------------------------------------------------------------------
---Down a production block
---@param model table
---@param block table
---@param step number
function ModelBuilder.downProductionBlock(model, block, step)
    if model ~= nil and block ~= nil then
        table.down_indexed_list(model.blocks, block.index, step)
        for _, block in pairs(model.blocks) do
            if block.index == 0 then
                block.unlinked = true
                break
            end
        end
    end
end

-------------------------------------------------------------------------------
---Up a production recipe
---@param block table
---@param recipe RecipeData
---@param step number
function ModelBuilder.upProductionRecipe(block, recipe, step)
    if block ~= nil and block.recipes ~= nil and recipe ~= nil then
        table.up_indexed_list(block.recipes, recipe.index, step)
        ---change block name
        local first_recipe = Model.firstRecipe(block.recipes)
        if first_recipe ~= nil then
            local recipe_prototype = RecipePrototype(first_recipe)
            local icon_name, icon_type = recipe_prototype:getIcon()
            block.name = icon_name
            block.type = icon_type
        end
    end
end

-------------------------------------------------------------------------------
---Down a production recipe
---@param block table
---@param recipe RecipeData
---@param step number
function ModelBuilder.downProductionRecipe(block, recipe, step)
    if block ~= nil and block.recipes ~= nil and recipe ~= nil then
        table.down_indexed_list(block.recipes, recipe.index, step)
        ---change block name
        local first_recipe = Model.firstRecipe(block.recipes)
        if first_recipe ~= nil then
            local recipe_prototype = RecipePrototype(first_recipe)
            local icon_name, icon_type = recipe_prototype:getIcon()
            block.name = icon_name
            block.type = icon_type
        end
    end
end

-------------------------------------------------------------------------------
---Update recipe contraint
---@param recipe RecipeData
---@param contraint table
function ModelBuilder.updateRecipeContraint(recipe, contraint)
    if recipe ~= nil then
        if recipe.contraint ~= nil and recipe.contraint.name == contraint.name and recipe.contraint.type == contraint.type then
            recipe.contraint = nil
        else
            recipe.contraint = contraint
        end
    end
end

-------------------------------------------------------------------------------
---Update recipe Neighbour Bonus
---@param recipe table
---@param value number
function ModelBuilder.updateRecipeNeighbourBonus(recipe, value)
    if recipe ~= nil then
        recipe.factory.neighbour_bonus = value
    end
end

return ModelBuilder
