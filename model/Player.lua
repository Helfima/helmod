-------------------------------------------------------------------------------
---Description of the module.
---@class Player
local Player = {
    ---single-line comment
    classname = "HMPlayer"
}

local Lua_player = nil

-------------------------------------------------------------------------------
---Print message
function Player.print(...)
    if Lua_player ~= nil then
        Lua_player.print(table.concat({ ... }, " "))
    end
end

-------------------------------------------------------------------------------
---Repport error
function Player.getStorageDebug()
    if storage.debug == nil then
        storage.debug = {}
    end
    return storage.debug
end
-------------------------------------------------------------------------------
---Repport error
---@param error string
function Player.repportError(error)
    Player.print(error)
    log(error)
    local error_message = {}
    table.insert(error_message, error)
    
    local storage_debug = Player.getStorageDebug()
    storage_debug[Lua_player.index] = table.concat(error_message, "\n")
end

-------------------------------------------------------------------------------
---Get last error
function Player.getLastError()
    local storage_debug = Player.getStorageDebug()
    return storage_debug[Lua_player.index]
end

-------------------------------------------------------------------------------
---Load factorio player
---@param event LuaEvent
---@return Player
function Player.load(event)
    Lua_player = game.players[event.player_index]
    return Player
end

-------------------------------------------------------------------------------
---Load factorio player by name or first
---@param player_name string
---@return Player
function Player.try_load_by_name(player_name)
    for _, player in pairs(game.players) do
        if Lua_player == nil then
            Lua_player = player
        end
        if player.name == player_name then
            Lua_player = player
            break
        end
    end
    return Player
end

-------------------------------------------------------------------------------
---Set factorio player
---@param player LuaPlayer
---@return Player
function Player.set(player)
    Lua_player = player
    return Player
end

-------------------------------------------------------------------------------
---Get game day
---@return number, number, number, number
function Player.getGameDay()
    local surface = game.surfaces[1]
    local day = surface.ticks_per_day
    local dusk = surface.evening - surface.dusk
    local night = surface.morning - surface.evening
    local dawn = surface.dawn - surface.morning
    return day, day * dusk, day * night, day * dawn
end

------------------------------------------------------------------------------
---Get display sizes
---@return number, number, number
function Player.getDisplaySizes()
    if Lua_player == nil or not Lua_player.valid then return 800, 600, 1 end
    local display_resolution = Lua_player.display_resolution
    local display_scale = Lua_player.display_scale
    return display_resolution.width, display_resolution.height, display_scale
end

-------------------------------------------------------------------------------
---Set pipette
---@param entity any
---@return any
function Player.setPipette(entity)
    if Lua_player == nil then return nil end
    return Lua_player.pipette_entity(entity)
end

-------------------------------------------------------------------------------
---Get character crafting speed
---@return number
function Player.getCraftingSpeed()
    if Lua_player == nil then return 0 end
    return 1 + Lua_player.character_crafting_speed_modifier
end

-------------------------------------------------------------------------------
---Get main inventory
---@return any
function Player.getMainInventory()
    if Lua_player == nil then return nil end
    return Lua_player.get_main_inventory()
end

-------------------------------------------------------------------------------
---Begin Crafting
---@param item string
---@param count number
function Player.beginCrafting(item, count)
    if Lua_player == nil then return nil end
    local filters = { { filter = "has-product-item", elem_filters = { { filter = "name", name = item } } } }
    local recipes = prototypes.get_recipe_filtered(filters)
    if recipes ~= nil and table.size(recipes) > 0 then
        local first_recipe = Model.firstChild(recipes)
        local craft = { count = math.ceil(count), recipe = first_recipe.name, silent = false }
        Lua_player.begin_crafting(craft)
    else
        Player.print("No recipe found for this craft!")
    end
end

-------------------------------------------------------------------------------
---Get smart tool
---@return LuaItemStack
function Player.getSmartTool(entities)
    if Lua_player == nil then
        return nil
    end
    local script_inventory = game.create_inventory(1)
    local tool_stack = script_inventory[1]
    tool_stack.set_stack({ name = "blueprint" })
    tool_stack.set_blueprint_entities(entities)
    tool_stack.label = "Helmod Smart Tool"

    Lua_player.add_to_clipboard(tool_stack)
    Lua_player.activate_paste()
    script_inventory.destroy()
    return tool_stack
end

-------------------------------------------------------------------------------
---Set smart tool
---@param recipe table
---@param type string
---@param index number
---@return any
function Player.setSmartTool(recipe, type, index)
    if Lua_player == nil or recipe == nil then
        return nil
    end
    local inventory_indexes = {}
    inventory_indexes["beacon"] = defines.inventory.beacon_modules
    inventory_indexes["rocket-silo"] = defines.inventory.rocket_silo_modules
    inventory_indexes["mining-drill"] = defines.inventory.mining_drill_modules
    inventory_indexes["lab"] = defines.inventory.lab_modules
    inventory_indexes["assembling-machine"] = defines.inventory.assembling_machine_modules
    inventory_indexes["furnace"] = defines.inventory.furnace_modules
    local machine = nil
    if index ~= nil then
        machine = recipe[type][index]
    else
        machine = recipe[type]
    end
    local prototype = EntityPrototype(machine)
    local prototype_type = prototype:getType()
    local inventory_index = inventory_indexes[prototype_type] or 0
    local modules = {}
    local stack_index = 0
    for _, module in pairs(machine.modules or {}) do
        local module_key = Model.getQualityElementKey(module)
        local module_amount = module.amount or 0
        if modules[module_key] == nil then modules[module_key] = {id={name=module.name,quality=module.quality},items={in_inventory={}}} end
        for i = 1, module_amount, 1 do
            table.insert(modules[module_key].items.in_inventory,{inventory=inventory_index, stack=stack_index})
            stack_index = stack_index + 1
        end
    end
    local items = {}
    for _, value in pairs(modules) do
        table.insert(items,value)
    end
    local entity = {
        entity_number = 1,
        name = machine.name,
        quality = machine.quality,
        position = { 0, 0 },
        items = items
    }
    if type == "factory" then
        entity.recipe = recipe.name
    end

    Player.getSmartTool({ entity })
end

-------------------------------------------------------------------------------
---Set smart tool
---@param recipe table
---@param type string
---@param index number
---@return any
function Player.setSmartToolConstantCombinator(recipe, type, index)
    if Lua_player == nil or recipe == nil then
        return nil
    end
    local elements = nil
    local recipe_prototype = RecipePrototype(recipe)
    if type == "product" then
        elements = recipe_prototype:getProducts(recipe.factory)
    else
        elements = recipe_prototype:getIngredients(recipe.factory)
    end
    if elements == nil then
        return nil
    end
    local filters = {}
    for id, element in pairs(elements) do
        if index == -1 or id == index then
            local signal_index = 1
            if index == -1 then
                signal_index = id
            end
            local product_prototype = Product(element)
            local count = product_prototype:countProduct(recipe)
            local filter = {
                signal = {
                    type = element.type,
                    name = element.name
                },
                count = math.ceil(count),
                index = signal_index
            }
            table.insert(filters, filter)
        end
    end
    local entity = {
        entity_number = 1,
        name = "constant-combinator",
        position = { 0, 0 },
        control_behavior = {
            filters = filters
        }
    }

    Player.getSmartTool({ entity })
end

-------------------------------------------------------------------------------
---Is valid sprite path
---@param sprite_path string
---@return boolean
function Player.is_valid_sprite_path(sprite_path)
    if Lua_player == nil then return false end
    return helpers.is_valid_sprite_path(sprite_path)
end

-------------------------------------------------------------------------------
---Return factorio player
---@return LuaPlayer
function Player.native()
    return Lua_player
