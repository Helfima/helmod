require "math.Matrix"
require "math.SolverMatrix"
require "math.SolverMatrixAlgebra"
require "math.SolverMatrixSimplex"
require "math.SolverLinkedMatrix"
require "math.SolverLinkedMatrixAlgebra"
require "math.SolverLinkedMatrixSimplex"

------------------------------------------------------------------------------
---Description of the module.
---@class ModelCompute
local ModelCompute = {
    classname = "HMModelCompute",
    capEnergy = -0.8,
    capSpeed = -0.8,
    capPollution = -0.8,
    waste_value = 0.00001,
    new_solver = false,
    cap_reason = {
        speed = {
            cycle = 1,
            module_low = 2,
            module_high = 4
        },
        productivity = {
            module_low = 1,
            recipe_maximum = 2
        },
        consumption = {
            module_low = 1
        },
        pollution = {
            module_low = 1
        }
    }
}

-------------------------------------------------------------------------------
---Check and valid unlinked all blocks
---@param model table
function ModelCompute.checkUnlinkedBlocks(model)
    if model.blocks ~= nil then
        for _, block in spairs(model.blocks, function(t, a, b) return t[b].index > t[a].index end) do
            ModelCompute.checkUnlinkedBlock(model, block)
        end
    end
end

-------------------------------------------------------------------------------
---Check and valid unlinked block
---@param model table
---@param block table
function ModelCompute.checkUnlinkedBlock(model, block)
    local unlinked = true
    local recipe = Player.getPlayerRecipe(block.name)
    if recipe ~= nil then
        if model.blocks ~= nil then
            for _, current_block in spairs(model.blocks, function(t, a, b) return t[b].index > t[a].index end) do
                if current_block.id == block.id then
                    break
                end
                for _, ingredient in pairs(current_block.ingredients) do
                    for _, product in pairs(recipe.products) do
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
    else
        ---not a recipe
        block.unlinked = true
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.try_update(model)
    local ok , err = pcall(function()
        ModelCompute.update(model)
    end)
    if not(ok) then
        log(err)
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model ModelData
function ModelCompute.update(model)
    if model ~= nil and model.blocks ~= nil then
        -- Add parameters
        Model.appendParameters(model)
        ModelCompute.updateBlock(model, model.block_root)
        ModelCompute.finalizeBlock(model.block_root, 1)
        model.version = Model.version
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model ModelData
---@param block BlockData
function ModelCompute.updateBlock(model, block)
    block.time = model.time
    local children = block.children

    -- check if block has child
    local _, child
    if children ~= nil then
        _, child = next(children)
    end
    if child == nil then
        -- empty block
        block.ingredients = {}
        block.products = {}
    else
        -- compute block children
        for _, child in spairs(children, defines.sorters.block.sort) do
            local is_block = Model.isBlock(child)
            if is_block then
                ModelCompute.updateBlock(model, child)
            end
        end
        ---prepare block
        ModelCompute.prepareBlockElements(block)

        ModelCompute.prepareBlockObjectives(block)

        ModelCompute.computeBlock(block, model.parameters)
        
        -- TODO
        --ModelCompute.computeResources(model)
    end
end

-------------------------------------------------------------------------------
---Create factories summary
---@param block BlockData
---@param factory table
---@param from_child boolean
function ModelCompute.createSummaryFactory(block, factory, from_child)
    ModelCompute.createSummaryMachine(block, "summary_global", "factories", factory)
    if from_child == false then
        ModelCompute.createSummaryMachine(block, "summary", "factories", factory)
    end
end

-------------------------------------------------------------------------------
---Create beacons summary
---@param block BlockData
---@param beacon table
---@param from_child boolean
function ModelCompute.createSummaryBeacon(block, beacon, from_child)
    -- same section of factories
    ModelCompute.createSummaryMachine(block, "summary_global", "factories", beacon)
    if from_child == false then
        ModelCompute.createSummaryMachine(block, "summary", "factories", beacon)
    end
end

