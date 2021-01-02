require "core.Object"
require "core.FormBase"
require "core.Form"
require "core.FormModel"

require "dialog.HelpPanel"
require "dialog.ModelDebug"
require "dialog.PinPanel"
require "dialog.SummaryPanel"
require "dialog.StatusPanel"
require "dialog.Settings"
require "dialog.Download"
require "dialog.Calculator"
require "dialog.RecipeExplorer"
require "dialog.PropertiesPanel"
require "dialog.PrototypeFiltersPanel"
require "dialog.UnitTestPanel"
require "dialog.RichTextPanel"

require "edition.LogisticEdition"
require "edition.ModelEdition"
require "edition.RecipeEdition"
require "edition.ProductEdition"
require "edition.RuleEdition"
require "edition.PreferenceEdition"

require "selector.EnergySelector"
require "selector.EntitySelector"
require "selector.RecipeSelector"
require "selector.TechnologySelector"
require "selector.ItemSelector"
require "selector.FluidSelector"

require "tab.ProductionBlockTab"
require "tab.ProductionLineTab"
require "tab.ResourceTab"
require "tab.SummaryTab"
require "tab.StatisticTab"
require "tab.AdminTab"

require "model.Prototype"
require "model.ElectricPrototype"
require "model.EnergySourcePrototype"
require "model.EntityPrototype"
require "model.FluidboxPrototype"
require "model.FluidPrototype"
require "model.ItemPrototype"
require "model.Product"
require "model.RecipePrototype"
require "model.Technology"

ModGui = require "mod-gui"
Cache = require "data.Cache"
User = require "data.User"
Model = require "data.Model"
ModelCompute = require "data.ModelCompute"
ModelBuilder = require "data.ModelBuilder"

PrototypeFilters = require "model.PrototypeFilters"
Converter = require "core.Converter"

PLANNER_COMMAND = "helmod_planner-command"

local Controller = newclass(Object,function(base,classname)
  Object.init(base,classname)
end)

Controller.classname = "HMController"

local views = nil
local locate = "center"
local pinLocate = "left"
local nextEvent = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Controller] prepare
--
function Controller:prepare()

  local forms = {}
  table.insert(forms, HelpPanel("HMHelpPanel"))
  table.insert(forms, ModelDebug("HMModelDebug"))
  table.insert(forms, Download("HMDownload"))
  table.insert(forms, Calculator("HMCalculator"))
  table.insert(forms, RecipeExplorer("HMRecipeExplorer"))
  table.insert(forms, PropertiesPanel("HMPropertiesPanel"))
  table.insert(forms, PrototypeFiltersPanel("HMPrototypeFiltersPanel"))
  table.insert(forms, UnitTestPanel("HMUnitTestPanel"))
  table.insert(forms, RichTextPanel("HMRichTextPanel"))

  table.insert(forms, ProductionLineTab("HMProductionLineTab"))
  table.insert(forms, ProductionBlockTab("HMProductionBlockTab"))
  table.insert(forms, ResourceTab("HMResourceTab"))
  table.insert(forms, SummaryTab("HMSummaryTab"))
  table.insert(forms, StatisticTab("HMStatisticTab"))
  table.insert(forms, AdminTab("HMAdminTab"))

  table.insert(forms, EnergySelector("HMEnergySelector"))
  table.insert(forms, EntitySelector("HMEntitySelector"))
  table.insert(forms, RecipeSelector("HMRecipeSelector"))
  table.insert(forms, TechnologySelector("HMTechnologySelector"))
  table.insert(forms, ItemSelector("HMItemSelector"))
  table.insert(forms, FluidSelector("HMFluidSelector"))

  table.insert(forms, LogisticEdition("HMLogisticEdition"))
  table.insert(forms, ModelEdition("HMModelEdition"))
  table.insert(forms, RecipeEdition("HMRecipeEdition"))
  table.insert(forms, ProductEdition("HMProductEdition"))
  table.insert(forms, RuleEdition("HMRuleEdition"))
  table.insert(forms, PreferenceEdition("HMPreferenceEdition"))

  table.insert(forms, PinPanel("HMPinPanel"))
  table.insert(forms, SummaryPanel("HMSummaryPanel"))
  table.insert(forms, StatusPanel("HMStatusPanel"))

  views = {}
  for _,form in pairs(forms) do
    form:bind()
    views[form.classname] = form
  end

end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Controller] on_init
--
function Controller:on_init()
  log("Controller:on_init()")
  local caches_data = Cache.get()
  if caches_data["HMPlayer"] == nil then
    Player.getResources()
  end
  local forms = {}
  table.insert(forms, EnergySelector("HMEnergySelector"))
  table.insert(forms, EntitySelector("HMEntitySelector"))
  table.insert(forms, RecipeSelector("HMRecipeSelector"))
  table.insert(forms, TechnologySelector("HMTechnologySelector"))
  table.insert(forms, ItemSelector("HMItemSelector"))
  table.insert(forms, FluidSelector("HMFluidSelector"))
  for _,form in pairs(forms) do
    form:prepare()
  end
