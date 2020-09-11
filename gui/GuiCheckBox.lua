-------------------------------------------------------------------------------
-- Class to help to build GuiCheckBox
--
-- @module GuiCheckBox
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCheckBox] constructor
-- @param #arg name
-- @return #GuiCheckBox
--
GuiCheckBox = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiCheckBox"
  base.options.type = "checkbox"
  --base.options.style = "helmod_textbox_default"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCheckBox] state
-- @param #boolean state
-- @return #GuiCheckBox
--
function GuiCheckBox:state(state)
  self.options.state = state
  return self
end