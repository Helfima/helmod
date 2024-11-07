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
            module_low = 1
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
---Finalize input block
---@param block BlockData
function ModelCompute.createSummaryFactory(block, factory)
    ---summary factory
    local summary_factory = block.summary.factories[factory.name]
    if summary_factory == nil then
        summary_factory = {
            name = factory.name,
            type = factory.type or "entity",
            count = 0,
            count_limit = 0,
            count_deep = 0
        }
        block.summary.factories[factory.name] = summary_factory
    end
    
    local factory_ceil = math.ceil(factory.count)

    summary_factory.count = summary_factory.count + factory_ceil
    summary_factory.count_limit = summary_factory.count
    summary_factory.count_deep = summary_factory.count * block.count_deep

    block.summary.building = block.summary.building + factory_ceil
    block.summary.building_limit = block.summary.building
    block.summary.building_deep = block.summary.building * block.count_deep
    ---summary factory module
    if factory.modules ~= nil then
        for module, value in pairs(factory.modules) do
            local summary_module = block.summary.modules[module]
            if summary_module == nil then
                summary_module = {
                    name = module,
                    type = "item",
                    count = 0,
                    count_limit = 0,
                    count_deep = 0
                }
                block.summary.modules[module] = summary_module
            end
            summary_module.count = summary_module.count + value * factory_ceil
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
    if block.by_factory ~= true and one_block_factor_enable and block.has_input ~= true then
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
    
    block.count_deep = block.count * factor
    local children = block.children
    if children ~= nil and table.size(children) > 0 then
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

                for _, factory in pairs(child.summary.factories) do
                    ModelCompute.createSummaryFactory(block, factory)
                end
                for _, beacon in pairs(child.summary.beacons) do
                    ModelCompute.createSummaryFactory(block, beacon)
                end
                for module_name, module in pairs(child.summary.modules) do
                    local summary_module = block.summary.modules[module_name]
                    if summary_module == nil then
                        summary_module = {
                            name = module_name,
                            type = "item",
                            count = 0,
                            count_limit = 0,
                            count_deep = 0
                        }
                        block.summary.modules[module_name] = summary_module
                    end
                    summary_module.count = summary_module.count + module.count
                    summary_module.count_limit = summary_module.count
                    summary_module.count_deep = summary_module.count * block.count_deep
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

                    ModelCompute.createSummaryFactory(block, recipe.factory)
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

                        ModelCompute.createSummaryFactory(block, beacon)
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
            end
        end

        if ratio_limit > 0 then
            block.count_ratio_limit = ratio_limit
            block.count_limit = ratio_limit
            block.power_limit = block.power * ratio_limit
            block.pollution_limit = block.pollution * ratio_limit
            block.summary.building_limit =  block.summary.building * ratio_limit
            for _, factory in pairs(block.summary.factories) do
                factory.count_limit = factory.count * ratio_limit
            end
            for _, beacon in pairs(block.summary.beacons) do
                beacon.count_limit = beacon.count * ratio_limit
            end
            for _, module in pairs(block.summary.modules) do
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
                    child_elements = recipe_prototype:getIngredients(child.factory)
                    factor = 1
                else
                    child_elements = recipe_prototype:getProducts(child.factory)
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
                child_products = recipe_prototype:getProducts(child.factory)
                child_ingredients = recipe_prototype:getIngredients(child.factory)
            end
            -- prepare products
            for _, lua_product in pairs(child_products) do
                local product_key = Product(lua_product):getTableKey()
                block_products[product_key] = {
                    name = lua_product.name,
                    type = lua_product.type,
                    amount = 0,
                    temperature = lua_product.temperature,
                    minimum_temperature = lua_product.minimum_temperature,
                    maximum_temperature = lua_product.maximum_temperature
                }
            end
            -- prepare ingredients
            for _, lua_ingredient in pairs(child_ingredients) do
                local ingredient_key = Product(lua_ingredient):getTableKey()
                block_ingredients[ingredient_key] = {
                    name = lua_ingredient.name,
                    type = lua_ingredient.type,
                    amount = 0,
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
            if block_ingredients[product_key] == nil then
                block_product.state = 1
            else
                block_product.state = 0
            end
        end

        for i, block_ingredient in pairs(block_ingredients) do
            local ingredient_key = Product(block_ingredient):getTableKey()
            -- copy input value
            if block.by_factory ~= true and block.ingredients ~= nil and block.ingredients[ingredient_key] ~= nil then
                block_ingredient.input = block.ingredients[ingredient_key].input
            end
            -- set state
            if block_products[ingredient_key] == nil then
                block_ingredient.state = 1
            else
                block_ingredient.state = 0
            end
        end
        block.products = block_products
        block.ingredients = block_ingredients
    end
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
    local recipe_productivity = Player.getRecipeProductivityBonus(recipe.name)
    factory.effects = { speed = 0, productivity = recipe_productivity, consumption = 0, pollution = 0, quality = 0 }
    if parameters ~= nil then
        factory.effects.speed = factory.effects.speed + (parameters.effects.speed or 0)
        factory.effects.productivity = factory.effects.productivity + (parameters.effects.productivity or 0)
        factory.effects.consumption = factory.effects.consumption + (parameters.effects.consumption or 0)
        factory.effects.pollution = factory.effects.pollution + (parameters.effects.pollution or 0)
        factory.effects.quality = factory.effects.quality + (parameters.effects.quality or 0)
    end
    factory.cap = { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
    local factory_prototype = EntityPrototype(factory)
    local base_effect = factory_prototype:getBaseEffect()
    local base_productivity = base_effect["productivity"] or 0
    factory.effects.productivity = factory.effects.productivity + base_productivity
    ---effet module factory
    if factory.modules ~= nil then
        for module, value in pairs(factory.modules) do
            local speed_bonus = Player.getModuleBonus(module, "speed")
            local productivity_bonus = Player.getModuleBonus(module, "productivity")
            local consumption_bonus = Player.getModuleBonus(module, "consumption")
            local pollution_bonus = Player.getModuleBonus(module, "pollution")
            local quality_bonus = Player.getModuleBonus(module, "quality")
            factory.effects.speed = factory.effects.speed + value * speed_bonus
            factory.effects.productivity = factory.effects.productivity + value * productivity_bonus
            factory.effects.consumption = factory.effects.consumption + value * consumption_bonus
            factory.effects.pollution = factory.effects.pollution + value * pollution_bonus
            factory.effects.quality = factory.effects.quality + value * quality_bonus
        end
    end
    ---effet module beacon
    if recipe.beacons ~= nil then
        local profile_count = 0
        for _, beacon in pairs(recipe.beacons) do
            if beacon.modules ~= nil then
                profile_count = profile_count + beacon.combo
            end
        end
        for _, beacon in pairs(recipe.beacons) do
            if beacon.modules ~= nil then
                for module, value in pairs(beacon.modules) do
                    local prototype_beacon = EntityPrototype(beacon);
                    local speed_bonus = Player.getModuleBonus(module, "speed")
                    local productivity_bonus = Player.getModuleBonus(module, "productivity")
                    local consumption_bonus = Player.getModuleBonus(module, "consumption")
                    local pollution_bonus = Player.getModuleBonus(module, "pollution")
                    local quality_bonus = Player.getModuleBonus(module, "quality")
                    local distribution_effectivity = prototype_beacon:getDistributionEffectivity()
                    local profile_effectivity = prototype_beacon:getProfileEffectivity(profile_count)
                    factory.effects.speed = factory.effects.speed + value * speed_bonus * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.productivity = factory.effects.productivity + value * productivity_bonus * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.consumption = factory.effects.consumption + value * consumption_bonus * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.pollution = factory.effects.pollution + value * pollution_bonus * distribution_effectivity * profile_effectivity * beacon.combo
                    factory.effects.quality = factory.effects.quality + value * quality_bonus * distribution_effectivity * profile_effectivity * beacon.combo
                end
            end
        end
    end
    if recipe.type == "resource" then
        local bonus = Player.getForce().mining_drill_productivity_bonus
        factory.effects.productivity = factory.effects.productivity + bonus
    end
    if recipe.type == "technology" then
        local bonus = Player.getForce().laboratory_speed_modifier or 0
        factory.effects.speed = factory.effects.speed + bonus * (1 + factory.effects.speed)
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
    ---cap speed creation maximum de 1 cycle par tick
    ---seulement sur les recipes normaux
    if recipe.type == "recipe" and recipe.time / recipe.factory.speed < 1 / 60 then
        recipe.factory.speed = 60 * recipe.time
        recipe.factory.cap.speed = bit32.bor(recipe.factory.cap.speed, ModelCompute.cap_reason.speed.cycle)
    end

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
        recipe.factory.energy_total = recipe.factory.amount * recipe.factory.energy
        local drain = factory_prototype:getMinEnergyUsage()
        recipe.factory.energy_total = math.ceil(recipe.factory.energy_total + (math.ceil(recipe.factory.amount) * drain))
        recipe.factory.energy = recipe.factory.energy + drain
    end
    ---arrondi des valeurs
    recipe.factory.speed = recipe.factory.speed
    recipe.factory.energy = math.ceil(recipe.factory.energy)

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

    ---effet consumption
    local energy_prototype = factory_prototype:getEnergySource()

    local energy_type = factory_prototype:getEnergyType()
    local gameDay = { day = 12500, dusk = 5000, night = 2500, dawn = 2500 }
    if factory_prototype:getType() == "accumulator" then
        local dark_time = (gameDay.dusk / 2 + gameDay.night + gameDay.dawn / 2)
        --recipe_energy = dark_time
    end
    recipe.factory.energy = factory_prototype:getEnergyConsumption() * (1 + recipe.factory.effects.consumption)

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