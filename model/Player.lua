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
    Lua_player.print(table.concat({...}," "))
  end
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
  local dusk = surface.evening-surface.dusk
  local night = surface.morning-surface.evening
  local dawn = surface.dawn-surface.morning
  return day, day*dusk, day*night, day*dawn
end

------------------------------------------------------------------------------
---Get display sizes
---@return number, number
function Player.getDisplaySizes()
  if Lua_player == nil then return 800,600 end
  local display_resolution = Lua_player.display_resolution
  local display_scale = Lua_player.display_scale
  return display_resolution.width/display_scale, display_resolution.height/display_scale
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
  local filters = {{filter = "has-product-item", elem_filters = {{filter = "name", name = item}}}}
  local recipes = game.get_filtered_recipe_prototypes(filters)
  if recipes ~= nil and table.size(recipes) > 0 then
    local first_recipe = Model.firstRecipe(recipes)
    local craft = {count=math.ceil(count),recipe=first_recipe.name,silent=false}
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
  tool_stack.set_stack({name="blueprint"})
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
---@return any
function Player.setSmartTool(recipe, type)  
  if Lua_player == nil or recipe == nil then
    return nil
  end
    local factory = recipe[type]
    local modules = {}
    for name,value in pairs(factory.modules or {}) do
      modules[name] = value
    end
    local entity = {
      entity_number = 1,
      name = factory.name,
      position = {0, 0},
      items = modules
    }
    if type == "factory" then
      entity.recipe = recipe.name
    end

    Player.getSmartTool({entity})
end

-------------------------------------------------------------------------------
---Is valid sprite path
---@param sprite_path string
---@return boolean
function Player.is_valid_sprite_path(sprite_path)
  if Lua_player == nil then return false end
  return Lua_player.gui.is_valid_sprite_path(sprite_path)
end

-------------------------------------------------------------------------------
---Return factorio player
---@return LuaPlayer
function Player.native()
  return Lua_player
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
          localisedName = {"helmod_common.fluid-temperature", item.localised_name, element.temperature}
        elseif (element.minimum_temperature and (element.minimum_temperature >= -1e300)) and (element.maximum_temperature and (element.maximum_temperature <= 1e300)) then
          localisedName = {"helmod_common.fluid-temperature-range", item.localised_name, element.minimum_temperature, element.maximum_temperature}
        elseif (element.minimum_temperature and (element.minimum_temperature >= -1e300)) then
          localisedName = {"helmod_common.fluid-temperature-min", item.localised_name, element.minimum_temperature}
        elseif (element.maximum_temperature and (element.maximum_temperature <= 1e300)) then
          localisedName = {"helmod_common.fluid-temperature-max", item.localised_name, element.maximum_temperature}
        else
          localisedName = item.localised_name
        end
      end
    elseif element.type == "energy" then
      localisedName = {string.format("helmod_common.%s", element.name)}
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
  return game.recipe_prototypes
end

-------------------------------------------------------------------------------
---Return technologie prototypes
---@param filters table
---@return table
function Player.getTechnologies(filters)
  if filters ~= nil then
    return game.get_filtered_technology_prototypes(filters)
  end
  return game.technology_prototypes
end

-------------------------------------------------------------------------------
---Return technology prototype
---@param name string
---@return LuaTechnologyPrototype
function Player.getTechnology(name)
  return game.technology_prototypes[name]
end

