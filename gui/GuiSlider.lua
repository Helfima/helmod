-------------------------------------------------------------------------------
---Class to help to build GuiSlider
---@class GuiSlider
GuiSlider = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiSlider"
  base.options.type = "slider"
end)

-------------------------------------------------------------------------------
---Set number values
---@param minimum_value number|string
---@param maximum_value number|string
---@param value number|string
---@param value_step number
---@return GuiSlider
function GuiSlider:values(minimum_value, maximum_value, value, value_step)
  self.options.minimum_value = minimum_value
  self.options.maximum_value = maximum_value
  self.options.value = value or minimum_value
  self.options.value_step = value_step or 1
  return self
end

-------------------------------------------------------------------------------
---Set discrete values
---@param discrete_slider boolean
---@param discrete_values boolean
---@return GuiSlider
function GuiSlider:discrete(discrete_slider, discrete_values)
  self.options.discrete_slider = discrete_slider or false
  self.options.discrete_values = discrete_values or false
  return self
end
