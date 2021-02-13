-------------------------------------------------------------------------------
-- Class to build HelpPanel panel
--
-- @module HelpPanel
-- @extends #Form
--

HelpPanel = newclass(Form)

local page_list = {}

local help_data = {}
help_data.getting_start = {
  name = "getting-start",
  content = {}
}
help_data.getting_start.content.getting_start = {
  sprite = "getting-start",
  localised_text = "getting-start-panel",
  desc = false,
  list = "number",
  count = 4
}
help_data.getting_start.content.quick_start = {
  sprite = "quick-start",
  localised_text = "quick-start",
  desc = true,
  list = "number",
  count = 8
}
help_data.mod_settings = {
  name = "mod-settings",
  content = {}
}
help_data.mod_settings.content.mod_settings_map = {
  sprite = "mod-settings-map",
  localised_text = "mod-settings-map",
  desc = false,
  list = "none",
  count = 10
}
help_data.mod_settings.content.mod_settings_player = {
  sprite = "mod-settings-player",
  localised_text = "mod-settings-player",
  desc = false,
  list = "none",
  count = 5
}
help_data.preferences = {
  name = "preferences",
  content = {}
}
help_data.preferences.content.general = {
  sprite = "preferences-general",
  localised_text = "preferences-general",
  desc = true,
  list = "none",
  count = 10
}
help_data.preferences.content.ui = {
  sprite = "preferences-ui",
  localised_text = "preferences-ui",
  desc = true,
  list = "none",
  count = 3
}
help_data.preferences.content.module_priority = {
  sprite = "preferences-module-priority",
  localised_text = "preferences-module-priority",
  desc = true,
  list = "none",
  count = 0
}
help_data.preferences.content.items_logistic = {
  sprite = "preferences-items-logistic",
  localised_text = "preferences-items-logistic",
  desc = true,
  list = "none",
  count = 0
}
help_data.preferences.content.fluids_logistic = {
  sprite = "preferences-fluids-logistic",
  localised_text = "preferences-fluids-logistic",
  desc = true,
  list = "none",
  count = 0
}
help_data.selector = {
  name = "recipe-selector",
  content = {}
}
help_data.selector.content.recipe_selector = {
  sprite = "recipe-selector",
  localised_text = "recipe-selector-normal",
  desc = true,
  list = "none",
  count = 7
}
help_data.selector.content.recipe_selector_all = {
  sprite = "recipe-selector-all",
  localised_text = "recipe-selector-all",
  desc = true,
  list = "none",
  count = 3
}
help_data.selector.content.recipe_selector_helmod = {
  sprite = "recipe-selector-helmod",
  localised_text = "recipe-selector-helmod",
  desc = true,
  list = "none",
  count = 3
}
help_data.recipe_editor = {
  name = "recipe-editor",
  content = {}
}
help_data.recipe_editor.content.recipe_editor = {
  sprite = "recipe-editor",
  localised_text = "recipe-editor-general",
  desc = true,
  list = "number",
  count = 6
}
help_data.recipe_editor.content.recipe_editor_info = {
  sprite = "recipe-editor-info",
  localised_text = "recipe-editor-info",
  desc = true,
  list = "none",
  count = 2
}
help_data.recipe_editor.content.recipe_editor_factory = {
  sprite = "recipe-editor-factory",
  localised_text = "recipe-editor-factory",
  desc = true,
  list = "number",
  count = 4
}
help_data.recipe_editor.content.recipe_editor_beacon = {
  sprite = "recipe-editor-beacon",
  localised_text = "recipe-editor-beacon",
  desc = true,
  list = "number",
  count = 4
}
help_data.recipe_editor.content.recipe_editor_tools = {
  sprite = "recipe-editor-tools",
  localised_text = "recipe-editor-tools",
  desc = true,
  list = "number",
  count = 10
}
help_data.recipe_editor.content.recipe_editor_module_selection = {
  sprite = "recipe-editor-module-selection",
  localised_text = "recipe-editor-module-selection",
  desc = true,
  list = "number",
  count = 4
}
help_data.recipe_editor.content.recipe_editor_module_priority = {
  sprite = "recipe-editor-module-priority",
  localised_text = "recipe-editor-module-priority",
  desc = true,
  list = "number",
  count = 6
}

