-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module LogisticEdition
-- @extends #AbstractEdition
--

LogisticEdition = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#LogisticEdition] onInit
--
function LogisticEdition:onInit()
  self.panelCaption = ({"helmod_panel.logistic-edition"})
end

-------------------------------------------------------------------------------
-- On Style
--
-- @function [parent=#LogisticEdition] onStyle
--
-- @param #table styles
-- @param #number width_main
-- @param #number height_main
--
function LogisticEdition:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_height = 100,
    maximal_height = height_main,
  }
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#LogisticEdition] onBind
--
function LogisticEdition:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#LogisticEdition] onUpdate
--
-- @param #LuaEvent event
--
function LogisticEdition:onUpdate(event)
  self:updateItemsLogistic(event)
end

-------------------------------------------------------------------------------
-- On scroll width
--
-- @function [parent=#LogisticEdition] getSrollWidth
--
function LogisticEdition:getSrollWidth()
  local number_column = User.getPreferenceSetting("preference_number_column")
  return 38 * (number_column or 6) + 20
end

-------------------------------------------------------------------------------
-- On scroll height
--
-- @function [parent=#LogisticEdition] getSrollHeight
--
function LogisticEdition:getSrollHeight()
  local number_line = User.getPreferenceSetting("preference_number_line")
  return 38 * (number_line or 3) + 4
end

-------------------------------------------------------------------------------
-- Update items logistic
--
-- @function [parent=#LogisticEdition] updateItemsLogistic
--
-- @param #LuaEvent event
--

function LogisticEdition:updateItemsLogistic(event)
  local number_column = User.getPreferenceSetting("preference_number_column")
  local container_panel = self:getFramePanel("information")
  container_panel.clear()

  if event.item1 == "item" then
    local type = User.getParameter("logistic_row_item") or "belt"
    local type_table_panel = GuiElement.add(container_panel, GuiTable(string.format("%s-selector-table", type)):column(number_column))
    
    local item_logistic = Player.getDefaultItemLogistic(type)
    for key, entity in pairs(Player.getItemsLogistic(type)) do
      local color = nil
      if entity.name == item_logistic then color = "green" end
      local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "items-logistic-select", type):choose("entity", entity.name):color(color))
      button.locked = true
    end
  end
  if event.item1 == "fluid" then
    local type = User.getParameter("logistic_row_fluid") or "pipe"
    local type_table_panel = GuiElement.add(container_panel, GuiTable(string.format("%s-selector-table", type)):column(number_column))
    
    local fluid_logistic = Player.getDefaultFluidLogistic(type)
    for key, entity in pairs(Player.getFluidsLogistic(type)) do
      local color = nil
      if entity.name == fluid_logistic then color = "green" end
      local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "fluids-logistic-select", type):choose("entity", entity.name):color(color))
      button.locked = true
    end
  end
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#LogisticEdition] onEvent
--
-- @param #LuaEvent event
--
function LogisticEdition:onEvent(event)
  if event.action == "items-logistic-select" then
    User.setParameter(string.format("items_logistic_%s", event.item1), event.item2)
    self:close()
    Controller:send("on_gui_refresh", event)
  end
  
  if event.action == "fluids-logistic-select" then
    User.setParameter(string.format("fluids_logistic_%s", event.item1), event.item2)
    self:close()
    Controller:send("on_gui_refresh", event)
  end
  
  if event.action == "fluids-logistic-flow" then
    local index = event.element.selected_index
    local fluids_logistic_maximum_flow = helmod_logistic_flow[index].flow
    User.setParameter("fluids_logistic_maximum_flow", fluids_logistic_maximum_flow)
    self:close()
    Controller:send("on_gui_refresh", event)
  end
end