-------------------------------------------------------------------------------
---Return technologies
---@return table
function Player.getPlayerTechnologies()
  if Lua_player ~= nil then
    local technologies = {}
    for _,technology in pairs(Player.getForce().technologies) do
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
  for rule_id, rule in spairs(Model.getRules(), function(t,a,b) return t[b].index > t[a].index end) do
    if game.active_mods[rule.mod] and rule.name == rule_name then
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
---@param lua_recipe table
---@return boolean
function Player.checkFactoryLimitationModule(module, lua_recipe)
  local factory = lua_recipe.factory
  if factory.module_slots ==  0 then
    return false
  end

  local rules_included, rules_excluded = Player.getRules("module-limitation")
  local model_filter_factory_module = User.getModGlobalSetting("model_filter_factory_module")
  local allowed = true
  local check_not_bypass = true
  local prototype = RecipePrototype(lua_recipe)
  local category = prototype:getCategory()
  if category == "rocket-building" and lua_recipe.name ~= "rocket-part" then
    local rocket_recipe = RecipePrototype("rocket-part")
    if rocket_recipe.lua_prototype ~= nil then
      rocket_recipe.name = "rocket-part"
      rocket_recipe.factory = lua_recipe.factory
      allowed = Player.checkFactoryLimitationModule(module, rocket_recipe)
      return allowed
    end
    return true
  end
  if rules_excluded[category] == nil then category = "standard" end
  check_not_bypass = Player.checkRules(check_not_bypass, rules_excluded, category, EntityPrototype(factory.name):native(), false)
  if table.size(module.limitations) > 0 and check_not_bypass and model_filter_factory_module == true then
    allowed = false
    for _, recipe_name in pairs(module.limitations) do
      if lua_recipe.name == recipe_name then
        allowed = true
      end
    end
  end

  local allowed_effects = EntityPrototype(factory):getAllowedEffects()
  if allowed_effects ~= nil and model_filter_factory_module == true then
    for _, effect in pairs({"speed", "productivity", "consumption", "pollution"}) do
      if (Player.getModuleBonus(module.name, effect) ~= 0) and (not allowed_effects[effect]) then
        allowed = false
      end
    end
  end

  return allowed
end