help_data.production = {
  name = "production",
  content = {}
}
help_data.production.content.production_line = {
  sprite = "production-line",
  localised_text = "production-line",
  desc = true,
  list = "number",
  count = 11
}
help_data.production.content.production_block = {
  sprite = "production-block",
  localised_text = "production-block",
  desc = true,
  list = "number",
  count = 14
}
help_data.production.content.production_edition = {
  sprite = "production-edition",
  localised_text = "production-edition",
  desc = true,
  list = "none",
  count = 4
}
help_data.compute = {
  name = "compute",
  content = {}
}
help_data.compute.content.compute_order = {
  sprite = "compute-order",
  localised_text = "compute-order",
  desc = true,
  list = "none",
  count = 7
}
help_data.compute.content.compute_solver = {
  localised_text = "compute-solver",
  desc = true,
  list = "none",
  count = 5
}
help_data.special_panel = {
  name = "special-panel",
  content = {}
}
help_data.special_panel.content.admin = {
  sprite = "admin-tab",
  localised_text = "special-panel-admin",
  desc = true,
  list = "none",
  count = 5
}
help_data.special_panel.content.properties = {
  sprite = "properties-panel",
  localised_text = "special-panel-properties",
  desc = true,
  list = "none",
  count = 5
}
help_data.special_panel.content.filter = {
  sprite = "filter-panel",
  localised_text = "special-panel-filter",
  desc = true,
  list = "none",
  count = 5
}
help_data.special_panel.content.unittest = {
  sprite = "unittest-panel",
  localised_text = "special-panel-unittest",
  desc = true,
  list = "none",
  count = 2
}
help_data.special_panel.content.solver_debug = {
  sprite = "solver-debug-panel",
  localised_text = "special-panel-debug",
  desc = true,
  list = "none",
  count = 4
}
help_data.control = {
  name = "control",
  content = {}
}
help_data.control.content.control = {
  localised_text = "control-hotkey",
  desc = true,
  list = "none",
  count = 3
}
help_data.tips = {
  name = "tips",
  content = {}
}
help_data.tips.content.production_line = {
  localised_text = "tips-production-line",
  desc = true,
  list = "none",
  count = 4
}
help_data.tips.content.production_block = {
  localised_text = "tips-production-block",
  desc = true,
  list = "none",
  count = 4
}

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#HelpPanel] onInit
--
function HelpPanel:onInit()
  self.panelCaption = ({"helmod_help.panel-title"})
  self.help_button = false
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#HelpPanel] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function HelpPanel:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    height = math.max(height_main,800),
  }
  styles.menu_panel = {
    width = 300,
  }
  styles.content_panel = {
    width = 850,
  }
end

