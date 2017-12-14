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
require "selector.EntitySelector"
require "selector.RecipeSelector"
require "selector.TechnologySelector"
require "selector.ItemSelector"
require "selector.FluidSelector"
require "selector.ContainerSelector"
require "tab.MainTab"

Model = require "model.Model"
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
    if player.gui[location]["helmod_planner_main"] ~= nil then
      player.gui[location]["helmod_planner_main"].destroy()
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
      local gui_button = ElementGui.addGuiFrameH(gui_top, "helmod_planner-command", "helmod_frame_default")
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
      local player = game.players[event.player_index]
      Controller.cleanController(player)
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
function Controller.parseEvent(event, type)
  Logging:debug(Controller.classname, "parseEvent(event)", event, type)
  local ok , err = pcall(function()
  if views == nil then Controller.init() end
  if views ~= nil then
    -- settings action
    local main_panel = Controller.getView("HMMainPanel")
    if type == "settings" and event.element == nil then
      Logging:trace(Controller.classname, "parse_event(event): settings=", event.name)
      Controller.bindController(Player.native())
      if main_panel:isOpened() then
        main_panel:main()
        main_panel:main()
      end
    end
    -- hotkey action
    if type == "hotkey" and event.element == nil then
      Logging:trace(Controller.classname, "parse_event(event): hotkey=", event.name)
      local player = game.players[event.player_index]
      if event.name == "helmod-open-close" then
        main_panel:main()
      end
      if event.name == "helmod-production-line-open" then
        if not(main_panel:isOpened()) then
          main_panel:main()
        end
        Controller.sendEvent(event, "HMMainTab", "change-tab", "HMProductionLineTab")
      end
      if event.name == "helmod-recipe-selector-open" then
        if not(main_panel:isOpened()) then
          main_panel:main()
        end
        Controller.sendEvent(event, "HMRecipeSelector", "OPEN")
      end
    end
    -- button action
    if type == nil and event.element ~= nil and event.element.valid then
      local eventController = nil
      for _, controller in pairs(views) do
        Logging:trace(Controller.classname, "match:", event.element.name, controller:classname())
        if string.find(event.element.name, controller:classname()) then
          Logging:trace(Controller.classname, "match ok:", controller:classname())
          eventController = controller
        end
      end
      if eventController ~= nil then
        local patternAction = eventController:classname().."=([^=]*)"
        local patternItem = eventController:classname()..".*=ID=([^=]*)"
        local patternItem2 = eventController:classname()..".*=ID=[^=]*=([^=]*)"
        local patternItem3 = eventController:classname()..".*=ID=[^=]*=[^=]*=([^=]*)"

        Logging:trace(Controller.classname, "pattern:", patternAction, patternItem, patternItem2, patternItem3)

        local action = string.match(event.element.name,patternAction,1)
        local item = string.match(event.element.name,patternItem,1)
        local item2 = string.match(event.element.name,patternItem2,1)
        local item3 = string.match(event.element.name,patternItem3,1)
        Logging:trace(Controller.classname, "parse_event:", event.element.name, action, item, item2, item3)
        Controller.sendEvent(event, eventController:classname(), action, item, item2, item3)
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
  if views ~= nil then
    for r, controller in pairs(views) do
      if controller:classname() == classname then
        controller:sendEvent(event, action, item, item2, item3)
      end
    end
  end
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
