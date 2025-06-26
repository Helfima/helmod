-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class BlockEdition : FormModel
BlockEdition = newclass(FormModel)

-------------------------------------------------------------------------------
---On initialization
function BlockEdition:onInit()
    print("BlockEdition:onInit()")
    self.panelCaption = ({ "helmod_block_edition_panel.pane-title" })
    self.panel_close_before_main = true
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function BlockEdition:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 500,
        maximal_height = math.max(height_main, 600),
    }
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function BlockEdition:onBind()
    Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function BlockEdition:onUpdate(event)
    self:updateInfo(event)
    self:updateNote(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function BlockEdition:updateInfo(event)
    local model, block = self:getParameterObjects()
    local info_panel = self:getFramePanel("information")
    info_panel.clear()

    GuiElement.add(info_panel, GuiLabel("label-info"):caption({ "helmod_common.information" }):style("helmod_label_title_frame"))

    local block_table = GuiElement.add(info_panel, GuiTable("output-table"):column(2))

    local block_infos = Model.getBlockInfos(block)
    local title_string = block_infos.title or ""
    GuiElement.add(block_table, GuiLabel("label-title"):caption({ "helmod_panel.model-title" }))
    local change_title = GuiElement.add(block_table, GuiTextField(self.classname, "change-title"):text(title_string))
    change_title.style.width = 200

    GuiElement.add(block_table, GuiLabel("label-primary"):caption({ "helmod_block_edition_panel.block-icon" }))
    local icon = block_infos.icon or {}
    local primary_type = icon.type or "signal"
    local primary_name = icon.name
    local primary_quality = icon.quality
    local primary_cell = GuiElement.add(block_table, GuiFlowH())
    primary_cell.style.horizontal_spacing = 5
    GuiElement.add(primary_cell, GuiButtonSelectSprite(self.classname, "change-icon", "icon"):choose_with_quality(primary_type, primary_name, primary_quality))

    local flip_tooltip = {"helmod_button.remove"}
    GuiElement.add(primary_cell, GuiButton(self.classname, "remove-icon"):sprite("menu", defines.sprites.eraser.black, defines.sprites.eraser.black):style("helmod_button_menu"):tooltip(flip_tooltip))

end

-------------------------------------------------------------------------------
---Update note
---@param event LuaEvent
function BlockEdition:updateNote(event)
    local model, block = self:getParameterObjects()
    local block_infos = Model.getBlockInfos(block)
    local note_panel = self:getFramePanel("note")
    note_panel.clear()

    local data_string = block_infos.note or ""
    GuiElement.add(note_panel, GuiLabel("label-note"):caption({ "helmod_common.note" }):style("helmod_label_title_frame"))
    local text_box = GuiElement.add(note_panel, GuiTextBox(self.classname, "note-text"):text(data_string))

    GuiElement.add(note_panel, GuiButton(self.classname, "block-note"):caption({ "helmod_button.save" }))
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function BlockEdition:onEvent(event)
    local model, block = self:getParameterObjects()
    if User.isWriter(model) then
        if event.action == "change-title" then
            local block_infos = Model.getBlockInfos(block)
            local block_title = event.element.text
            block_infos["title"] = block_title
            Controller:send("on_gui_refresh", event)
        end
        
        if event.action == "change-icon" then
            local element_type = event.element.elem_type
            local element_value = event.element.elem_value
            if element_value ~= nil then
                local icon_name = event.item1
                local block_infos = Model.getBlockInfos(block)
                block_infos[icon_name] = {type=element_type, name=element_value, quality=element_value.quality}
                Controller:send("on_gui_recipe_update", event)
            end
        end

        if event.action == "remove-icon" then
            local block_infos = Model.getBlockInfos(block)
            block_infos["icon"] = nil
            Controller:send("on_gui_refresh", event)
        end

        if event.action == "block-note" then
            local note_field_name = table.concat({ self.classname, "note-text" }, "=")
            local note_text = event.element.parent[note_field_name].text
            if note_text == nil or note_text == "" then
                note_text = ""
            end
            local block_infos = Model.getBlockInfos(block)
            block_infos["note"] = note_text
            Controller:send("on_gui_refresh", event)
        end
    end
end
