-------------------------------------------------------------------------------
---Class to build PropertiesPanel panel
---@class PropertiesPanel : Form
PropertiesPanel = newclass(Form, function(base, classname)
    Form.init(base, classname)
    base.add_special_button = true
end)

-------------------------------------------------------------------------------
---On initialization
function PropertiesPanel:onInit()
    self.panelCaption = ({ "helmod_result-panel.tab-button-properties" })
    self.help_button = false
end

-------------------------------------------------------------------------------
---On bind
function PropertiesPanel:onBind()
    Dispatcher:bind("on_gui_refresh", self, self.updateData)
end

-------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function PropertiesPanel:getButtonSprites()
    return defines.sprites.database_schema.white, defines.sprites.database_schema.black
end

-------------------------------------------------------------------------------
---Is visible
---@return boolean
function PropertiesPanel:isVisible()
    return User.getModGlobalSetting("hidden_panels")
end

-------------------------------------------------------------------------------
---Is special
---@return boolean
function PropertiesPanel:isSpecial()
    return true
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement
function PropertiesPanel:getTabPane()
    local content_panel = self:getFrameDeepPanel("panel")
    local panel_name = "tab_panel"
    local name = table.concat({ self.classname, "change-tab", panel_name }, "=")
    if content_panel[name] ~= nil and content_panel[name].valid then
        return content_panel[name]
    end
    local panel = GuiElement.add(content_panel, GuiTabPane(self.classname, "change-tab", panel_name))
    return panel
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@param panel_name string
---@param caption string
---@return LuaGuiElement
function PropertiesPanel:getTab(panel_name, caption)
    local content_panel = self:getTabPane()
    local scroll_name = "scroll-" .. panel_name
    if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
        return content_panel[scroll_name]
    end
    local tab_panel = GuiElement.add(content_panel, GuiTab(panel_name):caption(caption))
    local scroll_panel = GuiElement.add(content_panel, GuiScroll(scroll_name):style("helmod_scroll_pane"):policy(true))
    content_panel.add_tab(tab_panel, scroll_panel)
    scroll_panel.style.horizontally_stretchable = true
    scroll_panel.style.vertically_stretchable = true
    return scroll_panel
end

-------------------------------------------------------------------------------
---Get or create conversion tab panel
---@return LuaGuiElement
function PropertiesPanel:getPropertiesTab()
    return self:getTab("properties-tab-panel", "Properties")
end

-------------------------------------------------------------------------------
---Get or create conversion tab panel
---@return LuaGuiElement
function PropertiesPanel:getRuntimeApiTab()
    return self:getTab("runtime-api-tab-panel", "Runtime API")
end

-------------------------------------------------------------------------------
---Get or create menu panel
---@return LuaGuiElement
function PropertiesPanel:getMenuPanel(scroll_panel)
    local panel_name = "menu-panel"
    if scroll_panel[panel_name] ~= nil and scroll_panel[panel_name].valid then
        return scroll_panel[panel_name]
    end
    local panel = GuiElement.add(scroll_panel, GuiFrameH(panel_name))
    panel.style.horizontally_stretchable = true
    --panel.style.vertically_stretchable = true
    return panel
end

-------------------------------------------------------------------------------
---Get or create header panel
---@return LuaGuiElement
function PropertiesPanel:getHeaderPanel(scroll_panel)
    local panel_name = "header-panel"
    if scroll_panel[panel_name] ~= nil and scroll_panel[panel_name].valid then
        return scroll_panel[panel_name]
    end
    local panel = GuiElement.add(scroll_panel, GuiFrameV(panel_name))
    panel.style.horizontally_stretchable = true
    --panel.style.vertically_stretchable = true
    return panel
end

