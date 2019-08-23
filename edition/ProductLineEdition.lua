-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module ProductLineEdition
-- @extends #AbstractEdition
--

ProductLineEdition = setclass("HMProductLineEdition", AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ProductLineEdition] onInit
--
-- @param #Controller parent parent controller
--
function ProductLineEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_result-panel.tab-title-production-line"})
  self.panelClose = false
  self.parameterLast = string.format("%s_%s",self:classname(),"last")
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#ProductLineEdition] onBeforeEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ProductLineEdition.methods:onBeforeEvent(event, action, item, item2, item3)
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
-- @function [parent=#ProductLineEdition] onClose
--
function ProductLineEdition.methods:onClose()
  User.setParameter(self.parameterLast,nil)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ProductLineEdition] getInfoPanel
--
function ProductLineEdition.methods:getInfoPanel()
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
-- @function [parent=#ProductLineEdition] getOutputPanel
--
function ProductLineEdition.methods:getOutputPanel()
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
-- @function [parent=#ProductLineEdition] getInputPanel
--
function ProductLineEdition.methods:getInputPanel()
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
-- @function [parent=#ProductLineEdition] after_open
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:after_open(event, action, item, item2, item3)
  self:getInfoPanel()
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ProductLineEdition] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:onUpdate(event, action, item, item2, item3)
  self:updateInfo(item, item2, item3)
  self:updateOutput(item, item2, item3)
  self:updateInput(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductLineEdition] updateInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:updateInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateInfo", item, item2, item3)
  local model = Model.getModel()
  Logging:debug(self:classname(), "model:", model)
  -- data
  local info_panel = self:getInfoPanel()
  info_panel.clear()
  -- info panel
  local block_scroll = ElementGui.addGuiScrollPane(info_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(block_scroll, "scroll_block", "height")
  local block_table = ElementGui.addGuiTable(block_scroll,"output-table",2)

  ElementGui.addGuiLabel(block_table, "label-owner", ({"helmod_result-panel.owner"}))
  ElementGui.addGuiLabel(block_table, "value-owner", model.owner)

  ElementGui.addGuiLabel(block_table, "label-share", ({"helmod_result-panel.share"}))

  local tableAdminPanel = ElementGui.addGuiTable(block_table, "table" , 9)
  local model_read = false
  if model.share ~= nil and  bit32.band(model.share, 1) > 0 then model_read = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=read="..model.id, model_read, nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-read", "R", nil, ({"tooltip.share-mod", {"helmod_common.reading"}}))

  local model_write = false
  if model.share ~= nil and  bit32.band(model.share, 2) > 0 then model_write = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=write="..model.id, model_write, nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-write", "W", nil, ({"tooltip.share-mod", {"helmod_common.writing"}}))

  local model_delete = false
  if model.share ~= nil and bit32.band(model.share, 4) > 0 then model_delete = true end
  ElementGui.addGuiCheckbox(tableAdminPanel, self:classname().."=share-model=ID=delete="..model.id, model_delete, nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))
  ElementGui.addGuiLabel(tableAdminPanel, self:classname().."=share-model-delete", "X", nil, ({"tooltip.share-mod", {"helmod_common.removal"}}))

  local count_block = Model.countBlocks()
  if count_block > 0 then
    -- info panel
    ElementGui.addGuiLabel(block_table, "label-power", ({"helmod_label.electrical-consumption"}))
    if model.summary ~= nil then
      ElementGui.addGuiLabel(block_table, "power", Format.formatNumberKilo(model.summary.energy or 0, "W"))
    end
  end

end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductLineEdition] updateInput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:updateInput(item, item2, item3)
  Logging:debug(self:classname(), "updateInput", item, item2, item3)
  local model = Model.getModel()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local input_panel = self:getInputPanel()
  input_panel.clear()
  -- input panel
  local input_scroll = ElementGui.addGuiScrollPane(input_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(input_scroll, "scroll_block_element", "height")

  local count_block = Model.countBlocks()
  if count_block > 0 then

    local input_table = ElementGui.addGuiTable(input_scroll,"input-table", 5, "helmod_table_element")
    if model.ingredients ~= nil then
      for index, element in pairs(model.ingredients) do
        ElementGui.addCellElement(input_table, element, self:classname().."=production-block-add=ID=new="..element.name.."=", true, "tooltip.add-recipe", ElementGui.color_button_add, index)
      end
    end

  end
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ProductLineEdition] updateOutput
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ProductLineEdition.methods:updateOutput(item, item2, item3)
  Logging:debug(self:classname(), "updateOutput", item, item2, item3)
  local model = Model.getModel()
  Logging:debug("ProductionBlockTab", "model:", model)
  -- data
  local output_panel = self:getOutputPanel()
  output_panel.clear()
  -- ouput panel
  local output_scroll = ElementGui.addGuiScrollPane(output_panel, "output-scroll", helmod_frame_style.scroll_pane, true)
  ElementGui.setStyle(output_scroll, "scroll_block_element", "height")

  -- production block result
  local count_block = Model.countBlocks()
  if count_block > 0 then

    -- ouput panel
    local output_table = ElementGui.addGuiTable(output_scroll,"output-table", 5, "helmod_table_element")
    if model.products ~= nil then
      for index, element in pairs(model.products) do
        ElementGui.addCellElement(output_table, element, self:classname().."=product-selected=ID=new="..element.name.."=", false, "tooltip.product", nil, index)
      end
    end
    
  end
end