end

-------------------------------------------------------------------------------
---Return player name or unknown
---@return string
function Player.getName()
    local player_name = "unknown"
    if Lua_player ~= nil then
        player_name = Lua_player.name
    end
    return player_name
end

-------------------------------------------------------------------------------
---Return admin player
---@return boolean
function Player.isAdmin()
    return Lua_player.admin
end

-------------------------------------------------------------------------------
---Get gui
---@param location string
---@return LuaGuiElement
function Player.getGui(location)
    return Lua_player.gui[location]
end

-------------------------------------------------------------------------------
---Return force's player
---@return LuaForce
function Player.getForce()
    return Lua_player.force
end

-------------------------------------------------------------------------------
---Sets the toggle state of the shotcut tool/icon
---@param state boolean
function Player.setShortcutState(state)
    if Lua_player ~= nil then
        Lua_player.set_shortcut_toggled("helmod-shortcut", state)
    end
end

-------------------------------------------------------------------------------
---Return item type
---@param element LuaPrototype
---@return string
function Player.getItemIconType(element)
    local item = Player.getItemPrototype(element.name)
    if item ~= nil then
        return "item"
    end
    local fluid = Player.getFluidPrototype(element.name)
    if fluid ~= nil then
        return "fluid"
    else
        return "item"
    end
end

-------------------------------------------------------------------------------
---Return localised name
---@param element LuaPrototype
---@return string|table
function Player.getLocalisedName(element)
    local localisedName = element.name
    if element.type ~= nil then
        if element.type == "recipe" or element.type == "recipe-burnt" then
            local recipe = Player.getPlayerRecipe(element.name)
            if recipe ~= nil then
                localisedName = recipe.localised_name
            end
        elseif element.type == "technology" then
            local technology = Player.getPlayerTechnology(element.name)
            if technology ~= nil then
                localisedName = technology.localised_name
            end
        elseif element.type == "entity" or element.type == "resource" then
            local item = Player.getEntityPrototype(element.name)
            if item ~= nil then
                localisedName = item.localised_name
            end
        elseif element.type == 0 or element.type == "item" then
            local item = Player.getItemPrototype(element.name)
            if item ~= nil then
                localisedName = item.localised_name
            end
        elseif element.type == 1 or element.type == "fluid" then
            local item = Player.getFluidPrototype(element.name)
            if item ~= nil then
                if element.temperature then
                    localisedName = { "helmod_common.fluid-temperature", item.localised_name, element.temperature }
                elseif (element.minimum_temperature and (element.minimum_temperature >= -1e300)) and (element.maximum_temperature and (element.maximum_temperature <= 1e300)) then
                    localisedName = { "helmod_common.fluid-temperature-range", item.localised_name, element
                        .minimum_temperature, element.maximum_temperature }
                elseif (element.minimum_temperature and (element.minimum_temperature >= -1e300)) then
                    localisedName = { "helmod_common.fluid-temperature-min", item.localised_name, element
                        .minimum_temperature }
                elseif (element.maximum_temperature and (element.maximum_temperature <= 1e300)) then
                    localisedName = { "helmod_common.fluid-temperature-max", item.localised_name, element
                        .maximum_temperature }
                else
                    localisedName = item.localised_name
                end
            end
        elseif element.type == "energy" then
            localisedName = { string.format("helmod_common.%s", element.name) }
        end
    end
    return localisedName
end

-------------------------------------------------------------------------------
---Return localised name
---@param prototype LuaPrototype
---@return string|table
function Player.getRecipeLocalisedName(prototype)
    local element = Player.getPlayerRecipe(prototype.name)
    if element ~= nil then
        return element.localised_name
    end
    return prototype.name
end

-------------------------------------------------------------------------------
---Return localised name
---@param prototype LuaPrototype
---@return string|table
function Player.getTechnologyLocalisedName(prototype)
    local element = Player.getPlayerTechnology(prototype.name)
    if element ~= nil then
        return element.localised_name
    end
    return element.name
end

-------------------------------------------------------------------------------
---Return recipes
---@return table
function Player.getPlayerRecipes()
    if Lua_player ~= nil then
        return Player.getForce().recipes
    end
    return {}
end

-------------------------------------------------------------------------------
---Return recipe prototypes
---@return table
function Player.getRecipes()
    return prototypes.recipe
end

-------------------------------------------------------------------------------
---Return recipe productivity
---@return number
function Player.getRecipeProductivityBonus(recipe_name)
    local force = Player.getForce()
    local recipe_force = force.recipes[recipe_name]
    if recipe_force == nil then return 0 end
    return recipe_force.productivity_bonus or 0
end

-------------------------------------------------------------------------------
---Return technologie prototypes
---@param filters table
---@return table
function Player.getTechnologies(filters)
    if filters ~= nil then
        return prototypes.get_technology_filtered(filters)
    end
    return prototypes.technology
end

-------------------------------------------------------------------------------
---Return technology prototype
---@param name string
---@return LuaTechnologyPrototype
function Player.getTechnology(name)
    return prototypes.technology[name]
end

-------------------------------------------------------------------------------
---Return technologies
---@return table
function Player.getPlayerTechnologies()
    if Lua_player ~= nil then
        local technologies = {}
        for _, technology in pairs(Player.getForce().technologies) do
            technologies[technology.name] = technology
        end
        return technologies
    end
    return {}
end

-------------------------------------------------------------------------------
---Return technology
---@param name string
---@return LuaTechnology
function Player.getPlayerTechnology(name)
    if Lua_player ~= nil then
        local technology = Player.getForce().technologies[name]
        return technology
    end
    return nil
end

-------------------------------------------------------------------------------
---Return rule
---@param rule_name string
---@return table, table --rules_included, rules_excluded
function Player.getRules(rule_name)
    local rules_included = {}
    local rules_excluded = {}
    for rule_id, rule in spairs(Model.getRules(), function(t, a, b) return t[b].index > t[a].index end) do
        if script.active_mods[rule.mod] and rule.name == rule_name then
            if rule.excluded then
                if rules_excluded[rule.category] == nil then rules_excluded[rule.category] = {} end
                if rules_excluded[rule.category][rule.type] == nil then rules_excluded[rule.category][rule.type] = {} end
                rules_excluded[rule.category][rule.type][rule.value] = true
            else
                if rules_included[rule.category] == nil then rules_included[rule.category] = {} end
                if rules_included[rule.category][rule.type] == nil then rules_included[rule.category][rule.type] = {} end
                rules_included[rule.category][rule.type][rule.value] = true
            end
        end
    end
    return rules_included, rules_excluded
end

-------------------------------------------------------------------------------
---Return rule
---@param check boolean
---@param rules table
---@param category string
---@param lua_entity table
---@param included boolean
---@return boolean
function Player.checkRules(check, rules, category, lua_entity, included)
    if rules[category] then
        if rules[category]["entity-name"] and (rules[category]["entity-name"]["all"] or rules[category]["entity-name"][lua_entity.name]) then
            check = included
        elseif rules[category]["entity-type"] and (rules[category]["entity-type"]["all"] or rules[category]["entity-type"][lua_entity.type]) then
            check = included
        elseif rules[category]["entity-group"] and (rules[category]["entity-group"]["all"] or rules[category]["entity-group"][lua_entity.group.name]) then
            check = included
        elseif rules[category]["entity-subgroup"] and (rules[category]["entity-subgroup"]["all"] or rules[category]["entity-subgroup"][lua_entity.subgroup.name]) then
            check = included
        end
    end
    return check
end

