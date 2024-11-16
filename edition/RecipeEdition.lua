-------------------------------------------------------------------------------
---Class to build recipe edition dialog
---@class RecipeEdition : FormModel
RecipeEdition = newclass(FormModel)

local limit_display_height = 850
local tool_spacing = 2

-------------------------------------------------------------------------------
---On Bind Dispatcher
function RecipeEdition:onBind()
    Dispatcher:bind("on_gui_priority_module", self, self.updateFactoryModules)
    Dispatcher:bind("on_gui_priority_module", self, self.updateBeaconModules)
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function RecipeEdition:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 100,
        maximal_height = math.max(height_main, 800),
    }
end

-------------------------------------------------------------------------------
---On initialization
function RecipeEdition:onInit()
    self.panelCaption = ({ "helmod_recipe-edition-panel.title" })
    self.parameterLast = string.format("%s_%s", self.classname, "last")
end

-------------------------------------------------------------------------------
---Get or create recipe info panel
---@return LuaGuiElement
function RecipeEdition:getObjectInfoPanel()
    local flow_panel, content_panel, menu_panel = self:getPanel()
    if content_panel["info"] ~= nil and content_panel["info"].valid then
        return content_panel["info"]
    end
    local panel = GuiElement.add(content_panel, GuiFrameV("info"))
    panel.style.horizontally_stretchable = true
    return panel
end

function RecipeEdition:getRecipeEditionScrollGroups()
    local width, height, scale = Player.getDisplaySizes()
    local recipe_edition_scroll_groups = User.getSetting("recipe_edition_scroll_groups")
    if recipe_edition_scroll_groups == nil then
        recipe_edition_scroll_groups = height / scale >= limit_display_height
    end
    return recipe_edition_scroll_groups
end

-------------------------------------------------------------------------------
---Get or create tab panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getTabPanel()
    local flow_panel, content_panel, menu_panel = self:getPanel()
    local factory_panel_name = "facory_panel"
    local beacon_panel_name = "beacon_panel"

    local recipe_edition_scroll_groups = self:getRecipeEditionScrollGroups()

    if recipe_edition_scroll_groups then
        ---affichage normal
        if content_panel[factory_panel_name] ~= nil and content_panel[factory_panel_name].valid then
            return content_panel[factory_panel_name], content_panel[beacon_panel_name]
        end
        local factory_panel = GuiElement.add(content_panel, GuiFrameH(factory_panel_name))
        factory_panel.style.horizontally_stretchable = true

        local beacon_panel = GuiElement.add(content_panel, GuiFrameH(beacon_panel_name))
        beacon_panel.style.horizontally_stretchable = true

        return factory_panel, beacon_panel
    else
        local recipe_edition_tab = User.getParameter("recipe_edition_tab") or 1
        local panel_name = table.concat({ self.classname, "change-tab" }, "=")
        ---affichage tab
        if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
            return content_panel[panel_name][panel_name][factory_panel_name],
                content_panel[panel_name][panel_name][beacon_panel_name]
        end


        local panel = GuiElement.add(content_panel, GuiFrameH(panel_name))
        local tab_panel = GuiElement.add(panel, GuiTabPane(panel_name))
        local factory_tab_panel = GuiElement.add(tab_panel, GuiTab(self.classname, "change-tab", "factory"):caption({ "helmod_common.factory" }))
        local factory_panel = GuiElement.add(tab_panel, GuiFlowV(factory_panel_name))
        tab_panel.add_tab(factory_tab_panel, factory_panel)

        local beacon_tab_panel = GuiElement.add(tab_panel, GuiTab(self.classname, "change-tab", "beacon"):caption({ "helmod_common.beacon" }))
        local beacon_panel = GuiElement.add(tab_panel, GuiFlowV(beacon_panel_name))
        tab_panel.add_tab(beacon_tab_panel, beacon_panel)
        tab_panel.selected_tab_index = recipe_edition_tab
        return factory_panel, beacon_panel
    end
end

-------------------------------------------------------------------------------
---Get or create factory panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getFactoryTablePanel()
    local content_panel, _ = self:getTabPanel()
    local table_name = "factory_table"
    local info_name = "factory_info"
    local module_name = "factory_module"
    if content_panel[table_name] ~= nil and content_panel[table_name].valid then
        return content_panel[table_name][info_name], content_panel[table_name][module_name]
    end

    local table_panel = GuiElement.add(content_panel, GuiTable(table_name):column(2))
    table_panel.vertical_centering = false
    local info_panel = GuiElement.add(table_panel, GuiFlowV(info_name))
    info_panel.style.minimal_width = 250
    GuiElement.add(info_panel, GuiLabel("factory_label"):caption({ "helmod_common.factory" }):style("helmod_label_title_frame"))

    local module_panel = GuiElement.add(table_panel, GuiFlowV(module_name))

    module_panel.style.minimal_width = 300
    return info_panel, module_panel
end

-------------------------------------------------------------------------------
---Get or create factory panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getFactoryInfoPanel()
    local info_panel, module_panel = self:getFactoryTablePanel()
    local tool_name = "factory_tool"
    local detail_name = "factory_detail"
    if info_panel[detail_name] ~= nil and info_panel[detail_name].valid then
        return info_panel[tool_name], info_panel[detail_name]
    end
    local tool_panel = GuiElement.add(info_panel, GuiFlowV(tool_name))
    local detail_panel = GuiElement.add(info_panel, GuiFlowV(detail_name))
    return tool_panel, detail_panel
end

-------------------------------------------------------------------------------
---Get or create factory panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getFactoryModulePanel()
    local info_panel, module_panel = self:getFactoryTablePanel()
    local tool_name = "factory_tool"
    local module_name = "factory_module"
    if module_panel[module_name] ~= nil and module_panel[module_name].valid then
        return module_panel[tool_name], module_panel[module_name]
    end
    local tool_panel = GuiElement.add(module_panel, GuiFlowV(tool_name))
    local module_panel = GuiElement.add(module_panel, GuiFlowV(module_name))
    return tool_panel, module_panel
end

-------------------------------------------------------------------------------
---Get or create beacon table panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getBeaconTablePanel()
    local _, content_panel = self:getTabPanel()
    local table_name = "beacon_table"
    local info_name = "beacon_info"
    local module_name = "beacon_module"
    if content_panel[table_name] ~= nil and content_panel[table_name].valid then
        return content_panel[table_name][info_name], content_panel[table_name][module_name]
    end

    local table_panel = GuiElement.add(content_panel, GuiTable(table_name):column(2))
    table_panel.vertical_centering = false
    local info_panel = GuiElement.add(table_panel, GuiFlowV(info_name))
    info_panel.style.minimal_width = 250
    GuiElement.add(info_panel, GuiLabel("beacon_label"):caption({ "helmod_common.beacon" }):style("helmod_label_title_frame"))

    local module_panel = GuiElement.add(table_panel, GuiFlowV(module_name))

    module_panel.style.minimal_width = 300
    return info_panel, module_panel
end

-------------------------------------------------------------------------------
---Get or create beacon info panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getBeaconInfoPanel()
    local info_panel, module_panel = self:getBeaconTablePanel()
    local tool_name = "beacon_tool"
    local detail_name = "beacon_detail"
    if info_panel[detail_name] ~= nil and info_panel[detail_name].valid then
        return info_panel[tool_name], info_panel[detail_name]
    end
    local tool_panel = GuiElement.add(info_panel, GuiFlowV(tool_name))
    local detail_panel = GuiElement.add(info_panel, GuiFlowV(detail_name))
    return tool_panel, detail_panel
end

-------------------------------------------------------------------------------
---Get or create beacon module panel
---@return LuaGuiElement, LuaGuiElement
function RecipeEdition:getBeaconModulePanel()
    local info_panel, module_panel = self:getBeaconTablePanel()
    local tool_name = "beacon_tool"
    local module_name = "beacon_module"
    if module_panel[module_name] ~= nil and module_panel[module_name].valid then
        return module_panel[tool_name], module_panel[module_name]
    end
    local tool_panel = GuiElement.add(module_panel, GuiFlowV(tool_name))
    local module_panel = GuiElement.add(module_panel, GuiFlowV(module_name))
    return tool_panel, module_panel
