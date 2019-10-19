-------------------------------------------------------------------------------
-- Class to help to build GuiTextField
--
-- @module GuiTextField
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTextField] constructor
-- @param #arg name
-- @return #GuiTextField
--
GuiTextField = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTextField"
  base.options.type = "textfield"
  base.options.style = "helmod_textfield"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTextField] text
-- @param #string text
-- @return #GuiTextField
--
function GuiTextField:text(text)
  self.options.text = text
  return self
end