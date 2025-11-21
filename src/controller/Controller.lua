require "core.Object"
require "core.Form"
require "core.FormModel"

require "dialog.AdminPanel"
require "dialog.ArrangeModels"
require "dialog.BugRepportPanel"
require "dialog.CreatedOrWhereUsedPanel"
require "dialog.HelpPanel"
require "dialog.ModelDebug"
require "dialog.PinPanel"
require "dialog.SummaryPanel"
require "dialog.StatisticPanel"
require "dialog.Settings"
require "dialog.Download"
require "dialog.Calculator"
require "dialog.RecipeExplorer"
require "dialog.ProductionPanel"
require "dialog.PrototypeFiltersPanel"
require "dialog.QualityPanel"
require "dialog.UnitTestPanel"
require "dialog.RichTextPanel"

require "edition.LogisticEdition"
require "edition.ModelEdition"
require "edition.BlockEdition"
require "edition.RecipeEdition"
require "edition.RecipeCustomization"
require "edition.ParametersEdition"
require "edition.ProductEdition"
require "edition.RuleEdition"
require "edition.PreferenceEdition"

require "selector.EntitySelector"
require "selector.RecipeSelector"
require "selector.TechnologySelector"
require "selector.ItemSelector"
require "selector.FluidSelector"
require "selector.TileSelector"

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
require "model.TilePrototype"

ModGui = require "mod-gui"
Cache = require "data.Cache"
User = require "data.User"
Model = require "data.Model"
ModelCompute = require "data.ModelCompute"
ModelBuilder = require "data.ModelBuilder"

PrototypeFilters = require "model.PrototypeFilters"
Converter = require "core.Converter"
Blueprint = require "core.Blueprint"

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
---Prepare Views
---
function Controller:prepare()

  local forms = {}
  table.insert(forms, AdminPanel("HMAdminPanel"))
  table.insert(forms, ArrangeModels("HMArrangeModels"))
  table.insert(forms, BugReportPanel("HMBugReportPanel"))
  table.insert(forms, CreatedOrWhereUsedPanel("HMCreatedOrWhereUsedPanel"))
  table.insert(forms, HelpPanel("HMHelpPanel"))
  table.insert(forms, ModelDebug("HMModelDebug"))
  table.insert(forms, Download("HMDownload"))
  table.insert(forms, Calculator("HMCalculator"))
  table.insert(forms, RecipeExplorer("HMRecipeExplorer"))
  table.insert(forms, ProductionPanel("HMProductionPanel"))
  table.insert(forms, PrototypeFiltersPanel("HMPrototypeFiltersPanel"))
  table.insert(forms, QualityPanel("HMQualityPanel"))
  table.insert(forms, UnitTestPanel("HMUnitTestPanel"))
  table.insert(forms, RichTextPanel("HMRichTextPanel"))

  table.insert(forms, EntitySelector("HMEntitySelector"))
  table.insert(forms, RecipeSelector("HMRecipeSelector"))
  table.insert(forms, TechnologySelector("HMTechnologySelector"))
  table.insert(forms, ItemSelector("HMItemSelector"))
  table.insert(forms, FluidSelector("HMFluidSelector"))
  table.insert(forms, TileSelector("HMTileSelector"))

  table.insert(forms, LogisticEdition("HMLogisticEdition"))
  table.insert(forms, ModelEdition("HMModelEdition"))
  table.insert(forms, BlockEdition("HMBlockEdition"))
  table.insert(forms, RecipeEdition("HMRecipeEdition"))
  table.insert(forms, RecipeCustomization("HMRecipeCustomization"))
  table.insert(forms, ParametersEdition("HMParametersEdition"))
  table.insert(forms, ProductEdition("HMProductEdition"))
  table.insert(forms, RuleEdition("HMRuleEdition"))
  table.insert(forms, PreferenceEdition("HMPreferenceEdition"))

  table.insert(forms, PinPanel("HMPinPanel"))
  table.insert(forms, SummaryPanel("HMSummaryPanel"))
  table.insert(forms, StatisticPanel("HMStatisticPanel"))

  views = {}
  for _,form in pairs(forms) do
    form:bind()
    views[form.classname] = form
  end

end

