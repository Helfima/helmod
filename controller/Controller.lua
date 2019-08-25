require "core.Form"
require "dialog.HelpPanel"
require "dialog.PinPanel"
require "dialog.StatusPanel"
require "dialog.Settings"
require "dialog.Download"
require "dialog.Calculator"
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

ModGui = require "mod-gui"
Cache = require "core.Cache"
User = require "model.User"
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
  table.insert(controllers, HelpPanel:new())
  table.insert(controllers, Download:new())
  table.insert(controllers, Calculator:new())

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
  for _,location in pairs({"center", "left", "top", "screen"}) do
    local lua_gui_element = player.gui[location]
    for _,children_name in pairs(lua_gui_element.children_names) do
      if string.find(children_name,"helmod") then
        lua_gui_element[children_name].destroy()
      end
      if Controller.getView(children_name) and children_name ~= "HMPinPanel" then
        Controller.getView(children_name):close()
      end
      if children_name == "HMTab" then
        for _,form in pairs(Controller.getViews()) do
          if form:getPanelName() == "HMTab" then
            form:close()
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- closeEditionOrSelector
--
-- @function [parent=#Controller] closeEditionOrSelector
--
-- @param #LuaPlayer player
--
function Controller.closeEditionOrSelector()
  Logging:trace(Controller.classname, "closeEditionOrSelector()")
    local lua_gui_element = Player.getGui("screen")
    for _,children_name in pairs(lua_gui_element.children_names) do
      if Controller.getView(children_name) and (string.find(children_name,"Edition") ~= nil) then
        Controller.getView(children_name):close()
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
    local lua_gui_element = Player.getGui("top")
    if lua_gui_element["helmod_menu-main"] ~= nil then lua_gui_element["helmod_menu-main"].destroy() end
    if lua_gui_element["helmod_planner-command"] ~= nil then lua_gui_element["helmod_planner-command"].destroy() end
    
    lua_gui_element = ModGui.get_button_flow(Player.native())
    if not(User.getModSetting("display_main_icon")) or User.getVersion() < User.version then
      if lua_gui_element["helmod_planner-command"] ~= nil then lua_gui_element["helmod_planner-command"].destroy() end
    end
    if lua_gui_element ~= nil and lua_gui_element["helmod_planner-command"] == nil and User.getModSetting("display_main_icon") then
      --local gui_button = ElementGui.addGuiFrameH(lua_gui_element, "helmod_planner-command", helmod_frame_style.default)
      local gui_button = ElementGui.addGuiButton(lua_gui_element, "helmod_planner-command", nil, "helmod_button_icon_calculator",nil, ({"helmod_planner-command"}))
      gui_button.style.width = 37
      gui_button.style.height = 37
    end
    if User.getVersion() < User.version then
      local message = string.format("%s %s: %s","Helmod",game.active_mods["helmod"], "Now every panel is draggable.")
      Player.print(message)
    end
    User.update()
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
          Controller.sendEvent(Event.native(), "HMRecipeSelector", "OPEN")
        end
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
    local navigate = User.getNavigate()
    if action == "CLOSE" then
      views[classname]:close(true)
    end

    if Event.prepare == false then
      Logging:trace(Controller.classname, "-> prepare", game.tick)
      if action == "OPEN" then
        User.setActiveForm(classname)
      end

      Logging:trace(Controller.classname, "-> before event: navigate", navigate)

      for _,form in pairs(views) do
        local form_name = form:classname()
        Logging:trace(Controller.classname, "--> beforeEvent", form_name, classname)
        if form_name == classname and User.isActiveForm(form_name) then
          form:beforeEvent(event, action, item, item2, item3)
        end
      end

      for _,form in pairs(views) do
        local form_name = form:classname()
        Logging:trace(Controller.classname, "--> onEvent", form_name, classname)
        if form_name == classname and User.isActiveForm(form_name) then
          form:onEvent(event, action, item, item2, item3)
        end
      end
      
      for _,form in pairs(views) do
        local form_name = form:classname()
        Logging:trace(Controller.classname, "--> prepare", form_name)
        if User.isActiveForm(form_name) then
          local prepared = form:prepare(event, action, item, item2, item3)
          if(prepared == true) then
            Event.prepare = prepared
          end
        else
          Logging:warn(Controller.classname, "--> Prepare", form_name)
        end
      end
      if(Event.prepare == true) then
        return true
      end
    end

    Logging:trace(Controller.classname, "-> open and update", game.tick)
    for _,form in pairs(views) do
      local form_name = form:classname()
      Logging:trace(Controller.classname, "--> open and update", form_name, User.isActiveForm(form_name))
      if User.isActiveForm(form_name) then
        if action == "OPEN" or Event.force_open == true then
          Logging:trace(Controller.classname, "---> open form", form_name)
          form:open(event, action, item, item2, item3)
        end
        if not(action ~= "OPEN" and form_name == classname) or Event.force_refresh == true then
          Logging:trace(Controller.classname, "---> update form", form_name)
          form:update(event, action, item, item2, item3)
        end
      else
        Logging:warn(Controller.classname, "---> Open or Update", form_name)
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
  local current_block = User.getParameter("current_block")
  local model = Model.getModel()

  if Controller.isOpened() then
    Controller.cleanController(Player.native())
  else
    local form_name
    if current_block and model.blocks[current_block] then
      form_name = "HMProductionBlockTab"
    else
      form_name = "HMProductionLineTab"
    end
    Event.force_refresh = true
    Event.prepare = false
    Controller.sendEvent(nil, form_name, "OPEN")
    Event.prepare = true
    Controller.sendEvent(nil, form_name, "OPEN")
    Event.finaly()
  end
end

-------------------------------------------------------------------------------
-- Is opened main panel
--
-- @function [parent=#Controller] isOpened
--
function Controller.isOpened()
  Logging:debug(Controller.classname, "isOpened()")
  local lua_player = Player.native()
  if lua_player == nil then return false end
  local gui_screen = Player.getGui("screen")
  local is_open = false
  for _,form_name in pairs(gui_screen.children_names) do
    --if string.find(form_name,"Tab") and Controller.getView(form_name) then
    if form_name == "HMTab" then
      Logging:debug(Controller.classname,"form is open", form_name)
      is_open = true
    end
  end
  return is_open
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

  -- ***************************
  -- access for all
  -- ***************************
  Controller.onEventAccessAll(event, action, item, item2, item3)

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

  if action == "refresh-model" then
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "change-model" then
    User.setParameter("model_id", item)
    Model.getModel()
    User.setActiveForm("HMProductionLineTab")
    User.setParameter("current_block", "new")
    Event.force_refresh = true
    Event.force_open = true
  end

  if action == "change-tab" then
    if item == "HMProductionLineTab" then
      User.setParameter("current_block", "new")
    else
      User.setParameter("current_block", item2)
    end
    Event.force_refresh = true
    Event.force_open = true
    Controller.closeEditionOrSelector()
    Controller.createEvent(event, item, "OPEN", item, item2, item3)
  end

  if action == "change-sort" then
    local order = User.getParameter("order")
    if order.name == item then
      order.ascendant = not(order.ascendant)
    else
      order = {name=item, ascendant=true}
    end
    User.setParameter("order", order)
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

  if action == "copy-model" then
    local model_id = User.getParameter("model_id")
    local current_block = User.getParameter("current_block")
    if User.isActiveForm("HMProductionBlockTab") then
      if current_block ~= nil and current_block ~= "new" then
        User.setParameter("copy_from_block_id", current_block)
        User.setParameter("copy_from_model_id", model_id)
      end
    end
    if User.isActiveForm("HMProductionLineTab") then
      User.setParameter("copy_from_block_id", nil)
      User.setParameter("copy_from_model_id", model_id)
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
  local model = Model.getModel()
  local model_id = User.getParameter("model_id")
  local current_block = User.getParameter("current_block")
      
  if action == "change-tab" then
    if item == "HMProductionBlockTab" and item2 == "new" then
      Controller.createEvent(event, "HMRecipeSelector", "OPEN", item, item2, item3)
    end
  end
  
  if action == "change-boolean-option" and model.blocks ~= nil and model.blocks[current_block] ~= nil then
    local element = model.blocks[current_block]
    ModelBuilder.updateProductionBlockOption(current_block, item, not(element[item]))
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "change-number-option" and model.blocks ~= nil and model.blocks[current_block] ~= nil then
    local value = ElementGui.getInputNumber(event.element)
    ModelBuilder.updateProductionBlockOption(current_block, item, value)
    ModelCompute.update()
    Event.force_refresh = true
  end

  if action == "change-time" then
    local index = event.element.selected_index
    model.time = helmod_base_times[index].value or 1
    Logging:debug(Controller.classname, "change-time", index, helmod_base_times[index], model.time)
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
      User.setParameter("scroll_down",true)
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
    User.setParameter("current_block","new")
    Event.force_refresh = true
  end

  if User.isActiveForm("HMProductionLineTab") then
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
      User.setActiveForm("HMProductionBlockTab")
    end

    if action == "production-block-up" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionBlock(item, step)
      ModelCompute.update()
      Event.force_refresh = true
    end

    if action == "production-block-down" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionBlock(item, step)
      ModelCompute.update()
      Event.force_refresh = true
    end
  end

  if User.isActiveForm("HMProductionBlockTab") then
    if action == "production-recipe-remove" then
      ModelBuilder.removeProductionRecipe(item, item2)
      ModelCompute.update()
      Event.force_refresh = true
    end

    if action == "production-recipe-up" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionRecipe(item, item2, step)
      ModelCompute.update()
      Event.force_refresh = true
    end

    if action == "production-recipe-down" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionRecipe(item, item2, step)
      ModelCompute.update()
      Event.force_refresh = true
    end
  end

  if User.isActiveForm("HMEnergyTab") then
    if action == "power-remove" then
      ModelBuilder.removePower(item)
      Event.force_refresh = true
    end
  end

  if action == "past-model" then
    if User.isActiveForm("HMProductionBlockTab") then
      ModelBuilder.pastModel(User.getParameter("copy_from_model_id"), User.getParameter("copy_from_block_id"))
      ModelCompute.update()
      Event.force_refresh = true
    end
    if User.isActiveForm("HMProductionLineTab") then
      ModelBuilder.pastModel(User.getParameter("copy_from_model_id"), User.getParameter("copy_from_block_id"))
      ModelCompute.update()
      User.setParameter("current_block","new")
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
  if action == "remove-model" then
    ModelBuilder.removeModel(item)
    User.setActiveForm("HMProductionLineTab")
    User.setParameter("current_block","new")
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

return Controller
