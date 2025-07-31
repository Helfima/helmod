-------------------------------------------------------------------------------
---Class to help to build GuiEmptyWidget
---@class GuiEmptyWidget : Form
GuiEmptyWidget = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiEmptyWidget"
  base.options.type = "empty-widget"
end)

