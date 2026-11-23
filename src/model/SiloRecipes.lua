local PartRecipe = require "model.launch.PartRecipe"
local SiloRecipes = {}

---@class SiloRecipeOptions
---@field recipes LuaRecipePrototype[] Picker order
---@field byName table<string,LuaRecipePrototype>

---@type table<string,SiloRecipeOptions>
local optionsBySilo = {}

---@param silo LuaEntityPrototype
---@return SiloCraftSlots
local function craftingSlots(silo)
    local slots = {items=silo.ingredient_count, inputs=0, outputs=0}
    local fuel = silo.fluid_energy_source_prototype
    local fuelInput = fuel and fuel.fluid_box
    local fuelOutput = fuel and fuel.output_fluid_box
    for _, box in pairs(silo.fluidbox_prototypes) do
        if (not fuelInput or box.index ~= fuelInput.index) and (not fuelOutput or box.index ~= fuelOutput.index) then
            if box.production_type == "input" then slots.inputs = slots.inputs + 1 end
            if box.production_type == "output" then slots.outputs = slots.outputs + 1 end
        end
    end
    return slots
end

---@param silo LuaEntityPrototype Silo without a fixed recipe
---@return SiloRecipeOptions
function SiloRecipes.options(silo)
    local cached = optionsBySilo[silo.name]
    if cached then return cached end
    local options = {recipes={}, byName={}}
    local filters = {}
    for category in pairs(silo.crafting_categories) do
        table.insert(filters, {filter="category", category=category})
    end
    if #filters > 0 then
        local slots = craftingSlots(silo)
        for name, recipe in pairs(prototypes.get_recipe_filtered(filters)) do
            if not recipe.parameter and not recipe.hidden and PartRecipe.fits(slots, recipe.ingredients, recipe.products) then
                options.byName[name] = recipe
                table.insert(options.recipes, recipe)
            end
        end
        table.sort(options.recipes, function(left, right)
            if left.order ~= right.order then return left.order < right.order end
            return left.name < right.name
        end)
    end
    optionsBySilo[silo.name] = options
    return options
end

---@param silo LuaEntityPrototype?
---@param selected? string
---@return LuaRecipePrototype?
function SiloRecipes.resolve(silo, selected)
    if not silo or silo.type ~= "rocket-silo" then return nil end
    if silo.fixed_recipe then return silo.fixed_recipe end
    local options = SiloRecipes.options(silo)
    return options.byName[selected] or options.byName["rocket-part"] or options.recipes[1]
end

return SiloRecipes
