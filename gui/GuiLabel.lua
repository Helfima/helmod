-------------------------------------------------------------------------------
-- Class to help to build GuiLabel
--
-- @module GuiLabel
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLabel] constructor
-- @param #arg name
-- @return #GuiLabel
--
GuiLabel = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiLabel"
  base.options.type = "label"
end)
