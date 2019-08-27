-------------------------------------------------------------------------------
-- Class to build Calculator panel
--
-- @module Calculator
-- @extends #Form
--

Calculator = class(Form)

local display_panel = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Calculator] init
--
-- @param #Controller parent parent controller
--
function Calculator:onInit(parent)
  self.panelCaption = ({"helmod_calculator-panel.title"})
  self.parent = parent
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#Calculator] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function Calculator:onBeforeEvent(event, action, item, item2, item3)
  -- close si nouvel appel
  return true
end


-------------------------------------------------------------------------------
-- Get or create column panel
--
-- @function [parent=#Calculator] getColumnPanel
--
function Calculator:getColumnPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["main_panel"] ~= nil and content_panel["main_panel"].valid then
    return content_panel["main_panel"]["display_panel1"], content_panel["main_panel"]["display_panel2"]
  end
  local panel = ElementGui.addGuiFlowH(content_panel, "main_panel", helmod_flow_style.horizontal)
  local display_panel1 = ElementGui.addGuiFlowV(panel, "display_panel1", helmod_flow_style.vertical)
  local display_panel2 = ElementGui.addGuiFlowV(panel, "display_panel2", helmod_flow_style.vertical)
  display_panel2.style.width=200

  return display_panel1, display_panel2
end

-------------------------------------------------------------------------------
-- Get or create display panel
--
-- @function [parent=#Calculator] getDisplayPanel
--
function Calculator:getDisplayPanel()
  local display_panel1, display_panel2 = self:getColumnPanel()
  if display_panel1["display"] ~= nil and display_panel1["display"].valid then
    return display_panel1["display"]
  end
  return ElementGui.addGuiFrameV(display_panel1, "display", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create keyboard panel
--
-- @function [parent=#Calculator] getKeyboardPanel
--
function Calculator:getKeyboardPanel()
  local display_panel1, display_panel2 = self:getColumnPanel()
  if display_panel1["keyboard"] ~= nil and display_panel1["keyboard"].valid then
    return display_panel1["keyboard"]
  end
  local panel = ElementGui.addGuiFrameV(display_panel1, "keyboard", helmod_frame_style.panel)
  panel.style.horizontally_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- Get or create history panel
--
-- @function [parent=#Calculator] getHistoryPanel
--
function Calculator:getHistoryPanel()
  local display_panel1, display_panel2 = self:getColumnPanel()
  if display_panel2["history"] ~= nil and display_panel2["history"].valid then
    return display_panel2["history"]
  end
  local panel = ElementGui.addGuiFrameV(display_panel2, "history", helmod_frame_style.panel)
  panel.style.horizontally_stretchable = true
  panel.style.vertically_stretchable = true
  return panel
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Calculator] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Calculator:onEvent(event, action, item, item2, item3)
  Logging:debug(self.classname, "onEvent()", action, item, item2, item3)
  -- import
  if action == "compute" then
    local text = event.element.text
    local ok , err = pcall(function()
      local result = formula(text)
      self:addHistory(text, result)
      User.setParameter("calculator_value", result or 0)
      self:updateDisplay(item, item2, item3)
      self:updateHistory(item, item2, item3)
    end)
    if not(ok) then
      Player.print("Formula is not valid!")
    end
  end
  if action == "selected-key" then
    if item == "enter" then
      local ok , err = pcall(function()
        local calculator_value = User.getParameter("calculator_value") or 0
        local result = formula(calculator_value)
        self:addHistory(calculator_value, result)
        User.setParameter("calculator_value", result or 0)
        self:updateDisplay(item, item2, item3)
        self:updateHistory(item, item2, item3)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    elseif item == "clear" then
      User.setParameter("calculator_value", 0)
      self:updateDisplay(item, item2, item3)
    else
      local calculator_value = User.getParameter("calculator_value") or 0
      if calculator_value == 0 then calculator_value = "" end
      User.setParameter("calculator_value", calculator_value..item)
      self:updateDisplay(item, item2, item3)
    end
  end
end

-------------------------------------------------------------------------------
-- Add history
--
-- @function [parent=#Calculator] Calculator
--
-- @param #string calculator_value
-- @param #number result
--
function Calculator:addHistory(calculator_value, result)
  if calculator_value ~= result then
    local calculator_history = User.getParameter("calculator_history") or {}
    table.insert(calculator_history,1,string.format("%s=%s",calculator_value,result))
    if #calculator_history > 9 then table.remove(calculator_history,#calculator_history) end
    User.setParameter("calculator_history", calculator_history)
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#Calculator] Calculator
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Calculator:onUpdate(event, action, item, item2, item3)
  self:updateDisplay(item, item2, item3)
  self:updateKeyboard(item, item2, item3)
  self:updateHistory(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update display
--
-- @function [parent=#Calculator] updateDisplay
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Calculator:updateDisplay(item, item2, item3)
  Logging:debug(self.classname, "updateDisplay()", item, item2, item3)
  local keyboard_panel = self:getDisplayPanel()
  keyboard_panel.clear()

  --local table_panel = ElementGui.addGuiTable(keyboard_panel,"keys",2)
  local calculator_value = User.getParameter("calculator_value") or 0
  display_panel = ElementGui.addGuiText(keyboard_panel,self.classname.."=compute=ID=",calculator_value,"helmod_textfield_calculator")
  --display_panel.style.horizontally_stretchable = true
  display_panel.style.width=155
  display_panel.style.horizontal_align = "right"
  display_panel.focus()

end
-------------------------------------------------------------------------------
-- Update keyboard
--
-- @function [parent=#Calculator] updateKeyboard
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Calculator:updateKeyboard(item, item2, item3)
  Logging:debug(self.classname, "updateCalculator()", item, item2, item3)
  local keyboard_panel = self:getKeyboardPanel()
  keyboard_panel.clear()

  local table_panel = ElementGui.addGuiTable(keyboard_panel,"keys",4)
  local keys = {}
  table.insert(keys, {key="clear" ,caption="C"})
  table.insert(keys, {key="(" ,caption="("})
  table.insert(keys, {key=")" ,caption=")"})
  table.insert(keys, {key="/" ,caption="/"})

  table.insert(keys, {key="7" ,caption="7"})
  table.insert(keys, {key="8" ,caption="8"})
  table.insert(keys, {key="9" ,caption="9"})
  table.insert(keys, {key="*" ,caption="X"})

  table.insert(keys, {key="4" ,caption="4"})
  table.insert(keys, {key="5" ,caption="5"})
  table.insert(keys, {key="6" ,caption="6"})
  table.insert(keys, {key="-" ,caption="-"})

  table.insert(keys, {key="1" ,caption="1"})
  table.insert(keys, {key="2" ,caption="2"})
  table.insert(keys, {key="3" ,caption="3"})
  table.insert(keys, {key="+" ,caption="+"})

  table.insert(keys, {key="" ,caption=""})
  table.insert(keys, {key="0" ,caption="0"})
  table.insert(keys, {key="." ,caption="."})
  table.insert(keys, {key="enter" ,caption="="})

  for index,button in pairs(keys) do
    if button.key == "" then
      ElementGui.addGuiLabel(table_panel,string.format("vide_%s",index))
    else
      ElementGui.addGuiButton(table_panel,self.classname.."=selected-key=ID=",button.key,"helmod_button_calculator",button.caption)
    end
  end

end

-------------------------------------------------------------------------------
-- Update history
--
-- @function [parent=#Calculator] updateHistory
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function Calculator:updateHistory(item, item2, item3)
  Logging:debug(self.classname, "updateHistory()", item, item2, item3)
  local history_panel = self:getHistoryPanel()
  history_panel.clear()

  local calculator_history = User.getParameter("calculator_history") or {}
  for index, line in pairs(calculator_history) do
    ElementGui.addGuiLabel(history_panel,string.format("history_%s",index),line)
  end

end
