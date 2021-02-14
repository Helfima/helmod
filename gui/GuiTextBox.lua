-------------------------------------------------------------------------------
---Class to help to build GuiTextBox
---@class GuiTextBox
GuiTextBox = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTextBox"
  base.options.type = "text-box"
  base.options.style = "helmod_textbox_default"
end)

-------------------------------------------------------------------------------
---Set text
---@param text string
---@return GuiTextBox
function GuiTextBox:text(text)
  self.options.text = text
  return self
end