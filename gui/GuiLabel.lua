-------------------------------------------------------------------------------
-- Class to help to build GuiLabel
-- @class GuiLabel
GuiLabel = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiLabel"
  base.options.type = "label"
end)

-------------------------------------------------------------------------------
---Set wrap
---@param wrap boolean
---@return GuiLabel
function GuiLabel:wordWrap(wrap)
  self.options.word_wrap = wrap
  return self
end

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiLabel
function GuiLabel:color(color)
  local color = helmod_tag.color[color] or helmod_tag.color.orange
  self.m_caption = {"", helmod_tag.color.orange, self.m_caption, helmod_tag.color.close}
  return self
end