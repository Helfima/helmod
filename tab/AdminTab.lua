require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AdminTab
-- @extends #AbstractTab
--

AdminTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#AdminTab] getButtonCaption
--
-- @return #string
--
function AdminTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-admin"}
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#AdminTab] getButtonStyles
--
-- @return boolean
--
function AdminTab:getButtonStyles()
  return "helmod_button_icon_database","helmod_button_icon_database_selected"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#AdminTab] isVisible
--
-- @return boolean
--
function AdminTab:isVisible()
  return Player.isAdmin()
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#AdminTab] isSpecial
--
-- @return boolean
--
function AdminTab:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#AdminTab] hasIndexModel
--
-- @return #boolean
--
function AdminTab:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#AdminTab] getTabPane
--
function AdminTab:getTabPane()
  local content_panel = self:getResultPanel()
  local panel_name = "tab_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(panel_name))
  return panel
end

-------------------------------------------------------------------------------
-- Get or create cache tab panel
--
-- @function [parent=#AdminTab] getCacheTab
--
function AdminTab:getCacheTab()
  local content_panel = self:getTabPane()
  local panel_name = "cache-tab-panel"
  local scroll_name = "cache-scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_result-panel.cache-list"}))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(helmod_frame_style.scroll_pane):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create rule tab panel
--
-- @function [parent=#AdminTab] getRuleTab
--
function AdminTab:getRuleTab()
  local content_panel = self:getTabPane()
  local panel_name = "rule-tab-panel"
  local scroll_name = "rule-scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_result-panel.rule-list"}))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(helmod_frame_style.scroll_pane):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create sheet tab panel
