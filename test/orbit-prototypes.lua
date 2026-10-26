local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
silo.name = "orbit-test-silo"
silo.hidden = true
silo.fixed_recipe = "orbit-test-parts"
silo.rocket_parts_required = 100
silo.rocket_parts_storage_cap = 100
silo.lift_weight = 2000000
silo.rocket_entity = "orbit-test-rocket"
silo.rocket_engine_starting_speed_modifier_per_quality_level = 0
silo.arms_speed_modifier_per_quality_level = 0
silo.rocket_rising_speed_modifier_per_quality_level = 0
local rocket = table.deepcopy(data.raw["rocket-silo-rocket"]["rocket-silo-rocket"])
rocket.name = "orbit-test-rocket"
rocket.rising_speed = rocket.rising_speed * 2
rocket.engine_starting_speed = rocket.engine_starting_speed * 2
local recipe = table.deepcopy(data.raw.recipe["rocket-part"])
recipe.name = "orbit-test-parts"
recipe.energy_required = 2
recipe.ingredients = {{type="item", name="iron-plate", amount=4}}
recipe.results = {{type="item", name="rocket-part", amount=17}}
recipe.maximum_productivity = 0.5
data:extend{silo,rocket,recipe}

local burner = table.deepcopy(silo)
burner.name = "orbit-test-burner"
burner.energy_source = {type="burner", fuel_categories={"nuclear"}, effectivity=1, fuel_inventory_size=1, burnt_inventory_size=1}
data:extend{burner}

local unbuffered = table.deepcopy(silo)
unbuffered.name = "orbit-test-unbuffered"
unbuffered.rocket_parts_storage_cap = 0
data:extend{unbuffered}
