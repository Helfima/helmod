require "math.Matrix"
require "math.SolverMatrix"
require "math.SolverMatrixAlgebra"
require "math.SolverMatrixSimplex"

require "math.Solver"
require "math.SolverAlgebra"
require "math.SolverSimplex"

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
        model.input = {}
        ModelCompute.updateBlock(model, model.block_root)
        model.version = Model.version
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model ModelData
---@param block BlockData
function ModelCompute.updateBlock(model, block)
    block.time = model.time
    local children = block.recipes

    -- check if block has child
    local _, child = next(children)
    if child == nil then
        -- empty block
        block.ingredients = {}
        block.products = {}
    else
        -- compute block children
        for _, child in spairs(children, defines.sorters.block.sort) do
            local is_block = child.recipes ~= nil
            if is_block then
                ModelCompute.updateBlock(model, child)
            end
        end
        ---prepare block
        ModelCompute.prepareBlockElements(block)

        ModelCompute.prepareBlockObjectives(model, block)

        ModelCompute.computeBlock(block, model.parameters)

        ModelCompute.finalizeInputBlock(model, block)
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.update2(model)
    if model ~= nil and model.blocks ~= nil then
        Model.appendParameters(model)
        ---calcul les blocks
        local input = {}
        for _, block in spairs(model.blocks, function(t, a, b) return t[b].index > t[a].index end) do
            block.time = model.time
            ---premiere recette
            local _, recipe = next(block.recipes)
            if recipe == nil then
                block.ingredients = {}
                block.products = {}
            else
                
                ---prepare block
                ModelCompute.prepareBlockElements(block)
                
                ---state = 0 => produit
                ---state = 1 => produit pilotant
                ---state = 2 => produit restant
                ---prepare input
                if not (block.unlinked) then
                    if block.products == nil then
                        ModelCompute.computeBlock(block)
                    end
                    
                    ---prepare les inputs
                    local factor = -1
                    local block_elements = block.products
                    if block.by_product == false then
                        block_elements = block.ingredients
                        factor = 1
                    end
                    if block_elements ~= nil then
                        for _, element in pairs(block_elements) do
                            local element_key = Product(element):getTableKey()
                            if (element.state ~= nil and element.state == 1) or (block.products_linked ~= nil and block.products_linked[element_key] == true) then
                                if input[element_key] ~= nil then
                                    element.input = (input[element_key] or 0) * factor
                                    --element.state = 0
                                end
                            else
                                element.input = 0
                            end
                        end
                    end
                end

                ModelCompute.computeBlockCleanInput(block)

                
                ModelCompute.computeBlock(block, model.parameters)

                ---consume ingredients
                for _, product in pairs(block.products) do
                    local element_key = Product(product):getTableKey()
                    if input[element_key] == nil then
                        input[element_key] = product.count
                    elseif input[element_key] ~= nil then
                        input[element_key] = input[element_key] + product.count
                    end
                end
                ---count ingredients
                for _, ingredient in pairs(block.ingredients) do
                    local element_key = Product(ingredient):getTableKey()
                    if input[element_key] == nil then
                        input[element_key] = -ingredient.count
                    else
                        input[element_key] = input[element_key] - ingredient.count
                    end
                end
                ---consume energy
                local element_key = "energy"
                if input[element_key] == nil then
                    input[element_key] = -block.power
                else
                    input[element_key] = input[element_key] - block.power
                end
            end
        end

        ModelCompute.computeInputOutput(model)
        ModelCompute.computeResources(model)

        ---genere un bilan
        ModelCompute.createSummary(model)
        model.version = Model.version
    end
end

-------------------------------------------------------------------------------
---Finalize input block
---@param model ModelData
---@param block BlockData
function ModelCompute.finalizeInputBlock(model, block)
    local input = model.input
    ---consume ingredients
    for _, product in pairs(block.products) do
        local element_key = Product(product):getTableKey()
        if input[element_key] == nil then
            input[element_key] = product.count
        elseif input[element_key] ~= nil then
            input[element_key] = input[element_key] + product.count
        end
    end
    ---count ingredients
    for _, ingredient in pairs(block.ingredients) do
        local element_key = Product(ingredient):getTableKey()
        if input[element_key] == nil then
            input[element_key] = -ingredient.count
        else
            input[element_key] = input[element_key] - ingredient.count
        end
    end
    ---consume energy
    local element_key = "energy"
    if input[element_key] == nil then
        input[element_key] = -block.power
    else
        input[element_key] = input[element_key] - block.power
    end
