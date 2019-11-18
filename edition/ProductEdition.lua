-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ProductEdition
-- @extends #AbstractEdition
--

ProductEdition = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ProductEdition] onInit
--
function ProductEdition:onInit()
  self.panelCaption = ({"helmod_product-edition-panel.title"})
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#ProductEdition] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function ProductEdition:onBeforeEvent(event)
  local close = true
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) ~= event.item1 then
    close = false
  end
  User.setParameter(self.parameterLast, event.item1)
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#ProductEdition] onClose
--
function ProductEdition:onClose()
  User.setParameter(self.parameterLast,nil)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductEdition] getInfoPanel
--
function ProductEdition:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info"] ~= nil and content_panel["info"].valid then
    return content_panel["info"]
  end
  local info_panel = GuiElement.add(content_panel, GuiFrameV("info"):style(helmod_frame_style.panel))
  info_panel.style.horizontally_stretchable = true
  return info_panel
end

-------------------------------------------------------------------------------
-- Get or create tool panel
--
-- @function [parent=#ProductEdition] getToolPanel
--
function ProductEdition:getToolPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["tool_panel"] ~= nil and content_panel["tool_panel"].valid then
    return content_panel["tool_panel"]
  end
  local tool_panel = GuiElement.add(content_panel, GuiFrameV("tool_panel"):style(helmod_frame_style.panel):caption({"helmod_product-edition-panel.tool"}))
  tool_panel.style.horizontally_stretchable = true
  return tool_panel
end

-------------------------------------------------------------------------------
-- Get or create action panel
--
-- @function [parent=#ProductEdition] getActionPanel
--
function ProductEdition:getActionPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["action_panel"] ~= nil and content_panel["action_panel"].valid then
    return content_panel["action_panel"]
  end
  local action_panel = GuiElement.add(content_panel, GuiFrameV("action_panel"):style(helmod_frame_style.panel))
  action_panel.style.horizontally_stretchable = true
  return action_panel
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#ProductEdition] after_open
--
-- @param #LuaEvent event
--
function ProductEdition:after_open(event)
  self:getInfoPanel()
end

local product = nil
local product_count = 0

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ProductEdition] onUpdate
--
-- @param #LuaEvent event
--
function ProductEdition:onUpdate(event)
  local model = Model.getModel()
  product = nil
  if model.blocks[event.item1] ~= nil then
    local block = model.blocks[event.item1]
    local block_elements = block.products
    if block.by_product == false then
      block_elements = block.ingredients
    end
    local element_name = event.item2
    if block_elements ~= nil and block_elements[element_name] ~= nil then
      product = block_elements[element_name]
      if product.input ~= nil then
        product_count = product.input
      else
        product_count = product.count
      end
    end
  end

  self:updateInfo(event)
  self:updateTool(event)
  --self:updateAction(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ProductEdition] updateInfo
--
-- @param #LuaEvent event
--
local input_quantity = nil
function ProductEdition:updateInfo(event)
  Logging:debug(self.classname, "updateInfo()", event)
  local info_panel = self:getInfoPanel()
  if product ~= nil then
    info_panel.clear()

    local table_panel = GuiElement.add(info_panel, GuiTable("input-table"):column(2))
    GuiElement.add(table_panel, GuiButtonSprite("product"):sprite(product.type, product.name))
    GuiElement.add(table_panel, GuiLabel("product-label"):caption(Player.getLocalisedName(product)))

    GuiElement.add(table_panel, GuiLabel("quantity-label"):caption({"helmod_common.quantity"}))
    local cell, button
    cell, input_quantity, button = GuiCellInput(self.classname, "product-update=ID", event.item1, product.name):text(product_count or 0):create(table_panel)
    input_quantity.focus()
    input_quantity.select_all()
  end
end

-------------------------------------------------------------------------------
-- Update action
--
-- @function [parent=#ProductEdition] updateAction
--
-- @param #LuaEvent event
--
function ProductEdition:updateAction(event)
  Logging:debug(self.classname, "updateAction()", event)
  local action_panel = self:getActionPanel()
  if product ~= nil then
    action_panel.clear()
    local action_panel = GuiElement.add(action_panel, GuiTable("table_action"):column(3))
    GuiElement.add(action_panel, GuiButton(self.classname, "product-reset=ID", event.item1, product.name):caption({"helmod_button.reset"}))
  end
end

-------------------------------------------------------------------------------
-- Update tool
--
-- @function [parent=#ProductEdition] updateTool
--
-- @param #LuaEvent event
--
function ProductEdition:updateTool(event)
  Logging:debug(self.classname, "updateTool()", event)
  local tool_panel = self:getToolPanel()
  tool_panel.clear()
  local table_panel = GuiElement.add(tool_panel, GuiTable("table-belt"):column(5))
  for key, prototype in pairs(Player.getEntityPrototypes({{filter="type", mode="or", invert=false, type="transport-belt"}})) do
    GuiElement.add(table_panel, GuiButtonSelectSprite(self.classname, "element-select=ID"):sprite("entity", prototype.name):tooltip(EntityPrototype(prototype):getLocalisedName()))
  end
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ProductEdition] onEvent
--
-- @param #LuaEvent event
--
function ProductEdition:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local model = Model.getModel()
  if User.isWriter() then
    if event.action == "product-update" then
      local products = {}

      local operation = input_quantity.text
      local ok , err = pcall(function()
        local quantity = formula(operation)
        if quantity == 0 then quantity = nil end
        ModelBuilder.updateProduct(event.item1, event.item2, quantity)
        ModelCompute.update()
        self:close()
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end
    if event.action == "element-select" then
      local belt_speed = EntityPrototype(event.item1):getBeltSpeed()

      local text = string.format("%s*1", belt_speed * Product().belt_ratio)
      GuiElement.setInputText(input_quantity, text)
      input_quantity.focus()
      input_quantity.select(string.len(text), string.len(text))
    end
  end
end