-------------------------------------------------------------------------------
---Finalize input block
---@param block BlockData
---@param summary_name string
---@param section string
---@param factory table
function ModelCompute.createSummaryMachine(block, summary_name, section, factory)
    ---summary factory
    local factory_key = Model.getQualityElementKey(factory)
    if block[summary_name] == nil then
        block[summary_name] = {}
    end
    local summary = block[summary_name]
    local summary_factory = summary[section][factory_key]
    if summary_factory == nil then
        summary_factory = {
            name = factory.name,
            quality = factory.quality,
            type = factory.type or "entity",
            count = 0,
            count_limit = 0,
            count_deep = 0
        }
        summary[section][factory_key] = summary_factory
    end
    
    local factory_ceil = math.ceil(factory.count)

    summary_factory.count = summary_factory.count + factory_ceil
    summary_factory.count_limit = summary_factory.count
    summary_factory.count_deep = summary_factory.count * block.count_deep

    summary.building = summary.building + factory_ceil
    summary.building_limit = summary.building
    summary.building_deep = summary.building * block.count_deep
    ---summary factory module
    if factory.modules ~= nil then
        for _, module in pairs(factory.modules) do
            local module_key = Model.getQualityElementKey(module)
            local summary_module = summary.modules[module_key]
            if summary_module == nil then
                summary_module = {
                    name = module.name,
                    quality = module.quality,
                    type = "item",
                    count = 0,
                    count_limit = 0,
                    count_deep = 0
                }
                summary.modules[module_key] = summary_module
            end
            summary_module.count = summary_module.count + module.amount * factory_ceil
            summary_module.count_limit = summary_module.count
            summary_module.count_limit = summary_module.count * block.count_deep
        end
    end
end