end

-------------------------------------------------------------------------------
---Prepare objectives of block
---@param model ModelData
---@param block BlockData
function ModelCompute.prepareBlockObjectives(model, block)
    -- state = 0 => product
    -- state = 1 => main product
    -- state = 2 => remaining product
    -- prepare input
    if block.products == nil then
        ModelCompute.computeBlock(block)
    end
    
    local objectives_block = {}

    local factor = -1
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
                objective.value = element.input
                objectives_block[element_key] = objective
            end
            -- if (element.state ~= nil and element.state == 1) or (block.products_linked ~= nil and block.products_linked[element_key] == true) then
            --     local input = model.input
            --     if input[element_key] ~= nil then
            --         element.input = (input[element_key] or 0) * factor
            --     end
            -- else
            --     element.input = 0
            -- end
        end
    end
    -- if empty objectives create from the children
    if table.size(objectives_block) == 0 then
        local children = block.recipes
        for _, child in spairs(children, defines.sorters.block.sort) do
            local is_block = child.recipes ~= nil
            local child_products = nil
            if is_block then
                child_products = child.products
                for _, lua_product in pairs(child_products) do
                    local product = Product(lua_product)
                    local element_key = product:getTableKey()
                    local count = lua_product.count
                    local objective = {}
                    objective.key = element_key
                    objective.value = count
                    objectives_block[element_key] = objective
                end
            else
                local recipe_prototype = RecipePrototype(child)
                child_products = recipe_prototype:getProducts(child.factory)
                for _, lua_product in pairs(child_products) do
                    local product = Product(lua_product)
                    local element_key = product:getTableKey()
                    local count = product:getAmount(child)
                    local objective = {}
                    objective.key = element_key
                    objective.value = count
                    objectives_block[element_key] = objective
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
    local children = block.recipes
    if children ~= nil then
        local block_products = {}
        local block_ingredients = {}
        -- prepare
        for _, child in spairs(children, defines.sorters.block.sort) do
            local is_block = child.recipes ~= nil
            local child_products = nil
            local child_ingredients = nil
            if is_block then
                child_products = child.products
                child_ingredients = child.products
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
                    count = 0,
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
                    count = 0,
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
    local recipes = block.recipes
    block.power = 0
    block.count = 1
    block.pollution_total = 0

    if recipes ~= nil then
        local my_solver

        local debug = User.getModGlobalSetting("debug_solver")
        local selected_solvers = { algebra = SolverAlgebra, simplex = SolverSimplex }

        local solver_selected = User.getParameter("solver_selected") or defines.constant.default_solver
        if solver_selected ~= defines.constant.solvers.normal then
            selected_solvers = { algebra = SolverMatrixAlgebra, simplex = SolverMatrixSimplex }
        end
        if block.solver == true and block.by_factory ~= true then
            my_solver = selected_solvers.simplex()
        else
            my_solver = selected_solvers.algebra()
        end

        my_solver:solve(block, parameters, debug)
        
    end
end

