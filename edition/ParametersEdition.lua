-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class ParametersEdition
ParametersEdition = newclass(FormModel)

-------------------------------------------------------------------------------
---On initialization
function ParametersEdition:onInit()
    self.panelCaption = ({ "helmod_parameters_edition_panel.title" })
    self.panel_close_before_main = true
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function ParametersEdition:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 100,
        maximal_height = math.max(height_main, 600),
    }
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function ParametersEdition:onBind()
    Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function ParametersEdition:onUpdate(event)
    self:updateEffects(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function ParametersEdition:updateEffects(event)
    local model, block, recipe = self:getParameterObjects()
    local info_panel = self:getFramePanel("effects")
    info_panel.clear()

    GuiElement.add(info_panel,
        GuiLabel("label-info"):caption({ "helmod_parameters_edition_panel.global_bonus" }):style("helmod_label_title_frame"))

    local block_table = GuiElement.add(info_panel, GuiTable("output-table"):column(2))

    Model.appendParameters(model)

    local effects = model.parameters.effects
    GuiElement.add(block_table, GuiLabel("label-consumption"):caption({ "description.consumption-bonus" }))
    GuiElement.add(block_table, GuiTextField(self.classname, "change-effect", "consumption"):text(Format.formatNumberElement((effects.consumption or 1)*100)):style("helmod_textfield"))

    GuiElement.add(block_table, GuiLabel("label-speed"):caption({ "description.speed-bonus" }))
    GuiElement.add(block_table, GuiTextField(self.classname, "change-effect", "speed"):text(Format.formatNumberElement((effects.speed or 1)*100)):style("helmod_textfield"))

    GuiElement.add(block_table, GuiLabel("label-productivity"):caption({ "description.productivity-bonus" }))
    GuiElement.add(block_table, GuiTextField(self.classname, "change-effect", "productivity"):text(Format.formatNumberElement((effects.productivity or 1)*100)):style("helmod_textfield"))

    GuiElement.add(block_table, GuiLabel("label-pollution"):caption({ "description.pollution-bonus" }))
    GuiElement.add(block_table, GuiTextField(self.classname, "change-effect", "pollution"):text(Format.formatNumberElement((effects.pollution or 1)*100)):style("helmod_textfield"))

end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function ParametersEdition:onEvent(event)
    local model = self:getParameterObjects()
    if User.isWriter(model) then
        if event.action == "change-effect" then
            local text = event.element.text
            local value = (formula(text) or 0)/100
            local effect_name = event.item1
            local effects = model.parameters.effects
            effects[effect_name]=value
            ModelCompute.update(model)
            Controller:send("on_gui_refresh", event)
        end
    end
end
