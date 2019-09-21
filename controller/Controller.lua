require "core.Form"
require "dialog.HelpPanel"
require "dialog.PinPanel"
require "dialog.StatusPanel"
require "dialog.Settings"
require "dialog.Download"
require "dialog.Calculator"
require "dialog.RecipeExplorer"
require "edition.RecipeEdition"
require "edition.ProductEdition"
require "edition.ResourceEdition"
require "edition.EnergyEdition"
require "edition.RuleEdition"
require "edition.PreferenceEdition"
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

require "model.Prototype"
require "model.BurnerPrototype"
require "model.EntityPrototype"
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
EntityType = require "model.EntityType"

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
  Logging:debug(self.classname, "prepare()")

  local forms = {}
  table.insert(forms, HelpPanel("HMHelpPanel"))
  table.insert(forms, Download("HMDownload"))
  table.insert(forms, Calculator("HMCalculator"))
  table.insert(forms, RecipeExplorer("HMRecipeExplorer"))

  table.insert(forms, ProductionLineTab("HMProductionLineTab"))
  table.insert(forms, ProductionBlockTab("HMProductionBlockTab"))
  table.insert(forms, EnergyTab("HMEnergyTab"))
  table.insert(forms, ResourceTab("HMResourceTab"))
  table.insert(forms, SummaryTab("HMSummaryTab"))
  table.insert(forms, StatisticTab("HMStatisticTab"))
  table.insert(forms, PropertiesTab("HMPropertiesTab"))
  table.insert(forms, PrototypeFiltersTab("HMPrototypeFiltersTab"))
  table.insert(forms, AdminTab("HMAdminTab"))

  table.insert(forms, EntitySelector("HMEntitySelector"))
  table.insert(forms, RecipeSelector("HMRecipeSelector"))
  table.insert(forms, TechnologySelector("HMTechnologySelector"))
  table.insert(forms, ItemSelector("HMItemSelector"))
  table.insert(forms, FluidSelector("HMFluidSelector"))
  table.insert(forms, ContainerSelector("HMContainerSelector"))

  table.insert(forms, RecipeEdition("HMRecipeEdition"))
  table.insert(forms, ProductEdition("HMProductEdition"))
  table.insert(forms, EnergyEdition("HMEnergyEdition"))
  table.insert(forms, RuleEdition("HMRuleEdition"))
  table.insert(forms, PreferenceEdition("HMPreferenceEdition"))

  table.insert(forms, PinPanel("HMPinPanel"))
  table.insert(forms, StatusPanel("HMStatusPanel"))

  views = {}
  Logging:debug(self.classname, forms)
  for _,form in pairs(forms) do
    form:bind()
    views[form.classname] = form
  end

end

