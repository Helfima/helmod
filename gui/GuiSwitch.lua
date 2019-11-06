-------------------------------------------------------------------------------
-- Class to help to build GuiSwitch
--
-- @module GuiSwitch
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSwitch] constructor
-- @param #arg name
-- @return #GuiSwitch
--
GuiSwitch = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "GuiSwitch"
  base.options.type = "switch"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSwitch] state
-- @param #string switch_state
-- @param #boolean allow_none_state
-- @return #GuiSwitch
--
function GuiSwitch:state(switch_state, allow_none_state)
  self.options.switch_state = switch_state
  self.options.allow_none_state = allow_none_state
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSwitch] leftLabel
-- @param #string left_label_caption
-- @param #string left_label_tooltip
-- @return #GuiSwitch
--
function GuiSwitch:leftLabel(left_label_caption, left_label_tooltip)
  self.options.left_label_caption = left_label_caption
  self.options.left_label_tooltip = left_label_tooltip
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSwitch] rightLabel
-- @param #string right_label_caption
-- @param #string right_label_tooltip
-- @return #GuiSwitch
--
function GuiSwitch:rightLabel(right_label_caption, right_label_tooltip)
  self.options.right_label_caption = right_label_caption
  self.options.right_label_tooltip = right_label_tooltip
  return self
end