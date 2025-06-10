-------------------------------------------------------------------------------
--- Class to help to build GuiProgressBar
---@class GuiProgressBar : GuiElement
GuiProgressBar = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiProgressBar"
  base.options.type = "progressbar"
  base.options.style = "production_progressbar"
end)

-------------------------------------------------------------------------------
---Set wrap
---@param value double
---@return GuiProgressBar
function GuiProgressBar:value(value)
  self.options.value = value
  return self
end