end

-------------------------------------------------------------------------------
---On before open
---@param event LuaEvent
function RecipeEdition:onBeforeOpen(event)
    FormModel.onBeforeOpen(self, event)
    local close = (event.action == "OPEN") ---only on open event
    User.setParameter("module_list_refresh", false)
    if event.action == "OPEN" then
        local parameter_last = string.format("%s%s%s", event.item1, event.item2, event.item3)
        if User.getParameter(self.parameterLast) or User.getParameter(self.parameterLast) ~= parameter_last then
            close = false
            User.setParameter("factory_group_selected", nil)
            User.setParameter("beacon_group_selected", nil)
            User.setParameter("module_list_refresh", true)
        end

        User.setParameter(self.parameterLast, parameter_last)
    end
    return close
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function RecipeEdition:onEvent(event)
    local display_width, display_height, scale = Player.getDisplaySizes()

    local model, block, recipe = self:getParameterObjects()
    if model == nil or block == nil or recipe == nil then return end

    if event.action == "change-sroll-groups" then
        User.setSetting("recipe_edition_scroll_groups", event.item1 == "true")
        Controller:send("on_gui_update", event, self.classname)
    end

    if event.action == "change-tab" then
        local recipe_edition_tab = event.element.selected_tab_index
        User.setParameter("recipe_edition_tab", recipe_edition_tab)
    end

    if User.isWriter(model) then
        User.setParameter("scroll_element", recipe.id)

        if event.action == "neighbour-bonus-update" then
            local index = event.element.selected_index
            local items = { 1, 2, 4, 8 }
            ModelBuilder.updateRecipeNeighbourBonus(recipe, items[index])
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "recipe-update" then
            local text = event.element.text
            local production = (formula(text) or 100) / 100
            ModelBuilder.updateRecipeProduction(recipe, production)
            ModelCompute.update(model)
            self:updateObjectInfo(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-select" then
            Model.setFactory(recipe, event.item4)
            ModelBuilder.applyFactoryModulePriority(recipe)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-fuel-update" then
            local index = event.element.selected_index
            local factory_prototype = EntityPrototype(recipe.factory)
            local energy_type = factory_prototype:getEnergyTypeInput()
            local fuel_list = {}
            if energy_type == "burner" then
                local energy_prototype = factory_prototype:getEnergySource()
                fuel_list = energy_prototype:getFuelPrototypes()
            elseif energy_type == "fluid" then
                fuel_list = factory_prototype:getFluidFuelPrototypes()
            end
            local fuel = nil
            for _, item in pairs(fuel_list) do
                if index == 1 then
                    if energy_type == "fluid" then
                        fuel = { name = item:native().name, temperature = item.temperature }
                    else
                        fuel = item:native().name
                    end
                    break
                end
                index = index - 1
            end
            ModelBuilder.updateFuelFactory(recipe, fuel)
            ModelCompute.update(model)
            if recipe.type ~= "energy" then
                self:updateFactoryInfoTool(event)
            end
            self:updateFactoryInfo(event)
            self:updateHeader(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-tool" then
            if event.item4 == "default" then
                User.setDefaultFactory(recipe)
            elseif event.item4 == "block" then
                ModelBuilder.setFactoryBlock(block, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "line" then
                ModelBuilder.setFactoryLine(model, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "category" then
                local default_factory_mode = User.getParameter("default_factory_mode")
                if default_factory_mode ~= "category" then
                    User.setParameter("default_factory_mode", "category")
                else
                    User.setParameter("default_factory_mode", "all")
                end
            end
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-module-tool" then
            if event.item4 == "block" then
                ModelBuilder.setFactoryModuleBlock(block, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "line" then
                ModelBuilder.setFactoryModuleLine(model, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "erase" then
                ModelBuilder.setFactoryModulePriority(recipe, nil)
                ModelCompute.update(model)
            end
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-module-priority-select" then
            User.setParameter("factory_module_priority", tonumber(event.item4))
            self:updateFactoryModules(event)
        end

        if event.action == "factory-module-priority-apply" then
            local factory_module_priority = User.getParameter("factory_module_priority") or 1
            local priority_modules = User.getParameter("priority_modules")
            if factory_module_priority ~= nil and priority_modules ~= nil and priority_modules[factory_module_priority] ~= nil then
                local module_quality = event.item4
                local module_priorities = table.deepcopy(priority_modules[factory_module_priority])
                ModelBuilder.setQualityModulePriority(module_priorities, module_quality)
                ModelBuilder.setFactoryModulePriority(recipe, module_priorities)
                ModelCompute.update(model)
                self:update(event)
                Controller:send("on_gui_recipe_update", event)
            end
        end

        if event.action == "factory-module-select" then
            ModelBuilder.addFactoryModule(recipe, event.item4, event.item5, event.control)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-module-remove" then
            ModelBuilder.removeFactoryModule(recipe, event.item4, event.item5, event.control)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-select" then
            User.setParameter("current_beacon_selection", tonumber(event.item4))
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-add" then
            if recipe.beacons == nil then recipe.beacons = {} end
            local new_beacon = Model.newBeacon()
            table.insert(recipe.beacons, new_beacon)
            User.setParameter("current_beacon_selection", #recipe.beacons)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-remove" then
            local current_beacon_selection = User.getParameter("current_beacon_selection") or 1
            if #recipe.beacons > 1 then
                table.remove(recipe.beacons, current_beacon_selection)
            end
            User.setParameter("current_beacon_selection", #recipe.beacons)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-tool" then
            if event.item4 == "default" then
                User.setDefaultBeacons(recipe)
            elseif event.item4 == "block" then
                ModelBuilder.setBeaconBlock(block, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "line" then
                ModelBuilder.setBeaconLine(model, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "category" then
                local default_beacon_mode = User.getParameter("default_beacon_mode")
                if default_beacon_mode ~= "category" then
                    User.setParameter("default_beacon_mode", "category")
                else
                    User.setParameter("default_beacon_mode", "all")
                end
            end
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-module-tool" then
            if event.item4 == "block" then
                ModelBuilder.setBeaconModuleBlock(block, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "line" then
                ModelBuilder.setBeaconModuleLine(model, recipe)
                ModelCompute.update(model)
            elseif event.item4 == "erase" then
                local beacon = ModelBuilder.getCurrentBeacon(recipe)
                ModelBuilder.setBeaconModulePriority(beacon, recipe, nil)
                ModelCompute.update(model)
            end
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-module-priority-select" then
            User.setParameter("beacon_module_priority", tonumber(event.item4))
            self:updateBeaconModules(event)
        end

        if event.action == "beacon-module-priority-apply" then
            local beacon_module_priority = User.getParameter("beacon_module_priority") or 1
            local priority_modules = User.getParameter("priority_modules")
            if beacon_module_priority ~= nil and priority_modules ~= nil and priority_modules[beacon_module_priority] ~= nil then
                local beacon = ModelBuilder.getCurrentBeacon(recipe)
                local module_quality = event.item4
                local module_priorities = table.deepcopy(priority_modules[beacon_module_priority])
                ModelBuilder.setQualityModulePriority(module_priorities, module_quality)
                ModelBuilder.setBeaconModulePriority(beacon, recipe, module_priorities)
                ModelCompute.update(model)
                self:update(event)
                Controller:send("on_gui_recipe_update", event)
            end
        end

        if event.action == "beacon-module-select" then
            local beacon = ModelBuilder.getCurrentBeacon(recipe)
            ModelBuilder.addBeaconModule(beacon, recipe, event.item4, event.item5, event.control)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-module-remove" then
            local beacon = ModelBuilder.getCurrentBeacon(recipe)
            ModelBuilder.removeBeaconModule(beacon, recipe, event.item4, event.item5, event.control)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-choose" then
            local current_beacon_selection = User.getParameter("current_beacon_selection") or 1
            Model.setBeacon(recipe, current_beacon_selection, event.item4)
            ModelBuilder.applyBeaconModulePriority(recipe)
            ModelCompute.update(model)
            self:update(event)
            Controller:send("on_gui_recipe_update",     event)
        end

        if event.action == "beacon-update" then
            local options = {}
            local text = event.element.text
            ---item3 = "combo" or "factory"
            local ok, err = pcall(function()
                options[event.item4] = formula(text) or 0
                local beacon = ModelBuilder.getCurrentBeacon(recipe)
                ModelBuilder.updateBeacon(beacon, recipe, options)
                ModelCompute.update(model)
                self:updateBeaconInfo(event)
                if display_height / scale >= limit_display_height or User.getParameter("factory_tab") then
                    self:updateFactoryInfo(event)
                end
                Controller:send("on_gui_recipe_update", event)
            end)
            if not (ok) then
                Player.print("Formula is not valid!")
            end
        end

        if event.action == "factory-switch-module" then
            local factory_switch_priority = event.element.switch_state == "right"
            User.setParameter("factory_switch_priority", factory_switch_priority)
            self:updateFactoryModules(event)
        end

        if event.action == "beacon-switch-module" then
            local beacon_switch_priority = event.element.switch_state == "right"
            User.setParameter("beacon_switch_priority", beacon_switch_priority)
            self:updateBeaconModules(event)
        end

        if event.action == "recipe-quality-select" then
            recipe.quality = event.item4
            ModelCompute.update(model)
            self:updateObjectInfo(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-quality-select" then
            recipe.factory.quality = event.item4
            ModelCompute.update(model)
            self:updateFactoryInfo(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "beacon-quality-select" then
            local beacon = ModelBuilder.getCurrentBeacon(recipe)
            beacon.quality = event.item4
            ModelCompute.update(model)
            self:updateBeaconInfo(event)
            Controller:send("on_gui_recipe_update", event)
        end

        if event.action == "factory-module-quality-select" then
            local factory_module_quality = event.item4
            User.setParameter("factory_module_quality", factory_module_quality)
            self:updateFactoryModulesActive(event)
            self:updateFactoryModules(event)
        end
            
        if event.action == "beacon-module-quality-select" then
            local beacon_module_quality = event.item4
            User.setParameter("beacon_module_quality", beacon_module_quality)
            self:updateBeaconModulesActive(event)
            self:updateBeaconModules(event)
        end
            
    end
end

-------------------------------------------------------------------------------
---On close dialog
function RecipeEdition:onClose()
    User.setParameter(self.parameterLast, nil)
    User.setParameter("module_list_refresh", false)
end

-------------------------------------------------------------------------------
---On open
---@param event LuaEvent
function RecipeEdition:onOpen(event)
    if User.getParameter("module_panel") == nil then
        User.setParameter("module_panel", true)
    end
    if User.getParameter("factory_tab") == nil then
        User.setParameter("factory_tab", true)
    end
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeEdition:onUpdate(event)
    local model, block, recipe = self:getParameterObjects()
    ---header
    self:updateHeader(event)
    if recipe ~= nil and recipe.type ~= "spoiling" then
        if recipe.type == "energy" then
            self:updateFactoryInfo(event)
        else
            self:updateFactoryInfoTool(event)
            self:updateFactoryInfo(event)
            self:updateFactoryModulesActive(event)
            self:updateFactoryModules(event)

            self:updateBeaconInfoTool(event)
            self:updateBeaconInfo(event)
            self:updateBeaconModulesActive(event)
            self:updateBeaconModules(event)
        end
    end
end

-------------------------------------------------------------------------------
---Update tab menu
---@param event LuaEvent
function RecipeEdition:updateTabMenu(event)
    local tab_left_panel = self:getTabLeftPanel()
    local tab_right_panel = self:getTabRightPanel()
    local model, block, recipe = self:getParameterObjects()

    local display_width, display_height, scale = Player.getDisplaySizes()

    tab_left_panel.clear()
    tab_right_panel.clear()

    ---left tab
    if display_height / scale < limit_display_height then
        local style = "helmod_button_tab"
        if User.getParameter("factory_tab") == true then style = "helmod_button_tab_selected" end

        GuiElement.add(tab_left_panel, GuiFrameH(self.classname, "separator_factory"):style(helmod_frame_style.tab)).style.width = 5
        GuiElement.add(tab_left_panel, GuiButton(self.classname, "edition-change-tab", model.id, block.id, recipe.id, "factory"):style(style):caption({ "helmod_common.factory" }):tooltip({ "helmod_common.factory" }))

        local style = "helmod_button_tab"
        if User.getParameter("factory_tab") == false then style = "helmod_button_tab_selected" end

        GuiElement.add(tab_left_panel, GuiFrameH(self.classname, "separator_beacon"):style(helmod_frame_style.tab)).style.width = 5
        GuiElement.add(tab_left_panel, GuiButton(self.classname, "edition-change-tab", model.id, block.id, recipe.id, "beacon"):style(style):caption({ "helmod_common.beacon" }):tooltip({ "helmod_common.beacon" }))

        GuiElement.add(tab_left_panel, GuiFrameH("tab_final"):style(helmod_frame_style.tab)).style.width = 100
    end
    ---right tab
    local style = "helmod_button_tab"
    if User.getParameter("module_panel") == false then style = "helmod_button_tab_selected" end

    GuiElement.add(tab_right_panel, GuiFrameH(self.classname, "separator_factory"):style(helmod_frame_style.tab)).style.width = 5
    GuiElement.add(tab_right_panel, GuiButton(self.classname, "change-panel", model.id, block.id, recipe.id, "factory"):style(style):caption({"helmod_common.factory" }):tooltip({ "tooltip.selector-factory" }))

    local style = "helmod_button_tab"
    if User.getParameter("module_panel") == true then style = "helmod_button_tab_selected" end

    GuiElement.addGuiFrameH(tab_right_panel, self.classname .. "_separator_module", helmod_frame_style.tab).style.width = 5
    GuiElement.add(tab_right_panel, GuiButton(self.classname, "change-panel", model.id, block.id, recipe.id, "module"):style(style):caption({"helmod_common.module" }):tooltip({ "tooltip.selector-module" }))

    GuiElement.add(tab_right_panel, GuiFrameH("tab_final"):style(helmod_frame_style.tab)).style.width = 100
end

-------------------------------------------------------------------------------
---Update factory tool
---@param event LuaEvent
function RecipeEdition:updateFactoryInfoTool(event)
    local tool_panel, detail_panel = self:getFactoryInfoPanel()
    local model, block, recipe = self:getParameterObjects()

    if recipe ~= nil then
        local factory = recipe.factory
        local factory_prototype = EntityPrototype(factory)
        tool_panel.clear()

        ---factory tool
        local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
        tool_action_panel.style.horizontal_spacing = 10
        tool_action_panel.style.bottom_padding = 10
        local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
        tool_panel1.style.horizontal_spacing = tool_spacing

        local default_factory = User.getDefaultFactory(recipe)
        local record_style = "helmod_button_menu_sm_default"
        if Model.compareFactory(default_factory, factory, Model.factoryHasModule(factory)) then record_style = "helmod_button_menu_sm_selected" end
        
        local tooltip_default = GuiTooltipFactory("helmod_recipe-edition-panel.set-default"):element(default_factory)
        GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "default"):sprite("menu", defines.sprites.favorite.black, defines.sprites.favorite.black):style(record_style):tooltip(tooltip_default))
        
        local tooltip_line = GuiTooltipFactory("helmod_recipe-edition-panel.apply-block"):element(factory):tooltip("helmod_recipe-edition-panel.current-factory")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "block"):sprite("menu", defines.sprites.expand_right.black, defines.sprites.expand_right.black):style("helmod_button_menu_sm"):tooltip(tooltip_line))
        
        local tooltip_block = GuiTooltipFactory("helmod_recipe-edition-panel.apply-line"):element(factory):tooltip("helmod_recipe-edition-panel.current-factory")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "line"):sprite("menu", defines.sprites.expand_right_group.black, defines.sprites.expand_right_group.black):style("helmod_button_menu_sm"):tooltip(tooltip_block))

        local options_panel = GuiElement.add(tool_action_panel, GuiFlowH("tool3"))
        options_panel.style.horizontal_spacing = tool_spacing
        local button_style = "helmod_button_menu_sm_bold"
        local selected_button_style = "helmod_button_menu_sm_bold_selected"
        local default_factory_mode = User.getParameter("default_factory_mode")
        local all_button_style = button_style
        local tooltip = { "helmod_recipe-edition-panel.apply-option-category" }
        if default_factory_mode ~= "category" then
            all_button_style = selected_button_style
            tooltip = { "helmod_recipe-edition-panel.apply-option-all" }
        end
        GuiElement.add(options_panel, GuiButton(self.classname, "factory-tool", model.id, block.id, recipe.id, "category"):caption("A"):style(all_button_style):tooltip(tooltip))
    end
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function RecipeEdition:updateFactoryInfo(event)
    local tool_panel, detail_panel = self:getFactoryInfoPanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        local factory = recipe.factory
        local factory_prototype = EntityPrototype(factory)

        detail_panel.clear()

        if Player.hasFeatureQuality() then
            local current_quality = factory.quality or "normal"
            local quality_panel = GuiElement.addQualitySelector(detail_panel, current_quality, self.classname, "factory-quality-select", model.id, block.id, recipe.id)
            quality_panel.style.bottom_margin = 5
        end

        ---factory selection
        local scroll_panel = GuiElement.add(detail_panel, GuiScroll("factory-scroll"):policy(true))
        scroll_panel.style.maximal_height = 118
        local recipe_prototype = RecipePrototype(recipe)
        local category = recipe_prototype:getCategory()
        local factories = {}
        if recipe.type == "energy" then
            factories[recipe.factory.name] = recipe.factory
        elseif recipe.type == "fluid" then
            factories = Player.getProductionsCrafting("fluid", recipe)
        elseif recipe.type == "boiler" then
            factories = Player.getBoilersForRecipe(recipe_prototype)
        elseif recipe.type == "agricultural" then
            factories = Player.getAgriculturalTowers()
        else
            factories = Player.getProductionsCrafting(category, recipe)
        end

        local factory_table_panel = GuiElement.add(scroll_panel, GuiTable("factory-table"):column(5))
        for key, element in spairs(factories, function(t, a, b) return t[b].crafting_speed > t[a].crafting_speed end) do
            local color = nil
            if factory.name == element.name then color = GuiElement.color_button_edit end
            local choose_type = "entity"
            local choose_name = element.name
            local choose_quality = "normal"
            if factory ~= nil then
                choose_quality = factory.quality
            end
            local button = GuiElement.add(factory_table_panel, GuiButtonSelectSprite(self.classname, "factory-select", model.id, block.id, recipe.id):choose_with_quality(choose_type, choose_name, choose_quality):color(color))
            button.locked = true
        end
        ---factory info
        local header_panel = GuiElement.add(detail_panel, GuiTable("table-header"):column(2))
        if factory_prototype:native() == nil then
            GuiElement.add(header_panel, GuiLabel("label"):caption(factory.name))
        else
            GuiElement.add(header_panel, GuiLabel("label"):caption(factory_prototype:getLocalisedName()))
        end

        local input_panel = GuiElement.add(detail_panel, GuiTable("table-input"):column(2))
        input_panel.style.horizontal_spacing = 10

        GuiElement.add(input_panel, GuiLabel("label-module-slots"):caption({ "helmod_label.module-slots" }))
        GuiElement.add(input_panel, GuiLabel("module-slots"):caption(factory_prototype:getModuleInventorySize()))

        ---neighbour
        if factory_prototype:getType() == "reactor" then
            local items = {}
            local default_neighbour = nil
            local item = nil
            for _, value in pairs({ 1, 2, 4, 8 }) do
                item = { "", value, " ", { "entity-name.nuclear-reactor" } }
                table.insert(items, item)
                if default_neighbour == nil then
                    default_neighbour = item
                end
                if factory.neighbour_bonus == value then
                    default_neighbour = item
                end
            end

            GuiElement.add(input_panel, GuiLabel("label-neighbour"):caption({ "description.neighbour-bonus" }))
            GuiElement.add(input_panel, GuiDropDown(self.classname, "neighbour-bonus-update", model.id, block.id, recipe.id):items(items, default_neighbour))
        end
        ---energy
        local cell_energy = GuiElement.add(input_panel, GuiFlowH("label-energy"))
        GuiElement.add(cell_energy, GuiLabel("label-energy"):caption({ "helmod_label.energy" }))
        self:addAlert(cell_energy, factory, "consumption")

        local sign = ""
        if factory.effects.consumption > 0 then sign = "+" end
        GuiElement.add(input_panel, GuiLabel("energy"):caption(Format.formatNumberKilo(factory.energy, "W") .. " (" .. sign .. Format.formatPercent(factory.effects.consumption) .. "%)"))

        ---burner
        local energy_type = factory_prototype:getEnergyTypeInput()
        if energy_type == "burner" or energy_type == "fluid" then
            local fuel_type = "item"
            if energy_type == "fluid" then
                fuel_type = "fluid"
            end
            local energy_prototype = factory_prototype:getEnergySource()
            local fuel_list = {}
            local factory_fuel = nil

            if energy_type == "fluid" then
                fuel_list = factory_prototype:getFluidFuelPrototypes()
                factory_fuel = factory_prototype:getFluidFuelPrototype()
            else
                fuel_list = energy_prototype:getFuelPrototypes()
                factory_fuel = energy_prototype:getFuelPrototype()
            end

            if fuel_list ~= nil and factory_fuel ~= nil then
                local items = {}
                if (energy_type == "fluid") and (not factory_prototype:getBurnsFluid()) then
                    for _, item in pairs(fuel_list) do
                        table.insert(items, string.format("[%s=%s] %s °C", fuel_type, item:native().name, item.temperature))
                    end
                else
                    for _, item in pairs(fuel_list) do
                        table.insert(items, string.format("[%s=%s] %s", fuel_type, item:native().name, Format.formatNumberKilo(item:getFuelValue(), "J")))
                    end
                end

                local default_fuel
                if (energy_type == "fluid") and (not factory_prototype:getBurnsFluid()) then
                    default_fuel = string.format("[%s=%s] %s °C", fuel_type, factory_fuel:native().name, factory_fuel.temperature)
                else
                    default_fuel = string.format("[%s=%s] %s", fuel_type, factory_fuel:native().name, Format.formatNumberKilo(factory_fuel:getFuelValue(), "J"))
                end
                GuiElement.add(input_panel, GuiLabel("label-burner"):caption({ "helmod_common.resource" }))
                GuiElement.add(input_panel, GuiDropDown(self.classname, "factory-fuel-update", model.id, block.id, recipe.id, fuel_type):items(items, default_fuel):tooltip(factory_fuel:native().localised_name))
            end
        end

        ---speed
        local sign = ""
        if factory.effects.speed > 0 then sign = "+" end
        local cell_speed = GuiElement.add(input_panel, GuiFlowH("label-speed"))
        GuiElement.add(cell_speed, GuiLabel("label-speed"):caption({ "helmod_label.speed" }))
        self:addAlert(cell_speed, factory, "speed")
        GuiElement.add(input_panel, GuiLabel("speed"):caption(Format.formatNumber(factory.speed) .. " (" .. sign .. Format.formatPercent(factory.effects.speed) .. "%)"))

        ---productivity
        local sign = ""
        if factory.effects.productivity > 0 then sign = "+" end
        local cell_productivity = GuiElement.add(input_panel, GuiFlowH("label-productivity"))
        GuiElement.add(cell_productivity, GuiLabel("label-productivity"):caption({ "helmod_label.productivity" }))
        self:addAlert(cell_productivity, factory, "productivity")
        GuiElement.add(input_panel, GuiLabel("productivity"):caption(sign .. Format.formatPercent(factory.effects.productivity) .. "%"))

        ---pollution
        local cell_pollution = GuiElement.add(input_panel, GuiFlowH("label-pollution"))
        GuiElement.add(cell_pollution, GuiLabel("label-pollution"):caption({ "helmod_common.pollution" }))
        self:addAlert(cell_pollution, factory, "pollution")
        GuiElement.add(input_panel, GuiLabel("pollution"):caption({ "helmod_si.per-minute", Format.formatNumberElement((factory.pollution or 0) * 60) }))
    end
end

-------------------------------------------------------------------------------
---Add alert information
---@param cell LuaGuiElement
---@param factory table
---@param type string
function RecipeEdition:addAlert(cell, factory, type)
    if factory.cap ~= nil and factory.cap[type] ~= nil and factory.cap[type] > 0 then
        local tooltip = { "" }
        if ModelCompute.cap_reason[type].cycle ~= nil and ModelCompute.cap_reason[type].cycle > 0 and bit32.band(factory.cap[type], ModelCompute.cap_reason[type].cycle) > 0 then
            table.insert(tooltip, { string.format("helmod_cap_reason.%s-cycle", type) })
        end
        if ModelCompute.cap_reason[type].module_low ~= nil and ModelCompute.cap_reason[type].module_low > 0 and bit32.band(factory.cap[type], ModelCompute.cap_reason[type].module_low) > 0 then
            if #tooltip > 1 then
                table.insert(tooltip, "\n")
            end
            table.insert(tooltip, { string.format("helmod_cap_reason.%s-module-low", type) })
        end
        if ModelCompute.cap_reason[type].module_high ~= nil and ModelCompute.cap_reason[type].module_high > 0 and bit32.band(factory.cap[type], ModelCompute.cap_reason[type].module_high) > 0 then
            if #tooltip > 1 then
                table.insert(tooltip, "\n")
            end
            table.insert(tooltip, { string.format("helmod_cap_reason.%s-module-high", type) })
        end
        GuiElement.add(cell, GuiSprite("alert"):sprite("helmod-alert1"):tooltip(tooltip))
    end
end

-------------------------------------------------------------------------------
---Update modules information
---@param event LuaEvent
function RecipeEdition:updateFactoryModulesActive(event)
    if not (self:isOpened()) then return end
    local tool_panel, module_panel = self:getFactoryModulePanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        local factory = recipe.factory

        tool_panel.clear()
        GuiElement.add(tool_panel, GuiLabel("module_label"):caption({ "helmod_recipe-edition-panel.current-modules" }):style("helmod_label_title_frame"))

        ---module tool
        local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
        tool_action_panel.style.horizontal_spacing = 10
        tool_action_panel.style.bottom_padding = 10
        local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
        tool_panel1.style.horizontal_spacing = tool_spacing
        
        local tooltip_apply_block = GuiTooltipPriority("helmod_recipe-edition-panel.apply-block"):element(factory.module_priority):tooltip("helmod_recipe-edition-panel.current-module")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "block"):sprite("menu", defines.sprites.expand_right.black, defines.sprites.expand_right.black):style("helmod_button_menu_sm"):tooltip(tooltip_apply_block))
        
        local tooltip_line = GuiTooltipPriority("helmod_recipe-edition-panel.apply-line"):element(factory.module_priority):tooltip("helmod_recipe-edition-panel.current-module")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "line"):sprite("menu", defines.sprites.expand_right_group.black, defines.sprites.expand_right_group.black):style("helmod_button_menu_sm"):tooltip(tooltip_line))
        
        local tooltip_erase = GuiTooltipPriority("helmod_recipe-edition-panel.module-clear"):element(factory.module_priority)
        GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-tool", model.id, block.id, recipe.id, "erase"):sprite("menu", defines.sprites.eraser.black, defines.sprites.eraser.black):style("helmod_button_menu_sm"):tooltip(tooltip_erase))

        if Player.hasFeatureQuality() then
            local factory_module_quality = User.getParameter("factory_module_quality") or "normal"
            local quality_panel = GuiElement.addQualitySelector(tool_panel, factory_module_quality, self.classname, "factory-module-quality-select", model.id, block.id, recipe.id)
            quality_panel.style.bottom_margin = 5
        end

        ---actived modules panel
        local module_table = GuiElement.add(tool_panel, GuiTable("modules"):column(6):style("helmod_table_recipe_modules"))
        local control_info = "module-remove"
        for _, module in pairs(factory.modules) do
            if type(module) == "table" then
                local module_cell = GuiElement.add(module_table, GuiFlowH("module-cell", module.name, module.quality))
                local tooltip = GuiTooltipModule("tooltip.remove-module"):element({ type = "item", name = module.name, quality = module.quality }):withControlInfo(control_info)
                GuiElement.add(module_cell, GuiButtonSelectSprite(self.classname, "factory-module-remove", model.id, block.id, recipe.id):sprite_with_quality("item", module.name, module.quality):tooltip(tooltip))
                GuiElement.add(module_cell, GuiLabel("module-amount"):caption({ "", "x", module.amount }))
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update modules information
---@param event LuaEvent
function RecipeEdition:updateFactoryModules(event)
    if not (self:isOpened()) then return end
    local tool_panel, module_panel = self:getFactoryModulePanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        local factory_switch_priority = User.getParameter("factory_switch_priority")

        module_panel.clear()

        local element_state = "left"
        if factory_switch_priority == true then element_state = "right" end
        local factory_switch_module = GuiElement.add(module_panel, GuiSwitch(self.classname, "factory-switch-module", model.id, block.id, recipe.id):state(element_state) :leftLabel({ "helmod_recipe-edition-panel.selection-modules" }):rightLabel({ "helmod_label.priority-modules" }))
        if factory_switch_priority == true then
            ---module priority
            self:updateFactoryModulesPriority(module_panel)
        else
            ---module selector
            self:updateFactoryModulesSelector(module_panel)
        end
    end
end

-------------------------------------------------------------------------------
---Update modules priority
---@param factory_module_panel LuaGuiElement
function RecipeEdition:updateFactoryModulesPriority(factory_module_panel)
    local model, block, recipe = self:getParameterObjects()
    ---module priority
    local factory_module_priority = User.getParameter("factory_module_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    local factory_module_quality = User.getParameter("factory_module_quality") or "normal"

    ---configuration select
    local tool_action_panel2 = GuiElement.add(factory_module_panel, GuiFlowH("tool-action2"))
    tool_action_panel2.style.horizontal_spacing = 10
    tool_action_panel2.style.bottom_padding = 10

    local tool_panel1 = GuiElement.add(tool_action_panel2, GuiFlowH("tool1"))
    tool_panel1.style.horizontal_spacing = tool_spacing
    local button_style = "helmod_button_menu_sm_bold"
    GuiElement.add(tool_panel1, GuiButton("HMPreferenceEdition", "OPEN", "priority_module"):sprite("menu", defines.sprites.process.black, defines.sprites.process.black):style("helmod_button_menu_sm"):tooltip({ "helmod_button.preferences" }))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "factory-module-priority-apply", model.id, block.id, recipe.id, factory_module_quality):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"):tooltip({"helmod_recipe-edition-panel.apply-priority" }))

    local tool_panel2 = GuiElement.add(tool_action_panel2, GuiTable("tool2"):column(6))
    for i, priority_module in pairs(priority_modules) do
        local button_style2 = button_style
        if factory_module_priority == i then button_style2 = "helmod_button_menu_sm_bold_selected" end
        GuiElement.add(tool_panel2, GuiButton(self.classname, "factory-module-priority-select", model.id, block.id, recipe.id, i):caption(i):style(button_style2))
    end

    ---module priority info
    local priority_table_panel = GuiElement.add(factory_module_panel, GuiTable("module-priority-table"):column(2))
    if priority_modules[factory_module_priority] ~= nil then
        local control_info = "module-add"
        for index, element in pairs(priority_modules[factory_module_priority]) do
            local color = nil
            local module = ItemPrototype(element.name)
            local tooltip = GuiTooltipModule("tooltip.add-module"):element({ type = "item", name = element.name, quality = factory_module_quality }):withControlInfo(control_info)
            if Player.checkFactoryLimitationModule(module:native(), recipe) == false then
                local limitation_message = Player.getFactoryLimitationModuleMessage(module:native(), recipe);

                if limitation_message ~= nil then
                    tooltip = limitation_message
                else
                    tooltip = ""
                end
                color = GuiElement.color_button_rest
            end
            GuiElement.add(priority_table_panel, GuiButtonSelectSprite(self.classname, "factory-module-select", model.id, block.id, recipe.id):sprite_with_quality("entity", element.name, factory_module_quality):color(color):index(index):tooltip(tooltip))
            GuiElement.add(priority_table_panel, GuiLabel("priority-value", index):caption({ "", "x", element.value }))
        end
    end
end

-------------------------------------------------------------------------------
---Update modules selector
---@param factory_module_panel LuaGuiElement
function RecipeEdition:updateFactoryModulesSelector(factory_module_panel)
    local model, block, recipe = self:getParameterObjects()
    local factory_module_quality = User.getParameter("factory_module_quality") or "normal"
    local module_scroll = GuiElement.add(factory_module_panel, GuiScroll("module-selector-scroll"))
    module_scroll.style.maximal_height = 118
    local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(6))
    for k, element in pairs(Player.getModules()) do
        local control_info = "module-add"
        local tooltip = GuiTooltipModule("tooltip.add-module"):element({ type = "item", name = element.name, quality = factory_module_quality }):withControlInfo(control_info)
        local module = ItemPrototype(element.name)
        if Player.checkFactoryLimitationModule(module:native(), recipe) == true then
            GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "factory-module-select", model.id, block.id, recipe.id):sprite_with_quality("entity", element.name, factory_module_quality):tooltip(tooltip))
        end
    end
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function RecipeEdition:updateBeaconInfo(event)
    if event.is_queue == true then return end
    local tool_panel, detail_panel = self:getBeaconInfoPanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        local beacon = ModelBuilder.getCurrentBeacon(recipe)
        local beacon_prototype = EntityPrototype(beacon)

        detail_panel.clear()

        if Player.hasFeatureQuality() then
            local current_quality = beacon.quality or "normal"
            local quality_panel = GuiElement.addQualitySelector(detail_panel, current_quality, self.classname, "beacon-quality-select", model.id, block.id, recipe.id)
            quality_panel.style.bottom_margin = 5
        end

        ---beacon selection
        local scroll_panel = GuiElement.add(detail_panel, GuiScroll("beacon-scroll"):policy(true))
        scroll_panel.style.maximal_height = 118
        local factories = Player.getProductionsBeacon()

        local last_element = nil
        local factory_table_panel = GuiElement.add(scroll_panel, GuiTable("beacon-table"):column(5))
        for key, element in pairs(factories) do
            local color = nil
            if beacon ~= nil and beacon.name == element.name then color = GuiElement.color_button_edit end
            local choose_type = "entity"
            local choose_name = element.name
            local choose_quality = "normal"
            if beacon ~= nil then
                choose_quality = beacon.quality
            end
            local button = GuiElement.add(factory_table_panel, GuiButtonSelectSprite(self.classname, "beacon-choose", model.id, block.id, recipe.id):choose_with_quality(choose_type, choose_name, choose_quality):color(color))
            button.locked = true
            if beacon ~= nil and beacon.name == element.name then last_element = button end
        end

        if last_element ~= nil then
            scroll_panel.scroll_to_element(last_element)
        end

        ---beacon info
        local header_panel = GuiElement.add(detail_panel, GuiTable("table-header"):column(2))
        if beacon_prototype:native() == nil then
            GuiElement.add(header_panel, GuiLabel("label"):caption(beacon.name))
        else
            GuiElement.add(header_panel, GuiLabel("label"):caption(beacon_prototype:getLocalisedName()))
        end

        local input_panel = GuiElement.add(detail_panel, GuiTable("table-input"):column(2))

        GuiElement.add(input_panel, GuiLabel("label-module-slots"):caption({ "helmod_label.module-slots" }))
        GuiElement.add(input_panel, GuiLabel("module-slots"):caption(beacon_prototype:getModuleInventorySize()))

        GuiElement.add(input_panel, GuiLabel("label-energy-nominal"):caption({ "helmod_label.energy" }))
        GuiElement.add(input_panel, GuiLabel("energy"):caption(Format.formatNumberKilo(beacon_prototype:getEnergyUsage(), "W")))

        GuiElement.add(input_panel, GuiLabel("label-efficiency"):caption({ "helmod_label.efficiency" }))
        GuiElement.add(input_panel, GuiLabel("efficiency"):caption(beacon_prototype:getDistributionEffectivity()))

        GuiElement.add(input_panel, GuiLabel("label-combo"):caption({ "helmod_label.beacon-on-factory" }):tooltip({ "tooltip.beacon-on-factory" }))
        GuiElement.add(input_panel, GuiTextField(self.classname, "beacon-update", model.id, block.id, recipe.id, "combo", "onqueue"):text(beacon.combo):style("helmod_textfield"):tooltip({ "tooltip.beacon-on-factory" }))

        GuiElement.add(input_panel, GuiLabel("label-by-factory"):caption({ "helmod_label.beacon-per-factory" }):tooltip({"tooltip.beacon-per-factory" }))
        GuiElement.add(input_panel, GuiTextField(self.classname, "beacon-update", model.id, block.id, recipe.id, "per_factory", "onqueue"):text(beacon.per_factory):style("helmod_textfield"):tooltip({ "tooltip.beacon-per-factory" }))

        GuiElement.add(input_panel, GuiLabel("label-by-factory-constant"):caption({ "helmod_label.beacon-per-factory-constant" }):tooltip({"tooltip.beacon-per-factory-constant" }))
        GuiElement.add(input_panel, GuiTextField(self.classname, "beacon-update", model.id, block.id, recipe.id, "per_factory_constant",  "onqueue"):text(beacon.per_factory_constant):style("helmod_textfield"):tooltip({"tooltip.beacon-per-factory-constant" }))
    end
