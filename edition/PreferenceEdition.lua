-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class PreferenceEdition
PreferenceEdition = newclass(Form)

-------------------------------------------------------------------------------
---On initialization
function PreferenceEdition:onInit()
    self.panelCaption = ({ "helmod_preferences-edition-panel.title" })
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function PreferenceEdition:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = math.max(height_main, 800),
        maximal_height = math.max(height_main, 800),
    }
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function PreferenceEdition:onBind()
    Dispatcher:bind("on_gui_preference", self, self.updateFluidsLogistic)
    Dispatcher:bind("on_gui_preference", self, self.updateItemsLogistic)
    Dispatcher:bind("on_gui_preference", self, self.updatePriorityModule)
    Dispatcher:bind("on_gui_preference", self, self.updateUI)
end

-------------------------------------------------------------------------------
---On scroll width
---@return number
function PreferenceEdition:getSrollWidth()
    local number_column = User.getPreferenceSetting("preference_number_column")
    return 38 * (number_column or 6) + 20
end

-------------------------------------------------------------------------------
---On scroll height
---@return number
function PreferenceEdition:getSrollHeight()
    local number_line = User.getPreferenceSetting("preference_number_line")
    return 38 * (number_line or 3) + 4
end

-------------------------------------------------------------------------------
---Get or create preference panel
---@return LuaGuiElement
function PreferenceEdition:getPrefrencePanel()
    local panel = self:getFrameTabbedPanel("preference_panel")
    panel.style.minimal_width = 600
    panel.style.horizontally_stretchable = true
    panel.style.vertically_stretchable = true
    return panel
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement
function PreferenceEdition:getTabPane()
    local content_panel = self:getPrefrencePanel()
    local panel_name = "tab_panel"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[panel_name]
    end
    local panel = GuiElement.add(content_panel, GuiTabPane(panel_name):style(defines.styles.frame.tabbed_pane))
    return panel
end

-------------------------------------------------------------------------------
---Set active tab panel
---@param tab_name string
function PreferenceEdition:setActiveTab(tab_name)
    local content_panel = self:getTabPane()
    for index, tab in pairs(content_panel.tabs) do
        if string.find(tab.content.name, tab_name) then
            content_panel.selected_tab_index = index
        end
    end
end

-------------------------------------------------------------------------------
---Get or create general tab panel
---@return LuaGuiElement
function PreferenceEdition:getGeneralTab()
    local content_panel = self:getTabPane()
    local panel_name = "general_tab_panel"
    local scroll_name = "general_scroll"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({ "helmod_label.general" }))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(defines.styles.frame.tab_scroll_pane))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create UI tab panel
---@return LuaGuiElement
function PreferenceEdition:getUITab()
    local content_panel = self:getTabPane()
    local panel_name = "ui_tab_panel"
    local scroll_name = "ui_scroll"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({ "helmod_label.ui" }))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(defines.styles.frame.tab_scroll_pane))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create priority module tab panel
---@return LuaGuiElement
function PreferenceEdition:getPriorityModuleTab()
    local content_panel = self:getTabPane()
    local panel_name = "priority_module_tab_panel"
    local scroll_name = "priority_module_scroll"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({ "helmod_label.priority-modules" }))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(defines.styles.frame.tab_scroll_pane))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create solid container tab panel
---@return LuaGuiElement
function PreferenceEdition:getSolidContainerTab()
    local content_panel = self:getTabPane()
    local panel_name = "solid_container_tab_panel"
    local scroll_name = "solid_container_scroll"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({ "helmod_preferences-edition-panel.items-logistic-default" }))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(defines.styles.frame.tab_scroll_pane))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create fluid container tab panel
---@return LuaGuiElement
function PreferenceEdition:getFluidContainerTab()
    local content_panel = self:getTabPane()
    local panel_name = "fluid_container_tab_panel"
    local scroll_name = "fluid_container_scroll"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({ "helmod_preferences-edition-panel.fluids-logistic-default" }))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(defines.styles.frame.tab_scroll_pane))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create thumbnail color tab panel