-------------------------------------------------------------------------------
---Check factory limitation module
---@param module table
---@param lua_recipe RecipeData
---@return boolean
function Player.checkFactoryLimitationModule(module, lua_recipe)
    local factory = lua_recipe.factory
    local factory_prototype = EntityPrototype(factory)
    local factory_module_slots= factory_prototype:getModuleInventorySize()
    if factory_module_slots == 0 then
        return false
    end
    local model_filter_factory_module = User.getModGlobalSetting("model_filter_factory_module")
    if model_filter_factory_module == false then
        return true
    end

    if lua_recipe.type ~= "resource" then
        local module_prototype = ItemPrototype(module)
        local module_effects = module_prototype:getModuleEffects()
        local module_category = module_prototype:getCategory()
        local recipe_prototype = RecipePrototype(lua_recipe)
        local recipe_allowed_effects = recipe_prototype:getAllowedEffects()
        local entity_prototype = EntityPrototype(factory)
        local entity_allowed_effects = entity_prototype:getAllowedEffects()
        local recipe_allowed_module_categories = recipe_prototype:getAllowedModuleCategories()
        local entity_allowed_module_categories = entity_prototype:getAllowedModuleCategories()
        
        for effect_name, value in pairs(module_effects) do
            local positive_effect = Player.checkPositiveEffect(effect_name, value)
            if table.size(recipe_allowed_effects) > 0 then
                local recipe_allowed_effect = recipe_allowed_effects[effect_name]
                if recipe_allowed_effect == false and positive_effect == true then
                    return false
                end
            end
            if table.size(entity_allowed_effects) > 0 then
                local entity_allowed_effect = entity_allowed_effects[effect_name]
                if entity_allowed_effect == false and positive_effect == true then
                    return false
                end
            end
        end
        if recipe_allowed_module_categories ~= nil then
            if not(recipe_allowed_module_categories[module_category])  then
                return false
            end
        end
        if entity_allowed_module_categories ~= nil then
            if not(entity_allowed_module_categories[module_category])  then
                return false
            end
        end
    end
    return true
end

-------------------------------------------------------------------------------
---Get factory limitation message
---@param module table
---@param lua_recipe RecipeData
---@return table | nil
function Player.getFactoryLimitationModuleMessage(module, lua_recipe)
    local factory = lua_recipe.factory
    local factory_prototype = EntityPrototype(factory)
    local factory_module_slots= factory_prototype:getModuleInventorySize()
    if factory_module_slots == 0 then
        return {"helmod_limitation.no-module-slot"}
    end
    local model_filter_factory_module = User.getModGlobalSetting("model_filter_factory_module")
    if model_filter_factory_module == false then
        return nil
    end

    if lua_recipe.type ~= "resource" then
        local module_prototype = ItemPrototype(module)
        local module_effects = module_prototype:getModuleEffects()
        local module_category = module_prototype:getCategory()
        local recipe_prototype = RecipePrototype(lua_recipe)
        local recipe_allowed_effects = recipe_prototype:getAllowedEffects()
        local entity_prototype = EntityPrototype(factory)
        local entity_allowed_effects = entity_prototype:getAllowedEffects()
        local recipe_allowed_module_categories = recipe_prototype:getAllowedModuleCategories()
        local entity_allowed_module_categories = entity_prototype:getAllowedModuleCategories()
        
        for effect_name, value in pairs(module_effects) do
            local positive_effect = Player.checkPositiveEffect(effect_name, value)
            if table.size(recipe_allowed_effects) > 0 then
                local recipe_allowed_effect = recipe_allowed_effects[effect_name]
                if recipe_allowed_effect == false and positive_effect == true then
                    return recipe_prototype:getAllowedEffectMessage(effect_name)
                end
            end
            if table.size(entity_allowed_effects) > 0 then
                local entity_allowed_effect = entity_allowed_effects[effect_name]
                if entity_allowed_effect == false and positive_effect == true then
                    return recipe_prototype:getAllowedEffectMessage(effect_name)
                end
            end
        end
        if recipe_allowed_module_categories ~= nil then
            if not(recipe_allowed_module_categories[module_category])  then
                return {"helmod_limitation.not-allowed-category-module", module_category}
            end
        end
        if entity_allowed_module_categories ~= nil then
            if not(entity_allowed_module_categories[module_category])  then
                return {"helmod_limitation.not-allowed-category-module", module_category}
            end
        end
    end
    return nil
end

local is_effect_positive = {speed=true, productivity=true, quality=true,
                            consumption=false, pollution=false}
function Player.checkPositiveEffect(name, value)
    -- Effects are considered positive if their effect is actually in the 'desirable'
    -- direction, ie. positive speed, or negative pollution
    return (value > 0) == is_effect_positive[name]
end
-------------------------------------------------------------------------------
---Check beacon limitation module
---@param beacon FactoryData
---@param lua_recipe RecipeData
---@param module LuaItemPrototype
---@return boolean
function Player.checkBeaconLimitationModule(beacon, lua_recipe, module)
    local factory = lua_recipe.factory
    local factory_prototype = EntityPrototype(factory)
    local factory_module_slots= factory_prototype:getModuleInventorySize()
    if factory_module_slots == 0 then
        return false
    end
    local model_filter_beacon_module = User.getModGlobalSetting("model_filter_beacon_module")
    if model_filter_beacon_module == false then
        return true
    end

    if lua_recipe.type ~= "resource" then
        local module_prototype = ItemPrototype(module)
        local module_effects = module_prototype:getModuleEffects()
        local module_category = module_prototype:getCategory()
        local recipe_prototype = RecipePrototype(lua_recipe)
        local recipe_allowed_effects = recipe_prototype:getAllowedEffects()
        local entity_prototype = EntityPrototype(beacon)
        local entity_allowed_effects = entity_prototype:getAllowedEffects()
        local recipe_allowed_module_categories = recipe_prototype:getAllowedModuleCategories()
        local entity_allowed_module_categories = entity_prototype:getAllowedModuleCategories()
        
        for effect_name, value in pairs(module_effects) do
            local positive_effect = Player.checkPositiveEffect(effect_name, value)
            if table.size(recipe_allowed_effects) > 0 then
                local recipe_allowed_effect = recipe_allowed_effects[effect_name]
                if recipe_allowed_effect == false and positive_effect == true then
                    return false
                end
            end
            if table.size(entity_allowed_effects) > 0 then
                local entity_allowed_effect = entity_allowed_effects[effect_name]
                if entity_allowed_effect == false and positive_effect == true then
                    return false
                end
            end
        end
        if recipe_allowed_module_categories ~= nil then
            if not(recipe_allowed_module_categories[module_category])  then
                return false
            end
        end
        if entity_allowed_module_categories ~= nil then
            if not(entity_allowed_module_categories[module_category])  then
                return false
            end
        end
    end

    return true
end

