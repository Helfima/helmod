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
        -- add recipe
        ---@type RecipeData
        local ModelRecipe = Model.newRecipe(model, lua_recipe.name, recipe_type)
        local icon_name, icon_type = recipe_prototype:getIcon()
        
        if index == nil then
            local child_index = table.size(block.children)
            ModelRecipe.index = child_index
        else
            ModelRecipe.index = index
            for _, child in pairs(block.children) do
                if child.index >= index then
                    child.index = child.index + 1
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
                ModelRecipe.beacons = {}
                for _, default_beacon in pairs(default_beacons) do
                    local beacon = Model.addBeacon(ModelRecipe, default_beacon.name, default_beacon.combo, default_beacon.per_factory, default_beacon.per_factory_constant)
                    ModelBuilder.setBeaconModulePriority(beacon, ModelRecipe, default_beacon.module_priority)
                end
            end
        else
            Model.setFactory(ModelRecipe, recipe_name)
        end

        ModelCompute.prepareBlockElements(block)
        
        block.children[ModelRecipe.id] = ModelRecipe

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
    ModelBuilder.updateTreeChildDown(model, parent, block, with_below)
end

-------------------------------------------------------------------------------
---Move down block in the tree
---@param model ModelData
---@param parent BlockData
---@param block BlockData
---@param with_below boolean
function ModelBuilder.updateTreeBlockUp(model, parent, block, with_below)
    ModelBuilder.updateTreeChildUp(model, parent, block, with_below)
end

-------------------------------------------------------------------------------
---Move down child in the tree
---@param model ModelData
---@param block BlockData
---@param child RecipeData | BlockData
---@param with_below boolean
function ModelBuilder.updateTreeChildDown(model, block, child, with_below)
    local parent_block = model.blocks[block.parent_id] or model.block_root

    local sorter = defines.sorters.block.sort
    if block.by_product == false then sorter = defines.sorters.block.reverse end
    local started = false
    for _, block_child in spairs(block.children, sorter) do
        if started == true then
            if with_below ~= true then
                break
            end
           -- clean block
           block.children[block_child.id] = nil
           -- update index
           block_child.index = table.size(parent_block.children)
           -- add into block
           parent_block.children[block_child.id] = block_child
           block_child.parent_id = parent_block.id
        end
        if block_child == child and started == false then
            -- clean block
            block.children[block_child.id] = nil
            -- update index
            block_child.index = table.size(parent_block.children)
            -- add into block
            parent_block.children[block_child.id] = block_child
            block_child.parent_id = parent_block.id
            started = true
        end
    end

    if table.size(block.children) == 0 then
        ModelBuilder.blockChildRemove(model, parent_block, block)
    end

    ModelCompute.prepareBlockElements(parent_block)
    ModelCompute.prepareBlockElements(block)
    
end

-------------------------------------------------------------------------------
---Move up child in the tree
---@param model ModelData
---@param block BlockData
---@param child RecipeData | BlockData
---@param with_below boolean
function ModelBuilder.updateTreeChildUp(model, block, child, with_below)
    local new_block = Model.newBlock(model, child)
    local block_index = table.size(model.blocks)
    new_block.index = block_index
    new_block.unlinked = block.by_factory and true or false
    new_block.by_factory = block.by_factory
    new_block.by_product = block.by_product
    new_block.by_limit = block.by_limit
    model.blocks[new_block.id] = new_block
    child.parent_id = new_block.id

    local sorter = defines.sorters.block.sort
    if block.by_product == false then sorter = defines.sorters.block.reverse end
    local started = false
    for _, block_child in spairs(block.children, sorter) do
        if started == true then
            if with_below ~= true then
                break
            end
            -- update index
            block_child.index = table.size(new_block.children)
            -- clean block
            block.children[block_child.id] = nil
            -- add child
            new_block.children[block_child.id] = block_child
        end
        if block_child == child and started == false then
            -- clean block
            block.children[block_child.id] = nil
            -- update index
            new_block.index = block_child.index
            block_child.index = table.size(new_block.children)
            -- add block
            block.children[new_block.id] = new_block
            new_block.parent_id = block.id
            new_block.children[block_child.id] = block_child
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
---Update recipe production
---@param block BlockData
---@param production number
function ModelBuilder.updateBlockChildrenProduction(block, production)
    if block ~= nil then
        for _, child in pairs(block.children) do
            child.production = production
        end
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
        ModelBuilder.setFactoryModulePriority(recipe, module_priority)
    end
end

