local Orbit = require "model.Orbit"
script.on_init(function()
 assert(script.feature_flags.space_travel == false, "base-only feature flag")
    EventController.onInit()
    Player.set{name="OrbitTester", index=1, force=game.forces.player, mod_settings=settings.global, admin=true, print=function(message) error(message) end}
    assert(next(Orbit.machines()) == nil, "orbital shipping requires a platform-capable silo")
    for _, target in pairs({{"iron-gear-wheel", "recipe"}, {"automation", "technology"}, {"satellite", "rocket"}}) do
        local model=Model.newModel()
        local _,recipe=ModelBuilder.addRecipeIntoProductionBlock(model,model.block_root,target[1],target[2])
        ModelCompute.update(model)
        assert(recipe.factory.count > 0, "existing recipe calculation")
    end
    log("ORBIT TESTS PASSED")
end)
