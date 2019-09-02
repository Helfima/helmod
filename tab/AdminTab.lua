require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AdminTab
-- @extends #AbstractTab
--

AdminTab = newclass(AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#AdminTab] getButtonCaption
--
-- @return #string
--
function AdminTab:getButtonCaption()
  return {"helmod_result-panel.tab-button-admin"}
end

-------------------------------------------------------------------------------
-- Get Button Styles
--
-- @function [parent=#AdminTab] getButtonStyles
--
-- @return boolean
--
function AdminTab:getButtonStyles()
  return "helmod_button_icon_database","helmod_button_icon_database_selected"
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#AdminTab] isVisible
--
-- @return boolean
--
function AdminTab:isVisible()
  return Player.isAdmin()
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#AdminTab] isSpecial
--
-- @return boolean
--
function AdminTab:isSpecial()
  return true
end

-------------------------------------------------------------------------------
-- Has index model (for Tab panel)
--
-- @function [parent=#AdminTab] hasIndexModel
--
-- @return #boolean
--
function AdminTab:hasIndexModel()
  return false
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminTab] updateData
--
function AdminTab:updateData()
  Logging:debug(self.classname, "updatePowers()")

  -- data
  local scroll_panel = self:getResultScrollPanel({"helmod_result-panel.tab-title-admin"})
  
  -- Rule List
  local rule_panel = ElementGui.addGuiFrameH(scroll_panel,"rule-list", helmod_frame_style.section, {"helmod_result-panel.rule-list"})
  rule_panel.style.horizontally_stretchable = true
  
  local count_rule = #Model.getRules()
  if count_rule > 0 then
    
    local result_table = ElementGui.addGuiTable(rule_panel,"list-data", 8, "helmod_table-rule-odd")

    self:addRuleListHeader(result_table)

    for rule_id, element in spairs(Model.getRules(), function(t,a,b) return t[b].index > t[a].index end) do
      self:addRuleListRow(result_table, element, rule_id)
    end

  end
  
  -- Sheet List
  local sheet_panel = ElementGui.addGuiFrameH(scroll_panel,"sheet-list", helmod_frame_style.section, {"helmod_result-panel.sheet-list"})
  sheet_panel.style.horizontally_stretchable = true

  local count_model = Model.countModel()
  if count_model > 0 then
    
    local result_table = ElementGui.addGuiTable(sheet_panel,"list-data", 3, "helmod_table-odd")

    self:addSheetListHeader(result_table)

    local i = 0
    for _, element in spairs(Model.getModels(true), function(t,a,b) return t[b].owner > t[a].owner end) do
      self:addSheetListRow(result_table, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add rule List header
--
-- @function [parent=#AdminTab] addRuleListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab:addRuleListHeader(itable)
  Logging:debug(self.classname, "addRuleListHeader()", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data
  self:addCellHeader(itable, "header-index", {"helmod_result-panel.col-header-index"})
  self:addCellHeader(itable, "header-mod", {"helmod_result-panel.col-header-mod"})
  self:addCellHeader(itable, "header-name", {"helmod_result-panel.col-header-name"})
  self:addCellHeader(itable, "header-category", {"helmod_result-panel.col-header-category"})
  self:addCellHeader(itable, "header-type", {"helmod_result-panel.col-header-type"})
  self:addCellHeader(itable, "header-value", {"helmod_result-panel.col-header-value"})
  self:addCellHeader(itable, "header-excluded", {"helmod_result-panel.col-header-excluded"})
end

-------------------------------------------------------------------------------
-- Add row Rule List
--
-- @function [parent=#AdminTab] addRuleListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addRuleListRow(gui_table, rule, rule_id)
  Logging:debug(self.classname, "addSheetListRow()", gui_table, rule, rule_id)

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..rule_id, 4)
  ElementGui.addGuiButton(cell_action, self.classname.."=rule-remove=ID=", rule_id, "helmod_button_default", ({"helmod_result-panel.row-button-delete"}), ({"tooltip.remove-element"}))

  -- col index
  ElementGui.addGuiLabel(gui_table, "index"..rule_id, rule.index)
  
  -- col mod
  ElementGui.addGuiLabel(gui_table, "mod"..rule_id, rule.mod)
  
  -- col name
  ElementGui.addGuiLabel(gui_table, "name"..rule_id, rule.name)
  
  -- col category
  ElementGui.addGuiLabel(gui_table, "category"..rule_id, rule.category)
  
  -- col type
  ElementGui.addGuiLabel(gui_table, "type"..rule_id, rule.type)
  
  -- col value
  ElementGui.addGuiLabel(gui_table, "value"..rule_id, rule.value)
  
  -- col value
  ElementGui.addGuiLabel(gui_table, "excluded"..rule_id, rule.excluded)
  
end

-------------------------------------------------------------------------------
-- Add Sheet List header
--
-- @function [parent=#AdminTab] addSheetListHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab:addSheetListHeader(itable)
  Logging:debug(self.classname, "addSheetListHeader()", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data owner
  self:addCellHeader(itable, "owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "element", {"helmod_result-panel.col-header-sheet"})
end

-------------------------------------------------------------------------------
-- Add row Sheet List
--
-- @function [parent=#AdminTab] addSheetListRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab:addSheetListRow(gui_table, model)
  Logging:debug(self.classname, "addSheetListRow()", gui_table, model)

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..model.id, 4)
  if model.share ~= nil and bit32.band(model.share, 1) > 0 then
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=read=", model.id, "helmod_button_selected", "R", {"tooltip.share-mod", {"helmod_common.reading"}})
  else
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=read=", model.id, "helmod_button_default", "R", {"tooltip.share-mod", {"helmod_common.reading"}})
  end
  if model.share ~= nil and bit32.band(model.share, 2) > 0 then
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=write=", model.id, "helmod_button_selected", "W", {"tooltip.share-mod", {"helmod_common.writing"}})
  else
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=write=", model.id, "helmod_button_default", "W", {"tooltip.share-mod", {"helmod_common.writing"}})
  end
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=delete=", model.id, "helmod_button_selected", "X", {"tooltip.share-mod", {"helmod_common.removal"}})
  else
    ElementGui.addGuiButton(cell_action, self.classname.."=share-model=ID=delete=", model.id, "helmod_button_default", "X", {"tooltip.share-mod", {"helmod_common.removal"}})
  end

  -- col owner
  local cell_owner = ElementGui.addGuiFrameH(gui_table,"owner"..model.id, helmod_frame_style.hidden)
  ElementGui.addGuiLabel(cell_owner, model.id, model.owner or "empty", "helmod_label_right_70")
  
  -- col element
  local cell_element = ElementGui.addGuiFrameH(gui_table,"element"..model.id, helmod_frame_style.hidden)
  local element = Model.firstRecipe(model.blocks)
  if element ~= nil then
    ElementGui.addGuiButtonSprite(cell_element, self.classname.."=donothing=ID="..model.id.."=", Player.getIconType(element), element.name, model.id, RecipePrototype.load(element).getLocalisedName())
  else
    ElementGui.addGuiButton(cell_element, self.classname.."=donothing=ID=", model.id, "helmod_button_icon_help_selected")
  end
  
end
