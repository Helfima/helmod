-------------------------------------------------------------------------------
---Class to help to build GuiTab
---@class GuiTabPane
GuiTabPane = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTabPane"
  base.options.type = "tabbed-pane"
end)

-------------------------------------------------------------------------------
---@class GuiTab
GuiTab = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTab"
  base.options.type = "tab"
end)

