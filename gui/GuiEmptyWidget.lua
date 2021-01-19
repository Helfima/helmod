-------------------------------------------------------------------------------
-- Class to help to build GuiEmptyWidget
--
-- @module GuiEmptyWidget
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiEmptyWidget] constructor
-- @param #arg name
-- @return #GuiEmptyWidget
--
GuiEmptyWidget = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiEmptyWidget"
  base.options.type = "empty-widget"
end)

