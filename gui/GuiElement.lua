-------------------------------------------------------------------------------
-- Class to help to build GuiElement
--
-- @module GuiElement
--

-------------------------------------------------------------------------------
--
-- @function [parent = #GuiElement] constructor
-- @return #GuiElement
-- 
GuiElement = newclass(function(base,parent)
  base.parent = parent
  base.gui = {type = "sprite-button"}
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] name
-- @param #string name
-- @return #GuiElement
-- 
function GuiElement:name(name)
  self.gui.name = name
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] style
-- @param #string style
-- @return #GuiElement
-- 
function GuiElement:style(style)
  self.gui.style = style
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] action
-- @param #...
-- @return #GuiElement
-- 
function GuiElement:action(...)
  self.gui.name = table.concat({...},"=")
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] caption
-- @param #string caption
-- @return #GuiElement
-- 
function GuiElement:caption(caption)
  self.gui.caption = caption
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] tooltip
-- @param #string tooltip
-- @return #GuiElement
-- 
function GuiElement:tooltip(tooltip)
  self.gui.tooltip = tooltip
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] sprite
-- @param #string type
-- @param #string name
-- @return #GuiElement
-- 
function GuiElement:sprite(type, name)
  self.gui.sprite = string.format("%s/%s",type, name)
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiElement] apply
-- @return #table
-- 
function GuiElement:apply()
  self.gui.caption = nil
  return self.parent.add(self.gui)
end