-------------------------------------------------------------------------------
---Apply a module priority in factory
---@param recipe RecipeData
function ModelBuilder.applyBeaconModulePriority(recipe)
    if recipe ~= nil then
        local beacons = recipe.beacons
        for index, beacon in ipairs(beacons) do
            local module_priority = beacon.module_priority
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
---@param block BlockData
---@param current_recipe RecipeData
function ModelBuilder.setFactoryBlock(block, current_recipe)
    if current_recipe ~= nil then
        local default_factory_mode = User.getParameter("default_factory_mode")
        local categories = EntityPrototype(current_recipe.factory.name):getCraftingCategories()
        local factory_prototype = EntityPrototype(current_recipe.factory.name)
        local factory_ingredient_count = factory_prototype:getIngredientCount()
        for _, child in pairs(block.children) do
            if child.children == nil then
                local recipe = child
                if recipe ~= current_recipe then
                    local prototype_recipe = RecipePrototype(recipe)
                    local recipe_ingredient_count = prototype_recipe:getIngredientCount()
                    --- check ingredient limitation
                    if factory_ingredient_count < recipe_ingredient_count then
                        -- Skip
                    elseif (default_factory_mode ~= "category" and categories[prototype_recipe:getCategory()]) or prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
                        Model.setFactory(recipe, current_recipe.factory.name, current_recipe.factory.fuel)
                        ModelBuilder.setFactoryModulePriority(recipe, current_recipe.factory.module_priority)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set factory line
---@param model ModelData
---@param current_recipe RecipeData
function ModelBuilder.setFactoryLine(model, current_recipe)
    if current_recipe ~= nil then
        ModelBuilder.setFactoryBlock(model.block_root, current_recipe)
        for _, block in pairs(model.blocks) do
            ModelBuilder.setFactoryBlock(block, current_recipe)
        end
    end
end

-------------------------------------------------------------------------------
---Set factory module block
---@param block BlockData
---@param current_recipe RecipeData
function ModelBuilder.setFactoryModuleBlock(block, current_recipe)
    if current_recipe ~= nil then
        for key, child in pairs(block.children) do
            if child.children == nil then
                local recipe = child
                if recipe ~= current_recipe then
                    local prototype_recipe = RecipePrototype(recipe)
                    if prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
                        ModelBuilder.setFactoryModulePriority(recipe, current_recipe.factory.module_priority)
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Set factory module line
---@param model ModelData
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
---@param block BlockData
---@param current_recipe RecipeData
function ModelBuilder.setBeaconBlock(block, current_recipe)
    if current_recipe ~= nil then
        local default_beacon_mode = User.getParameter("default_beacon_mode")
        for key, child in pairs(block.children) do
            if child.children == nil then
                local recipe = child
                if recipe ~= current_recipe then
                    local prototype_recipe = RecipePrototype(recipe)
                    if default_beacon_mode ~= "category" or prototype_recipe:getCategory() == RecipePrototype(current_recipe):getCategory() then
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
end

-------------------------------------------------------------------------------
---Set beacon line
---@param model ModelData
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
---@param block BlockData
---@param current_recipe RecipeData
function ModelBuilder.setBeaconModuleBlock(block, current_recipe)
    if current_recipe ~= nil then
        for key, child in pairs(block.children) do
            if child.children == nil then
                local recipe = child
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
end

-------------------------------------------------------------------------------
---Set beacon module line
---@param model ModelData
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
---Past model
---@param into_model ModelData
---@param into_block BlockData
---@param from_data ModelData | BlockData
function ModelBuilder.pastModel(into_model, into_block, from_data)
    if Model.isBlock(from_data) then
        ModelBuilder.copyBlock(into_model, into_block, from_data)
    else
        ModelBuilder.copyModel(into_model, from_data)
    end
end

-------------------------------------------------------------------------------
---Copy model
---@param into_model ModelData
---@param from_model ModelData
function ModelBuilder.copyModel(into_model, from_model)
    if from_model ~= nil then
        if from_model.parameters ~= nil then
            into_model.parameters = table.deepcopy(from_model.parameters)
        end
        into_model.block_root.name = from_model.block_root.name
        into_model.block_root.type = from_model.block_root.type
        ModelBuilder.copyBlock(into_model, into_model.block_root, from_model.block_root)
    end
end

-------------------------------------------------------------------------------
---Copy block
---@param into_model ModelData
---@param into_block BlockData
---@param from_block BlockData
function ModelBuilder.copyBlock(into_model, into_block, from_block)
    if from_block ~= nil then
        local from_child_ids = {}
        for child_id, child in spairs(from_block.children, defines.sorters.block.sort) do
            table.insert(from_child_ids, child_id)
        end
        local child_index = #from_child_ids
        for _, child_id in ipairs(from_child_ids) do
            local child = from_block.children[child_id]
            local is_block = Model.isBlock(child)
            if is_block then
                local new_block = Model.newBlock(into_model, child)
                new_block.index = child_index
                new_block.unlinked = child.by_factory and true or false
                new_block.by_factory = child.by_factory
                new_block.by_product = child.by_product
                new_block.by_limit = child.by_limit
                into_model.blocks[new_block.id] = new_block
                ModelBuilder.copyBlock(into_model, new_block, child)
                into_block.children[new_block.id] = new_block
                child_index = child_index + 1
            else
                local recipe = child
                local recipe_prototype = RecipePrototype(recipe)
                if recipe_prototype:native() ~= nil then
                    local recipe_model = Model.newRecipe(into_model, recipe.name, recipe_prototype:getType())
                    recipe_model.index = child_index
                    recipe_model.production = recipe.production or 1
                    recipe_model.factory = ModelBuilder.copyFactory(recipe.factory)
                    if recipe.beacons ~= nil then
                        recipe_model.beacons = {}
                        for _, beacon in pairs(recipe.beacons) do
                            table.insert(recipe_model.beacons, ModelBuilder.copyBeacon(beacon))
                        end
                    end

                    if recipe.contraint ~= nil then
                        recipe_model.contraint = table.deepcopy(recipe.contraint)
                    end
                    into_block.children[recipe_model.id] = recipe_model
                    child_index = child_index + 1
                end
            end
            
        end
        if into_block ~= nil then
            table.reindex_list(into_block.children)
            if from_block.products_linked ~= nil then
                into_block.products_linked = table.deepcopy(from_block.products_linked)
            end
        end
    end