---@return LuaGuiElement
function PreferenceEdition:getThumbnailColorTab()
    local content_panel = self:getTabPane()
    local panel_name = "thumbnail_color_tab_panel"
    local scroll_name = "thumbnail_color_scroll"
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption({"helmod_preferences-edition-panel.thumbnail-color"}))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style(defines.styles.frame.tab_scroll_pane))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function PreferenceEdition:onUpdate(event)
    self:updateGeneral(event)
    self:updateUI(event)
    self:updatePriorityModule(event)
    self:updateItemsLogistic(event)
    self:updateFluidsLogistic(event)
    self:updateThumbnailColor(event)
    if event.action == "OPEN" then
        self:setActiveTab(event.item1)
    end
end

-------------------------------------------------------------------------------
---Update ui
---@param event LuaEvent
function PreferenceEdition:updateUI(event)
    local container_panel = self:getUITab()
    container_panel.clear()
    container_panel.style.padding = 5

    GuiElement.add(container_panel, GuiLabel("fluid_container_label"):caption({ "helmod_label.ui" }):style("helmod_label_title_frame"))

    local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
    options_table.vertical_centering = false
    options_table.style.horizontal_spacing = 10
    options_table.style.vertical_spacing = 5

    for preference_type, preference in pairs(defines.constant.preferences) do
        if preference.group == "ui" then
            GuiElement.add(options_table, GuiLabel(self.classname, "label", preference_type):caption(preference.localised_name):tooltip(preference.localised_description))
            local default_preference_type = User.getPreferenceSetting(preference_type)
            if preference.allowed_values then
                GuiElement.add(options_table, GuiDropDown(self.classname, "preference-setting", preference_type):items(preference.allowed_values, default_preference_type))
            else
                if preference.type == "bool-setting" then
                    GuiElement.add(options_table, GuiCheckBox(self.classname, "preference-setting", preference_type):state(default_preference_type))
                end
                if preference.type == "int-setting" or preference.type == "string-setting" then
                    local tooltip = nil
                    if preference.minimum_value then
                        tooltip = { "", { "helmod_pref_settings.range-value" }, "[", preference.minimum_value, ",", preference.maximum_value, "]" }
                    end
                    GuiElement.add(options_table, GuiTextField(self.classname, "preference-setting", preference_type):text(default_preference_type) :tooltip(tooltip))
                end
            end
            if preference.items ~= nil then
                for preference_name, checked in pairs(preference.items) do
                    local view = Controller:getView(preference_name)
                    if view ~= nil then
                        local localised_name = view.panelCaption
                        local default_preference_name = User.getPreferenceSetting(preference_type, preference_name)
                        GuiElement.add(options_table, GuiLabel(self.classname, "label", preference_type, preference_name):caption({ "", "\t\t\t\t", helmod_tag.color.gold, localised_name, helmod_tag.color.close }))
                        local checkbox = GuiElement.add(options_table, GuiCheckBox(self.classname, "preference-setting", preference_type, preference_name):state( default_preference_name))
                        if default_preference_type ~= true then
                            checkbox.enabled = false
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update general
---@param event LuaEvent
function PreferenceEdition:updateGeneral(event)
    local container_panel = self:getGeneralTab()
    container_panel.clear()
    container_panel.style.padding = 5

    GuiElement.add(container_panel, GuiLabel("fluid_container_label"):caption({ "helmod_label.general" }):style("helmod_label_title_frame"))

    local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
    options_table.vertical_centering = false
    options_table.style.horizontal_spacing = 10
    options_table.style.vertical_spacing = 5

    for preference_name, preference in pairs(defines.constant.preferences) do
        if preference.group == "general" then
            GuiElement.add(options_table, GuiLabel(self.classname, "label", preference_name):caption(preference.localised_name):tooltip(preference.localised_description))
            local default_preference = User.getPreferenceSetting(preference_name)
            if preference.allowed_values then
                GuiElement.add(options_table,  GuiDropDown(self.classname, "preference-setting", preference_name):items(preference.allowed_values, default_preference))
            else
                if preference.type == "bool-setting" then
                    GuiElement.add(options_table, GuiCheckBox(self.classname, "preference-setting", preference_name):state(default_preference))
                end
                if preference.type == "int-setting" or preference.type == "float-setting" or preference.type == "string-setting" then
                    GuiElement.add(options_table, GuiTextField(self.classname, "preference-setting", preference_name):text(default_preference))
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update priority module
---@param event LuaEvent
function PreferenceEdition:updatePriorityModule(event)
    local number_column = User.getPreferenceSetting("preference_number_column")
    local priority_module_panel = self:getPriorityModuleTab()
    priority_module_panel.clear()
    priority_module_panel.style.padding = 5

    GuiElement.add(priority_module_panel, GuiLabel("priority_module_label"):caption({ "helmod_label.priority-modules" }):style("helmod_label_title_frame"))

    local configuration_table_panel = GuiElement.add(priority_module_panel, GuiTable("configuration-table"):column(2))
    configuration_table_panel.vertical_centering = false

    local configuration_panel = GuiElement.add(configuration_table_panel, GuiFlowV("configuration"))
    ---configuration select
    local tool_panel = GuiElement.add(configuration_panel, GuiFlowH("tool"))
    tool_panel.style.width = 200
    local conf_table_panel = GuiElement.add(tool_panel, GuiTable("configuration-table"):column(6))
    local configuration_priority = User.getParameter("configuration_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    local button_style = "helmod_button_bold"
    for i, priority_module in pairs(priority_modules) do
        local button_style2 = button_style
        if configuration_priority == i then button_style2 = "helmod_button_bold_selected" end
        GuiElement.add(conf_table_panel, GuiButton(self.classname, "configuration-priority-select", i):caption(i):style(button_style2))
    end
    GuiElement.add(conf_table_panel, GuiButton(self.classname, "configuration-priority-select", "new"):caption("+"):style(button_style))
    GuiElement.add(conf_table_panel, GuiButton(self.classname, "configuration-priority-remove", "new"):caption("-"):style(button_style))
    ---module priority
    local priority_table_panel = GuiElement.add(configuration_panel, GuiTable("module-priority-table"):column(3))
    if priority_modules[configuration_priority] ~= nil then
        for index, element in pairs(priority_modules[configuration_priority]) do
            local tooltip = GuiTooltipModule("tooltip.add-module"):element({ type = "item", name = element.name })
            GuiElement.add(priority_table_panel, GuiButtonSprite(self.classname, "do-nothing", index):sprite("entity", element.name):tooltip(tooltip))
            GuiElement.add(priority_table_panel, GuiTextField(self.classname, "priority-module-update", index):text(element.value))
            GuiElement.add(priority_table_panel, GuiButtonSprite(self.classname, "priority-module-remove", index):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_sm_red"):tooltip(tooltip))
        end
    end

    ---module selector
    local module_scroll = GuiElement.add(configuration_table_panel, GuiScroll("module-selector-scroll"))
    module_scroll.style.maximal_height = self:getSrollHeight()
    module_scroll.style.minimal_width = self:getSrollWidth()
    local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(number_column))
    for k, element in pairs(Player.getModules()) do
        local tooltip = GuiTooltipModule("tooltip.add-module"):element({ type = "item", name = element.name })
        GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "priority-module-select"):sprite("entity", element.name):tooltip( tooltip))
    end
