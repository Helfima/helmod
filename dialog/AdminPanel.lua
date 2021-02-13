-------------------------------------------------------------------------------
-- Class to build panel
--
-- @module AdminPanel
-- @extends #Form
--

AdminPanel = newclass(Form,function(base,classname)
  Form.init(base,classname)
end)

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#AdminPanel] onBind
--
function AdminPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#AdminPanel] onInit
--
function AdminPanel:onInit()
  self.panelCaption = ({"helmod_result-panel.tab-button-admin"})
end

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#AdminPanel] getButtonCaption
--
-- @return #string
--
function AdminPanel:getButtonCaption()
  return {"helmod_result-panel.tab-button-admin"}
end

-------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#AdminPanel] getButtonSprites
--
-- @return boolean
--
function AdminPanel:getButtonSprites()
  return "database-white","database"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#AdminPanel] isVisible
--
-- @return boolean
--
function AdminPanel:isVisible()
  return Player.isAdmin()
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#AdminPanel] isSpecial
--
-- @return boolean
--
function AdminPanel:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#AdminPanel] getTabPane
--
function AdminPanel:getTabPane()
  local content_panel = self:getFrameDeepPanel("panel")
  local panel_name = "tab_panel"
  local name = table.concat({self.classname, "change-tab", panel_name},"=")
  if content_panel[name] ~= nil and content_panel[name].valid then
    return content_panel[name]
  end
  local panel = GuiElement.add(content_panel, GuiTabPane(self.classname, "change-tab", panel_name))
  return panel
end

-------------------------------------------------------------------------------
-- Get or create tab panel
--
-- @function [parent=#AdminPanel] getTab
--
function AdminPanel:getTab(panel_name, caption)
  local content_panel = self:getTabPane()
  local scroll_name = "scroll-" .. panel_name
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[scroll_name]
  end
  local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption(caption))
  local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"):policy(true))
  content_panel.add_tab(tab_panel,scroll_panel)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create cache tab panel
