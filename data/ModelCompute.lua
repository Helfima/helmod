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
---@param model table
function ModelCompute.update(model)
    if model ~= nil and model.blocks ~= nil then
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
                
                ---prepare bloc
                ModelCompute.prepareBlock(block)
                
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

                ModelCompute.computeBlock(block)

                ---consomme les ingredients
                for _, product in pairs(block.products) do
                    local element_key = Product(product):getTableKey()
                    if input[element_key] == nil then
                        input[element_key] = product.count
                    elseif input[element_key] ~= nil then
                        input[element_key] = input[element_key] + product.count
                    end
                end
                ---compte les ingredients
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
---Compute production block
---@param block table
function ModelCompute.computeBlockCleanInput(block)
    local recipes = block.recipes
    if recipes ~= nil then
        if block.input ~= nil then
            ---state = 0 => produit
            ---state = 1 => produit pilotant
            ---state = 2 => produit restant
            for product_name, quantity in pairs(block.input) do
                if block.products[product_name] == nil or not (bit32.band(block.products[product_name].state, 1)) then
                    block.input[product_name] = nil
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Prepare production block
---@param block table
function ModelCompute.prepareBlock(block)
    local recipes = block.recipes
    if recipes ~= nil then
        local block_products = {}
        local block_ingredients = {}
        ---preparation
        for _, recipe in spairs(recipes, function(t, a, b) return t[b].index > t[a].index end) do
            local recipe_prototype = RecipePrototype(recipe)

            for i, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
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
            for i, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
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
        ---preparation state
        ---state = 0 => produit
        ---state = 1 => produit pilotant
        ---state = 2 => produit restant
        for i, block_product in pairs(block_products) do
            local product_key = Product(block_product):getTableKey()
            ---recopie la valeur input
            if block.by_factory ~= true and block.products ~= nil and block.products[product_key] ~= nil then
                block_product.input = block.products[product_key].input
            end
            ---pose le status
            if block_ingredients[product_key] == nil then
                block_product.state = 1
            else
                block_product.state = 0
            end
        end

        for i, block_ingredient in pairs(block_ingredients) do
            local ingredient_key = Product(block_ingredient):getTableKey()
            ---recopie la valeur input
            if block.by_factory ~= true and block.ingredients ~= nil and block.ingredients[ingredient_key] ~= nil then
                block_ingredient.input = block.ingredients[ingredient_key].input
            end
            ---pose le status
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
function ModelCompute.computeBlock(block)
    local recipes = block.recipes
    block.power = 0
    block.count = 1
    block.pollution_total = 0

    if recipes ~= nil then
        local my_solver

        local debug = User.getModGlobalSetting("debug_solver")
        local selected_solvers = { algebra = SolverAlgebra, simplex = SolverSimplex }

        local solver_selected = User.getParameter("solver_selected") or "normal"
        if solver_selected ~= "normal" then
            selected_solvers = { algebra = SolverMatrixAlgebra, simplex = SolverMatrixSimplex }
        end
        if block.solver == true and block.by_factory ~= true then
            my_solver = selected_solvers.simplex()
        else
            my_solver = selected_solvers.algebra()
        end

        my_solver:solve(block, debug)
        
    end
end