-------------------------------------------------------------------------------
---Get or create content panel
---@return LuaGuiElement
function PropertiesPanel:getContentPanel(scroll_panel)
    local panel_name = "content"
    local scroll_name = "data-panel"
    if scroll_panel[panel_name] ~= nil and scroll_panel[panel_name].valid then
        return scroll_panel[panel_name][scroll_name]
    end
    local panel = GuiElement.add(scroll_panel, GuiFrameV(panel_name))
    panel.style.horizontally_stretchable = true
    panel.style.vertically_stretchable = true
    local scroll_panel2 = GuiElement.add(panel, GuiScroll(scroll_name))
    scroll_panel2.style.horizontally_stretchable = true
    scroll_panel2.style.vertically_stretchable = true
    return scroll_panel2
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function PropertiesPanel:onEvent(event)
    if event.action == "element-delete" then
        local prototype_compare = User.getParameter("prototype_compare") or {}
        local index = nil
        for i, prototype in pairs(prototype_compare) do
            if prototype.name == event.item1 then
                index = i
            end
        end
        if index ~= nil then
            table.remove(prototype_compare, index)
        end
        User.setParameter("prototype_compare", prototype_compare)
        self:updateData(event)
    end

    if event.action == "filter-nil-property-switch" then
        local switch_nil = event.element.switch_state == "right"
        User.setParameter("filter-nil-property", switch_nil)
        self:updateData(event)
    end

    if event.action == "filter-difference-property-switch" then
        local switch_nil = event.element.switch_state == "right"
        User.setParameter("filter-difference-property", switch_nil)
        self:updateData(event)
    end

    if event.action == "technology-search" then
        local state = event.element.state
        Player.getForce().technologies[event.item1].researched = state
        self:updateData(event)
    end

    if event.action == "filter-property" then
        local filter = event.element.text
        User.setParameter("filter-property", filter)
        self:updateData(event)
    end

    if event.action == "import-runtime-api" then
        local element = event.element
        local textbox = element.parent["json_string"]
        local json_string = textbox.text
        local api = helpers.json_to_table(json_string)
        if api ~= nil then
            Cache.setData(self.classname, "runtime_api", api)
        end
        self:updateData(event)
    end
end

-------------------------------------------------------------------------------
---Update data
---@param event LuaEvent
function PropertiesPanel:onUpdate(event)
    local flow_panel, content_panel, menu_panel = self:getPanel()
    local display_width, display_height, scale = User.getMainSizes()
    local width_main = display_width / scale
    local height_main = display_height / scale
    flow_panel.style.height = height_main
    flow_panel.style.width = width_main


    self:updateProperties(event)
    self:updateRuntimeApi(event)
end

-------------------------------------------------------------------------------
---Update menu
---@param event LuaEvent
function PropertiesPanel:updateRuntimeApi(event)
    local scroll_panel = self:getRuntimeApiTab()
    scroll_panel.clear()

    
    local json_table = GuiElement.add(scroll_panel, GuiTable("table-resources"):column(3))
    json_table.style.cell_padding = 5
    
    GuiElement.add(json_table, GuiLabel("json_label"):caption("URL to find Runtime API"))
    local json_url = GuiElement.add(json_table, GuiTextField("json_url"):text("https://lua-api.factorio.com/latest/runtime-api.json"))
    json_url.style.width = 600
    GuiElement.add(json_table, GuiFlow())

    GuiElement.add(json_table, GuiLabel("json_string_label"):caption("Json String"))
    local json_string = GuiElement.add(json_table, GuiTextField("json_string"))
    json_string.style.width = 600

    GuiElement.add(json_table, GuiButton(self.classname, "import-runtime-api"):caption("Import Runtime API"))
end

-------------------------------------------------------------------------------
---Update menu
---@param event LuaEvent
function PropertiesPanel:updateProperties(event)
    local scroll_panel = self:getPropertiesTab()
    self:updateMenu(event)
    self:updateHeader(event)
    self:updateData(event)
end

-------------------------------------------------------------------------------
---Update menu
---@param event LuaEvent
function PropertiesPanel:updateMenu(event)
    local runtime_api = Cache.getData(self.classname, "runtime_api")
    if runtime_api == nil then
        return
    end
    local scroll_panel = self:getPropertiesTab()
    local action_panel = self:getMenuPanel(scroll_panel)
    action_panel.clear()
    GuiElement.add(action_panel, GuiButton("HMEntitySelector", "OPEN", "HMPropertiesPanel"):caption({ "helmod_result-panel.select-button-entity" }))
    GuiElement.add(action_panel, GuiButton("HMItemSelector", "OPEN", "HMPropertiesPanel"):caption({ "helmod_result-panel.select-button-item" }))
    GuiElement.add(action_panel, GuiButton("HMFluidSelector", "OPEN", "HMPropertiesPanel"):caption({ "helmod_result-panel.select-button-fluid" }))
    GuiElement.add(action_panel, GuiButton("HMRecipeSelector", "OPEN", "HMPropertiesPanel"):caption({ "helmod_result-panel.select-button-recipe" }))
    GuiElement.add(action_panel, GuiButton("HMTechnologySelector", "OPEN", "HMPropertiesPanel"):caption({"helmod_result-panel.select-button-technology" }))
    GuiElement.add(action_panel, GuiButton("HMTileSelector", "OPEN", "HMPropertiesPanel"):caption({ "helmod_result-panel.select-button-tile" }))
