-------------------------------------------------------------------------------
---Description of the module.
---@class User
local User = {
  ---single-line comment
  classname = "HMUser",
  gui = "gui",
  prefixe = "helmod",
  version = "0.9.12",
  tab_name = "HMProductionPanel",
  delay_tips = 60*10
}

-------------------------------------------------------------------------------
---Get global variable for user
---@param key string
---@return any
function User.get(key)
  if global["users"] == nil then
    global["users"] = {}
  end
  local user_name = User.name()
  if global["users"][user_name] == nil then
    global["users"][user_name] = {}
  end

  if key ~= nil then
    if global["users"][user_name][key] == nil then
      global["users"][user_name][key] = {}
    end
    return global["users"][user_name][key]
  end
  return global["users"][user_name]
end

-------------------------------------------------------------------------------
---Get Name
---@return string
function User.name()
  return Player.native().name or Player.native().index or "nil"
end

-------------------------------------------------------------------------------
---Return is admin player
---@return boolean
function User.isAdmin()
  return Player.native().admin
end

-------------------------------------------------------------------------------
---Return is writer player
---@param model table
---@return boolean
function User.isReader(model)
  return Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 1) > 0)
end

-------------------------------------------------------------------------------
---Return is writer player
---@param model table
---@return boolean
function User.isWriter(model)
  return Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0)
end

-------------------------------------------------------------------------------
---Return is writer player
---@param model table
---@return boolean
function User.isDeleter(model)
  return Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0)
end

-------------------------------------------------------------------------------
---Return is filter translate
---@return boolean
function User.isFilterTranslate()
  return User.getModGlobalSetting("filter_translated_string_active") and (User.getParameter("filter-language") == nil or User.getParameter("filter-language") == "left")
end

-------------------------------------------------------------------------------
---Return is filter contain
---@return boolean
function User.isFilterContain()
  return (User.getParameter("filter-contain") == nil or User.getParameter("filter-contain") == "left")
end

-------------------------------------------------------------------------------
---Get default settings
---@return table
function User.getDefaultSettings()
  return {
    display_pin_beacon = false,
    display_pin_level = 4,
    model_auto_compute = false,
    model_loop_limit = 1000,
    other_speed_panel=false,
    filter_show_disable=true,
    filter_show_hidden=false,
    filter_show_hidden_player_crafting=true,
    filter_show_lock_recipes=false
  }
end

-------------------------------------------------------------------------------
---Get sorted style
---@param key string
---@return string
function User.getSortedStyle(key)
  local user_order = User.getParameter()
  if user_order == nil then user_order = User.setParameter("order", {name="index",ascendant="true"})  end
  local style = "helmod_button-sorted-none"
  if user_order.name == key and user_order.ascendant then style = "helmod_button-sorted-up" end
  if user_order.name == key and not(user_order.ascendant) then style = "helmod_button-sorted-down" end
  return style
end

-------------------------------------------------------------------------------
---Get parameter
---@param property string
---@return any
function User.getParameter(property)
  local parameter = User.get("parameter")
  if parameter ~= nil and property ~= nil then
    return parameter[property]
  end
  return parameter
end

-------------------------------------------------------------------------------
---Get preference
---@param type string
---@param name string
---@return any
function User.getPreference(type, name)
  local preferences = User.get("preferences")
  if preferences ~= nil and type ~= nil then
    if name ~= nil and name ~= "" then
      local preference_name = string.format("%s_%s", type, name)
      return preferences[preference_name]
    else
      return preferences[type]
    end
  end
  return preferences
end

-------------------------------------------------------------------------------
---Get default factory
---@param recipe table
---@return any
function User.getDefaultFactory(recipe)
  local default_factory = User.getParameter("default_factory")
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  if category ~= nil and default_factory ~= nil and default_factory[category] ~= nil then
    return default_factory[category]
  end
  return nil
end

-------------------------------------------------------------------------------
---Set default factory
---@param recipe table
function User.setDefaultFactory(recipe)
  local default_factory = User.getParameter("default_factory") or {}
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  local factory = recipe.factory
  if category ~= nil then
    local default_category = {name = factory.name, fuel = factory.fuel}
    if factory.module_priority ~= nil then
      default_category.module_priority = {}
      for _, priority in pairs(factory.module_priority) do
        table.insert(default_category.module_priority, {name = priority.name, value = priority.value})
      end
    end
    default_factory[category] = default_category
    User.setParameter("default_factory", default_factory)
  end
