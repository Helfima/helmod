-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AbstractTab
--

AbstractTab = setclass("HMAbstractTab", Form)

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#AbstractTab] getParentPanel
--
-- @return #LuaGuiElement
--
function AbstractTab.methods:getParentPanel()
  return Controller.getTabPanel()
end

-------------------------------------------------------------------------------
-- Get or create model panel
--
-- @function [parent=#AbstractTab] getDebugPanel
--
function AbstractTab.methods:getDebugPanel()
  local parent_panel = self:getPanel()
  if parent_panel["debug_panel"] ~= nil and parent_panel["debug_panel"].valid then
    return parent_panel["debug_panel"]
  end
  local panel = ElementGui.addGuiFrameH(parent_panel, "debug_panel", helmod_frame_style.panel, "Debug")
  return panel
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#AbstractTab] getInfoPanel
--
function AbstractTab.methods:getInfoPanel()
  local parent_panel = self:getPanel()
  if parent_panel["info_panel"] ~= nil and parent_panel["info_panel"].valid then
    return parent_panel["info_panel"]
  end
  local table_panel = ElementGui.addGuiTable(parent_panel, "info_panel", 2, helmod_table_style.panel)
  ElementGui.setStyle(table_panel, "block_info", "height")
  return table_panel
end

-------------------------------------------------------------------------------
-- Get or create result panel
--
-- @function [parent=#AbstractTab] getResultPanel
--
-- @param #string caption
--
function AbstractTab.methods:getResultPanel(caption)
  local parent_panel = self:getPanel()
  if parent_panel["result"] ~= nil and parent_panel["result"].valid then
    return parent_panel["result"]
  end
  local panel = ElementGui.addGuiFrameV(parent_panel, "result", helmod_frame_style.panel, caption)
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#AbstractTab] getResultScrollPanel
--
-- @param #string caption
--
function AbstractTab.methods:getResultScrollPanel(caption)
  local parent_panel = self:getResultPanel(caption)
  if parent_panel["scroll-data"] ~= nil and parent_panel["scroll-data"].valid then
    return parent_panel["scroll-data"]
  end
  local scroll_panel = ElementGui.addGuiScrollPane(parent_panel, "scroll-data", helmod_frame_style.scroll_pane, true, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Get or create result scroll panel
--
-- @function [parent=#AbstractTab] getDataScrollPanel
--
-- @param #string caption
--
function AbstractTab.methods:getDataScrollPanel(caption)
  local parent_panel = self:getResultPanel(caption)
  ElementGui.setStyle(parent_panel, "block_data", "height")
  if parent_panel["scroll-data"] ~= nil and parent_panel["scroll-data"].valid then
    return parent_panel["scroll-data"]
  end
  local scroll_panel = ElementGui.addGuiScrollPane(parent_panel, "scroll-data", helmod_frame_style.scroll_pane, true, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true
  return scroll_panel
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#AbstractTab] update
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:update(item, item2, item3)
  Logging:debug(self:classname(), "update():", item, item2, item3)
  Logging:debug(self:classname(), "update():global", global)
  local globalGui = Player.getGlobalGui()
  local parent_panel = self:getParentPanel()

  parent_panel.clear()

  self:beforeUpdate(item, item2, item3)
  self:updateHeader(item, item2, item3)
  self:updateData(item, item2, item3)

  Logging:debug(self:classname(), "debug_mode", Player.getSettings("debug"))
  if Player.getSettings("debug", true) ~= "none" then
    self:updateDebugPanel()
  end

end

-------------------------------------------------------------------------------
-- Before update
--
-- @function [parent=#AbstractTab] beforeUpdate
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:beforeUpdate(item, item2, item3)
  Logging:trace(self:classname(), "beforeUpdate():", item, item2, item3)
end

-------------------------------------------------------------------------------
-- Add cell header
--
-- @function [parent=#AbstractTab] addCellHeader
--
-- @param #LuaGuiElement guiTable
-- @param #string name
-- @param #string caption
-- @param #string sorted
--
function AbstractTab.methods:addCellHeader(guiTable, name, caption, sorted)
  Logging:trace(self:classname(), "addCellHeader():", guiTable, name, caption, sorted)

  if (name ~= "index" and name ~= "id" and name ~= "name" and name ~= "type") or Player.getSettings("display_data_col_"..name, true) then
    local cell = ElementGui.addGuiFrameH(guiTable,"header-"..name, helmod_frame_style.hidden)
    ElementGui.addGuiLabel(cell, "label", caption)
    if sorted ~= nil then
      ElementGui.addGuiButton(cell, self:classname().."=change-sort=ID=", sorted, Player.getSortedStyle(sorted))
    end
  end
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#AbstractTab] addIconRecipeCell
--
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
-- @deprecated
--
function AbstractTab.methods:addIconRecipeCell(cell, element, action, select, tooltip_name, color)
  Logging:trace(self:classname(), "addIconRecipeCell():", element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSpriteM(cell, action, Player.getRecipeIconType(element), element.name, element.name, ({tooltip_name, Player.getRecipeLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSpriteM(cell, action, Player.getRecipeIconType(element), element.name, element.name, ({tooltip_name, Player.getRecipeLocalisedName(element)}), color)
    end
  else
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSprite(cell, action, Player.getRecipeIconType(element), element.name, element.name, ({tooltip_name, Player.getRecipeLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSprite(cell, action, Player.getRecipeIconType(element), element.name, element.name, ({tooltip_name, Player.getRecipeLocalisedName(element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Update debug panel
--
-- @function [parent=#AbstractTab] updateDebugPanel
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:updateDebugPanel(item, item2, item3)
  Logging:debug("AbstractTab", "updateDebugPanel():", item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#AbstractTab] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:updateHeader(item, item2, item3)
  Logging:debug("AbstractTab", "updateHeader():", item, item2, item3)
end
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AbstractTab] updateData
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:updateData(item, item2, item3)
  Logging:debug("AbstractTab", "updateData():", item, item2, item3)
end