end

---Copy recipe
---@param recipe RecipeData
---@return RecipeData
function ModelBuilder.copyRecipe(recipe)
end

---Copy factory
---@param factory FactoryData
---@return FactoryData
function ModelBuilder.copyFactory(factory)
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

---Copy beacon
---@param beacon FactoryData
---@return FactoryData
function ModelBuilder.copyBeacon(beacon)
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
---Update a product
---@param block BlockData
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
---@param block BlockData
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
---Rebuild parent of block
---@param model ModelData
function ModelBuilder.rebuildParentBlockOfModel(model)
    if model.block_root ~= nil then
        if model.block_root.children ~= nil then
            model.block_root.parent_id = model.id
            for _, subChild in pairs(model.block_root.children) do
                ModelBuilder.rebuildParentBlockOfBlock(model.block_root, subChild)
            end        
        end
    end
end

-------------------------------------------------------------------------------
---Rebuild parent of block
---@param parent BlockData
---@param child BlockData | RecipeData
function ModelBuilder.rebuildParentBlockOfBlock(parent, child)
    child.parent_id = parent.id
    if child.children ~= nil then
        for _, subChild in pairs(child.children) do
            ModelBuilder.rebuildParentBlockOfBlock(child, subChild)
        end        
    end
end

-------------------------------------------------------------------------------
---Remove a child of block
---@param model ModelData
---@param block BlockData
---@param child RecipeData | BlockData
function ModelBuilder.blockChildRemove(model, block, child)
    if block ~= nil and block.children ~= nil and block.children[child.id] ~= nil then
        ModelBuilder.blockChildDeepRemove(model, child)
        block.children[child.id] = nil
        table.reindex_list(block.children)
        ---change block name
        ModelBuilder.blockUpdateIcon(block)
    end
end

-------------------------------------------------------------------------------
---Remove all child block of block
---@param model ModelData
---@param child RecipeData | BlockData
function ModelBuilder.blockChildDeepRemove(model, child)
    local is_block = Model.isBlock(child)
    if is_block and child ~= nil and child.children ~= nil then
        for _, subChild in pairs(child.children) do
            ModelBuilder.blockChildDeepRemove(model, subChild)
        end
    end
    model.blocks[child.id] = nil
end

-------------------------------------------------------------------------------
---Up a production recipe
---@param block BlockData
---@param recipe RecipeData
---@param step number
function ModelBuilder.blockChildUp(block, recipe, step)
    if block ~= nil and block.children ~= nil and recipe ~= nil then
        table.up_indexed_list(block.children, recipe.index, step)
        ---change block name
        ModelBuilder.blockUpdateIcon(block)
    end
end

-------------------------------------------------------------------------------
---Down a production recipe
---@param block BlockData
---@param recipe RecipeData
---@param step number
function ModelBuilder.blockChildDown(block, recipe, step)
    if block ~= nil and block.children ~= nil and recipe ~= nil then
        table.down_indexed_list(block.children, recipe.index, step)
        ---change block name
        ModelBuilder.blockUpdateIcon(block)
    end
end

-------------------------------------------------------------------------------
---Down a production recipe
---@param block BlockData
function ModelBuilder.blockUpdateIcon(block)
    if block ~= nil and block.children ~= nil then
        local first_recipe = Model.firstChild(block.children)
        if first_recipe ~= nil then
            block.name = first_recipe.name
            block.type = first_recipe.type
        end
    end
end

-------------------------------------------------------------------------------
---Unlink a block
---@param block BlockData
function ModelBuilder.blockUnlink(block)
    if block ~= nil then
        block.unlinked = not (block.unlinked)
        -- TODO delete ?
        -- if not block.unlinked then
        --     for i, ingredient in pairs(block.ingredients) do
        --         ingredient.input = 0
        --         ingredient.count = 0
        --     end
        --     for i, product in pairs(block.products) do
        --         product.input = 0
        --         product.count = 0
        --     end
        -- end
    end
end

-------------------------------------------------------------------------------
---Update child contraint
---@param child RecipeData | BlockData
---@param contraint ContraintData
function ModelBuilder.updateChildContraint(child, contraint)
    if child ~= nil then
        if child.contraints == nil then child.contraints = {} end
        if child.contraints[contraint.name] ~= nil then
            if child.contraints[contraint.name].type == contraint.type then
                child.contraints[contraint.name] = nil
            else
                child.contraints[contraint.name] = contraint
            end
        else
            child.contraints[contraint.name] = contraint
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