--------------------------------------------------------------------------------
---Compute module effects of factory
---@param recipe RecipeData
---@param parameters ParametersData
---@return RecipeData
function ModelCompute.computeModuleEffects(recipe, parameters)
    local factory = recipe.factory
    factory.effects = { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
    if parameters ~= nil then
        factory.effects.speed = parameters.effects.speed
        factory.effects.productivity = parameters.effects.productivity
        factory.effects.consumption = parameters.effects.consumption
        factory.effects.pollution = parameters.effects.pollution
    end
    factory.cap = { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
    local factory_prototype = EntityPrototype(factory)
    factory.effects.productivity = factory.effects.productivity + factory_prototype:getBaseProductivity()
    ---effet module factory
    if factory.modules ~= nil then
        for module, value in pairs(factory.modules) do
            local speed_bonus = Player.getModuleBonus(module, "speed")
            local productivity_bonus = Player.getModuleBonus(module, "productivity")
            local consumption_bonus = Player.getModuleBonus(module, "consumption")
            local pollution_bonus = Player.getModuleBonus(module, "pollution")
            factory.effects.speed = factory.effects.speed + value * speed_bonus
            factory.effects.productivity = factory.effects.productivity + value * productivity_bonus
            factory.effects.consumption = factory.effects.consumption + value * consumption_bonus
            factory.effects.pollution = factory.effects.pollution + value * pollution_bonus
        end
    end
    ---effet module beacon
    if recipe.beacons ~= nil then
        for _, beacon in pairs(recipe.beacons) do
            if beacon.modules ~= nil then
                for module, value in pairs(beacon.modules) do
                    local speed_bonus = Player.getModuleBonus(module, "speed")
                    local productivity_bonus = Player.getModuleBonus(module, "productivity")
                    local consumption_bonus = Player.getModuleBonus(module, "consumption")
                    local pollution_bonus = Player.getModuleBonus(module, "pollution")
                    local distribution_effectivity = EntityPrototype(beacon):getDistributionEffectivity()
                    factory.effects.speed = factory.effects.speed + value * speed_bonus * distribution_effectivity * beacon
                    .combo
                    factory.effects.productivity = factory.effects.productivity +
                        value * productivity_bonus * distribution_effectivity * beacon.combo
                    factory.effects.consumption = factory.effects.consumption +
                        value * consumption_bonus * distribution_effectivity * beacon.combo
                    factory.effects.pollution = factory.effects.pollution +
                        value * pollution_bonus * distribution_effectivity * beacon.combo
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
    local count = recipe.count * recipe.time / (recipe.factory.speed * recipe.base_time)
    if recipe.factory.speed == 0 then count = 0 end
    recipe.factory.count = count

    if energy_type ~= "electric" then
        recipe.factory.energy_total = 0
    else
        recipe.factory.energy_total = recipe.factory.count * recipe.factory.energy
        local drain = factory_prototype:getMinEnergyUsage()
        recipe.factory.energy_total = math.ceil(recipe.factory.energy_total + (math.ceil(recipe.factory.count) * drain))
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
                local constant = beacon.per_factory_constant or 0
                beacon.count = count * variant + constant
            else
                beacon.count = 0
            end
            local beacon_prototype = EntityPrototype(beacon)
            beacon.energy = beacon_prototype:getEnergyUsage()
            beacon.energy_total = math.ceil(beacon.count * beacon.energy)
            beacon.energy = math.ceil(beacon.energy)
            beacons_energy_total = beacons_energy_total + beacon.energy_total
        end
    end

    --- totaux
    recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * recipe.base_time
    recipe.pollution_total = recipe.factory.pollution_total * recipe_prototype:getEmissionsMultiplier()
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
    recipe.factory.pollution = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution)

    ---compte le nombre de machines necessaires
    ---[ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory]
    local count = recipe.count * recipe_energy / (recipe.factory.speed * recipe.base_time)
    if recipe.factory.speed == 0 then count = 0 end
    recipe.factory.count = count
    ---calcul des totaux
    if energy_type == "electric" then
        recipe.factory.energy_total = 0
    else
        recipe.factory.energy_total = 0
    end
    recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * recipe.base_time

    recipe.energy_total = recipe.factory.energy_total
    recipe.pollution_total = recipe.factory.pollution_total * recipe_prototype:getEmissionsMultiplier()
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
---Compute input and output
---@param model table
function ModelCompute.computeInputOutput(model)
    model.products = {}
    model.ingredients = {}

    local index = 1
    for _, element in spairs(model.blocks, function(t, a, b) return t[b].index > t[a].index end) do
        ---count product
        if element.products ~= nil and table.size(element.products) then
            for key, product in pairs(element.products) do
                if model.products[key] == nil then
                    model.products[key] = Model.newIngredient(product.name, product.type)
                    model.products[key].temperature = product.temperature
                    model.products[key].minimum_temperature = product.minimum_temperature
                    model.products[key].maximum_temperature = product.maximum_temperature
                    model.products[key].index = index
                    index = index + 1
                end
                model.products[key].count = model.products[key].count + product.count
            end
        end
        ---count ingredient
        if element.ingredients ~= nil and table.size(element.ingredients) then
            for key, ingredient in pairs(element.ingredients) do
                if model.ingredients[key] == nil then
                    model.ingredients[key] = Model.newIngredient(ingredient.name, ingredient.type)
                    model.ingredients[key].temperature = ingredient.temperature
                    model.ingredients[key].minimum_temperature = ingredient.minimum_temperature
                    model.ingredients[key].maximum_temperature = ingredient.maximum_temperature
                    model.ingredients[key].index = index
                    index = index + 1
                end
                model.ingredients[key].count = model.ingredients[key].count + ingredient.count
            end
        end
    end

    for _, element in spairs(model.blocks, function(t, a, b) return t[b].index > t[a].index end) do
        ---consomme les produits
        if element.ingredients ~= nil and table.size(element.ingredients) then
            for key, ingredient in pairs(element.ingredients) do
                if element.mining_ingredient ~= ingredient.name then
                    if model.products[key] ~= nil then
                        model.products[key].count = model.products[key].count - ingredient.count
                    end
                end
            end
        end
        ---consomme les ingredients
        if element.products ~= nil and table.size(element.products) then
            for key, product in pairs(element.products) do
                if model.ingredients[key] ~= nil then
                    model.ingredients[key].count = model.ingredients[key].count - product.count
                end
            end
        end
    end

    for key, ingredient in pairs(model.ingredients) do
        if ingredient.count < 0.01 then
            model.ingredients[key] = nil
        end
    end

    for key, product in pairs(model.products) do
        if product.count < 0.01 then
            model.products[key] = nil
        end
    end
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

-------------------------------------------------------------------------------
---Compute energy, speed, number total
---@param model table
function ModelCompute.createSummary(model)
    model.summary = {}
    model.summary.factories = {}
    model.summary.beacons = {}
    model.summary.modules = {}
    model.summary.building = 0
    local energy = 0
    local pollution = 0
    local building = 0

    for _, block in pairs(model.blocks) do
        energy = energy + block.power
        pollution = pollution + (block.pollution_total or 0)
        ModelCompute.computeSummaryFactory(block)
        building = building + block.summary.building
        for _, type in pairs({ "factories", "beacons", "modules" }) do
            for _, element in pairs(block.summary[type]) do
                if model.summary[type][element.name] == nil then
                    model.summary[type][element.name] = {
                        name = element.name,
                        type = "item",
                        count = 0
                    }
                end
                model.summary[type][element.name].count = model.summary[type][element.name].count + element.count
            end
        end
    end
    model.summary.energy = energy
    model.summary.pollution = pollution
    model.summary.building = building

    model.generators = {}
    ---formule 20 accumulateur /24 panneau solaire/1 MW
    model.generators["accumulator"] = { name = "accumulator", type = "item",
        count = 20 * math.ceil(energy / (1000 * 1000)) }
    model.generators["solar-panel"] = { name = "solar-panel", type = "item",
        count = 24 * math.ceil(energy / (1000 * 1000)) }
    model.generators["steam-engine"] = { name = "steam-engine", type = "item", count = math.ceil(energy / (510 * 1000)) }
end

-------------------------------------------------------------------------------
---Compute summary factory
---@param block table
function ModelCompute.computeSummaryFactory(block)
    if block ~= nil then
        block.summary = { building = 0, factories = {}, beacons = {}, modules = {} }
        for _, recipe in pairs(block.recipes) do
            ---calcul nombre factory
            local factory = recipe.factory
            if block.summary.factories[factory.name] == nil then
                block.summary.factories[factory.name] = {
                    name = factory.name,
                    type = factory.type or "entity",
                    count = 0
                }
            end
            block.summary.factories[factory.name].count = block.summary.factories[factory.name].count +
                math.ceil(factory.count)
            block.summary.building = block.summary.building + math.ceil(factory.count)
            ---calcul nombre de module factory
            if factory.modules ~= nil then
                for module, value in pairs(factory.modules) do
                    if block.summary.modules[module] == nil then
                        block.summary.modules[module] = {
                            name = module,
                            type = "item",
                            count = 0
                        }
                    end
                    block.summary.modules[module].count = block.summary.modules[module].count +
                    value * math.ceil(factory.count)
                end
            end
            ---calcul nombre beacon
            local beacons = recipe.beacons
            if beacons ~= nil then
                for _, beacon in pairs(beacons) do
                    if block.summary.beacons[beacon.name] == nil then
                        block.summary.beacons[beacon.name] = {
                            name = beacon.name,
                            type = beacon.type or "entity",
                            count = 0
                        }
                    end
                    block.summary.beacons[beacon.name].count = block.summary.beacons[beacon.name].count + math.ceil(beacon.count)
                    block.summary.building = block.summary.building + math.ceil(beacon.count)
                    ---calcul nombre de module beacon
                    if beacon.modules ~= nil then
                        for module, value in pairs(beacon.modules) do
                            if block.summary.modules[module] == nil then
                                block.summary.modules[module] = {
                                    name = module,
                                    type = "item",
                                    count = 0
                                }
                            end
                            block.summary.modules[module].count = block.summary.modules[module].count +
                            value * math.ceil(beacon.count)
                        end
                    end
                end
            end
        end
    end
end

return ModelCompute