-------------------------------------------------------------------------------
---Finalize input block
---@param block BlockData
function ModelCompute.finalizeBlock(block, factor)
    local one_block_factor_enable = User.getPreferenceSetting("one_block_factor_enable")
    local one_block_factor = 1
    if one_block_factor_enable and block.has_input ~= true then
        one_block_factor = block.count
        block.count = 1
        block.count_limit = 1
        for _, product in pairs(block.products) do
            product.amount = product.amount * one_block_factor
        end
        for _, ingredient in pairs(block.ingredients) do
            ingredient.amount = ingredient.amount * one_block_factor
        end
    end
    block.count_limit = block.count
    block.power = 0
    block.power_limit = 0
    block.power_deep = 0
    block.pollution = 0
    block.pollution_limit = 0
    block.pollution_deep = 0
    block.summary = { building = 0, building_limit = 0, building_deep = 0, factories = {}, beacons = {}, modules = {} }
    block.summary_global = { building = 0, building_limit = 0, building_deep = 0, factories = {}, beacons = {}, modules = {} }
    
    block.count_deep = block.count * factor
    local children = block.children
    if children ~= nil and table.size(children) > 0 then
        local spoilage_recipes = {has_spoil = false, recipes={}, products={}, ingredients={}}
        local ratio_limit = -1
        local sorter = defines.sorters.block.sort
        if block.by_product == false then
            sorter = defines.sorters.block.reverse
        end
        -- compute block children
        for _, child in spairs(children, sorter) do
            child.count = child.count * one_block_factor
            child.count_limit = child.count
            local is_block = Model.isBlock(child)
            if is_block then
                ModelCompute.finalizeBlock(child, block.count_deep)

                block.power = block.power + child.power * block.count
                block.power_limit = block.power
                block.power_deep = block.power_deep + child.power_deep

                block.pollution = block.pollution + child.pollution * block.count
                block.pollution_limit = block.pollution
                block.pollution_deep = block.pollution_deep + child.pollution_deep

                for _, factory in pairs(child.summary_global.factories) do
                    ModelCompute.createSummaryFactory(block, factory, true)
                end
                for _, beacon in pairs(child.summary_global.beacons) do
                    ModelCompute.createSummaryBeacon(block, beacon, true)
                end
                for module_key, module in pairs(child.summary_global.modules) do
                    local summary_module = block.summary_global.modules[module_key]
                    if summary_module == nil then
                        summary_module = {
                            name = module.name,
                            quality = module.quality,
                            type = "item",
                            count = 0,
                            count_limit = 0,
                            count_deep = 0
                        }
                        block.summary_global.modules[module_key] = summary_module
                    end
                    summary_module.count = summary_module.count + module.count
                    summary_module.count_limit = summary_module.count
                    summary_module.count_deep = summary_module.count * block.count_deep
                end
                if child.products ~= nil then
                    for key, lua_product in pairs(child.products) do
                        if lua_product.spoil ~= nil and lua_product.amount > 0 then
                            local spoil_product = {
                                spoil=lua_product.spoil,
                                spoil_out = lua_product.spoil,
                                spoil_amount=lua_product.spoil * lua_product.amount,
                                count=lua_product.amount}
                            spoilage_recipes.products[key] = spoil_product
                        end
                        
                    end
                   
                end
            else
                ---@type RecipeData
                local recipe = child
                recipe.count_limit = recipe.count
                recipe.count_deep = recipe.count * block.count_deep
                
                if recipe.factory ~= nil then
                    recipe.factory.count = recipe.factory.amount * recipe.count
                    recipe.factory.count_limit = recipe.factory.count
                    recipe.factory.count_deep = recipe.factory.count * block.count_deep

                    ModelCompute.createSummaryFactory(block, recipe.factory, false)
                end

                if recipe.beacons ~= nil then
                    for _, beacon in pairs(recipe.beacons) do
                        local constant = 0
                        if beacon.amount == nil then
                            beacon.amount = 0
                        end
                        -- add constant only if has a beacon
                        if beacon.amount > 0 then
                            constant = beacon.per_factory_constant or 0
                        end
                        beacon.count = beacon.amount * recipe.count + constant
                        beacon.count_limit = beacon.count
                        beacon.count_deep = beacon.count * block.count_deep

                        ModelCompute.createSummaryBeacon(block, beacon, false)
                    end
                end
                if recipe.energy_total == nil then recipe.energy_total = 0 end
                recipe.power = recipe.energy_total * recipe.count
                recipe.power_limit = recipe.power
                recipe.power_deep = recipe.power * block.count_deep
                
                recipe.pollution = recipe.pollution_amount * recipe.count
                recipe.pollution_limit = recipe.pollution
                recipe.pollution_deep = recipe.pollution * block.count_deep
                
                block.power = block.power + recipe.power * block.count
                block.power_limit = block.power
                block.power_deep = block.power_deep + recipe.power_deep

                block.pollution = block.pollution + recipe.pollution * block.count
                block.pollution_limit = block.pollution
                block.pollution_deep = block.pollution_deep + recipe.pollution_deep

                if recipe.factory ~= nil and type(recipe.factory.limit) == "number" and recipe.factory.limit > 0 then
                    local current_ratio = recipe.factory.limit / recipe.factory.count
                    if ratio_limit > current_ratio or ratio_limit == -1 then
                        ratio_limit = current_ratio
                    end
                end
                -- spoilage
                if recipe.spoilage ~= nil then
                    table.insert(spoilage_recipes.recipes, 1, recipe)
                    spoilage_recipes.has_spoil = true
                end
            end
        end

        if spoilage_recipes.has_spoil then
            for _, recipe in pairs(spoilage_recipes.recipes) do
                local spoil_product = {spoil=1, spoil_amount=0, count=0}
                for key, spoilage in pairs(recipe.spoilage.ingredients) do
                    recipe.spoilage.has_spoil = true
                    if spoilage_recipes.products[key] ~= nil then
                        spoilage.spoil = spoilage_recipes.products[key].spoil_out
                    end
                    recipe.spoilage.ingredients[key] = spoilage
                    spoil_product.spoil_amount = spoil_product.spoil_amount + spoilage.spoil * spoilage.amount
                    spoil_product.count = spoil_product.count + spoilage.amount
                    if spoil_product.count > 0 then
                        spoil_product.spoil = spoil_product.spoil_amount / spoil_product.count
                    end
                end
                for key, spoilage in pairs(recipe.spoilage.products) do
                    recipe.spoilage.has_spoil = true
                    if recipe.spoilage.ingredients[key] ~= nil then
                        spoilage.spoil = 1   
                    end
                    -- percent_spoiled used in some recipe
                    spoilage.spoil = spoil_product.spoil * (spoilage.percent_spoiled or 1)
                    spoilage.spoil_out = spoil_product.spoil * (recipe.spoilage_factor or 1)
                    spoilage_recipes.products[key] = spoilage
                    if block.products[key] ~= nil then
                        block.products[key].spoil = spoilage.spoil_out
                    end
                end
            end
        end
        if ratio_limit > 0 then
            block.count_ratio_limit = ratio_limit
            block.count_limit = ratio_limit
            block.power_limit = block.power * ratio_limit
            block.pollution_limit = block.pollution * ratio_limit
            block.summary_global.building_limit =  block.summary_global.building * ratio_limit
            for _, factory in pairs(block.summary_global.factories) do
                factory.count_limit = factory.count * ratio_limit
            end
            for _, beacon in pairs(block.summary_global.beacons) do
                beacon.count_limit = beacon.count * ratio_limit
            end
            for _, module in pairs(block.summary_global.modules) do
                module.count_limit = module.count * ratio_limit
            end

            for _, child in spairs(children, defines.sorters.block.sort) do
                local is_block = Model.isBlock(child)
                if is_block then
                    --child.count_limit = child.count * ratio_limit
                    --child.power_limit = child.power * ratio_limit
                    --child.pollution_limit = child.pollution * ratio_limit
                else
                    local recipe = child
                    recipe.count_limit = recipe.count * ratio_limit
                    if recipe.factory ~= nil then
                        recipe.factory.count_limit = recipe.factory.count * ratio_limit
                        recipe.factory.energy_limit = recipe.factory.energy_total * ratio_limit
                    end
                    if recipe.beacons ~= nil then
                        for _, beacon in pairs(recipe.beacons) do
                            beacon.count_limit = beacon.count * ratio_limit
                            beacon.energy_limit = beacon.energy_total * ratio_limit
                        end
                    end
                    recipe.power_limit = recipe.power * ratio_limit
                    recipe.pollution_limit = recipe.pollution * ratio_limit
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Clear all inputs of block
---@param block BlockData
function ModelCompute.clearBlockInputs(block)
    -- state = 0 => product
    -- state = 1 => main product
    -- state = 2 => remaining product
    -- prepare input
    if block.products == nil then
        ModelCompute.computeBlock(block)
    end
    local block_elements = block.products
    if block.by_product == false then
        block_elements = block.ingredients
    end
    if block_elements ~= nil then
        for _, element in pairs(block_elements) do
            element.input = nil
        end
    end
