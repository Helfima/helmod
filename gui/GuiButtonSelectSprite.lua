-------------------------------------------------------------------------------
-- Class to help to build form
--
-- @module GuiButtonSelectSprite
--

-------------------------------------------------------------------------------
--
-- @function [parent = #GuiButtonSelectSprite] constructor
--
-- @return #GuiButtonSelectSprite
-- 
GuiButtonSelectSprite = newclass(function(base,parent)
  base.parent = parent
  base.gui = {type = "sprite-button"}
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] name
--
-- @param #string name
-- 
-- @return #GuiButtonSelectSprite
-- 
function GuiButtonSelectSprite:name(name)
  self.gui.name = name
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] style
--
-- @param #string style
-- 
-- @return #GuiButtonSelectSprite
-- 
function GuiButtonSelectSprite:style(style)
  self.gui.style = style
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] action
--
-- @param #...
-- 
-- @return #GuiButtonSelectSprite
-- 
function GuiButtonSelectSprite:action(...)
  self.gui.name = table.concat({...},"=")
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] caption
--
-- @param #string caption
-- 
-- @return #GuiButtonSelectSprite
-- 
function GuiButtonSelectSprite:caption(caption)
  self.gui.caption = caption
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] tooltip
--
-- @param #string tooltip
-- 
-- @return #GuiButtonSelectSprite
-- 
function GuiButtonSelectSprite:tooltip(tooltip)
  self.gui.tooltip = tooltip
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] sprite
--
-- @param #string type
-- @param #string name
-- 
-- @return #GuiButtonSelectSprite
-- 
function GuiButtonSelectSprite:sprite(type, name)
  self.gui.sprite = string.format("%s/%s",type, name)
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiButtonSelectSprite] apply
--
-- @return #LuaGuiElement
-- 
function GuiButtonSelectSprite:apply()
  self.gui.caption = nil
  return self.parent.add(self.gui)
end

return GuiButtonSelectSprite