-------------------------------------------------------------------------------
-- Classe to build product edition dialog
--
-- @module PlannerProductEdition
-- @extends #PlannerDialog
--

PlannerProductEdition = setclass("HMPlannerProductEdition", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerProductEdition] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerProductEdition.methods:on_init(parent)
  self.panelCaption = ({"helmod_product-edition-panel.title"})
  self.player = self.parent.player
  self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerProductEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerProductEdition.methods:getParentPanel(player)
  return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerProductEdition] on_open
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
function PlannerProductEdition.methods:on_open(player, element, action, item, item2, item3)
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
-- @function [parent=#PlannerProductEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerProductEdition.methods:on_close(player, element, action, item, item2, item3)
  local model = self.model:getModel(player)
  model.guiProductLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerProductEdition] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerProductEdition.methods:getInfoPanel(player)
  local panel = self:getPanel(player)
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  return self:addGuiFrameV(panel, "info", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create buttons panel
--
-- @function [parent=#PlannerProductEdition] getButtonsPanel
--
-- @param #LuaPlayer player
--
function PlannerProductEdition.methods:getButtonsPanel(player)
  local panel = self:getPanel(player)
  if panel["buttons"] ~= nil and panel["buttons"].valid then
    return panel["buttons"]
  end
  return self:addGuiFlowH(panel, "buttons")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerProductEdition] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerProductEdition.methods:after_open(player, element, action, item, item2, item3)
  self.parent:send_event(player, "HMPlannerRecipeEdition", "CLOSE")
  self.parent:send_event(player, "HMPlannerRecipeSelector", "CLOSE")
  self.parent:send_event(player, "HMPlannerSettings", "CLOSE")
  self:getInfoPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerProductEdition] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerProductEdition.methods:on_update(player, element, action, item, item2, item3)
  self:updateInfo(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerProductEdition] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerProductEdition.methods:updateInfo(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerProductEdition", "updateInfo():",player, element, action, item, item2, item3)
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
-- @function [parent=#PlannerProductEdition] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerProductEdition.methods:on_event(player, element, action, item, item2, item3)
  Logging:debug("HMPlannerProductEdition", "on_event():",player, element, action, item, item2, item3)
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