-------------------------------------------------------------------------------
---Check beacon limitation module
---@param module table
---@param lua_recipe table
---@return boolean
function Player.checkBeaconLimitationModule(module, lua_recipe)
  local beacon = lua_recipe.beacon
  local allowed = true
  local model_filter_beacon_module = User.getModGlobalSetting("model_filter_beacon_module")

  if table.size(module.limitations) > 0 and model_filter_beacon_module == true then
    allowed = false
    for _, recipe_name in pairs(module.limitations) do
      if lua_recipe.name == recipe_name then
        allowed = true
      end
    end
  end

  local allowed_effects = EntityPrototype(beacon):getAllowedEffects()
  if allowed_effects ~= nil and model_filter_beacon_module == true then
    for _, effect in pairs({"speed", "productivity", "consumption", "pollution"}) do
      if (Player.getModuleBonus(module.name, effect) ~= 0) and (not allowed_effects[effect]) then
        allowed = false
      end
    end
  end

  if beacon.module_slots ==  0 then
    allowed = false
  end
  return allowed
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
    productions["character"] = game.entity_prototypes["character"]
  elseif lua_recipe.name ~= nil and category == "fluid" then
    for key, lua_entity in pairs(Player.getOffshorePumps(lua_recipe.name)) do
      productions[lua_entity.name] = lua_entity
    end
  else
    for key, lua_entity in pairs(Player.getProductionMachines()) do
      local check = false
      if category ~= nil then
        if not(rules_included[category]) then
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
            if lua_entity.resource_categories ~= nil and not(lua_entity.resource_categories[lua_entity_filter.resource_category]) then
              check = false
            elseif lua_entity_filter.mineable_properties and lua_entity_filter.mineable_properties.required_fluid then
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
        table.insert(item_filters, {filter="name", name=item, mode="or"})
      elseif item.name then
        table.insert(item_filters, {filter="name", name=item.name, mode="or"})
      end
    end

    local show = false

    if #item_filters == 0 then
      -- Has no items to place it. Probably placed by script.
      -- e.g. Numal reef from Py
      show = true
    else
      local items = game.get_filtered_item_prototypes(item_filters)
      for _, item in pairs(items) do
        if not item.has_flag("hidden") then
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
  table.insert(filters,{filter="type",type="module",mode="or"})
  table.insert(filters,{filter="flag",flag="hidden",mode="and", invert=true})

  for _,item in pairs(game.get_filtered_item_prototypes(filters)) do
    table.insert(items,item)
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
  table.insert(filters, {filter="crafting-machine", mode="or"})
  table.insert(filters, {filter="hidden", mode="and", invert=true})
  table.insert(filters, {filter="crafting-machine", mode="or"})
  table.insert(filters, {filter="flag", flag="player-creation", mode="and"})
  table.insert(filters, {filter="type", type="lab", mode="or"})
  table.insert(filters, {filter="hidden", mode="and", invert=true})
  table.insert(filters, {filter="type", type="lab", mode="or"})
  table.insert(filters, {filter="flag", flag="player-creation", mode="and"})
  table.insert(filters, {filter="type", type="mining-drill", mode="or"})
  table.insert(filters, {filter="hidden", mode="and", invert=true})
  table.insert(filters, {filter="type", type="mining-drill", mode="or"})
  table.insert(filters, {filter="flag", flag="player-creation", mode="and"})
  table.insert(filters, {filter="type", type="rocket-silo", mode="or"})
  table.insert(filters, {filter="hidden", mode="and", invert=true})
  table.insert(filters, {filter="type", type="rocket-silo", mode="or"})
  table.insert(filters, {filter="flag", flag="player-creation", mode="and"})
  local prototypes = game.get_filtered_entity_prototypes(filters)
  prototypes = Player.ExcludePlacedByHidden(prototypes)
  
  local list_machines = {}
  for prototype_name, lua_prototype in pairs(prototypes) do
    local machine = {name=lua_prototype.name, group=(lua_prototype.group or {}).name, subgroup=(lua_prototype.subgroup or {}).name, type=lua_prototype.type, order=lua_prototype.order, crafting_categories=lua_prototype.crafting_categories, resource_categories=lua_prototype.resource_categories}
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
  for _, type in pairs({"generator", "solar-panel", "accumulator", "reactor", "burner-generator", "electric-energy-interface"}) do
    table.insert(filters, {filter="type", mode="or", invert=false, type=type})
    table.insert(filters, {filter="hidden", mode="and", invert=true})
    table.insert(filters, {filter="type", mode="or", invert=false, type=type})
    table.insert(filters, {filter="flag", flag="player-creation", mode="and"})
  end
  for entity_name, entity in pairs(game.get_filtered_entity_prototypes(filters)) do
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
  table.insert(filters, {filter="type", type="boiler", mode="or"})
  table.insert(filters, {filter="hidden", mode="and", invert=true})
  table.insert(filters, {filter="type", type="boiler", mode="or"})
  table.insert(filters, {filter="flag", flag="player-creation", mode="and"})
  local prototypes = game.get_filtered_entity_prototypes(filters)

  prototypes = Player.ExcludePlacedByHidden(prototypes)

  if fluid_name == nil then
    return prototypes
  else
    local boilers = {}
    for boiler_name, boiler in pairs(prototypes) do
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
    local input_fluid
    local fluidbox = boiler.fluidbox_prototypes[1]
    if fluidbox.filter then
      input_fluid = fluidbox.filter.name
    end
    if input_fluid ~= recipe_prototype.input_fluid_name then
      goto continue
    end

    ---Check output fluid
    local output_fluid
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
---@param fluid_name string
---@return table
function Player.getOffshorePumps(fluid_name)
  local filters = {}
  table.insert(filters, {filter="type", type="offshore-pump", mode="or"})
  local entities = game.get_filtered_entity_prototypes(filters)
  local offshore_pump = {}
  for key, entity in pairs(entities) do
    if entity.fluid.name == fluid_name then
      for _, fluidbox in pairs(entity.fluidbox_prototypes) do
        if #fluidbox.pipe_connections > 0 then
          offshore_pump[key] = entity
          break
        end
      end
    end
  end
  return offshore_pump
end

-------------------------------------------------------------------------------
---Return module bonus (default return: bonus = 0 )
---@param module string
---@param effect string
---@return number
function Player.getModuleBonus(module, effect)
  if module == nil then return 0 end
  local bonus = 0
  ---search module
  local module = Player.getItemPrototype(module)
  if module ~= nil and module.module_effects ~= nil and module.module_effects[effect] ~= nil then
    bonus = module.module_effects[effect].bonus
  end
  return bonus
