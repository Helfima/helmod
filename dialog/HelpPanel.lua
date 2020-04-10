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
  desc = false,
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
  count = 9
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
  desc = false,
  list = "none",
  count = 8
}
help_data.preferences.content.module_priority = {
  sprite = "preferences-module-priority",
  localised_text = "preferences-module-priority",
  desc = false,
  list = "none",
  count = 0
}
help_data.preferences.content.items_logistic = {
  sprite = "preferences-items-logistic",
  localised_text = "preferences-items-logistic",
  desc = false,
  list = "none",
  count = 0
}
help_data.preferences.content.fluids_logistic = {
  sprite = "preferences-fluids-logistic",
  localised_text = "preferences-fluids-logistic",
  desc = false,
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
  count = 6
}
help_data.selector.content.recipe_selector_all = {
  sprite = "recipe-selector-all",
  localised_text = "recipe-selector-all",
  desc = true,
  list = "none",
  count = 3
}
help_data.recipe_editor = {
  name = "recipe-editor",
  content = {}
}
help_data.recipe_editor.content.recipe_editor_factory = {
  sprite = "recipe-editor-factory",
  localised_text = "recipe-editor-factory",
  desc = true,
  list = "none",
  count = 5
}
help_data.recipe_editor.content.recipe_editor_module = {
  sprite = "recipe-editor-module",
  localised_text = "recipe-editor-module",
  desc = true,
  list = "none",
  count = 3
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
  count = 7
}
help_data.production.content.production_block = {
  sprite = "production-block",
  localised_text = "production-block",
  desc = true,
  list = "number",
  count = 8
}
help_data.compute = {
  name = "compute",
  content = {}
}
help_data.compute.content.compute_order = {
  sprite = "compute-order",
  localised_text = "compute-order",
  desc = true,
  list = "number",
  count = 7
}
help_data.compute.content.compute_solver = {
  localised_text = "compute-solver",
  desc = true,
  list = "none",
  count = 5
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
  local panel_content_name = "content-panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name][panel_menu_name] ,content_panel[panel_name][panel_content_name]
  end
  local panel = GuiElement.add(content_panel, GuiFlowH(panel_name))
  local menu_panel = GuiElement.add(panel, GuiFrameV(panel_menu_name))
  menu_panel.style.vertically_stretchable = true
  menu_panel.style.minimal_width = 200
  local content_panel = GuiElement.add(panel, GuiFrameV(panel_content_name))
  content_panel.style.horizontally_stretchable = true
  return menu_panel, content_panel
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
  scroll_panel.style.minimal_width = 400
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
    local style_section = "helmod_label_help_menu_1"
    if key == selected_help.section then style_section = style_section.."_selected" end
    local caption_section = {string.format("helmod_help.%s", section.name)}
    GuiElement.add(menu_panel, GuiLabel(self.classname, "change-page", key):style(style_section):caption(caption_section))
    for key2,content in pairs(section.content) do
      local style_content = "helmod_label_help_menu_2"
      if key2 == selected_help.content then style_content = style_content.."_selected" end
      local caption_content = {string.format("helmod_help.%s", content.localised_text)}
      GuiElement.add(menu_panel, GuiLabel(self.classname, "change-page", key, key2):style(style_content):caption(caption_content))
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
  local content_panel = self:getContentScrollPanel()
  if content_panel then
    content_panel.clear()
  end

  local selected_help = User.getParameter("selected_help") or {section = "getting_start", content = "getting_start"}
  local section = help_data[selected_help.section]
  local content_selected = nil
  if section then
    GuiElement.add(content_panel, GuiLabel(section.name, "name"):caption({string.format("helmod_help.%s", section.name)}):style("helmod_label_help_title"))
    GuiElement.add(content_panel, GuiLabel(section.name, "desc"):caption({string.format("helmod_help.%s-desc", section.name)}):style("helmod_label_help"))
    for key,content in pairs(section.content) do
      local section_panel = GuiElement.add(content_panel, GuiFrameV(section.name, "panel", key):style(helmod_frame_style.section))
      local section_title = GuiElement.add(section_panel, GuiLabel(section.name, "title", key):caption({string.format("helmod_help.%s", content.localised_text)}):style("helmod_label_help_title"))
      if content.desc then
        GuiElement.add(section_panel, GuiLabel(section.name, "desc", key):caption({string.format("helmod_help.%s-desc", content.localised_text)}):style("helmod_label_help"))
      end
      if content.sprite then
        GuiElement.add(section_panel, GuiSprite():sprite("helmod_"..content.sprite))
      end

      local column = 1
      local content_table = GuiElement.add(section_panel, GuiTable(section.name, "list", key):column(column):style("helmod_table-help"))
      for line=1, content.count do
        local localised_text = {string.format("helmod_help.%s-%s", content.localised_text, line)}
        if content.list == "number" then
          GuiElement.add(content_table, GuiLabel(section.name, key, line):caption({"", line, ": ", localised_text}):style("helmod_label_help_text"))
        else
          GuiElement.add(content_table, GuiLabel(section.name, key, line):caption(localised_text):style("helmod_label_help_normal"))
        end
      end
      if key == selected_help.content then
        content_selected = section_title
      end
    end
    if content_selected ~= nil then
      content_panel.scroll_to_element(content_selected, "top-third")
    end
  end
end
