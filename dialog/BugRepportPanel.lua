-------------------------------------------------------------------------------
---Class to build pin tab dialog
---@class BugReportPanel
BugReportPanel = newclass(Form)

-------------------------------------------------------------------------------
---On initialization
function BugReportPanel:onInit()
    self.panelCaption = ({ "helmod_bug-repport-panel.title" })
end

------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function BugReportPanel:getButtonSprites()
    return defines.sprites.property.white, defines.sprites.property.black
end

-------------------------------------------------------------------------------
---Is tool
---@return boolean
function BugReportPanel:isTool()
    return true
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function BugReportPanel:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_width = 322,
        maximal_height = height_main
    }
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function BugReportPanel:onUpdate(event)
    self:updateInfo(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function BugReportPanel:updateInfo(event)
    local info_panel = self:getFramePanel("info_panel")
    info_panel.style.vertically_stretchable = true
    info_panel.clear()

    local last_error = Player.getLastError()
    if last_error ~= nil then
        local repport = {}
        table.insert(repport,"```")
        table.insert(repport,"---- Error ----")
        table.insert(repport,last_error)
        
        table.insert(repport,"---- Feature Flags ----")
        for feature_flag, value in pairs(script.feature_flags) do
            table.insert(repport, feature_flag..":"..tostring(value))
        end
    
        table.insert(repport,"---- Mods ----")
        for name, version in pairs(script.active_mods) do
            table.insert(repport, name..":"..tostring(version))
        end
        table.insert(repport,"```")
    
        local message = table.concat(repport,"\n")
        local textbox = GuiElement.add(info_panel, GuiTextBox("bug_repport"):text(message))
    else
        GuiElement.add(info_panel, GuiLabel("no_error"):caption({"helmod_bug-repport-panel.no_error"}))
    end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function BugReportPanel:onEvent(event)
end