end

-------------------------------------------------------------------------------
---Update items logistic
---@param event LuaEvent
function PreferenceEdition:updateItemsLogistic(event)
    local number_column = User.getPreferenceSetting("preference_number_column")
    local container_panel = self:getSolidContainerTab()
    container_panel.clear()
    container_panel.style.padding = 5

    GuiElement.add(container_panel, GuiLabel("solid_container_label"):caption({ "helmod_preferences-edition-panel.items-logistic-default" }):style("helmod_label_title_frame"))

    local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
    options_table.vertical_centering = false
    options_table.style.horizontal_spacing = 10
    options_table.style.vertical_spacing = 10

    for _, type in pairs({ "inserter", "belt", "container", "transport" }) do
        local type_label = GuiElement.add(options_table, GuiLabel(string.format("%s-label", type)):caption({ string.format("helmod_preferences-edition-panel.items-logistic-%s", type) }))
        type_label.style.width = 200

        local scroll_panel = GuiElement.add(options_table, GuiScroll(string.format("%s-selector-scroll", type)))
        scroll_panel.style.maximal_height = self:getSrollHeight()
        scroll_panel.style.minimal_width = self:getSrollWidth()

        local type_table_panel = GuiElement.add(scroll_panel,
            GuiTable(string.format("%s-selector-table", type)):column(number_column))
        local item_logistic = Player.getDefaultItemLogistic(type)
        for key, entity in pairs(Player.getItemsLogistic(type)) do
            local color = nil
            if entity.name == item_logistic then color = "green" end
            local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "items-logistic-select", type):choose("entity", entity.name):color(color))
            button.locked = true
        end
    end
