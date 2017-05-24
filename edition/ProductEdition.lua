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
-- @function [parent=#ProductEdition] on_init
--
-- @param #Controller parent parent controller
--
function ProductEdition.methods:on_init(parent)
  self.panelCaption = ({"helmod_product-edition-panel.title"})
  self.player = self.parent.player
  self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#ProductEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function ProductEdition.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#ProductEdition] on_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ProductEdition.methods:on_open(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
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
-- @function [parent=#ProductEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition.methods:on_close(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
  model.guiProductLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductEdition] getInfoPanel
--
-- @param #LuaPlayer player
--
function ProductEdition.methods:getInfoPanel(player)
  local panel = self:getPanel(player)
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return self:addGuiFrameV(panel, "info", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create buttons panel
--
-- @function [parent=#ProductEdition] getButtonsPanel
--
-- @param #LuaPlayer player
--
function ProductEdition.methods:getButtonsPanel(player)
  local panel = self:getPanel(player)
  if panel["buttons"] ~= nil and panel["buttons"].valid then
    return panel["buttons"]
  end
  return self:addGuiFlowH(panel, "buttons")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#ProductEdition] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition.methods:after_open(player, element, action, item, item2, item3)
  self.parent:send_event(player, "HMRecipeEdition", "CLOSE")
  self.parent:send_event(player, "HMRecipeSelector", "CLOSE")
  self.parent:send_event(player, "HMSettings", "CLOSE")
  self:getInfoPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ProductEdition] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition.methods:on_update(player, element, action, item, item2, item3)
  self:updateInfo(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ProductEdition] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition.methods:updateInfo(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "updateInfo():",player, element, action, item, item2, item3)
  local infoPanel = self:getInfoPanel(player)
  local model = self.model:getModel(player)

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

      local tablePanel = self:addGuiTable(infoPanel,"table-header",2)
      self:addGuiButtonSprite(tablePanel, "product", self.player:getIconType(product), product.name)
      self:addGuiLabel(tablePanel, "product-label", self.player:getLocalisedName(player, product))

      self:addGuiLabel(tablePanel, "quantity-label", ({"helmod_common.quantity"}))
      self:addGuiText(tablePanel, "quantity", product.count)

      self:addGuiButton(tablePanel, self:classname().."=product-update=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.save"}))
      self:addGuiButton(tablePanel, self:classname().."=CLOSE=ID="..item.."=", product.name, "helmod_button_default", ({"helmod_button.close"}))
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ProductEdition] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductEdition.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug(self:classname(), "on_event():",player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
  if self.player:isAdmin(player) or model.owner == player.name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "product-update" then
      local products = {}
      local inputPanel = self:getInfoPanel(player)["table-header"]

      local quantity = self:getInputNumber(inputPanel["quantity"])

      self.model:updateProduct(player, item, item2, quantity)
      self.model:update(player)
      self.parent:refreshDisplayData(player, nil, item, item2)
      self:close(player)
    end
  end
end