end

-------------------------------------------------------------------------------
---Prepare objectives of block
---@param block BlockData
function ModelCompute.prepareBlockObjectives(block)
    -- state = 0 => product
    -- state = 1 => main product
    -- state = 2 => remaining product
    -- prepare input
    if block.products == nil then
        ModelCompute.computeBlock(block)
    end
    local objectives_block = {}

    local factor = 1
    local block_elements = block.products
    if block.by_product == false then
        block_elements = block.ingredients
        factor = 1
    end
    if block_elements ~= nil then
        for _, element in pairs(block_elements) do
            local element_key = Product(element):getTableKey()
            local objective = {}
            if element.input ~= nil then
                objective.key = element_key
                objective.value = element.input * factor
                objectives_block[element_key] = objective
            end
        end
    end
    local objectives_size = table.size(objectives_block)
    block.has_input = objectives_size > 0
    -- if empty objectives create from the children
    if objectives_size == 0 then
        local children = block.children
        for _, child in spairs(children, defines.sorters.block.sort) do
            local is_block = Model.isBlock(child)
            if is_block then
                local child_elements = nil
                local factor = 1
                if block.by_product == false then
                    child_elements = child.ingredients
                    factor = 1
                else
                    child_elements = child.products
                end
                for _, lua_product in pairs(child_elements) do
                    local product = Product(lua_product)
                    local element_key = product:getTableKey()
                    local state = 0
                    if block_elements[element_key] ~= nil then
                        state = block_elements[element_key].state
                    end
                    if state == 1 then
                        local count = lua_product.amount
                        local objective = {}
                        objective.key = element_key
                        objective.value = count * factor
                        objectives_block[element_key] = objective
                    end
                    break
                end
            else
                local recipe_prototype = RecipePrototype(child)
                local child_elements = nil
                local factor = 1
                if block.by_product == false then
                    child_elements = recipe_prototype:getQualityIngredients(child.factory, child.quality)
                    factor = 1
                else
                    child_elements = recipe_prototype:getQualityProducts(child.factory, child.quality)
                end
                for _, lua_product in pairs(child_elements) do
                    local product = Product(lua_product)
                    local element_key = product:getTableKey()
                    local state = 0
                    if block_elements[element_key] ~= nil then
                        state = block_elements[element_key].state
                    end
                    if state == 1 then
                        local count = product:getAmount()
                        local objective = {}
                        objective.key = element_key
                        objective.value = count * factor
                        objectives_block[element_key] = objective
                    end
                    break
                end
            end
        end
    end
    block.objectives = objectives_block
end