end

-------------------------------------------------------------------------------
---Get default beacons
---@param recipe RecipeData
---@return {[uint] : BeaconData}
function User.getDefaultBeacons(recipe)
  local default_beacons = User.getParameter("default_beacons")
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  if category ~= nil and default_beacons ~= nil and default_beacons[category] ~= nil then
    return default_beacons[category]
  end
  return nil
end

-------------------------------------------------------------------------------
---Get default beacons
---@param recipe RecipeData
---@return FactoryData
function User.getCurrentDefaultBeacon(recipe)
  local default_beacons = User.getDefaultBeacons(recipe) or {}
  local current_beacon_selection = User.getParameter("current_beacon_selection") or 1
  return  default_beacons[current_beacon_selection] or {}
end

-------------------------------------------------------------------------------
---Set default beacon
---@param recipe table
function User.setDefaultBeacons(recipe)
  local default_beacons = User.getParameter("default_beacons") or {}
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  local beacons = recipe.beacons
  local default_category = {}
  if category ~= nil then
    for _, beacon in pairs(beacons) do
      local default_beacon = {name = beacon.name, combo = beacon.combo, per_factory = beacon.per_factory, per_factory_constant = beacon.per_factory_constant}
      if beacon.module_priority ~= nil then
        default_beacon.module_priority = {}
        for _, priority in pairs(beacon.module_priority) do
          table.insert(default_beacon.module_priority, {name = priority.name, value = priority.value})
        end
      end
      table.insert(default_category, default_beacon)
    end
    default_beacons[category] = default_category
    User.setParameter("default_beacons", default_beacons)
  end
end

-------------------------------------------------------------------------------
---Get version
---@return string
function User.getVersion()
  local parameter = User.get()
  return parameter["version"] or ""
end

-------------------------------------------------------------------------------
---Set version
---@return any
function User.setVersion()
  local parameter = User.get()
  parameter["version"] = User.version
  return User.version
end

-------------------------------------------------------------------------------
---Set
---@param property string
---@param value any
---@return any
function User.set(property, value)
  User.setVersion()
  local parameter = User.get()
  parameter[property] = value
  return value
end

-------------------------------------------------------------------------------
---Set parameter
---@param property string
---@param value any
---@return nil
function User.setParameter(property, value)
  if property == nil then
    return nil
  end
  User.setVersion()
  local parameter = User.get("parameter")
  parameter[property] = value
  return value
end

-------------------------------------------------------------------------------
---Create next event
---@param event table
---@param classname string
---@param method any
---@param index any
---@return table
function User.createNextEvent(event, classname, method, index)
  if event == nil then
    User.setParameter("next_event", nil)
    local auto_pause = User.getParameter("auto-pause")
    if not(game.is_multiplayer()) then
      game.tick_paused = auto_pause
    end
    return {wait=false, method=method}
  end
  local index_name = string.format("index_%s",method)
  event[index_name] = index
  event.method = method
  User.setParameter("next_event", {type_event=event.type, event=event, classname=classname})
  game.tick_paused = false
  return {wait=true, method=method}
end

-------------------------------------------------------------------------------
---Set preference
---@param type string
---@param name string
---@param value any
---@return any
function User.setPreference(type, name, value)
  if type == nil then
    return nil
  end
  User.setVersion()
  local preferences = User.get("preferences")
  if name == nil then
    local preference = defines.constant.preferences[type]
    if value == nil then
      value = preference.default_value
    end
    if preference.minimum_value ~= nil and value < preference.minimum_value then
      value = preference.default_value
    end
    if preference.maximum_value ~= nil and value > preference.maximum_value then
      value = preference.default_value
    end

    preferences[type] = value
  else
    local preference_name = string.format("%s_%s", type, name)
    preferences[preference_name] = value
  end
  return value
end

-------------------------------------------------------------------------------
---Get navigate
---@param property string
---@return table
function User.getNavigate(property)
  local navigate = User.get("navigate")
  if navigate ~= nil and property ~= nil then
    return navigate[property]
  elseif property ~= nil then
    navigate[property] = {}
    return navigate[property]
  end
  return navigate
end

