-------------------------------------------------------------------------------
---Class to help to build GuiButton
---@class GuiTreeView : GuiCell
---@field font_link table
GuiTreeView = newclass(GuiCell, function(base, ...)
    GuiCell.init(base, ...)
    --base.classname = "HMGuiTreeView"
    base.font_link = {}
    base._offset_previous = 16
end)

-------------------------------------------------------------------------------
---Set expanded
---@return GuiTreeView
function GuiTreeView:expanded(is_expanded)
  self.m_expanded = is_expanded
  return self
end

function GuiTreeView:bind()
    local options = self:getOptions()
    --self.classname = options.name
    Dispatcher.views[options.name] = self
    Dispatcher:unbind(defines.mod.events.on_gui_event, self)
    Dispatcher:bind(defines.mod.events.on_gui_event, self, self.event)
end

-------------------------------------------------------------------------------
---Set color
---@param font_color table
---@param hovered_font_color? table
---@return GuiTreeView
function GuiTreeView:font_color(font_color, hovered_font_color)
    self.font_link.font_color = font_color
    self.font_link.hovered_font_color = hovered_font_color
    return self
end

-------------------------------------------------------------------------------
---Set offset previous
---@param offset number
---@return GuiTreeView
function GuiTreeView:offset_previous(offset)
    self._offset_previous = offset
    return self
end

-------------------------------------------------------------------------------
---Set data source
---@param source table
---@return GuiTreeView
function GuiTreeView:source(source)
    self.data_source = source
    return self
end

-------------------------------------------------------------------------------
---Class decorator
---@param class_decorator table
---@return GuiTreeView
function GuiTreeView:class_decorator(class_decorator)
    self._class_decorator = class_decorator
    return self
end

-------------------------------------------------------------------------------
---Item decorator
---@param function_decorator function
---@return GuiTreeView
function GuiTreeView:item_decorator(function_decorator)
    self._item_decorator = function_decorator
    return self
end

-------------------------------------------------------------------------------
---Item decorator
---@param function_item_changed function
---@return GuiTreeView
function GuiTreeView:item_changed(function_item_changed)
    self._on_item_changed = function_item_changed
    return self
end

-------------------------------------------------------------------------------
---On item changed
---@param tree_node table
function GuiTreeView:on_item_changed(tree_node, is_expanded)
    tree_node.expanded = is_expanded
    if self._on_item_changed ~= nil then
        if self._class_decorator ~= nil then
            self._on_item_changed(self._class_decorator, tree_node)
        else
            self._on_item_changed(tree_node)
        end
    end
end

-------------------------------------------------------------------------------
---Create item
---@param parent LuaGuiElement --container for element
---@param root_node table
---@param tree_node table
function GuiTreeView:create_item(parent, root_node, tree_node)
    if self._item_decorator ~= nil then
        if self._class_decorator ~= nil then
            self._item_decorator(self._class_decorator, parent, root_node, tree_node)
        else
            self._item_decorator(parent, root_node, tree_node)
        end
    else
        local header = tree_node.header or ""
        local caption = { "", defines.mod.tags.font.default_bold, defines.mod.tags.color.gold, header, defines.mod.tags.color.close, defines.mod.tags.font.close }
        GuiElement.add(parent, GuiLabel("header-caption"):caption(caption))
    end
end

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return GuiTreeView
function GuiTreeView:create(parent)
    self:bind()
    local root_branch = GuiElement.add(parent, GuiFlowV())
    root_branch.style.vertically_stretchable = false
    self:create_tree(root_branch, self.data_source, self.data_source)
    return self
end

-------------------------------------------------------------------------------
---Create Tree
---@param parent LuaGuiElement
---@param root_node table
---@param current_node table
function GuiTreeView:create_tree(parent, root_node, current_node)
    if current_node == nil then
        return
    end
    local index = 0
    for _, tree_node in pairs(current_node.children) do
        index = index + 1
        local tree_branch = GuiElement.add(parent, GuiFlowH())
        -- vertical bar
        local tree_control = GuiElement.add(tree_branch, GuiFlowV("control"))
        tree_control.style.width = 16
        tree_control.style.margin = 0
        tree_control.style.padding = 0

        if self._offset_previous > 0 then
            local tree_control_previous = GuiElement.add(tree_control, GuiSprite("previous"):sprite("menu", defines.sprites.branch_next.blue))
            tree_control_previous.resize_to_sprite = false
            tree_control_previous.style.width = 16
            tree_control_previous.style.height = self._offset_previous
        end

        if tree_node.children == nil or #tree_node.children == 0 then
            if index == #current_node.children then
                local tree_control_action = GuiElement.add(tree_control, GuiSprite("action"):sprite("menu", defines.sprites.branch_end.blue))
                tree_control_action.resize_to_sprite = false
                tree_control_action.style.width = 16
                tree_control_action.style.height = 16
            else
                local tree_control_action = GuiElement.add(tree_control, GuiSprite("action"):sprite("menu", defines.sprites.branch.blue))
                tree_control_action.resize_to_sprite = false
                tree_control_action.style.width = 16
                tree_control_action.style.height = 16
                local tree_control_next = GuiElement.add(tree_control, GuiSprite("next"):sprite("menu", defines.sprites.branch_next.blue))
                tree_control_next.resize_to_sprite = false
                tree_control_next.style.width = 16
                tree_control_next.style.vertically_stretchable = true
            end
        else
            if tree_node.expanded then
                GuiElement.add(tree_control, GuiButtonSpriteSm(self.classname, "tree-view-expand-or-collapse", "bypass"):sprite("menu", defines.sprites.collapse.gray, defines.sprites.collapse.black)
                    :tags({ value = tree_node }))
            else
                GuiElement.add(tree_control, GuiButtonSpriteSm(self.classname, "tree-view-expand-or-collapse", "bypass"):sprite("menu", defines.sprites.expand.gray, defines.sprites.expand.black)
                    :tags({ value = tree_node }))
            end
            if index < #current_node.children then
                local tree_control_next = GuiElement.add(tree_control, GuiSprite("next"):sprite("menu", defines.sprites.branch_next.blue))
                tree_control_next.resize_to_sprite = false
                tree_control_next.style.width = 16
                tree_control_next.style.vertically_stretchable = true
            end
        end
        
        -- content
        local content_branch = GuiElement.add(tree_branch, GuiFlowV("content"))
        -- header
        local header = GuiElement.add(content_branch, GuiFlowH("header"))
        self:create_item(header, root_node, tree_node)
        -- next
        local next = GuiElement.add(content_branch, GuiFlowV("next"))

        if tree_node.expanded and tree_node.children ~= nil and #tree_node.children > 0 then
            self:create_tree(next, root_node, tree_node)
        end
        
    end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function GuiTreeView:event(event)
    if event.action == "tree-view-expand-or-collapse" then
        local element = event.element
        local content = element.parent.parent.content
        local parent_next = content.next
        local tree_node = element.tags.value
        if #parent_next.children > 0 then
            element.sprite = GuiElement.getSprite(defines.sprites.expand.gray)
            for _, child in pairs(parent_next.children) do
                child.destroy()
            end
            parent_next.visible = false
            self:on_item_changed(tree_node, false)
        else
            element.sprite = GuiElement.getSprite(defines.sprites.collapse.gray)
            parent_next.visible = true
            self:create_tree(parent_next, self.data_source, tree_node)
            self:on_item_changed(tree_node, true)
        end
    end
end

