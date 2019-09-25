-------------------------------------------------------------------------------
-- Class to help to build GuiTab
--
-- @module GuiTab
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTab] constructor
-- @param #arg name
-- @return #GuiTab
--
GuiTabPane = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTabPane"
  base.options.type = "tabbed-pane"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTab] constructor
-- @param #arg name
-- @return #GuiTab
--
GuiTab = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTab"
  base.options.type = "tab"
end)

