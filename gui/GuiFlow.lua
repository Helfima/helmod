-------------------------------------------------------------------------------
-- Class to help to build flow
-- 
-- @module GuiFlow
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiFlow] constructor
-- @param #arg name
-- @return #GuiFlow
--
GuiFlow = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiFlow"
  base.options.type = "flow"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiFlowH] constructor
-- @param #arg name
-- @return #GuiFlowH
--
GuiFlowH = newclass(GuiFlow,function(base,...)
  GuiFlow.init(base,...)
  base.options.direction = "horizontal"
  base.options.style = helmod_flow_style.horizontal
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiFlowV] constructor
-- @param #arg name
-- @return #GuiFlowV
--
GuiFlowV = newclass(GuiFlow,function(base,...)
  GuiFlow.init(base,...)
  base.options.direction = "vertical"
  base.options.style = helmod_flow_style.vertical
end)

