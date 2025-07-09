-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class BlockEdition : FormModel
BlockEdition = newclass(FormModel)

-------------------------------------------------------------------------------
---On initialization
function BlockEdition:onInit()
    self.panel_close_before_main = true
end

local is_model = false
-------------------------------------------------------------------------------
---On before event
---@param event LuaEvent
function BlockEdition:onBeforeOpen(event)
    FormModel.onBeforeOpen(self, event)
    if event.item3 == "model" then
        self.panelCaption = ({ "helmod_panel.model-edition" })
        is_model = true
    else
        self.panelCaption = ({ "helmod_block_edition_panel.pane-title" })
        is_model = false
    end
end
-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function BlockEdition:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 500,
        maximal_height = math.max(height_main, 500),
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
    if is_model then
        self:updateShare(event)
    end
    self:updateNote(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function BlockEdition:updateInfo(event)
    local model, block = self:getParameterObjects()
    local block_infos = Model.getBlockInfos(block)

    -- The panel we're creating/using.
    local info_panel = self:getFramePanel("information")
    info_panel.clear() -- Obligatory

    -- The title at the top of the panel.
    local info_panel_title = GuiLabel("label-info")
    info_panel_title:caption({ "helmod_common.information" })
    info_panel_title:style("helmod_label_title_frame")
    GuiElement.add(info_panel, info_panel_title)

    -- The form where the user enters info such as title and icons.
    local form = GuiElement.add(info_panel, GuiTable("output-table"):column(2))

    if is_model then
        GuiElement.add(form, GuiLabel("label-owner"):caption({ "helmod_result-panel.owner" }))
        GuiElement.add(form, GuiLabel("value-owner"):caption(model.owner))
    end

    -- Title input label
    local title_label = GuiLabel("label-title")
    title_label:caption({ "helmod_block_edition_panel.block-title" })
    GuiElement.add(form, title_label)

    -- Title input field
    local title_text_entry_field = GuiTextField(self.classname, "change-title")
    local prepopulated_title = block_infos.title or ""
    title_text_entry_field:text(prepopulated_title)
    GuiElement.add(form, title_text_entry_field).style.width = 200

    if is_model then
        -- Group input label
        local group_label = GuiLabel("label-group")
        group_label:caption({ "helmod_common.group" })
        GuiElement.add(form, group_label)

        -- Group input field
        local group_text_entry_field = GuiTextField(self.classname, "change-group")
        local prepopulated_group = model.group or ""
        group_text_entry_field:text(prepopulated_group)
        GuiElement.add(form, group_text_entry_field).style.width = 200
    end

    -- Primary icon input label
    local primary_icon_label = GuiLabel("label-primary-icon"):caption({ "helmod_block_edition_panel.block-icon-primary" })
    GuiElement.add(form, primary_icon_label)
    -- The container which holds the primary icon option buttons.
    local primary_icon_options_container = GuiElement.add(form, GuiFlowH())
    primary_icon_options_container.style.horizontal_spacing = 5
    -- The primary icon picker button.
    local prepopulated_primary_icon = block_infos.primary_icon or {}
    local primary_icon_picker = GuiButtonSelectSprite(self.classname, "change-primary-icon", "icon")
    primary_icon_picker:choose_with_quality(
        prepopulated_primary_icon.type or "signal",
        prepopulated_primary_icon.name,
        prepopulated_primary_icon.quality
    )
    GuiElement.add(primary_icon_options_container, primary_icon_picker)
    -- Remove primary icon button.
    local remove_icon_button = GuiButton(self.classname, "remove-primary-icon")
    remove_icon_button:sprite("menu", defines.sprites.eraser.black, defines.sprites.eraser.black)
    remove_icon_button:style("helmod_button_menu")
    remove_icon_button:tooltip({"helmod_button.remove"})
    GuiElement.add(primary_icon_options_container, remove_icon_button)
    -- Switch icons button.
    local switch_icons_button = GuiButton(self.classname, "switch-icons")
    switch_icons_button:sprite("menu", defines.sprites.arrow_bottom.black, defines.sprites.arrow_bottom.black)
    switch_icons_button:style("helmod_button_menu")
    switch_icons_button:tooltip({"helmod_button.flip-icons"})
    GuiElement.add(primary_icon_options_container, switch_icons_button)


    -- Secondary icon input label
    local secondary_icon_label = GuiLabel("label-secondary-icon"):caption({ "helmod_block_edition_panel.block-icon-secondary" })
    GuiElement.add(form, secondary_icon_label)
    -- The container which holds the secondary icon option buttons.
    local secondary_icon_options_container = GuiElement.add(form, GuiFlowH())
    secondary_icon_options_container.style.horizontal_spacing = 5
    -- The secondary icon picker button.
    local prepopulated_secondary_icon = block_infos.secondary_icon or {}
    local secondary_icon_picker = GuiButtonSelectSprite(self.classname, "change-secondary-icon", "icon")
    secondary_icon_picker:choose_with_quality(
        prepopulated_secondary_icon.type or "signal",
        prepopulated_secondary_icon.name,
        prepopulated_secondary_icon.quality
    )
    GuiElement.add(secondary_icon_options_container, secondary_icon_picker)
    -- Remove secondary icon button.
    local remove_icon_button = GuiButton(self.classname, "remove-secondary-icon")
    remove_icon_button:sprite("menu", defines.sprites.eraser.black, defines.sprites.eraser.black)
    remove_icon_button:style("helmod_button_menu")
    remove_icon_button:tooltip({"helmod_button.remove"})
    GuiElement.add(secondary_icon_options_container, remove_icon_button)
end

-------------------------------------------------------------------------------
---Update share
---@param event LuaEvent
function BlockEdition:updateShare(event)
    local model, block = self:getParameterObjects()
    if block.parent_id ~= model.id then
        return
    end
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
        
        if event.action == "change-group" then
            local block_group = event.element.text
            model.group = block_group or ""
            Controller:send("on_gui_refresh", event)
        end
        
        if event.action == "change-primary-icon" then
            local element_type = event.element.elem_type
            local element_value = event.element.elem_value
            if element_value ~= nil then
                local block_infos = Model.getBlockInfos(block)
                block_infos.primary_icon = {type=element_type, name=element_value, quality=element_value.quality}
                Controller:send("on_gui_recipe_update", event)
            end
        end

        if event.action == "remove-primary-icon" then
            local block_infos = Model.getBlockInfos(block)
            block_infos.primary_icon = nil
            Controller:send("on_gui_refresh", event)
        end

        if event.action == "switch-icons" then
            local block_infos = Model.getBlockInfos(block)
            -- Store the current primary and secondary icons in memory.
            -- If we overwrite the icons without storing them first,
            -- we lose the original icon before we can switch them.
            local primary_icon = block_infos.primary_icon
            local secondary_icon = block_infos.secondary_icon
            -- Swap the primary and secondary icons.
            block_infos.primary_icon = secondary_icon
            block_infos.secondary_icon = primary_icon
            Controller:send("on_gui_refresh", event)
        end

        if event.action == "change-secondary-icon" then
            local element_type = event.element.elem_type
            local element_value = event.element.elem_value
            if element_value ~= nil then
                local block_infos = Model.getBlockInfos(block)
                block_infos.secondary_icon = {type=element_type, name=element_value, quality=element_value.quality}
                Controller:send("on_gui_recipe_update", event)
            end
        end

        if event.action == "remove-secondary-icon" then
            local block_infos = Model.getBlockInfos(block)
            block_infos.secondary_icon = nil
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
