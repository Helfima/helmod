-------------------------------------------------------------------------------
-- Class to build HelpPanel panel
--
-- @module HelpPanel
-- @extends #Form
--

HelpPanel = newclass(Form)

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
-- Get or create content panel
--
-- @function [parent=#HelpPanel] getContentPanel
--
function HelpPanel:getContentPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "help-panel"
  local panel_menu_name = "menu-panel"
  local panel_scroll_name = "scroll-panel"
  local panel_content_name = "content-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name][panel_menu_name][panel_scroll_name] ,content_panel[panel_name][panel_content_name]
  end
  local panel = GuiElement.add(content_panel, GuiFlowH(panel_name))
  local menu_panel = GuiElement.add(panel, GuiFrameV(panel_menu_name))
  local scroll_panel = GuiElement.add(menu_panel, GuiScroll(panel_scroll_name))
  scroll_panel.style.vertically_stretchable = true
  scroll_panel.style.minimal_width = 200
  local content_panel = GuiElement.add(panel, GuiFrameV(panel_content_name))
  content_panel.style.horizontally_stretchable = true
  return scroll_panel, content_panel
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#HelpPanel] getContentScrollPanel
--
-- @param #string caption
--
function HelpPanel:getContentScrollPanel(caption)
  local menu_panel, content_panel = self:getContentPanel(caption)
  if content_panel["scroll-content"] ~= nil and content_panel["scroll-content"].valid then
    return content_panel["scroll-content"]
  end
  local scroll_panel = GuiElement.add(content_panel, GuiScroll("scroll-content"))
  GuiElement.setStyle(scroll_panel, "scroll_help", "height")
  scroll_panel.style.minimal_width = 850
  scroll_panel.style.maximal_width = 850
  return scroll_panel
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
    User.setParameter("selected_help", {section=event.item1 , content=event.item2})
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
function HelpPanel:updateMenu(event)
  local menu_panel, content_panel = self:getContentPanel()
  menu_panel.clear()
  local selected_help = User.getParameter("selected_help") or {section = "getting_start", content = "getting_start"}
  for key,section in pairs(help_data) do
    local style_section = "helmod_button_help_menu"
    if key == selected_help.section and (selected_help.content == nil or selected_help.content =="") then style_section = style_section.."_selected" end
    local caption_section = {string.format("helmod_help.%s", section.name)}
    local group_panel = GuiElement.add(menu_panel, GuiFlowV(key))
    group_panel.style.vertical_spacing = 0
    GuiElement.add(group_panel, GuiButton(self.classname, "change-page", key):style(style_section):caption(caption_section))
    for key2,content in pairs(section.content) do
      local style_content = "helmod_button_help_menu2"
      if key2 == selected_help.content then style_content = style_content.."_selected" end
      local caption_content = {string.format("helmod_help.%s", content.localised_text)}
      GuiElement.add(group_panel, GuiButton(self.classname, "change-page", key, key2):style(style_content):caption(caption_content))
    end
  end
end

-------------------------------------------------------------------------------
-- Update about HelpPanel
--
-- @function [parent=#HelpPanel] updateContent
--
-- @param #LuaEvent event
--
function HelpPanel:updateContent(event)
  local scroll_panel = self:getContentScrollPanel()
  if scroll_panel then
    scroll_panel.clear()
  end

  local selected_help = User.getParameter("selected_help") or {section = "getting_start", content = "getting_start"}
  local section = help_data[selected_help.section]
  local content_selected = nil
  if section then
    -- section panel
    local section_caption_name = {string.format("helmod_help.%s", section.name)}
    local section_caption_desc = {string.format("helmod_help.%s-desc", section.name)}
    local section_panel = GuiElement.add(scroll_panel, GuiFlowV("section", section.name))
    section_panel.style.horizontally_stretchable = true
    -- section header
    GuiElement.add(section_panel, GuiLabel("header"):caption({"", "[font=heading-1]", section_caption_name, "[/font]"}):style("helmod_label_help"))
    GuiElement.add(section_panel, GuiLabel(section.name, "desc"):caption({"", "\t\t\t",section_caption_desc}):style("helmod_label_help"))
    for key,content in pairs(section.content) do
      local content_panel = GuiElement.add(section_panel, GuiFrameV(section.name, "panel", key):style(helmod_frame_style.section))
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
      --local content_list = GuiElement.add(content_panel, GuiTable(section.name, "list", key):column(column):style("helmod_table-help"))
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
      scroll_panel.scroll_to_element(content_selected, "top-third")
    end
  end
end
