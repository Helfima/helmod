require "edition.AbstractEdition"
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
-- @param #Controller parent parent controller
--
function ProductEdition:onInit(parent)
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
  local info_panel = ElementGui.addGuiFrameV(content_panel, "info", helmod_frame_style.panel)
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
  local tool_panel = ElementGui.addGuiFrameV(content_panel, "tool_panel", helmod_frame_style.panel, {"helmod_product-edition-panel.tool"})
  tool_panel.style.horizontally_stretchable = true
  ElementGui.setStyle(tool_panel, "edition_product_tool", "height")
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
  local action_panel = ElementGui.addGuiFrameV(content_panel, "action_panel", helmod_frame_style.panel)
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
    for _, element in pairs(block.products) do
      if element.name == event.item2 then
        product = element
        if block.input ~= nil and block.input[product.name] then
          product_count = block.input[product.name]
        else
          product_count = product.count
        end
      end
    end
  end

  self:updateInfo(event)
  self:updateTool(event)
  self:updateAction(event)
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

    local table_panel = ElementGui.addGuiTable(info_panel,"input-table",2)
    ElementGui.addGuiButtonSprite(table_panel, "product", Player.getIconType(product), product.name)
    ElementGui.addGuiLabel(table_panel, "product-label", Player.getLocalisedName(product))

    ElementGui.addGuiLabel(table_panel, "quantity-label", ({"helmod_common.quantity"}))
    input_quantity = ElementGui.addGuiText(table_panel, string.format("%s=product-update=ID=%s=%s",self.classname,event.item1,product.name), product_count or 0, nil, ({"tooltip.formula-allowed"}))
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
    local action_panel = ElementGui.addGuiTable(action_panel,"table_action",3)
    ElementGui.addGuiButton(action_panel, self.classname.."=product-reset=ID="..event.item1.."=", product.name, "helmod_button_default", ({"helmod_button.reset"}))
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
  local table_panel = ElementGui.addGuiTable(tool_panel,"table-belt",5)
  for key, prototype in pairs(Player.getEntityPrototypes({"transport-belt"})) do
    ElementGui.addGuiButtonSelectSprite(table_panel, self.classname.."=element-select=ID=", Player.getEntityIconType(prototype), prototype.name, prototype.name, EntityPrototype(prototype):getLocalisedName())
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
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if event.action == "product-update" then
      local products = {}

      local operation = event.element.text
      local ok , err = pcall(function()
        local quantity = formula(operation)

        ModelBuilder.updateProduct(event.item1, event.item2, quantity)
        ModelCompute.update()
        self:close()
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end
    if event.action == "product-reset" then
      local products = {}
      ModelBuilder.updateProduct(event.item1, event.item2, nil)
      ModelCompute.update()
      self:close()
      Controller:send("on_gui_refresh", event)
    end
    if event.action == "element-select" then
      local belt_speed = EntityPrototype(event.item1):getBeltSpeed()

      local text = string.format("%s*1", belt_speed * Product().belt_ratio)
      ElementGui.setInputText(input_quantity, text)
      input_quantity.focus()
      input_quantity.select(string.len(text), string.len(text))
    end
  end
end