-------------------------------------------------------------------------------
---Set navigate
---@param property string
---@param value any
---@return any
function User.setNavigate(property, value)
  User.setVersion()
  local navigate = User.get("navigate")
  navigate[property] = value
  return value
end

-------------------------------------------------------------------------------
---Get user settings
---@return table
function User.getSettings()
  local data_user = User.get()
  if data_user["settings"] == nil then
    data_user["settings"] = User.getDefaultSettings()
  end
  return data_user["settings"]
end

-------------------------------------------------------------------------------
---Get user settings
---@param property string
---@return any
function User.getSetting(property)
  local settings = User.getSettings()
  if settings ~= nil and property ~= nil then
    local value = settings[property]
    if value == nil then
      value = User.getDefaultSettings()[property]
    end
    return value
  end
  return settings
end

-------------------------------------------------------------------------------
---Set setting
---@param property string
---@param value any
---@return any
function User.setSetting(property, value)
  User.setVersion()
  local settings = User.get("settings")
  settings[property] = value
  return value
end

-------------------------------------------------------------------------------
---Get settings
---@param name string
---@return any
function User.getModSetting(name)
  local property = nil
  local property_name = string.format("%s_%s",User.prefixe,name)
  if Player.native() ~= nil then
    property = Player.native().mod_settings[property_name]
  else
    property = settings.global[property_name]
  end
  if property ~= nil then
    return property.value
  else
    return defines.constant.settings_mod[name].default_value
  end
end

-------------------------------------------------------------------------------
---Get settings
---@param name string
---@return any
function User.getModGlobalSetting(name)
  local property = nil
  local property_name = string.format("%s_%s",User.prefixe,name)
  property = settings.global[property_name]
  if property ~= nil then
    return property.value
  else
    return defines.constant.settings_mod[name].default_value
  end
end

-------------------------------------------------------------------------------
---Get preference settings
---@param type string
---@param name string
---@return any
function User.getPreferenceSetting(type, name)
  local preference_type = User.getPreference(type)
  if name == nil then
    local preference = defines.constant.preferences[type]
    if preference_type == nil then
      return preference.default_value
    end
    if preference.minimum_value ~= nil and preference_type < preference.minimum_value then
      return preference.default_value
    end
    if preference.maximum_value ~= nil and preference_type > preference.maximum_value then
      return preference.default_value
    end
    return preference_type
  end
  if preference_type == nil then return false end
  local preference_name = User.getPreference(type, name)
  if preference_name ~= nil then
    return preference_name
  else
    if defines.constant.preferences[type].items == nil or defines.constant.preferences[type].items[name] == nil then return false end
    return defines.constant.preferences[type].items[name]
  end
end

-------------------------------------------------------------------------------
---Reset global variable for user
function User.reset()
  local user_name = User.name()
  global["users"][user_name] = {}
end

-------------------------------------------------------------------------------
---Reset global variable for all user
function User.resetAll()
  global["users"] = {}
end

-------------------------------------------------------------------------------
---Set Close Form
---@param classname string
---@param location table
function User.setCloseForm(classname, location)
  local navigate = User.getNavigate()
  if navigate[classname] == nil then navigate[classname] = {} end
  navigate[classname]["open"] = false
  if string.find(classname, "HMProductionPanel") then
    game.tick_paused = false
  end
  navigate[classname]["location"] = location
  navigate[classname]["tips"] = nil
end

-------------------------------------------------------------------------------
---Get location Form
---@param classname string
---@return table
function User.getLocationForm(classname)
  local navigate = User.getNavigate()
  if User.getPreferenceSetting("ui_glue") == true and User.getPreferenceSetting("ui_glue", classname) == true then
    if navigate[User.tab_name] == nil or navigate[User.tab_name]["location"] == nil then return {x=50,y=50} end
    return navigate[User.tab_name]["location"]
  else
    if navigate[classname] == nil or navigate[classname]["location"] == nil then return {x=200,y=100} end
    return navigate[classname]["location"]
  end
end

