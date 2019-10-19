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
  if type ~= nil and name ~= nil then
    if type == "resource" then type = "item" end
    if Player.is_valid_sprite_path(string.format("%s/%s", type, name)) then
      self.options.sprite = string.format("%s/%s", type, name)
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item", name)) then
      self.options.sprite = string.format("%s/%s", "item", name)
      Logging:warn(ElementGui.classname, "wrong type", type, name, "-> item")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "entity", name)) then
      self.options.sprite = string.format("%s/%s", "entity", name)
      Logging:warn(ElementGui.classname, "wrong type", type, name, "-> entity")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "fluid", name)) then
      self.options.sprite = string.format("%s/%s", "fluid", name)
      Logging:warn(ElementGui.classname, "wrong type", type, name, "-> fluid")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "technology", name)) then
      self.options.sprite = string.format("%s/%s", "technology", name)
      Logging:warn(ElementGui.classname, "wrong type", type, name, "-> technology")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "recipe", name)) then
      self.options.sprite = string.format("%s/%s", "recipe", name)
      Logging:warn(ElementGui.classname, "wrong type", type, name, "-> recipe")
    elseif Player.is_valid_sprite_path(string.format("%s/%s", "item-group", name)) then
      self.options.sprite = string.format("%s/%s", "item-group", name)
      Logging:warn(ElementGui.classname, "wrong type", type, name, "-> item-group")
    end
  end
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
  elseif self.m_caption ~= nil then
    options.caption = self.m_caption
  else
    options.caption = options.key
  end
  return options
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSprite
--
GuiButtonSprite = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_icon"
  base.is_caption = false
end)

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

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSpriteM
--
GuiButtonSpriteM = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_icon_m"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSelectSpriteM
--
GuiButtonSelectSpriteM = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_select_icon_m"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] color
-- @param #string color
-- @return #GuiButtonSelectSpriteM
--
function GuiButtonSelectSpriteM:color(color)
  local style = "helmod_button_select_icon_m"
  if color == "red" then style = "helmod_button_select_icon_m_red" end
  if color == "yellow" then style = "helmod_button_select_icon_m_yellow" end
  if color == "green" then style = "helmod_button_select_icon_m_green" end
  self.options.style = style
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSpriteSm
--
GuiButtonSpriteSm = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_icon_sm"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSelectSpriteSm
--
GuiButtonSelectSpriteSm = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_select_icon_sm"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] color
-- @param #string color
-- @return #GuiButtonSelectSpriteSm
--
function GuiButtonSelectSpriteSm:color(color)
  local style = "helmod_button_select_icon_sm"
  if color == "red" then style = "helmod_button_select_icon_sm_red" end
  if color == "yellow" then style = "helmod_button_select_icon_sm_yellow" end
  if color == "green" then style = "helmod_button_select_icon_sm_green" end
  self.options.style = style
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSpriteXxl
--
GuiButtonSpriteXxl = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_icon_xxl"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] constructor
-- @param #arg name
-- @return #GuiButtonSelectSpriteXxl
--
GuiButtonSelectSpriteXxl = newclass(GuiButton,function(base,...)
  GuiButton.init(base,...)
  base.options.style = "helmod_button_select_icon_xxl"
  base.is_caption = false
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButton] color
-- @param #string color
-- @return #GuiButtonSelectSpriteXxl
--
function GuiButtonSelectSpriteXxl:color(color)
  local style = "helmod_button_select_icon_xxl"
  if color == "red" then style = "helmod_button_select_icon_xxl_red" end
  if color == "yellow" then style = "helmod_button_select_icon_xxl_yellow" end
  if color == "green" then style = "helmod_button_select_icon_xxl_green" end
  self.options.style = style
  return self
end


