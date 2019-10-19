-------------------------------------------------------------------------------
-- Class to help to build GuiSlider
--
-- @module GuiSlider
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSlider] constructor
-- @param #arg name
-- @return #GuiSlider
--
GuiSlider = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiSlider"
  base.options.type = "slider"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSlider] values
-- @param #number minimum_value
-- @param #number maximum_value
-- @param #number value
-- @param #number value_step
-- @return #GuiSlider
--
function GuiSlider:values(minimum_value, maximum_value, value, value_step)
  self.options.minimum_value = minimum_value
  self.options.maximum_value = maximum_value
  self.options.value = value or minimum_value
  self.options.value_step = value_step or 1
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSlider] discrete
-- @param #number discrete_slider
-- @param #number maximum_value
-- @return #GuiSlider
--
function GuiSlider:discrete(discrete_slider, discrete_values)
  self.options.discrete_slider = discrete_slider or false
  self.options.discrete_values = discrete_values or false
  return self
end
