-------------------------------------------------------------------------------
---Class to help to build GuiLine
---@class GuiLine
GuiLine = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiLine"
  base.options.type = "line"
  base.options.style = "line"
end)

-------------------------------------------------------------------------------
---@class GuiLineH
GuiLineH = newclass(GuiLine,function(base,...)
  GuiLine.init(base,...)
  base.options.direction = "horizontal"
end)

-------------------------------------------------------------------------------
---@class GuiLineV
GuiLineV = newclass(GuiLine,function(base,...)
  GuiLine.init(base,...)
  base.options.direction = "vertical"
end)
