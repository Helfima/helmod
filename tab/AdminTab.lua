require "tab.AbstractTab"
-------------------------------------------------------------------------------
-- Class to build tab
--
-- @module AdminTab
-- @extends #AbstractTab
--

AdminTab = setclass("HMAdminTab", AbstractTab)

-------------------------------------------------------------------------------
-- Return button caption
--
-- @function [parent=#AdminTab] getButtonCaption
--
-- @return #string
--
function AdminTab.methods:getButtonCaption()
  return {"helmod_result-panel.tab-button-admin"}
end

-------------------------------------------------------------------------------
-- Update data
--
-- @function [parent=#AdminTab] updateData
--
function AdminTab.methods:updateData()
  Logging:debug(self:classname(), "updatePowers()")
  local globalGui = Player.getGlobalGui()

  -- data
  local scroll_panel = self.parent:getResultScrollPanel({"helmod_result-panel.tab-title-admin"})
  
  local menu_panel = ElementGui.addGuiFrameH(scroll_panel,"menu", helmod_frame_style.section, {"helmod_result-panel.sheet-list"})
  menu_panel.style.horizontally_stretchable = true

  local count_model = Model.countModel()
  if count_model > 0 then
    
    local result_table = ElementGui.addGuiTable(menu_panel,"list-data", 3, "helmod_table-odd")

    self:addTableHeader(result_table)

    local i = 0
    for _, element in spairs(Model.getModels(true), function(t,a,b) return t[b].owner > t[a].owner end) do
      self:addTableRow(result_table, element)
    end

  end
end

-------------------------------------------------------------------------------
-- Add table header
--
-- @function [parent=#AdminTab] addTableHeader
--
-- @param #LuaGuiElement itable container for element
--
function AdminTab.methods:addTableHeader(itable)
  Logging:debug(self:classname(), "addTableHeader():", itable)

  -- col action
  self:addCellHeader(itable, "action", {"helmod_result-panel.col-header-action"})
  -- data owner
  self:addCellHeader(itable, "owner", {"helmod_result-panel.col-header-owner"})
  self:addCellHeader(itable, "element", {"helmod_result-panel.col-header-sheet"})
end

-------------------------------------------------------------------------------
-- Add row table
--
-- @function [parent=#AdminTab] addTableRow
--
-- @param #LuaGuiElement itable container for element
-- @param #table model
--
function AdminTab.methods:addTableRow(gui_table, model)
  Logging:debug(self:classname(), "addPowersRow():", gui_table, model)

  -- col action
  local cell_action = ElementGui.addCell(gui_table, "action"..model.id, 4)
  if model.share ~= nil and bit32.band(model.share, 1) > 0 then
    ElementGui.addGuiButton(cell_action, self.parent:classname().."=share-model=ID=read=", model.id, "helmod_button_selected", "R", {"tooltip.share-mod", {"helmod_common.reading"}})
  else
    ElementGui.addGuiButton(cell_action, self.parent:classname().."=share-model=ID=read=", model.id, "helmod_button_default", "R", {"tooltip.share-mod", {"helmod_common.reading"}})
  end
  if model.share ~= nil and bit32.band(model.share, 2) > 0 then
    ElementGui.addGuiButton(cell_action, self.parent:classname().."=share-model=ID=write=", model.id, "helmod_button_selected", "W", {"tooltip.share-mod", {"helmod_common.writing"}})
  else
    ElementGui.addGuiButton(cell_action, self.parent:classname().."=share-model=ID=write=", model.id, "helmod_button_default", "W", {"tooltip.share-mod", {"helmod_common.writing"}})
  end
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then
    ElementGui.addGuiButton(cell_action, self.parent:classname().."=share-model=ID=delete=", model.id, "helmod_button_selected", "X", {"tooltip.share-mod", {"helmod_common.removal"}})
  else
    ElementGui.addGuiButton(cell_action, self.parent:classname().."=share-model=ID=delete=", model.id, "helmod_button_default", "X", {"tooltip.share-mod", {"helmod_common.removal"}})
  end

  -- col owner
  local cell_owner = ElementGui.addGuiFrameH(gui_table,"owner"..model.id, helmod_frame_style.hidden)
  ElementGui.addGuiLabel(cell_owner, model.id, model.owner or "empty", "helmod_label_right_70")
  
  -- col element
  local cell_element = ElementGui.addGuiFrameH(gui_table,"element"..model.id, helmod_frame_style.hidden)
  local element = Model.firstRecipe(model.blocks)
  if element ~= nil then
    ElementGui.addGuiButtonSprite(cell_element, self:classname().."=donothing=ID="..model.id.."=", Player.getIconType(element), element.name, model.id, RecipePrototype.load(element).getLocalisedName())
  else
    ElementGui.addGuiButton(cell_element, self:classname().."=donothing=ID=", model.id, "helmod_button_icon_help_selected")
  end
  
end