-------------------------------------------------------------------------------
---Get beacon limitation message
---@param beacon FactoryData
---@param lua_recipe RecipeData
---@param module LuaItemPrototype
---@return table | nil
function Player.getBeaconLimitationModuleMessage(beacon, lua_recipe, module)
    local factory = lua_recipe.factory
    local factory_prototype = EntityPrototype(factory)
    local factory_module_slots= factory_prototype:getModuleInventorySize()
    if factory_module_slots == 0 then
        return {"helmod_limitation.no-module-slot"}
    end
    local model_filter_beacon_module = User.getModGlobalSetting("model_filter_beacon_module")
    if model_filter_beacon_module == false then
        return nil
    end

    if lua_recipe.type ~= "resource" then
        local module_prototype = ItemPrototype(module)
        local module_effects = module_prototype:getModuleEffects()
        local module_category = module_prototype:getCategory()
        local recipe_prototype = RecipePrototype(lua_recipe)
        local recipe_allowed_effects = recipe_prototype:getAllowedEffects()
        local entity_prototype = EntityPrototype(beacon)
        local entity_allowed_effects = entity_prototype:getAllowedEffects()
        local recipe_allowed_module_categories = recipe_prototype:getAllowedModuleCategories()
        local entity_allowed_module_categories = entity_prototype:getAllowedModuleCategories()
        
        for effect_name, value in pairs(module_effects) do
            local positive_effect = Player.checkPositiveEffect(effect_name, value)
            if table.size(recipe_allowed_effects) > 0 then
                local recipe_allowed_effect = recipe_allowed_effects[effect_name]
                if recipe_allowed_effect == false and positive_effect == true then
                    return recipe_prototype:getAllowedEffectMessage(effect_name)
                end
            end
            if table.size(entity_allowed_effects) > 0 then
                local entity_allowed_effect = entity_allowed_effects[effect_name]
                if entity_allowed_effect == false and positive_effect == true then
                    return recipe_prototype:getAllowedEffectMessage(effect_name)
                end
            end
        end
        if recipe_allowed_module_categories ~= nil then
            if not(recipe_allowed_module_categories[module_category])  then
                return {"helmod_limitation.not-allowed-category-module", module_category}
            end
        end
        if entity_allowed_module_categories ~= nil then
            if not(entity_allowed_module_categories[module_category])  then
                return {"helmod_limitation.not-allowed-category-module", module_category}
            end
        end
    end

    return nil
end

-------------------------------------------------------------------------------
---Return list of productions
---@param category string
---@param lua_recipe table
---@return table
function Player.getProductionsCrafting(category, lua_recipe)
    local productions = {}
    local rules_included, rules_excluded = Player.getRules("production-crafting")
    if category == "crafting-handonly" then
        productions["character"] = prototypes.entity["character"]
    elseif lua_recipe.name ~= nil and category == "fluid" then
        for key, lua_entity in pairs(Player.getOffshorePumps()) do
            productions[lua_entity.name] = lua_entity
        end
    else
        for key, lua_entity in pairs(Player.getProductionMachines()) do
            local check = false
            if category ~= nil then
                if not (rules_included[category]) then
                    ---standard recipe
                    if lua_entity.crafting_categories ~= nil and lua_entity.crafting_categories[category] then
                        local recipe_ingredient_count = RecipePrototype(lua_recipe, "recipe"):getIngredientCount()
                        local factory_ingredient_count = EntityPrototype(lua_entity):getIngredientCount()
                        --- check ingredient limitation
                        if factory_ingredient_count >= recipe_ingredient_count then
                            check = true
                        end
                        ---resolve rule excluded
                        check = Player.checkRules(check, rules_excluded, "standard", lua_entity, false)
                    end
                else
                    ---resolve rule included
                    check = Player.checkRules(check, rules_included, category, lua_entity, true)
                    ---resolve rule excluded
                    check = Player.checkRules(check, rules_excluded, category, lua_entity, false)
                end
            else
                --- take all production if category is nil
                if lua_entity.group ~= nil and lua_entity.group.name == "production" then
                    check = true
                end
            end
            ---resource filter
            if check then
                if lua_recipe.name ~= nil then
                    local lua_entity_filter = Player.getEntityPrototype(lua_recipe.name)
                    if lua_entity_filter ~= nil then
                        if lua_entity.resource_categories ~= nil and not (lua_entity.resource_categories[lua_entity_filter.resource_category]) then
                            check = false
                        elseif lua_entity.type == "mining-drill" and lua_entity_filter.mineable_properties and lua_entity_filter.mineable_properties.required_fluid then
                            local fluidboxes = EntityPrototype(lua_entity):getFluidboxPrototypes()
                            if #fluidboxes == 0 then
                                check = false
                            end
                        end
                    end
                end
            end
            ---ok to add entity
            if check then
                productions[lua_entity.name] = lua_entity
            end
        end
    end
    return productions
end

-------------------------------------------------------------------------------
---Excludes entities that are placed only by a hidden item
---@param entities table
---@return table
function Player.ExcludePlacedByHidden(entities)
    local results = {}

    for entity_name, entity in pairs(entities) do
        local item_filters = {}

        for _, item in pairs(entity.items_to_place_this or {}) do
            if type(item) == "string" then
                table.insert(item_filters, { filter = "name", name = item, mode = "or" })
            elseif item.name then
                table.insert(item_filters, { filter = "name", name = item.name, mode = "or" })
            end
        end

        local show = false

        if #item_filters == 0 then
            -- Has no items to place it. Probably placed by script.
            -- e.g. Numal reef from Py
            show = true
        else
            local items = prototypes.get_item_filtered(item_filters)
            for _, item in pairs(items) do
                if not item.hidden then
                    show = true
                    break
                end
            end
        end

        if show == true then
            results[entity_name] = entity
        end
    end

    return results
end

-------------------------------------------------------------------------------
---Return list of modules
---@return table
function Player.getModules()
    local items = {}
    local filters = {}
    table.insert(filters, { filter = "type", type = "module", mode = "or" })

    for _, item in pairs(prototypes.get_item_filtered(filters)) do
        table.insert(items, item)
    end
    return items
end

