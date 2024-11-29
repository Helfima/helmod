-------------------------------------------------------------------------------
---Class to help to build form
---@class Form : Object
Form = newclass(Object,function(base,classname)
  Object.init(base,classname)
  base:style()
  base.otherClose = true
  base.locate = "screen"
  base.panelClose = true
  base.help_button = true
  base.auto_clear = true
  base.content_verticaly = true
  base.has_tips = false
  base.list_tips = {
    {name="tips-production-line", count=4},
    {name="tips-production-block", count=4}
  }
end)

-------------------------------------------------------------------------------
---Style
function Form:style()
  local display_width, display_height, scale = User.getMainSizes()
  local width_main = display_width/scale
  local height_main = display_height/scale
  self.styles = {
    flow_panel ={
      width = width_main,
      height = height_main,
      minimal_width = width_main,
      minimal_height = height_main,
      maximal_width = width_main,
      maximal_height = height_main,
    }
  }
  self:onStyle(self.styles, width_main, height_main)
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function Form:onStyle(styles, width_main, height_main)
  
end

-------------------------------------------------------------------------------
---Bind Dispatcher
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
---On Bind Dispatcher
function Form:onBind()
end

-------------------------------------------------------------------------------
---On initialization
function Form:onInit()
end

-------------------------------------------------------------------------------
---Is visible
---@return boolean
function Form:isVisible()
  return true
end

-------------------------------------------------------------------------------
---Is special
---@return boolean
function Form:isSpecial()
  return false
end

-------------------------------------------------------------------------------
---Is tool
---@return boolean
function Form:isTool()
  return false
end

-------------------------------------------------------------------------------
---Get panel name
---@return string
function Form:getPanelName()
  return self.classname
end

-------------------------------------------------------------------------------
---Get the parent panel
---@return LuaGuiElement
function Form:getParentPanel()
  local lua_player = Player.native()
  return lua_player.gui[self.locate]
end

-------------------------------------------------------------------------------
---Set style
---@param element LuaGuiElement
---@param style string
---@param property string
function Form:setStyle(element, style, property)
  if element.style ~= nil and self.styles ~= nil and self.styles[style] ~= nil and self.styles[style][property] ~= nil then
    element.style[property] = self.styles[style][property]
  end
end

--------------------------------------------------------------------------------
---Get the parent panel
---@return LuaGuiElement
function Form:getPanel()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil and parent_panel[self:getPanelName()].valid then
    return parent_panel[self:getPanelName()], parent_panel[self:getPanelName()]["content_panel"], parent_panel[self:getPanelName()]["header_panel"]["menu_panel"]
  end
  ---main panel
  local flow_panel = GuiElement.add(parent_panel, GuiFrameV(self:getPanelName()):style("frame"))
  flow_panel.style.horizontally_stretchable = true
  flow_panel.style.vertically_stretchable = true
  flow_panel.location = User.getLocationForm(self:getPanelName())
  self:setFlowStyle(flow_panel)

  local header_panel = GuiElement.add(flow_panel, GuiFlowH("header_panel"))
  header_panel.style.horizontally_stretchable = true
  ---header panel
  local title_panel = GuiElement.add(header_panel, GuiFrameH("title_panel"):caption(self.panelCaption or self.classname):style("helmod_frame_header"))
  title_panel.style.horizontally_stretchable = true
  title_panel.drag_target = flow_panel

  local menu_panel = GuiElement.add(header_panel,  GuiFlowH("menu_panel"))
  menu_panel.style.horizontal_spacing = 10
  menu_panel.style.horizontal_align = "right"

  local content_panel
  content_panel = GuiElement.add(flow_panel, GuiFrameV("content_panel"):style("inside_deep_frame"))
  content_panel.style.vertically_stretchable = true
  content_panel.style.horizontally_stretchable = true
  return flow_panel, content_panel, menu_panel
end

