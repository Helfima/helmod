-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ModelEdition
-- @extends #AbstractEdition
--

ModelEdition = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ModelEdition] onInit
--
function ModelEdition:onInit()
  self.panelCaption = ({"helmod_panel.model-edition"})
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ModelEdition] onUpdate
--
-- @param #LuaEvent event
--
function ModelEdition:onUpdate(event)
  self:updateInfo(event)
  self:updateShare(event)
  self:updateNote(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ModelEdition] updateInfo
--
-- @param #LuaEvent event
--
function ModelEdition:updateInfo(event)
  local model = Model.getModel()
  local info_panel = self:getFramePanel("information")
  info_panel.clear()
  
  GuiElement.add(info_panel, GuiLabel("label-info"):caption({"helmod_common.information"}):style("helmod_label_title_frame"))

  local block_table = GuiElement.add(info_panel, GuiTable("output-table"):column(2))

  GuiElement.add(block_table, GuiLabel("label-owner"):caption({"helmod_result-panel.owner"}))
  GuiElement.add(block_table, GuiLabel("value-owner"):caption(model.owner))

end

-------------------------------------------------------------------------------
-- Update share
--
-- @function [parent=#ModelEdition] updateShare
--
-- @param #LuaEvent event
--
function ModelEdition:updateShare(event)
  local model = Model.getModel()
  local share_panel = self:getFramePanel("share")
  share_panel.clear()

  GuiElement.add(share_panel, GuiLabel("label-share"):caption({"helmod_result-panel.share"}):style("helmod_label_title_frame"))
  
  local block_table = GuiElement.add(share_panel, GuiTable("output-table"):column(2))
  
  local tableAdminPanel = GuiElement.add(block_table, GuiTable("table"):column(2))
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-read"):caption({"helmod_common.reading"}):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))
  GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", "read", model.id):state(model_read):tooltip({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-write"):caption({"helmod_common.writing"}):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))
  GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", "write", model.id):state(model_write):tooltip({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-delete"):caption({"helmod_common.removal"}):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
  GuiElement.add(tableAdminPanel,GuiCheckBox( self.classname, "share-model", "delete", model.id):state(model_delete):tooltip({"tooltip.share-mod", {"helmod_common.removal"}}))
end

-------------------------------------------------------------------------------
-- Update note
--
-- @function [parent=#ModelEdition] updateNote
--
-- @param #LuaEvent event
--
function ModelEdition:updateNote(event)
  local model = Model.getModel()
  local note_panel = self:getFramePanel("note")
  note_panel.clear()
  local group_string = model.group or ""
  GuiElement.add(note_panel, GuiLabel("label-group"):caption({"helmod_common.group"}):style("helmod_label_title_frame"))
  local text_group = GuiElement.add(note_panel, GuiTextField(self.classname, "group-text"):text(group_string))
  text_group.style.width = 250

  local data_string = model.note or ""
  GuiElement.add(note_panel, GuiLabel("label-note"):caption({"helmod_common.note"}):style("helmod_label_title_frame"))
  local text_box = GuiElement.add(note_panel, GuiTextBox(self.classname, "note-text"):text(data_string))

  GuiElement.add(note_panel, GuiButton(self.classname, "model-note"):caption({"helmod_button.save"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ModelEdition] onEvent
--
-- @param #LuaEvent event
--
function ModelEdition:onEvent(event)
  if User.isWriter() then
    local model = Model.getModel()
    if event.action == "model-note" then
      local group_field_name = table.concat({self.classname, "group-text"},"=")
      local note_field_name = table.concat({self.classname, "note-text"},"=")
      if event.element.parent ~= nil and event.element.parent[group_field_name] ~= nil then
        local group = event.element.parent[group_field_name].text
        model.group = group or ""
      end
      if event.element.parent ~= nil and event.element.parent[note_field_name] ~= nil then
        local note = event.element.parent[note_field_name].text
        model.note = note or ""
      end
      Controller:send("on_gui_refresh", event)
    end
  end
end
