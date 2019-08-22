require "core.Form"
require "dialog.HelpPanel"
require "dialog.LeftMenuPanel"
require "dialog.MainMenuPanel"
require "dialog.PinPanel"
require "dialog.StatusPanel"
require "dialog.Settings"
require "dialog.Download"
require "edition.RecipeEdition"
require "edition.ProductEdition"
require "edition.ResourceEdition"
require "edition.EnergyEdition"
require "edition.RuleEdition"
require "selector.EntitySelector"
require "selector.RecipeSelector"
require "selector.TechnologySelector"
require "selector.ItemSelector"
require "selector.FluidSelector"
require "selector.ContainerSelector"

require "tab.EnergyTab"
require "tab.ProductionBlockTab"
require "tab.ProductionLineTab"
require "tab.ResourceTab"
require "tab.SummaryTab"
require "tab.StatisticTab"
require "tab.PropertiesTab"
require "tab.PrototypeFiltersTab"
require "tab.AdminTab"

require "edition.ProductLineEdition"
require "edition.ProductBlockEdition"

Cache = require "core.Cache"
Model = require "model.Model"
ModelCompute = require "core.ModelCompute"
ModelBuilder = require "core.ModelBuilder"
EntityType = require "model.EntityType"
EntityPrototype = require "model.EntityPrototype"
FluidPrototype = require "model.FluidPrototype"
ItemPrototype = require "model.ItemPrototype"
Product = require "model.Product"
RecipePrototype = require "model.RecipePrototype"
Technology = require "model.Technology"
Prototype = require "model.Prototype"
PrototypeFilter = require "model.PrototypeFilter"
Converter = require "core.Converter"

PLANNER_COMMAND = "helmod_planner-command"

---
-- Description of the module.
-- @module Controller
--
local Controller = {
  -- single-line comment
  classname = "HMController"
}

local views = nil
local locate = "center"
local pinLocate = "left"
local nextEvent = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Controller] init
--
function Controller.init()
  Logging:debug(Controller.classname, "init()")

  local controllers = {}
  table.insert(controllers, MainMenuPanel:new())
  table.insert(controllers, LeftMenuPanel:new())

  table.insert(controllers, Settings:new())
  table.insert(controllers, HelpPanel:new())
  table.insert(controllers, Download:new())

  table.insert(controllers, ProductionLineTab:new())
  table.insert(controllers, ProductionBlockTab:new())
  table.insert(controllers, EnergyTab:new())
  table.insert(controllers, ResourceTab:new())
  table.insert(controllers, SummaryTab:new())
  table.insert(controllers, StatisticTab:new())
  table.insert(controllers, PropertiesTab:new())
  table.insert(controllers, PrototypeFiltersTab:new())
  table.insert(controllers, AdminTab:new())

  table.insert(controllers, EntitySelector:new())
  table.insert(controllers, RecipeSelector:new())
  table.insert(controllers, RecipeEdition:new())
  table.insert(controllers, ResourceEdition:new())
  table.insert(controllers, ProductEdition:new())
  table.insert(controllers, EnergyEdition:new())
  table.insert(controllers, RuleEdition:new())
  table.insert(controllers, PinPanel:new())
  table.insert(controllers, StatusPanel:new())
  table.insert(controllers, TechnologySelector:new())
  table.insert(controllers, ItemSelector:new())
  table.insert(controllers, FluidSelector:new())
  table.insert(controllers, ContainerSelector:new())

  table.insert(controllers, ProductLineEdition:new())
  table.insert(controllers, ProductBlockEdition:new())
  views = {}
  for _,controller in pairs(controllers) do
    views[controller:classname()] = controller
  end

end