end

-------------------------------------------------------------------------------
---Return recipe prototype
---@param name string
---@return LuaRecipe
function Player.getRecipe(name)
  if name == nil then return nil end
  return game.recipe_prototypes[name]
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
  local ingredients = {}
  if entity_prototype:getMineableMiningFluidRequired() then
    local fluid_ingredient = {name=entity_prototype:getMineableMiningFluidRequired(), type="fluid", amount=entity_prototype:getMineableMiningFluidAmount()}
    table.insert(ingredients, fluid_ingredient)
  end
  local recipe = {}
  recipe.category = "extraction-machine"
  recipe.enabled = true
  recipe.energy = 1
  recipe.force = {}
  recipe.group = {name="helmod", order="zzzz"}
  recipe.subgroup = {name="helmod-resource", order="aaaa"}
  recipe.hidden = false
  if prototype and prototype.flags ~= nil then
    recipe.hidden = prototype.flags["hidden"] or false
  end
  recipe.ingredients = ingredients
  recipe.products = entity_prototype:getMineableMiningProducts()
  recipe.localised_description = prototype.localised_description
  recipe.localised_name = prototype.localised_name
  recipe.name = prototype.name
  recipe.prototype = {}
  recipe.valid = true

  return recipe
end

-------------------------------------------------------------------------------
---Return resource recipes
---@return table
function Player.getResourceRecipes()
  local recipes = {}

  for key, prototype in pairs(game.entity_prototypes) do
    if prototype.name ~= nil and prototype.resource_category ~= nil then
      recipe = Player.buildResourceRecipe(EntityPrototype(prototype))
      recipes[recipe.name] = recipe
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
  recipe.group = {name="helmod", order="zzzz"}
  recipe.subgroup = {name="helmod-energy", order="dddd"}
  recipe.hidden = false
  if prototype ~= nil and prototype.flags ~= nil then
    recipe.hidden = prototype.flags["hidden"] or false
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

  ---Offshore pumps
  local filters = {}
  table.insert(filters, {filter="type", type="offshore-pump", mode="or"})
  local entities = game.get_filtered_entity_prototypes(filters)
  for key, entity in pairs(entities) do
    for _, fluidbox in pairs(entity.fluidbox_prototypes) do
      if #fluidbox.pipe_connections > 0 then
        local recipe = Player.buildFluidRecipe(entity.fluid.name, {}, nil)
        recipe.subgroup = {name="helmod-fluid", order="bbbb"}
        if not recipes[entity.fluid.name] then
          recipes[entity.fluid.name] = recipe
        end
        if entity.has_flag("hidden") then
          recipes[entity.fluid.name].hidden = true
        end
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
---Return table of boiler recipes
---@return table
function Player.getBoilerRecipes()
  local recipes = {}

  ---Boilers
  local boilers = Player.getBoilers()

  for boiler_name, boiler in pairs(boilers) do
    local input_fluid
    local output_fluid

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
      local ingredients = {{name=input_fluid, type="fluid", amount=1}}
      local fluid_prototype = FluidPrototype(output_fluid)
      local recipe = Player.buildFluidRecipe(fluid_prototype, ingredients, boiler.target_temperature)
      recipe.subgroup = {name="helmod-boiler", order="cccc"}
      recipe.input_fluid_name = input_fluid
      recipe.output_fluid_name = output_fluid
      recipe.output_fluid_temperature = boiler.target_temperature

      if not recipes[recipe.name] then
        recipes[recipe.name] = recipe
      end
      if boiler.has_flag("hidden") then
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
---@return table
function Player.buildFluidRecipe(fluid, ingredients, temperature)
  local fluid_prototype
  if type(fluid) == "string" then
    fluid_prototype = FluidPrototype(fluid)
  else
    fluid_prototype = fluid
  end

  local prototype = fluid_prototype:native()
  local products = {{name=prototype.name, type="fluid", amount=1, temperature=temperature}}
  local recipe = {}
  recipe.enabled = true
  recipe.energy = 1
  recipe.force = {}
  recipe.group = {name="helmod", order="zzzz"}
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

