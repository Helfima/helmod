-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AbstractTab
-- @extends #ElementGui
--

AbstractTab = setclass("HMAbstractTab", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#AbstractTab] init
--
-- @param #Controller parent parent controller
--
function AbstractTab.methods:init(parent)
  self.parent = parent
  self.player = self.parent.player
  self.model = self.parent.model

  self.color_button_edit="green"
  self.color_button_add="yellow"
  self.color_button_rest="red"
end

-------------------------------------------------------------------------------
-- Before update
--
-- @function [parent=#AbstractTab] beforeUpdate
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:beforeUpdate(player, item, item2, item3)
  Logging:trace(self:classname(), "beforeUpdate():", player, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Add cell element
--
-- @function [parent=#AbstractTab] addCellElement
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #table element production block
-- @param #string action
-- @param #boolean select true if select button
-- @param #string tooltip_name tooltip name
-- @param #string color button color
--
function AbstractTab.methods:addCellElement(player, guiTable, element, action, select, tooltip_name, color)
  Logging:trace(self:classname(), "addCellElement():", player, guiTable, element, action, select, tooltip_name, color)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  local cell = nil
  local button = nil

  if display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = self:addCellLabel(player, guiTable, element.name, self:formatNumberKilo(element.count))
  else
    cell = self:addCellLabel(player, guiTable, element.name, self:formatNumberElement(element.count))
  end

  self:addIconCell(player, cell, element, action, select, tooltip_name, color)
end

-------------------------------------------------------------------------------
-- Add cell header
--
-- @function [parent=#AbstractTab] addCellHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement guiTable
-- @param #string name
-- @param #string caption
-- @param #string sorted
--
function AbstractTab.methods:addCellHeader(player, guiTable, name, caption, sorted)
  Logging:trace(self:classname(), "addCellHeader():", player, guiTable, name, caption, sorted)

  if (name ~= "index" and name ~= "id" and name ~= "name") or self.player:getSettings(player, "display_data_col_"..name, true) then
    local cell = self:addGuiFlowH(guiTable,"header-"..name)
    self:addGuiLabel(cell, "label", caption)
    if sorted ~= nil then
      self:addGuiButton(cell, self.parent:classname().."=change-sort=ID=", sorted, self.player:getSortedStyle(player, sorted))
    end
  end
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#AbstractTab] addIconRecipeCell
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function AbstractTab.methods:addIconRecipeCell(player, cell, element, action, select, tooltip_name, color)
  Logging:trace(self:classname(), "addIconRecipeCell():", element, action, select, tooltip_name, color)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSpriteM(cell, action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSpriteM(cell, action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    end
  else
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSprite(cell, action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSprite(cell, action, self.player:getRecipeIconType(player, element), element.name, element.name, ({tooltip_name, self.player:getRecipeLocalisedName(player, element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add icon in cell element
--
-- @function [parent=#AbstractTab] addIconCell
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement cell
-- @param #table element production block
-- @param #string action
-- @param #boolean select
-- @param #string tooltip_name
-- @param #string color
--
function AbstractTab.methods:addIconCell(player, cell, element, action, select, tooltip_name, color)
  Logging:trace(self:classname(), "addIconCell():", player, cell, element, action, select, tooltip_name, color)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  -- ingredient = {type="item", name="steel-plate", amount=8}
  if display_cell_mod == "small-icon" then
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSpriteM(cell, action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSpriteM(cell, action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    end
  else
    if cell ~= nil and select == true then
      self:addGuiButtonSelectSprite(cell, action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    else
      self:addGuiButtonSprite(cell, action, self.player:getIconType(element), element.name, "X"..self.model:getElementAmount(element), ({tooltip_name, self.player:getLocalisedName(player, element)}), color)
    end
  end
end

-------------------------------------------------------------------------------
-- Add cell label
--
-- @function [parent=#AbstractTab] addCellLabel
--
-- @param #LuaPlayer player
-- @param #string name
-- @param #string label
--
function AbstractTab.methods:addCellLabel(player, guiTable, name, label, minimal_width)
  Logging:trace(self:classname(), "addCellLabel():", guiTable, name, label)
  local display_cell_mod = self.player:getSettings(player, "display_cell_mod")
  local cell = nil

  if display_cell_mod == "small-text"then
    -- small
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_icon_text_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "small-icon" then
    -- small
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_icon_sm").style["minimal_width"] = minimal_width or 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 50
  else
    -- default
    cell = self:addGuiFlowH(guiTable,"cell_"..name, "helmod_flow_cell")
    self:addGuiLabel(cell, name, label, "helmod_label_row_right").style["minimal_width"] = minimal_width or 60

  end
  return cell
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#AbstractTab] updateHeader
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:updateHeader(player, item, item2, item3)
  Logging:debug("AbstractTab", "updateHeader():", player, item, item2, item3)
end
-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AbstractTab] updateData
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function AbstractTab.methods:updateData(player, item, item2, item3)
  Logging:debug("AbstractTab", "updateData():", player, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Format number for factory
--
-- @function [parent=#AbstractTab] formatNumberFactory
--
-- @param #number number
--
function AbstractTab.methods:formatNumberFactory(number)
  local decimal = 2
  local format_number = self.player:getSettings(nil, "format_number_factory", true)
  if format_number == "0" then decimal = 0 end
  if format_number == "0.0" then decimal = 1 end
  if format_number == "0.00" then decimal = 2 end
  return self:formatNumber(number, decimal)
end


-------------------------------------------------------------------------------
-- Format number for element product or ingredient
--
-- @function [parent=#AbstractTab] formatNumberElement
--
-- @param #number number
--
function AbstractTab.methods:formatNumberElement(number)
  local decimal = 2
  local format_number = self.player:getSettings(nil, "format_number_element", true)
  if format_number == "0" then decimal = 0 end
  if format_number == "0.0" then decimal = 1 end
  if format_number == "0.00" then decimal = 2 end
  return self:formatNumber(number, decimal)
end