-------------------------------------------------------------------------------
-- Get views
--
-- @function [parent=#Controller] getViews
--
-- @return #table
--
function Controller.getViews()
  return views
end

-------------------------------------------------------------------------------
-- Reset caches
--
-- @function [parent=#Controller] resetCaches
--
-- @return #table
--
function Controller.resetCaches()
  Cache.reset()
end

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Controller] getView
--
-- @param #string name
--
-- @return #table
--
function Controller.getView(name)
  return views[name]
end

-------------------------------------------------------------------------------
-- Cleanup
--
-- @function [parent=#Controller] cleanController
--
-- @param #LuaPlayer player
--
function Controller.cleanController(player)
  Logging:trace(Controller.classname, "cleanController(player)")
  for _,location in pairs(helmod_settings_mod.display_location.allowed_values) do
    if player.gui[location]["helmod_main_panel"] ~= nil then
      player.gui[location]["helmod_main_panel"].destroy()
    end
  end
end

-------------------------------------------------------------------------------
-- Bind all controllers
--
-- @function [parent=#Controller] bindController
--
-- @param #LuaPlayer player
--
function Controller.bindController(player)
  Logging:trace(Controller.classname, "bindController()")
  if player ~= nil then
    local gui_top = Player.getGuiTop(player)
    if gui_top["helmod_menu-main"] ~= nil then gui_top["helmod_menu-main"].destroy() end
    if not(Player.getSettings("display_main_icon")) then
      if gui_top["helmod_planner-command"] ~= nil then gui_top["helmod_planner-command"].destroy() end
    end
    if gui_top ~= nil and gui_top["helmod_planner-command"] == nil and Player.getSettings("display_main_icon") then
      local gui_button = ElementGui.addGuiFrameH(gui_top, "helmod_planner-command", helmod_frame_style.default)
      gui_button.add({type="button", name="helmod_planner-command", tooltip=({"helmod_planner-command"}), style="helmod_icon"})
    end
  end
end

-------------------------------------------------------------------------------
-- On tick
--
-- @function [parent=#Controller] onTick
--
-- @param #table event
--
function Controller.onTick(event)
  Logging:trace(Controller.classname, "onTick(event)", event)
  if(Event.state ~= Event.STATE_RELEASE) then
    Controller.parseEvent()
  end
end

-------------------------------------------------------------------------------
-- On gui closed
--
-- @function [parent=#Controller] onGuiClosed
--
-- @param #table event
--
function Controller.onGuiClosed(event)
  Logging:trace(Controller.classname, "onGuiClosed(event)", event)
  Controller.cleanController(Player.native())
end

-------------------------------------------------------------------------------
-- Parse event
--
-- @function [parent=#Controller] parseEvent
--
function Controller.parseEvent()
  Logging:debug(Controller.classname, "parseEvent()")
  Event.state = Event.STATE_RELEASE
  nextEvent = nil
  local ok , err = pcall(function()
    if views == nil then Controller.init() end
    if views ~= nil then
      -- settings action
      if Event.isSettings() then
        Logging:trace(Controller.classname, "parse_event(): settings=", Event.getElementName())
        Controller.bindController(Player.native())
        if Controller.isOpened() then
          Controller.cleanController(Player.native())
          Controller.openMainPanel()
        else
          -- prevent change location
          Controller.cleanController(Player.native())
        end
      end
      -- hotkey action
      if Event.isHotkey() then
        Logging:debug(Controller.classname, "parse_event(): hotkey=", Event.getElementName())
        if Event.getName() == "helmod-close" then
          if Controller.isOpened() then
            Controller.cleanController(Player.native())
          end
        end
        if Event.getName() == "helmod-open-close" then
          Controller.openMainPanel()
        end
        if Event.getName() == "helmod-production-line-open" then
          if not(Controller.isOpened()) then
            Controller.openMainPanel()
          end
          Controller.sendEvent(Event.native(), "HMController", "change-tab", "HMProductionLineTab")
        end
        if Event.getName() == "helmod-recipe-selector-open" then
          if not(Controller.isOpened()) then
            Controller.openMainPanel()
          end
          Controller.sendEvent(Event.native(), "HMRecipeSelector", "OPEN")
        end
      end
      -- Open form
      if Controller.isOpened() then
      --Controller.openFormPanel(Event.native(), Event.name, Event.action, Event.item1, Event.item2, Event.item3)
      end
      -- button action
      if Event.isButton() or Event.next then
        Logging:debug(Controller.classname, "button action")
        if Event.name == Controller.classname and Event.action == "CLOSE" then
          Controller.cleanController(Player.native())
        elseif Event.name == "helmod_planner-command" then
          Controller.openMainPanel()
        else
          if views ~= nil and views[Event.name] then
            local continue = Controller.sendEvent(Event.native(), Event.name, Event.action, Event.item1, Event.item2, Event.item3)
            if(continue) then
              -- release state in the event without stage
              Event.state = Event.STATE_CONTINUE
            end
            if(nextEvent) then
              Event.setNext(nextEvent.name, nextEvent.action, nextEvent.item1, nextEvent.item2, nextEvent.item3)
              nextEvent = nil
              Event.state = Event.STATE_CONTINUE
              Event.force_refresh = true
              Event.prepare = false
            end
            Logging:debug(Controller.classname, "event state", Event.state)
            if(Event.state == Event.STATE_RELEASE) then
              Event.finaly()
            end
          end
        end
      end
    end
  end)
  if not(ok) then
    Player.print(err)
    log(err)
  end
end

-------------------------------------------------------------------------------
-- Send event dialog
--
-- @function [parent=#Controller] sendEvent
--
-- @param #lua_event event
-- @param #string classname controller name
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.sendEvent(event, classname, action, item, item2, item3)
  Logging:debug(Controller.classname, "send_event(event, classname, action, item, item2, item3)", classname, action, item, item2, item3)
  if Event.prepare == false then
    Controller.onEvent(event, action, item, item2, item3)
  end
  if views ~= nil and views[classname] then
    local ui = Player.getGlobalUI()
    if action == "CLOSE" then
      views[classname]:close(true)
    end
    local form_loop = { "data"}
    if string.find(classname, "Pin") then form_loop = {"pin"} end

    if Event.prepare == false then
      Logging:debug(Controller.classname, "===== prepare", game.tick)
      if action == "OPEN" then
        Controller.setActiveForm(classname)
      end

      Logging:debug(Controller.classname, "***** before event: ui", ui)

      for form_name,form_ui in pairs(ui) do
        Logging:debug(Controller.classname, "before event", form_name, classname)
        if views[form_name] ~= nil and form_name == classname and Controller.isActiveForm(form_name) then
          views[form_name]:beforeEvent(event, action, item, item2, item3)
        end
      end

      for form_name,form_ui in pairs(ui) do
        Logging:debug(Controller.classname, "***** on event", form_name, classname)
        if views[form_name] ~= nil and form_name == classname and Controller.isActiveForm(form_name) then
          views[form_name]:onEvent(event, action, item, item2, item3)
        end
      end
      Logging:debug(Controller.classname, "***** after event: ui", ui)

      for form_name,form_ui in pairs(ui) do
        Logging:debug(Controller.classname, "***** locate", ui, locate)
        if form_name ~= nil then
          if views[form_name] ~= nil and Controller.isActiveForm(form_name) then
            local prepared = views[form_name]:prepare(event, action, item, item2, item3)
            if(prepared == true) then
              Event.prepare = prepared
            end
          else
            Logging:error(Controller.classname, "Prepare locate", ui, locate)
          end
        end
      end
      if(Event.prepare == true) then
        return true
      end
    end

    Logging:debug(Controller.classname, "===== open and update", game.tick)
    for form_name,form_ui in pairs(ui) do
      if form_name ~= nil then
        if views[form_name] ~= nil and Controller.isActiveForm(form_name) then
          if action == "OPEN" or Event.force_open == true then
            Logging:debug(Controller.classname, "***** open form")
            views[form_name]:open(event, action, item, item2, item3)
          end
          if not(action ~= "OPEN" and form_name == classname) or Event.force_refresh == true then
            Logging:debug(Controller.classname, "***** update form")
            views[form_name]:update(event, action, item, item2, item3)
          end
        else
          Logging:error(Controller.classname, "Open or Update locate", ui, locate)
        end
      end
    end
    return false
  end
  return false
end

-------------------------------------------------------------------------------
-- Send event dialog
--
-- @function [parent=#Controller] createEvent
--
-- @param #lua_event event
-- @param #string classname controller name
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.createEvent(event, classname, action, item, item2, item3)
  Logging:debug(Controller.classname, "createEvent(event, classname, action, item, item2, item3)", classname, action, item, item2, item3)
  nextEvent = {name=classname, action=action, item1=item, item2=item2, item3=item3}
  Event.force_refresh = true
end

-------------------------------------------------------------------------------
-- Prepare main display
--
-- @function [parent=#Controller] openMainPanel
--
function Controller.openMainPanel()
  Logging:debug(Controller.classname, "openMainPanel()")
  local lua_player = Player.native()
  local location = Player.getSettings("display_location")
  local globalGui = Player.getGlobalGui()
  local model = Model.getModel()
  local gui_main = lua_player.gui[location]
  if Controller.isOpened() then
    Controller.cleanController(Player.native())
  else
    local form_name
    if globalGui.currentBlock and model.blocks[globalGui.currentBlock] then
      form_name = "HMProductionBlockTab"
    else
      form_name = "HMProductionLineTab"
    end
    Event.force_refresh = true
    Controller.sendEvent(nil, form_name, "OPEN")
  end
end

-------------------------------------------------------------------------------
-- Is opened main panel
--
-- @function [parent=#Controller] isOpened
--
function Controller.isOpened()
  Logging:trace(Controller.classname, "isOpened()")
  local lua_player = Player.native()
  if lua_player == nil then return false end
  local location = Player.getSettings("display_location")
  local guiMain = lua_player.gui[location]
  if guiMain["helmod_main_panel"] ~= nil then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.onEvent(event, action, item, item2, item3)
  Logging:debug(Controller.classname, "onEvent()", action, item, item2, item3)
  local model = Model.getModel()

  -- *******************************
  -- access admin only
  -- *******************************

  if Player.isAdmin() then
    Controller.onEventAccessAdmin(event, action, item, item2, item3)
  end

  -- *******************************
  -- access admin or owner or write
  -- *******************************

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    Controller.onEventAccessWrite(event, action, item, item2, item3)
  end

  -- ***************************
  -- access admin or owner
  -- ***************************

  if Player.isAdmin() or model.owner == Player.native().name then
    Controller.onEventAccessRead(event, action, item, item2, item3)
  end

  -- ********************************
  -- access admin or owner or delete
  -- ********************************

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
    Controller.onEventAccessDelete(event, action, item, item2, item3)
  end

  -- ***************************
  -- access for all
  -- ***************************
  Controller.onEventAccessAll(event, action, item, item2, item3)

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessAll
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.onEventAccessAll(event, action, item, item2, item3)
  Logging:debug(Controller.classname, "onEventAccessAll()", action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local ui = Player.getGlobalUI()

  if action == "refresh-model" then
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "change-model" then
    globalGui.model_id = item
    Model.getModel()
    Controller.setActiveForm("HMProductionLineTab")
    globalGui.currentBlock = "new"
    Event.force_refresh = true
    Event.force_open = true
  end

  if action == "change-tab" then
    Controller.setActiveForm(item)
    if item == "HMProductionLineTab" then
      globalGui.currentBlock = "new"
    else
      globalGui.currentBlock = item2
    end
    Event.force_refresh = true
    Event.force_open = true
  end

  if action == "change-sort" then
    if globalGui.order.name == item then
      globalGui.order.ascendant = not(globalGui.order.ascendant)
    else
      globalGui.order = {name=item, ascendant=true}
    end
    Event.force_refresh = true
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessRead
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.onEventAccessRead(event, action, item, item2, item3)
  Logging:debug(Controller.classname, "onEventAccessRead()", action, item, item2, item3)

  local globalGui = Player.getGlobalGui()
  local ui = Player.getGlobalUI()

  if action == "copy-model" then
    if Controller.isActiveForm("HMProductionBlockTab") then
      if globalGui.currentBlock ~= nil and globalGui.currentBlock ~= "new" then
        globalGui.copy_from_block_id = globalGui.currentBlock
        globalGui.copy_from_model_id = Player.getGlobalGui("model_id")
      end
    end
    if Controller.isActiveForm("HMProductionLineTab") then
      globalGui.copy_from_block_id = nil
      globalGui.copy_from_model_id = Player.getGlobalGui("model_id")
    end
    Event.force_refresh = true
  end
  if action == "share-model" then
    local models = Model.getModels(true)
    local model = models[item2]
    if model ~= nil then
      if item == "read" then
        if model.share == nil or not(bit32.band(model.share, 1) > 0) then
          model.share = 1
        else
          model.share = 0
        end
      end
      if item == "write" then
        if model.share == nil or not(bit32.band(model.share, 2) > 0) then
          model.share = 3
        else
          model.share = 1
        end
      end
      if item == "delete" then
        if model.share == nil or not(bit32.band(model.share, 4) > 0) then
          model.share = 7
        else
          model.share = 3
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessWrite
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.onEventAccessWrite(event, action, item, item2, item3)
  Logging:debug(Controller.classname, "onEventAccessWrite()", action, item, item2, item3)
  local global_player = Player.getGlobal()
  local globalGui = Player.getGlobalGui()
  local ui = Player.getGlobalUI()
  local model = Model.getModel()
  
  if action == "change-tab" then
    if item == "HMProductionBlockTab" and item2 == "new" then
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end
  
  if action == "change-boolean-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
    local element = model.blocks[globalGui.currentBlock]
    ModelBuilder.updateProductionBlockOption(globalGui.currentBlock, item, not(element[item]))
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "change-number-option" and model.blocks ~= nil and model.blocks[globalGui.currentBlock] ~= nil then
    local value = ElementGui.getInputNumber(event.element)
    ModelBuilder.updateProductionBlockOption(globalGui.currentBlock, item, value)
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "change-time" then
    model.time = tonumber(item) or 1
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "product-selected" then
    Logging:debug(Controller.classname, "product-selected", event.button, defines.mouse_button_type.right)
    if event.button == defines.mouse_button_type.right then
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end

  if action == "product-edition" then
    if event.button == defines.mouse_button_type.right then
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    else
      Controller.createEvent(event, "HMProductEdition", "OPEN", item, item2, item3)
    end
  end

  if action == "production-block-unlink" then
    ModelBuilder.unlinkProductionBlock(item)
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "production-recipe-add" then
    local recipes = Player.searchRecipe(item3)
    if #recipes == 1 then
      local recipe = recipes[1]
      ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
      ModelCompute.update()
      globalGui["scroll_down"] = true
      Event.force_refresh = true
    else
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end

  if action == "production-block-solver" then
    if model.blocks[item] ~= nil then
      ModelBuilder.updateProductionBlockOption(item, "solver", not(model.blocks[item].solver))
      ModelCompute.update()
      Event.force_refresh = true
    end
  end

  if action == "production-block-remove" then
    ModelBuilder.removeProductionBlock(item)
    ModelCompute.update()
    globalGui.currentBlock = "new"
    Event.force_refresh = true
  end

  if Controller.isActiveForm("HMProductionLineTab") then
    if action == "production-block-add" then
      local recipes = Player.searchRecipe(item2)
      if #recipes == 1 then
        local recipe = recipes[1]
        ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
        ModelCompute.update()
        Event.force_refresh = true
        Event.force_open = true
      else
        Controller.createEvent(nil, "HMRecipeSelector", "OPEN", item, item2, item3)
      end
      Controller.setActiveForm("HMProductionBlockTab")
    end

    if action == "production-block-up" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionBlock(item, step)
      ModelCompute.update()
      Event.force_refresh = true
    end

    if action == "production-block-down" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionBlock(item, step)
      ModelCompute.update()
      Event.force_refresh = true
    end
  end

  if Controller.isActiveForm("HMProductionBlockTab") then
    if action == "production-recipe-remove" then
      ModelBuilder.removeProductionRecipe(item, item2)
      ModelCompute.update()
      Event.force_refresh = true
    end

    if action == "production-recipe-up" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionRecipe(item, item2, step)
      ModelCompute.update()
      Event.force_refresh = true
    end

    if action == "production-recipe-down" then
      local step = 1
      if event.shift then step = Player.getSettings("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionRecipe(item, item2, step)
      ModelCompute.update()
      Event.force_refresh = true
    end
  end

  if ui.data == "HMEnergyTab" then
    if action == "power-remove" then
      ModelBuilder.removePower(item)
      Event.force_refresh = true
    end
  end

  if action == "past-model" then
    if Controller.isActiveForm("HMProductionBlockTab") then
      ModelBuilder.pastModel(globalGui.copy_from_model_id, globalGui.copy_from_block_id)
      ModelCompute.update()
      Event.force_refresh = true
    end
    if Controller.isActiveForm("HMProductionLineTab") then
      ModelBuilder.pastModel(globalGui.copy_from_model_id, globalGui.copy_from_block_id)
      ModelCompute.update()
      globalGui.currentBlock = "new"
      Event.force_refresh = true
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessDelete
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.onEventAccessDelete(event, action, item, item2, item3)
  Logging:debug(Controller.classname, "onEventAccessDelete()", action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local ui = Player.getGlobalUI()
  if action == "remove-model" then
    ModelBuilder.removeModel(item)
    Controller.setActiveForm("HMProductionLineTab")
    globalGui.currentBlock = "new"
    Event.force_refresh = true
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessAdmin
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.onEventAccessAdmin(event, action, item, item2, item3)
  Logging:debug(Controller.classname, "onEventAccessAdmin()", action, item, item2, item3)
  if action == "rule-remove" then
    ModelBuilder.removeRule(item)
    Event.force_refresh = true
  end
  if action == "reset-rules" then
    Model.resetRules()
    Event.force_refresh = true
  end

end

-------------------------------------------------------------------------------
-- Set Close Form
--
-- @function [parent=#Controller] setCloseForm
--
-- @param #string classname
-- @param #table location
--
function Controller.setCloseForm(classname, location)
  Logging:debug(Controller.classname, "setCloseForm()", classname)
  local ui = Player.getGlobalUI()
  if ui[classname] == nil then ui[classname] = {} end
  ui[classname]["open"] = false
  if string.find(classname, "Tab") then
    if ui["Tab"] == nil then ui["Tab"] = {} end
    ui["Tab"]["location"] = location
  else
    ui[classname]["location"] = location
  end
end

-------------------------------------------------------------------------------
-- Get location Form
--
-- @function [parent=#Controller] getLocationForm
--
-- @param #string classname
-- @param #table location
--
-- @return #table
--
function Controller.getLocationForm(classname)
  Logging:debug(Controller.classname, "getLocationForm()", classname)
  local ui = Player.getGlobalUI()
  if string.find(classname, "Tab") then
    if ui["Tab"] == nil then return nil end
    return ui["Tab"]["location"]
  else
    if ui[classname] == nil then return nil end
    return ui[classname]["location"]
  end
end

-------------------------------------------------------------------------------
-- Set Active Form
--
-- @function [parent=#Controller] setActiveForm
--
-- @param #string classname
-- 
function Controller.setActiveForm(classname)
  Logging:debug(Controller.classname, "setActiveForm()", classname)
  local ui = Player.getGlobalUI()
  if string.find(classname, "Tab") then
    for form_name,form in pairs(ui) do
      if views[form_name] ~= nil and form_name ~= classname and string.find(form_name, "Tab") then
        Controller.getView(form_name):close(true)
      end
    end
  end
  if ui[classname] == nil then ui[classname] = {} end
  ui[classname]["open"] = true
end

-------------------------------------------------------------------------------
-- Is Active Form
--
-- @function [parent=#Controller] isActiveForm
--
-- @param #string classname
-- 
-- @return #boolean
--
function Controller.isActiveForm(classname)
  Logging:debug(Controller.classname, "isActiveForm()", classname)
  local ui = Player.getGlobalUI()
  if ui[classname] ~= nil then return ui[classname]["open"] end
  return false
end

return Controller
