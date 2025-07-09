-------------------------------------------------------------------------------
---Class to help to build flow
---@class GuiFlow
GuiFlow = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiFlow"
  base.options.type = "flow"
end)

-------------------------------------------------------------------------------
---@class GuiFlowH
GuiFlowH = newclass(GuiFlow,function(base,...)
  GuiFlow.init(base,...)
  base.options.direction = "horizontal"
  base.options.style = helmod_flow_style.horizontal
end)

-------------------------------------------------------------------------------
---@class GuiFlowV
GuiFlowV = newclass(GuiFlow,function(base,...)
  GuiFlow.init(base,...)
  base.options.direction = "vertical"
  base.options.style = helmod_flow_style.vertical
end)