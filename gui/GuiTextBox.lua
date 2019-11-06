-------------------------------------------------------------------------------
-- Class to help to build GuiTextBox
--
-- @module GuiTextBox
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTextBox] constructor
-- @param #arg name
-- @return #GuiTextBox
--
GuiTextBox = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTextBox"
  base.options.type = "text-box"
  base.options.style = "helmod_textbox_default"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTextBox] text
-- @param #string text
-- @return #GuiTextBox
--
function GuiTextBox:text(text)
  self.options.text = text
  return self
end