-------------------------------------------------------------------------------
---Prepare products and ingredients of block
---@param block BlockData
function ModelCompute.prepareBlockElements(block)
    local children = block.children
    if children ~= nil then
        local block_products = {}
        local block_ingredients = {}
        -- prepare
        for _, child in spairs(children, defines.sorters.block.sort) do
            local is_block = Model.isBlock(child)
            local child_products = nil
            local child_ingredients = nil
            if is_block then
                child_products = child.products
                child_ingredients = child.ingredients
            else
                local recipe_prototype = RecipePrototype(child)
                child_products = recipe_prototype:getQualityProducts(child.factory, child.quality)
                child_ingredients = recipe_prototype:getQualityIngredients(child.factory, child.quality)
                child.spoilage = {products={}, ingredients={}}
            end
            -- prepare products
            for _, lua_product in pairs(child_products) do
                local product = Product(lua_product)
                local product_key = product:getTableKey()

                lua_product.spoil = product:getSpoil()
                if child.spoilage ~= nil and lua_product.spoil ~= nil then
                    local amount = product:getAmount()
                    child.spoilage.products[product_key] = {spoil = lua_product.spoil, percent_spoiled=lua_product.percent_spoiled, amount = amount}
                end

                block_products[product_key] = {
                    key = product_key,
                    name = lua_product.name,
                    type = lua_product.type,
                    quality = lua_product.quality,
                    amount = 0,
                    spoil = product.spoil,
                    temperature = lua_product.temperature,
                    minimum_temperature = lua_product.minimum_temperature,
                    maximum_temperature = lua_product.maximum_temperature
                }
            end
            -- prepare ingredients
            for _, lua_ingredient in pairs(child_ingredients) do
                local product = Product(lua_ingredient)
                local ingredient_key = product:getTableKey()

                lua_ingredient.spoil = product:getSpoil()
                if child.spoilage ~= nil and lua_ingredient.spoil ~= nil then
                    local amount = product:getAmount()
                    child.spoilage.ingredients[ingredient_key] = {spoil = lua_ingredient.spoil, amount = amount}
                end

                block_ingredients[ingredient_key] = {
                    key = ingredient_key,
                    name = lua_ingredient.name,
                    type = lua_ingredient.type,
                    quality = lua_ingredient.quality,
                    amount = 0,
                    spoil = lua_ingredient.spoil,
                    temperature = lua_ingredient.temperature,
                    minimum_temperature = lua_ingredient.minimum_temperature,
                    maximum_temperature = lua_ingredient.maximum_temperature
                }
            end
        end

        -- prepare state
        -- state = 0 => product
        -- state = 1 => main product
        -- state = 2 => remaining product
        for i, block_product in pairs(block_products) do
            local product_key = Product(block_product):getTableKey()
            -- copy input value
            if block.by_factory ~= true and block.products ~= nil and block.products[product_key] ~= nil then
                block_product.input = block.products[product_key].input
            end
            -- set state
            if block_product.type == "fluid" then
                local main_fluid = true;
                for key, block_ingredient in pairs(block_ingredients) do
                    if block_ingredient.type == "fluid" and block_ingredient.name == block_product.name then
                        if ModelCompute.checkLinkedTemperatureFluid(block_product, block_ingredient, true) then
                            main_fluid = false
                        end
                    end
                end
                if main_fluid then
                    block_product.state = 1
                else
                    block_product.state = 0
                end
            else
                if block_ingredients[product_key] == nil then
                    block_product.state = 1
                else
                    block_product.state = 0
                end
            end
        end

        for i, block_ingredient in pairs(block_ingredients) do
            local ingredient_key = Product(block_ingredient):getTableKey()
            -- copy input value
            if block.by_factory ~= true and block.ingredients ~= nil and block.ingredients[ingredient_key] ~= nil then
                block_ingredient.input = block.ingredients[ingredient_key].input
            end
            -- set state
            if block_ingredient.type == "fluid" then
                local main_fluid = true;
                for key, block_product in pairs(block_products) do
                    if block_product.type == "fluid" and block_product.name == block_ingredient.name then
                        if ModelCompute.checkLinkedTemperatureFluid(block_ingredient, block_product, true) then
                            main_fluid = false
                        end
                    end
                end
                if main_fluid then
                    block_ingredient.state = 1
                else
                    block_ingredient.state = 0
                end
            else
                if block_products[ingredient_key] == nil then
                    block_ingredient.state = 1
                else
                    block_ingredient.state = 0
                end
            end
        end
        block.products = block_products
        block.ingredients = block_ingredients
    end
end
-------------------------------------------------------------------------------
---Check Linked Temperature Fluid
---@param item1 table
---@param item2 table
---@param by_product boolean
---@return boolean
function ModelCompute.checkLinkedTemperatureFluid(item1, item2, by_product)
    local result = false

    local product, ingredient
    if by_product ~= false then
        product = item1
        ingredient = item2
    else
        product = item2
        ingredient = item1
    end
    if product.key == ingredient.key then
        return true
    end

    local T = product.temperature
    local T2 = ingredient.temperature
    local T2min = ingredient.minimum_temperature
    local T2max = ingredient.maximum_temperature
    if T ~= nil or T2 ~= nil or T2min ~= nil or T2max ~= nil then
        ---traitement seulement si une temperature
        if T2min == nil and T2max == nil then
            ---Temperature sans intervale
            if T == nil or T2 == nil or T2 == T then
                result = true
            end
        else
            ---Temperature avec intervale
            ---securise les valeurs
            T = T or 25
            T2min = T2min or -defines.constant.max_float
            T2max = T2max or defines.constant.max_float
            if T >= T2min and T <= T2max then
                result = true
            end
        end
    end

    return result
