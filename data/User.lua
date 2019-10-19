---
-- Description of the module.
-- @module User
--
local User = {
  -- single-line comment
  classname = "HMUser",
  gui = "gui",
  prefixe = "helmod",
  version = "0.9.0",
  tab_name = "HMTab"
}

-------------------------------------------------------------------------------
-- Get global variable for user
--
-- @function [parent=#User] get
--
-- @param #string key
--
-- @return #table global
--
function User.get(key)
  if global["users"] == nil then
    global["users"] = {}
  end
  local user_name = User.name()
  if global["users"][user_name] == nil then
    global["users"][user_name] = {}
  end

  if global["users"][user_name].settings == nil then
    global["users"][user_name]["settings"] = User.getDefaultSettings()
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
-- Get Name
--
-- @function [parent=#User] name
--
function User.name()
  return Player.native().name
end

-------------------------------------------------------------------------------
-- Return is admin player
--
-- @function [parent=#User] isAdmin
--
-- @return #boolean
--
function User.isAdmin()
  return Player.native().admin
end

-------------------------------------------------------------------------------
-- Return is writer player
--
-- @function [parent=#User] isWriter
--
-- @return #boolean
--
function User.isWriter()
  local model = Model.getModel()
  return Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0)
end

-------------------------------------------------------------------------------
-- Return is filter translate
--
-- @function [parent=#User] isFilterTranslate
--
-- @return #boolean
--
function User.isFilterTranslate()
  return User.getModGlobalSetting("filter_translated_string_active") and (User.getParameter("filter-language") == nil or User.getParameter("filter-language") == "right")
end

-------------------------------------------------------------------------------
-- Return is filter contain
--
-- @function [parent=#User] isFilterContain
--
-- @return #boolean
--
function User.isFilterContain()
  return (User.getParameter("filter-contain") == nil or User.getParameter("filter-contain") == "right")
end

-------------------------------------------------------------------------------
-- Get default settings
--
-- @function [parent=#User] getDefaultSettings
--
function User.getDefaultSettings()
  return {
    display_pin_beacon = false,
    display_pin_level = 4,
    model_auto_compute = false,
    model_loop_limit = 1000,
    other_speed_panel=false,
    filter_show_disable=false,
    filter_show_hidden=false
  }
end

-------------------------------------------------------------------------------
-- Get sorted style
--
-- @function [parent=#User] getSortedStyle
--
-- @param #string key
--
-- @return #string style
--
function User.getSortedStyle(key)
  local user_order = User.getParameter()
  if user_order == nil then user_order = User.setParameter("order", {name="index",ascendant="true"})  end
  local style = "helmod_button-sorted-none"
  if user_order.name == key and user_order.ascendant then style = "helmod_button-sorted-up" end
  if user_order.name == key and not(user_order.ascendant) then style = "helmod_button-sorted-down" end
  return style
end

-------------------------------------------------------------------------------
-- Get parameter
--
-- @function [parent=#User] getParameter
--
-- @param #string property
--
function User.getParameter(property)
  local parameter = User.get("parameter")
  if parameter ~= nil and property ~= nil then
    return parameter[property]
  end
  return parameter
end

-------------------------------------------------------------------------------
-- Get default factory
--
-- @function [parent=#User] getDefaultFactory
--
-- @param #table recipe
--
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
-- Set default factory
--
-- @function [parent=#User] setDefaultFactory
--
-- @param #table recipe
--
function User.setDefaultFactory(recipe)
  local default_factory = User.getParameter("default_factory") or {}
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  local factory = recipe.factory
  if category ~= nil then
    default_factory[category] = {name = factory.name}
    User.setParameter("default_factory", default_factory)
  end
end

-------------------------------------------------------------------------------
-- Get default factory module
--
-- @function [parent=#User] getDefaultFactoryModule
--
-- @param #table recipe
--
function User.getDefaultFactoryModule(recipe)
  local default_factory_module = User.getParameter("default_factory_module")
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  if category ~= nil and default_factory_module ~= nil and default_factory_module[category] ~= nil then
    return default_factory_module[category]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Set default factory module
--
-- @function [parent=#User] setDefaultFactoryModule
--
-- @param #table recipe
--
function User.setDefaultFactoryModule(recipe)
  local default_factory_module = User.getParameter("default_factory_module") or {}
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  local factory = recipe.factory
  if category ~= nil then
    default_factory_module[category] = factory.module_priority
    User.setParameter("default_factory_module", default_factory_module)
  end
end

-------------------------------------------------------------------------------
-- Get default beacon
--
-- @function [parent=#User] getDefaultBeacon
--
-- @param #table recipe
--
function User.getDefaultBeacon(recipe)
  local default_beacon = User.getParameter("default_beacon")
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  if category ~= nil and default_beacon ~= nil and default_beacon[category] ~= nil then
    return default_beacon[category]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Set default beacon
--
-- @function [parent=#User] setDefaultBeacon
--
-- @param #table recipe
--
function User.setDefaultBeacon(recipe)
  local default_beacon = User.getParameter("default_beacon") or {}
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  local beacon = recipe.beacon
  if category ~= nil then
    default_beacon[category] = {name = beacon.name}
    User.setParameter("default_beacon", default_beacon)
  end
end

-------------------------------------------------------------------------------
-- Get default beacon module
--
-- @function [parent=#User] getDefaultBeaconModule
--
-- @param #table recipe
--
function User.getDefaultBeaconModule(recipe)
  local default_beacon_module = User.getParameter("default_beacon_module")
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  if category ~= nil and default_beacon_module ~= nil and default_beacon_module[category] ~= nil then
    return default_beacon_module[category]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Set default beacon module
--
-- @function [parent=#User] setDefaultBeaconModule
--
-- @param #table recipe
--
function User.setDefaultBeaconModule(recipe)
  local default_beacon_module = User.getParameter("default_beacon_module") or {}
  local recipe_prototype = RecipePrototype(recipe)
  local category = recipe_prototype:getCategory()
  if category ~= nil then
    default_beacon_module[category] = recipe.beacon.module_priority
    User.setParameter("default_beacon_module", default_beacon_module)
  end
end

-------------------------------------------------------------------------------
-- Get version
--
-- @function [parent=#User] getVersion
--
function User.getVersion()
  local parameter = User.get()
  return parameter["version"] or ""
end

-------------------------------------------------------------------------------
-- Set version
--
-- @function [parent=#User] setVersion
--
function User.setVersion()
  local parameter = User.get()
  parameter["version"] = User.version
  return User.version
end

-------------------------------------------------------------------------------
-- Set
--
-- @function [parent=#User] set
--
-- @param #string property
-- @param #object value
--
function User.set(property, value)
  User.setVersion()
  local parameter = User.get()
  parameter[property] = value
  return value
end

-------------------------------------------------------------------------------
-- Set parameter
--
-- @function [parent=#User] setParameter
--
-- @param #string property
-- @param #object value
--
function User.setParameter(property, value)
  --Logging:debug(User.classname, property, value)
  if property == nil then
    Logging:error(User.classname, "property must not nil", value)
    return nil
  end
  User.setVersion()
  local parameter = User.get("parameter")
  parameter[property] = value
  return value
end

-------------------------------------------------------------------------------
-- Get navigate
--
-- @function [parent=#User] getNavigate
--
-- @param #string property
--
function User.getNavigate(property)
  local navigate = User.get("navigate")
  if navigate ~= nil and property ~= nil then
    return navigate[property]
  end
  return navigate
end

-------------------------------------------------------------------------------
-- Set navigate
--
-- @function [parent=#User] setNavigate
--
-- @param #string property
-- @param #object value
--
function User.setNavigate(property, value)
  User.setVersion()
  local navigate = User.get("navigate")
  navigate[property] = value
  return value
end

-------------------------------------------------------------------------------
-- Get user settings
--
-- @function [parent=#User] getSetting
--
-- @param #string property
--
function User.getSetting(property)
  local settings = User.get("settings")
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
-- Set setting
--
-- @function [parent=#User] setSetting
--
-- @param #string property
-- @param #object value
--
function User.setSetting(property, value)
  User.setVersion()
  local settings = User.get("settings")
  settings[property] = value
  return value
end

-------------------------------------------------------------------------------
-- Get settings
--
-- @function [parent=#User] getModSetting
--
-- @param #string name
--
function User.getModSetting(name)
  Logging:trace(User.classname, "getModSetting(name)", name)
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
    Logging:error(User.classname, "Mod settings property not found:", property_name)
    return helmod_settings_mod[name].default_value
  end
end

-------------------------------------------------------------------------------
-- Get settings
--
-- @function [parent=#User] getModGlobalSetting
--
-- @param #string name
--
function User.getModGlobalSetting(name)
  Logging:trace(User.classname, "getModGlobalSetting(name, global)", name)
  local property = nil
  local property_name = string.format("%s_%s",User.prefixe,name)
  property = settings.global[property_name]
  if property ~= nil then
    return property.value
  else
    Logging:warn(User.classname, "Mod Global settings property not found:", property_name)
    return helmod_settings_mod[name].default_value
  end
end

-------------------------------------------------------------------------------
-- Reset global variable for user
--
-- @function [parent=#User] reset
--
function User.reset()
  local user_name = User.name()
  global["users"][user_name] = {}
end

-------------------------------------------------------------------------------
-- Reset global variable for all user
--
-- @function [parent=#User] resetAll
--
function User.resetAll()
  global["users"] = {}
end

-------------------------------------------------------------------------------
-- Set Close Form
--
-- @function [parent=#User] setCloseForm
--
-- @param #string classname
-- @param #table location
--
function User.setCloseForm(classname, location)
  Logging:debug(User.classname, "setCloseForm()", classname)
  local navigate = User.getNavigate()
  if navigate[classname] == nil then navigate[classname] = {} end
  navigate[classname]["open"] = false
  if string.find(classname, "Tab") then
    if navigate[User.tab_name] == nil then navigate[User.tab_name] = {} end
    navigate[User.tab_name]["location"] = location
    game.tick_paused = false
  else
    navigate[classname]["location"] = location
  end
end

-------------------------------------------------------------------------------
-- Get location Form
--
-- @function [parent=#User] getLocationForm
--
-- @param #string classname
-- @param #table location
--
-- @return #table
--
function User.getLocationForm(classname)
  Logging:debug(User.classname, "getLocationForm()", classname)
  local navigate = User.getNavigate()
  if string.find(classname, "Tab") then
    if navigate[User.tab_name] == nil or navigate[User.tab_name]["location"] == nil then return {50,50} end
    return navigate[User.tab_name]["location"]
  else
    if navigate[classname] == nil or navigate[classname]["location"] == nil then return {200,100} end
    return navigate[classname]["location"]
  end
end

-------------------------------------------------------------------------------
-- Set Active Form
--
-- @function [parent=#User] setActiveForm
--
-- @param #string classname
--
function User.setActiveForm(classname)
  Logging:debug(User.classname, "setActiveForm()", classname)
  local navigate = User.getNavigate()
  if string.find(classname, "Edition") then
    for form_name,form in pairs(navigate) do
      if Controller.getView(form_name) ~= nil and form_name ~= classname and string.find(form_name, "Edition") then
        Controller.getView(form_name):close()
      end
    end
  end
  if string.find(classname, "Tab") then
    if navigate[User.tab_name] == nil then navigate[User.tab_name] = {} end
    navigate[User.tab_name]["open"] = true
    navigate[User.tab_name]["name"] = classname
    if not(game.is_multiplayer()) and User.getParameter("auto-pause") then
      game.tick_paused = true
    else
      game.tick_paused = false
    end
  else
    if navigate[classname] == nil then navigate[classname] = {} end
    navigate[classname]["open"] = true
  end
end

-------------------------------------------------------------------------------
-- Is Active Form
--
-- @function [parent=#User] isActiveForm
--
-- @param #string classname
--
-- @return #boolean
--
function User.isActiveForm(classname)
  Logging:debug(User.classname, "isActiveForm()", classname)
  local navigate = User.getNavigate()
  if string.find(classname, "Tab") and navigate[User.tab_name] ~= nil then
    return navigate[User.tab_name]["open"] == true and navigate[User.tab_name]["name"] == classname
  elseif navigate[classname] ~= nil then
    return navigate[classname]["open"] == true
  end
  return false
end

-------------------------------------------------------------------------------
-- Is Active Form
--
-- @function [parent=#User] isActiveForm
--
-- @param #string classname
--
-- @return #boolean
--
function User.update()
  if User.getVersion() < User.version then
    User.reset()
  end
end

-------------------------------------------------------------------------------
-- Add translate
--
-- @function [parent=#User] addTranslate
--
-- @param #table request {player_index=number, localised_string=#string, result=#string, translated=#boolean}
--
function User.addTranslate(request)
  --Logging:debug(User.classname, "addTranslate()", request)
  if request.translated == true then
    local localised_string = request.localised_string
    local string_translated = request.result
    --Logging:debug(User.classname, "-> addTranslate", localised_string, string_translated)
    if type(localised_string) == "table" then
      local localised_value = localised_string[1]
      --Logging:debug(User.classname, "--> localised_value", localised_value)
      if localised_value ~= nil and localised_value ~= "" then
        local _,key = string.match(localised_value,"([^.]*).([^.]*)")
        --Logging:debug(User.classname, "---> key", key)
        if key ~= nil and key ~= "" then
          local translated = User.get("translated")
          translated[key] = string_translated
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Is translate
--
-- @function [parent=#User] isTranslate
--
function User.isTranslate()
  local translated = User.get("translated")
  return translated ~= nil and Model.countList(translated) > 0
end

-------------------------------------------------------------------------------
-- Get translate
--
-- @function [parent=#User] getTranslate
--
-- @param #string name
--
function User.getTranslate(name)
  local translated = User.get("translated")
  if translated == nil or translated[name] == nil then return name end
  return translated[name]
end

-------------------------------------------------------------------------------
-- Reset translate
--
-- @function [parent=#User] resetTranslate
--
function User.resetTranslate()
  local data_user = User.get()
  data_user["translated"] = {}
end

return User
