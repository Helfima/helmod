-------------------------------------------------------------------------------
---Class to help to build GuiSwitch
---@class GuiSwitch
GuiSwitch = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "GuiSwitch"
  base.options.type = "switch"
end)

-------------------------------------------------------------------------------
---Set state
---@param switch_state any
---@param allow_none_state any
---@return GuiSwitch
function GuiSwitch:state(switch_state, allow_none_state)
  self.options.switch_state = switch_state
  self.options.allow_none_state = allow_none_state
  return self
end

-------------------------------------------------------------------------------
---Set label
---@param left_label_caption any
---@param left_label_tooltip any
---@return GuiSwitch
function GuiSwitch:leftLabel(left_label_caption, left_label_tooltip)
  self.options.left_label_caption = left_label_caption
  self.options.left_label_tooltip = left_label_tooltip
  return self
end

-------------------------------------------------------------------------------
---Set label
---@param right_label_caption any
---@param right_label_tooltip any
---@return GuiSwitch
function GuiSwitch:rightLabel(right_label_caption, right_label_tooltip)
  self.options.right_label_caption = right_label_caption
  self.options.right_label_tooltip = right_label_tooltip
  return self
end