-------------------------------------------------------------------------------
---Set style
---@param flow_panel LuaGuiElement
function Form:setFlowStyle(flow_panel)
  self:setStyle(flow_panel, "flow_panel", "width")
  self:setStyle(flow_panel, "flow_panel", "height")
  self:setStyle(flow_panel, "flow_panel", "minimal_width")
  self:setStyle(flow_panel, "flow_panel", "minimal_height")
  self:setStyle(flow_panel, "flow_panel", "maximal_width")
  self:setStyle(flow_panel, "flow_panel", "maximal_height")
end

-------------------------------------------------------------------------------
---Get or create scroll panel
---@param panel_name string
---@return LuaGuiElement
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
---Get or create scroll panel
---@param panel_name string
---@return LuaGuiElement
function Form:getScrollFramePanel(panel_name)
  local frame_panel = self:getFramePanel(panel_name)
  local scroll_name = "scroll-panel"
  if frame_panel[scroll_name] ~= nil and frame_panel[scroll_name].valid then
    return frame_panel[scroll_name]
  end
  local scroll_panel = GuiElement.add(frame_panel, GuiScroll(scroll_name))
  scroll_panel.style.horizontally_stretchable = false
  return  scroll_panel
end

-------------------------------------------------------------------------------
---Get or create flow panel
---@param panel_name string
---@return LuaGuiElement
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
---Get or create frame panel
---@param panel_name string
---@param style string
---@param direction string --horizontal, vertical
---@return LuaGuiElement
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
---Get or create frame panel
---@param panel_name string
---@param direction string --horizontal, vertical
---@return LuaGuiElement
function Form:getFrameInsidePanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_inside_frame", direction)
end

-------------------------------------------------------------------------------
---Get or create frame panel
---@param panel_name string
---@param direction string --horizontal, vertical
---@return LuaGuiElement
function Form:getFrameDeepPanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_deep_frame", direction)
end

-------------------------------------------------------------------------------
---Get or create frame panel
---@param panel_name string
---@param direction string --horizontal, vertical
---@return LuaGuiElement
function Form:getFrameTabbedPanel(panel_name, direction)
  return self:getFramePanel(panel_name, "helmod_tabbed_frame", direction)
end

-------------------------------------------------------------------------------
---Get the top panel
---@return LuaGuiElement
function Form:getTopPanel()
  local panel = self:getFrameDeepPanel("top")
  return panel
end

-------------------------------------------------------------------------------
---Get the menu panel
---@return LuaGuiElement, LuaGuiElement
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
---Get the menu panel
---@return LuaGuiElement
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
---Is opened panel
---@return boolean
function Form:isOpened()
  local parent_panel = self:getParentPanel()
  if parent_panel[self:getPanelName()] ~= nil then
    return true
  end
  return false
end

-------------------------------------------------------------------------------
---Build first container
---@return boolean
function Form:open(event)
  self:style()
  self:onBeforeOpen(event)
  if self:isOpened() then
    local flow_panel = self:getPanel()
    flow_panel.bring_to_front()
    return true
  end
  local parent_panel = self:getParentPanel()
  User.setActiveForm(self.classname)
  self:updateTopMenu(event)
  if parent_panel[self:getPanelName()] == nil then
    self:onOpen(event)
  end

  if self.classname == "HMProductionPanel" then
    Player.setShortcutState(true)
    Player.native().opened = self:getPanel()
  end

  return true
end

-------------------------------------------------------------------------------
---On before open
---@return boolean
function Form:onBeforeOpen(event)
  return false
end

-------------------------------------------------------------------------------
---Event
---@param event LuaEvent
function Form:event(event)
  if not(self:isOpened()) then return end
  self:onFormEvent(event)
  self:onEvent(event)
end

-------------------------------------------------------------------------------
---On form event
---@param event LuaEvent
function Form:onFormEvent(event)
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if event.action == "minimize-window" then
    content_panel.visible = false
    flow_panel.style.height = 50
    flow_panel.style.minimal_width = 100
  end
  if event.action == "maximize-window" then
    content_panel.visible = true
    self:setFlowStyle(flow_panel)
  end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function Form:onEvent(event)
end

-------------------------------------------------------------------------------
---On open
---@param event LuaEvent
function Form:onOpen(event)
  return false
end