--------------------------------------------------------------------------------
---Compute module effects of factory
---@param recipe table
---@return table
function ModelCompute.computeModuleEffects(recipe)
    local factory = recipe.factory
    factory.effects = { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
    factory.cap = { speed = 0, productivity = 0, consumption = 0, pollution = 0 }
    local factory_prototype = EntityPrototype(factory)
    factory.effects.productivity = factory_prototype:getBaseProductivity()
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
    local beacon = recipe.beacon
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
    recipe.factory.pollution = factory_prototype:getPollution() * (1 + recipe.factory.effects.pollution) *
        (1 + recipe.factory.effects.consumption)

    ---compte le nombre de machines necessaires
    ---[ratio recipe] * [effort necessaire du recipe] / ([la vitesse de la factory] * [le temps en second])
    local count = recipe.count * recipe.time / (recipe.factory.speed * recipe.base_time)
    if recipe.factory.speed == 0 then count = 0 end
    recipe.factory.count = count
    if Model.countModulesModel(recipe.beacon) > 0 then
        local variant = recipe.beacon.per_factory or 0
        local constant = recipe.beacon.per_factory_constant or 0
        recipe.beacon.count = count * variant + constant
    else
        recipe.beacon.count = 0
    end
    local beacon_prototype = EntityPrototype(recipe.beacon)
    recipe.beacon.energy = beacon_prototype:getEnergyUsage()
    ---calcul des totaux
    if energy_type ~= "electric" then
        recipe.factory.energy_total = 0
    else
        recipe.factory.energy_total = recipe.factory.count * recipe.factory.energy
        local drain = factory_prototype:getMinEnergyUsage()
        recipe.factory.energy_total = math.ceil(recipe.factory.energy_total + (math.ceil(recipe.factory.count) * drain))
        recipe.factory.energy = recipe.factory.energy + drain
    end
    recipe.factory.pollution_total = recipe.factory.pollution * recipe.factory.count * recipe.base_time

    recipe.beacon.energy_total = math.ceil(recipe.beacon.count * recipe.beacon.energy)
    recipe.energy_total = recipe.factory.energy_total + recipe.beacon.energy_total
    recipe.pollution_total = recipe.factory.pollution_total * recipe_prototype:getEmissionsMultiplier()
    ---arrondi des valeurs
    recipe.factory.speed = recipe.factory.speed
    recipe.factory.energy = math.ceil(recipe.factory.energy)
    recipe.beacon.energy = math.ceil(recipe.beacon.energy)
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

    recipe.beacon.energy_total = 0
    recipe.beacon.energy = 0
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
                    type = "item",
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
            local beacon = recipe.beacon
            if block.summary.beacons[beacon.name] == nil then
                block.summary.beacons[beacon.name] = {
                    name = beacon.name,
                    type = "item",
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

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.updateVersion_0_9_3(model)
    if ModelCompute.versionCompare(model, "0.9.3") then
        Model.resetRules()
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.updateVersion_0_9_12(model)
    if ModelCompute.versionCompare(model, "0.9.12") then
        if model.blocks ~= nil then
            for _, block in pairs(model.blocks) do
                for _, element in pairs(block.products) do
                    if block.input ~= nil and block.input[element.name] ~= nil then
                        element.input = block.input[element.name]
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.updateVersion_0_9_27(model)
    if ModelCompute.versionCompare(model, "0.9.27") then
        ModelCompute.update(model)
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.updateVersion_0_9_35(model)
    if ModelCompute.versionCompare(model, "0.9.35") then
        if model.blocks ~= nil then
            for _, block in pairs(model.blocks) do
                for _, recipe in pairs(block.recipes) do
                    if recipe.beacon ~= nil then
                        recipe.beacon.per_factory = Format.round(1 / recipe.beacon.factory, 3)
                        recipe.beacon.per_factory_constant = 0
                    end
                end
            end
            ModelCompute.update(model)
        end
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
function ModelCompute.check(model)
    if model ~= nil and (model.version == nil or model.version ~= Model.version) then
        ModelCompute.updateVersion_0_9_3(model)
        ModelCompute.updateVersion_0_9_12(model)
        ModelCompute.updateVersion_0_9_27(model)
        ModelCompute.updateVersion_0_9_35(model)
    end
end

-------------------------------------------------------------------------------
---Update model
---@param model table
---@param version string
---@return boolean
function ModelCompute.versionCompare(model, version)
    local vm1, vm2, vm3 = string.match(model.version, "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
    local v1, v2, v3 = string.match(version, "([0-9]+)[.]([0-9]+)[.]([0-9]+)")
    if tonumber(vm1) <= tonumber(v1) and tonumber(vm2) <= tonumber(v2) and tonumber(vm3) < tonumber(v3) then
        Player.print("Helmod information: Model is updated to version " .. Model.version)
        return true
    end
    return false
end

return ModelCompute