--
-- @function [parent=#AdminTab] getSheetTab
--
function AdminTab:getSheetTab()
  local content_panel = self:getTabPane()
  local panel_name = "sheet-tab-panel"
  local scroll_name = "sheet-scroll"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_result-panel.sheet-list"}))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(helmod_frame_style.scroll_pane):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminTab] updateData
--
function AdminTab:updateData()
  Logging:debug(self.classname, "updateData()")

  self:updateCache()
  self:updateRule()
  self:updateSheet()
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminTab] updateCache
--
function AdminTab:updateCache()
  Logging:debug(self.classname, "updateCache()")

  -- Rule List
  local rule_panel = self:getCacheTab()
  local users_data = global["users"]
  if Model.countList(users_data) > 0 then

    local result_table = ElementGui.addGuiTable(rule_panel,"list-data", 3, "helmod_table-rule-odd")

    self:addCacheListHeader(result_table)

    for user_name, user_data in spairs(users_data, function(t,a,b) return b > a end) do
      self:addCacheListRow(result_table, user_name, user_data)
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminTab] updateRule
--
function AdminTab:updateRule()
  Logging:debug(self.classname, "updateRule()")

  -- Rule List
  local rule_panel = self:getRuleTab()
  local count_rule = #Model.getRules()
  if count_rule > 0 then

    local result_table = ElementGui.addGuiTable(rule_panel,"list-data", 8, "helmod_table-rule-odd")

    self:addRuleListHeader(result_table)

    for rule_id, element in spairs(Model.getRules(), function(t,a,b) return t[b].index > t[a].index end) do
      self:addRuleListRow(result_table, element, rule_id)
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminTab] updateSheet
--
function AdminTab:updateSheet()
  Logging:debug(self.classname, "updateSheet()")
  -- Sheet List
  local sheet_panel = self:getSheetTab()

  local count_model = Model.countModel()
  if count_model > 0 then

    local result_table = ElementGui.addGuiTable(sheet_panel,"list-data", 3, "helmod_table-odd")

    self:addSheetListHeader(result_table)

    local i = 0
    for _, element in spairs(Model.getModels(true), function(t,a,b) return t[b].owner > t[a].owner end) do
      self:addSheetListRow(result_table, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add cahce List header
--
-- @function [parent=#AdminTab] addCacheListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab:addCacheListHeader(itable)
  Logging:debug(self.classname, "addCacheListHeader()", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data
  self:addCellHeader(itable, "header-owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "header-translated", "Count Translated")
end

-------------------------------------------------------------------------------
-- Add row Rule List
--
-- @function [parent=#AdminTab] addCacheListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addCacheListRow(gui_table, user_name, user_data)
  Logging:debug(self.classname, "addCacheListRow()", gui_table, user_name, user_data)

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..user_name, 4)
  ElementGui.addGuiButton(cell_action, self.classname.."=user-remove=ID=", user_name, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))

  -- col owner
  ElementGui.addGuiLabel(gui_table, "owner"..user_name, user_name)

  -- col translated
  ElementGui.addGuiLabel(gui_table, "translated"..user_name, Model.countList(user_data.translated))

end

-------------------------------------------------------------------------------
-- Add rule List header
--
-- @function [parent=#AdminTab] addRuleListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab:addRuleListHeader(itable)
  Logging:debug(self.classname, "addRuleListHeader()", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data
  self:addCellHeader(itable, "header-index", {"helmod_result-panel.col-header-index"})
  self:addCellHeader(itable, "header-mod", {"helmod_result-panel.col-header-mod"})
  self:addCellHeader(itable, "header-name", {"helmod_result-panel.col-header-name"})
  self:addCellHeader(itable, "header-category", {"helmod_result-panel.col-header-category"})
  self:addCellHeader(itable, "header-type", {"helmod_result-panel.col-header-type"})
  self:addCellHeader(itable, "header-value", {"helmod_result-panel.col-header-value"})
  self:addCellHeader(itable, "header-excluded", {"helmod_result-panel.col-header-excluded"})
end

-------------------------------------------------------------------------------
-- Add row Rule List
--
-- @function [parent=#AdminTab] addRuleListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addRuleListRow(gui_table, rule, rule_id)
  Logging:debug(self.classname, "addRuleListRow()", gui_table, rule, rule_id)

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..rule_id, 4)
  ElementGui.addGuiButton(cell_action, self.classname.."=rule-remove=ID=", rule_id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))

  -- col index
  ElementGui.addGuiLabel(gui_table, "index"..rule_id, rule.index)

  -- col mod
  ElementGui.addGuiLabel(gui_table, "mod"..rule_id, rule.mod)

  -- col name
  ElementGui.addGuiLabel(gui_table, "name"..rule_id, rule.name)

  -- col category
  ElementGui.addGuiLabel(gui_table, "category"..rule_id, rule.category)

  -- col type
  ElementGui.addGuiLabel(gui_table, "type"..rule_id, rule.type)

  -- col value
  ElementGui.addGuiLabel(gui_table, "value"..rule_id, rule.value)

  -- col value
  ElementGui.addGuiLabel(gui_table, "excluded"..rule_id, rule.excluded)

end

-------------------------------------------------------------------------------
-- Add Sheet List header
--
-- @function [parent=#AdminTab] addSheetListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab:addSheetListHeader(itable)
  Logging:debug(self.classname, "addSheetListHeader()", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data owner
  self:addCellHeader(itable, "owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "element", {"helmod_result-panel.col-header-sheet"})
end

-------------------------------------------------------------------------------
-- Add row Sheet List
--
-- @function [parent=#AdminTab] addSheetListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addSheetListRow(gui_table, model)
  Logging:debug(self.classname, "addSheetListRow()", gui_table, model)

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..model.id, 4)
  if model.share ~= nil and bit32.band(model.share, 1) > 0 then
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=read=", model.id, "helmod_button_selected", "R", {"tooltip.share-mod", {"helmod_common.reading"}})
  else
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=read=", model.id, "helmod_button_default", "R", {"tooltip.share-mod", {"helmod_common.reading"}})
  end
  if model.share ~= nil and bit32.band(model.share, 2) > 0 then
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=write=", model.id, "helmod_button_selected", "W", {"tooltip.share-mod", {"helmod_common.writing"}})
  else
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=write=", model.id, "helmod_button_default", "W", {"tooltip.share-mod", {"helmod_common.writing"}})
  end
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=delete=", model.id, "helmod_button_selected", "X", {"tooltip.share-mod", {"helmod_common.removal"}})
  else
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=delete=", model.id, "helmod_button_default", "X", {"tooltip.share-mod", {"helmod_common.removal"}})
  end

  -- col owner
  local cell_owner = ElementGui.addGuiFrameH(gui_table,"owner"..model.id, helmod_frame_style.hidden)
  ElementGui.addGuiLabel(cell_owner, model.id, model.owner or "empty", "helmod_label_right_70")

  -- col element
  local cell_element = ElementGui.addGuiFrameH(gui_table,"element"..model.id, helmod_frame_style.hidden)
  local element = Model.firstRecipe(model.blocks)
  if element ~= nil then
    ElementGui.addGuiButtonSprite(cell_element, self.classname.."=donothing=ID="..model.id.."=", "recipe", element.name, model.id, RecipePrototype(element):getLocalisedName())
  else
    ElementGui.addGuiButton(cell_element, self.classname.."=donothing=ID=", model.id, "helmod_button_icon_help_selected")
  end

end