function Player.buildRocketRecipe(prototype)
  if prototype == nil then return nil end
  local products = prototype.rocket_launch_products
  local ingredients = {}
  local item_prototype = ItemPrototype(prototype.name)
  local stack_size = item_prototype:stackSize()
  table.insert(ingredients, {name=prototype.name, type="item", amount=1, constant=true})
  local recipe = {}
  recipe.category = "rocket-building"
  recipe.enabled = true
  recipe.energy = 1
  recipe.force = {}
  recipe.group = {name="helmod", order="zzzz"}
  recipe.subgroup = {name="helmod-rocket", order="eeee"}
  recipe.hidden = false
  recipe.ingredients = ingredients
  for key, product in pairs(products) do
    local product_prototype = ItemPrototype(product.name)
    local i=0
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
  
  if Player.getRecipe("rocket-part") ~= nil and Player.getRecipe("rocket-silo") ~= nil then
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
  recipe.group = {name="helmod", order="zzzz"}
  recipe.subgroup = {name="helmod-recipe-burnt", order="ffff"}
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
        table.insert(recipes,{name=recipe.name, type="recipe"})
        break
      end
    end
  end
  ---recherche dans les resource
  for key, resource in pairs(Player.getResources()) do
    local elements = EntityPrototype(resource):getMineableMiningProducts()
    for key, element in pairs(elements) do
      if element.name == element_name then
        table.insert(recipes,{name=resource.name, type="resource"})
        break
      end
    end
  end
  ---recherche dans les fluids
  for key, recipe in pairs(Player.getFluidRecipes()) do
    if recipe.name == element_name then
      table.insert(recipes, {name=recipe.name, type="fluid"})
    end
  end
  for key, recipe in pairs(Player.getBoilerRecipes()) do
    if recipe.name == element_name then
      table.insert(recipes, {name=recipe.name, type="boiler"})
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
    return game.get_filtered_entity_prototypes(filters)
  end
  return game.entity_prototypes
end

-------------------------------------------------------------------------------
---Return entity prototype types
---@return table
function Player.getEntityPrototypeTypes()
  local types = {}
  for _,entity in pairs(game.entity_prototypes) do
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
  return game.entity_prototypes[name]
end

-------------------------------------------------------------------------------
---Return beacon production
---@return table
function Player.getProductionsBeacon()
  local items = {}
  local filters = {}
  table.insert(filters,{filter="type",type="beacon",mode="or"})
  table.insert(filters,{filter="hidden",invert=true,mode="and"})

  for _,item in pairs(game.get_filtered_entity_prototypes(filters)) do
    table.insert(items,item)
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
  for _,item in pairs(game.entity_prototypes) do
    if item.name ~= nil and item.resource_category ~= nil then
      table.insert(items,item)
    end
  end
  Cache.setData(Player.classname, "resources", items)
  return items
end

-------------------------------------------------------------------------------
---Return item prototypes
---@param filters table --{{filter="fuel-category", mode="or", invert=false,["fuel-category"]="chemical"}}
---@return table
function Player.getItemPrototypes(filters)
  if filters ~= nil then
    return game.get_filtered_item_prototypes(filters)
  end
  return game.item_prototypes
end

-------------------------------------------------------------------------------
---Return item prototype types
---@return table
function Player.getItemPrototypeTypes()
  local types = {}
  for _,entity in pairs(game.item_prototypes) do
    local type = entity.type
    types[type] = true
  end
  return types
end

-------------------------------------------------------------------------------
---Return item prototype
---@param name string
---@return LuaItemPrototype
function Player.getItemPrototype(name)
  if name == nil then return nil end
  return game.item_prototypes[name]
end

-------------------------------------------------------------------------------
---Return fluid prototypes
---@param filters table --{{filter="type", mode="or", invert=false type="transport-belt"}}
---@return table
function Player.getFluidPrototypes(filters)
  if filters ~= nil then
    return game.get_filtered_fluid_prototypes(filters)
  end
  return game.fluid_prototypes