-------------------------------------------------------------------------------
-- Bind Dispatcher
--
-- @function [parent=#Controller] bind
--
function Controller:bind()
  Dispatcher:bind("on_gui_action", self, self.onGuiAction)
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
  Logging:trace(self.classname, "cleanController(player)")
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
        for _,form in pairs(self:getViews()) do
          if form:getPanelName() == "HMTab" then
            form:close(true)
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
function Controller:closeEditionOrSelector()
  Logging:trace(self.classname, "closeEditionOrSelector()")
  local lua_gui_element = Player.getGui("screen")
  for _,children_name in pairs(lua_gui_element.children_names) do
    if self:getView(children_name) and (string.find(children_name,"Edition") ~= nil) then
      self:getView(children_name):close()
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
  Logging:trace(self.classname, "bindController()")
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
function Controller:onTick(event)
  Logging:debug(Controller.classname, "onNthTick(NthTickEvent)", NthTickEvent)
  if Player.native() ~= nil then
    local next_event = User.getParameter("next_event")
    if next_event ~= nil then
      if next_event.event.action == "OPEN" then
        Controller:send("on_gui_open", next_event.event, next_event.classname)
      end
      Controller:send("on_gui_event", next_event.event, next_event.classname)
      User.setParameter("next_event",nil)
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
  Logging:trace(Controller.classname, "onNthTick(NthTickEvent)", NthTickEvent)
  if Player.native() ~= nil then
    local next_event = User.getParameter("next_event")
    if next_event ~= nil then
      next_event.event.tick = NthTickEvent.tick
      if next_event.event.action == "OPEN" then
        Controller:send("on_gui_open", next_event.event, next_event.classname)
      end
      Controller:send("on_gui_event", next_event.event, next_event.classname)
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
  Logging:debug(Controller.classname, "onStringTranslated(event)", event)
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
  Logging:trace(self.classname, "onGuiClosed(event)", event)
  self:cleanController(Player.native())
end

local pattern = "([^=]*)=?([^=]*)=?[^=]*=?([^=]*)=?([^=]*)=?([^=]*)"

-------------------------------------------------------------------------------
-- On gui action
--
-- @function [parent=#Controller] onGuiAction
--
-- @param #table event
--
function Controller:onGuiAction(event)
  Logging:debug(self.classname, "onGuiAction(event)", event)
  if views == nil then self:prepare() end

  event.classname, event.action, event.item1, event.item2, event.item3 = string.match(event.element.name,pattern)
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
    User.setParameter("prepare",false)
    Controller:send("on_gui_prepare", event, event.classname)
    if User.getParameter("prepare") then
      User.setParameter("next_event", {event=event, classname=event.classname})
    else
      if event.action == "OPEN" then
        Controller:send("on_gui_open", event, event.classname)
      end
      Controller:send("on_gui_event", event, event.classname)
    end
  end
end

-------------------------------------------------------------------------------
-- On gui hotkey
--
-- @function [parent=#Controller] onGuiHotkey
--
-- @param #table event
--
function Controller:onGuiHotkey(event)
  Logging:debug(self.classname, "onGuiHotkey(event)", event)
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
end

-------------------------------------------------------------------------------
-- On gui setting
--
-- @function [parent=#Controller] onGuiSetting
--
-- @param #table event
--
function Controller:onGuiSetting(event)
  Logging:debug(self.classname, "onGuiSetting(event)", event)
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
  Logging:debug(self.classname, "openMainPanel()")
  local current_block = User.getParameter("current_block")
  local model = Model.getModel()

  if self:isOpened() then
    self:cleanController(Player.native())
  else
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
  Logging:debug(self.classname, "isOpened()")
  local lua_player = Player.native()
  if lua_player == nil then return false end
  local gui_screen = Player.getGui("screen")
  local is_open = false
  for _,form_name in pairs(gui_screen.children_names) do
    --if string.find(form_name,"Tab") and Controller.getView(form_name) then
    if form_name == "HMTab" then
      Logging:debug(self.classname,"form is open", form_name)
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
  Logging:debug(self.classname, "onEvent()", event)
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

  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
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
  Logging:debug(self.classname, "onEventAccessAll()", event)

  if event.action == "refresh-model" then
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "change-model" then
    User.setParameter("model_id", event.item1)
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

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Controller] onEventAccessRead
--
-- @param #LuaEvent event
--
function Controller:onEventAccessRead(event)
  Logging:debug(self.classname, "onEventAccessRead()", event)

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
  Logging:debug(self.classname, "onEventAccessWrite()", event)
  local model = Model.getModel()
  local model_id = User.getParameter("model_id")
  local current_block = User.getParameter("current_block")

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
    local value = ElementGui.getInputNumber(event.element)
    ModelBuilder.updateProductionBlockOption(current_block, event.item1, value)
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "change-time" then
    local index = event.element.selected_index
    model.time = helmod_base_times[index].value or 1
    Logging:debug(self.classname, "change-time", index, helmod_base_times[index], model.time)
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "product-selected" then
    Logging:debug(self.classname, "product-selected", event.button, defines.mouse_button_type.right)
    if event.button == defines.mouse_button_type.right then
      self:sendWithPrepare("on_gui_open", event,"HMRecipeSelector")
    end
  end

  if event.action == "product-edition" then
    if event.button == defines.mouse_button_type.right then
      self:sendWithPrepare("on_gui_open", event, "HMRecipeSelector")
    else
      self:send("on_gui_open", event, "HMProductEdition")
    end
  end

  if event.action == "production-block-unlink" then
    ModelBuilder.unlinkProductionBlock(event.item1)
    ModelCompute.update()
    self:send("on_gui_update", event)
  end

  if event.action == "production-recipe-add" then
    if event.button == defines.mouse_button_type.right then
      self:sendWithPrepare("on_gui_open", event, "HMRecipeSelector")
    else
      local recipes = Player.searchRecipe(event.item3)
      if #recipes == 1 then
        local recipe = recipes[1]
        ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
        ModelCompute.update()
        User.setParameter("scroll_down",true)
        self:send("on_gui_update", event)
      else
        self:send("on_gui_open", event,"HMRecipeSelector")
      end
    end
  end

  if event.action == "production-block-solver" then
    if model.blocks[event.item1] ~= nil then
      ModelBuilder.updateProductionBlockOption(event.item1, "solver", not(model.blocks[event.item1].solver))
      ModelCompute.update()
      self:send("on_gui_update", event)
    end
  end

  if event.action == "production-block-remove" then
    ModelBuilder.removeProductionBlock(event.item1)
    ModelCompute.update()
    User.setParameter("current_block","new")
    self:send("on_gui_update", event)
  end

  if User.isActiveForm("HMProductionLineTab") then
    if event.button == defines.mouse_button_type.right then
      self:sendWithPrepare("on_gui_open", event, "HMRecipeSelector")
    else
      if event.action == "production-block-add" then
        local recipes = Player.searchRecipe(event.item2)
        if #recipes == 1 then
          local recipe = recipes[1]
          ModelBuilder.addRecipeIntoProductionBlock(recipe.name, recipe.type)
          ModelCompute.update()
          self:send("on_gui_refresh", event)
          User.setActiveForm("HMProductionBlockTab")
        else
          self:send("on_gui_open", event,"HMRecipeSelector")
        end
      end
    end

    if event.action == "production-block-up" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionBlock(event.item1, step)
      ModelCompute.update()
      self:send("on_gui_update", event)
    end

    if event.action == "production-block-down" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionBlock(event.item1, step)
      ModelCompute.update()
      self:send("on_gui_update", event)
    end
  end

  if User.isActiveForm("HMProductionBlockTab") then
    if event.action == "production-recipe-remove" then
      ModelBuilder.removeProductionRecipe(event.item1, event.item2)
      ModelCompute.update()
      self:send("on_gui_update", event)
    end

    if event.action == "production-recipe-up" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.upProductionRecipe(event.item1, event.item2, step)
      ModelCompute.update()
      self:send("on_gui_update", event)
    end

    if event.action == "production-recipe-down" then
      local step = 1
      if event.shift then step = User.getModSetting("row_move_step") end
      if event.control then step = 1000 end
      ModelBuilder.downProductionRecipe(event.item1, event.item2, step)
      ModelCompute.update()
      self:send("on_gui_update", event)
    end
  end

  if User.isActiveForm("HMEnergyTab") then
    if event.action == "power-remove" then
      ModelBuilder.removePower(event.item1)
      self:send("on_gui_update", event)
    end
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
  Logging:debug(self.classname, "onEventAccessDelete()", event)
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
  Logging:debug(self.classname, "onEventAccessAdmin()", event)
  if event.action == "rule-remove" then
    ModelBuilder.removeRule(event.item1)
    self:send("on_gui_update", event)
  end
  if event.action == "reset-rules" then
    Model.resetRules()
    self:send("on_gui_update", event)
  end

end

-------------------------------------------------------------------------------
-- Send
--
-- @function [parent=#Controller] send
--
function Controller:send(event_type, data, classname)
  Logging:trace(self.classname, "send()", event_type, data, classname)
  if classname ~= nil then data.classname = classname end
  Dispatcher:send(event_type, data, classname)
end

-------------------------------------------------------------------------------
-- Send
--
-- @function [parent=#Controller] send
--
function Controller:sendWithPrepare(event_type, data, classname)
  Logging:trace(self.classname, "send()", event_type, data, classname)
  if classname ~= nil then data.classname = classname end
  User.setParameter("prepare",false)
  Dispatcher:send("on_gui_prepare", data, classname)
  if User.getParameter("prepare") then
    User.setParameter("next_event", {event=data, classname=classname})
  else
    Dispatcher:send(event_type, data, classname)
  end
end

local MyController = Controller(Controller.classname)
MyController:bind()

return MyController