end

-------------------------------------------------------------------------------
---Update beacon tool
---@param event LuaEvent
function RecipeEdition:updateBeaconInfoTool(event)
    local tool_panel, detail_panel = self:getBeaconInfoPanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        local beacon = ModelBuilder.getCurrentBeacon(recipe)

        tool_panel.clear()

        ---factory tool
        local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
        tool_action_panel.style.horizontal_spacing = 10
        tool_action_panel.style.bottom_padding = 10
        local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
        tool_panel1.style.horizontal_spacing = tool_spacing

        local beacons = recipe.beacons
        local default_beacons = User.getDefaultBeacons(recipe)
        local record_style = "helmod_button_menu_sm"
        if Model.compareBeacons(default_beacons, beacons) then record_style = "helmod_button_menu_sm_selected" end
        
        local tooltip_default = GuiTooltipBeacons("helmod_recipe-edition-panel.set-default"):element(default_beacons)
        GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "default"):sprite("menu", defines.sprites.favorite.black, defines.sprites.favorite.black):style(record_style):tooltip(tooltip_default))
        
        local tooltip_apply_block = GuiTooltipBeacons("helmod_recipe-edition-panel.apply-block"):element(recipe.beacons):tooltip("helmod_recipe-edition-panel.current-beacon")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "block"):sprite("menu", defines.sprites.expand_right.black, defines.sprites.expand_right.black):style("helmod_button_menu_sm"):tooltip(tooltip_apply_block))
        
        local tooltip_line = GuiTooltipBeacons("helmod_recipe-edition-panel.apply-line"):element(recipe.beacons):tooltip("helmod_recipe-edition-panel.current-beacon")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "line"):sprite("menu", defines.sprites.expand_right_group.black, defines.sprites.expand_right_group.black):style("helmod_button_menu_sm"):tooltip(tooltip_line))

        local options_panel = GuiElement.add(tool_action_panel, GuiFlowH("tool3"))
        options_panel.style.horizontal_spacing = tool_spacing
        local button_style = "helmod_button_menu_sm_bold"
        local selected_button_style = "helmod_button_menu_sm_bold_selected"
        local default_beacon_mode = User.getParameter("default_beacon_mode")
        local all_button_style = button_style
        local tooltip = { "helmod_recipe-edition-panel.apply-option-category" }
        if default_beacon_mode ~= "category" then
            all_button_style = selected_button_style
            tooltip = { "helmod_recipe-edition-panel.apply-option-all" }
        end
        GuiElement.add(options_panel, GuiButton(self.classname, "beacon-tool", model.id, block.id, recipe.id, "category"):caption("A"):style(all_button_style):tooltip(tooltip))

        local selection_panel = GuiElement.add(tool_action_panel, GuiFlowH("tool2"))
        selection_panel.style.horizontal_spacing = tool_spacing

        local current_beacon_selection = User.getParameter("current_beacon_selection") or 1
        GuiElement.add(selection_panel,  GuiButton(self.classname, "beacon-remove", model.id, block.id, recipe.id):sprite("menu", defines.sprites.remove.black, defines.sprites.remove.black):style("helmod_button_menu_sm"):tooltip({"helmod_recipe-edition-panel.remove-beacon" }))
        GuiElement.add(selection_panel, GuiButton(self.classname, "beacon-add", model.id, block.id, recipe.id):sprite("menu", defines.sprites.add.black, defines.sprites.add.black):style("helmod_button_menu_sm"):tooltip({"helmod_recipe-edition-panel.add-beacon" }))
        for key, beacon in pairs(recipe.beacons) do
            local style = "helmod_button_menu_sm_bold"
            if current_beacon_selection == key then
                style = "helmod_button_menu_sm_bold_selected"
            end
            GuiElement.add(selection_panel, GuiButton(self.classname, "beacon-select", model.id, block.id, recipe.id, key):caption(key):style(style):tooltip(GuiTooltipFactory("tooltip.info-beacon"):element(beacon)))
        end
    end
