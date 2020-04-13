-------------------------------------------------------------------------------
-- Class to help to build GuiSprite
--
-- @module GuiSlider
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSprite] constructor
-- @param #arg name
-- @return #GuiSprite
--
GuiSprite = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiSprite"
  base.options.type = "sprite"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiSprite] sprite
-- @param #string type
-- @param #string name
-- @return #GuiSprite
--
function GuiSprite:sprite(type, name)
  if type == "menu" then
    self.options.sprite = GuiElement.getSprite(name)
  elseif name == nil then
    self.options.sprite = type
  else
    self.options.sprite = string.format("%s/%s", type, name)
  end
  return self
end


