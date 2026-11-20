local rocket_silo_2 = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
rocket_silo_2.name = "rocket-silo-2"
rocket_silo_2.fixed_recipe = nil
data:extend({
    rocket_silo_2
})