end

-------------------------------------------------------------------------------
---Update modules information
---@param event LuaEvent
function RecipeEdition:updateBeaconModulesActive(event)
    if not (self:isOpened()) then return end
    local tool_panel, module_panel = self:getBeaconModulePanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        local beacon = ModelBuilder.getCurrentBeacon(recipe)

        tool_panel.clear()
        GuiElement.add(tool_panel, GuiLabel("module_label"):caption({ "helmod_recipe-edition-panel.current-modules" }):style("helmod_label_title_frame"))

        ---module tool
        local tool_action_panel = GuiElement.add(tool_panel, GuiFlowH("tool-action"))
        tool_action_panel.style.horizontal_spacing = 10
        tool_action_panel.style.bottom_padding = 10
        local tool_panel1 = GuiElement.add(tool_action_panel, GuiFlowH("tool1"))
        tool_panel1.style.horizontal_spacing = tool_spacing
        
        local tooltip_block = GuiTooltipPriorities("helmod_recipe-edition-panel.apply-block"):element(recipe.beacons):tooltip("helmod_recipe-edition-panel.current-module")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "block"):sprite("menu", defines.sprites.expand_right.black, defines.sprites.expand_right.black):style("helmod_button_menu_sm"):tooltip(tooltip_block))
        
        local tooltip_line = GuiTooltipPriorities("helmod_recipe-edition-panel.apply-line"):element(recipe.beacons):tooltip("helmod_recipe-edition-panel.current-module")
        GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "line"):sprite("menu", defines.sprites.expand_right_group.black, defines.sprites.expand_right_group.black):style("helmod_button_menu_sm"):tooltip(tooltip_line))
        local tooltip_block = GuiTooltipPriority("helmod_recipe-edition-panel.module-clear"):element(beacon.module_priority)
        GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-tool", model.id, block.id, recipe.id, "erase"):sprite("menu", defines.sprites.eraser.black, defines.sprites.eraser.black):style("helmod_button_menu_sm"):tooltip(tooltip_block))

        if Player.hasFeatureQuality() then
            local beacon_module_quality = User.getParameter("beacon_module_quality")or "normal"
            local quality_panel = GuiElement.addQualitySelector(tool_panel, beacon_module_quality, self.classname, "beacon-module-quality-select", model.id, block.id, recipe.id)
            quality_panel.style.bottom_margin = 5
        end

        ---actived modules panel
        local module_table = GuiElement.add(tool_panel, GuiTable("modules"):column(6):style("helmod_table_recipe_modules"))
        local control_info = "module-remove"
        for _, module in pairs(beacon.modules) do
            if type(module) == "table" then
                local module_cell = GuiElement.add(module_table, GuiFlowH("module-cell", module.name, module.quality))
                local tooltip = GuiTooltipModule("tooltip.remove-module"):element({ type = "item", name = module.name, quality = module.quality }):withControlInfo(control_info)
                GuiElement.add(module_cell, GuiButtonSelectSprite(self.classname, "beacon-module-remove", model.id, block.id, recipe.id):sprite_with_quality("item", module.name, module.quality):tooltip(tooltip))
                GuiElement.add(module_cell, GuiLabel("module-amount"):caption({ "", "x", module.amount }))
            end
        end
    end
