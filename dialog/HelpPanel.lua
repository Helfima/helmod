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
      localised_text = "getting-start",
      count = 1
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
  return ElementGui.addGuiFrameV(panel, "header-panel", "helmod_frame_resize_row_width", {"helmod_settings-panel.about-section"})
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
  return ElementGui.addGuiFrameV(panel, "menu-panel", "helmod_frame_resize_row_width")
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
  return ElementGui.addGuiFrameV(panel, "content-panel", "helmod_frame_resize_row_width")
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
  
  ElementGui.addGuiDropDown(menu_panel,self:classname().."=change-page=ID=", nil, items)
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
  local content_panel = self:getContentPanel()
  local section = help_data[item or 1]
  for i,content in pairs(section.content) do
    if content.sprite then
      ElementGui.addSprite(content_panel, "helmod_"..content.sprite)
    end
    for line=1, content.count do
      ElementGui.addGuiLabel(content_panel, table.concat({section.name, "-",i, "-", line}), {table.concat({"helmod_help.",content.localised_text,"-",line})}, "helmod_label_help", nil, false)
    end
  end
end