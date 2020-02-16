-------------------------------------------------------------------------------
-- Class to help to build GuiLabel
--
-- @module GuiLabel
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLabel] constructor
-- @param #arg name
-- @return #GuiLabel
--
GuiLabel = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiLabel"
  base.options.type = "label"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLabel] wordWrap
-- @param #boolean wrap
-- @return #GuiLabel
--
function GuiLabel:wordWrap(wrap)
  self.options.word_wrap = wrap
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiLabel] color
-- @param #boolean wrap
-- @return #GuiLabel
--
function GuiLabel:color(color)
  local color = helmod_tag.color[color] or helmod_tag.color.orange
  self.m_caption = {"", helmod_tag.color.orange, self.m_caption, helmod_tag.color.close}
  return self
end