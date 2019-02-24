require "core.Form"
require "core.MainPanel"
require "dialog.Dialog"
require "dialog.HelpPanel"
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
require "tab.MainTab"

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
Converter = require "core.Converter"

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
  local main_panel = MainPanel:new()
  table.insert(controllers, main_panel)
  table.insert(controllers, MainTab:new(main_panel))
  table.insert(controllers, Settings:new(main_panel))
  table.insert(controllers, HelpPanel:new(main_panel))
  table.insert(controllers, Download:new(main_panel))
  table.insert(controllers, EntitySelector:new(main_panel))
  table.insert(controllers, RecipeSelector:new(main_panel))
  table.insert(controllers, RecipeEdition:new(main_panel))
  table.insert(controllers, ResourceEdition:new(main_panel))
  table.insert(controllers, ProductEdition:new(main_panel))
  table.insert(controllers, EnergyEdition:new(main_panel))
  table.insert(controllers, RuleEdition:new(main_panel))
  table.insert(controllers, PinPanel:new(main_panel))
  table.insert(controllers, StatusPanel:new(main_panel))
  table.insert(controllers, TechnologySelector:new(main_panel))
  table.insert(controllers, ItemSelector:new(main_panel))
  table.insert(controllers, FluidSelector:new(main_panel))
  table.insert(controllers, ContainerSelector:new(main_panel))

  views = {}
  for _,controller in pairs(controllers) do
    views[controller:classname()] = controller
  end
end

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Controller] getViews
--
-- @return #table
--
function Controller.getViews()
  return views
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
-- On click event
--
-- @function [parent=#Controller] onGuiClick
--
-- @param event
--
function Controller.onGuiClick(event)
  Logging:trace(Controller.classname, "on_gui_click(event)")
  if views == nil then Controller.init() end
  if event.element and event.element.valid then
    if event.element.name == "helmod_planner-command" then
      local main_panel = Controller.getView("HMMainPanel")
      main_panel:main()
    end

    if event.element.name == Controller.classname.."=CLOSE" then
      Controller.cleanController(Player.native())
    end
    Controller.parseEvent(event)
  end
end

-------------------------------------------------------------------------------
-- Parse event
--
-- @function [parent=#Controller] parseEvent
--
-- @param event
-- @param type event type
--
function Controller.parseEvent()
  Logging:debug(Controller.classname, "parseEvent()", Event)
  Event.state = Event.STATE_RELEASE
  nextEvent = nil
  local ok , err = pcall(function()
  if views == nil then Controller.init() end
  if views ~= nil then
    -- settings action
    local main_panel = Controller.getView("HMMainPanel")
    if Event.isSettings() then
      Logging:trace(Controller.classname, "parse_event(): settings=", Event.getElementName())
      Controller.bindController(Player.native())
      if main_panel:isOpened() then
        main_panel:main()
        main_panel:main()
      else
      -- prevent change location
        Controller.cleanController(Player.native())
      end
    end
    -- hotkey action
    if Event.isHotkey() then
      Logging:trace(Controller.classname, "parse_event(): hotkey=", Event.getElementName())
      if Event.getName() == "helmod-close" then
        if main_panel:isOpened() then
          main_panel:main()
        end
      end
      if Event.getName() == "helmod-open-close" then
        main_panel:main()
      end
      if Event.getName() == "helmod-production-line-open" then
        if not(main_panel:isOpened()) then
          main_panel:main()
        end
        Controller.sendEvent(Event.native(), "HMMainTab", "change-tab", "HMProductionLineTab")
      end
      if Event.getName() == "helmod-recipe-selector-open" then
        if not(main_panel:isOpened()) then
          main_panel:main()
        end
        Controller.sendEvent(Event.native(), "HMRecipeSelector", "OPEN")
      end
    end
    -- button action
    if Event.isButton() or Event.next then
      Logging:debug(Controller.classname, "button action")
      if Event.name == "helmod_planner-command" then
        local main_panel = Controller.getView("HMMainPanel")
        main_panel:main()
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
          end
          Logging:debug(Controller.classname, "event state", Event.state)
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
  if views ~= nil and views[classname] then
    local form = views[classname]
    Logging:debug(Controller.classname, "form state begin", form:classname(), form.state)
    if action == "CLOSE" then
      form:close(true)
    else
      if form.state == form.STATE_CLOSE or form.state == form.STATE_EVENT then
        Logging:debug(Controller.classname, "*** event", form:classname(), form.state)
        form.state = form.STATE_OPEN
        form:onEvent(event, action, item, item2, item3)
      end
      if form.state == form.STATE_OPEN then
        Logging:debug(Controller.classname, "*** Open", form:classname(), form.state)
        form:beforeOpen(event, action, item, item2, item3)
        form.state = form.STATE_UPDATE
        form:open(event, action, item, item2, item3)
      end
      if form.state == form.STATE_UPDATE then
        Logging:debug(Controller.classname, "*** update", form:classname(), form.state)
        form.state = form.STATE_EVENT
        form:update(event, action, item, item2, item3)
      end
    end
    Logging:debug(Controller.classname, "form state end", form:classname(), form.state)
    -- release state in the event without stage
    return form.state == form.STATE_UPDATE and form.state ~= nil
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
end

-------------------------------------------------------------------------------
-- Refresh display data
--
-- @function [parent=#Controller] refreshDisplayData
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.refreshDisplayData(player, item, item2, item3)
  Logging:debug(Controller.classname, "refreshDisplayData():",player, item, item2, item3)
  Controller.getView("HMMainTab"):update(player, item, item2, item3)
  local pin_panel = Controller.getView("HMPinPanel")
  if pin_panel:isOpened() then
    pin_panel:update()
  end
end

-------------------------------------------------------------------------------
-- Refresh pin data
--
-- @function [parent=#Controller] refreshPin
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.refreshPin(player, item, item2, item3)
  Logging:debug(Controller.classname, "refreshPin():",player, item, item2, item3)
  local pin_panel = Controller.getView("HMPinPanel")
  if pin_panel:isOpened() then
    pin_panel:update()
  end
end

-------------------------------------------------------------------------------
-- Refresh display
--
-- @function [parent=#Controller] refreshDisplay
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Controller.refreshDisplay(player, item, item2, item3)
  Logging:debug(Controller.classname, "refreshDisplay():",player, item, item2, item3)
  local main_panel = Controller.getView("HMMainPanel")
  main_panel:main()
  main_panel:main()
end

return Controller
