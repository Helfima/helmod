require "edition.AbstractEdition"
-------------------------------------------------------------------------------
-- Class to build rule edition dialog
--
-- @module RuleEdition
--

RuleEdition = newclass(AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#RuleEdition] onInit
--
-- @param #Controller parent parent controller
--
function RuleEdition:onInit(parent)
  self.panelCaption = ({"helmod_rule-edition-panel.title"})
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- Get or create rule panel
--
-- @function [parent=#RuleEdition] getRulePanel
--
-- @return #LuaGuiElement
--
function RuleEdition:getRulePanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["rule_panel"] ~= nil and content_panel["rule_panel"].valid then
    return content_panel["rule_panel"]
  end
  local table_panel = ElementGui.addGuiFrameV(content_panel, "rule_panel", helmod_frame_style.panel)
  return table_panel
end

-------------------------------------------------------------------------------
-- Get or create action panel
--
-- @function [parent=#RuleEdition] getActionPanel
--
function RuleEdition:getActionPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["action_panel"] ~= nil and content_panel["action_panel"].valid then
    return content_panel["action_panel"]
  end
  return ElementGui.addGuiFrameV(content_panel, "action_panel", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RuleEdition] onUpdate
--
-- @param #LuaEvent event
--
function RuleEdition:onUpdate(event)
  Logging:debug(self.classname, "onUpdate()", event)
  self:updateRule(event)
  self:updateAction(event)
end

local rule_mod = nil
local rule_name = nil
local rule_category = nil
local rule_type = nil
local rule_value = nil
local rule_excluded = false
-------------------------------------------------------------------------------
-- Update rule
--
-- @function [parent=#RuleEdition] updateRule
--
-- @param #LuaEvent event
--
function RuleEdition:updateRule(event)
  Logging:debug(self.classname, "updateRule()", event)
  local rule_panel = self:getRulePanel()
  rule_panel.clear()
  local rule_table = ElementGui.addGuiTable(rule_panel,"list-data", 2, helmod_table_style.rule)

  -- mod
  local mod_list = {}
  for name, version in pairs(game.active_mods) do
    table.insert(mod_list, name)
  end
  if rule_mod == nil then rule_mod = mod_list[1] end
  ElementGui.addGuiLabel(rule_table, "label-mod", ({"helmod_rule-edition-panel.mod"}))
  ElementGui.addGuiDropDown(rule_table, self.classname.."=dropdown=ID=", "mod", mod_list, rule_mod)

  -- name
  local helmod_rule_manes = {}
  for name,rule in pairs(helmod_rules) do
    table.insert(helmod_rule_manes,name)
  end
  if rule_name == nil then rule_name = helmod_rule_manes[1] end
  ElementGui.addGuiLabel(rule_table, "label-name", ({"helmod_rule-edition-panel.name"}))
  ElementGui.addGuiDropDown(rule_table, self.classname.."=dropdown=ID=", "name", helmod_rule_manes, rule_name)

  -- category
  local helmod_rule_categories = {}
  for name,rule in pairs(helmod_rules[rule_name].categories) do
    table.insert(helmod_rule_categories,name)
  end
  if rule_category == nil then rule_category = helmod_rule_categories[1] end
  ElementGui.addGuiLabel(rule_table, "label-category", ({"helmod_rule-edition-panel.category"}))
  ElementGui.addGuiDropDown(rule_table, self.classname.."=dropdown=ID=", "category", helmod_rule_categories, rule_category)

  -- type
  local helmod_rule_types = helmod_rules[rule_name].categories[rule_category]
  if rule_type == nil then rule_type = helmod_rule_types[1] end
  ElementGui.addGuiLabel(rule_table, "label-type", ({"helmod_rule-edition-panel.type"}))
  ElementGui.addGuiDropDown(rule_table, self.classname.."=dropdown=ID=", "type",  helmod_rule_types, rule_type)

  ElementGui.addGuiLabel(rule_table, "label-value", ({"helmod_rule-edition-panel.value"}))
  ElementGui.addGuiChooseButton(rule_table, "choose=", "value", "entity", nil, nil)

  ElementGui.addGuiLabel(rule_table, "label-excluded", ({"helmod_rule-edition-panel.excluded"}))
  local checkbox = ElementGui.addGuiCheckbox(rule_table, "excluded", false)
  if helmod_rules[rule_name].excluded_only then
    checkbox.state=true
    checkbox.enabled=false
  end
end

-------------------------------------------------------------------------------
-- Update action
--
-- @function [parent=#RuleEdition] updateAction
--
-- @param #LuaEvent event
--
function RuleEdition:updateAction(event)
  Logging:debug(self.classname, "updateAction()", event)
  local action_panel = self:getActionPanel()
  action_panel.clear()
  local action_panel = ElementGui.addGuiTable(action_panel,"table_action",2)
  ElementGui.addGuiButton(action_panel, self.classname.."=", "save", "helmod_button_default", ({"helmod_button.save"}))
  ElementGui.addGuiButton(action_panel, self.classname.."=CLOSE=", "close", "helmod_button_default", ({"helmod_button.close"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#RuleEdition] onEvent
--
-- @param #LuaEvent event
--
function RuleEdition:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  if Player.isAdmin() then
    if event.action == "dropdown" then
      if event.item1 == "mod" then
        rule_mod = ElementGui.getDropdownSelection(event.element)
      end
      if event.item1 == "name" then
        rule_name = ElementGui.getDropdownSelection(event.element)
      end
      if event.item1 == "category" then
        rule_category = ElementGui.getDropdownSelection(event.element)
      end
      if event.item1 == "type" then
        rule_type = ElementGui.getDropdownSelection(event.element)
      end
      self:updateRule(event)
    end

    if event.action == "save" then
      local rule_panel = self:getRulePanel()
      local rule_table = rule_panel["list-data"]

      local rule_value = rule_table["choose=value"].elem_value
      local rule_excluded = rule_table["excluded"].state

      if rule_value ~= nil then
        if rule_type == "entity-type" then
          rule_value = EntityPrototype(rule_value):getType()
        end
        if rule_type == "entity-group" then
          rule_value = EntityPrototype(rule_value):native().group.name
        end
        if rule_type == "entity-subgroup" then
          rule_value = EntityPrototype(rule_value):native().subgroup.name
        end
      else
        rule_value = "all"
      end
      ModelBuilder.addRule(rule_mod, rule_name, rule_category, rule_type, rule_value, rule_excluded)
      self:close()
    end
  end
end
