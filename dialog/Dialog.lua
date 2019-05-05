-------------------------------------------------------------------------------
-- Class to help to build dialog
-- 
-- @module Dialog
-- 
Dialog = setclass("HMDialog", Form)

-------------------------------------------------------------------------------
-- Bind the button
--
-- @function [parent=#Dialog] bindButton
-- 
-- @param #LuaGuiElement gui parent element
-- @param #string label displayed text
-- 
function Dialog.methods:bindButton(gui, label)
	local caption = ({self.ACTION_OPEN})
	if label ~= nil then caption = label end
	if gui ~= nil then
		gui.add({type="button", name=self.ACTION_OPEN, caption=caption, style="helmod_button_default"})
	end
end