end
-------------------------------------------------------------------------------
-- Bind Dispatcher
--
-- @function [parent=#Controller] bind
--
function Controller:bind()
  Dispatcher:bind("on_gui_action", self, self.onGuiAction)
  Dispatcher:bind("on_gui_event", self, self.onGuiEvent)
  Dispatcher:bind("on_gui_setting", self, self.onGuiSetting)
  Dispatcher:bind("on_gui_hotkey", self, self.onGuiHotkey)
end

-------------------------------------------------------------------------------
-- Get views
--
-- @function [parent=#Controller] getViews
--
-- @return #table
--
function Controller:getViews()
  if views == nil then Controller.prepare() end
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
function Controller:getView(name)
  if views == nil then Controller.prepare() end
  return views[name]
end

-------------------------------------------------------------------------------
-- Cleanup
--
-- @function [parent=#Controller] cleanController
--
-- @param #LuaPlayer player
--
function Controller:cleanController(player)
  for _,location in pairs({"center", "left", "top", "screen"}) do
    local lua_gui_element = player.gui[location]
    for _,children_name in pairs(lua_gui_element.children_names) do
      if string.find(children_name,"helmod") then
        lua_gui_element[children_name].destroy()
      end
      if self:getView(children_name) and children_name ~= "HMPinPanel" then
        self:getView(children_name):close()
      end
      if children_name == "HMTab" then
        self:closeTab()
      end
    end
  end
end

-------------------------------------------------------------------------------
-- closeEditionOrSelector
--
-- @function [parent=#Controller] closeEditionOrSelector
--
function Controller:closeEditionOrSelector()
  local lua_gui_element = Player.getGui("screen")
  for _,children_name in pairs(lua_gui_element.children_names) do
    if self:getView(children_name) and (string.find(children_name,"Edition") ~= nil) then
      self:getView(children_name):close()
    end
  end
end

-------------------------------------------------------------------------------
-- closeTab
--
-- @function [parent=#Controller] closeTab
--
function Controller:closeTab()
  for _,form in pairs(self:getViews()) do
    if form:getPanelName() == "HMTab" then
      form:close()
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
function Controller:bindController(player)
  if player ~= nil then
    local lua_gui_element = Player.getGui("top")
    if lua_gui_element["helmod_menu-main"] ~= nil then lua_gui_element["helmod_menu-main"].destroy() end
    if lua_gui_element["helmod_planner-command"] ~= nil then lua_gui_element["helmod_planner-command"].destroy() end

    lua_gui_element = ModGui.get_button_flow(Player.native())
    if not(User.getModSetting("display_main_icon")) or User.getVersion() < User.version then
      if lua_gui_element["helmod_planner-command"] ~= nil then lua_gui_element["helmod_planner-command"].destroy() end
    end
    if lua_gui_element ~= nil and lua_gui_element["helmod_planner-command"] == nil and User.getModSetting("display_main_icon") then
      local gui_button = GuiElement.add(lua_gui_element, GuiButton("helmod_planner-command"):sprite("menu", "calculator-white", "calculator"):style("helmod_button_menu_dark"):tooltip({"helmod_planner-command"}))
      gui_button.style.width = 37
      gui_button.style.height = 37
    end
--    if User.getVersion() < User.version then
--      local message = string.format("%s %s: %s","Helmod",game.active_mods["helmod"], "Now every panel is draggable.")
--      Player.print(message)
--    end
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
function Controller:onTick(event)
  if Player.native() ~= nil then
    local next_event = User.getParameter("next_event")
    if next_event ~= nil then
      if (next_event.event.iteration or 0) < 1000 then
        next_event.event.iteration = (next_event.event.iteration or 0) + 1
        Dispatcher:send(next_event.type_event, next_event.event, next_event.classname)
      else
        User.setParameter("next_event", nil)
        event.message = {"", {"helmod_error.excessive-event-iteration"}, " (>1000)"}
        Dispatcher:send("on_gui_error", event, next_event.classname)
      end
    end
  end
end

-------------------------------------------------------------------------------
-- On tick
--
-- @function [parent=#Controller] onNthTick
--
-- @param #table NthTickEvent {tick=#number, nth_tick=#number}
--
function Controller:onNthTick(NthTickEvent)
  if Player.native() ~= nil then
    local next_event = User.getParameter("next_event")
    if next_event ~= nil and next_event.event.tick < NthTickEvent.tick then
      Player.load(next_event.event)
      next_event.event.tick = NthTickEvent.tick
      script.raise_event(next_event.type_event, next_event.event)
      User.setParameter("next_event",nil)
    end
  end
end

-------------------------------------------------------------------------------
-- On string translated
--
-- @function [parent=#Controller] onStringTranslated
--
-- @param #table event {player_index=number, localised_ string=#string,result=#string, translated=#boolean}
--
function Controller:onStringTranslated(event)
  User.addTranslate(event)
end

-------------------------------------------------------------------------------
-- On gui closed
--
-- @function [parent=#Controller] onGuiClosed
--
-- @param #table event
--
function Controller:onGuiClosed(event)
  self:cleanController(Player.native())
end

local pattern = "([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)"

-------------------------------------------------------------------------------
-- On gui action
--
-- @function [parent=#Controller] onGuiAction
--
-- @param #table event
--
function Controller:onGuiAction(event)
  if event.element ~= nil and (string.find(event.element.name,"^HM.*") or string.find(event.element.name,"^helmod.*")) then
    if views == nil then self:prepare() end
  
    event.classname, event.action, event.item1, event.item2, event.item3, event.item4 = string.match(event.element.name,pattern)
  
    if event.classname == self.classname and event.action == "CLOSE" then
      Controller:cleanController(Player.native())
    elseif event.classname == "helmod_planner-command" then
      Controller:openMainPanel()
    else
      if event.action == "CLOSE" then
        Controller:send("on_gui_close", event, event.classname)
      end
  
      self:onGuiEvent(event)
    end
  end
end

-------------------------------------------------------------------------------
-- On gui event
--
-- @function [parent=#Controller] onGuiEvent
--
-- @param #table event
--
function Controller:onGuiEvent(event)
  if event.action == "OPEN" and event.continue ~= true then
    User.setActiveForm(event.classname)
    Controller:send("on_gui_open", event, event.classname)
  end
  Controller:send("on_gui_event", event, event.classname)
end

-------------------------------------------------------------------------------
-- On gui hotkey
--
-- @function [parent=#Controller] onGuiHotkey
--
-- @param #table event
--
function Controller:onGuiHotkey(event)
  if views == nil then self:prepare() end

  if event.input_name == "helmod-close" then
    if self:isOpened() then
      self:cleanController(Player.native())
    end
  end
  if event.input_name == "helmod-open-close" then
    self:openMainPanel()
  end
  if event.input_name == "helmod-production-line-open" then
    if not(self:isOpened()) then
      self:openMainPanel()
    end
    --Controller.sendEvent(Event.native(), "HMController", "change-tab", "HMProductionLineTab")
  end
  if event.input_name == "helmod-recipe-selector-open" then
    if not(self:isOpened()) then
      self:openMainPanel()
    end
    self:send("on_gui_open", event, "HMRecipeSelector")
  end
  if event.input_name == "helmod-recipe-explorer-open" then
    local view = Controller:getView("HMRecipeExplorer")
    if not(view:isOpened()) then
      self:send("on_gui_open", event, "HMRecipeExplorer")
    else
      view:close()
    end
  end
  if event.input_name == "helmod-richtext-open" then
    local view = Controller:getView("HMRichTextPanel")
    if not(view:isOpened()) then
      self:send("on_gui_open", event, "HMRichTextPanel")
    else
      view:close()
    end
  end
end

-------------------------------------------------------------------------------
-- On gui setting
--
-- @function [parent=#Controller] onGuiSetting
--
-- @param #table event
--
function Controller:onGuiSetting(event)
  if views == nil then self:prepare() end

  self:bindController(Player.native())
  if self:isOpened() then
    self:cleanController(Player.native())
    self:openMainPanel()
  else
    -- prevent change location
    self:cleanController(Player.native())
  end
end

-------------------------------------------------------------------------------
-- Prepare main display
--
-- @function [parent=#Controller] openMainPanel
--
function Controller:openMainPanel()
  if self:isOpened() then
    self:cleanController(Player.native())
  else
    local current_tab = User.getParameter("current_tab") or "HMProductionBlockTab"
    local parameter_name = string.format("%s_%s", current_tab, "objects")
    local parameter_objects = User.getParameter(parameter_name)
    
    local event = {name="OPEN"}
    if parameter_objects == nil then
      parameter_objects = {name=parameter_name}
    else
      event.item2 = parameter_objects.block
    end
    local model, block, recipe = Model.getParameterObjects(parameter_objects)
    event.item1 = model.id
    ModelCompute.check(model)
    self:send("on_gui_open", event, current_tab)
  end
end

-------------------------------------------------------------------------------
-- Is opened main panel
--
-- @function [parent=#Controller] isOpened
--
function Controller:isOpened()
  local lua_player = Player.native()
  if lua_player == nil then return false end
  local gui_screen = Player.getGui("screen")
  local is_open = false
  for _,form_name in pairs(gui_screen.children_names) do
    --if string.find(form_name,"Tab") and Controller.getView(form_name) then
    if form_name == "HMTab" then
      is_open = true
    end
  end
  return is_open
end

-------------------------------------------------------------------------------
-- Send
--
-- @function [parent=#Controller] send
--
function Controller:send(event_type, data, classname)
  if classname ~= nil then data.classname = classname end
  Dispatcher:send(event_type, data, classname)
end

local MyController = Controller(Controller.classname)
MyController:bind()

return MyController
