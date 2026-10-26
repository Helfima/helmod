local Orbit = require "model.Orbit"
local function near(actual, expected, label)
    assert(math.abs(actual - expected) < 1e-7, label .. ": " .. tostring(actual) .. " / " .. tostring(expected))
end
script.on_init(function()
    EventController.onInit()
    Player.set{name="OrbitTester", index=1, force=game.forces.player, mod_settings=settings.global, admin=true, print=function(message) error(message) end}
    local count = 0
    for name, silo in pairs(prototypes.get_entity_filtered{{filter="type",type="rocket-silo"}}) do
        log("COMPAT SILO " .. name .. " platform=" .. tostring(silo.launch_to_space_platforms))
        if silo.fixed_recipe then
            local model=Model.newModel()
            local _, recipe=ModelBuilder.addRecipeIntoProductionBlock(model,model.block_root,silo.fixed_recipe.name,"recipe")
            Model.setFactory(recipe,name)
            ModelCompute.update(model)
            assert(recipe.factory.count > 0, "rocket construction " .. name)
        end
    end
    for name, silo in pairs(Orbit.machines()) do
        local cargo = prototypes.item["iron-plate"] and "iron-plate" or nil
        if not cargo or Orbit.capacity(cargo,silo)==0 then
            for item in pairs(prototypes.item) do
                if Orbit.capacity(item,silo)>0 then cargo=item; break end
            end
        end
        assert(cargo, "compatible cargo " .. name)
        local model=Model.newModel()
        local block, recipe=ModelBuilder.addRecipeIntoProductionBlock(model,model.block_root,cargo,"orbit")
        Model.setFactory(recipe,name)
        ModelCompute.update(model)
        local output = "orbit/" .. cargo .. "#normal"
        block.products[output].input=60
        ModelCompute.update(model)
        local silos=recipe.factory.count
        local ingredients={}
        for key, ingredient in pairs(block.ingredients) do ingredients[key]=ingredient.amount end
        assert(silos>0 and silos<math.huge, "finite silo count " .. name)
        block.products[output].input=120
        ModelCompute.update(model)
        near(recipe.factory.count,2*silos,"linked silo demand " .. name)
        for key, amount in pairs(ingredients) do near(block.ingredients[key].amount,2*amount,"linked ingredients " .. key) end
        model.parameters.effects.speed=100
        ModelCompute.update(model)
        near(recipe.factory.count,120/recipe.orbit.capacity*recipe.orbit.cycle_time,"launch cap " .. name)
        for quality in pairs(prototypes.quality) do
            recipe.factory.quality=quality
            ModelCompute.update(model)
            assert(recipe.factory.count>0 and recipe.factory.count<math.huge,"quality " .. quality)
        end
        count=count+1
        log("COMPAT ORBIT " .. name .. " capacity=" .. recipe.orbit.capacity .. " launch=" .. recipe.orbit.launch_time)
    end
    local ordinary=0
    for name, proto in pairs(prototypes.recipe) do
        if not proto.hidden and #proto.products>0 and #proto.ingredients>0 then
            local model=Model.newModel()
            local _, recipe=ModelBuilder.addRecipeIntoProductionBlock(model,model.block_root,name,"recipe")
            if recipe.factory and recipe.factory.name then
                ModelCompute.update(model)
                assert(recipe.factory.count>=0 and recipe.factory.count<math.huge,"ordinary recipe " .. name)
                ordinary=ordinary+1
                if ordinary==5 then break end
            end
        end
    end
    assert(ordinary>0,"ordinary recipes")
    log("ORBIT COMPATIBILITY PASSED silos=" .. count .. " recipes=" .. ordinary)
end)