end

-------------------------------------------------------------------------------
---Update modules information
---@param event LuaEvent
function RecipeEdition:updateBeaconModules(event)
    if not (self:isOpened()) then return end
    local tool_panel, module_panel = self:getBeaconModulePanel()
    local model, block, recipe = self:getParameterObjects()
    if recipe ~= nil then
        module_panel.clear()

        local beacon_switch_priority = User.getParameter("beacon_switch_priority")
        local element_state = "left"
        if beacon_switch_priority == true then element_state = "right" end
        local factory_switch_module = GuiElement.add(module_panel, GuiSwitch(self.classname, "beacon-switch-module", model.id, block.id, recipe.id):state(element_state):leftLabel({ "helmod_recipe-edition-panel.selection-modules" }):rightLabel({ "helmod_label.priority-modules" }))
        if beacon_switch_priority == true then
            ---module priority
            self:updateBeaconModulesPriority(module_panel)
        else
            ---module selector
            self:updateBeaconModulesSelector(module_panel)
        end
    end
end

-------------------------------------------------------------------------------
---Update modules priority
---@param beacon_module_panel LuaGuiElement
function RecipeEdition:updateBeaconModulesPriority(beacon_module_panel)
    local model, block, recipe = self:getParameterObjects()
    local beacon = ModelBuilder.getCurrentBeacon(recipe)
    ---module priority
    local beacon_module_priority = User.getParameter("beacon_module_priority") or 1
    local priority_modules = User.getParameter("priority_modules") or {}
    local beacon_module_quality = User.getParameter("beacon_module_quality") or "normal"

    ---configuration select
    local tool_action_panel2 = GuiElement.add(beacon_module_panel, GuiFlowH("tool-action2"))
    tool_action_panel2.style.horizontal_spacing = 10
    tool_action_panel2.style.bottom_padding = 10

    local tool_panel1 = GuiElement.add(tool_action_panel2, GuiFlowH("tool1"))
    tool_panel1.style.horizontal_spacing = tool_spacing
    local button_style = "helmod_button_small_bold"
    GuiElement.add(tool_panel1, GuiButton("HMPreferenceEdition", "OPEN", "priority_module"):sprite("menu", defines.sprites.process.black, defines.sprites.process.black):style("helmod_button_menu_sm"):tooltip({ "helmod_button.preferences" }))
    GuiElement.add(tool_panel1, GuiButton(self.classname, "beacon-module-priority-apply", model.id, block.id, recipe.id, beacon_module_quality):sprite("menu", defines.sprites.arrow_top.black, defines.sprites.arrow_top.black):style("helmod_button_menu_sm"):tooltip({"helmod_recipe-edition-panel.apply-priority" }))

    local tool_panel2 = GuiElement.add(tool_action_panel2, GuiTable("tool2"):column(6))
    for i, priority_module in pairs(priority_modules) do
        local button_style2 = button_style
        if beacon_module_priority == i then button_style2 = "helmod_button_small_bold_selected" end
        GuiElement.add(tool_panel2, GuiButton(self.classname, "beacon-module-priority-select", model.id, block.id, recipe.id, i):caption(i):style(button_style2))
    end

    ---module priority info
    local priority_table_panel = GuiElement.add(beacon_module_panel, GuiTable("module-priority-table"):column(2))
    if priority_modules[beacon_module_priority] ~= nil then
        local control_info = "module-add"
        for index, element in pairs(priority_modules[beacon_module_priority]) do
            local color = nil
            local tooltip = GuiTooltipModule("tooltip.add-module"):element({ type = "item", name = element.name, quality = beacon_module_quality }):withControlInfo(control_info)
            local module = ItemPrototype(element.name)
            if Player.checkBeaconLimitationModule(beacon, recipe, module:native()) == false then
                local limitation_message = Player.getBeaconLimitationModuleMessage(beacon, recipe, module:native());

                if limitation_message ~= nil then
                    tooltip = limitation_message
                else
                    tooltip = ""
                end
                color = GuiElement.color_button_rest
            end
            GuiElement.add(priority_table_panel, GuiButtonSelectSprite(self.classname, "beacon-module-select", model.id, block.id, recipe.id):sprite_with_quality("entity", element.name, beacon_module_quality):color(color):index(index):tooltip(tooltip))
            GuiElement.add(priority_table_panel, GuiLabel("priority-value", index):caption({ "", "x", element.value }))
        end
    end
