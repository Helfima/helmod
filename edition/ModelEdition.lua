-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class ModelEdition : FormModel
ModelEdition = newclass(FormModel)

-------------------------------------------------------------------------------
---On initialization
function ModelEdition:onInit()
    self.panelCaption = ({ "helmod_panel.model-edition" })
    self.panel_close_before_main = true
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function ModelEdition:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 500,
        maximal_height = math.max(height_main, 600),
    }
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function ModelEdition:onBind()
    Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function ModelEdition:onUpdate(event)
    self:updateInfo(event)
    self:updateShare(event)
    self:updateNote(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function ModelEdition:updateInfo(event)
    local model = self:getParameterObjects()
    local info_panel = self:getFramePanel("information")
    info_panel.clear()

    GuiElement.add(info_panel, GuiLabel("label-info"):caption({ "helmod_common.information" }):style("helmod_label_title_frame"))

    local block_table = GuiElement.add(info_panel, GuiTable("output-table"):column(2))

    local model_infos = Model.getModelInfos(model)
    local title_string = model_infos.title or ""
    GuiElement.add(block_table, GuiLabel("label-title"):caption({ "helmod_panel.model-title" }))
    local change_title = GuiElement.add(block_table, GuiTextField(self.classname, "change-title"):text(title_string))
    change_title.style.width = 200

    local group_string = model.group or ""
    GuiElement.add(block_table, GuiLabel("label-group"):caption({"helmod_common.group"}))
    local text_group = GuiElement.add(block_table, GuiTextField(self.classname, "group-text"):text(group_string))
    text_group.style.width = 250

    GuiElement.add(block_table, GuiLabel("label-primary"):caption({ "helmod_panel.model-icon-primary" }))
    local primary_icon = model_infos.primary_icon or {type=model.block_root.type, name=model.block_root.name, quality=model.block_root.quality}
    local primary_type = primary_icon.type or "signal"
    local primary_name = primary_icon.name
    local primary_quality = primary_icon.quality
    local primary_cell = GuiElement.add(block_table, GuiFlowH())
    primary_cell.style.horizontal_spacing = 5
    GuiElement.add(primary_cell, GuiButtonSelectSprite(self.classname, "change-icon", "primary_icon"):choose_with_quality(primary_type, primary_name, primary_quality):color(color))
    local flip_tooltip = {"helmod_button.flip-icons"}
    GuiElement.add(primary_cell, GuiButton(self.classname, "flip-icon"):sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black):style("helmod_button_menu"):tooltip(flip_tooltip))

    GuiElement.add(block_table, GuiLabel("label-secondary"):caption({ "helmod_panel.model-icon-secondary" }))
    local secondary_icon = model_infos.secondary_icon or {}
    local secondary_type = secondary_icon.type or "signal"
    local secondary_name = secondary_icon.name
    local secondary_quality = secondary_icon.quality
    GuiElement.add(block_table, GuiButtonSelectSprite(self.classname, "change-icon", "secondary_icon"):choose_with_quality(secondary_type, secondary_name, secondary_quality):color(color))

    GuiElement.add(block_table, GuiLabel("label-owner"):caption({ "helmod_result-panel.owner" }))
    GuiElement.add(block_table, GuiLabel("value-owner"):caption(model.owner))
end