end

-------------------------------------------------------------------------------
---Update fluids logistic
---@param event LuaEvent
function PreferenceEdition:updateFluidsLogistic(event)
    local number_column = User.getPreferenceSetting("preference_number_column")
    local container_panel = self:getFluidContainerTab()
    container_panel.clear()
    container_panel.style.padding = 5

    GuiElement.add(container_panel, GuiLabel("fluid_container_label"):caption({ "helmod_preferences-edition-panel.fluids-logistic-default" }):style("helmod_label_title_frame"))

    local options_table = GuiElement.add(container_panel, GuiTable("options-table"):column(2))
    options_table.vertical_centering = false
    options_table.style.horizontal_spacing = 10
    options_table.style.vertical_spacing = 10

    local type_label = GuiElement.add(options_table, GuiLabel("maximum-flow"):caption({ "helmod_preferences-edition-panel.fluids-logistic-maximum-flow" }))
    type_label.style.width = 200
    local fluids_logistic_maximum_flow = User.getParameter("fluids_logistic_maximum_flow")
    local default_flow = nil
    local items = {}
    for _, element in pairs(defines.constant.logistic_flow) do
        local flow = { "helmod_preferences-edition-panel.fluids-logistic-flow", element.pipe, element.flow }
        table.insert(items, flow)
        if fluids_logistic_maximum_flow ~= nil and fluids_logistic_maximum_flow == element.flow or element.flow == defines.constant.logistic_flow_default then
            default_flow = flow
        end
    end
    GuiElement.add(options_table, GuiDropDown(self.classname, "fluids-logistic-flow"):items(items, default_flow))

    for _, type in pairs({ "pipe", "container", "transport" }) do
        local type_label = GuiElement.add(options_table, GuiLabel(string.format("%s-label", type)):caption({string.format("helmod_preferences-edition-panel.fluids-logistic-%s", type) }))
        type_label.style.width = 200

        local scroll_panel = GuiElement.add(options_table, GuiScroll(string.format("%s-selector-scroll", type)))
        scroll_panel.style.maximal_height = self:getSrollHeight()
        scroll_panel.style.minimal_width = self:getSrollWidth()
        local type_table_panel = GuiElement.add(scroll_panel,
            GuiTable(string.format("%s-selector-table", type)):column(number_column))
        local fluid_logistic = Player.getDefaultFluidLogistic(type)
        for key, entity in pairs(Player.getFluidsLogistic(type)) do
            local color = nil
            if entity.name == fluid_logistic then color = "green" end
            local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "fluids-logistic-select", type):choose("entity", entity.name):color(color))
            button.locked = true
        end
    end
end

