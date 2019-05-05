-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ProductBlockEdition
-- @extends #Dialog
--

ProductBlockEdition = setclass("HMProductBlockEdition", AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ProductBlockEdition] onInit
--
-- @param #Controller parent parent controller
--
function ProductBlockEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_result-panel.tab-title-production-block"})
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#ProductBlockEdition] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ProductBlockEdition.methods:onBeforeEvent(event, action, item, item2, item3)
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
-- @function [parent=#ProductBlockEdition] onClose
--
function ProductBlockEdition.methods:onClose()
  local player_gui = Player.getGlobalGui()
  player_gui.guiProductLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductBlockEdition] getInfoPanel
--
function ProductBlockEdition.methods:getInfoPanel()
  local panel = self:getPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local info_panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.panel)
  info_panel.style.horizontally_stretchable = true
  return info_panel
end

-------------------------------------------------------------------------------
-- Get or create output panel
--
-- @function [parent=#ProductBlockEdition] getOutputPanel
--
function ProductBlockEdition.methods:getOutputPanel()
  local panel = self:getPanel()
  if panel["output"] ~= nil and panel["output"].valid then
    return panel["output"]
  end
  local output_panel = ElementGui.addGuiFrameV(panel, "output", helmod_frame_style.panel, ({"helmod_common.output"}))
  output_panel.style.horizontally_stretchable = true
  ElementGui.setStyle(output_panel, "block_element", "height")
  return output_panel
end

-------------------------------------------------------------------------------
-- Get or create input panel
--
-- @function [parent=#ProductBlockEdition] getInputPanel
--
function ProductBlockEdition.methods:getInputPanel()
  local panel = self:getPanel()
  if panel["input"] ~= nil and panel["input"].valid then
    return panel["input"]
  end
  local input_panel = ElementGui.addGuiFrameV(panel, "input", helmod_frame_style.panel, ({"helmod_common.input"}))
  input_panel.style.horizontally_stretchable = true
  ElementGui.setStyle(input_panel, "block_element", "height")
  return input_panel
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#ProductBlockEdition] after_open
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:after_open(event, action, item, item2, item3)
  self:getInfoPanel()
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ProductBlockEdition] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:onUpdate(event, action, item, item2, item3)
  self:updateInfo(item, item2, item3)
  self:updateOutput(item, item2, item3)
  self:updateInput(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductBlockEdition] updateInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:updateInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateInfo", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug(self:classname(), "model:", model)
  -- data
  local blockId = globalGui.currentBlock or "new"

  local countRecipes = Model.countBlockRecipes(blockId)

  local info_panel = self:getInfoPanel()
  info_panel.clear()
  -- info panel
  local block_scroll = ElementGui.addGuiScrollPane(info_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(block_scroll, "scroll_block", "height")
  local block_table = ElementGui.addGuiTable(block_scroll,"output-table",2)

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    -- block panel
    ElementGui.addGuiLabel(block_table, "label-power", ({"helmod_label.electrical-consumption"}))
    ElementGui.addGuiLabel(block_table, "power", Format.formatNumberKilo(element.power or 0, "W"),"helmod_label_right_70")

    ElementGui.addGuiLabel(block_table, "label-count", ({"helmod_label.block-number"}))
    ElementGui.addGuiLabel(block_table, "count", Format.formatNumberFactory(element.count or 0),"helmod_label_right_70")

    ElementGui.addGuiLabel(block_table, "label-sub-power", ({"helmod_label.sub-block-power"}))
    ElementGui.addGuiLabel(block_table, "sub-power", Format.formatNumberKilo(element.sub_power or 0),"helmod_label_right_70")

    ElementGui.addGuiLabel(block_table, "options-linked", ({"helmod_label.block-unlinked"}))
    local unlinked = element.unlinked and true or false
    if element.index == 0 then unlinked = true end
    ElementGui.addGuiCheckbox(block_table, self:classname().."=change-boolean-option=ID=unlinked", unlinked)

    ElementGui.addGuiLabel(block_table, "options-by-factory", ({"helmod_label.compute-by-factory"}))
    local by_factory = element.by_factory and true or false
    ElementGui.addGuiCheckbox(block_table, self:classname().."=change-boolean-option=ID=by_factory", by_factory)

    if element.by_factory == true then
      local factory_number = element.factory_number or 0
      ElementGui.addGuiLabel(block_table, "label-factory_number", ({"helmod_label.factory-number"}))
      ElementGui.addGuiText(block_table, "factory_number", factory_number, "helmod_textfield")
      ElementGui.addGuiButton(block_table, self:classname().."=change-number-option=ID=", "factory_number", "helmod_button_default", ({"helmod_button.update"}))
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductBlockEdition] updateInput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:updateInput(item, item2, item3)
  Logging:debug(self:classname(), "updateInput", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug(self:classname(), "model:", model)
  -- data
  local blockId = globalGui.currentBlock or "new"

  local countRecipes = Model.countBlockRecipes(blockId)

  local input_panel = self:getInputPanel()
  input_panel.clear()
  -- input panel
  local input_scroll = ElementGui.addGuiScrollPane(input_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(input_scroll, "scroll_block_element", "height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]
    -- input panel
    local input_table = ElementGui.addGuiTable(input_scroll,"input-table", 5, "helmod_table_element")
      if element.ingredients ~= nil then
      for index, lua_product in pairs(element.ingredients) do
        local ingredient = Product.load(lua_product).new()
        ingredient.count = lua_product.count
        if element.count > 1 then
          ingredient.limit_count = lua_product.count / element.count
        end
        ElementGui.addCellElement(input_table, ingredient, self:classname().."=product-selected=ID="..element.id.."="..ingredient.name.."=", false, "tooltip.ingredient", nil, index)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductBlockEdition] updateOutput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:updateOutput(item, item2, item3)
  Logging:debug(self:classname(), "updateOutput", item, item2, item3)
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()
  Logging:debug(self:classname(), "model:", model)
  -- data
  local blockId = globalGui.currentBlock or "new"

  local countRecipes = Model.countBlockRecipes(blockId)

  local output_panel = self:getOutputPanel()
  output_panel.clear()
  -- ouput panel
  ElementGui.setStyle(output_panel, "block_element", "height")
  local output_scroll = ElementGui.addGuiScrollPane(output_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(output_scroll, "scroll_block_element", "height")

  -- production block result
  if countRecipes > 0 then

    local element = model.blocks[blockId]

    -- ouput panel
    local output_table = ElementGui.addGuiTable(output_scroll,"output-table", 5, "helmod_table_element")
    if element.products ~= nil then
      for index, lua_product in pairs(element.products) do
        local product = Product.load(lua_product).new()
        product.count = lua_product.count
        if element.count > 1 then
          product.limit_count = lua_product.count / element.count
        end
        if bit32.band(lua_product.state, 1) > 0 then
          if element.by_factory == true then
            ElementGui.addCellElement(output_table, product, self:classname().."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.product", nil, index)
          else
            ElementGui.addCellElement(output_table, product, self:classname().."=product-edition=ID="..element.id.."="..product.name.."=", true, "tooltip.edit-product", self.color_button_edit, index)
          end
        end
        if bit32.band(lua_product.state, 2) > 0 and bit32.band(lua_product.state, 1) == 0 then
          ElementGui.addCellElement(output_table, product, self:classname().."=product-selected=ID="..element.id.."="..product.name.."=", true, "tooltip.rest-product", self.color_button_rest, index)
        end
        if lua_product.state == 0 then
          ElementGui.addCellElement(output_table, product, self:classname().."=product-selected=ID="..element.id.."="..product.name.."=", false, "tooltip.other-product", nil, index)
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ProductBlockEdition] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if action == "product-update" then
      local products = {}
      local input_panel = self:getInfoPanel()["table-header"]
      local quantity = ElementGui.getInputNumber(input_panel["quantity"])

      ModelBuilder.updateProduct(item, item2, quantity)
      ModelCompute.update()
      self:refreshDisplayData(nil, item, item2)
      self:close()
    end
    if action == "product-reset" then
      local products = {}
      local inputPanel = self:getInfoPanel()["table-header"]

      ModelBuilder.updateProduct(item, item2, nil)
      ModelCompute.update()
      self:refreshDisplayData(nil, item, item2)
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

-------------------------------------------------------------------------------
-- Get factory number
--
-- @function [parent=#ProductBlockEdition] getFactoryNumber
-- 
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductBlockEdition.methods:getFactoryNumber(item, item2, item3)
  Logging:debug(self:classname(), "getFactoryNumber()")
  local panel = self:getInfoPanel()["output-scroll"]["output-table"]
    if panel[item] ~= nil then
    return ElementGui.getInputNumber(panel[item])
   end
   return 0
end
