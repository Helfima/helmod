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
-- Add cell element
--
-- @function [parent=#AbstractTab] addCellElement
--
-- @param #LuaGuiElement guiTable
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function AbstractTab.methods:addCellElement(guiTable, element, action, select, tooltip_name, color)
  Logging:trace(self:classname(), "addCellElement():", guiTable, element, action, select, tooltip_name, color)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local cell = nil
  local button = nil

  if display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = self:addCellLabel(guiTable, element.name, Format.formatNumberKilo(element.count))
  else
    cell = self:addCellLabel(guiTable, element.name, Format.formatNumberElement(element.count))
  end

  self:addIconCell(cell, element, action, select, tooltip_name, color)
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
    local cell = ElementGui.addGuiFlowH(guiTable,"header-"..name)
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
-- Add cell label
--
-- @function [parent=#AbstractTab] addCellLabel
--
-- @param #string name
-- @param #string label
--
function AbstractTab.methods:addCellLabel(guiTable, name, label, minimal_width)
  Logging:trace(self:classname(), "addCellLabel():", guiTable, name, label)
  local display_cell_mod = Player.getSettings("display_cell_mod")
  local cell = nil

  if display_cell_mod == "small-text"then
    -- small
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_icon_text_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "small-icon" then
    -- small
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_icon_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 50
  else
    -- default
    cell = ElementGui.addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    ElementGui.addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 60

  end
  return cell
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