end
-------------------------------------------------------------------------------
---Compute production block
---@param block table
function ModelCompute.computeBlock(block, parameters)
    local children = block.children
    block.power = 0
    block.count = 1
    block.pollution = 0

    if children ~= nil then
        local solver_selected = User.getParameter("solver_selected")
        local my_solver

        local solvers = {}
        solvers[defines.constant.solvers.matrix] = { algebra = SolverMatrixAlgebra, simplex = SolverMatrixSimplex }
        solvers[defines.constant.solvers.default] = { algebra = SolverLinkedMatrixAlgebra, simplex = SolverLinkedMatrixSimplex }
        local selected_solver = solvers[defines.constant.solvers.default]
        if solvers[solver_selected] ~= nil then
            selected_solver = solvers[solver_selected]
        end
        if block.solver == true and block.by_factory ~= true then
            my_solver = selected_solver.simplex()
        else
            my_solver = selected_solver.algebra()
        end

        local debug = User.getModGlobalSetting("debug_solver")
        my_solver:solve(block, parameters, debug)
        
    end
end

--------------------------------------------------------------------------------
---Compute module effects of factory
---@param recipe RecipeData
---@param parameters ParametersData
---@return RecipeData
function ModelCompute.computeModuleEffects(recipe, parameters)
    if recipe.factory == nil then return end
    local factory = recipe.factory
    local factory_prototype = EntityPrototype(factory)
    local recipe_prototype = RecipePrototype(recipe)
    --- apply base effect
    local effect_receiver = factory_prototype:getEffectReveiver()
    factory.effects = {
        speed = effect_receiver.base_effect["speed"] or 0,
        productivity = effect_receiver.base_effect["productivity"] or 0,
        consumption = effect_receiver.base_effect["consumption"] or 0,
        pollution = effect_receiver.base_effect["pollution"] or 0,
        quality = effect_receiver.base_effect["quality"] or 0
    }

    local recipe_productivity = Player.getRecipeProductivityBonus(recipe.name)
    factory.effects.productivity = factory.effects.productivity + recipe_productivity

    if parameters ~= nil then
        factory.effects.speed = factory.effects.speed + (parameters.effects.speed or 0)
        factory.effects.productivity = factory.effects.productivity + (parameters.effects.productivity or 0)
        factory.effects.consumption = factory.effects.consumption + (parameters.effects.consumption or 0)
        factory.effects.pollution = factory.effects.pollution + (parameters.effects.pollution or 0)
        factory.effects.quality = factory.effects.quality + (parameters.effects.quality or 0)
    end
    factory.cap = { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
    
    ---effet module factory
    if factory.modules ~= nil and effect_receiver.uses_module_effects then
        for _, module in pairs(factory.modules) do
            local module_effects = Player.getModuleEffects(module)
            local amount = module.amount
            factory.effects.speed = factory.effects.speed + amount * module_effects.speed
            factory.effects.productivity = factory.effects.productivity + amount * module_effects.productivity
            factory.effects.consumption = factory.effects.consumption + amount * module_effects.consumption
            factory.effects.pollution = factory.effects.pollution + amount * module_effects.pollution
            factory.effects.quality = factory.effects.quality + amount * module_effects.quality
        end
    end
    ---effet module beacon
    if recipe.beacons ~= nil and effect_receiver.uses_beacon_effects then
        local profile_count = 0
        for _, beacon in pairs(recipe.beacons) do
            if beacon.modules ~= nil then
                profile_count = profile_count + beacon.combo
            end
        end
        for _, beacon in pairs(recipe.beacons) do
            if beacon.modules ~= nil then
                for _, module in pairs(beacon.modules) do
                    local module_effects = Player.getModuleEffects(module)
                    local amount = module.amount
                    local prototype_beacon = EntityPrototype(beacon);
                    local distribution_effectivity = prototype_beacon:getDistributionEffectivity()
                    local profile_effectivity = prototype_beacon:getProfileEffectivity(profile_count)

                    factory.effects.speed = factory.effects.speed + amount * module_effects.speed * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.productivity = factory.effects.productivity + amount * module_effects.productivity * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.consumption = factory.effects.consumption + amount * module_effects.consumption * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.pollution = factory.effects.pollution + amount * module_effects.pollution * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.quality = factory.effects.quality + amount * module_effects.quality * distribution_effectivity * profile_effectivity * beacon.combo
                end
            end
        end
    end
    if recipe.type == "resource" then
        local mining_drill_productivity = Player.getForce().mining_drill_productivity_bonus
        factory.effects.productivity = factory.effects.productivity + mining_drill_productivity

        local quality = Player.getQualityPrototype(factory.quality)
        if quality ~= nil then
            local drain_modifier = quality.mining_drill_resource_drain_multiplier
            factory.drain_resource = factory_prototype:getResourceDrain() * drain_modifier
        end
    end
    if recipe.type == "technology" then
        local laboratory_speed_modifier = Player.getForce().laboratory_speed_modifier or 0
        factory.effects.speed = factory.effects.speed + laboratory_speed_modifier * (1 + factory.effects.speed)
        local laboratory_productivity = Player.getForce().laboratory_productivity_bonus or 0
        factory.effects.productivity = factory.effects.productivity + laboratory_productivity

        local machine = EntityPrototype(factory)
    	factory.drain_ingredient = machine:getSciencePackDrainRatePercent() / 100
    end
    ---nuclear reactor
    if factory_prototype:getType() == "reactor" then
        local bonus = factory_prototype:getNeighbourBonus()
        factory.effects.consumption = factory.effects.consumption + bonus
    end

    ---cap la productivite
    if factory.effects.productivity < 0 then
        factory.effects.productivity = 0
        factory.cap.productivity = bit32.bor(factory.cap.productivity, ModelCompute.cap_reason.productivity.module_low)
    end
    if recipe.type == "recipe" then
        local maximum_productivity = recipe_prototype:getMaximumProductivity()
        if factory.effects.productivity > maximum_productivity then
            factory.effects.productivity = maximum_productivity
            factory.cap.productivity = bit32.bor(factory.cap.productivity, ModelCompute.cap_reason.productivity.recipe_maximum)
        end
    end

    ---cap la vitesse a self.capSpeed
    if factory.effects.speed < ModelCompute.capSpeed then
        factory.effects.speed = ModelCompute.capSpeed
        factory.cap.speed = bit32.bor(factory.cap.speed, ModelCompute.cap_reason.speed.module_low)
    end
    ---cap short integer max for %
    ---@see https://fr.wikipedia.org/wiki/Entier_court
    if factory.effects.speed * 100 > 32767 then
        factory.effects.speed = 32767 / 100
        factory.cap.speed = bit32.bor(factory.cap.speed, ModelCompute.cap_reason.speed.module_high)
    end

    ---cap l'energy a self.capEnergy
    if factory.effects.consumption < ModelCompute.capEnergy then
        factory.effects.consumption = ModelCompute.capEnergy
        factory.cap.consumption = bit32.bor(factory.cap.consumption, ModelCompute.cap_reason.consumption.module_low)
    end

    ---cap la pollution a self.capPollution
    if factory.effects.pollution < ModelCompute.capPollution then
        factory.effects.pollution = ModelCompute.capPollution
        factory.cap.pollution = bit32.bor(factory.cap.pollution, ModelCompute.cap_reason.pollution.module_low)
    end
    return recipe
end

-------------------------------------------------------------------------------
---Compute energy, speed, number of factory for recipes
---@param recipe table
function ModelCompute.computeFactory(recipe)
    recipe.pollution_amount = 0
    recipe.energy_total = 0
    if recipe.factory == nil then return end
    local recipe_prototype = RecipePrototype(recipe)
    local factory_prototype = EntityPrototype(recipe.factory)
    recipe.time = recipe_prototype:getEnergy(recipe.factory)

    ---effet speed
    recipe.factory.speed_total = factory_prototype:speedFactory(recipe) * (1 + recipe.factory.effects.speed)
    if recipe.type == "rocket" then
        local speed_penalty = recipe_prototype:getRocketPenalty(recipe.factory)
        recipe.factory.speed_total = recipe.factory.speed_total * speed_penalty
    end
    recipe.factory.speed = recipe.factory.speed_total

    ---effet consumption
    local energy_type = factory_prototype:getEnergyType()
    recipe.factory.energy = factory_prototype:getEnergyConsumption() * (1 + recipe.factory.effects.consumption)

    ---effet pollution
    recipe.factory.pollution = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution) * (1 + recipe.factory.effects.consumption)

    ---compte le nombre de machines necessaires
    ---[ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory] * [le temps en second])
    local count = recipe.time / (recipe.factory.speed * recipe.base_time)
    if recipe.factory.speed == 0 then count = 0 end
    recipe.factory.amount = count

    if energy_type ~= "electric" then
        recipe.factory.energy_total = 0
    else
        local drain = factory_prototype:getMinEnergyUsage()
        recipe.factory.energy = math.ceil(recipe.factory.energy + drain)
        recipe.factory.energy_total = recipe.factory.amount * recipe.factory.energy
    end
    recipe.factory.speed = recipe.factory.speed

    local beacons_energy_total = 0
    if recipe.beacons ~= nil then
        for _, beacon in pairs(recipe.beacons) do
            if Model.countModulesModel(beacon) > 0 then
                local variant = beacon.per_factory or 0
                -- @see ModelCompute.finalizeBlock where beacon.per_factory_constant used
                -- per_factory_constant for 1 block
                beacon.amount = count * variant
            else
                beacon.amount = 0
            end
            local beacon_prototype = EntityPrototype(beacon)
            beacon.energy = beacon_prototype:getEnergyUsage()
            beacon.energy_total = math.ceil(beacon.amount * beacon.energy)
            beacon.energy = math.ceil(beacon.energy)
            beacons_energy_total = beacons_energy_total + beacon.energy_total
        end
    end

    --- totaux
    recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.amount * recipe.base_time
    recipe.pollution_amount = recipe.factory.pollution_total * recipe_prototype:getEmissionsMultiplier()
    recipe.energy_total = recipe.factory.energy_total + beacons_energy_total
