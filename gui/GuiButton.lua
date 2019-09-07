-------------------------------------------------------------------------------
-- Class to help to build GuiButton
--
-- @module GuiButton
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButton
--
GuiButton = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiButton"
  base.options.type = "button"
  base.options.style = "helmod_button_default"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] sprite
-- @param #string type
-- @param #string name
-- @return #GuiButton
--
function GuiButton:sprite(type, name)
  self.options.type = "sprite-button"
  self.is_caption = false
  self.options.sprite = string.format("%s/%s",type, name)
  table.insert(self.name, name)
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] onErrorOptions
-- @return #table
--
function GuiButton:onErrorOptions()
  local options = self:getOptions()
  options.style = "helmod_button_default"
  options.type = "button"
  if (type(options.caption) == "boolean") then
    Logging:error(self.classname, "addGuiButton - caption is a boolean")
  elseif self.caption ~= nil then
    options.caption = self.caption
  else
    options.caption = options.key
  end
  return options
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSelectSprite
--
GuiButtonSelectSprite = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_select_icon"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] color
-- @param #string color
-- @return #GuiButtonSelectSprite
--
function GuiButtonSelectSprite:color(color)
  local style = "helmod_button_select_icon"
  if color == "red" then style = "helmod_button_select_icon_red" end
  if color == "yellow" then style = "helmod_button_select_icon_yellow" end
  if color == "green" then style = "helmod_button_select_icon_green" end
  self.options.style = style
  return self
end


