-------------------------------------------------------------------------------
---Class to build quality dialog
---@class QualityPanel
QualityPanel = newclass(Form)

-------------------------------------------------------------------------------
---On initialization
function QualityPanel:onInit()
    self.panelCaption = {"helmod_quality-panel.title"}
    self.otherClose = false
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function QualityPanel:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 300,
        maximal_height = height_main
    }
end

------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function QualityPanel:getButtonSprites()
    return defines.sprites.jewel.white, defines.sprites.jewel.black
end

-------------------------------------------------------------------------------
---Is tool
---@return boolean
function QualityPanel:isTool()
    return Player.hasFeatureQuality()
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function QualityPanel:onUpdate(event)
    self:updateQualityModules(event)
    self:updateQualityCalculation(event)
end

-------------------------------------------------------------------------------
---Update input
---@param event LuaEvent
function QualityPanel:updateQualityModules(event)
    local modules_panel = self:getFramePanel("modules-panel")
    modules_panel.clear()

    local analyze_module_quality = User.getParameter("analyze_module_quality") or "normal"
    local quality_panel = GuiElement.addQualitySelector(modules_panel, analyze_module_quality, self.classname, "module-quality-select")
    quality_panel.style.bottom_margin = 5

    local analyze_module_name = User.getParameter("analyze_module_name")
    local table_panel = GuiElement.add(modules_panel, GuiTable("table_panel"):column(10))
    for k, lua_module in pairs(Player.getModules()) do
        local module = { name = lua_module.name, quality = module_quality, module_effects = lua_module.module_effects }
        local effects = Player.getModuleEffects(module)
        if effects.quality > 0 then
            local style = defines.styles.button.select_icon
            if module.name == analyze_module_name then
                style = defines.styles.button.select_icon_green
            end
            local button = GuiElement.add(table_panel, GuiButtonSelectSprite(self.classname, "module-select"):choose_with_quality("item", module.name, analyze_module_quality):style(style))
            button.locked = true
        end
    end

    local table_input = GuiElement.add(modules_panel, GuiTable("table-input"):column(2))
    
    local analyze_module_amount = User.getParameter("analyze_module_amount") or 4
    GuiElement.add(table_input, GuiLabel("label-module-amount"):caption({"helmod_quality-panel.module-amount"}))
    GuiElement.add(table_input, GuiTextField(self.classname, "change-module-amount"):text(analyze_module_amount):style("helmod_textfield"))

    local analyze_bonus_probability = User.getParameter("analyze_bonus_probability") or 0
    GuiElement.add(table_input, GuiLabel("label-bonus-probability"):caption({"helmod_quality-panel.bonus-probability"}))
    GuiElement.add(table_input, GuiTextField(self.classname, "change-bonus-probability"):text(analyze_bonus_probability):style("helmod_textfield"))
end

-------------------------------------------------------------------------------
---Update history
---@param event LuaEvent
function QualityPanel:updateQualityCalculation(event)
    local modules_panel = self:getFramePanel("calculation-panel")
    modules_panel.clear()

    local default_module = nil
    local modules = Player.getModules()
    for key, lua_module in pairs(modules) do
        local module = { name = lua_module.name, quality = "normal", module_effects = lua_module.module_effects }
        local effects = Player.getModuleEffects(module)
        if effects.quality > 0 then
            default_module = lua_module
            break
        end
    end
    local default_module_name = default_module.name

    local style = defines.styles.button.select_icon_flat

    local qualities = Player.getQualityPrototypesWithoutHidden()
    local analyze_module_quality = User.getParameter("analyze_module_quality") or "normal"
    local analyze_module_name = User.getParameter("analyze_module_name") or default_module_name
    local analyze_module_amount = User.getParameter("analyze_module_amount") or 4
    local analyze_bonus_probability = User.getParameter("analyze_bonus_probability") or 0
    local module_effects = Player.getModuleEffects({type="item", name=analyze_module_name, quality=analyze_module_quality, amount=analyze_module_amount})
    local quality_effect = analyze_bonus_probability/100 + module_effects.quality * analyze_module_amount
    
    local column_count = table.size(qualities) + 2
    local table_percent = GuiElement.add(modules_panel, GuiTable("table-percent"):column(column_count):style("helmod_table_border"))
    GuiElement.add(table_percent, GuiLabel("label-module"):caption({"helmod_quality-panel.percent-value", tostring(quality_effect * 100)}))
    for key, lua_quality in pairs(qualities) do
        GuiElement.add(table_percent, GuiButton("column", lua_quality.name):sprite("quality", lua_quality.name):style(style):tooltip(lua_quality.localised_name))
    end
    GuiElement.add(table_percent, GuiLabel("label-total"):caption({"helmod_quality-panel.total-control"}))

    for row_key, lua_quality in pairs(qualities) do
        GuiElement.add(table_percent, GuiButton("row", lua_quality.name):sprite("quality", lua_quality.name):style(style):tooltip(lua_quality.localised_name))

        local results = ModelCompute.computeQualityProbability(lua_quality, quality_effect)
        local quality_map = {}
        local total = 0
        for _, result in pairs(results) do
            quality_map[result.name] = result
            total = total + result.probability
        end
        for col_key, lua_quality in pairs(qualities) do
            if quality_map[lua_quality.name] then
                local result = quality_map[lua_quality.name]
                GuiElement.add(table_percent, GuiLabel("value", row_key, col_key):caption({"helmod_quality-panel.percent-value", tostring(result.probability * 100)}))
            else
                GuiElement.add(table_percent, GuiFlow())
            end
        end
        GuiElement.add(table_percent, GuiLabel("total", row_key):caption({"helmod_quality-panel.percent-value", tostring(total * 100)}))
    end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function QualityPanel:onEvent(event)
    if event.action == "module-select" then
        local analyze_module_name = event.item1
        User.setParameter("analyze_module_name", analyze_module_name)
        self:onUpdate(event)
    end

    if event.action == "module-quality-select" then
        local analyze_module_quality = event.item1
        User.setParameter("analyze_module_quality", analyze_module_quality)
        self:onUpdate(event)
    end

    if event.action == "change-module-amount" then
        local text = event.element.text
        local analyze_module_amount = formula(text)
        User.setParameter("analyze_module_amount", analyze_module_amount)
        self:onUpdate(event)
    end

    if event.action == "change-bonus-probability" then
        local text = event.element.text
        local analyze_bonus_probability = formula(text)
        User.setParameter("analyze_bonus_probability", analyze_bonus_probability)
        self:onUpdate(event)
    end
end
