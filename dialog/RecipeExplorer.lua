-------------------------------------------------------------------------------
-- Class to build RecipeExplorer panel
--
-- @module RecipeExplorer
-- @extends #Form
--

RecipeExplorer = newclass(Form)

local display_panel = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#RecipeExplorer] init
--
function RecipeExplorer:onInit()
  self.panelCaption = ({"helmod_recipe-explorer-panel.title"})
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#RecipeExplorer] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function RecipeExplorer:onBeforeEvent(event)
  -- close si nouvel appel
  return true
end


-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeExplorer] updateHeader
--
-- @param #LuaEvent event
--
function RecipeExplorer:updateHeader(event)
  Logging:debug(self.classname, "updateHeader()", event)
  local left_menu_panel = self:getLeftMenuPanel()
  left_menu_panel.clear()
  local group1 = GuiElement.add(left_menu_panel, GuiFlowH("group1"))
  GuiElement.add(group1, GuiButton("HMRecipeSelector", "OPEN"):sprite("menu", "arrow-left-white", "arrow-left"):style("helmod_button_menu"):tooltip({"helmod_button.decrease"}))
end

-------------------------------------------------------------------------------
-- Get or create column panel
--
-- @function [parent=#RecipeExplorer] getColumnPanel
--
function RecipeExplorer:getColumnPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["main_panel"] ~= nil and content_panel["main_panel"].valid then
    return content_panel["main_panel"]["display_panel1"], content_panel["main_panel"]["display_panel2"]
  end
  local panel = GuiElement.add(content_panel, GuiFlowH("main_panel"))
  local display_panel1 = GuiElement.add(panel, GuiFlowV("display_panel1"))
  local display_panel2 = GuiElement.add(panel, GuiFlowV("display_panel2"))
  display_panel2.style.width=200

  return display_panel1, display_panel2
end

-------------------------------------------------------------------------------
-- Get or create display panel
--
-- @function [parent=#RecipeExplorer] getDisplayPanel
--
function RecipeExplorer:getDisplayPanel()
  local display_panel1, display_panel2 = self:getColumnPanel()
  if display_panel1["display"] ~= nil and display_panel1["display"].valid then
    return display_panel1["display"]
  end
  return GuiElement.add(display_panel1, GuiFrameV("display"):style(helmod_frame_style.panel))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#RecipeExplorer] onEvent
--
-- @param #LuaEvent event
--
function RecipeExplorer:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  -- import
  if event.action == "compute" then
    local text = event.element.text
    local ok , err = pcall(function()
      local result = formula(text)
      self:addHistory(text, result)
      User.setParameter("RecipeExplorer_value", result or 0)
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
        local RecipeExplorer_value = User.getParameter("RecipeExplorer_value") or 0
        local result = formula(RecipeExplorer_value)
        self:addHistory(RecipeExplorer_value, result)
        User.setParameter("RecipeExplorer_value", result or 0)
        self:updateDisplay()
        self:updateHistory()
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    elseif event.item1 == "clear" then
      User.setParameter("RecipeExplorer_value", 0)
      self:updateDisplay()
    else
      local RecipeExplorer_value = User.getParameter("RecipeExplorer_value") or 0
      if RecipeExplorer_value == 0 then RecipeExplorer_value = "" end
      User.setParameter("RecipeExplorer_value", RecipeExplorer_value..event.item1)
      self:updateDisplay()
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RecipeExplorer] onUpdate
--
-- @param #LuaEvent event
--
function RecipeExplorer:onUpdate(event)
  self:updateHeader(event)
  self:updateDisplay()
end

-------------------------------------------------------------------------------
-- Update display
--
-- @function [parent=#RecipeExplorer] updateDisplay
--
function RecipeExplorer:updateDisplay()
  Logging:debug(self.classname, "updateDisplay()")
  local keyboard_panel = self:getDisplayPanel()
  keyboard_panel.clear()

  
end
