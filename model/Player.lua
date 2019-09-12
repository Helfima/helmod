---
-- Description of the module.
-- @module Player
--
local Player = {
  -- single-line comment
  classname = "HMPlayer"
}

local Lua_player = nil

-------------------------------------------------------------------------------
-- Print message
--
-- @function [parent=#Player] print
--
-- @param #string message
--
function Player.print(message)
  if Lua_player ~= nil then
    Lua_player.print(message)
  end
end
-------------------------------------------------------------------------------
-- Load factorio player
--
-- @function [parent=#Player] load
--
-- @param #LuaEvent event
--
-- @return #Player
--
function Player.load(event)
  --log("event.player_index="..(event.player_index or "nil"))
  Lua_player = game.players[event.player_index]
  return Player
end

-------------------------------------------------------------------------------
-- Set factorio player
--
-- @function [parent=#Player] set
--
-- @param #LuaPlayer player
--
-- @return #Player
--
function Player.set(player)
  Lua_player = player
  return Player
end

-------------------------------------------------------------------------------
-- Return factorio player
--
-- @function [parent=#Player] native
--
-- @return #Lua_player
--
function Player.native()
  return Lua_player
end

-------------------------------------------------------------------------------
-- Return admin player
--
-- @function [parent=#Player] native
--
-- @return #boolean
--
function Player.isAdmin()
  return Lua_player.admin
end

-------------------------------------------------------------------------------
-- Get gui
--
-- @function [parent=#Player] getGui
--
-- @param location
--
-- @return #LuaGuiElement
--
function Player.getGui(location)
  return Lua_player.gui[location]
end

-------------------------------------------------------------------------------
-- Return icon type
--
-- @function [parent=#Player] getIconType
--
-- @param #ModelRecipe element
--
-- @return #string recipe type
--
function Player.getIconType(element)
  Logging:trace(Player.classname, "getIconType(element)", element)
  if element == nil or element.name == nil then return "unknown" end
  local item = Player.getItemPrototype(element.name)
  if item ~= nil then
    return "item"
  end
  local fluid = Player.getFluidPrototype(element.name)
  if fluid ~= nil then
    return "fluid"
  end
  local entity = Player.getEntityPrototype(element.name)
  if entity ~= nil then
    return "entity"
  end
  local technology = Player.getTechnology(element.name)
  if technology ~= nil then
    return "technology"
  end
  return "recipe"
end

-------------------------------------------------------------------------------
-- Return force's player
--
-- @function [parent=#Player] getForce
--
--
-- @return #table force
--
function Player.getForce()
  return Lua_player.force
end

-------------------------------------------------------------------------------
-- Return recipe type
--
-- @function [parent=#Player] getRecipeIconType
--
-- @param #ModelRecipe element
--
-- @return #string recipe type
--
function Player.getRecipeIconType(element)
  Logging:trace(Player.classname, "getRecipeIconType(element)", element)
  if element == nil then Logging:error(Player.classname, "getRecipeIconType(element): missing player") end
  local lua_recipe = Player.getRecipe(element.name)
  if lua_recipe ~= nil and lua_recipe.force ~= nil then
    return "recipe"
  end
  local lua_technology = Player.getTechnology(element.name)
  if lua_technology ~= nil and lua_technology.force ~= nil then
    return "technology"
  end
  return Player.getIconType(element);
end

-------------------------------------------------------------------------------
-- Return item type
--
-- @function [parent=#Player] getItemIconType
--
-- @param #table factorio prototype
--
-- @return #string item type
--
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
-- Return entity type
--
-- @function [parent=#Player] getEntityIconType
--
-- @param #table factorio prototype
--
-- @return #string item type
--
function Player.getEntityIconType(element)
  local item = Player.getEntityPrototype(element.name)
  if item ~= nil then
    return "entity"
  end
  return Player.getItemIconType(element)
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Player] getLocalisedName
--
-- @param #table element factorio prototype
--
-- @return #string localised name
--
function Player.getLocalisedName(element)
  Logging:trace(Player.classname, "getLocalisedName(element)", element)
  if User.getModGlobalSetting("display_real_name") then
    return element.name
  end
  local localisedName = element.name
  if element.type ~= nil then
    if element.type == "entity" then
      local item = Player.getEntityPrototype(element.name)
      if item ~= nil then
        localisedName = item.localised_name
      end
    end
    if element.type == 0 or element.type == "item" then
      local item = Player.getItemPrototype(element.name)
      if item ~= nil then
        localisedName = item.localised_name
      end
    end
    if element.type == 1 or element.type == "fluid" then
      local item = Player.getFluidPrototype(element.name)
      if item ~= nil then
        localisedName = item.localised_name
      end
    end
  end
  return localisedName
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Player] getRecipeLocalisedName
--
-- @param #LuaPrototype prototype factorio prototype
--
-- @return #string localised name
--
function Player.getRecipeLocalisedName(prototype)
  local element = Player.getRecipe(prototype.name)
  if element ~= nil and not(User.getModGlobalSetting("display_real_name")) then
    return element.localised_name
  end
  return prototype.name
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#Player] getTechnologyLocalisedName
--
-- @param #LuaPrototype prototype factorio prototype
--
-- @return #string localised name
--
function Player.getTechnologyLocalisedName(prototype)
  local element = Player.getTechnology(prototype.name)
  if element ~= nil and not(User.getModGlobalSetting("display_real_name")) then
    return element.localised_name
  end
  return element.name
end

-------------------------------------------------------------------------------
-- Return recipes
--
-- @function [parent=#Player] getRecipes
--
-- @return #table recipes
--
function Player.getRecipes()
  return Player.getForce().recipes
end

-------------------------------------------------------------------------------
-- Return technologies
--
-- @function [parent=#Player] getTechnologies
--
-- @return #table technologies
--
function Player.getTechnologies()
  local technologies = {}
  for _,technology in pairs(Player.getForce().technologies) do
    technologies[technology.name] = technology
  end
  return technologies
end

-------------------------------------------------------------------------------
-- Return technology
--
-- @function [parent=#Player] getTechnology
--
-- @param #string name technology name
--
-- @return #LuaPrototype factorio prototype
--
function Player.getTechnology(name)
  local technology = Player.getForce().technologies[name]
  return technology
end

-------------------------------------------------------------------------------
-- Return rule
--
-- @function [parent=#Player] getRules
--
-- @param #string rule_name
--
-- @return #table, #table rules_included, rules_excluded
--
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
-- Return rule
--
-- @function [parent=#Player] checkRules
--
-- @param #boolean check
-- @param #table rules
-- @param #string category
-- @param #lua_entity lua_entity
-- @param #boolean included
--
-- @return #boolean
--
function Player.checkRules(check, rules, category, lua_entity, included)
  Logging:debug(Player.classname, "checkRules()", check, rules, category, lua_entity.name, included)
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
-- Check limitation module
--
-- @function [parent=#Player] checkLimitationModule
--
-- @param #lua_item_prototype module
-- @param #table lua_recipe
--
-- @return #table list of productions
--
function Player.checkLimitationModule(module, lua_recipe)
  Logging:debug(Player.classname, "checkLimitationModule()", module, lua_recipe.name)
  local rules_included, rules_excluded = Player.getRules("module-limitation")
  local model_filter_factory_module = User.getModGlobalSetting("model_filter_factory_module")
  local factory = lua_recipe.factory
  local allowed = true
  local check_not_bypass = true
  local prototype = RecipePrototype(lua_recipe)
  local category = prototype:getCategory()
  if rules_excluded[category] == nil then category = "standard" end
  check_not_bypass = Player.checkRules(check_not_bypass, rules_excluded, category, EntityPrototype(factory.name):native(), false)
  if Model.countList(module.limitations) > 0 and Player.getModuleBonus(module.name, "productivity") > 0 and check_not_bypass and model_filter_factory_module == true then
    allowed = false
    for _, recipe_name in pairs(module.limitations) do
      if lua_recipe.name == recipe_name then allowed = true end
    end
  end
  if factory.module_slots ==  0 then
    allowed = false
  end
  return allowed
end
-------------------------------------------------------------------------------
-- Return list of productions
--
-- @function [parent=#Player] getProductionsCrafting
--
-- @param #string category filter
-- @param #string lua_recipe
--
-- @return #table list of productions
--
function Player.getProductionsCrafting(category, lua_recipe)
  Logging:debug(Player.classname, "getProductionsCrafting(category)", category, lua_recipe)
  local productions = {}
  local rules_included, rules_excluded = Player.getRules("production-crafting")

  Logging:debug(Player.classname, "rules", rules_included, rules_excluded)

  if category == "crafting-handonly" then
    productions["player"] = game.entity_prototypes["player"]
  elseif lua_recipe.name ~= nil and lua_recipe.name == "water" then
    for key, lua_entity in pairs(Player.getOffshorePump()) do
      productions[lua_entity.name] = lua_entity
    end
  elseif lua_recipe.name ~= nil and lua_recipe.name == "steam" then
    for key, lua_entity in pairs(Player.getBoilers()) do
      productions[lua_entity.name] = lua_entity
    end
  else
    for key, lua_entity in pairs(Player.getProductionMachines()) do
      Logging:debug(Player.classname, "loop production machines", lua_entity.name, lua_entity.type, lua_entity.group.name, lua_entity.subgroup.name, lua_entity.crafting_categories)
      local check = false
      if category ~= nil then
        if not(rules_included[category]) and not(rules_included[category]) then
          Logging:debug(Player.classname, "test crafting", lua_entity.name, category, lua_entity.crafting_categories )
          -- standard recipe
          if lua_entity.crafting_categories ~= nil and lua_entity.crafting_categories[category] then
            local recipe_ingredient_count = RecipePrototype(lua_recipe, "recipe"):getIngredientCount()
            local factory_ingredient_count = EntityPrototype(lua_entity):getIngredientCount()
            Logging:debug(Player.classname, "crafting", recipe_ingredient_count, factory_ingredient_count)
            if factory_ingredient_count >= recipe_ingredient_count then
              check = true
              Logging:debug(Player.classname, "allowed machine", lua_entity.name)
            end
            -- resolve rule excluded
            check = Player.checkRules(check, rules_excluded, "standard", lua_entity, false)
          end
        else
          -- resolve rule included
          check = Player.checkRules(check, rules_included, category, lua_entity, true)
          -- resolve rule excluded
          check = Player.checkRules(check, rules_excluded, category, lua_entity, false)
        end
      else
        if lua_entity.group ~= nil and lua_entity.group.name == "production" then
          check = true
        end
      end
      -- resource filter
      if check then
        if lua_recipe.name ~= nil then
          local lua_entity_filter = Player.getEntityPrototype(lua_recipe.name)
          if lua_entity_filter ~= nil and lua_entity.resource_categories ~= nil and not(lua_entity.resource_categories[lua_entity_filter.resource_category]) then
            check = false
          end
        end
      end
      -- ok to add entity
      if check then
        productions[lua_entity.name] = lua_entity
      end
    end
  end
  Logging:debug(Player.classname, "category", category, "productions", productions)
  return productions
end

-------------------------------------------------------------------------------
-- Return list of modules
--
-- @function [parent=#Player] getModules
--
-- @return #table list of modules
--
function Player.getModules()
  local items = {}
  local filters = {}
  table.insert(filters,{filter="type",type="module",mode="or"})

  for _,item in pairs(game.get_filtered_item_prototypes(filters)) do
    table.insert(items,item)
  end
  return items
end

-------------------------------------------------------------------------------
-- Return list of production machines
--
-- @function [parent=#Player] getProductionMachines
--
-- @return #table list of modules
--
function Player.getProductionMachines()
  local filters = {}
  table.insert(filters,{filter="crafting-machine",mode="and"})
  table.insert(filters,{filter="hidden",mode="and",invert=true})
  table.insert(filters,{filter="type", type="lab",mode="or"})
  table.insert(filters,{filter="type", type="mining-drill",mode="or"})
  return game.get_filtered_entity_prototypes(filters)
end

-------------------------------------------------------------------------------
-- Return list of boilers
--
-- @function [parent=#Player] getBoilers
--
-- @return #table list of modules
--
function Player.getBoilers()
  local filters = {}
  table.insert(filters,{filter="type", type="boiler" ,mode="or"})

  return game.get_filtered_entity_prototypes(filters)
end

-------------------------------------------------------------------------------
-- Return list of Offshore-Pump
--
-- @function [parent=#Player] getOffshorePump
--
-- @return #table list of modules
--
function Player.getOffshorePump()
  local filters = {}
  table.insert(filters,{filter="type", type="offshore-pump" ,mode="or"})

  return game.get_filtered_entity_prototypes(filters)
end

-------------------------------------------------------------------------------
-- Return module bonus (default return: bonus = 0 )
--
-- @function [parent=#Player] getModuleBonus
--
-- @param #string module module name
-- @param #string effect effect name
--
-- @return #number
--
function Player.getModuleBonus(module, effect)
  if module == nil then return 0 end
  local bonus = 0
  -- search module
  local module = Player.getItemPrototype(module)
  if module ~= nil and module.module_effects ~= nil and module.module_effects[effect] ~= nil then
    bonus = module.module_effects[effect].bonus
  end
  return bonus
end

-------------------------------------------------------------------------------
-- Return recipe
--
-- @function [parent=#Player] getRecipe
--
-- @param #string name recipe name
--
-- @return #LuaRecipe recipe
--
function Player.getRecipe(name)
  return Player.getForce().recipes[name]
end

-------------------------------------------------------------------------------
-- Return resource recipe
--
-- @function [parent=#Player] getRecipeEntity
--
-- @param #string name recipe name
--
-- @return #LuaRecipe recipe
--
function Player.getRecipeEntity(name)
  local entity_prototype = EntityPrototype(name)
  local prototype = entity_prototype:native()
  local ingredients = {{name=prototype.name, type="item", amount=1}}
  if entity_prototype:getMineableMiningFluidRequired() then
    local fluid_ingredient = {name=entity_prototype:getMineableMiningFluidRequired(), type="fluid", amount=entity_prototype:getMineableMiningFluidAmount()}
    table.insert(ingredients, fluid_ingredient)
  end
  local recipe = {}
  recipe.category = "extraction-machine"
  recipe.enabled = true
  recipe.energy = 1
  recipe.force = {}
  recipe.group = prototype.group
  recipe.subgroup = prototype.subgroup
  recipe.hidden = false
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
-- Return recipe
--
-- @function [parent=#Player] getRecipeFluid
--
-- @param #string name recipe name
--
-- @return #LuaRecipe recipe
--
function Player.getRecipeFluid(name)
  local fluid_prototype = FluidPrototype(name)
  local prototype = fluid_prototype:native()
  local products = {{name=prototype.name, type="fluid", amount=1}}
  local ingredients = {{name=prototype.name, type="fluid", amount=1}}
  if prototype.name == "steam" then
    ingredients = {{name="water", type="fluid", amount=1}}
  end
  local recipe = {}
  recipe.category = "chemistry"
  recipe.enabled = true
  recipe.energy = 1
  recipe.force = {}
  recipe.group = prototype.group
  recipe.subgroup = prototype.subgroup
  recipe.hidden = false
  recipe.ingredients = ingredients
  recipe.products = products
  recipe.localised_description = prototype.localised_description
  recipe.localised_name = prototype.localised_name
  recipe.name = prototype.name
  recipe.prototype = {}
  recipe.valid = true
  return recipe
end

-------------------------------------------------------------------------------
-- Return recipe
--
-- @function [parent=#Player] getRecipeTechnology
--
-- @param #string name recipe name
--
-- @return #LuaRecipe recipe
--
function Player.getRecipeTechnology(name)
  local technology_prototype = Player.getTechnology(name)
  local recipe = {}
  recipe.category = "technology"
  recipe.enabled = true
  recipe.energy = 1
  recipe.force = technology_prototype.force
  recipe.group = {}
  recipe.subgroup = {}
  recipe.hidden = false
  recipe.ingredients = {}
  recipe.products = {}
  recipe.localised_description = technology_prototype.localised_description
  recipe.localised_name = technology_prototype.localised_name
  recipe.name = technology_prototype.name
  recipe.prototype = technology_prototype.prototype
  recipe.valid = true
  return recipe
end

-------------------------------------------------------------------------------
-- Return list of recipes
--
-- @function [parent=#Player] searchRecipe
--
-- @param #string recipe name
--
-- @return #table list of recipes
--
function Player.searchRecipe(name)
  local recipes = {}
  -- recherche dans les produits des recipes
  for key, recipe in pairs(Player.getRecipes()) do
    for k, product in pairs(recipe.products) do
      if product.name == name then
        table.insert(recipes,{name=recipe.name, type="recipe"})
      end
    end
  end
  -- recherche dans les resource
  for key, resource in pairs(Player.getResources()) do
    local products = EntityPrototype(resource):getMineableMiningProducts()
    for key, product in pairs(products) do
      if product.name == name then
        table.insert(recipes,{name=resource.name, type="resource"})
        break
      end
    end
  end
  -- recherche dans les fluids
  for key, fluid in pairs(Player.getFluidPrototypes()) do
    if fluid.name == name then
      table.insert(recipes,{name=fluid.name, type="fluid"})
    end
  end
  return recipes
end

-------------------------------------------------------------------------------
-- Return entity prototypes
--
-- @function [parent=#Player] getEntityPrototypes
--
-- @param #table filters  sample: {{filter="type", mode="or", invert=false type="transport-belt"}}
--
-- @return #LuaEntityPrototype entity prototype
--
function Player.getEntityPrototypes(filters)
  if filters ~= nil then
    return game.get_filtered_entity_prototypes(filters)
  end
  return game.entity_prototypes
end

-------------------------------------------------------------------------------
-- Return entity prototype types
--
-- @function [parent=#Player] getEntityPrototypeTypes
--
-- @return #table
--
function Player.getEntityPrototypeTypes()
  local types = {}
  for _,entity in pairs(game.entity_prototypes) do
    local type = entity.type
    types[type] = true
  end
  return types
end

-------------------------------------------------------------------------------
-- Return entity prototype
--
-- @function [parent=#Player] getEntityPrototype
--
-- @param #string name entity name
--
-- @return #LuaEntityPrototype entity prototype
--
function Player.getEntityPrototype(name)
  if name == nil then return nil end
  return game.entity_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return beacon production
--
-- @function [parent=#Player] getProductionsBeacon
--
-- @return #table items prototype
--
function Player.getProductionsBeacon()
  local items = {}
  local filters = {}
  table.insert(filters,{filter="type",type=EntityType.beacon,mode="or"})

  for _,item in pairs(game.get_filtered_entity_prototypes(filters)) do
    table.insert(items,item)
  end
  return items
end

-------------------------------------------------------------------------------
-- Return generators
--
-- @function [parent=#Player] getGenerators
--
-- @param #string type type primary or secondary
--
-- @return #table items prototype
--
function Player.getGenerators(type)
  if type == nil then type = "primary" end
  local items = {}
  local filters = {}
  if type == "primary" then
    table.insert(filters,{filter="type",type=EntityType.generator,mode="or"})
    table.insert(filters,{filter="type",type=EntityType.solar_panel,mode="or"})
  else
    table.insert(filters,{filter="type",type=EntityType.boiler,mode="or"})
    table.insert(filters,{filter="type",type=EntityType.accumulator,mode="or"})
  end

  for _,item in pairs(game.get_filtered_entity_prototypes(filters)) do
    table.insert(items,item)
  end
  return items
end

-------------------------------------------------------------------------------
-- Return resources list
--
-- @function [parent=#Player] getResources
--
-- @return #table entity prototype
--

function Player.getResources()
  local cache_resources = Cache.getData(Player.classname, "resources")
  if cache_resources ~= nil then return cache_resources end
  local items = {}
  for _,item in pairs(game.entity_prototypes) do
    --Logging:debug(Player.classname, "getItemsPrototype(type)", item.name, item.group.name, item.subgroup.name)
    if item.name ~= nil and item.resource_category ~= nil then
      table.insert(items,item)
    end
  end
  Cache.setData(Player.classname, "resources", items)
  return items
end

-------------------------------------------------------------------------------
-- Return item prototypes
--
-- @function [parent=#Player] getItemPrototypes
--
-- @param #table filters  sample: {{filter="fuel-category", mode="or", invert=false,["fuel-category"]="chemical"}}
--
-- @return #LuaItemPrototype item prototype
--
function Player.getItemPrototypes(filters)
  if filters ~= nil then
    return game.get_filtered_item_prototypes(filters)
  end
  return game.item_prototypes
end

-------------------------------------------------------------------------------
-- Return item prototype types
--
-- @function [parent=#Player] getItemPrototypeTypes
--
-- @return #table
--
function Player.getItemPrototypeTypes()
  local types = {}
  for _,entity in pairs(game.item_prototypes) do
    local type = entity.type
    types[type] = true
  end
  return types
end

-------------------------------------------------------------------------------
-- Return item prototype
--
-- @function [parent=#Player] getItemPrototype
--
-- @param #string name item name
--
-- @return #LuaItemPrototype item prototype
--
function Player.getItemPrototype(name)
  if name == nil then return nil end
  return game.item_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return fluid prototypes
--
-- @function [parent=#Player] getFluidPrototypes
--
-- @return #LuaFluidPrototype fluid prototype
--
function Player.getFluidPrototypes()
  return game.fluid_prototypes
end

-------------------------------------------------------------------------------
-- Return fluid prototype types
--
-- @function [parent=#Player] getFluidPrototypeTypes
--
-- @return #table
--
function Player.getFluidPrototypeTypes()
  local types = {}
  for _,entity in pairs(game.fluid_prototypes) do
    local type = entity.type
    types[type] = true
  end
  return types
end

-------------------------------------------------------------------------------
-- Return fluid prototype subgroups
--
-- @function [parent=#Player] getFluidPrototypeSubgroups
--
-- @return #table
--
function Player.getFluidPrototypeSubgroups()
  local types = {}
  for _,entity in pairs(game.fluid_prototypes) do
    local type = entity.subgroup.name
    types[type] = true
  end
  return types
end

-------------------------------------------------------------------------------
-- Return fluid prototype
--
-- @function [parent=#Player] getFluidPrototype
--
-- @param #string name fluid name
--
-- @return #LuaFluidPrototype fluid prototype
--
function Player.getFluidPrototype(name)
  if name == nil then return nil end
  return game.fluid_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return number
--
-- @function [parent=#Player] parseNumber
--
-- @param #string name
-- @param #string property
--
function Player.parseNumber(number)
  Logging:trace(Player.classname, "parseNumber(number)", number)
  if number == nil then return 0 end
  local value = string.match(number,"[0-9.]*",1)
  local power = string.match(number,"[0-9.]*([a-zA-Z]*)",1)
  Logging:trace(Player.classname, "parseNumber(number)", number, value, power)
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

return Player