-------------------------------------------------------------------------------
---On initialization
---
function Controller:on_init()
  local caches_data = Cache.get()
  if caches_data["HMPlayer"] == nil then
    Player.getResources()
  end
  local forms = {}
  table.insert(forms, EntitySelector("HMEntitySelector"))
  table.insert(forms, RecipeSelector("HMRecipeSelector"))
  table.insert(forms, TechnologySelector("HMTechnologySelector"))
  table.insert(forms, ItemSelector("HMItemSelector"))
  table.insert(forms, FluidSelector("HMFluidSelector"))
  table.insert(forms, TileSelector("HMTileSelector"))
  for _,form in pairs(forms) do
    form:prepare()
  end
end
-------------------------------------------------------------------------------
---Bind Dispatcher
---
function Controller:bind()
  Dispatcher:bind("on_gui_action", self, self.onGuiAction)
  Dispatcher:bind("on_gui_event", self, self.onGuiEvent)
  Dispatcher:bind("on_gui_setting", self, self.onGuiSetting)
  Dispatcher:bind("on_gui_hotkey", self, self.onGuiHotkey)
  Dispatcher:bind("on_gui_shortcut", self, self.onGuiShortcut)
  Dispatcher:bind("on_gui_queue", self, self.onGuiQueue)
  Dispatcher:bind("on_gui_tips", self, self.onGuiTips)
end

-------------------------------------------------------------------------------
--- Get views
---
---@return table
---
function Controller:getViews()
  if views == nil then Controller.prepare() end
  return views
end

-------------------------------------------------------------------------------
---Get View
---
---@param name string
---
---@return table
---
function Controller:getView(name)
  if views == nil then Controller.prepare() end
  return views[name]
end

-------------------------------------------------------------------------------
---Cleanup
---
---@param player table
---
function Controller:cleanController(player)
  for _,location in pairs({"center", "left", "top", "screen"}) do
    local lua_gui_element = player.gui[location]
    for _,children_name in pairs(lua_gui_element.children_names) do
      if children_name ~= "HMPinPanel" and self:getView(children_name) then
        self:getView(children_name):close()
      end
      if children_name ~= "HMPinPanel" and not(string.find(children_name,"mod_gui")) and lua_gui_element[children_name] ~= nil and lua_gui_element[children_name].get_mod() == "helmod" then
        lua_gui_element[children_name].destroy()
      end
    end
  end
end

-------------------------------------------------------------------------------
---closeEditionOrSelector
---
function Controller:closeEditionOrSelector()
  local lua_gui_element = Player.getGui("screen")
  for _,children_name in pairs(lua_gui_element.children_names) do
    if self:getView(children_name) and (string.find(children_name,"Edition") ~= nil) then
      self:getView(children_name):close()
    end
  end
end

-------------------------------------------------------------------------------
---Bind all controllers
---
---@param player table
---
function Controller:bindController(player)
  if player ~= nil then
    local lua_gui_element = Player.getGui("top")
    if lua_gui_element["helmod_planner-command"] ~= nil then
      lua_gui_element["helmod_planner-command"].destroy()
    end

    -- Destroy gui button
    if lua_gui_element["helmod_planner-command"] ~= nil then
      lua_gui_element["helmod_planner-command"].destroy()
    end

    local flow = lua_gui_element.mod_gui_button_flow or (lua_gui_element.mod_gui_top_frame and lua_gui_element.mod_gui_top_frame.mod_gui_inner_frame)

    if flow and flow["helmod_planner-command"] then
      flow["helmod_planner-command"].destroy()
      -- Remove empty frame if we're the only thing there, remove the parent frame if we just removed the only child
      if #flow.children_names == 0 then
        local parent = flow.parent
        flow.destroy()
        if parent and parent.name ~= "top" and #parent.children_names == 0 then
          parent.destroy()
        end
      end
    end

    -- Create gui button
    if User.getModSetting("display_main_icon") then
      lua_gui_element = ModGui.get_button_flow(player)
      if lua_gui_element ~= nil then
        local gui_button = GuiElement.add(lua_gui_element, GuiButton("helmod_planner-command"):sprite("menu", defines.sprites.calculator.white, defines.sprites.calculator.black):style("helmod_button_menu_dark"):tooltip({"helmod_planner-command"}))
        gui_button.style.width = 37
        gui_button.style.height = 37
      end
    end
    User.update()
  end
end

