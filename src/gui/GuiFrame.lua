-------------------------------------------------------------------------------
---Class to help to build frame
---@class GuiFrame
GuiFrame = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiFrame"
  base.options.type = "frame"
  base.options.style = "helmod_frame"
end)

-------------------------------------------------------------------------------
---@class GuiFrameH
GuiFrameH = newclass(GuiFrame,function(base,...)
  GuiFrame.init(base,...)
  base.options.direction = "horizontal"
end)

-------------------------------------------------------------------------------
---@class GuiFrameV
GuiFrameV = newclass(GuiFrame,function(base,...)
  GuiFrame.init(base,...)
  base.options.direction = "vertical"
end)

