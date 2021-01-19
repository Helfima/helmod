-------------------------------------------------------------------------------
-- Class to build Calculator panel
--
-- @module Calculator
-- @extends #Form
--

Calculator = newclass(Form)

local display_panel = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#Calculator] init
--
function Calculator:onInit()
  self.panelCaption = ({"helmod_calculator-panel.title"})
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#Calculator] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function Calculator:onStyle(styles, width_main, height_main)
  styles.flow_panel = nil
end

------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#Calculator] getButtonSprites
--
-- @return boolean
--
function Calculator:getButtonSprites()
  return "calculator-white","calculator"
end

-------------------------------------------------------------------------------
-- Is tool
--
-- @function [parent=#Calculator] isTool
--
-- @return boolean
--
function Calculator:isTool()
  return true
end

-------------------------------------------------------------------------------
-- Get or create column panel
--
-- @function [parent=#Calculator] getColumnPanel
--
function Calculator:getColumnPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "main_panel"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]["display_panel1"], content_panel[panel_name]["display_panel2"]
  end
  local panel = self:getFlowPanel(panel_name, "horizontal")
  local display_panel1 = GuiElement.add(panel, GuiFrameV("display_panel1"))
  display_panel1.style.vertically_stretchable = true
  local display_panel2 = GuiElement.add(panel, GuiFrameV("display_panel2"))
  display_panel2.style.vertically_stretchable = true
  return display_panel1, display_panel2
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#Calculator] onEvent
--
-- @param #LuaEvent event
--
function Calculator:onEvent(event)
  -- import
  if event.action == "compute" then
    local text = event.element.text
    local ok , err = pcall(function()
      local result = formula(text)
      self:addHistory(text, result)
      User.setParameter("calculator_value", result or 0)
      self:updateDisplay()
      self:updateHistory()
    end)
    if not(ok) then
      Player.print("Formula is not valid!")
    end
  end
  if event.action == "selected-key" then
    if event.item1 == "enter" then
      local ok , err = pcall(function()
        local calculator_value = User.getParameter("calculator_value") or 0
        local result = formula(calculator_value)
        self:addHistory(calculator_value, result)
        User.setParameter("calculator_value", result or 0)
        self:updateDisplay()
        self:updateHistory()
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    elseif event.item1 == "clear" then
      User.setParameter("calculator_value", 0)
      self:updateDisplay()
    else
      local calculator_value = User.getParameter("calculator_value") or 0
      if calculator_value == 0 then calculator_value = "" end
      User.setParameter("calculator_value", calculator_value..event.item1)
      self:updateDisplay()
    end
  end
end

-------------------------------------------------------------------------------
-- Add history
--
-- @function [parent=#Calculator] addHistory
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
-- @function [parent=#Calculator] onUpdate
--
-- @param #LuaEvent event
--
function Calculator:onUpdate(event)
  self:updateDisplay()
  self:updateKeyboard()
  self:updateHistory()
end

-------------------------------------------------------------------------------
-- Update display
--
-- @function [parent=#Calculator] updateDisplay
--
function Calculator:updateDisplay()
  local keyboard_panel = self:getFrameDeepPanel("display")
  keyboard_panel.clear()

  local calculator_value = User.getParameter("calculator_value") or 0
  display_panel = GuiElement.add(keyboard_panel, GuiTextField(self.classname, "compute"):text(calculator_value):style("helmod_textfield_calculator"))
  --display_panel.style.horizontally_stretchable = true
  display_panel.style.width=352
  display_panel.style.horizontal_align = "right"
  display_panel.focus()
end
-------------------------------------------------------------------------------
-- Update keyboard
--
-- @function [parent=#Calculator] updateKeyboard
--
function Calculator:updateKeyboard()
  local _,keyboard_panel = self:getColumnPanel()
  keyboard_panel.clear()

  local table_panel = GuiElement.add(keyboard_panel, GuiTable("keys"):column(4))
  local keys = {}
  table.insert(keys, {key="clear" ,caption="C", tooltip="clear"})
  table.insert(keys, {key="(" ,caption="("})
  table.insert(keys, {key=")" ,caption=")"})
  table.insert(keys, {key="" ,caption=""})

  table.insert(keys, {key="" ,caption=""})
  table.insert(keys, {key="^" ,caption="^", tooltip="x pow y"})
  table.insert(keys, {key="%" ,caption="%", tooltip="x modulo y"})
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
      GuiElement.add(table_panel, GuiLabel("vide",index))
    else
      GuiElement.add(table_panel, GuiButton(self.classname, "selected-key",button.key):caption(button.caption):tooltip(button.tooltip):style("helmod_button_calculator"))
    end
  end

end

-------------------------------------------------------------------------------
-- Update history
--
-- @function [parent=#Calculator] updateHistory
--
function Calculator:updateHistory()
  local history_panel = self:getColumnPanel()
  history_panel.clear()
  history_panel.style.width=200

  local calculator_history = User.getParameter("calculator_history") or {}
  for index, line in pairs(calculator_history) do
    GuiElement.add(history_panel, GuiLabel("history",index):caption(line))
  end

end
