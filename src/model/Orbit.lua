local SiloRecipes = require "model.SiloRecipes"
local RocketTiming = require "model.RocketTiming"
---@class OrbitDetails
---@field capacity integer Items per full rocket.
---@field parts number
---@field crafts number
---@field crafting_time number Seconds per rocket.
---@field launch_time number Minimum seconds between launches.
---@field cycle_time number Mean seconds between launches at the selected speed.
---@field at_launch_limit boolean
---@field speed_required number

local Orbit = {}

---@param item_name string
---@param silo LuaEntityPrototype?
---@return integer
function Orbit.capacity(item_name, silo)
    local item = prototypes.item[item_name]
    if script.feature_flags.space_travel == false then
        return 0
    end
    if item == nil or item.weight <= 0 or silo == nil or silo.type ~= "rocket-silo" or silo.launch_to_space_platforms == false then
        return 0
    end
    return math.floor(silo.lift_weight / item.weight)
end

---@param silo LuaEntityPrototype?
---@param item_name? string
---@return boolean
function Orbit.canLaunch(silo, item_name)
    return script.feature_flags.space_travel and silo ~= nil and silo.type == "rocket-silo"
        and silo.launch_to_space_platforms and (item_name == nil or Orbit.capacity(item_name, silo) > 0)
        and SiloRecipes.resolve(silo) ~= nil and RocketTiming.getLaunchTicks(silo, "normal") ~= nil
end

---@param item_name? string
---@return table<string, LuaEntityPrototype>
function Orbit.machines(item_name)
    local machines = {}
    if script.feature_flags.space_travel == false then
        return machines
    end
    for name, silo in pairs(prototypes.get_entity_filtered{{filter="type", type="rocket-silo"}}) do
        if not silo.hidden and not silo.has_flag("not-in-made-in") and Orbit.canLaunch(silo, item_name) then
            machines[name] = silo
        end
    end
    return machines
end

---@param factory FactoryData?
---@param item_name string
---@return LuaEntityPrototype?
function Orbit.silo(factory, item_name)
    if factory ~= nil then
        return prototypes.entity[factory.name]
    end
    local _, silo = next(Orbit.machines(item_name))
    return silo
end

---@param name string
---@param factory? FactoryData
---@return table?
function Orbit.recipe(name, factory)
    local item = prototypes.item[name]
    if item == nil then
        return nil
    end
    local silo = Orbit.silo(factory, name)
    if Orbit.capacity(name, silo) == 0 then
        return nil
    end
    local part_recipe = SiloRecipes.resolve(silo, factory and factory.rocket_part_recipe)
    if part_recipe == nil or RocketTiming.getLaunchTicks(silo, "normal") == nil then
        return nil
    end
    local allowed_effects = table.deepcopy(part_recipe.allowed_effects or {})
    allowed_effects.quality = false
    return {name=name, category="helmod-orbit", valid=true, enabled=true, hidden=false,
        localised_name={"helmod_orbit.sent", item.localised_name},
        localised_description={"helmod_orbit.description"},
        group=item.group, subgroup=item.subgroup, order=item.order, energy=1,
        ingredients={{name=name, type="item", amount=1}},
        products={{name=name, type="orbit", amount=1}},
        maximum_productivity=part_recipe.maximum_productivity,
        allowed_effects=allowed_effects, allowed_module_categories=part_recipe.allowed_module_categories}
end

---@param name string
---@param factory FactoryData?
---@param quality? string
---@return table[]
function Orbit.ingredients(name, factory, quality)
    local ingredients = {{name=name, type="item", amount=1, quality=quality or "normal"}}
    local silo = Orbit.silo(factory, name)
    local capacity = Orbit.capacity(name, silo)
    local part_recipe = SiloRecipes.resolve(silo, factory and factory.rocket_part_recipe)
    if capacity == 0 or part_recipe == nil then
        return ingredients
    end
    local productivity = 0
    if factory ~= nil and factory.effects ~= nil then
        productivity = factory.effects.productivity or 0
    end
    local crafts = silo.rocket_parts_required / capacity / (1 + productivity)
    for index, ingredient in pairs(part_recipe.ingredients) do
        local copy = table.deepcopy(ingredient)
        copy.amount = copy.amount * crafts
        if copy.type == "item" then
            copy.quality = part_recipe.get_ingredient_quality(index, silo.fixed_quality or "normal").name
        end
        table.insert(ingredients, copy)
    end
    return ingredients
end

---@param name string
---@param factory FactoryData?
---@return number
function Orbit.energy(name, factory)
    local silo = Orbit.silo(factory, name)
    local capacity = Orbit.capacity(name, silo)
    local part_recipe = SiloRecipes.resolve(silo, factory and factory.rocket_part_recipe)
    if capacity == 0 or part_recipe == nil then
        return 1
    end
    local productivity = 0
    if factory ~= nil and factory.effects ~= nil then
        productivity = factory.effects.productivity or 0
    end
    return part_recipe.energy * silo.rocket_parts_required / capacity / (1 + productivity)
end

---@param recipe RecipeData
---@return OrbitDetails?
function Orbit.details(recipe)
    local factory = recipe.factory
    local silo = Orbit.silo(factory, recipe.name)
    local capacity = Orbit.capacity(recipe.name, silo)
    local part_recipe = SiloRecipes.resolve(silo, factory.rocket_part_recipe)
    if not part_recipe or capacity == 0 then return nil end
    local launch_ticks = RocketTiming.getLaunchTicks(silo, factory.quality or "normal")
    if not launch_ticks then return nil end
    local productivity = 1 + factory.effects.productivity
    local crafting_time = part_recipe.energy * silo.rocket_parts_required / productivity / factory.speed_total
    local launch_time = launch_ticks / 60
    local cycle_time = RocketTiming.getCycleTicks(silo, factory.quality or "normal", crafting_time * 60) / 60
    return {capacity=capacity, parts=silo.rocket_parts_required, crafts=silo.rocket_parts_required / productivity,
        crafting_time=crafting_time, launch_time=launch_time,
        cycle_time=cycle_time, at_launch_limit=cycle_time <= launch_time + 1e-9,
        speed_required=part_recipe.energy * silo.rocket_parts_required / productivity / launch_time}
end

return Orbit