end

-------------------------------------------------------------------------------
---Return fluid prototype types
---@return table
function Player.getFluidPrototypeTypes()
  local types = {}
  for _,entity in pairs(game.fluid_prototypes) do
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
  for _,entity in pairs(game.fluid_prototypes) do
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
  return game.fluid_prototypes[name]
end

-------------------------------------------------------------------------------
---Return fluid fuel prototype
---@return table
function Player.getFluidFuelPrototypes()
  local filters = {}
  table.insert(filters, {filter = "hidden", invert = true, mode = "and"})
  table.insert(filters, {filter = "fuel-value", mode= "and", invert = false, comparison = ">", value = 0})

  local items = {}
  
  for _, fluid in spairs(Player.getFluidPrototypes(filters), function(t,a,b) return t[b].fuel_value > t[a].fuel_value end) do
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
    filters = {{filter="type", mode="or", invert=false, type="inserter"}}
  elseif type == "belt" then
    filters = {{filter="type", mode="or", invert=false, type="transport-belt"}}
  elseif type == "container" then
    filters = {{filter="type", mode="or", invert=false, type="container"}, {filter="minable", mode="and", invert=false}, {filter="type", mode="or", invert=false, type="logistic-container"}, {filter="minable", mode="and", invert=false}}
  elseif type == "transport" then
    filters = {{filter="type", mode="or", invert=false, type="cargo-wagon"}, {filter="type", mode="or", invert=false, type="logistic-robot"}, {filter="type", mode="or", invert=false, type="car"}}
  end
  return Player.getEntityPrototypes(filters)
end

-------------------------------------------------------------------------------
---Return default item logistic
---@param type string --belt, container or transport
---@return table
function Player.getDefaultItemLogistic(type)
  local default = User.getParameter(string.format("items_logistic_%s", type))
  if default == nil then 
    local logistics = Player.getItemsLogistic(type)
    if logistics ~= nil then
      default = first(logistics).name
      User.setParameter(string.format("items_logistic_%s", type), default)
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
    filters = {{filter="type", mode="or", invert=false, type="pipe"}}
  elseif type == "container" then
    filters = {{filter="type", mode="or", invert=false, type="storage-tank"}, {filter="minable", mode="and", invert=false}}
  elseif type == "transport" then
    filters = {{filter="type", mode="or", invert=false, type="fluid-wagon"}}
  end
  return Player.getEntityPrototypes(filters)
end

-------------------------------------------------------------------------------
---Return default fluid logistic
---@param type string --pipe, container or transport
---@return table
function Player.getDefaultFluidLogistic(type)
  local default = User.getParameter(string.format("fluids_logistic_%s", type))
  if default == nil then 
    local logistics = Player.getFluidsLogistic(type)
    if logistics ~= nil then
      default = first(logistics).name
      User.setParameter(string.format("fluids_logistic_%s", type), default)
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
  local value = string.match(number,"[0-9.]*",1)
  local power = string.match(number,"[0-9.]*([a-zA-Z]*)",1)
  if power == nil then
    return tonumber(value)
  elseif string.lower(power) == "kw" then
    return tonumber(value)*1000
  elseif string.lower(power) == "mw" then
    return tonumber(value)*1000*1000
  elseif string.lower(power) == "gw" then
    return tonumber(value)*1000*1000*1000
  elseif string.lower(power) == "kj" then
    return tonumber(value)*1000
  elseif string.lower(power) == "mj" then
    return tonumber(value)*1000*1000
  elseif string.lower(power) == "gj" then
    return tonumber(value)*1000*1000*1000
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
  table.insert(filters, {filter = "has-product-fluid", elem_filters = {{filter = "name", name = fluid.name}}, mode = "and"})
  local prototypes = game.get_filtered_recipe_prototypes(filters)

  for recipe_name, recipe in pairs(prototypes) do
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
  for temperature, _ in spairs(temperatures, function(t,a,b) return b > a end) do
    item = FluidPrototype(fluid)
    item:setTemperature(temperature)
    table.insert(items, item)
  end

  return items
end

return Player