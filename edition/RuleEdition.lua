-------------------------------------------------------------------------------
-- Class to build rule edition dialog
--
-- @module RuleEdition
--

RuleEdition = setclass("HMRuleEdition", Dialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#RuleEdition] onInit
--
-- @param #Controller parent parent controller
--
function RuleEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_rule-edition-panel.title"})
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#RuleEdition] getParentPanel
--
-- @return #LuaGuiElement
--
function RuleEdition.methods:getParentPanel()
  return self.parent:getDialogPanel()
end

-------------------------------------------------------------------------------
-- Get or create rule panel
--
-- @function [parent=#RuleEdition] getRulePanel
--
-- @return #LuaGuiElement
--
function RuleEdition.methods:getRulePanel()
  local panel = self:getPanel()
  if panel["rule_panel"] ~= nil and panel["rule_panel"].valid then
    return panel["rule_panel"]
  end
  local table_panel = ElementGui.addGuiFrameV(panel, "rule_panel", helmod_frame_style.panel)
  return table_panel
end

-------------------------------------------------------------------------------
-- Get or create action panel
--
-- @function [parent=#RuleEdition] getActionPanel
--
function RuleEdition.methods:getActionPanel()
  local panel = self:getPanel()
  if panel["action_panel"] ~= nil and panel["action_panel"].valid then
    return panel["action_panel"]
  end
  return ElementGui.addGuiFrameV(panel, "action_panel", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RuleEdition] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RuleEdition.methods:onUpdate(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onUpdate():", action, item, item2, item3)
  self:updateRule(item, item2, item3)
  self:updateAction(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update rule
--
-- @function [parent=#RuleEdition] updateRule
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RuleEdition.methods:updateRule(item, item2, item3)
  Logging:debug(self:classname(), "updateRule():", item, item2, item3)
  local rule_panel = self:getRulePanel()
  rule_panel.clear()
  local rule_table = ElementGui.addGuiTable(rule_panel,"list-data", 2, helmod_table_style.rule)

  -- mod
  local mod_list = {}
  for name, version in pairs(game.active_mods) do
    table.insert(mod_list, name)
  end
  ElementGui.addGuiLabel(rule_table, "label-mod", ({"helmod_rule-edition-panel.mod"}))
  ElementGui.addGuiDropDown(rule_table, "dropdown=", "mod", mod_list)

  ElementGui.addGuiLabel(rule_table, "label-name", ({"helmod_rule-edition-panel.name"}))
  ElementGui.addGuiDropDown(rule_table, "dropdown=", "name", helmod_rule_manes)

  ElementGui.addGuiLabel(rule_table, "label-category", ({"helmod_rule-edition-panel.category"}))
  ElementGui.addGuiDropDown(rule_table, "dropdown=", "category", helmod_rule_categories)

  ElementGui.addGuiLabel(rule_table, "label-type", ({"helmod_rule-edition-panel.type"}))
  ElementGui.addGuiDropDown(rule_table, "dropdown=", "type",  helmod_rule_types)

  ElementGui.addGuiLabel(rule_table, "label-value", ({"helmod_rule-edition-panel.value"}))
  ElementGui.addGuiChooseButton(rule_table, "choose=", "value", "entity", nil, nil)

  ElementGui.addGuiLabel(rule_table, "label-excluded", ({"helmod_rule-edition-panel.excluded"}))
  ElementGui.addGuiCheckbox(rule_table, "excluded", false)
end

-------------------------------------------------------------------------------
-- Update action
--
-- @function [parent=#RuleEdition] updateAction
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RuleEdition.methods:updateAction(item, item2, item3)
  Logging:debug(self:classname(), "updateAction():", item, item2, item3)
  local action_panel = self:getActionPanel()
  action_panel.clear()
  local action_panel = ElementGui.addGuiTable(action_panel,"table_action",2)
  ElementGui.addGuiButton(action_panel, self:classname().."=", "save", "helmod_button_default", ({"helmod_button.save"}))
  ElementGui.addGuiButton(action_panel, self:classname().."=CLOSE=", "close", "helmod_button_default", ({"helmod_button.close"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#RuleEdition] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RuleEdition.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  if Player.isAdmin() then
    if action == "save" then
      local rule_panel = self:getRulePanel()
      local rule_table = rule_panel["list-data"]
      
      local rule_mod = ElementGui.getDropdownSelection(rule_table["dropdown=mod"])
      local rule_name = ElementGui.getDropdownSelection(rule_table["dropdown=name"])
      local rule_category = ElementGui.getDropdownSelection(rule_table["dropdown=category"])
      local rule_type = ElementGui.getDropdownSelection(rule_table["dropdown=type"])
      local rule_value = rule_table["choose=value"].elem_value
      local rule_excluded = rule_table["excluded"].state
      
      if rule_type == "entity-type" then
        rule_value = EntityPrototype.load(rule_value).getType()
      end
      if rule_type == "entity-group" then
        rule_value = EntityPrototype.load(rule_value).native().group.name
      end
      if rule_type == "entity-subgroup" then
        rule_value = EntityPrototype.load(rule_value).native().subgroup.name
      end
      ModelBuilder.addRule(rule_mod, rule_name, rule_category, rule_type, rule_value, rule_excluded)
      self.parent:refreshDisplayData()
      self:close()
    end
  end
end