-------------------------------------------------------------------------------
---Prepare
---@param event LuaEvent
function Form:prepare(event)
  return false
end

-------------------------------------------------------------------------------
---Add cell header
---@param guiTable LuaGuiElement
---@param name string
---@param caption string
function Form:addCellHeader(guiTable, name, caption)
  local cell = GuiElement.add(guiTable, GuiFrameH("header", name):style(helmod_frame_style.hidden))
  GuiElement.add(cell, GuiLabel("label"):caption(caption))
end

-------------------------------------------------------------------------------
---Update top menu
---@param event LuaEvent
function Form:updateTopMenu(event)
  ---ajoute un menu
  if self.panelCaption ~= nil then
    local flow_panel, content_panel, menu_panel = self:getPanel()
    menu_panel.clear()
    if self.panelClose then
      ---pause game
      if string.find(self.classname, "HMProductionPanel") then
        local group3 = GuiElement.add(menu_panel, GuiFlowH("group3"))
        if game.is_multiplayer() and not(game.tick_paused) then
          local pause_button = GuiElement.add(group3, GuiButton("do-nothing"):sprite("menu", defines.sprites.run.white, defines.sprites.run.black):style("helmod_frame_button"):tooltip({"helmod_button.game-play-multiplayer"}))
          pause_button.enabled = false
        else
          if game.tick_paused then
            GuiElement.add(group3, GuiButton(self.classname, "game-play"):sprite("menu", defines.sprites.pause.black, defines.sprites.pause.black):style("helmod_frame_button_actived_red"):tooltip({"helmod_button.game-pause"}))
          else
            GuiElement.add(group3, GuiButton(self.classname, "game-pause"):sprite("menu", defines.sprites.run.white, defines.sprites.run.black):style("helmod_frame_button"):tooltip({"helmod_button.game-play"}))
          end
        end
      end

      ---Tool button
      local tool_group = GuiElement.add(menu_panel, GuiFlowH("tool_group"))
      for _, form in pairs(Controller.getViews()) do
        if self.add_special_button == true and form:isVisible() and form:isTool() then
          local icon_hovered, icon = form:getButtonSprites()
          GuiElement.add(tool_group, GuiButton(form.classname, "OPEN"):sprite("menu", icon_hovered, icon):style("helmod_frame_button"):tooltip(form.panelCaption))
        end
      end
      
      ---special tab
      local special_group = GuiElement.add(menu_panel, GuiFlowH("special_group"))
      for _, form in pairs(Controller.getViews()) do
        if self.add_special_button == true and form:isVisible() and form:isSpecial() then
          local icon_hovered, icon = form:getButtonSprites()
          GuiElement.add(special_group, GuiButton(form.classname, "OPEN"):sprite("menu", icon_hovered, icon):style("helmod_frame_button"):tooltip(form.panelCaption))
        end
      end
      ---Standard group
      local standard_group = GuiElement.add(menu_panel, GuiFlowH("standard_group"))
      if self.help_button then
        GuiElement.add(standard_group, GuiButton("HMHelpPanel", "OPEN"):sprite("menu", defines.sprites.status_help.white, defines.sprites.status_help.black):style("helmod_frame_button"):tooltip({"helmod_button.help"}))
      end
      GuiElement.add(standard_group, GuiButton(self.classname, "minimize-window"):sprite("menu", defines.sprites.minimize.white, defines.sprites.minimize.black):style("helmod_frame_button"):tooltip({"helmod_button.minimize"}))
      GuiElement.add(standard_group, GuiButton(self.classname, "maximize-window"):sprite("menu", defines.sprites.maximize.white, defines.sprites.maximize.black):style("helmod_frame_button"):tooltip({"helmod_button.maximize"}))
      GuiElement.add(standard_group, GuiButton(self.classname, "CLOSE"):sprite("menu", defines.sprites.close.white, defines.sprites.close.black):style("helmod_frame_button"):tooltip({"helmod_button.close"}))
    end
  else
    Logging:warn(self.classname, "self.panelCaption not found")
  end
end