-------------------------------------------------------------------------------
-- Get or create content panel
--
-- @function [parent=#HelpPanel] getContentPanel
--
function HelpPanel:getContentPanel()
  local panel = self:getFrameDeepPanel("help-panel", "horizontal")
  local panel_menu_name = "menu-panel"
  local panel_content_name = "content-panel"

  if panel[panel_menu_name] ~= nil and panel[panel_menu_name].valid then
    return panel[panel_menu_name], panel[panel_content_name]
  end

  local menu_panel = GuiElement.add(panel, GuiFlowV(panel_menu_name))
  menu_panel.style.vertically_stretchable = true
  self:setStyle(menu_panel, "menu_panel", "width")

  local content_panel = GuiElement.add(panel, GuiScroll(panel_content_name))
  self:setStyle(content_panel, "content_panel", "width")
  menu_panel.style.vertically_stretchable = true
  return menu_panel, content_panel
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#HelpPanel] onEvent
--
-- @param #LuaEvent event
--
function HelpPanel:onEvent(event)
  if event.action == "change-page" then
    local selected_index = event.element.selected_index
    User.setParameter("selected_help", page_list[selected_index])
    self:onUpdate(event)
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#HelpPanel] onUpdate
--
-- @param #LuaEvent event
--
function HelpPanel:onUpdate(event)
  self:generateList()
  self:updateMenu(event)
  self:updateContent(event)
end

-------------------------------------------------------------------------------
-- Update about HelpPanel
--
-- @function [parent=#HelpPanel] updateMenu
--
-- @param #LuaEvent event
--
function HelpPanel:generateList()
  page_list = {}
  for key1,section in pairs(help_data) do
    local caption_section = {"", helmod_tag.font.default_bold, helmod_tag.color.gold, {string.format("helmod_help.%s", section.name)}, helmod_tag.color.close, helmod_tag.font.close}
    table.insert(page_list, {section = key1, content = nil, caption = caption_section})
    for key2,content in pairs(section.content) do
      local caption_content = {"", "   ", {string.format("helmod_help.%s", content.localised_text)}}
      table.insert(page_list, {section = key1, content = key2, caption = caption_content})
    end
  end
end

-------------------------------------------------------------------------------
-- Update about HelpPanel
--
-- @function [parent=#HelpPanel] updateMenu
--
-- @param #LuaEvent event
--
function HelpPanel:updateMenu(event)
  local menu_panel, content_panel = self:getContentPanel()
  menu_panel.clear()
  local selected_help = User.getParameter("selected_help") or {section = "getting_start", content = nil}
  local items = {}
  local selected_item = nil
  local scroll_index = 0
  for index,page in pairs(page_list) do
    table.insert(items, page.caption)
    if page.section == selected_help.section and page.content == selected_help.content then
      selected_item = page.caption
      scroll_index = index
    end
  end
  local list_box = GuiElement.add(menu_panel, GuiListBox(self.classname, "change-page"):items(items, selected_item))
  list_box.scroll_to_item(scroll_index, "top-third")
end

-------------------------------------------------------------------------------
-- Update about HelpPanel
--
-- @function [parent=#HelpPanel] updateContent
--
-- @param #LuaEvent event
--
function HelpPanel:updateContent(event)
  local menu_panel, content_panel = self:getContentPanel()
  content_panel.clear()

  local selected_help = User.getParameter("selected_help") or {section = "getting_start", content = nil}
  local section = help_data[selected_help.section]
  local content_selected = nil
  if section then
    -- section panel
    local section_caption_name = {string.format("helmod_help.%s", section.name)}
    local section_caption_desc = {string.format("helmod_help.%s-desc", section.name)}
    local section_panel = GuiElement.add(content_panel, GuiFlowV("section", section.name))
    section_panel.style.horizontally_stretchable = true
    -- section header
    GuiElement.add(section_panel, GuiLabel("header"):caption({"", "[font=heading-1]", section_caption_name, "[/font]"}):style("helmod_label_help"))
    local section_title = GuiElement.add(section_panel, GuiLabel(section.name, "desc"):caption({"", "   ",section_caption_desc}):style("helmod_label_help"))
    for key,content in pairs(section.content) do
      local content_panel = GuiElement.add(section_panel, GuiFrameV(section.name, "panel", key):style("helmod_inside_frame"))
      content_panel.style.horizontally_stretchable = true

      local content_title_name = {string.format("helmod_help.%s", content.localised_text)}
      local content_title = GuiElement.add(content_panel, GuiLabel(section.name, "title", key):caption({"", "[font=heading-2]", content_title_name, "[/font]"}):style("helmod_label_help_title"))
      if content.desc then
        GuiElement.add(content_panel, GuiLabel(section.name, "desc", key):caption({string.format("helmod_help.%s-desc", content.localised_text)}):style("helmod_label_help_text"))
      end
      if content.sprite then
        GuiElement.add(content_panel, GuiSprite():sprite("helmod_"..content.sprite))
      end

      local column = 1
      local content_list = GuiElement.add(content_panel, GuiFlowV(section.name, "list", key))
      content_list.style.horizontally_stretchable = true

      for line=1, content.count do
        local localised_text = {string.format("helmod_help.%s-%s", content.localised_text, line)}
        if content.list == "number" then
          GuiElement.add(content_list, GuiLabel(section.name, key, line):caption({"", "[font=default-bold]", line, ":[/font] ", localised_text}):style("helmod_label_help_text"))
        else
          GuiElement.add(content_list, GuiLabel(section.name, key, line):caption({"", "[font=default-bold]*[/font] ", localised_text}):style("helmod_label_help_text"))
        end
      end
      if key == selected_help.content then
        content_selected = content_title
      end
    end
    if content_selected ~= nil then
      content_panel.scroll_to_element(content_selected, "top-third")
    else
      content_panel.scroll_to_element(section_title, "top-third")
    end
  end
end