--
-- @function [parent=#AdminPanel] getCacheTab
--
function AdminPanel:getCacheTab()
  return self:getTab("cache-tab-panel", {"helmod_result-panel.cache-list"})
end

-------------------------------------------------------------------------------
-- Get or create rule tab panel
--
-- @function [parent=#AdminPanel] getRuleTab
--
function AdminPanel:getRuleTab()
  return self:getTab("rule-tab-panel", {"helmod_result-panel.rule-list"})
end

-------------------------------------------------------------------------------
-- Get or create sheet tab panel
--
-- @function [parent=#AdminPanel] getSheetTab
--
function AdminPanel:getSheetTab()
  return self:getTab("sheet-tab-panel", {"helmod_result-panel.sheet-list"})
end

-------------------------------------------------------------------------------
-- Get or create mods tab panel
--
-- @function [parent=#AdminPanel] getModTab
--
function AdminPanel:getModTab()
  return self:getTab("mod-tab-panel", {"helmod_common.mod-list"})
end

-------------------------------------------------------------------------------
-- Get or create gui tab panel
--
-- @function [parent=#AdminPanel] getGuiTab
--
function AdminPanel:getGuiTab()
  return self:getTab("gui-tab-panel", {"helmod_common.gui-list"})
end

-------------------------------------------------------------------------------
-- Get or create global tab panel
--
-- @function [parent=#AdminPanel] getGlobalTab
--
function AdminPanel:getGlobalTab()
  return self:getTab("global-tab-panel", "Global")
end

-------------------------------------------------------------------------------
-- is global tab panel
--
-- @function [parent=#AdminPanel] isGlobalTab
--
function AdminPanel:isGlobalTab()
  return self:getTabPane()["global-tab-panel"] ~= nil
end

-------------------------------------------------------------------------------
-- Get or create conversion tab panel
--
-- @function [parent=#AdminPanel] getConversionTab
--
function AdminPanel:getConversionTab()
  return self:getTab("conversion-tab-panel", "Conversion")
end

-------------------------------------------------------------------------------
-- is conversion tab panel
--
-- @function [parent=#AdminPanel] isConversionTab
--
function AdminPanel:isConversionTab()
  return self:getTabPane()["conversion-tab-panel"] ~= nil
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] onUpdate
--
-- @param #LuaEvent event
--
function AdminPanel:onUpdate(event)
  self:updateCache()
  self:updateRule()
  self:updateSheet()
  self:updateMod()
  self:updateGui()
  self:updateConversion()
  self:updateGlobal()

  self:getTabPane().selected_tab_index = User.getParameter("admin_selected_tab_index") or 1
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateConversion
--
function AdminPanel:updateConversion()
  if self:isConversionTab() then return end
  local scroll_panel = self:getConversionTab()
  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(3))
  GuiElement.add(table_panel, GuiTextBox("encoded-text"))
  local actions = GuiElement.add(table_panel, GuiFlowV("actions"))
  GuiElement.add(actions, GuiButton(self.classname, "string-decode"):caption("Decode ==>"))
  GuiElement.add(actions, GuiButton(self.classname, "string-encode"):caption("<== Encode"))
  local decoded_textbox = GuiElement.add(table_panel, GuiTextBox("decoded-text"))
  decoded_textbox.style.height = 600
end
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateGui
--
function AdminPanel:updateGui()
  -- Rule List
  local scroll_panel = self:getGuiTab()
  scroll_panel.clear()

  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(3):style("helmod_table_border"))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 5

  self:addCellHeader(table_panel, "location", {"",helmod_tag.font.default_bold, {"helmod_common.location"}, helmod_tag.font.close})
  self:addCellHeader(table_panel, "_name", {"",helmod_tag.font.default_bold, {"helmod_result-panel.col-header-name"}, helmod_tag.font.close})
  self:addCellHeader(table_panel, "mod", {"",helmod_tag.font.default_bold, {"helmod_common.mod"}, helmod_tag.font.close})

  local index = 0
  for _,location in pairs({"top","left","center","screen","goal"}) do
    for _, element in pairs(Player.getGui(location).children) do
      if element.name == "mod_gui_button_flow" or element.name == "mod_gui_frame_flow" then
        for _, element in pairs(element.children) do
          GuiElement.add(table_panel, GuiLabel("location", index):caption(location))
          GuiElement.add(table_panel, GuiLabel("_name", index):caption(element.name))
          GuiElement.add(table_panel, GuiLabel("mod", index):caption(element.get_mod() or "base"))
          index = index + 1
        end
      else
        GuiElement.add(table_panel, GuiLabel("location", index):caption(location))
        GuiElement.add(table_panel, GuiLabel("_name", index):caption(element.name))
        GuiElement.add(table_panel, GuiLabel("mod", index):caption(element.get_mod() or "base"))
        index = index + 1
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateMod
--
function AdminPanel:updateMod()
  -- Rule List
  local scroll_panel = self:getModTab()
  scroll_panel.clear()

  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(2):style("helmod_table_border"))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 50

  self:addCellHeader(table_panel, "_name", {"",helmod_tag.font.default_bold, {"helmod_result-panel.col-header-name"}, helmod_tag.font.close})
  self:addCellHeader(table_panel, "version", {"",helmod_tag.font.default_bold, {"helmod_common.version"}, helmod_tag.font.close})

  for name, version in pairs(game.active_mods) do
    GuiElement.add(table_panel, GuiLabel("_name", name):caption(name))
    GuiElement.add(table_panel, GuiLabel("version", name):caption(version))
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateCache
--
function AdminPanel:updateCache()
  -- Rule List
  local scroll_panel = self:getCacheTab()
  scroll_panel.clear()

  GuiElement.add(scroll_panel, GuiLabel("warning"):caption({"", helmod_tag.color.orange, helmod_tag.font.default_large_bold, "Do not use this panel, unless absolutely necessary", helmod_tag.font.close, helmod_tag.color.close}))
  GuiElement.add(scroll_panel, GuiButton(self.classname, "generate-cache"):sprite("menu", "settings", "settings"):style("helmod_button_menu_sm_red"):tooltip("Generate missing cache"))
  
  local table_panel = GuiElement.add(scroll_panel, GuiTable("list-table"):column(2))
  table_panel.vertical_centering = false
  table_panel.style.horizontal_spacing = 50

  if table.size(Cache.get()) > 0 then
    local translate_panel = GuiElement.add(table_panel, GuiFlowV("global-caches"))
    GuiElement.add(translate_panel, GuiLabel("translate-label"):caption("Global caches"):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(translate_panel, GuiTable("list-data"):column(3))
    self:addCacheListHeader(result_table)
    
    for key1, data1 in pairs(Cache.get()) do
      self:addCacheListRow(result_table, "caches", key1, nil, nil, nil, data1)
      for key2, data2 in pairs(data1) do
        self:addCacheListRow(result_table, "caches", key1, key2, nil, nil, data2)
      end
    end
  end

  local users_data = global["users"]
  if table.size(users_data) > 0 then
    local cache_panel = GuiElement.add(table_panel, GuiFlowV("user-caches"))
    GuiElement.add(cache_panel, GuiLabel("translate-label"):caption("User caches"):style("helmod_label_title_frame"))
    local result_table = GuiElement.add(cache_panel, GuiTable("list-data"):column(3))
    self:addCacheListHeader(result_table)
    
    for key1, data1 in pairs(users_data) do
      self:addCacheListRow(result_table, "users", key1, nil, nil, nil, data1)
      for key2, data2 in pairs(data1) do
        self:addCacheListRow(result_table, "users", key1, key2, nil, nil, data2)
        if key2 == "cache" then
          for key3, data3 in pairs(data2) do
            self:addCacheListRow(result_table, "users", key1, key2, key3, nil, data3)
            if string.find(key3, "^HM.*") then
              for key4, data4 in pairs(data3) do
                self:addCacheListRow(result_table, "users", key1, key2, key3, key4, data4)
              end
            end
          end
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateRule
--
function AdminPanel:updateRule()
  -- Rule List
  local scroll_panel = self:getRuleTab()
  scroll_panel.clear()

  local menu_group = GuiElement.add(scroll_panel,GuiFlowH("menu"))
  GuiElement.add(menu_group, GuiButton("HMRuleEdition", "OPEN"):style("helmod_button_bold"):caption({"helmod_result-panel.add-button-rule"}))
  GuiElement.add(menu_group, GuiButton(self.classname, "reset-rules"):style("helmod_button_bold"):caption({"helmod_result-panel.reset-button-rule"}))
  local count_rule = #Model.getRules()
  if count_rule > 0 then

    local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(8):style("helmod_table-rule-odd"))

    self:addRuleListHeader(result_table)

    for rule_id, element in spairs(Model.getRules(), function(t,a,b) return t[b].index > t[a].index end) do
      self:addRuleListRow(result_table, element, rule_id)
    end

  end
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateSheet
--
function AdminPanel:updateSheet()
  -- Sheet List
  local scroll_panel = self:getSheetTab()
  scroll_panel.clear()

  if table.size(global.models) > 0 then

    local result_table = GuiElement.add(scroll_panel, GuiTable("list-data"):column(3):style("helmod_table-odd"))

    self:addSheetListHeader(result_table)

    local i = 0
    for _, element in spairs(global.models, function(t,a,b) return t[b].owner > t[a].owner end) do
      self:addSheetListRow(result_table, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add cahce List header
--
-- @function [parent=#AdminPanel] addTranslateListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminPanel:addTranslateListHeader(itable)
  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data
  self:addCellHeader(itable, "header-owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "header-total", {"helmod_result-panel.col-header-total"})
end

-------------------------------------------------------------------------------
-- Add cahce List header
--
-- @function [parent=#AdminPanel] addCacheListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminPanel:addCacheListHeader(itable)
  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data
  self:addCellHeader(itable, "header-owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "header-total", {"helmod_result-panel.col-header-total"})
end

-------------------------------------------------------------------------------
-- Add row translate List
--
-- @function [parent=#AdminPanel] addTranslateListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminPanel:addTranslateListRow(gui_table, user_name, user_data)
  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", user_name):column(4))

  -- col owner
  GuiElement.add(gui_table, GuiLabel("owner", user_name):caption(user_name))

  -- col translated
  GuiElement.add(gui_table, GuiLabel("total", user_name):caption(table.size(user_data.translated)))

end

-------------------------------------------------------------------------------
-- Add row Rule List
--
-- @function [parent=#AdminPanel] addCacheListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #string class_name
-- @param #table data
--
function AdminPanel:addCacheListRow(gui_table, class_name, key1, key2, key3, key4, data)
  local caption = ""
  if type(data) == "table" then
    caption = table.size(data)
  else
    caption = data
  end

  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", string.format("%s-%s-%s-%s", key1, key2, key3, key4)):column(4))
  if key2 == nil and key3 == nil and key4 == nil then
    if class_name ~= "users" then
      GuiElement.add(cell_action, GuiButton(self.classname, "delete-cache", class_name, key1):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"helmod_button.remove"}))
      GuiElement.add(cell_action, GuiButton(self.classname, "refresh-cache", class_name, key1):sprite("menu", "refresh-sm", "refresh-sm"):style("helmod_button_menu_sm_red"):tooltip({"helmod_button.refresh"}))
      -- col class
      GuiElement.add(gui_table, GuiLabel("class", key1):caption({"", helmod_tag.color.orange, helmod_tag.font.default_large_bold, string.format("%s", key1), "[/font]", helmod_tag.color.close}))
    else
      -- col class
      GuiElement.add(gui_table, GuiLabel("class", key1):caption({"", helmod_tag.color.blue, helmod_tag.font.default_large_bold, string.format("%s", key1), "[/font]", helmod_tag.color.close}))
    end
  
    -- col count
    GuiElement.add(gui_table, GuiLabel("total", key1):caption({"", helmod_tag.font.default_semibold, caption, "[/font]"}))
  elseif key3 == nil and key4 == nil then
    if class_name == "users" and (key2 == "translated" or key2 == "cache") then
      GuiElement.add(cell_action, GuiButton(self.classname, "delete-cache", class_name, key1, key2):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
      -- col class
      GuiElement.add(gui_table, GuiLabel("class", key1, key2):caption({"", helmod_tag.color.orange, helmod_tag.font.default_bold, "|-" , key2, "[/font]", helmod_tag.color.close}))
    else
      -- col class
      GuiElement.add(gui_table, GuiLabel("class", key1, key2):caption({"", helmod_tag.font.default_bold, "|-" , key2, "[/font]"}))
    end
  
    -- col count
    GuiElement.add(gui_table, GuiLabel("total", key1, key2):caption({"", helmod_tag.font.default_semibold, caption, "[/font]"}))
  elseif key4 == nil then
    if class_name == "users" then
      GuiElement.add(cell_action, GuiButton(self.classname, "delete-cache", class_name, key1, key2, key3):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))
      -- col class
      GuiElement.add(gui_table, GuiLabel("class", key1, key2, key3):caption({"", helmod_tag.color.orange, helmod_tag.font.default_bold, "|\t\t\t|-" , key3, "[/font]", helmod_tag.color.close}))
    else
      -- col class
      GuiElement.add(gui_table, GuiLabel("class", key1, key2, key3):caption({"", helmod_tag.font.default_bold, "|-" , key3, "[/font]"}))
    end
  
    -- col count
    GuiElement.add(gui_table, GuiLabel("total", key1, key2, key3):caption({"", helmod_tag.font.default_semibold, caption, "[/font]"}))
  else
    GuiElement.add(gui_table, GuiLabel("class", key1, key2, key3, key4):caption({"", helmod_tag.font.default_bold, "|\t\t\t|\t\t\t|-" , key4, "[/font]"}))
  
    -- col count
    GuiElement.add(gui_table, GuiLabel("total", key1, key2, key3, key4):caption({"", helmod_tag.font.default_semibold, caption, "[/font]"}))
  end

end

-------------------------------------------------------------------------------
-- Add rule List header
--
-- @function [parent=#AdminPanel] addRuleListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminPanel:addRuleListHeader(itable)
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
-- @function [parent=#AdminPanel] addRuleListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminPanel:addRuleListRow(gui_table, rule, rule_id)
  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", rule_id):column(4))
  GuiElement.add(cell_action, GuiButton(self.classname, "rule-remove", rule_id):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_red"):tooltip({"tooltip.remove-element"}))

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
-- @function [parent=#AdminPanel] addSheetListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminPanel:addSheetListHeader(itable)
  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data owner
  self:addCellHeader(itable, "owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "element", {"helmod_result-panel.col-header-sheet"})
end

-------------------------------------------------------------------------------
-- Add row Sheet List
--
-- @function [parent=#AdminPanel] addSheetListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminPanel:addSheetListRow(gui_table, model)
  -- col action
  local cell_action = GuiElement.add(gui_table, GuiTable("action", model.id):column(4))
  if model.share ~= nil and bit32.band(model.share, 1) > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model", model.id, "read"):style("helmod_button_selected"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model", model.id, "read"):style("helmod_button_default"):caption("R"):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  end
  if model.share ~= nil and bit32.band(model.share, 2) > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model", model.id, "write"):style("helmod_button_selected"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model", model.id, "write"):style("helmod_button_default"):caption("W"):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  end
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model", model.id, "delete"):style("helmod_button_selected"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  else
    GuiElement.add(cell_action, GuiButton(self.classname, "share-model", model.id, "delete"):style("helmod_button_default"):caption("X"):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  end

  -- col owner
  local cell_owner = GuiElement.add(gui_table, GuiFrameH("owner", model.id):style(helmod_frame_style.hidden))
  GuiElement.add(cell_owner, GuiLabel(model.id):caption(model.owner or "empty"):style("helmod_label_right_70"))

  -- col element
  local cell_element = GuiElement.add(gui_table, GuiFrameH("element", model.id):style(helmod_frame_style.hidden))
  local element = Model.firstRecipe(model.blocks)
  if element ~= nil then
    GuiElement.add(cell_element, GuiButtonSprite(self.classname, "donothing", model.id):sprite("recipe", element.name):tooltip(RecipePrototype(element):getLocalisedName()))
  else
    GuiElement.add(cell_element, GuiButton(self.classname, "donothing", model.id):sprite("menu", "help-white", "help"):style("helmod_button_menu_selected"))
  end

end

local color_name = "blue"
local color_index = 1
local bar_thickness = 2
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminPanel] updateConversion
--
function AdminPanel:updateGlobal()
  if self:isGlobalTab() then return end
  local scroll_panel = self:getGlobalTab()
  local root_branch = GuiElement.add(scroll_panel, GuiFlowV())
  root_branch.style.vertically_stretchable = false
  self:createTree(root_branch, {global=global}, true)
end

-------------------------------------------------------------------------------
-- Create Tree
--
-- @function [parent=#AdminPanel] createTree
--
function AdminPanel:createTree(parent, list, expand)
  local data_info = table.data_info(list)
  local index = 1
  local size = table.size(list)
  for k,info in pairs(data_info) do
    local tree_branch = GuiElement.add(parent, GuiFlowV())
    local cell = GuiElement.add(tree_branch, GuiFlowH())
    local hbar = GuiElement.add(cell, GuiFrameV("hbar"):style("helmod_frame_product", color_name, color_index))
    hbar.style.width = 5
    hbar.style.height = bar_thickness
    hbar.style.top_margin=10
    hbar.style.right_margin=5
    if info.type == "table" then
      local caption = {"", helmod_tag.font.default_bold, helmod_tag.color.green_light, k, helmod_tag.color.close, helmod_tag.font.close, " (", info.type,")"}
      if expand then
        GuiElement.add(cell, GuiLabel("global-end"):caption(caption))
      else
        local label = GuiElement.add(cell, GuiLabel(self.classname, "global-update", "bypass"):caption(caption))
        label.tags = info
      end
    else
      local caption = {"", helmod_tag.font.default_bold, helmod_tag.color.gold, k, helmod_tag.color.close, helmod_tag.font.close, "=", helmod_tag.font.default_bold, info.value, helmod_tag.font.close, " (", info.type,")"}
      local label = GuiElement.add(cell, GuiLabel("global-end"):caption(caption))
    end
    local content = GuiElement.add(tree_branch, GuiFlowH("content"))
    local vbar = GuiElement.add(content, GuiFrameV("vbar"):style("helmod_frame_product", color_name, color_index))
    vbar.style.vertically_stretchable = true
    vbar.style.width = bar_thickness
    vbar.style.left_margin=15
    vbar.style.bottom_margin=8
    local next = GuiElement.add(content, GuiFlowV("next"))
    if expand then
      self:createTree(next, info.value, false)
    else
      content.visible = false
    end
    index = index + 1
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#AdminPanel] onEvent
--
-- @param #LuaEvent event
--
function AdminPanel:onEvent(event)
  if event.action == "change-tab" then
    User.setParameter("admin_selected_tab_index", event.element.selected_tab_index)
  end
  
  if not(User.isAdmin()) then return end

  if event.action == "global-update" then
    local element = event.element
    local parent = element.parent.parent
    local parent_next = parent.content.next
    local parent_bar = parent.content.vbar
    if #parent_next.children > 0 then
      for _,child in pairs(parent_next.children) do
          child.destroy()
      end
      parent.content.visible = false
    else
      local list = element.tags.value
      parent.content.visible = true
      self:createTree(parent_next, list)
    end
  end

  if event.action == "rule-remove" then
    local rule_id = event.item1
    if global.rules ~= nil then
      table.remove(global.rules,rule_id)
      table.reindex_list(global.rules)
    end
    Controller:send("on_gui_update", event)
  end
  if event.action == "reset-rules" then
    Model.resetRules()
    Controller:send("on_gui_update", event)
  end

  if event.action == "string-decode" then
    local parent = event.element.parent.parent
    local decoded_textbox = parent["decoded-text"]
    local encoded_textbox = parent["encoded-text"]
    local input = string.sub(encoded_textbox.text,2)
    local json = game.decode_string(input)
    local result = Converter.indent(json)
    decoded_textbox.text = result
  end

  if event.action == "string-encode" then
    local parent = event.element.parent.parent
    local decoded_textbox = parent["decoded-text"]
    local encoded_textbox = parent["encoded-text"]
    encoded_textbox.text = "0"..game.encode_string(decoded_textbox.text)
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
    Controller:send("on_gui_update", event)
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
    
    Controller:send("on_gui_update", event)
  end

  if event.action == "generate-cache" then
    Controller:on_init()
    Controller:send("on_gui_update", event)
  end

  if event.action == "share-model" then
    local access = event.item2
    local model = global.models[event.item1]
    if model ~= nil then
      if access == "read" then
        if model.share == nil or not(bit32.band(model.share, 1) > 0) then
          model.share = 1
        else
          model.share = 0
        end
      end
      if access == "write" then
        if model.share == nil or not(bit32.band(model.share, 2) > 0) then
          model.share = 3
        else
          model.share = 1
        end
      end
      if access == "delete" then
        if model.share == nil or not(bit32.band(model.share, 4) > 0) then
          model.share = 7
        else
          model.share = 3
        end
      end
    end
    Controller:send("on_gui_refresh", event)
  end
end