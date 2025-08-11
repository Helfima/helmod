-------------------------------------------------------------------------------
---Class to help to build GuiButton
---@class GuiTree : GuiCell
---@field font_link table
GuiTree = newclass(GuiCell, function(base, ...)
    GuiCell.init(base, ...)
    --base.classname = "HMGuiTree"
    base.font_link = {}
end)

-------------------------------------------------------------------------------
---Set expanded
---@return GuiTree
function GuiTree:expanded(is_expanded)
  self.m_expanded = is_expanded
  return self
end

local is_expanded = false

function GuiTree:bind()
    is_expanded = false
    local options = self:getOptions()
    --self.classname = options.name
    Dispatcher.views[options.name] = self
    Dispatcher:unbind(defines.mod.events.on_gui_event, self)
    Dispatcher:bind(defines.mod.events.on_gui_event, self, self.event)
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function GuiTree:event(event)
    if event.action == "create-tree" then
        local element = event.element
        local content = element.parent
        if is_expanded then
            for _, child in pairs(content.children) do
                if child.name == "" then
                    child.destroy()
                end
            end
            is_expanded = false
        else
            self:create_tree(content, self.data_source, false)
            is_expanded = true
        end
    end
    
    if event.action == "expand-branch" then
        local element = event.element
        local content = element.parent.parent
        local parent_next = content.next
        if #parent_next.children > 0 then
            for _, child in pairs(parent_next.children) do
                child.destroy()
            end
            parent_next.visible = false
        else
            local list = element.tags.value
            parent_next.visible = true
            self:create_tree(parent_next, list)
        end
    end

    if event.action == "expand-continue" then
        local element = event.element
        local content = element.parent.parent
        local parent_next = content.parent.parent
        local list = element.tags.list
        content.parent.destroy()
        self:create_tree(parent_next, list)
    end
end

-------------------------------------------------------------------------------
---Set color
---@param font_color table
---@param hovered_font_color? table
---@return GuiTree
function GuiTree:font_color(font_color, hovered_font_color)
    self.font_link.font_color = font_color
    self.font_link.hovered_font_color = hovered_font_color
    return self
end

-------------------------------------------------------------------------------
---Set color
---@param source table
---@return GuiTree
function GuiTree:source(source)
    self.data_source = source
    return self
end

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return GuiTree
function GuiTree:create(parent)
    self:bind()
    local root_branch = GuiElement.add(parent, GuiFlowV())
    root_branch.style.vertically_stretchable = false
    GuiElement.add(root_branch, GuiLink(self.classname, "create-tree"):caption(self.m_caption):font_color(self.font_link.font_color, self.font_link.hovered_font_color))
    if self.m_expanded == true then
        self:create_tree(root_branch, self.data_source, false)
        is_expanded = true
    end
    return self
end

-------------------------------------------------------------------------------
---Create Tree
---@param parent LuaGuiElement
---@param list table
---@param expand? boolean
function GuiTree:create_tree(parent, list, expand)
    local data_info = table.data_info(list)
    local data_info_type = type(data_info)
    local index = 1
    local size = table.size(list)
    for info_key, info in pairs(data_info) do
        local tree_branch = GuiElement.add(parent, GuiFlowH())
        -- vertical bar
        local tree_control = GuiElement.add(tree_branch, GuiFlowV("control"))
        tree_control.style.width = 25
        tree_control.style.margin = 0
        tree_control.style.padding = 0

        if index == size or index > 25 then
            -- end vertical bar
            local tree_action = GuiElement.add(tree_control, GuiSprite("action"):sprite("menu", defines.sprites.branch_end.blue))
            tree_action.resize_to_sprite = false
            tree_action.style.width = 25
            tree_action.style.height = 25
        else
            -- intersect vertical
            local tree_action = GuiElement.add(tree_control, GuiSprite("action"):sprite("menu", defines.sprites.branch.blue))
            tree_action.resize_to_sprite = false
            tree_action.style.width = 25
            tree_action.style.height = 25
            -- continious vertical
            local tree_action = GuiElement.add(tree_control, GuiSprite("next"):sprite("menu", defines.sprites.branch_next.blue))
            tree_action.resize_to_sprite = false
            tree_action.style.width = 25
            tree_action.style.vertically_stretchable = true
        end
        -- content
        local content_branch = GuiElement.add(tree_branch, GuiFlowV("content"))
        -- header
        local header = GuiElement.add(content_branch, GuiFlowH("header"))
        if index > 25 then
            local caption = "More..."
            local label = GuiElement.add(header, GuiLink(self.classname, "expand-continue", "bypass"):caption(caption):font_color(self.font_link.font_color, self.font_link.hovered_font_color))
            label.tags = {list=table.slice(list, 25)}
        else
            if info.type == "table" then
                local caption = { "", "[", table.size(info.value), "]", " (", info.type, ")" }
                if table_size(info.value) == 0 then
                    GuiElement.add(header, GuiLabel("table-empty"):tags(info):caption(info_key):font_color(defines.color.gray.silver))
                    GuiElement.add(header, GuiLabel("table-info"):caption(caption))
                else
                    GuiElement.add(header, GuiLink(self.classname, "expand-branch", "bypass"):tags(info):caption(info_key):font_color(defines.color.green.lime_green))
                    GuiElement.add(header, GuiLabel(self.classname, "expand-branch", "bypass", "table-info"):tags(info):caption(caption))
                end
            else
                local caption = { "", defines.mod.tags.font.default_bold, defines.mod.tags.color.gold, info_key, defines.mod.tags.color.close, defines.mod.tags.font.close, "=", defines.mod.tags.font.default_bold, info.value, defines.mod.tags.font.close, " (", info.type, ")" }
                GuiElement.add(header, GuiLabel("global-end"):caption(caption))
            end
        end
        -- next
        local next = GuiElement.add(content_branch, GuiFlowV("next"))

        if expand and info.type == "table" then
            self:create_tree(next, info.value, false)
        else
            next.visible = false
        end
        if index > 25 then
            break
        end
        index = index + 1
    end
end