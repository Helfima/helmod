-------------------------------------------------------------------------------
---Class to help to build GuiCheckBox
---@class GuiCheckBox
GuiCheckBox = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiCheckBox"
  base.options.type = "checkbox"
  --base.options.style = "helmod_textbox_default"
end)

-------------------------------------------------------------------------------
---Set state
---@param state boolean
---@return GuiCheckBox
function GuiCheckBox:state(state)
  self.options.state = state
  return self
end