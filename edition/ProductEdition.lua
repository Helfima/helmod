require "edition.AbstractEdition"
-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ProductEdition
-- @extends #AbstractEdition
--

ProductEdition = class(Form)

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
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ProductEdition:onBeforeEvent(event, action, item, item2, item3)
  local close = true
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) ~= item then
    close = false
  end
  User.setParameter(self.parameterLast,item)
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
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition:after_open(event, action, item, item2, item3)
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
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition:onUpdate(event, action, item, item2, item3)
  local model = Model.getModel()
  product = nil
  if model.blocks[item] ~= nil then
    local block = model.blocks[item]
    for _, element in pairs(block.products) do
      if element.name == item2 then
        product = element
        if block.input ~= nil and block.input[product.name] then
          product_count = block.input[product.name]
        else
          product_count = product.count
        end
      end
    end
  end

  self:updateInfo(item, item2, item3)
  --self:updateTool(item, item2, item3)
  self:updateAction(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ProductEdition] updateInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--

function ProductEdition:updateInfo(item, item2, item3)
  Logging:debug(self.classname, "updateInfo():", item, item2, item3)
  local info_panel = self:getInfoPanel()
  if product ~= nil then
    info_panel.clear()

    local tablePanel = ElementGui.addGuiTable(info_panel,"table-header",2)
    ElementGui.addGuiButtonSprite(tablePanel, "product", Player.getIconType(product), product.name)
    ElementGui.addGuiLabel(tablePanel, "product-label", Player.getLocalisedName(product))

    ElementGui.addGuiLabel(tablePanel, "quantity-label", ({"helmod_common.quantity"}))
    local textfield = ElementGui.addGuiText(tablePanel, string.format("%s=product-update=ID=%s=%s",self.classname,item,product.name), product_count or 0, nil, ({"tooltip.formula-allowed"}))
    textfield.focus()
    textfield.select_all()
  end
end

-------------------------------------------------------------------------------
-- Update action
--
-- @function [parent=#ProductEdition] updateAction
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition:updateAction(item, item2, item3)
  Logging:debug(self.classname, "updateAction():", item, item2, item3)
  local action_panel = self:getActionPanel()
  if product ~= nil then
    action_panel.clear()
    local action_panel = ElementGui.addGuiTable(action_panel,"table_action",3)
    ElementGui.addGuiButton(action_panel, self.classname.."=product-reset=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.reset"}))
  end
end

-------------------------------------------------------------------------------
-- Update tool
--
-- @function [parent=#ProductEdition] updateTool
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
local belt_count = 1
function ProductEdition:updateTool(item, item2, item3)
  Logging:debug(self.classname, "updateTool():", item, item2, item3)
  local tool_panel = self:getToolPanel()
  tool_panel.clear()
  local table_panel = ElementGui.addGuiTable(tool_panel,"table-header",1)
  ItemPrototype.load("transport-belt").getLocalisedName()
  ElementGui.addGuiLabel(table_panel, "quantity-label", {"helmod_product-edition-panel.transport-belt"})
  ElementGui.addGuiText(table_panel, "quantity", belt_count)

  local table_panel = ElementGui.addGuiTable(tool_panel,"table-belt",5)
  for key, prototype in pairs(Player.getEntityPrototypes({"transport-belt"})) do
    ElementGui.addGuiButtonSelectSprite(table_panel, self.classname.."=element-select=ID=", Player.getEntityIconType(prototype), prototype.name, prototype.name, EntityPrototype.load(prototype).getLocalisedName())
  end
end
-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ProductEdition] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition:onEvent(event, action, item, item2, item3)
  Logging:debug(self.classname, "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "product-update" then
      local products = {}

      local operation = event.element.text
      local ok , err = pcall(function()
        local quantity = formula(operation)

        ModelBuilder.updateProduct(item, item2, quantity)
        ModelCompute.update()
        self:close()
        Event.force_open = true
        Event.force_refresh = true
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end
    if action == "product-reset" then
      local products = {}
      local inputPanel = self:getInfoPanel()["table-header"]

      ModelBuilder.updateProduct(item, item2, nil)
      ModelCompute.update()
      self:close()
      Event.force_open = true
      Event.force_refresh = true
    end
    if action == "element-select" then
      local input_panel = self:getToolPanel()["table-header"]
      local belt_count = ElementGui.getInputNumber(input_panel["quantity"])
      local belt_speed = EntityPrototype.load(item).getBeltSpeed()

      local output_panel = self:getInfoPanel()["table-header"]
      ElementGui.setInputNumber(output_panel["quantity"], belt_count * belt_speed * Product.belt_ratio)
    end
  end
end