end

-------------------------------------------------------------------------------
---Compute energy factory for recipes
---@param recipe table
function ModelCompute.computeEnergyFactory(recipe)
    local recipe_prototype = RecipePrototype(recipe)
    local factory_prototype = EntityPrototype(recipe.factory)
    local recipe_energy = recipe_prototype:getEnergy(recipe.factory)
    ---effet speed
    recipe.factory.speed = factory_prototype:speedFactory(recipe) * (1 + recipe.factory.effects.speed)
    ---cap speed creation maximum de 1 cycle par tick
    ---seulement sur les recipes normaux
    if recipe.type == "recipe" and recipe_energy / recipe.factory.speed < 1 / 60 then
        recipe.factory.speed = 60 * recipe_energy
    end

    local energy_type = factory_prototype:getEnergyType()
    if factory_prototype:getType() == "solar-panel" then
        recipe.factory.energy = factory_prototype:getEnergyProduction() 
    else
        recipe.factory.energy = factory_prototype:getEnergyConsumption() * (1 + recipe.factory.effects.consumption)
    end

    ---effet pollution
    recipe.factory.pollution_amount = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution)

    ---compte le nombre de machines necessaires
    ---[ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory]
    local count = recipe_energy / (recipe.factory.speed * recipe.base_time)
    if recipe.factory.speed == 0 then count = 0 end
    recipe.factory.amount = count
    ---calcul des totaux
    if energy_type == "electric" then
        recipe.factory.energy_total = 0
    else
        recipe.factory.energy_total = 0
    end
    recipe.factory.pollution_total = recipe.factory.pollution_amount * recipe.factory.amount * recipe.base_time

    recipe.energy_total = recipe.factory.energy_total
    recipe.pollution_amount = recipe.factory.pollution_total * recipe_prototype:getEmissionsMultiplier()
    ---arrondi des valeurs
    recipe.factory.speed = recipe.factory.speed
    recipe.factory.energy = math.ceil(recipe.factory.energy)

    if recipe.beacons then
        for _, beacon in pairs(recipe.beacons) do
            beacon.energy_total = 0
            beacon.energy = 0
        end
    end
    
    recipe.time = 1