end

-------------------------------------------------------------------------------
---Update data
---@param event LuaEvent
function PropertiesPanel:updateData(event)
    if not (self:isOpened()) then return end
    local runtime_api = Cache.getData(self.classname, "runtime_api")
    if runtime_api == nil then
        return
    end
    local scroll_panel = self:getPropertiesTab()
    ---data
    local content_panel = self:getContentPanel(scroll_panel)
    content_panel.clear()

    local runtime_api = Cache.getData(self.classname, "runtime_api")
    if runtime_api == nil then
        return
    end
    ---data
    local filter = User.getParameter("filter-property")
    local prototype_compare = User.getParameter("prototype_compare")
    if prototype_compare ~= nil then
        local data = {}
        for _, prototype in pairs(prototype_compare) do
            local data_prototype = self:getPrototypeData(prototype)
            local key = string.format("%s_%s", prototype.type, prototype.name)
            for _, properties in pairs(data_prototype) do
                if data[properties.name] == nil then data[properties.name] = {} end
                data[properties.name][key] = properties
            end
        end
        local result_table = GuiElement.add(content_panel, GuiTable("table-resources"):column(#prototype_compare + 1):style("helmod_table-rule-odd"))

        self:addTableHeader(result_table, prototype_compare)

        for property, values in pairs(data) do
            if filter == nil or filter == "" or string.find(property, filter, 0, true) then
                if not (User.getParameter("filter-nil-property") == true and self:isNilLine(values, prototype_compare)) then
                    if not (User.getParameter("filter-difference-property") == true and self:isSameLine(values, prototype_compare)) then
                        local cell_name = GuiElement.add(result_table, GuiFrameH("property", property):style(helmod_frame_style.hidden))
                        GuiElement.add(cell_name, GuiLabel("label"):caption(property))

                        for index, prototype in pairs(prototype_compare) do
                            ---col value
                            local cell_value = GuiElement.add(result_table, GuiFrameH(property, prototype.name, index):style(helmod_frame_style.hidden))
                            local key = string.format("%s_%s", prototype.type, prototype.name)
                            if values[key] ~= nil then
                                local chmod = values[key].chmod
                                local value = self:tableToString(values[key].value)
                                --GuiElement.add(cell_value, GuiLabel("prototype_chmod"):caption(string.format("[%s]:", chmod)))
                                local label_value = GuiElement.add(cell_value, GuiLabel("prototype_value"):caption(value):style("helmod_label_max_600"))
                                label_value.style.width = 400
                            end
                        end
                    end
                end
            end
        end
    end
end

-------------------------------------------------------------------------------
---Add cell header
---@param guiTable LuaGuiElement
---@param name string
---@param caption string
---@param sorted any
function PropertiesPanel:addCellHeader(guiTable, name, caption, sorted)
    if (name ~= "index" and name ~= "id" and name ~= "name" and name ~= "type") or User.getModGlobalSetting("display_data_col_" .. name) then
        local cell = GuiElement.add(guiTable, GuiFrameH("header", name):style(helmod_frame_style.hidden))
        GuiElement.add(cell, GuiLabel("label"):caption(caption))
    end
end

-------------------------------------------------------------------------------
---Add table header
---@param itable LuaGuiElement
---@param prototype_compare table
function PropertiesPanel:addTableHeader(itable, prototype_compare)
    self:addCellHeader(itable, "property", { "helmod_result-panel.col-header-name" })
    for index, prototype in pairs(prototype_compare) do
        local icon_type = nil
        local localised_name = nil
        if prototype.type == "entity" then
            local entity_prototype = EntityPrototype(prototype)
            icon_type = "entity"
            localised_name = entity_prototype:getLocalisedName()
        elseif prototype.type == "item" then
            local item_prototype = ItemPrototype(prototype)
            icon_type = "item"
            localised_name = item_prototype:getLocalisedName()
        elseif prototype.type == "fluid" then
            local fluid_prototype = FluidPrototype(prototype)
            icon_type = "fluid"
            localised_name = fluid_prototype:getLocalisedName()
        elseif string.find(prototype.type, "recipe") then
            local recipe_prototype = RecipePrototype(prototype)
            icon_type = recipe_prototype:getType()
            localised_name = recipe_prototype:getLocalisedName()
        elseif prototype.type == "technology" then
            local technology_prototype = Technology(prototype)
            icon_type = "technology"
            localised_name = technology_prototype:getLocalisedName()
        elseif prototype.type == "tile" then
            local tile_prototype = TilePrototype(prototype)
            icon_type = "tile"
            localised_name = tile_prototype:getLocalisedName()
        end
        local cell_header = GuiElement.add(itable, GuiFlowH("header", prototype.name, index))
        GuiElement.add(cell_header,
            GuiButtonSprite(self.classname, "element-delete", prototype.name, index):sprite(icon_type, prototype.name)
            :tooltip(localised_name))
        if prototype.type == "technology" then
            GuiElement.add(cell_header,
                GuiCheckBox(self.classname, "technology-search", prototype.name, index):state(Technology(prototype)
                :isResearched()):tooltip("isResearched"))
        end
    end

    self:addCellHeader(itable, "property_type", "Element Type")
    for index, prototype in pairs(prototype_compare) do
        GuiElement.add(itable, GuiLabel("element_type", prototype.name, index):caption(prototype.type))
    end

    self:addCellHeader(itable, "property_name", "Element Name")
    for index, prototype in pairs(prototype_compare) do
        local textfield = GuiElement.add(itable, GuiTextField("element_name", prototype.name, index):text(prototype.name))
        textfield.style.width = 300
    end
end

-------------------------------------------------------------------------------
---Update header
---@param event LuaEvent
function PropertiesPanel:updateHeader(event)
    local scroll_panel = self:getPropertiesTab()
    local info_panel = self:getHeaderPanel(scroll_panel)
    info_panel.clear()
    local options_table = GuiElement.add(info_panel, GuiTable("options-table"):column(2))
    
    local runtime_api = Cache.getData(self.classname, "runtime_api")
    if runtime_api == nil then
        GuiElement.add(options_table, GuiLabel("runtime_api"):caption("Runtime API not imported, use Runtime API Tab!"))
        return
    else
        GuiElement.add(options_table, GuiLabel("runtime_api"):caption("Runtime API:"))
        GuiElement.add(options_table, GuiLabel("runtime_api_version"):caption(runtime_api["application_version"]))
    end
    ---nil values
    local switch_nil = "left"
    if User.getParameter("filter-nil-property") == true then
        switch_nil = "right"
    end
    GuiElement.add(options_table, GuiLabel("filter-nil-property"):caption("Hide nil values:"))
    local filter_switch = GuiElement.add(options_table, GuiSwitch(self.classname, "filter-nil-property-switch"):state(switch_nil):leftLabel("Off"):rightLabel("On"))
    ---difference values
    local switch_nil = "left"
    if User.getParameter("filter-difference-property") == true then
        switch_nil = "right"
    end
    GuiElement.add(options_table, GuiLabel("filter-difference-property"):caption("Show differences:"))
    local filter_switch = GuiElement.add(options_table,
        GuiSwitch(self.classname, "filter-difference-property-switch"):state(switch_nil):leftLabel("Off"):rightLabel(
        "On"))

    GuiElement.add(options_table, GuiLabel("filter-property-label"):caption("Filter:"))
    local filter_value = User.getParameter("filter-property")
    local filter_field = GuiElement.add(options_table,
        GuiTextField(self.classname, "filter-property", "onchange"):text(filter_value))
    filter_field.style.width = 300
end

---Return attributes of classe
---@param object_name any
---@return unknown
function PropertiesPanel:getClasseAttributes(object_name)
    local runtime_api = Cache.getData(self.classname, "runtime_api")
    for _, value in pairs(runtime_api["classes"]) do
        if value.name == object_name then
            return value.attributes
        end
    end
    return {}
end

-------------------------------------------------------------------------------
---Table to string
---@param value table
function PropertiesPanel:tableToString(value)
    if type(value) == "table" then
        local key2, _ = next(value)
        if type(key2) ~= "number" then
            local message = "{\n"
            local first = true
            for key, content in pairs(value) do
                local mask = "%s%s%s=%s%s"
                if not (first) then
                    message = message .. ",\n"
                end
                if type(content) == "table" then
                    message = string.format(mask, message, helmod_tag.color.orange, key, helmod_tag.color.close,
                        string.match(serpent.dump(content), "do local _=(.*);return _;end"))
                else
                    message = string.format(mask, message, helmod_tag.color.orange, key, helmod_tag.color.close, content)
                end
                first = false
            end
            value = message .. "\n}"
        else
            local message = "{"
            local first = true
            for key, content in pairs(value) do
                if not (first) then
                    message = message .. ","
                end
                message = message .. tostring(self:tableToString(content))
                first = false
            end
            value = message .. "}"
        end
    end
    return value
end

-------------------------------------------------------------------------------
---Is nil line
---@param values table
---@param prototype_compare any
---@return boolean
function PropertiesPanel:isNilLine(values, prototype_compare)
    local is_nil = true
    for index, prototype in pairs(prototype_compare) do
        local key = string.format("%s_%s", prototype.type, prototype.name)
        if values[key] ~= nil and values[key].value ~= "nil" then is_nil = false end
    end
    return is_nil
end

-------------------------------------------------------------------------------
---Is same line
---@param values table
---@param prototype_compare any
---@return boolean
function PropertiesPanel:isSameLine(values, prototype_compare)
    local is_same = true
    local compare = nil
    for index, prototype in pairs(prototype_compare) do
        local key = string.format("%s_%s", prototype.type, prototype.name)
        if values[key] ~= nil then
            if compare == nil then
                compare = values[key].value
            else
                if values[key].value ~= compare then is_same = false end
            end
        end
    end
    return is_same
end

-------------------------------------------------------------------------------
---Get prototype data
---@param prototype table
function PropertiesPanel:getPrototypeData(prototype)
    ---data
    if prototype ~= nil then
        local lua_prototype = nil
        if prototype.type == "entity" then
            lua_prototype = EntityPrototype(prototype):native()
        elseif prototype.type == "item" then
            lua_prototype = ItemPrototype(prototype):native()
        elseif prototype.type == "fluid" then
            lua_prototype = FluidPrototype(prototype):native()
        elseif string.find(prototype.type, "recipe") then
            lua_prototype = RecipePrototype(prototype):native()
        elseif prototype.type == "technology" then
            lua_prototype = Technology(prototype):native()
        elseif prototype.type == "tile" then
            lua_prototype = TilePrototype(prototype):native()
        end
        if lua_prototype ~= nil then
            local properties = self:parseProperties(lua_prototype, 0)
            local data_properties = {}
            for key, value in pairs(properties) do
                table.insert(data_properties, { name = key, value = value })
            end
            return data_properties
        end
    end
    return {}
end

-------------------------------------------------------------------------------
---Parse Properties
---@param prototype table
---@param level number
---@return table
function PropertiesPanel:parseProperties(prototype, level)
    if prototype == nil then return "nil" end
    local object_name = prototype.object_name
    if level > 2 then
        return object_name
    end

    local properties = {}
    local attributes = self:getClasseAttributes(object_name)
    for _, attribute in pairs(attributes) do
        local attribute_name = attribute.name
        local content = nil
        pcall(function()
            content = prototype[attribute_name]
            if content ~= nil then
                if content.object_name then
                    content = self:parseProperties(content, level + 1)
                elseif type(content) == "table" then
                    for key, value in pairs(content) do
                        content[key] = self:parseProperties(value, level + 1)
                    end
                end
            end
        end)
        properties[attribute_name] = content
    end
    return properties
end