-------------------------------------------------------------------------------
---Set Active Form
---@param classname string
function User.setActiveForm(classname)
  local navigate = User.getNavigate()
  if User.getPreferenceSetting("ui_auto_close") == true then
    if User.getPreferenceSetting("ui_auto_close", classname) == true then
      for form_name,form in pairs(navigate) do
        if Controller:getView(form_name) ~= nil and form_name ~= classname and User.getPreferenceSetting("ui_auto_close", form_name) == true then
          Controller:getView(form_name):close()
        end
      end
    end
  end
  if string.find(classname, "HMProductionPanel") then
    if not(game.is_multiplayer()) and User.getParameter("auto-pause") then
      game.tick_paused = true
    else
      game.tick_paused = false
    end
  end

  if navigate[classname] == nil then navigate[classname] = {} end
  navigate[classname]["open"] = true
end

-------------------------------------------------------------------------------
---Get main sizes
---@return number, number
function User.getMainSizes()
  local width , height = Player.getDisplaySizes()
  local display_ratio_horizontal = User.getModSetting("display_ratio_horizontal")
  local display_ratio_vertictal = User.getModSetting("display_ratio_vertical")
  if type(width) == "number" and  type(height) == "number" then
    local width_main = math.ceil(width*display_ratio_horizontal)
    local height_main = math.ceil(height*display_ratio_vertictal)
    return width_main, height_main
  end
  return 800,600
end

-------------------------------------------------------------------------------
---update
function User.update()
  if User.getVersion() ~= User.version then
    User.reset()
  end
end

-------------------------------------------------------------------------------
---Add translate
---@param request table --{player_index=number, localised_string=#string, result=#string, translated=#boolean}
function User.addTranslate(request)
  if request.translated == true then
    local localised_string = request.localised_string
    local string_translated = request.result
    if type(localised_string) == "table" then
      local localised_value = localised_string[1]
      if localised_value ~= nil and localised_value ~= "" then
        local _,key = string.match(localised_value,"([^.]*).([^.]*)")
        if key ~= nil and key ~= "" then
          local translated = User.get("translated")
          translated[key] = string_translated
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
---Is translate
---@return boolean
function User.isTranslate()
  local translated = User.get("translated")
  return translated ~= nil and table.size(translated) > 0
end

-------------------------------------------------------------------------------
---Get translate
---@param name string
---@return any
function User.getTranslate(name)
  local translated = User.get("translated")
  if translated == nil or translated[name] == nil then return name end
  return translated[name]
end

-------------------------------------------------------------------------------
---Reset translate
function User.resetTranslate()
  local data_user = User.get()
  data_user["translated"] = {}
end

-------------------------------------------------------------------------------
---Return Cache User
---@param classname string
---@param name string
---@return table
function User.getCache(classname, name)
  local data = User.get("cache")
  if classname == nil and name == nil then return data end
  if data[classname] == nil or data[classname][name] == nil then return nil end
  return data[classname][name]
end

-------------------------------------------------------------------------------
---Set Cache User
---@param classname string
---@param name string
---@param value any
function User.setCache(classname, name, value)
  local data = User.get("cache")
  if data[classname] == nil then data[classname] = {} end
  data[classname][name] = value
end

-------------------------------------------------------------------------------
---Has User Cache
---@param classname string
---@param name string
---@return boolean
function User.hasCache(classname, name)
  local data = User.get("cache")
  return data[classname] ~= nil and data[classname][name] ~= nil
end

-------------------------------------------------------------------------------
---Reset cache
---@param classname string
---@param name string
function User.resetCache(classname, name)
  local data = User.get("cache")
  if classname == nil and name == nil then
    User.set("cache",{})
  elseif data[classname] ~= nil and name == nil then
    data[classname] = nil
  elseif data[classname] ~= nil then
    data[classname][name] = nil
  end
end

-------------------------------------------------------------------------------
---Get Function Product Sorter
---@return function
function User.getProductSorter()
  local display_product_order = User.getPreferenceSetting("display_product_order")
  if display_product_order == "name" then
    return function(t,a,b) return t[b].name > t[a].name end
  elseif display_product_order == "cost" then
    return function(t,a,b) return t[b].amount < t[a].amount end
  end
  return nil
end

-------------------------------------------------------------------------------
---Get Function Product Sorter
function User.setParameterObjects(classname, model_id, block_id, recipe_id)
  local parameter_objects = string.format("%s_%s", classname, "objects")
  User.setParameter(parameter_objects, {name=parameter_objects, model=model_id, block=block_id, recipe=recipe_id})
end

return User
