require "core.Object"

-------------------------------------------------------------------------------
-- Class to help to build form
--
-- @module Form
-- @extends Object#Object
--
Form = newclass(Object,function(base,classname)
  Object.init(base,classname)
  base.otherClose = true
  base.locate = "screen"
  base.panelClose = true
  base.help_button = true
  base.auto_clear = true
  base.content_verticaly = true
  base.debug = false
end)

-------------------------------------------------------------------------------
-- Bind Dispatcher
--
-- @function [parent=#Form] bind
--
function Form:bind()
  Dispatcher:bind("on_gui_event", self, self.event)

  Dispatcher:bind("on_gui_open", self, self.open)
  Dispatcher:bind("on_gui_open", self, self.update)

  Dispatcher:bind("on_gui_update", self, self.update)
  Dispatcher:bind("on_gui_close", self, self.close)

  Dispatcher:bind("on_gui_error", self, self.updateError)
  Dispatcher:bind("on_gui_message", self, self.updateMessage)

  self:onBind()
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#Form] onBind
--
function Form:onBind()
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Form] onInit
--
function Form:onInit()
end

-------------------------------------------------------------------------------
-- Is visible
--
-- @function [parent=#Form] isVisible
--
-- @return boolean
--
function Form:isVisible()
  return true
end

-------------------------------------------------------------------------------
-- Is special
--
-- @function [parent=#Form] isSpecial
--
-- @return boolean
--
function Form:isSpecial()
  return false
end

-------------------------------------------------------------------------------
-- Get panel name
--
-- @function [parent=#Form] getPanelName
--
-- @return #LuaGuiElement
--
function Form:getPanelName()
  return self.classname
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getParentPanel
--
-- @return #LuaGuiElement
--
function Form:getParentPanel()
  local lua_player = Player.native()
  return lua_player.gui[self.locate]
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#Form] getPanel
--
-- @return #LuaGuiElement
--
function Form:getPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil and parent_panel[self:getPanelName()].valid then
    return parent_panel[self:getPanelName()], parent_panel[self:getPanelName()]["content_panel"], parent_panel[self:getPanelName()]["header_panel"]["menu_panel"]
  end
  -- main panel
  local flow_panel = GuiElement.add(parent_panel, GuiFrameV(self:getPanelName()):style("frame"))
  flow_panel.style.horizontally_stretchable = true
  flow_panel.style.vertically_stretchable = true
  flow_panel.location = User.getLocationForm(self:getPanelName())
  local width_main, height_main = GuiElement.getMainSizes()
  GuiElement.setStyle(flow_panel, self.classname, "width")
  GuiElement.setStyle(flow_panel, self.classname, "height")
  GuiElement.setStyle(flow_panel, self.classname, "minimal_width")
  GuiElement.setStyle(flow_panel, self.classname, "minimal_height")
  GuiElement.setStyle(flow_panel, self.classname, "maximal_width")
  GuiElement.setStyle(flow_panel, self.classname, "maximal_height")

  local header_panel = GuiElement.add(flow_panel, GuiFlowH("header_panel"))
  header_panel.style.horizontally_stretchable = true
  -- header panel
  local title_panel = GuiElement.add(header_panel, GuiFrameH("title_panel"):caption(self.panelCaption or self.classname):style("helmod_frame_header"))
  title_panel.style.horizontally_stretchable = true
  title_panel.drag_target = flow_panel

  local menu_panel = GuiElement.add(header_panel,  GuiFlowH("menu_panel"))
  --menu_panel.style.horizontal_spacing = 10
  menu_panel.style.horizontal_align = "right"

  local content_panel
  content_panel = GuiElement.add(flow_panel, GuiFrameV("content_panel"):style("inside_deep_frame"))
  return flow_panel, content_panel, menu_panel
end

-------------------------------------------------------------------------------
-- Get or create scroll panel
--
-- @function [parent=#Form] getScrollPanel
--
function Form:getScrollPanel(panel_name)
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local frame_panel = GuiElement.add(content_panel, GuiScroll(panel_name):style("helmod_scroll_pane"))
  frame_panel.style.horizontally_stretchable = true
  return frame_panel
end

-------------------------------------------------------------------------------
-- Get or create flow panel
--
-- @function [parent=#Form] getFlowPanel
--
function Form:getFlowPanel(panel_name, direction)
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local frame_panel = nil
  if direction == "horizontal" then
    frame_panel = GuiElement.add(content_panel, GuiFlowH(panel_name))
  else
    frame_panel = GuiElement.add(content_panel, GuiFlowV(panel_name))
  end
  frame_panel.style.horizontally_stretchable = true
  return frame_panel
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#Form] getFramePanel
--
function Form:getFramePanel(panel_name, style, direction)
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local frame_panel = nil
  if direction == "horizontal" then
    frame_panel = GuiElement.add(content_panel, GuiFrameH(panel_name):style(style or "helmod_frame"))
  else
    frame_panel = GuiElement.add(content_panel, GuiFrameV(panel_name):style(style or "helmod_frame"))
  end
  frame_panel.style.horizontally_stretchable = true
  return frame_panel
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#Form] getFrameInsidePanel
--
function Form:getFrameInsidePanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_inside_frame", direction)
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#Form] getFrameDeepPanel
--
function Form:getFrameDeepPanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_deep_frame", direction)
end

-------------------------------------------------------------------------------
-- Get or create frame panel
--
-- @function [parent=#Form] getFrameDeepPanel
--
function Form:getFrameTabbedPanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_tabbed_frame", direction)
end

-------------------------------------------------------------------------------
-- Get the top panel
--
-- @function [parent=#Form] getTopPanel
--
-- @return #LuaGuiElement
--
function Form:getTopPanel()
  local panel = self:getFrameDeepPanel("top")
  return panel
end

-------------------------------------------------------------------------------
-- Get the menu panel
--
-- @function [parent=#Form] getMenuPanel
--
-- @return #LuaGuiElement
--
function Form:getMenuPanel()
  local content_panel = self:getTopPanel()
  local panel_name = "menu"
  local left_name = "left_menu"
  local right_name = "right_menu"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name][left_name], content_panel[panel_name][right_name]
  end
  local panel = GuiElement.add(content_panel, GuiFlowH(panel_name))
  panel.style.horizontally_stretchable = true
  panel.style.height = 32
  
  local left_panel = GuiElement.add(panel, GuiFlowH(left_name))
  left_panel.style.horizontal_spacing = 10
  
  local right_panel = GuiElement.add(panel, GuiFlowH(right_name))
  right_panel.style.horizontal_spacing = 10
  right_panel.style.horizontally_stretchable = true
  right_panel.style.horizontal_align = "right"
  return left_panel, right_panel
end

-------------------------------------------------------------------------------
-- Get the menu panel
--
-- @function [parent=#Form] getMenuPanel
--
-- @return #LuaGuiElement
--
function Form:getMenuSubPanel()
  local content_panel = self:getTopPanel()
  local panel_name = "sub_menu"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]
  end
  local panel = GuiElement.add(content_panel, GuiFlowH(panel_name))
  panel.style.horizontally_stretchable = true
  panel.style.minimal_height = 32
  return panel
end

-------------------------------------------------------------------------------
-- Is opened panel
--
-- @function [parent=#Form] isOpened
--
function Form:isOpened()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil and User.isActiveForm(self.classname) then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
-- Build first container
--
-- @function [parent=#Form] open
--
-- @param #LuaEvent event
--
function Form:open(event)
  self:onBeforeOpen(event)
  --if self:isOpened() then return true end
  if self:isOpened() then self:close() end
  local parent_panel = self:getParentPanel()
  User.setActiveForm(self.classname)
  if parent_panel[self:getPanelName()] == nil then
    self:updateTopMenu(event)
    self:onOpen(event)
  end
  return true
end

-------------------------------------------------------------------------------
-- On before open
--
-- @function [parent=#Form] onBeforeOpen
--
-- @param #LuaEvent event
--
function Form:onBeforeOpen(event)
  return false
end

-------------------------------------------------------------------------------
-- Event
--
-- @function [parent=#Form] event
--
-- @param #LuaEvent event
--
function Form:event(event)
  if not(self:isOpened()) then return end
  self:onEvent(event)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Form] onEvent
--
-- @param #LuaEvent event
--
function Form:onEvent(event)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#Form] onOpen
--
-- @param #LuaEvent event
--
function Form:onOpen(event)
  return false
end

-------------------------------------------------------------------------------
-- Prepare
--
-- @function [parent=#Form] prepare
--
-- @param #LuaEvent event
--
function Form:prepare(event)
  return false
end

-------------------------------------------------------------------------------
-- Update top menu
--
-- @function [parent=#Form] updateTopMenu
--
-- @param #LuaEvent event
--
function Form:updateTopMenu(event)
  -- ajoute un menu
  if self.panelCaption ~= nil then
    local flow_panel, content_panel, menu_panel = self:getPanel()
    menu_panel.clear()
    if self.panelClose then
      -- pause game
      if string.find(self.classname, "Tab") then
        local group3 = GuiElement.add(menu_panel, GuiFlowH("group3"))
        if game.is_multiplayer() and not(game.tick_paused) then
          local pause_button = GuiElement.add(group3, GuiButton("do-nothing"):sprite("menu", "play-white", "play"):style("helmod_frame_button"):tooltip({"helmod_button.game-play-multiplayer"}))
          pause_button.enabled = false
        else
          if game.tick_paused then
            GuiElement.add(group3, GuiButton(self.classname, "game-play"):sprite("menu", "pause", "pause"):style("helmod_frame_button_actived_red"):tooltip({"helmod_button.game-pause"}))
          else
            GuiElement.add(group3, GuiButton(self.classname, "game-pause"):sprite("menu", "play-white", "play"):style("helmod_frame_button"):tooltip({"helmod_button.game-play"}))
          end
        end
      end
      -- special tab
      local group1 = GuiElement.add(menu_panel, GuiFlowH("group1"))
      for _, form in pairs(Controller.getViews()) do
        if self.add_special_button == true and form:isVisible() and form:isSpecial() then
          local icon_hovered, icon = form:getButtonSprites()
          local style = "helmod_frame_button"
          if string.find(form.classname, "Tab") then
            if User.isActiveForm(form.classname) then style = "helmod_frame_button_selected" end
            GuiElement.add(group1, GuiButton(self.classname, "change-tab", form.classname):sprite("menu", icon_hovered, icon):style(style):tooltip(form:getButtonCaption()))
          else
            GuiElement.add(group1, GuiButton(form.classname, "OPEN"):sprite("menu", icon_hovered, icon):style(style):tooltip(form.panelCaption))
          end
        end
      end
      -- current button
      local group2 = GuiElement.add(menu_panel, GuiFlowH("group2"))
      if self.help_button then
        GuiElement.add(group2, GuiButton("HMHelpPanel", "OPEN"):sprite("menu", "help-white", "help"):style("helmod_frame_button"):tooltip({"helmod_button.help"}))
      end
      if string.find(self.classname, "Tab") then
        GuiElement.add(group2, GuiButton(self.classname, "close-tab"):sprite("menu", "close-window-white", "close-window"):style("helmod_frame_button"):tooltip({"helmod_button.close"}))
      else
        GuiElement.add(group2, GuiButton(self.classname, "CLOSE"):sprite("menu", "close-window-white", "close-window"):style("helmod_frame_button"):tooltip({"helmod_button.close"}))
      end
    end
  else
    Logging:warn(self.classname, "self.panelCaption not found")
  end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#Form] update
--
-- @param #LuaEvent event
--
function Form:update(event)
  if not(self:isOpened()) then return end
  local profiler
  if self.debug then 
    profiler = game.create_profiler()
    profiler.reset()
  end
  
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if self.auto_clear then content_panel.clear() end
  self:onUpdate(event)
  self:updateLocation(event)
  
  if self.debug then
    log({"",self.classname, " ",profiler})
    profiler.stop()
  end
end

-------------------------------------------------------------------------------
-- Update location
--
-- @function [parent=#Form] updateLocation
--
-- @param #LuaEvent event
--
function Form:updateLocation(event)
  local width , height = GuiElement.getDisplaySizes()
  local width_main, height_main = GuiElement.getMainSizes()
  local flow_panel, content_panel, menu_panel = self:getPanel()
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
-- Update message
--
-- @function [parent=#Form] updateMessage
--
-- @param #LuaEvent event
--
function Form:updateMessage(event)
  if not(self:isOpened()) then return end
  local panel = self:getFrameDeepPanel("message")
  panel.clear()
  GuiElement.add(panel, GuiLabel("message"):caption(event.message))
end

-------------------------------------------------------------------------------
-- Update error
--
-- @function [parent=#Form] updateError
--
-- @param #LuaEvent event
--
function Form:updateError(event)
  if not(self:isOpened()) then return end
  local panel = self:getFrameDeepPanel("error")
  panel.clear()
  GuiElement.add(panel, GuiLabel("message"):caption(event.message or "Unknown error"):color("red"))
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Form] onUpdate
--
-- @param #LuaEvent event
--
function Form:onUpdate(event)

end

-------------------------------------------------------------------------------
-- Close dialog
--
-- @function [parent=#Form] close
--
function Form:close(force)
  if not(self:isOpened()) and force ~= true then return end
  local flow_panel, content_panel, menu_panel = self:getPanel()
  User.setCloseForm(self.classname, flow_panel.location)
  self:onClose()
  flow_panel.destroy()
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#Form] onClose
--
-- @return #boolean if true the next call close dialog
--
function Form:onClose()
end
