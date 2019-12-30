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
-- Get Button Sprites
--
-- @function [parent=#AdminTab] getButtonSprites
--
-- @return boolean
--
function AdminTab:getButtonSprites()
  return "database-white","database"
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
  local caches_panel = self:getCacheTab()
  local users_data = global["users"]
  if Model.countList(users_data) > 0 then

    local translate_panel = GuiElement.add(caches_panel, GuiFlowV("translate"))
    GuiElement.add(translate_panel, GuiLabel("translate-label"):caption("Translated String"):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(translate_panel, GuiTable("list-data"):column(3):style("helmod_table-rule-odd"))
    self:addTranslateListHeader(result_table)
    for user_name, user_data in spairs(users_data, function(t,a,b) return b > a end) do
      self:addTranslateListRow(result_table, user_name, user_data)
    end

  end

  local caches_data = Cache.get()
  if Model.countList(caches_data) > 0 then
    local cache_panel = GuiElement.add(caches_panel, GuiFlowV("caches"))
    GuiElement.add(cache_panel, GuiLabel("translate-label"):caption("Cache Data"):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(cache_panel, GuiTable("list-data"):column(3):style("helmod_table-rule-odd"))
    self:addCacheListHeader(result_table)
    for key1, data1 in pairs(caches_data) do
      for key2, data2 in pairs(data1) do
        self:addCacheListRow(result_table, string.format("%s->%s", key1, key2), data2)
      end
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

    local result_table = GuiElement.add(rule_panel, GuiTable("list-data"):column(8):style("helmod_table-rule-odd"))

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

    local result_table = GuiElement.add(sheet_panel, GuiTable("list-data"):column(3):style("helmod_table-odd"))

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
-- @function [parent=#AdminTab] addTranslateListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab:addTranslateListHeader(itable)
  Logging:debug(self.classname, "addCacheListHeader()", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data
  self:addCellHeader(itable, "header-owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "header-total", {"helmod_result-panel.col-header-total"})
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
  self:addCellHeader(itable, "header-total", {"helmod_result-panel.col-header-total"})
end

-------------------------------------------------------------------------------
-- Add row translate List
--
-- @function [parent=#AdminTab] addTranslateListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addTranslateListRow(gui_table, user_name, user_data)
  Logging:debug(self.classname, "addCacheListRow()", gui_table, user_name, user_data)

  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", user_name):column(4))

  -- col owner
  GuiElement.add(gui_table, GuiLabel("owner", user_name):caption(user_name))

  -- col translated
  GuiElement.add(gui_table, GuiLabel("total", user_name):caption(Model.countList(user_data.translated)))

end

-------------------------------------------------------------------------------
-- Add row Rule List
--
-- @function [parent=#AdminTab] addCacheListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addCacheListRow(gui_table, class_name, data)
  Logging:debug(self.classname, "addCacheListRow()", gui_table, class_name, data)

  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", class_name):column(4))

  -- col class
  GuiElement.add(gui_table, GuiLabel("class", class_name):caption(class_name))

  -- col count
  GuiElement.add(gui_table, GuiLabel("total", class_name):caption(Model.countList(data)))

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
  local cell_action = GuiElement.add(gui_table, GuiTable("action", rule_id):column(4))
  GuiElement.add(cell_action, GuiButton(self.classname, "rule-remove=ID", rule_id):sprite("menu", "delete-white-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))

  -- col index
  GuiElement.add(gui_table, GuiLabel("index", rule_id):caption(rule.index))

  -- col mod
  GuiElement.add(gui_table, GuiLabel("mod", rule_id):caption(rule.mod))

  -- col name
  GuiElement.add(gui_table, GuiLabel("name", rule_id):caption(rule.name))

  -- col category
  GuiElement.add(gui_table, GuiLabel("category", rule_id):caption(rule.category))

  -- col type
  GuiElement.add(gui_table, GuiLabel("type", rule_id):caption(rule.type))

  -- col value
  GuiElement.add(gui_table, GuiLabel("value", rule_id):caption(rule.value))

  -- col value
  GuiElement.add(gui_table, GuiLabel("excluded", rule_id):caption(rule.excluded))

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
  local cell_action = GuiElement.add(gui_table, GuiTable("action", model.id):column(4))
  if model.share ~= nil and bit32.band(model.share, 1) > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model=ID=read", model.id):style("helmod_button_selected"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model=ID=read", model.id):style("helmod_button_default"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  end
  if model.share ~= nil and bit32.band(model.share, 2) > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model=ID=write", model.id):style("helmod_button_selected"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model=ID=write", model.id):style("helmod_button_default"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  end
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model=ID=delete", model.id):style("helmod_button_selected"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model=ID=delete", model.id):style("helmod_button_default"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  end

  -- col owner
  local cell_owner = GuiElement.add(gui_table, GuiFrameH("owner", model.id):style(helmod_frame_style.hidden))
  GuiElement.add(cell_owner, GuiLabel(model.id):caption(model.owner or "empty"):style("helmod_label_right_70"))

  -- col element
  local cell_element = GuiElement.add(gui_table, GuiFrameH("element", model.id):style(helmod_frame_style.hidden))
  local element = Model.firstRecipe(model.blocks)
  if element ~= nil then
    GuiElement.add(cell_element, GuiButtonSprite(self.classname, "donothing=ID", model.id):sprite("recipe", element.name):tooltip(RecipePrototype(element):getLocalisedName()))
  else
    GuiElement.add(cell_element, GuiButton(self.classname, "donothing=ID", model.id):sprite("menu", "help-white", "help"):style("helmod_button_menu_selected"))
  end

end
