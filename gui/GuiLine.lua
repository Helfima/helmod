-------------------------------------------------------------------------------
-- Class to help to build GuiLine
--
-- @module GuiLine
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLine] constructor
-- @param #arg name
-- @return #GuiLine
--
GuiLine = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiLine"
  base.options.type = "line"
  base.options.style = "line"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLine] constructor
-- @param #arg name
-- @return #GuiLineH
--
GuiLineH = newclass(GuiLine,function(base,...)
  GuiLine.init(base,...)
  base.options.direction = "horizontal"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLine] constructor
-- @param #arg name
-- @return #GuiLineV
--
GuiLineV = newclass(GuiLine,function(base,...)
  GuiLine.init(base,...)
  base.options.direction = "vertical"
end)
