-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ProductEdition
-- @extends #Dialog
--

ProductEdition = setclass("HMProductEdition", Dialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ProductEdition] onInit
--
-- @param #Controller parent parent controller
--
function ProductEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_product-edition-panel.title"})
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#ProductEdition] getParentPanel
--
-- @return #LuaGuiElement
--
function ProductEdition.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#ProductEdition] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ProductEdition.methods:onOpen(event, action, item, item2, item3)
  local player_gui = Player.getGlobalGui()
  local close = true
  if player_gui.guiProductLast == nil or player_gui.guiProductLast ~= item then
    close = false
  end
  player_gui.guiProductLast = item
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#ProductEdition] onClose
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition.methods:onClose(event, action, item, item2, item3)
  local player_gui = Player.getGlobalGui()
  player_gui.guiProductLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductEdition] getInfoPanel
--
function ProductEdition.methods:getInfoPanel()
  local panel = self:getPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.panel)
end

-------------------------------------------------------------------------------
-- Get or create tool panel
--
-- @function [parent=#ProductEdition] getToolPanel
--
function ProductEdition.methods:getToolPanel()
  local panel = self:getPanel()
  if panel["tool_panel"] ~= nil and panel["tool_panel"].valid then
    return panel["tool_panel"]
  end
  return ElementGui.addGuiFrameV(panel, "tool_panel", helmod_frame_style.panel, {"helmod_product-edition-panel.tool"})
end

-------------------------------------------------------------------------------
-- Get or create action panel
--
-- @function [parent=#ProductEdition] getActionPanel
--
function ProductEdition.methods:getActionPanel()
  local panel = self:getPanel()
  if panel["action_panel"] ~= nil and panel["action_panel"].valid then
    return panel["action_panel"]
  end
  return ElementGui.addGuiFrameV(panel, "action_panel", helmod_frame_style.panel)
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
function ProductEdition.methods:after_open(event, action, item, item2, item3)
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
function ProductEdition.methods:onUpdate(event, action, item, item2, item3)
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
  self:updateTool(item, item2, item3)
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

function ProductEdition.methods:updateInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateInfo():", item, item2, item3)
  local info_panel = self:getInfoPanel()
  if product ~= nil then
    info_panel.clear()

    local tablePanel = ElementGui.addGuiTable(info_panel,"table-header",2)
    ElementGui.addGuiButtonSprite(tablePanel, "product", Player.getIconType(product), product.name)
    ElementGui.addGuiLabel(tablePanel, "product-label", Player.getLocalisedName(product))

    ElementGui.addGuiLabel(tablePanel, "quantity-label", ({"helmod_common.quantity"}))
    ElementGui.addGuiText(tablePanel, "quantity", product_count or 0)
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
function ProductEdition.methods:updateAction(item, item2, item3)
  Logging:debug(self:classname(), "updateAction():", item, item2, item3)
  local action_panel = self:getActionPanel()
  if product ~= nil then
    action_panel.clear()
    local action_panel = ElementGui.addGuiTable(action_panel,"table_action",3)
    ElementGui.addGuiButton(action_panel, self:classname().."=product-update=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.save"}))
    ElementGui.addGuiButton(action_panel, self:classname().."=product-reset=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.reset"}))
    ElementGui.addGuiButton(action_panel, self:classname().."=CLOSE=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.close"}))
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
function ProductEdition.methods:updateTool(item, item2, item3)
  Logging:debug(self:classname(), "updateTool():", item, item2, item3)
  local tool_panel = self:getToolPanel()
  tool_panel.clear()
  local table_panel = ElementGui.addGuiTable(tool_panel,"table-header",1)
  ItemPrototype.load("transport-belt").getLocalisedName()
  ElementGui.addGuiLabel(table_panel, "quantity-label", {"helmod_product-edition-panel.transport-belt"})
  ElementGui.addGuiText(table_panel, "quantity", belt_count)
  
  local table_panel = ElementGui.addGuiTable(tool_panel,"table-belt",5)
  for key, prototype in pairs(Player.getEntityPrototypes({"transport-belt"})) do
    ElementGui.addGuiButtonSelectSprite(table_panel, self:classname().."=element-select=ID=", Player.getEntityIconType(prototype), prototype.name, prototype.name, EntityPrototype.load(prototype).getLocalisedName())
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
function ProductEdition.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "product-update" then
      local products = {}
      local input_panel = self:getInfoPanel()["table-header"]
      local quantity = ElementGui.getInputNumber(input_panel["quantity"])

      ModelBuilder.updateProduct(item, item2, quantity)
      ModelCompute.update()
      self.parent:refreshDisplayData(nil, item, item2)
      self:close()
    end
    if action == "product-reset" then
      local products = {}
      local inputPanel = self:getInfoPanel()["table-header"]

      ModelBuilder.updateProduct(item, item2, nil)
      ModelCompute.update()
      self.parent:refreshDisplayData(nil, item, item2)
      self:close()
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
