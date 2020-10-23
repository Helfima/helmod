-------------------------------------------------------------------------------
-- Class to help to build frame
-- 
-- @module GuiFrame
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiFrame] constructor
-- @param #arg name
-- @return #GuiFrame
--
GuiFrame = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiFrame"
  base.options.type = "frame"
  base.options.style = "helmod_frame"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiFrameH] constructor
-- @param #arg name
-- @return #GuiFrameH
--
GuiFrameH = newclass(GuiFrame,function(base,...)
  GuiFrame.init(base,...)
  base.options.direction = "horizontal"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiFrameV] constructor
-- @param #arg name
-- @return #GuiFrameV
--
GuiFrameV = newclass(GuiFrame,function(base,...)
  GuiFrame.init(base,...)
  base.options.direction = "vertical"
end)