-------------------------------------------------------------------------------
---Update share
---@param event LuaEvent
function ModelEdition:updateShare(event)
    local model = self:getParameterObjects()
    local share_panel = self:getFramePanel("share")
    share_panel.clear()

    GuiElement.add(share_panel, GuiLabel("label-share"):caption({ "helmod_result-panel.share" }):style("helmod_label_title_frame"))

    local block_table = GuiElement.add(share_panel, GuiTable("output-table"):column(2))

    local tableAdminPanel = GuiElement.add(block_table, GuiTable("table"):column(2))
    local model_read = false
    if model.share ~= nil and bit32.band(model.share, 1) > 0 then model_read = true end
    GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-read"):caption({ "helmod_common.reading" }):tooltip({ "tooltip.share-mod", { "helmod_common.reading" } }))
    GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", model.id, "read"):state(model_read):tooltip({ "tooltip.share-mod", { "helmod_common.reading" } }))

    local model_write = false
    if model.share ~= nil and bit32.band(model.share, 2) > 0 then model_write = true end
    GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-write"):caption({ "helmod_common.writing" }):tooltip({ "tooltip.share-mod", { "helmod_common.writing" } }))
    GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", model.id, "write"):state(model_write):tooltip({ "tooltip.share-mod", { "helmod_common.writing" } }))

    local model_delete = false
    if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
    GuiElement.add(tableAdminPanel, GuiLabel(self.classname, "share-model-delete"):caption({ "helmod_common.removal" }):tooltip({ "tooltip.share-mod", { "helmod_common.removal" } }))
    GuiElement.add(tableAdminPanel, GuiCheckBox(self.classname, "share-model", model.id, "delete"):state(model_delete):tooltip({ "tooltip.share-mod", { "helmod_common.removal" } }))
end

-------------------------------------------------------------------------------
---Update note
---@param event LuaEvent
function ModelEdition:updateNote(event)
    local model = self:getParameterObjects()
    local note_panel = self:getFramePanel("note")
    note_panel.clear()
    local group_string = model.group or ""
    GuiElement.add(note_panel, GuiLabel("label-group"):caption({ "helmod_common.group" }):style(
    "helmod_label_title_frame"))
    local text_group = GuiElement.add(note_panel, GuiTextField(self.classname, "group-text"):text(group_string))
    text_group.style.width = 250

    local data_string = model.note or ""
    GuiElement.add(note_panel, GuiLabel("label-note"):caption({ "helmod_common.note" }):style("helmod_label_title_frame"))
    local text_box = GuiElement.add(note_panel, GuiTextBox(self.classname, "note-text"):text(data_string))

    GuiElement.add(note_panel, GuiButton(self.classname, "model-note"):caption({ "helmod_button.save" }))
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function ModelEdition:onEvent(event)
    local model = self:getParameterObjects()
    if User.isWriter(model) then
        if event.action == "change-title" then
            local model_infos = Model.getModelInfos(model)
            local model_title = event.element.text
            model_infos.title = model_title
            Controller:send("on_gui_refresh", event)
        end
        
        if event.action == "change-icon" then
            local element_type = event.element.elem_type
            local element_value = event.element.elem_value
            if element_value ~= nil then
                local icon_name = event.item1
                local model_infos = Model.getModelInfos(model)
                model_infos[icon_name] = {type=element_type, name=element_value, quality=element_value.quality}
                Controller:send("on_gui_recipe_update", event)
            end
        end

        if event.action == "flip-icon" then
            local model_infos = Model.getModelInfos(model)
            local primary_icon = model_infos["primary_icon"] or {type=model.block_root.type, name=model.block_root.name, quality=model.block_root.quality} 
            local secondary_icon = model_infos["secondary_icon"]
            model_infos["primary_icon"] = secondary_icon
            model_infos["secondary_icon"] = primary_icon
            Controller:send("on_gui_refresh", event)
        end

        if event.action == "model-note" then
            local group_field_name = table.concat({ self.classname, "group-text" }, "=")
            local note_field_name = table.concat({ self.classname, "note-text" }, "=")
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

        if event.action == "share-model" then
            local access = event.item2
            if model ~= nil then
                if access == "read" then
                    if model.share == nil or not (bit32.band(model.share, 1) > 0) then
                        model.share = 1
                    else
                        model.share = 0
                    end
                end
                if access == "write" then
                    if model.share == nil or not (bit32.band(model.share, 2) > 0) then
                        model.share = 3
                    else
                        model.share = 1
                    end
                end
                if access == "delete" then
                    if model.share == nil or not (bit32.band(model.share, 4) > 0) then
                        model.share = 7
                    else
                        model.share = 3
                    end
                end
            end
            Controller:send("on_gui_refresh", event)
        end
    end
end
