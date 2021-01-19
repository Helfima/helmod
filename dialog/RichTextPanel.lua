-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module RichTextPanel
-- @extends #Form
--

RichTextPanel = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#RichTextPanel] onInit
--
function RichTextPanel:onInit()
  self.panelCaption = ({"helmod_panel.richtext"})
  self.otherClose = false
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#RichTextPanel] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function RichTextPanel:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 322,
    maximal_width = 322,
    minimal_height = 300,
    maximal_height = height_main
  }
end

------------------------------------------------------------------------------
-- Get Button Sprites
--
-- @function [parent=#RichTextPanel] getButtonSprites
--
-- @return boolean
--
function RichTextPanel:getButtonSprites()
  return "text-white","text"
end

-------------------------------------------------------------------------------
-- Is tool
--
-- @function [parent=#RichTextPanel] isTool
--
-- @return boolean
--
function RichTextPanel:isTool()
  return true
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RichTextPanel] onUpdate
--
-- @param #LuaEvent event
--
function RichTextPanel:onUpdate(event)
  self:updateHeader(event)
  self:updateInput(event)
  self:updateHistory(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RichTextPanel] updateHeader
--
-- @param #LuaEvent event
--
function RichTextPanel:updateHeader(event)
  local header_panel = self:getTopPanel()
  header_panel.clear()
  local element_list = {}
  table.insert(element_list, {type="item", localized_name={"helmod_common.item"}})
  table.insert(element_list, {type="fluid", localized_name={"helmod_common.fluid"}})
  table.insert(element_list, {type="recipe", localized_name={"helmod_common.recipe"}})
  table.insert(element_list, {type="entity", localized_name={"helmod_common.entity"}})
  table.insert(element_list, {type="technology", localized_name={"helmod_common.technology"}})
  
  local selectors = GuiElement.add(header_panel, GuiTable("selection"):column(#element_list))
  selectors.style.horizontal_spacing = 10
  for _,element in pairs(element_list) do
    GuiElement.add(selectors, GuiLabel("label", element.type):caption(element.localized_name))
  end
  for _,element in pairs(element_list) do
    GuiElement.add(selectors, GuiButtonSelectSprite(self.classname, "element-select", element.type):choose(element.type):color("gray"):tooltip({"helmod_button.choose-element"}))
  end
end

-------------------------------------------------------------------------------
-- Update input
--
-- @function [parent=#RichTextPanel] updateInput
--
-- @param #LuaEvent event
--
function RichTextPanel:updateInput(event)
  local input_panel = self:getFramePanel("input-panel")
  local richtext_text = User.getParameter("richtext_text")
  input_panel.clear()

  -- rich text
  local text_panel = GuiElement.add(input_panel, GuiTable("text_panel"):column(3))
  text_panel.style.cell_padding = 3
  local text_field = GuiElement.add(text_panel, GuiTextField(self.classname, "input-text", "onchange"):text(richtext_text))
  text_field.style.width = 200
  text_field.lose_focus_on_confirm = false
  text_field.focus()
  GuiElement.add(text_panel, GuiButton(self.classname, "richtext-clear"):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_actived_red"):tooltip({"helmod_button.clear"}))
  GuiElement.add(text_panel, GuiButton(self.classname, "richtext-save"):sprite("menu", "save-sm", "save-sm"):style("helmod_button_menu_sm_actived_green"):tooltip({"helmod_button.save"}))
end

-------------------------------------------------------------------------------
-- Update history
--
-- @function [parent=#RichTextPanel] updateHistory
--
-- @param #LuaEvent event
--
function RichTextPanel:updateHistory(event)
  local history_panel = self:getScrollPanel("history-panel")
  local richtext_text = User.getParameter("richtext_text")
  history_panel.clear()
  history_panel.style.vertically_stretchable = true

  -- history
  local richtext_history = User.getParameter("richtext_history") or {}
  local table_panel = GuiElement.add(history_panel, GuiTable("table_panel"):column(2))
  for index,value in pairs(richtext_history) do
    local button = GuiElement.add(table_panel, GuiButton(self.classname, "richtext-history-use", index):caption(value):style("helmod_button_left"):tooltip({"helmod_button.use"}))
    button.style.width = 250
    GuiElement.add(table_panel, GuiButton(self.classname, "richtext-history-delete", index):sprite("menu", "delete-sm", "delete-sm"):style("helmod_button_menu_sm_actived_red"):tooltip({"helmod_button.delete"}))
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#RichTextPanel] onEvent
--
-- @param #LuaEvent event
--
function RichTextPanel:onEvent(event)
  if event.action == "element-select" then
    local element_type = event.element.elem_type
    local element_name = event.element.elem_value
    event.element.elem_value = nil
    if element_name ~= nil then
      local richtext_text = User.getParameter("richtext_text") or ""
      richtext_text = string.format("%s[%s=%s]",richtext_text, element_type, element_name)
      User.setParameter("richtext_text", richtext_text)
      self:onUpdate(event)
    end
  end
  if event.action == "input-text" then
    User.setParameter("richtext_text", event.element.text)
  end
  if event.action == "richtext-clear" then
    User.setParameter("richtext_text", "")
    self:onUpdate(event)
  end
  if event.action == "richtext-save" then
    local text_field_name = table.concat({self.classname, "input-text", "onchange"},"=")
    if event.element.parent ~= nil and event.element.parent[text_field_name] ~= nil then
      local richtext_history = User.getParameter("richtext_history") or {}
      local richtext_text = event.element.parent[text_field_name].text
      table.insert(richtext_history, richtext_text)
      User.setParameter("richtext_history", richtext_history)
      self:onUpdate(event)
    end
  end
  if event.action == "richtext-history-use" then
    local richtext_history = User.getParameter("richtext_history")
    local index = tonumber(event.item1)
    if richtext_history ~= nil and richtext_history[index] ~= nil then
      User.setParameter("richtext_text", richtext_history[index])
      self:onUpdate(event)
    end
  end
  if event.action == "richtext-history-delete" then
    local richtext_history = User.getParameter("richtext_history")
    local index = tonumber(event.item1)
    if richtext_history ~= nil and richtext_history[index] ~= nil then
      table.remove(richtext_history, index)
      User.setParameter("richtext_history", richtext_history)
      self:onUpdate(event)
    end
  end
end