-------------------------------------------------------------------------------
---Update Thumbnail Cell
---@param stack_panel LuaGuiElement
---@param label string
---@param parameter string
---@param fake_element table
function PreferenceEdition:updateThumbnailCell(stack_panel, label, parameter, fake_element)
    local cell_panel = GuiElement.add(stack_panel, GuiFlowV(parameter))
    local localized_label = {"helmod_preferences-edition-panel.thumbnail-color-"..label}
    GuiElement.add(cell_panel, GuiLabel("cell_label"):caption(localized_label):style(defines.styles.label.default))
    local color_change_confirm = User.getParameter("color_change_confirm")
    local thumbnails_color = User.getThumbnailsColor()
    local thumbnail_color = thumbnails_color[parameter]
    if color_change_confirm == parameter then

        local menu_panel = GuiElement.add(cell_panel, GuiFrameH("menu"):style(defines.styles.frame.inside_deep))
        menu_panel.style.width = 215
        menu_panel.style.margin = 5
        --menu_panel.style.padding = 3
        local menu_panel_right = GuiElement.add(menu_panel, GuiFlowH("menu-right"))
        menu_panel_right.style.horizontally_stretchable = true
        local menu_panel_left = GuiElement.add(menu_panel, GuiFlowH("menu-left"))
        GuiElement.add(menu_panel_right, GuiButton(self.classname, "thumbnail-cancel", parameter):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_sm_actived_red"):tooltip({ "helmod_preferences-edition-panel.thumbnail-color-modify-cancel" }))
        GuiElement.add(menu_panel_left, GuiButton(self.classname, "thumbnail-default", parameter):sprite("menu", defines.sprites.refresh.black, defines.sprites.refresh.black):style("helmod_button_menu_sm_actived_red"):tooltip({ "helmod_preferences-edition-panel.thumbnail-color-modify-default" }))

        local last_element = nil
        local options_scroll = GuiElement.add(cell_panel, GuiScroll("options-scroll"))
        options_scroll.style.margin = 5
        --options_scroll.style.padding = 3
        options_scroll.style.width = 215
        options_scroll.style.height = 215

        local options_color = GuiElement.add(options_scroll, GuiTable("options-table"):column(10))
        options_color.style.horizontally_stretchable = false
        for code, frame_color in pairs(defines.frame_colors) do
            for _, value in ipairs(frame_color) do
                local button = nil
                if value == thumbnail_color then
                    button = GuiElement.add(options_color, GuiButtonSelectSpriteSm(self.classname, "thumbnail-select", parameter, value):tooltip(value))
                    last_element = button
                else
                    button = GuiElement.add(options_color, GuiButtonSpriteSm(self.classname, "thumbnail-select", parameter, value):tooltip(value))
                end
                local frame = GuiElement.add(button, GuiFrame("color"):style("helmod_frame_element_w30", value, 1))
                frame.style.width = 14
                frame.style.height = 14
                frame.ignored_by_interaction = true
                button.style.padding = { 2, 0, 2, 2 }
            end
        end
        if last_element ~= nil then
            options_scroll.scroll_to_element(last_element)
        end
    else
        local thumbnail = GuiElement.add(cell_panel, GuiCellThumbnail(self.classname, "thumbnail-change", parameter):element(fake_element):color(thumbnail_color):tooltip(thumbnail_color))
        thumbnail.style.horizontally_stretchable = false
    end
end

-------------------------------------------------------------------------------
---Update frame color
---@param event LuaEvent
function PreferenceEdition:updateThumbnailColor(event)
    local container_panel = self:getThumbnailColorTab()
    container_panel.clear()
    container_panel.style.padding = 5

    local menu_panel = GuiElement.add(container_panel, GuiFrameH("menu"):style(defines.styles.frame.inside_deep))
    menu_panel.style.horizontally_stretchable = true
    menu_panel.style.horizontal_align = "left"
    menu_panel.style.margin = 5
    menu_panel.style.padding = 3
    local menu_panel_right = GuiElement.add(menu_panel, GuiFlowH("menu-right"))
    menu_panel_right.style.horizontally_stretchable = true
    local menu_panel_left = GuiElement.add(menu_panel, GuiFlowH("menu-left"))
    local button = GuiElement.add(menu_panel_left, GuiButton(self.classname, "thumbnail-default", "all"):sprite("menu", defines.sprites.refresh.black, defines.sprites.refresh.black):style("helmod_button_menu_sm_actived_red"):tooltip({ "helmod_preferences-edition-panel.thumbnail-color-modify-all-default" }))

    local blocks_panel = GuiElement.add(container_panel, GuiFrameV("blocks"):caption({"helmod_common.blocks"}):style(defines.styles.frame.bordered))
    blocks_panel.style.horizontally_stretchable = true
    local blocks_stack = GuiElement.add(blocks_panel, GuiFlowH("stack"))
    local fake_block = { name = "block1", sprite1 = defines.sprites.hangar.white, sprite2 = defines.sprites.hangar.white }

    self:updateThumbnailCell(blocks_stack, "default", "block_default", fake_block)
    self:updateThumbnailCell(blocks_stack, "selected", "block_selected", fake_block)
    self:updateThumbnailCell(blocks_stack, "reverted", "block_reverted", fake_block)
    
    local recipes_panel = GuiElement.add(container_panel, GuiFrameV("recipes"):caption({"helmod_common.recipes"}):style(defines.styles.frame.bordered))
    recipes_panel.style.horizontally_stretchable = true
    local recipes_stack = GuiElement.add(recipes_panel, GuiFlowH("stack"))
    local fake_recipe = { name = "recipe1", sprite1 = defines.sprites.script.white, sprite2 = defines.sprites.script.white }

    self:updateThumbnailCell(recipes_stack, "default", "recipe_default", fake_recipe)


    local products_panel = GuiElement.add(container_panel, GuiFrameV("products"):caption({"helmod_common.products"}):style(defines.styles.frame.bordered))
    products_panel.style.horizontally_stretchable = true
    local products_stack = GuiElement.add(products_panel, GuiFlowH("stack"))
    local fake_product = { name = "product1", sprite1 = defines.sprites.jewel.white, sprite2 = defines.sprites.jewel.white }

    self:updateThumbnailCell(products_stack, "default", "product_default", fake_product)
    self:updateThumbnailCell(products_stack, "driving", "product_driving", fake_product)
    self:updateThumbnailCell(products_stack, "overflow", "product_overflow", fake_product)

    local ingredients_panel = GuiElement.add(container_panel, GuiFrameV("ingredients"):caption({"helmod_common.ingredients"}):style(defines.styles.frame.bordered))
    ingredients_panel.style.horizontally_stretchable = true
    local ingredients_stack = GuiElement.add(ingredients_panel, GuiFlowH("stack"))
    local fake_ingredient = { name = "ingredient1", sprite1 = defines.sprites.jewel.white, sprite2 = defines.sprites.jewel.white }

    self:updateThumbnailCell(ingredients_stack, "default", "ingredient_default", fake_ingredient)
    self:updateThumbnailCell(ingredients_stack, "driving", "ingredient_driving", fake_ingredient)
    self:updateThumbnailCell(ingredients_stack, "overflow", "ingredient_overflow", fake_ingredient)
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function PreferenceEdition:onEvent(event)
    if event.action == "thumbnail-default" then
        local thumbnails_color = User.getThumbnailsColor()
        if event.item1 == "all" then
            thumbnails_color = {}
        else
            thumbnails_color[event.item1] = nil
        end
        User.setThumbnailsColor(thumbnails_color)
        User.setParameter("color_change_confirm", nil)
        self:updateThumbnailColor(event)
        Controller:send("on_gui_refresh", event)
    end

    if event.action == "thumbnail-cancel" then
        User.setParameter("color_change_confirm", nil)
        self:updateThumbnailColor(event)
    end

    if event.action == "thumbnail-change" then
        User.setParameter("color_change_confirm", event.item1)
        self:updateThumbnailColor(event)
    end

    if event.action == "thumbnail-select" then
        local thumbnails_color = User.getThumbnailsColor()
        thumbnails_color[event.item1] = event.item2
        User.setThumbnailsColor(thumbnails_color)
        User.setParameter("color_change_confirm", nil)
        self:updateThumbnailColor(event)
        Controller:send("on_gui_refresh", event)
    end

    if event.action == "preference-setting" then
        local type = event.item1
        local name = event.item2
        if name == "" then
            local preference = defines.constant.preferences[type]
            if preference ~= nil then
                if preference.allowed_values then
                    local index = event.element.selected_index
                    User.setPreference(type, nil, preference.allowed_values[index])
                else
                    if preference.type == "bool-setting" then
                        User.setPreference(type, nil, event.element.state)
                    end
                    if preference.type == "int-setting" or preference.type == "float-setting" then
                        local value = tonumber(event.element.text or preference.default_value)
                        User.setPreference(type, nil, value)
                    end
                    if preference.type == "string-setting" then
                        User.setPreference(type, nil, event.element.text or preference.default_value)
                    end
                end
                Controller:send("on_gui_refresh", event)
                Controller:send("on_gui_preference", event)
            end
        else
            local preference = defines.constant.preferences[type]
            if preference ~= nil then
                User.setPreference(type, name, event.element.state)
            end
            Controller:send("on_gui_refresh", event)
            Controller:send("on_gui_preference", event)
        end
    end

    if event.action == "configuration-priority-select" then
        if event.item1 == "new" then
            local priority_modules = User.getParameter("priority_modules") or {}
            table.insert(priority_modules, {})
            User.setParameter("configuration_priority", table.size(priority_modules))
            User.setParameter("priority_modules", priority_modules)
        else
            User.setParameter("configuration_priority", tonumber(event.item1))
        end
        self:updatePriorityModule(event)
        Controller:send("on_gui_priority_module", event)
    end

    if event.action == "configuration-priority-remove" then
        local priority_modules = User.getParameter("priority_modules") or {}
        local configuration_priority = User.getParameter("configuration_priority")
        table.remove(priority_modules, configuration_priority)
        User.setParameter("configuration_priority", table.size(priority_modules))
        User.setParameter("priority_modules", priority_modules)
        self:updatePriorityModule(event)
        Controller:send("on_gui_priority_module", event)
    end

    if event.action == "priority-module-select" then
        local configuration_priority = User.getParameter("configuration_priority") or 1
        local priority_modules = User.getParameter("priority_modules") or {}
        if table.size(priority_modules) == 0 then
            table.insert(priority_modules, { { name = event.item1, value = 1 } })
            User.setParameter("configuration_priority", 1)
            User.setParameter("priority_modules", priority_modules)
        else
            if priority_modules[configuration_priority] ~= nil then
                table.insert(priority_modules[configuration_priority], { name = event.item1, value = 1 })
            end
        end
        self:updatePriorityModule(event)
        Controller:send("on_gui_priority_module", event)
    end

    if event.action == "priority-module-update" then
        local configuration_priority = User.getParameter("configuration_priority")
        local priority_modules = User.getParameter("priority_modules")
        local priority_index = tonumber(event.item1)
        if priority_modules ~= nil and priority_modules[configuration_priority] ~= nil and priority_modules[configuration_priority][priority_index] ~= nil then
            local text = event.element.text
            priority_modules[configuration_priority][priority_index].value = tonumber(text)
        end
        self:updatePriorityModule(event)
        Controller:send("on_gui_priority_module", event)
    end

    if event.action == "priority-module-remove" then
        local configuration_priority = User.getParameter("configuration_priority")
        local priority_modules = User.getParameter("priority_modules")
        local priority_index = tonumber(event.item1)
        if priority_modules ~= nil and priority_modules[configuration_priority] ~= nil and priority_modules[configuration_priority][priority_index] ~= nil then
            table.remove(priority_modules[configuration_priority], priority_index)
        end
        self:updatePriorityModule(event)
        Controller:send("on_gui_priority_module", event)
    end

    if event.action == "items-logistic-select" then
        User.setParameter(string.format("items_logistic_%s", event.item1), event.item2)
        self:updateItemsLogistic(event)
        Controller:send("on_gui_refresh", event)
    end

    if event.action == "fluids-logistic-select" then
        User.setParameter(string.format("fluids_logistic_%s", event.item1), event.item2)
        self:updateFluidsLogistic(event)
        Controller:send("on_gui_refresh", event)
    end

    if event.action == "fluids-logistic-flow" then
        local index = event.element.selected_index
        local fluids_logistic_maximum_flow = defines.constant.logistic_flow[index].flow
        User.setParameter("fluids_logistic_maximum_flow", fluids_logistic_maximum_flow)
        Controller:send("on_gui_refresh", event)
    end
end