end

-------------------------------------------------------------------------------
---Update modules selector
---@param beacon_module_panel LuaGuiElement
function RecipeEdition:updateBeaconModulesSelector(beacon_module_panel)
    local model, block, recipe = self:getParameterObjects()
    local beacon = ModelBuilder.getCurrentBeacon(recipe)
    local beacon_module_quality = User.getParameter("beacon_module_quality") or "normal"
    local module_scroll = GuiElement.add(beacon_module_panel, GuiScroll("module-selector-scroll"))
    module_scroll.style.maximal_height = 118
    local module_table_panel = GuiElement.add(module_scroll, GuiTable("module-selector-table"):column(6))
    for k, element in pairs(Player.getModules()) do
        local control_info = "module-add"
        local tooltip = GuiTooltipModule("tooltip.add-module"):element({ type = "item", name = element.name }):withControlInfo(control_info)
        local module = ItemPrototype(element.name)
        if Player.checkBeaconLimitationModule(beacon, recipe, module:native()) == true then
            GuiElement.add(module_table_panel, GuiButtonSelectSprite(self.classname, "beacon-module-select", model.id, block.id, recipe.id):sprite_with_quality("entity", element.name, beacon_module_quality):tooltip(tooltip))
        end
    end
end

-------------------------------------------------------------------------------
---Update header
---@param event LuaEvent
function RecipeEdition:updateHeader(event)
    self:updateObjectInfo(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function RecipeEdition:updateObjectInfo(event)
    local info_panel = self:getObjectInfoPanel()
    local model, block, recipe = self:getParameterObjects()
    if block ~= nil and recipe ~= nil then
        info_panel.clear()

        local panel = GuiElement.add(info_panel, GuiFlowH("options_panel"))
        panel.style.horizontally_stretchable = true

        local left_panel = GuiElement.add(panel, GuiFlowH("left_panel"))

        local right_panel = GuiElement.add(panel, GuiFlowH(right_name))
        right_panel.style.horizontal_spacing = 10
        right_panel.style.horizontally_stretchable = true
        right_panel.style.horizontal_align = "right"


        local group_sroll = GuiElement.add(right_panel, GuiFlowH("group_sroll"))
        group_sroll.style.horizontal_spacing = 2

        local recipe_edition_scroll_groups = self:getRecipeEditionScrollGroups()
        if recipe_edition_scroll_groups == true then
            GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "false"):sprite("menu", defines.sprites.two_rows.black, defines.sprites.two_rows.black):style("helmod_button_menu_sm"))
            GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "true"):sprite("menu", defines.sprites.three_rows.black, defines.sprites.three_rows.black):style("helmod_button_menu_sm_selected"))
        else
            GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "false"):sprite("menu", defines.sprites.two_rows.black, defines.sprites.two_rows.black):style("helmod_button_menu_sm_selected"))
            GuiElement.add(group_sroll, GuiButton(self.classname, "change-sroll-groups", "true"):sprite("menu", defines.sprites.three_rows.black, defines.sprites.three_rows.black):style("helmod_button_menu_sm"))
        end

        local recipe_prototype = RecipePrototype(recipe)
        local recipe_table = GuiElement.add(left_panel, GuiTable("list-data"):column(4))
        recipe_table.style.horizontally_stretchable = false
        recipe_table.style.horizontal_spacing = 10
        recipe_table.vertical_centering = false

        GuiElement.add(recipe_table, GuiLabel("header-recipe"):caption({ "helmod_result-panel.col-header-recipe" }))
        GuiElement.add(recipe_table, GuiLabel("header-duration"):caption({ "helmod_result-panel.col-header-duration" }))
        GuiElement.add(recipe_table, GuiLabel("header-products"):caption({ "helmod_result-panel.col-header-products" }))
        GuiElement.add(recipe_table, GuiLabel("header-ingredients"):caption({ "helmod_result-panel.col-header-ingredients" }))
        local cell_recipe = GuiElement.add(recipe_table, GuiFrameH("recipe", recipe.id):style(helmod_frame_style.hidden))
        GuiElement.add(cell_recipe, GuiCellRecipe(self.classname, "do_noting"):element(recipe):tooltip("helmod_common.recipe"):color("gray"))


        ---duration
        local cell_duration = GuiElement.add(recipe_table, GuiFrameH("duration", recipe.id):style(helmod_frame_style.hidden))
        local element_duration = { 
            name = "helmod_button_menu_flat",
            hovered = defines.sprites.time.white,
            sprite = defines.sprites.time.white,
            count = recipe_prototype:getEnergy(recipe.factory),
            localised_name = "helmod_label.duration"
        }
        GuiElement.add(cell_duration, GuiCellProduct(self.classname, "do_noting"):element(element_duration):tooltip("tooltip.product"):color("gray"))

        ---products
        local cell_products = GuiElement.add(recipe_table,
            GuiTable("products", recipe.id):column(3):style("helmod_table_element"))
        local lua_products = recipe_prototype:getProducts(recipe.factory)
        if lua_products ~= nil then
            for index, lua_product in pairs(lua_products) do
                local product_prototype = Product(lua_product)
                local product = product_prototype:clone()
                product.count = product_prototype:getElementAmount()
                GuiElement.add(cell_products, GuiCellProductSm(self.classname, "do_noting"):element(product):tooltip("tooltip.product"):index(index):color(GuiElement.color_button_none))
            end
        end

        ---ingredients
        local cell_ingredients = GuiElement.add(recipe_table,
            GuiTable("ingredients", recipe.id):column(5):style("helmod_table_element"))
        local lua_ingredients = recipe_prototype:getIngredients(recipe.factory)
        if lua_ingredients ~= nil then
            for index, lua_ingredient in pairs(lua_ingredients) do
                local ingredient_prototype = Product(lua_ingredient)
                local ingredient = ingredient_prototype:clone()
                ingredient.count = ingredient_prototype:getElementAmount()
                GuiElement.add(cell_ingredients, GuiCellProductSm(self.classname, "do_noting"):element(ingredient):tooltip("tooltip.ingredient"):index(index):color(GuiElement.color_button_add))
            end
        end

        local tablePanel = GuiElement.add(info_panel, GuiTable("table-input"):column(2))
        -- if Player.hasFeatureQuality() then
        --     GuiElement.add(tablePanel, GuiLabel("label-quality"):caption({ "helmod_label.quality" }))
        --     local current_quality = recipe.quality or "normal"
        --     GuiElement.addQualitySelector(tablePanel, current_quality, self.classname, "recipe-quality-select", model.id, block.id, recipe.id)
        -- end
        GuiElement.add(tablePanel, GuiLabel("label-production"):caption({ "helmod_recipe-edition-panel.production" }))
        local production_value = (recipe.production or 1) * 100
        GuiElement.add(tablePanel, GuiTextField(self.classname, "recipe-update", model.id, block.id, recipe.id):text(production_value):style("helmod_textfield"))
    end
end