-------------------------------------------------------------------------------
---Return list of production machines
---@return table
function Player.getProductionMachines()
    local cache_machines = Cache.getData(Player.classname, "list_machines")
    if cache_machines ~= nil then
        return cache_machines
    end

    local filters = {}
    table.insert(filters, { filter = "crafting-machine", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    table.insert(filters, { filter = "type", type = "lab", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    table.insert(filters, { filter = "type", type = "mining-drill", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    table.insert(filters, { filter = "type", type = "rocket-silo", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    table.insert(filters, { filter = "type", type = "agricultural-tower", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    local entities = prototypes.get_entity_filtered(filters)
    entities = Player.ExcludePlacedByHidden(entities)

    local list_machines = {}
    for prototype_name, lua_prototype in pairs(entities) do
        local machine = { name = lua_prototype.name, group = (lua_prototype.group or {}).name, subgroup = (lua_prototype.subgroup or {})
        .name, type = lua_prototype.type, order = lua_prototype.order, crafting_categories = lua_prototype
        .crafting_categories, resource_categories = lua_prototype.resource_categories }
        table.insert(list_machines, machine)
    end

    Cache.setData(Player.classname, "list_machines", list_machines)
    return list_machines
end

-------------------------------------------------------------------------------
---Return list of energy machines
---@return table
function Player.getEnergyMachines()
    local machines = {}

    local filters = {}
    for _, type in pairs({ "generator", "solar-panel", "accumulator", "reactor", "burner-generator", "electric-energy-interface" }) do
        table.insert(filters, { filter = "type", mode = "or", invert = false, type = type })
        table.insert(filters, { filter = "hidden", mode = "and", invert = true })
        table.insert(filters, { filter = "type", mode = "or", invert = false, type = type })
        table.insert(filters, { filter = "flag", flag = "player-creation", mode = "and" })
    end
    for entity_name, entity in pairs(prototypes.get_entity_filtered(filters)) do
        machines[entity_name] = entity
    end

    machines = Player.ExcludePlacedByHidden(machines)
    return machines
end

-------------------------------------------------------------------------------
---Return list of boilers
---@param fluid_name string
---@return table
function Player.getBoilers(fluid_name)
    local filters = {}
    table.insert(filters, { filter = "type", type = "boiler", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    table.insert(filters, { filter = "type", type = "boiler", mode = "or" })
    table.insert(filters, { filter = "flag", flag = "player-creation", mode = "and" })
    local entities = prototypes.get_entity_filtered(filters)

    entities = Player.ExcludePlacedByHidden(entities)

    if fluid_name == nil then
        return entities
    else
        local boilers = {}
        for boiler_name, boiler in pairs(entities) do
            for _, fluidbox in pairs(boiler.fluidbox_prototypes) do
                if (fluidbox.production_type == "output") and fluidbox.filter and (fluidbox.filter.name == fluid_name) then
                    boilers[boiler_name] = boiler
                    break
                end
            end
        end

        return boilers
    end
end

-------------------------------------------------------------------------------
---Return table of boiler recipes
---@return table
function Player.getBoilersForRecipe(recipe_prototype)
    local boilers = {}

    for boiler_name, boiler in pairs(Player.getBoilers()) do
        ---Check temperature
        if boiler.target_temperature ~= recipe_prototype.output_fluid_temperature then
            goto continue
        end

        ---Check input fluid
        local input_fluid = "water"
        local fluidbox = boiler.fluidbox_prototypes[1]
        if fluidbox.filter then
            input_fluid = fluidbox.filter.name
        end
        if input_fluid ~= recipe_prototype.input_fluid_name then
            goto continue
        end

        ---Check output fluid
        local output_fluid = "steam"
        for _, fluidbox in pairs(boiler.fluidbox_prototypes) do
            if fluidbox.filter and fluidbox.production_type == "output" then
                output_fluid = fluidbox.filter.name
            end
        end
        if output_fluid ~= recipe_prototype.output_fluid_name then
            goto continue
        end

        boilers[boiler_name] = boiler

        ::continue::
    end

    return boilers
end

-------------------------------------------------------------------------------
---Return list of Offshore-Pump
---@return table
function Player.getOffshorePumps()
    local filters = {}
    table.insert(filters, { filter = "type", type = "offshore-pump", mode = "or" })
    local entities = prototypes.get_entity_filtered(filters)
    local offshore_pump = {}
    for key, entity in pairs(entities) do
        offshore_pump[key] = entity
    end
    return offshore_pump
end

-------------------------------------------------------------------------------
---Return module effects
---@param module ModuleData
---@return ModuleEffectsData
function Player.getModuleEffects(module)
    local module_effects = { speed = 0, productivity = 0, consumption = 0, pollution = 0, quality = 0 }
    if module == nil then return module_effects end
    local multiplier = 1
    -- search quality
    local quality = Player.getQualityPrototype(module.quality)
    if quality ~= nil then
        multiplier = multiplier + (quality.level * 0.3)
    end
    -- search module
    local module = Player.getItemPrototype(module.name)
    for effect_name, effect_value in pairs(module.module_effects) do
        local final_value = effect_value
        if Player.checkPositiveEffect(effect_name, effect_value) then
            -- quality has positive effect
            final_value = effect_value * multiplier
        else
            -- quality has no effect
            final_value = effect_value
        end
        -- arround the % value
        final_value = math.floor(final_value*100)/100
        if effect_name == "quality" and final_value > 0 then
            -- fix quality value, in game is 10x
            final_value = final_value / 10
        end
        module_effects[effect_name] = final_value
    end
    return module_effects
end

-------------------------------------------------------------------------------
---Return recipe prototype
---@param name string
---@return LuaRecipe
function Player.getRecipe(name)
    if name == nil then return nil end
    return prototypes.recipe[name]
end

-------------------------------------------------------------------------------
---Return recipe
---@param name string
---@return LuaRecipe
function Player.getPlayerRecipe(name)
    if Lua_player ~= nil then
        return Player.getForce().recipes[name]
    end
    return nil
end

function Player.buildResourceRecipe(entity_prototype)
    local prototype = entity_prototype:native()
    if prototype == nil then return nil end
    local ingredients = {}
    if entity_prototype:getMineableMiningFluidRequired() then
        local fluid_ingredient = { name = entity_prototype:getMineableMiningFluidRequired(), type = "fluid", amount =
        entity_prototype:getMineableMiningFluidAmount() }
        table.insert(ingredients, fluid_ingredient)
    end
    local recipe = {}
    recipe.category = "extraction-machine"
    recipe.enabled = true
    recipe.energy = 1
    recipe.force = {}
    recipe.group = { name = "helmod", order = "zzzz" }
    recipe.subgroup = { name = "helmod-resource", order = "aaaa" }
    recipe.hidden = false
    if prototype then
        if prototype.flags ~= nil then
            recipe.hidden = prototype.hidden or false
        end
        recipe.localised_description = prototype.localised_description
        recipe.localised_name = prototype.localised_name
        recipe.name = prototype.name
    end
    recipe.ingredients = ingredients
    recipe.products = entity_prototype:getMineableMiningProducts()
    recipe.prototype = {}
    recipe.valid = true

    return recipe
end

-------------------------------------------------------------------------------
---Return resource recipes
---@return table
function Player.getResourceRecipes()
    local recipes = {}

    for key, prototype in pairs(prototypes.entity) do
        if prototype.name ~= nil and prototype.resource_category ~= nil then
            local recipe = Player.buildResourceRecipe(EntityPrototype(prototype))
            if recipe ~= nil then
                recipes[recipe.name] = recipe
            end
        end
    end

    return recipes
end

-------------------------------------------------------------------------------
---Return resource recipe
---@param name string
---@return table
function Player.getResourceRecipe(name)
    local entity_prototype = EntityPrototype(name)
    local recipe = Player.buildResourceRecipe(entity_prototype)

    return recipe
end

-------------------------------------------------------------------------------
---Return energy recipe
---@param name string
---@return table
function Player.getEnergyRecipe(name)
    local entity_prototype = EntityPrototype(name)
    local prototype = entity_prototype:native()
    local recipe = {}
    recipe.category = "energy"
    recipe.enabled = true
    recipe.energy = 1
    recipe.force = {}
    recipe.group = { name = "helmod", order = "zzzz" }
    recipe.subgroup = { name = "helmod-energy", order = "dddd" }
    recipe.hidden = false
    if prototype ~= nil and prototype.flags ~= nil then
        recipe.hidden = prototype.hidden or false
    end
    recipe.ingredients = {}
    recipe.products = {}
    recipe.localised_description = prototype.localised_description
    recipe.localised_name = prototype.localised_name
    recipe.name = prototype.name
    recipe.prototype = {}
    recipe.valid = true

    return recipe
end

-------------------------------------------------------------------------------
---Return table of fluid recipes
---@return table
function Player.getFluidRecipes()
    local recipes = {}

    local tiles = Player.getTilePrototypes()
    for _, tile in pairs(tiles) do
        if tile.fluid then
            local recipe = Player.buildFluidRecipe(tile.fluid.name, {}, nil)
            recipe.subgroup = { name = "helmod-fluid", order = "bbbb" }
            if not recipes[tile.fluid.name] then
                recipes[tile.fluid.name] = recipe
            end
            if tile.hidden then
                recipes[tile.fluid.name].hidden = true
            end
        end
    end
    return recipes
end

-------------------------------------------------------------------------------
---Return recipe
---@param name string
---@return table
function Player.getFluidRecipe(name)
    local recipes = Player.getFluidRecipes()
    return recipes[name]
end

-------------------------------------------------------------------------------
---Return table of Agricultural Towers
---@return table
function Player.getAgriculturalTowers()
    local filters = {}
    table.insert(filters, { filter = "type", type = "agricultural-tower", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    table.insert(filters, { filter = "type", type = "agricultural-tower", mode = "or" })
    table.insert(filters, { filter = "flag", flag = "player-creation", mode = "and" })
    local entities = prototypes.get_entity_filtered(filters)

    entities = Player.ExcludePlacedByHidden(entities)
    return entities
end

-------------------------------------------------------------------------------
---Return table filter of Plants for Agricultural Towers
---@return table
function Player.getPlantsFilter()
    local filters = {}
    table.insert(filters, { filter = "type", type = "plant", mode = "or" })
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    return filters
end

-------------------------------------------------------------------------------
---Return table of Plants for Agricultural Towers
---@return table
function Player.getPlants()
    local filters = Player.getPlantsFilter()
    local entities = prototypes.get_entity_filtered(filters)

    entities = Player.ExcludePlacedByHidden(entities)
    return entities
end

-------------------------------------------------------------------------------
---Return table of Seeds for Agricultural Towers
---@return table
function Player.getSeeds()
    local result = {}
    local plants_filters = Player.getPlantsFilter()
    local filters = {}
    table.insert(filters, { filter = "type", type = "item", mode = "or"})
    table.insert(filters, { filter = "plant-result", elem_filters = plants_filters, mode = "and"})
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    local items = prototypes.get_item_filtered(filters)
    return items
end

-------------------------------------------------------------------------------
---Return table of Agricultural recipes for Agricultural Towers
---@return table
function Player.getAgriculturalRecipes()
    local recipes = {}
    local items = Player.getSeeds()
    for _, prototype in pairs(items) do
        local ingredients = { { name = prototype.name, type = "item", amount = 1 } }
        local plant_prototype = prototype.plant_result
        local mineable_properties = plant_prototype.mineable_properties
        local products = mineable_properties.products
        local recipe = {}
        recipe.enabled = true
        recipe.energy = plant_prototype.growth_ticks / 60
        recipe.force = {}
        recipe.group = { name = "helmod", order = "zzzz" }
        recipe.subgroup = { name = "helmod-farming-1", order = "cccc" }
        recipe.hidden = false
        recipe.ingredients = ingredients
        recipe.products = products
        recipe.localised_description = prototype.localised_description
        recipe.localised_name = prototype.localised_name
        recipe.name = prototype.name
        recipe.category = "farming"
        recipe.prototype = {}
        recipe.valid = true

        if not recipes[recipe.name] then
            recipes[recipe.name] = recipe
        end
        if recipe.hidden then
            recipes[recipe.name].hidden = true
        end
    end

    return recipes
end

-------------------------------------------------------------------------------
---Return recipe of Agricultural recipes for Agricultural Towers
---@param name string
---@return table
function Player.getAgriculturalRecipe(name)
    local recipes = Player.getAgriculturalRecipes()
    return recipes[name]
end

-------------------------------------------------------------------------------
---Return table of spoilable items
---@return table
function Player.getSpoilableItems()
    local filters = {}
    table.insert(filters, { filter = "spoil-result", elem_filters = {{ filter = "hidden", mode = "and", invert = true }}, mode = "and"})
    table.insert(filters, { filter = "hidden", mode = "and", invert = true })
    local results = prototypes.get_item_filtered(filters)
    
    return results
end

-------------------------------------------------------------------------------
---Return table of Spoilable recipes
---@return table
function Player.getSpoilableRecipes()
    local recipes = {}
    local items = Player.getSpoilableItems()
    for _, prototype in pairs(items) do
        local ingredients = { { name = prototype.name, type = "item", amount = 1 } }
        local spoil_result = prototype.spoil_result
        local products = {}
        if spoil_result ~= nil then
            local product = { name = spoil_result.name, type = "item", amount = 1 }
            table.insert(products, product)
        else
            local i = 0
        end
        
        local recipe = {}
        recipe.enabled = true
        recipe.energy = prototype.get_spoil_ticks() / 60
        recipe.force = {}
        recipe.group = { name = "helmod", order = "zzzz" }
        recipe.subgroup = { name = "helmod-farming-2", order = "dddd" }
        recipe.hidden = false
        recipe.ingredients = ingredients
        recipe.products = products
        recipe.localised_description = prototype.localised_description
        recipe.localised_name = prototype.localised_name
        recipe.name = prototype.name
        recipe.category = "spoiling"
        recipe.prototype = {}
        recipe.valid = true

        if not recipes[recipe.name] then
            recipes[recipe.name] = recipe
        end
        if recipe.hidden then
            recipes[recipe.name].hidden = true
        end
    end

    return recipes
end

-------------------------------------------------------------------------------
---Return Spoilable recipe
---@param name string
---@return table
function Player.getSpoilableRecipe(name)
    local recipes = Player.getSpoilableRecipes()
    return recipes[name]
end

-------------------------------------------------------------------------------
---Return table of boiler recipes
---@return table
function Player.getBoilerRecipes()
    local recipes = {}

    ---Boilers
    local boilers = Player.getBoilers()

    for boiler_name, boiler in pairs(boilers) do
        local input_fluid = "water"
        local output_fluid = "steam"

        local fluidbox = boiler.fluidbox_prototypes[1]
        if fluidbox.filter then
            input_fluid = fluidbox.filter.name
        end

        for _, fluidbox in pairs(boiler.fluidbox_prototypes) do
            if fluidbox.filter and fluidbox.production_type == "output" then
                output_fluid = fluidbox.filter.name
            end
        end

        if input_fluid ~= nil and output_fluid ~= nil then
            local ingredients = { { name = input_fluid, type = "fluid", amount = 1 } }
            local fluid_prototype = FluidPrototype(output_fluid)
            local recipe = Player.buildFluidRecipe(fluid_prototype, ingredients, boiler.target_temperature, 10)
            recipe.subgroup = { name = "helmod-boiler", order = "cccc" }
            recipe.input_fluid_name = input_fluid
            recipe.output_fluid_name = output_fluid
            recipe.output_fluid_temperature = boiler.target_temperature

            if not recipes[recipe.name] then
                recipes[recipe.name] = recipe
            end
            if boiler.hidden then
                recipes[recipe.name].hidden = true
            end
        end
    end

    return recipes
end

-------------------------------------------------------------------------------
---Return recipe
---@param name string
---@return table
function Player.getBoilerRecipe(name)
    local recipes = Player.getBoilerRecipes()
    return recipes[name]
end

-------------------------------------------------------------------------------
---Return recipe
---@param ingredients table
---@param fluid string|table
---@param temperature number
---@param product_amount? number
---@return table
function Player.buildFluidRecipe(fluid, ingredients, temperature, product_amount)
    local fluid_prototype
    if type(fluid) == "string" then
        fluid_prototype = FluidPrototype(fluid)
    else
        fluid_prototype = fluid
    end

    local prototype = fluid_prototype:native()
    local products = { { name = prototype.name, type = "fluid", amount = product_amount or 1, temperature = temperature } }
    local recipe = {}
    recipe.enabled = true
    recipe.energy = 1
    recipe.force = {}
    recipe.group = { name = "helmod", order = "zzzz" }
    recipe.subgroup = {}
    recipe.hidden = false
    recipe.ingredients = ingredients
    recipe.products = products
    recipe.localised_description = prototype.localised_description
    recipe.localised_name = prototype.localised_name
    if temperature ~= nil then
        recipe.name = string.format("%s#%s", prototype.name, temperature)
    else
        recipe.name = prototype.name
    end
    if #ingredients > 0 then
        recipe.name = string.format("%s->%s", ingredients[1].name, recipe.name)
    end
    recipe.category = recipe.name
    recipe.prototype = {}
    recipe.valid = true

    return recipe
end

function Player.getRocketPartRecipe(factory)
    -- Get rocket silos
    local silos = {}
    if factory and factory.name then
        silos = { prototypes.entity[factory.name] }
    else
        local entity_filters = {
            { filter = "type",   invert = false, mode = "and", type = "rocket-silo" },
            { filter = "hidden", invert = true,  mode = "and" },
        }
        silos = prototypes.get_entity_filtered(entity_filters)
    end

    -- Get rocket silo fixed recipes
    local rocket_part_recipes = {}
    for _, silo_prototype in pairs(silos) do
        if silo_prototype.fixed_recipe then
            table.insert(rocket_part_recipes, prototypes.recipe[silo_prototype.fixed_recipe])
        end
    end

    if #rocket_part_recipes == 0 then
        return nil
    else
        return rocket_part_recipes[1]
    end
end

function Player.buildRocketRecipe(prototype)
    if prototype == nil then return nil end
    local products = prototype.rocket_launch_products
    local ingredients = {}
    local item_prototype = ItemPrototype(prototype.name)
    local stack_size = item_prototype:stackSize()
    table.insert(ingredients, { name = prototype.name, type = "item", amount = 1, constant = true })
    local recipe = {}
    recipe.category = Player.getRocketPartRecipe().category
    recipe.enabled = true
    recipe.energy = 1
    recipe.force = {}
    recipe.group = { name = "helmod", order = "zzzz" }
    recipe.subgroup = { name = "helmod-rocket", order = "eeee" }
    recipe.hidden = false
    recipe.ingredients = ingredients
    for key, product in pairs(products) do
        local product_prototype = ItemPrototype(product.name)
        local i = 0
    end
    recipe.products = products
    recipe.localised_description = prototype.localised_description
    recipe.localised_name = prototype.localised_name
    recipe.name = prototype.name
    recipe.prototype = {}
    recipe.valid = true

    return recipe
end

-------------------------------------------------------------------------------
---Return table of recipe
---@return table
function Player.getRocketRecipes()
    local recipes = {}

    if Player.getRocketPartRecipe() ~= nil then
        for key, item_prototype in pairs(Player.getItemPrototypes()) do
            if item_prototype.rocket_launch_products ~= nil and table.size(item_prototype.rocket_launch_products) > 0 then
                local recipe = Player.buildRocketRecipe(item_prototype)
                recipes[recipe.name] = recipe
            end
        end
    end
    return recipes
end

-------------------------------------------------------------------------------
---Return recipe
---@param name string
---@return table
function Player.getRocketRecipe(name)
    local item_prototype = ItemPrototype(name)
    local prototype = item_prototype:native()
    local recipe = Player.buildRocketRecipe(prototype)

    return recipe
end

-------------------------------------------------------------------------------
---Return recipe
---@param name string
---@return table
function Player.getBurntRecipe(name)
    local recipe_prototype = Player.getRecipe(name)
    local recipe = {}
    recipe.category = recipe_prototype.category
    recipe.enabled = true
    recipe.energy = recipe_prototype.energy
    recipe.force = {}
    recipe.group = { name = "helmod", order = "zzzz" }
    recipe.subgroup = { name = "helmod-recipe-burnt", order = "ffff" }
    recipe.hidden = false
    recipe.ingredients = recipe_prototype.ingredients
    recipe.products = recipe_prototype.products
    recipe.localised_description = recipe_prototype.localised_description
    recipe.localised_name = recipe_prototype.localised_name
    recipe.name = recipe_prototype.name
    recipe.prototype = {}
    recipe.valid = true
    recipe.hidden_from_player_crafting = recipe_prototype.hidden_from_player_crafting

    return recipe
end

-------------------------------------------------------------------------------
---Return list of recipes
---@param element_name string
---@param by_ingredient boolean
---@return table
function Player.searchRecipe(element_name, by_ingredient)
    local recipes = {}
    ---recherche dans les produits des recipes
    for key, recipe in pairs(Player.getPlayerRecipes()) do
        local elements = recipe.products or {}
        if by_ingredient == true then
            elements = recipe.ingredients or {}
        end
        for k, element in pairs(elements) do
            if element.name == element_name then
                table.insert(recipes, { name = recipe.name, type = "recipe" })
                break
            end
        end
    end
    ---recherche dans les resource
    for key, resource in pairs(Player.getResources()) do
        local elements = EntityPrototype(resource):getMineableMiningProducts()
        for key, element in pairs(elements) do
            if element.name == element_name then
                table.insert(recipes, { name = resource.name, type = "resource" })
                break
            end
        end
    end
    -- recherche dans les fluids
    for key, recipe in pairs(Player.getFluidRecipes()) do
      if recipe.name == element_name then
        table.insert(recipes, {name=recipe.name, type="fluid"})
      end
    end
    local boiler_recipes = Player.getBoilerRecipes()
    for key, recipe in pairs(boiler_recipes) do
        local fluid_name = recipe.output_fluid_name
        if by_ingredient == true then
            fluid_name = recipe.input_fluid_name
        end
        if fluid_name == element_name then
            table.insert(recipes, { name = recipe.name, type = "boiler" })
        end
    end
    return recipes
end

-------------------------------------------------------------------------------
---Return entity prototypes
---@param filters table --{{filter="type", mode="or", invert=false type="transport-belt"}}
---@return table
function Player.getEntityPrototypes(filters)
    if filters ~= nil then
        return prototypes.get_entity_filtered(filters)
    end
    return prototypes.entity
end

-------------------------------------------------------------------------------
---Return entity prototype types
---@return table
function Player.getEntityPrototypeTypes()
    local types = {}
    for _, entity in pairs(prototypes.entity) do
        local type = entity.type
        types[type] = true
    end
    return types
end

-------------------------------------------------------------------------------
---Return entity prototype
---@param name string
---@return LuaEntityPrototype
function Player.getEntityPrototype(name)
    if name == nil then return nil end
    return prototypes.entity[name]
end

-------------------------------------------------------------------------------
---Return beacon production
---@return table
function Player.getProductionsBeacon()
    local items = {}
    local filters = {}
    table.insert(filters, { filter = "type", type = "beacon", mode = "or" })
    table.insert(filters, { filter = "hidden", invert = true, mode = "and" })

    table.insert(filters, { filter = "type", type = "beacon", mode = "or" })
    table.insert(filters, { filter = "name", name = "hidden-beacon-turd", mode = "and" })
    for _, item in pairs(prototypes.get_entity_filtered(filters)) do
        table.insert(items, item)
    end
    return items
end

-------------------------------------------------------------------------------
---Return resources list
---@return table
function Player.getResources()
    local cache_resources = Cache.getData(Player.classname, "resources")
    if cache_resources ~= nil then return cache_resources end
    local items = {}
    for _, item in pairs(prototypes.entity) do
        if item.name ~= nil and item.resource_category ~= nil then
            table.insert(items, item)
        end
    end
    Cache.setData(Player.classname, "resources", items)
    return items
end

-------------------------------------------------------------------------------
---Return item prototypes
---@param filters? table --{{filter="fuel-category", mode="or", invert=false,["fuel-category"]="chemical"}}
---@return table
function Player.getItemPrototypes(filters)
    if filters ~= nil then
        return prototypes.get_item_filtered(filters)
    end
    return prototypes.item
end

-------------------------------------------------------------------------------
---Return item prototype types
---@return table
function Player.getItemPrototypeTypes()
    local types = {}
    for _, entity in pairs(prototypes.item) do
        local type = entity.type
        types[type] = true
    end
    return types
end

-------------------------------------------------------------------------------
---Return tile prototypes
---@param filters? table --{{filter="fuel-category", mode="or", invert=false,["fuel-category"]="chemical"}}
---@return table
function Player.getTilePrototypes(filters)
    if filters ~= nil then
        return prototypes.get_tile_filtered(filters)
    end
    return prototypes.tile
end

-------------------------------------------------------------------------------
---Return tile prototype
---@param name string
---@return LuaTilePrototype
function Player.getTilePrototype(name)
    if name == nil then return nil end
    return prototypes.tile[name]
end

-------------------------------------------------------------------------------
---Return item prototype
---@param name string
---@return LuaItemPrototype
function Player.getItemPrototype(name)
    if name == nil then return nil end
    return prototypes.item[name]
end

-------------------------------------------------------------------------------
---Return fluid prototypes
---@param filters table --{{filter="type", mode="or", invert=false type="transport-belt"}}
---@return table
function Player.getFluidPrototypes(filters)
    if filters ~= nil then
        return prototypes.get_fluid_filtered(filters)
    end
    return prototypes.fluid
end

-------------------------------------------------------------------------------
---Return fluid prototype types
---@return table
function Player.getFluidPrototypeTypes()
    local types = {}
    for _, entity in pairs(prototypes.fluid) do
        local type = entity.type
        types[type] = true
    end
    return types
end

-------------------------------------------------------------------------------
---Return fluid prototype subgroups
---@return table
function Player.getFluidPrototypeSubgroups()
    local types = {}
    for _, entity in pairs(prototypes.fluid) do
        local type = entity.subgroup.name
        types[type] = true
    end
    return types
end

-------------------------------------------------------------------------------
---Return fluid prototype
---@param name string
---@return LuaFluidPrototype
function Player.getFluidPrototype(name)
    if name == nil then return nil end
    return prototypes.fluid[name]
end

-------------------------------------------------------------------------------
---Return fluid fuel prototype
---@return table
function Player.getFluidFuelPrototypes()
    local filters = {}
    table.insert(filters, { filter = "hidden", invert = true, mode = "and" })
    table.insert(filters, { filter = "fuel-value", mode = "and", invert = false, comparison = ">", value = 0 })

    local items = {}

    for _, fluid in spairs(Player.getFluidPrototypes(filters), function(t, a, b) return t[b].fuel_value > t[a]
        .fuel_value end) do
        table.insert(items, FluidPrototype(fluid))
    end
    return items
end

-------------------------------------------------------------------------------
---Return items logistic
---@param type string --belt, container or transport
---@return table
function Player.getItemsLogistic(type)
    local filters = {}
    if type == "inserter" then
        filters = { { filter = "type", mode = "or", invert = false, type = "inserter" } }
    elseif type == "belt" then
        filters = { { filter = "type", mode = "or", invert = false, type = "transport-belt" } }
    elseif type == "container" then
        filters = { { filter = "type", mode = "or", invert = false, type = "container" }, { filter = "minable", mode = "and", invert = false }, { filter = "type", mode = "or", invert = false, type = "logistic-container" }, { filter = "minable", mode = "and", invert = false } }
    elseif type == "transport" then
        filters = { { filter = "type", mode = "or", invert = false, type = "cargo-wagon" }, { filter = "type", mode = "or", invert = false, type = "logistic-robot" }, { filter = "type", mode = "or", invert = false, type = "car" } }
    end
    return Player.getEntityPrototypes(filters)
end

-------------------------------------------------------------------------------
---Return default item logistic
---@param entity_type string --belt, container or transport
---@return table
function Player.getDefaultItemLogistic(entity_type)
    local default = User.getParameter(string.format("items_logistic_%s", entity_type))
    if type(default) == "string" then
        default = Model.newElement("entity", default)
        User.setParameter(string.format("items_logistic_%s", entity_type), default)
    end
    if default == nil then
        local logistics = Player.getItemsLogistic(entity_type)
        if logistics ~= nil then
            local logistic = first(logistics)
            default = Model.newElement("entity", logistic.name)
            User.setParameter(string.format("items_logistic_%s", entity_type), default)
        end
    end
    return default
end

-------------------------------------------------------------------------------
---Return fluids logistic
---@param type string --pipe, container or transport
---@return table
function Player.getFluidsLogistic(type)
    local filters = {}
    if type == "pipe" then
        filters = { { filter = "type", mode = "or", invert = false, type = "pipe" } }
    elseif type == "container" then
        filters = { { filter = "type", mode = "or", invert = false, type = "storage-tank" }, { filter = "minable", mode = "and", invert = false } }
    elseif type == "transport" then
        filters = { { filter = "type", mode = "or", invert = false, type = "fluid-wagon" } }
    end
    return Player.getEntityPrototypes(filters)
end

-------------------------------------------------------------------------------
---Return default fluid logistic
---@param entity_type string --pipe, container or transport
---@return table
function Player.getDefaultFluidLogistic(entity_type)
    local default = User.getParameter(string.format("fluids_logistic_%s", entity_type))
    if type(default) == "string" then
        default = Model.newElement("entity", default)
        User.setParameter(string.format("fluids_logistic_%s", entity_type), default)
    end
    if default == nil then
        local logistics = Player.getFluidsLogistic(entity_type)
        if logistics ~= nil then
            default = first(logistics).name
            User.setParameter(string.format("fluids_logistic_%s", entity_type), default)
        end
    end
    return default
end

-------------------------------------------------------------------------------
---Return number
---@param number string
---@return number
function Player.parseNumber(number)
    if number == nil then return 0 end
    local value = string.match(number, "[0-9.]*", 1)
    local power = string.match(number, "[0-9.]*([a-zA-Z]*)", 1)
    if power == nil then
        return tonumber(value)
    elseif string.lower(power) == "kw" then
        return tonumber(value) * 1000
    elseif string.lower(power) == "mw" then
        return tonumber(value) * 1000 * 1000
    elseif string.lower(power) == "gw" then
        return tonumber(value) * 1000 * 1000 * 1000
    elseif string.lower(power) == "kj" then
        return tonumber(value) * 1000
    elseif string.lower(power) == "mj" then
        return tonumber(value) * 1000 * 1000
    elseif string.lower(power) == "gj" then
        return tonumber(value) * 1000 * 1000 * 1000
    end
end

-------------------------------------------------------------------------------
---Return fluid prototypes with temperature
---@param fluid LuaFluidPrototype
---@return table
function Player.getFluidTemperaturePrototypes(fluid)
    -- Find all ways of making this fluid

    local temperatures = {}

    -- Recipes
    local filters = {}
    ---Hidden fluids do need to be included unfortunately. Only real alternative would be to add a setting.
    ---table.insert(filters, {filter = "hidden", invert = true, mode = "and"})
    table.insert(filters, { filter = "has-product-fluid", elem_filters = { { filter = "name", name = fluid.name } }, mode = "and" })
    local recipes = prototypes.get_recipe_filtered(filters)

    for recipe_name, recipe in pairs(recipes) do
        for product_name, product in pairs(recipe.products) do
            if product.name == fluid.name and product.temperature then
                temperatures[product.temperature] = true
            end
        end
    end

    -- Boilers
    local boilers = Player.getBoilers()

    for boiler_name, boiler in pairs(boilers) do
        for _, fluidbox in pairs(boiler.fluidbox_prototypes) do
            if (fluidbox.production_type == "output") and fluidbox.filter and (fluidbox.filter.name == fluid.name) then
                temperatures[boiler.target_temperature] = true
            end
        end
    end

    -- Build result table of FluidPrototype
    local items = {}
    local item
    for temperature, _ in spairs(temperatures, function(t, a, b) return b > a end) do
        item = FluidPrototype(fluid)
        item:setTemperature(temperature)
        table.insert(items, item)
    end

    return items
end

function Player.hasFeatureQuality()
    return script.feature_flags["quality"]
end

-------------------------------------------------------------------------------
---Return quality prototypes
---@return LuaQualityPrototype
function Player.getQualityPrototypes()
    return prototypes.quality
end

-------------------------------------------------------------------------------
---Return quality prototype
---@param name string
---@return LuaQualityPrototype
function Player.getQualityPrototype(name)
    if name == nil then return nil end
    return prototypes.quality[name]
end

return Player
