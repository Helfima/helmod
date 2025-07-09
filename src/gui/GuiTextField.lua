-------------------------------------------------------------------------------
---Class to help to build GuiTextField
---@class GuiTextField
GuiTextField = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTextField"
  base.options.type = "textfield"
  base.options.style = "helmod_textfield"
end)

-------------------------------------------------------------------------------
---Set text
---@param text string
---@return GuiTextField
function GuiTextField:text(text)
  self.options.text = text
  return self
end

-------------------------------------------------------------------------------
---Set is numeric
---@return GuiTextField
function GuiTextField:isNumeric()
  self.options.numeric = true
  return self
end

-------------------------------------------------------------------------------
---Set allow decimal
---@return GuiTextField
function GuiTextField:allowDecimal ()
  self.options.allow_decimal = true
  return self
end

-------------------------------------------------------------------------------
---Set allow negative
---@return GuiTextField
function GuiTextField:allowNegative ()
  self.options.allow_negative = true
  return self
end