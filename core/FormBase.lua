-------------------------------------------------------------------------------
-- Class to help to build FormBase
--
-- @module FormBase
-- @extends Object#Object
--
FormBase = newclass(Object,function(base,classname)
  Object.init(base,classname)
  base.otherClose = true
  base.locate = "screen"
  base.panelClose = true
  base.auto_clear = true
  base.content_verticaly = true
end)

-------------------------------------------------------------------------------
-- Bind Dispatcher
--
-- @function [parent=#FormBase] bind
--
function FormBase:bind()
  Dispatcher:bind("on_gui_event", self, self.event)

  Dispatcher:bind("on_gui_open", self, self.open)
  Dispatcher:bind("on_gui_open", self, self.update)

  Dispatcher:bind("on_gui_update", self, self.update)
  Dispatcher:bind("on_gui_close", self, self.close)

  self:onBind()
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#FormBase] onBind
--
function FormBase:onBind()
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#FormBase] onInit
--
function FormBase:onInit()
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#FormBase] isVisible
--
-- @return boolean
--
function FormBase:isVisible()
  return true
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#FormBase] isSpecial
--
-- @return boolean
--
function FormBase:isSpecial()
  return false
end

-------------------------------------------------------------------------------
-- Get panel name
--
-- @function [parent=#FormBase] getPanelName
--
-- @return #LuaGuiElement
--
function FormBase:getPanelName()
  return self.classname
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#FormBase] getParentPanel
--
-- @return #LuaGuiElement
--
function FormBase:getParentPanel()
  local lua_player = Player.native()
  return lua_player.gui[self.locate]
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#FormBase] getPanel
--
-- @return #LuaGuiElement
--
function FormBase:getPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil and parent_panel[self:getPanelName()].valid then
    return parent_panel[self:getPanelName()]
  end
  -- main panel
  local flow_panel = GuiElement.add(parent_panel, GuiFrameV(self:getPanelName()):style("frame"))
  flow_panel.style.horizontally_stretchable = true
  flow_panel.style.vertically_stretchable = true
  flow_panel.location = User.getLocationForm(self:getPanelName())

  return flow_panel
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#FormBase] getFramePanel
--
function FormBase:getFramePanel(panel_name, style, direction)
  local flow_panel = self:getPanel()
  if flow_panel[panel_name] ~= nil and flow_panel[panel_name].valid then
    return flow_panel[panel_name]
  end
  local frame_panel = nil
  if direction == "horizontal" then
    frame_panel = GuiElement.add(flow_panel, GuiFrameH(panel_name):style(style or "helmod_frame"))
  else
    frame_panel = GuiElement.add(flow_panel, GuiFrameV(panel_name):style(style or "helmod_frame"))
  end
  frame_panel.style.horizontally_stretchable = true
  return frame_panel
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#FormBase] getFrameInsidePanel
--
function FormBase:getFrameInsidePanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_inside_frame", direction)
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#FormBase] getFrameDeepPanel
--
function FormBase:getFrameDeepPanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_deep_frame", direction)
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#FormBase] getFrameDeepPanel
--
function FormBase:getFrameTabbedPanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_tabbed_frame", direction)
end

-------------------------------------------------------------------------------
-- Get the top panel
--
-- @function [parent=#FormBase] getTopPanel
--
-- @return #LuaGuiElement
--
function FormBase:getTopPanel()
  local panel = self:getFrameDeepPanel("top")
  return panel
end

-------------------------------------------------------------------------------
-- Is opened panel
--
-- @function [parent=#FormBase] isOpened
--
function FormBase:isOpened()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil and User.isActiveForm(self.classname) then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#FormBase] open
--
-- @param #LuaEvent event
--
function FormBase:open(event)
  self:onBeforeOpen(event)
  --if self:isOpened() then return true end
  if self:isOpened() then
    self:close()
    return false
  end
  local flow_panel self:getPanel(event)
  User.setActiveForm(self.classname)
  self:onOpen(event)
  return true
end

-------------------------------------------------------------------------------
-- On before open
--
-- @function [parent=#FormBase] onBeforeOpen
--
-- @param #LuaEvent event
--
function FormBase:onBeforeOpen(event)
  return false
end

-------------------------------------------------------------------------------
-- Event
--
-- @function [parent=#FormBase] event
--
-- @param #LuaEvent event
--
function FormBase:event(event)
  if not(self:isOpened()) then return end
  self:onEvent(event)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#FormBase] onEvent
--
-- @param #LuaEvent event
--
function FormBase:onEvent(event)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#FormBase] onOpen
--
-- @param #LuaEvent event
--
function FormBase:onOpen(event)
  return false
end

-------------------------------------------------------------------------------
-- Prepare
--
-- @function [parent=#FormBase] prepare
--
-- @param #LuaEvent event
--
function FormBase:prepare(event)
  return false
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#FormBase] update
--
-- @param #LuaEvent event
--
function FormBase:update(event)
  if not(self:isOpened()) then return end
  local flow_panel = self:getPanel()
  if self.auto_clear then flow_panel.clear() end
  self:onUpdate(event)
  self:updateLocation(event)
end

-------------------------------------------------------------------------------
-- Update location
--
-- @function [parent=#FormBase] updateLocation
--
-- @param #LuaEvent event
--
function FormBase:updateLocation(event)
  local width , height = GuiElement.getDisplaySizes()
  local width_main, height_main = GuiElement.getMainSizes()
  local flow_panel = self:getPanel()
  if User.getPreferenceSetting("ui_glue") == true and User.getPreferenceSetting("ui_glue", self.classname) == true then
    local offset = User.getPreferenceSetting("ui_glue_offset")
    local navigate = User.getNavigate()
    local location = {x=50,y=50}
    if navigate[User.tab_name] ~= nil or navigate[User.tab_name]["location"] ~= nil then
      location = navigate[User.tab_name]["location"]
    end
    local location_x = location.x + width_main + width*offset
    flow_panel.location = {location_x, y=location.y}
  end

  local location = flow_panel.location
  if location.x < 0 or location.x > (width - 100) then
    location.x = 0
    flow_panel.location = location
  end
  if location.y < 0 or location.y > (height - 50) then
    location.y = 50
    flow_panel.location = location
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#FormBase] onUpdate
--
-- @param #LuaEvent event
--
function FormBase:onUpdate(event)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#FormBase] close
--
function FormBase:close(force)
  if not(self:isOpened()) and force ~= true then return end
  local flow_panel = self:getPanel()
  User.setCloseForm(self.classname, flow_panel.location)
  self:onClose()
  flow_panel.destroy()
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#FormBase] onClose
--
-- @return #boolean if true the next call close dialog
--
function FormBase:onClose()
end
