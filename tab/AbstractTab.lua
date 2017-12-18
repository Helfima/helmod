-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AbstractTab
--

AbstractTab = setclass("HMAbstractTab")

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#AbstractTab] init
--
-- @param #Controller parent parent controller
--
function AbstractTab.methods:init(parent)
  self.parent = parent

  self.color_button_edit="green"
  self.color_button_add="yellow"
  self.color_button_rest="red"
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
      ElementGui.addGuiButton(cell, self.parent:classname().."=change-sort=ID=", sorted, Player.getSortedStyle(sorted))
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
-- Add icon in cell element
--
-- @function [parent=#AbstractTab] addIconCell
--
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function AbstractTab.methods:addIconCell(cell, element, action, select, tooltip_name, color)
  Logging:trace(self:classname(), "addIconCell():", cell, element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSpriteM(cell, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSpriteM(cell, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
    end
  else
    if cell ~= nil and select == true then
      ElementGui.addGuiButtonSelectSprite(cell, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
    else
      ElementGui.addGuiButtonSprite(cell, action, Player.getIconType(element), element.name, "X"..Product.getElementAmount(element), ({tooltip_name, Player.getLocalisedName(element)}), color)
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
