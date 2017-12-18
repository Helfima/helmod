-------------------------------------------------------------------------------
-- Class to build HelpPanel panel
--
-- @module HelpPanel
-- @extends #Dialog
--

HelpPanel = setclass("HMHelpPanel", Dialog)

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
      count = 8
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
-- Initialization
--
-- @function [parent=#HelpPanel] init
--
-- @param #Controller parent parent controller
--
function HelpPanel.methods:init(parent)
  self.panelCaption = ({"helmod_help.panel-title"})
  self.parent = parent
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#HelpPanel] getParentPanel
--
-- @return #LuaGuiElement
--
function HelpPanel.methods:getParentPanel()
  return self.parent:getDialogPanel()
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#HelpPanel] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function HelpPanel.methods:onOpen(event, action, item, item2, item3)
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- Get or create header panel
--
-- @function [parent=#HelpPanel] getHeaderPanel
--
function HelpPanel.methods:getHeaderPanel()
  local panel = self:getPanel()
  if panel["header-panel"] ~= nil and panel["header-panel"].valid then
    return panel["header-panel"]
  end
  return ElementGui.addGuiFrameV(panel, "header-panel", helmod_frame_style.panel, {"helmod_settings-panel.about-section"})
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#HelpPanel] getMenuPanel
--
function HelpPanel.methods:getMenuPanel()
  local panel = self:getPanel()
  if panel["menu-panel"] ~= nil and panel["menu-panel"].valid then
    return panel["menu-panel"]
  end
  return ElementGui.addGuiFrameH(panel, "menu-panel", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create content panel
--
-- @function [parent=#HelpPanel] getContentPanel
--
function HelpPanel.methods:getContentPanel()
  local panel = self:getPanel()
  if panel["content-panel"] ~= nil and panel["content-panel"].valid then
    return panel["content-panel"]
  end
  return ElementGui.addGuiFrameV(panel, "content-panel", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#HelpPanel] getContentScrollPanel
--
-- @param #string caption
--
function HelpPanel.methods:getContentScrollPanel(caption)
  local content_panel = self:getContentPanel(caption)
  if content_panel["scroll-content"] ~= nil and content_panel["scroll-content"].valid then
    return content_panel["scroll-content"]
  end
  local scroll_panel = ElementGui.addGuiScrollPane(content_panel, "scroll-content", helmod_frame_style.scroll_pane)
  Player.setStyle(scroll_panel, "scroll_help", "minimal_width")
  Player.setStyle(scroll_panel, "scroll_help", "maximal_width")
  Player.setStyle(scroll_panel, "scroll_help", "minimal_height")
  Player.setStyle(scroll_panel, "scroll_help", "maximal_height")
  return scroll_panel
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#HelpPanel] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function HelpPanel.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)

  if action == "change-page" then
    self:updateContent(event, action, item, item2, item3)
  end

  if action == "previous-page" then
    local menu_panel = self:getMenuPanel()
    if menu_panel[self:classname().."=change-page"] then
      local selected_index = menu_panel[self:classname().."=change-page"].selected_index
      if selected_index > 1 then
        menu_panel[self:classname().."=change-page"].selected_index = selected_index - 1
        self:updateContent(event, action, item, item2, item3)
      end
    end
  end

  if action == "next-page" then
    local menu_panel = self:getMenuPanel()
    if menu_panel[self:classname().."=change-page"] then
      local selected_index = menu_panel[self:classname().."=change-page"].selected_index
      if selected_index < #help_data then
        menu_panel[self:classname().."=change-page"].selected_index = selected_index + 1
        self:updateContent(event, action, item, item2, item3)
      end
    end
  end

end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#HelpPanel] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function HelpPanel.methods:afterOpen(event, action, item, item2, item3)
  self:updateMenu(event, action, item, item2, item3)
  self:getContentPanel()
end

-------------------------------------------------------------------------------
-- Update about HelpPanel
--
-- @function [parent=#HelpPanel] updateMenu
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function HelpPanel.methods:updateMenu(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateMenu():", action, item, item2, item3)
  local menu_panel = self:getMenuPanel()
  local items = {}
  for _,help in pairs(help_data) do
    table.insert(items, {"helmod_help."..help.name})
  end
  ElementGui.addGuiButton(menu_panel, self:classname().."=previous-page", nil, "helmod_button_icon_arrow_left", nil, ({"helmod_help.button-previous"}))
  ElementGui.addGuiDropDown(menu_panel,self:classname().."=change-page", nil, items)
  ElementGui.addGuiButton(menu_panel, self:classname().."=next-page=", nil, "helmod_button_icon_arrow_right", nil, ({"helmod_help.button-next"}))
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#HelpPanel] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function HelpPanel.methods:onUpdate(event, action, item, item2, item3)
  self:updateContent(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update about HelpPanel
--
-- @function [parent=#HelpPanel] updateContent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function HelpPanel.methods:updateContent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateContent():", action, item, item2, item3)
  local content_panel = self:getContentScrollPanel()
  if content_panel then
    content_panel.clear()
  end

  local menu_panel = self:getMenuPanel()
  local selected_index = 1
  if menu_panel[self:classname().."=change-page"] then
    selected_index = menu_panel[self:classname().."=change-page"].selected_index
  end

  local section = help_data[selected_index or 1]
  if section then
    ElementGui.addGuiLabel(content_panel, table.concat({section.name, "-name"}), {table.concat({"helmod_help.",section.name})}, "helmod_label_help_title", nil, false)
    ElementGui.addGuiLabel(content_panel, table.concat({section.name, "-desc"}), {table.concat({"helmod_help.",section.name, "-desc"})}, "helmod_label_help", nil, false)
    for i,content in pairs(section.content) do
      ElementGui.addGuiLabel(content_panel, table.concat({section.name, "-title-",i}), {table.concat({"helmod_help.",content.localised_text})}, "helmod_label_help_title", nil, false)
      if content.desc then
        ElementGui.addGuiLabel(content_panel, table.concat({section.name, "-desc-",i}), {table.concat({"helmod_help.",content.localised_text, "-desc"})}, "helmod_label_help", nil, false)
      end
      if content.sprite then
        ElementGui.addSprite(content_panel, "helmod_"..content.sprite)
      end

      local column = 1
      if content.list == "number" then
        column = 2
      end
      local content_table = ElementGui.addGuiTable(content_panel, table.concat({section.name, "-list-",i}), column, "helmod_table-help")
      for line=1, content.count do
        if content.list == "number" then
          ElementGui.addGuiLabel(content_table, table.concat({section.name, "-num-",i, "-", line}), table.concat({line,":"}) , "helmod_label_help_number")
          ElementGui.addGuiLabel(content_table, table.concat({section.name, "-",i, "-", line}), {table.concat({"helmod_help.",content.localised_text,"-",line})}, "helmod_label_help_text", nil, false)
        else
          ElementGui.addGuiLabel(content_table, table.concat({section.name, "-",i, "-", line}), {table.concat({"helmod_help.",content.localised_text,"-",line})}, "helmod_label_help_normal", nil, false)
        end
      end
    end
  end
end