end

-------------------------------------------------------------------------------
---Compute resources
---@param model table
function ModelCompute.computeResources(model)
    local resources = {}

    ---calcul resource
    for k, ingredient in pairs(model.ingredients) do
        if ingredient.resource_category ~= nil or ingredient.name == "water" then
            local resource = model.resources[ingredient.name]
            if resource ~= nil then
                resource.count = ingredient.count
            else
                resource = Model.newResource(model, ingredient.name, ingredient.type, ingredient.count)
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

            ---compute storage
            if resource.category == "basic-solid" then
                resource.wagon = { type = "item", name = "cargo-wagon" }
                resource.wagon.count = math.ceil(resource.count / 2000)
                resource.wagon.limit_count = math.ceil(resource.wagon.count * ratio)

                resource.storage = { type = "item", name = "steel-chest" }
                resource.storage.count = math.ceil(resource.count / (48 * 50))
                resource.storage.limit_count = math.ceil(resource.storage.count * ratio)
            elseif resource.category == "basic-fluid" then
                --resource.wagon = {type="item", name="cargo-wagon"}
                --resource.wagon.count = math.ceil(resource.count/2000)

                resource.storage = { type = "item", name = "storage-tank" }
                resource.storage.count = math.ceil(resource.count / 2400)
                resource.storage.limit_count = math.ceil(resource.storage.count * ratio)
            end
            resources[resource.name] = resource
        end
    end
    model.resources = resources
end

return ModelCompute