---
-- Description of the module.
-- 
-- @module GuiElement
--
-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] constructor
-- @param #arg name
-- @return #GuiElement
-- 
GuiElement = newclass(function(base,...)
  base.name = {...}
  base.classname = "HMGuiElement"
  base.options = {}
  base.is_caption = true
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] style
-- @param #string style
-- @return #GuiElement
-- 
function GuiElement:style(style)
  self.options.style = style
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] caption
-- @param #string caption
-- @return #GuiElement
-- 
function GuiElement:caption(caption)
  self.m_caption = caption
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] tooltip
-- @param #string tooltip
-- @return #GuiElement
-- 
function GuiElement:tooltip(tooltip)
  self.options.tooltip = tooltip
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] sprite
-- @param #string sprite
-- @return #GuiElement
-- 
function GuiElement:sprite(sprite)
  self.options.type = "sprite"
  self.options.sprite = sprite
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] getOptions
-- @return #table
-- 
function GuiElement:getOptions()
  self.options.name = table.concat(self.name,"=")
  if self.is_caption then
    self.options.caption = self.m_caption
  end
  return self.options
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] onErrorOptions
-- @return #table
-- 
function GuiElement:onErrorOptions()
  local options = self:getOptions()
  options.style = nil
  return options
end

-------------------------------------------------------------------------------
-- Add a element
--
-- @function [parent=#GuiElement] add
--
-- @param #LuaGuiElement parent container for element
-- @param #GuiElement gui_element
--
-- @return #LuaGuiElement the LuaGuiElement added
--
function GuiElement.add(parent, gui_element)
  Logging:trace(gui_element.classname, "add", gui_element)
  local element = nil
  local ok , err = pcall(function()
    Logging:debug(gui_element.classname, "options", gui_element:getOptions())
    element = parent.add(gui_element:getOptions())
  end)
  if not ok then
    Logging:debug(gui_element.classname, "options", gui_element:onErrorOptions())
    element = parent.add(gui_element:onErrorOptions())
  end
  return element
end