-------------------------------------------------------------------------------
---On tick
---
---@param event table
---
function Controller:onTick(event)
  if Player.native() ~= nil and Player.native().valid then
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

    local event_queue = User.getParameter("event_queue")
    if event_queue ~= nil then
      local current_tick = game.tick
      for _,event in pairs(event_queue) do
        if event.is_tips == true then
          if current_tick - event.tick > User.delay_tips then
            Dispatcher:send("on_gui_tips", event, Controller.classname)
            event_queue[event.classname] = nil
          end
        else  
          if current_tick - event.tick > 60 then
            event.is_queue = true
            Dispatcher:send("on_gui_action", event, Controller.classname)
            event_queue[event.element.name] = nil
          end
        end
      end
      if table.size(event_queue) == 0 then
        User.setParameter("event_queue", nil)
      end
    end
  end
end

-------------------------------------------------------------------------------
---On gui queue
---
---@param event table
---
function Controller:onGuiQueue(event)
  local event_queue = User.getParameter("event_queue") or {}
  event.element = {name=event.element.name, text=event.element.text}
  event_queue[event.element.name] = event
  User.setParameter("event_queue", event_queue)
end

-------------------------------------------------------------------------------
---On gui tips
---
---@param event table
---
function Controller:onGuiTips(event)
  local form = self:getView(event.classname)
  if form ~= nil then
    form:destroyTips()
  end
end

-------------------------------------------------------------------------------
---On tick
---
---@param NthTickEvent table {tick=#number, nth_tick=#number}
---
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
---On string translated
---
---@param event table {player_index=number, localised_ string=string, result=string, translated=boolean}
---
function Controller:onStringTranslated(event)
  User.addTranslate(event)
end

-------------------------------------------------------------------------------
---On gui closed
---
---@param event table
---
function Controller:onGuiClosed(event)
  self:cleanController(Player.native())
end

local pattern = "([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)=?([^=]*)"

-------------------------------------------------------------------------------
---On gui action
---
---@param event table
---
function Controller:onGuiAction(event)
  if event.element ~= nil and (string.find(event.element.name,"^HM.*") or string.find(event.element.name,"^helmod.*")) then
    if views == nil then self:prepare() end

    event.classname, event.action, event.item1, event.item2, event.item3, event.item4, event.item5 = string.match(event.element.name,pattern)
    event.item = GuiElement.getElementTags(event.element)

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
---On gui event
---
---@param event table
---
function Controller:onGuiEvent(event)
  if event.action == "OPEN" and event.continue ~= true then
    User.setActiveForm(event.classname)
    Controller:send("on_gui_open", event, event.classname)
  end
  Controller:send("on_gui_event", event, event.classname)
end

-------------------------------------------------------------------------------
---On gui hotkey
---
---@param event table
---
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
  if event.input_name == "helmod-create-or-where-used-open" then
    local view = Controller:getView("HMCreatedOrWhereUsedPanel")
    if not(view:isOpened()) then
      self:send("on_gui_open", event, "HMCreatedOrWhereUsedPanel")
    else
      view:close()
    end
  end
end


-------------------------------------------------------------------------------
---On gui shortcut
---
---@param event table
---
function Controller:onGuiShortcut(event)
  if views == nil then self:prepare() end

  if event.prototype_name == "helmod-shortcut" then
    self:openMainPanel()
  end
end

-------------------------------------------------------------------------------
---On gui setting
---
---@param event table
---
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

Controller.panel_close_before_main = {}
-------------------------------------------------------------------------------
---Prepare main display
---
function Controller:openMainPanel()
  if self:isOpened() then
    if #Controller.panel_close_before_main == 0 then
      self:cleanController(Player.native())
      game.tick_paused = false
    else
      local last_form_name = Controller.panel_close_before_main[#Controller.panel_close_before_main]
      local view = Controller:getView(last_form_name)
      view:close()
    end
  else
    local current_tab = "HMProductionPanel"
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
    self:send("on_gui_open", event, current_tab)
  end
end

-------------------------------------------------------------------------------
---Is opened main panel
---@return boolean
---
function Controller:isOpened()
  local lua_player = Player.native()
  if lua_player == nil then return false end
  local panel = self:getView("HMProductionPanel")
  return panel:isOpened()
end

-------------------------------------------------------------------------------
---Send event
---@param event_type string
---@param data table
---@param classname string
---
function Controller:send(event_type, data, classname)
  if classname ~= nil then data.classname = classname end
  Dispatcher:send(event_type, data, classname)
end

local MyController = Controller(Controller.classname)
MyController:bind()

return MyController