-------------------------------------------------------------------------------
---Update
---@param event LuaEvent
function Form:update(event)
  if not(self:isOpened()) then return end
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if self.auto_clear then content_panel.clear() end
  self:updateTopMenu(event)
  self:onUpdate(event)
  self:updateLocation(event)
  if self.has_tips and User.getPreferenceSetting("display_tips") then
    self:updateTips("un tips")
  end
end

-------------------------------------------------------------------------------
---Update location
---@param event LuaEvent
function Form:updateLocation(event)
  local display_width, display_height, scale = Player.getDisplaySizes()
  local width_main, height_main, scale = User.getMainSizes()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if User.getPreferenceSetting("ui_glue") == true and User.getPreferenceSetting("ui_glue", self.classname) == true then
    local offset = User.getPreferenceSetting("ui_glue_offset")
    local navigate = User.getNavigate()
    local location = {x=50,y=50}
    if navigate[User.tab_name] ~= nil and navigate[User.tab_name]["location"] ~= nil then
      location = navigate[User.tab_name]["location"]
    end
    local location_x = location.x + width_main/scale + display_width*offset/scale
    flow_panel.location = {location_x, y=location.y}
  end

  local location = flow_panel.location
  if location.x < 0 or location.x > (display_width - 50)/scale then
    location.x = 0
    flow_panel.location = location
  end
  if location.y < 0 or location.y > (display_height - 50)/scale then
    location.y = 50
    flow_panel.location = location
  end
end

-------------------------------------------------------------------------------
---Update message
---@param event LuaEvent
function Form:updateMessage(event)
  if not(self:isOpened()) then return end
  local panel = self:getFrameDeepPanel("message")
  panel.clear()
  GuiElement.add(panel, GuiLabel("message"):caption(event.message))
end

-------------------------------------------------------------------------------
---Get tips
---@return string
function Form:getTips()
  local list_tips = {}
  if self.list_tips ~= nil then
    for _,tips in pairs(self.list_tips) do
      for line = 1, tips.count, 1 do
        local localised_text = {string.format("helmod_help.%s-%s", tips.name, line)}
        table.insert(list_tips, localised_text)
      end
    end
    local index = math.random(#list_tips)
    return list_tips[index]
  end
  return nil
end
-------------------------------------------------------------------------------
---Update tips
---@param message string
function Form:updateTips(message)
  if not(self:isOpened()) then return end
  local navigate = User.getNavigate(self.classname)
  local time_tips = navigate["tips"] or game.tick
  if game.tick - time_tips > User.delay_tips then return end
  local message = self:getTips()
  if message == nil then return end
  local panel = self:getFramePanel("tips")
  panel.clear()
  GuiElement.add(panel, GuiLabel("tips"):caption(message))

  local event_queue = User.getParameter("event_queue") or {}
  local event = {tick=game.tick, is_tips=true, classname=self.classname}
  event_queue[self.classname] = event
  if time_tips == game.tick then
    navigate["tips"] = game.tick
    User.setParameter("event_queue", event_queue)
  end
end

-------------------------------------------------------------------------------
---Destroy tips
function Form:destroyTips()
  if not(self:isOpened()) then return end
  local panel = self:getFramePanel("tips")
  panel.destroy()
end

-------------------------------------------------------------------------------
---Update error
---@param event LuaEvent
function Form:updateError(event)
  if not(self:isOpened()) then return end
  local panel = self:getFrameDeepPanel("error")
  panel.clear()
  GuiElement.add(panel, GuiLabel("message"):caption(event.message or "Unknown error"):color("red"))
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function Form:onUpdate(event)

end

-------------------------------------------------------------------------------
---Close dialog
---@param force? boolean
function Form:close(force)
  if not(self:isOpened()) and force ~= true then return end
  local flow_panel, content_panel, menu_panel = self:getPanel()
  User.setCloseForm(self.classname, flow_panel.location)
  self:onClose()
  flow_panel.destroy()

  if self.classname == "HMProductionPanel" then
    Player.setShortcutState(false)
  end
end

-------------------------------------------------------------------------------
---On close dialog
function Form:onClose()
end
