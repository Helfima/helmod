local category = "test-orbit-construction"
data:extend{{type="recipe-category", name=category}}

local silo = table.deepcopy(data.raw["rocket-silo"]["rocket-silo"])
silo.name = "test-selectable-silo"
silo.fixed_recipe = nil
silo.launch_to_space_platforms = true
silo.crafting_categories = {"rocket-building", category}
silo.crafting_speed = 2
silo.ingredient_count = 3

local part = table.deepcopy(data.raw.recipe["rocket-part"])
part.name = "test-copper-rocket-part"
part.localised_name = "Copper rocket construction"
part.categories = {category}
part.enabled = true
part.ingredients = {{type="item", name="copper-plate", amount=2}}
part.results = {{type="item", name="stone", amount=5}}
part.energy_required = 4
part.maximum_productivity = 0.5

local fluid = table.deepcopy(part)
fluid.name = "test-fluid-rocket-part"
fluid.ingredients = {{type="fluid", name="water", amount=1}}
local crowded = table.deepcopy(part)
crowded.name = "test-crowded-rocket-part"
for _, item in ipairs({"stone", "iron-plate", "plastic-bar"}) do
    table.insert(crowded.ingredients, {type="item", name=item, amount=1})
end
local empty = table.deepcopy(silo)
empty.name = "test-no-part-silo"
empty.crafting_categories = {"test-empty-rocket-category"}
data:extend{{type="recipe-category", name="test-empty-rocket-category"}, silo, part, fluid, crowded, empty}

local plumbed = table.deepcopy(silo)
plumbed.name = "test-plumbed-silo"
plumbed.crafting_categories = {category}
plumbed.fluid_boxes = table.deepcopy(data.raw["assembling-machine"]["chemical-plant"].fluid_boxes)
local indexed = table.deepcopy(fluid)
indexed.name = "test-indexed-rocket-part"
indexed.ingredients[1].fluidbox_index = 3
data:extend{plumbed, indexed}
