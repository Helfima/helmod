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
  local model = Model.getModel()
  local close = true
  if model.guiProductLast == nil or model.guiProductLast ~= item then
    close = false
  end
  model.guiProductLast = item
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
  local model = Model.getModel()
  model.guiProductLast = nil
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
  return ElementGui.addGuiFrameV(panel, "info", "helmod_frame_resize_row_width")
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
  self:updateInfo(item, item2, item3)
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
  local infoPanel = self:getInfoPanel()
  local model = Model.getModel()

  if model.blocks[item] ~= nil then
    local product = nil
    for _, element in pairs(model.blocks[item].products) do
      if element.name == item2 then
        product = element
      end
    end

    if product ~= nil then
      for k,guiName in pairs(infoPanel.children_names) do
        infoPanel[guiName].destroy()
      end

      local tablePanel = ElementGui.addGuiTable(infoPanel,"table-header",2)
      ElementGui.addGuiButtonSprite(tablePanel, "product", Player.getIconType(product), product.name)
      ElementGui.addGuiLabel(tablePanel, "product-label", Player.getLocalisedName(product))

      ElementGui.addGuiLabel(tablePanel, "quantity-label", ({"helmod_common.quantity"}))
      ElementGui.addGuiText(tablePanel, "quantity", product.count)

      ElementGui.addGuiButton(tablePanel, self:classname().."=product-update=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.save"}))
      ElementGui.addGuiButton(tablePanel, self:classname().."=CLOSE=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.close"}))
    end
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
      local inputPanel = self:getInfoPanel()["table-header"]

      local quantity = ElementGui.getInputNumber(inputPanel["quantity"])

      Model.updateProduct(item, item2, quantity)
      Model.update()
      self.parent:refreshDisplayData(nil, item, item2)
      self:close()
    end
  end
end
