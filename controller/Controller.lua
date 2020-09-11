require "core.Form"

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
      local gui_button = GuiElement.add(lua_gui_element, GuiButton("helmod_planner-command"):sprite("menu", "calculator-white", "calculator"):style("helmod_button_menu"):tooltip({"helmod_planner-command"}))
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
    Controller:onEvent(event)
  
    if event.classname == self.classname and event.action == "CLOSE" then
      Controller:cleanController(Player.native())
    elseif event.classname == "helmod_planner-command" then
      Controller:openMainPanel()
    else
      if event.action == "CLOSE" then
        Controller:send("on_gui_close", event, event.classname)
      end
  
      if event.action == "OPEN" then
        User.setActiveForm(event.classname)
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
  if event.action == "OPEN" then
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
  local current_block = User.getParameter("current_block")
  local model = Model.getModel()

  if self:isOpened() then
    self:cleanController(Player.native())
  else
    ModelCompute.check()
    local form_name
    if current_block and model.blocks[current_block] then
      form_name = "HMProductionBlockTab"
    else
      form_name = "HMProductionLineTab"
    end
    self:send("on_gui_open", {name="OPEN"}, form_name)
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
-- On event
--
-- @function [parent=#Controller] onEvent
--
-- @param #LuaEvent event
--
function Controller:onEvent(event)
  local model = Model.getModel()

  -- ***************************
  -- access for all
  -- ***************************
  self:onEventAccessAll(event)

  -- *******************************
  -- access admin only
  -- *******************************

  if Player.isAdmin() then
    self:onEventAccessAdmin(event)
  end

  -- *******************************
  -- access admin or owner or write
  -- *******************************

  if User.isWriter() then
    self:onEventAccessWrite(event)
  end

  -- ***************************
  -- access admin or owner
  -- ***************************

  if Player.isAdmin() or model.owner == Player.native().name then
    self:onEventAccessRead(event)
  end

  -- ********************************
  -- access admin or owner or delete
  -- ********************************

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 4) > 0) then
    self:onEventAccessDelete(event)
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessAll
--
-- @param #LuaEvent event
--
function Controller:onEventAccessAll(event)
  if event.action == "refresh-model" then
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "change-model" then
    User.setParameter("model_id", event.item1)
    ModelCompute.check()
    Model.getModel()
    User.setActiveForm("HMProductionLineTab")
    User.setParameter("current_block", "new")
    self:send("on_gui_open", event,"HMProductionLineTab")
  end

  if event.action == "change-tab" then
    if event.item1 == "HMProductionLineTab" then
      User.setParameter("current_block", "new")
    else
      User.setParameter("current_block", event.item2)
    end
    self:closeEditionOrSelector()
    self:send("on_gui_open", event, event.item1)
  end

  if event.action == "close-tab" then
    self:closeTab()
  end

  if event.action == "change-sort" then
    local order = User.getParameter("order")
    if order.name == event.item1 then
      order.ascendant = not(order.ascendant)
    else
      order = {name=event.item1, ascendant=true}
    end
    User.setParameter("order", order)
    self:send("on_gui_update", event)
  end

  if event.action == "change-logistic" then
    local display_logistic_row = User.getParameter("display_logistic_row")
    User.setParameter("display_logistic_row", not(display_logistic_row))
    self:send("on_gui_update", event)
  end

  if event.action == "change-logistic-item" then
    User.setParameter("logistic_row_item", event.item1)
    self:send("on_gui_update", event)
  end

  if event.action == "change-logistic-fluid" then
    User.setParameter("logistic_row_fluid", event.item1)
    self:send("on_gui_update", event)
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessRead
--
-- @param #LuaEvent event
--
function Controller:onEventAccessRead(event)
  if event.action == "copy-model" then
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
    self:send("on_gui_update", event)
  end
  if event.action == "share-model" then
    local models = Model.getModels(true)
    local model = models[event.item2]
    if model ~= nil then
      if event.item1 == "read" then
        if model.share == nil or not(bit32.band(model.share, 1) > 0) then
          model.share = 1
        else
          model.share = 0
        end
      end
      if event.item1 == "write" then
        if model.share == nil or not(bit32.band(model.share, 2) > 0) then
          model.share = 3
        else
          model.share = 1
        end
      end
      if event.item1 == "delete" then
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
--
function Controller:onEventAccessWrite(event)
  local model = Model.getModel()
  local model_id = User.getParameter("model_id")
  local current_block = User.getParameter("current_block")
  local block = model.blocks[current_block] or {}
  local selector_name = "HMRecipeSelector"
  if model.blocks[current_block] ~= nil and model.blocks[current_block].isEnergy then
    selector_name = "HMEnergySelector"
  end

  if event.action == "change-tab" then
    if event.item1 == "HMProductionBlockTab" and event.item2 == "new" then
      self:send("on_gui_open", event,"HMRecipeSelector")
    end
  end

  if event.action == "change-boolean-option" and model.blocks ~= nil and model.blocks[current_block] ~= nil then
    local element = model.blocks[current_block]
    ModelBuilder.updateProductionBlockOption(current_block, event.item1, not(element[event.item1]))
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "change-number-option" and model.blocks ~= nil and model.blocks[current_block] ~= nil then
    local value = GuiElement.getInputNumber(event.element)
    ModelBuilder.updateProductionBlockOption(current_block, event.item1, value)
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "change-time" then
    local index = event.element.selected_index
    model.time = helmod_base_times[index].value or 1
    ModelCompute.update()
    self:send("on_gui_update", event)
    self:send("on_gui_close", event, "HMProductEdition")
  end

  if event.action == "product-selected" then
    if event.button == defines.mouse_button_type.right then
      self:send("on_gui_open", event,"HMRecipeSelector")
    end
  end

  if event.action == "product-edition" then
    if event.button == defines.mouse_button_type.right then
      self:send("on_gui_open", event, selector_name)
    else
      self:send("on_gui_open", event, "HMProductEdition")
    end
  end

  if event.action == "production-block-remove" then
    ModelBuilder.removeProductionBlock(event.item1)
    ModelCompute.update()
    User.setParameter("current_block","new")
    self:send("on_gui_update", event)
  end

  if event.action == "production-block-unlink" then
    ModelBuilder.unlinkProductionBlock(event.item1)
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "past-model" then
    if User.isActiveForm("HMProductionBlockTab") then
      ModelBuilder.pastModel(User.getParameter("copy_from_model_id"), User.getParameter("copy_from_block_id"))
      ModelCompute.update()
      self:send("on_gui_update", event)
    end
    if User.isActiveForm("HMProductionLineTab") then
      ModelBuilder.pastModel(User.getParameter("copy_from_model_id"), User.getParameter("copy_from_block_id"))
      ModelCompute.update()
      User.setParameter("current_block","new")
      self:send("on_gui_update", event)
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessDelete
--
-- @param #LuaEvent event
--
function Controller:onEventAccessDelete(event)
  if event.action == "remove-model" then
    ModelBuilder.removeModel(event.item1)
    User.setActiveForm("HMProductionLineTab")
    User.setParameter("current_block","new")
    self:send("on_gui_update", event)
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessAdmin
--
-- @param #LuaEvent event
--
function Controller:onEventAccessAdmin(event)
  if event.action == "rule-remove" then
    ModelBuilder.removeRule(event.item1)
    self:send("on_gui_update", event)
  end
  if event.action == "reset-rules" then
    Model.resetRules()
    self:send("on_gui_update", event)
  end

  if event.action == "game-pause" then
    if not(game.is_multiplayer()) then
      User.setParameter("auto-pause", true)
      game.tick_paused = true
      self:send("on_gui_pause", event)
    end
  end

  if event.action == "game-play" then
    User.setParameter("auto-pause", false)
    game.tick_paused = false
    self:send("on_gui_pause", event)
  end

  if event.action == "delete-cache" then
    if event.item1 ~= nil and global[event.item1] ~= nil then
      if event.item2 == "" and event.item3 == "" and event.item4 == "" then
        global[event.item1] = nil
      elseif event.item3 == "" and event.item4 == "" then
        global[event.item1][event.item2] = {}
      elseif event.item4 == "" then
        global[event.item1][event.item2][event.item3] = nil
      else
        global[event.item1][event.item2][event.item3][event.item4] = nil
      end
      Player.print("Deleted:", event.item1, event.item2, event.item3, event.item4)
    else
      Player.print("Not found to delete:", event.item1, event.item2, event.item3, event.item4)
    end
    self:send("on_gui_refresh", event, event.classname)
  end

  if event.action == "refresh-cache" then
    global[event.item1][event.item2] = {}
    
    if event.item2 == "HMPlayer" then
      Player.getResources()
    else    
      local forms = {}
      table.insert(forms, EnergySelector("HMEnergySelector"))
      table.insert(forms, EntitySelector("HMEntitySelector"))
      table.insert(forms, RecipeSelector("HMRecipeSelector"))
      table.insert(forms, TechnologySelector("HMTechnologySelector"))
      table.insert(forms, ItemSelector("HMItemSelector"))
      table.insert(forms, FluidSelector("HMFluidSelector"))
      for _,form in pairs(forms) do
        if event.item2 == form.classname then
          form:prepare()
        end
      end
    end
    
    self:send("on_gui_refresh", event)
  end

  if event.action == "generate-cache" then
    Controller:on_init()
    self:send("on_gui_refresh", event)
  end
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
