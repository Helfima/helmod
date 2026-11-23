local Orbit = require "model.Orbit"
local SiloRecipes = require "model.SiloRecipes"

local function near(actual, expected, label)
    assert(math.abs(actual - expected) < 1e-7, label .. ": expected " .. expected .. ", got " .. actual)
end

return function()
    local model = Model.newModel()
    local block, cargo = ModelBuilder.addRecipeIntoProductionBlock(model, model.block_root, "iron-plate", "orbit")
    local machines = RecipePrototype(cargo):getAllowedMachines()
    local silo = assert(machines["test-selectable-silo"], "offer a platform silo with selectable recipes")
    assert(not machines["test-no-part-silo"], "a silo with no construction recipes cannot launch")
    local options = SiloRecipes.options(silo)
    assert(#options.recipes >= 2 and options.byName["test-copper-rocket-part"])
    for _, name in ipairs({"parameter-0", "iron-gear-wheel", "test-fluid-rocket-part", "test-crowded-rocket-part"}) do
        assert(not options.byName[name], "exclude " .. name)
    end
    local surface = game.surfaces.nauvis
    local placed = assert(surface.create_entity{name=silo.name, position={40, 40}, force=game.forces.player})
    for _, name in ipairs({"test-copper-rocket-part", "test-fluid-rocket-part", "test-crowded-rocket-part", "iron-gear-wheel"}) do
        placed.set_recipe(nil)
        placed.set_recipe(name)
        local actual = placed.get_recipe()
        assert((actual ~= nil) == (options.byName[name] ~= nil), "same selection as the placed silo for " .. name)
    end
    placed.destroy()
    local plumbed = assert(machines["test-plumbed-silo"])
    local plumbedOptions = SiloRecipes.options(plumbed)
    assert(plumbedOptions.byName["test-fluid-rocket-part"] and not plumbedOptions.byName["test-indexed-rocket-part"])
    assert(not plumbedOptions.byName["rocket-part"] and SiloRecipes.resolve(plumbed) == plumbedOptions.recipes[1])
    assert(Orbit.details({factory={name="test-no-part-silo"}, name="iron-plate"}) == nil)
    Model.setFactory(cargo, silo.name, "normal")
    assert(SiloRecipes.resolve(silo).name == "rocket-part")
    cargo.factory.rocket_part_recipe = "test-copper-rocket-part"
    local forceRecipe = game.forces.player.recipes[cargo.factory.rocket_part_recipe]
    forceRecipe.productivity_bonus = 0.25
    ModelCompute.update(model)
    local capacity = Orbit.capacity(cargo.name, silo)
    local output = "orbit/iron-plate#normal"
    block.products[output].input = capacity
    ModelCompute.update(model)
    local crafts = silo.rocket_parts_required / 1.25
    near(block.products[output].amount, capacity, "one rocket of cargo per second")
    near(block.ingredients["copper-plate"].amount, 2 * crafts, "part ingredients after research")
    near(cargo.orbit.crafting_time, 4 * crafts / 2, "selected recipe duration")
    near(cargo.factory.count, cargo.orbit.crafting_time, "silos building one rocket/s below the animation limit")
    assert(not block.ingredients["processing-unit"] and not block.products.stone)

    forceRecipe.productivity_bonus = 1
    ModelCompute.update(model)
    near(cargo.factory.effects.productivity, 0.5, "alternate recipe productivity cap")
    near(block.ingredients["copper-plate"].amount, 2 * silo.rocket_parts_required / 1.5, "changed research")
    forceRecipe.productivity_bonus = 0

    local copy = helpers.json_to_table(helpers.table_to_json(model))
    ModelCompute.update(copy)
    near(copy.block_root.ingredients["copper-plate"].amount, 2 * silo.rocket_parts_required, "reopened alternate recipe")
    assert(ModelBuilder.copyFactory(cargo.factory).rocket_part_recipe == forceRecipe.name)
    local oldDefault = table.deepcopy(User.getParameter("default_factory"))
    User.setDefaultFactory(cargo)
    local _, second = ModelBuilder.addRecipeIntoProductionBlock(model, block, "copper-cable", "orbit")
    assert(second.factory.name == silo.name and second.factory.rocket_part_recipe == forceRecipe.name)
    Model.setFactory(second, "rocket-silo")
    ModelBuilder.setFactoryBlock(block, cargo)
    assert(second.factory.name == silo.name and second.factory.rocket_part_recipe == forceRecipe.name)
    User.setParameter("default_factory", oldDefault)
    block.children[second.id] = nil
    cargo.factory.rocket_part_recipe = "removed-recipe"
    ModelCompute.update(model)
    assert(block.ingredients["processing-unit"] and not block.ingredients["copper-plate"], "missing recipe falls back")
    cargo.factory.rocket_part_recipe = forceRecipe.name
    Model.setFactory(cargo, "rocket-silo")
    ModelCompute.update(model)
    assert(not cargo.factory.rocket_part_recipe and block.ingredients["processing-unit"], "fixed silo uses its own recipe")
end
