-------------------------------------------------------------------------------
-- Class to build HelpPanel panel
--
-- @module HelpPanel
-- @extends #Form
--

HelpPanel = newclass(Form)

local help_data = {
  {
    name = "getting-start",
    content = {{
      sprite = "getting-start",
      localised_text = "getting-start-panel",
      desc = false,
      list = "number",
      count = 7
    },
    {
      localised_text = "convention",
      desc = false,
      list = "none",
      count = 3
    },
    {
      localised_text = "quick-start",
      desc = false,
      list = "number",
      count = 6
    }}
  },
  {
    name = "mod-settings",
    content = {{
      sprite = "mod-settings-map",
      localised_text = "mod-settings-map",
      desc = false,
      list = "none",
      count = 10
    },
    {
      sprite = "mod-settings-player",
      localised_text = "mod-settings-player",
      desc = false,
      list = "none",
      count = 6
    }}
  },
  {
    name = "recipe-selector",
    content = {{
      sprite = "recipe-selector",
      localised_text = "recipe-selector-normal",
      desc = true,
      list = "none",
      count = 6
    },
    {
      sprite = "recipe-selector-all",
      localised_text = "recipe-selector-all",
      desc = true,
      list = "none",
      count = 3
    }}
  },
  {
    name = "recipe-editor",
    content = {{
      sprite = "recipe-editor-factory",
      localised_text = "recipe-editor-factory",
      desc = true,
      list = "none",
      count = 5
    },
    {
      sprite = "recipe-editor-module",
      localised_text = "recipe-editor-module",
      desc = true,
      list = "none",
      count = 3
    }}
  },
  {
    name = "production",
    content = {{
      sprite = "production-line",
      localised_text = "production-line",
      desc = true,
      list = "none",
      count = 9
    },
    {
      sprite = "production-block",
      localised_text = "production-block",
      desc = true,
      list = "none",
      count = 12
    }}
  },
  {
    name = "compute",
    content = {{
      sprite = "compute-order",
      localised_text = "compute-order",
      desc = true,
      list = "number",
      count = 7
    },
    {
      localised_text = "compute-solver",
      desc = true,
      list = "none",
      count = 5
    }}
  },
  {
    name = "control",
    content = {{
      localised_text = "control-hotkey",
      desc = true,
      list = "none",
      count = 3
    }}
  },
  {
    name = "container",
    content = {{
      localised_text = "container-solid",
      desc = true,
      list = "none",
      count = 2
    },
    {
      localised_text = "container-fluid",
      desc = true,
      list = "none",
      count = 2
    }}
  }

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
  menu_panel.style.width = 250
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
  GuiElement.setStyle(scroll_panel, "scroll_help", "width")
  GuiElement.setStyle(scroll_panel, "scroll_help", "height")
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
    User.setParameter("selected_help", tonumber(event.item1))
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
  local selected_help = User.getParameter("selected_help")
  for index,section in pairs(help_data) do
    local style = "helmod_label_help_menu_1"
    if index == selected_help then style = style.."_selected" end
    GuiElement.add(menu_panel, GuiLabel(self.classname, "change-page", index):style(style):caption({"helmod_help."..section.name}):tooltip({"helmod_help."..section.name.."-desc"}))
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

  local selected_help = User.getParameter("selected_help")
  local section = help_data[selected_help or 1]
  if section then
    GuiElement.add(content_panel, GuiLabel(section.name, "name"):caption({"helmod_help."..section.name}):style("helmod_label_help_title"))
    GuiElement.add(content_panel, GuiLabel(section.name, "desc"):caption({"helmod_help."..section.name.."-desc"}):style("helmod_label_help"))
    for i,content in pairs(section.content) do
      local section_panel = GuiElement.add(content_panel, GuiFrameV(section.name, "panel",i):style(helmod_frame_style.section))
    
      GuiElement.add(section_panel, GuiLabel(section.name, "title",i):caption({"helmod_help."..content.localised_text}):style("helmod_label_help_title"))
      if content.desc then
        GuiElement.add(section_panel, GuiLabel(section.name, "desc",i):caption({"helmod_help."..content.localised_text.."-desc"}):style("helmod_label_help"))
      end
      if content.sprite then
        GuiElement.add(section_panel, GuiSprite():sprite("helmod_"..content.sprite))
      end

      local column = 1
      if content.list == "number" then
        column = 2
      end
      local content_table = GuiElement.add(section_panel, GuiTable(section.name, "list",i):column(column):style("helmod_table-help"))
      for line=1, content.count do
        if content.list == "number" then
          GuiElement.add(content_table, GuiLabel(section.name, "num", i, line):caption(line..":"):style("helmod_label_help_number"))
          GuiElement.add(content_table, GuiLabel(section.name, i, line):caption({"helmod_help."..content.localised_text.."-"..line}):style("helmod_label_help_text"))
        else
          GuiElement.add(content_table, GuiLabel(section.name, i, line):caption({"helmod_help."..content.localised_text.."-"..line}):style("helmod_label_help_normal"))
        end
      end
    end
  end
end
