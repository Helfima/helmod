-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module PinPanel
-- @extends #Dialog
--

PinPanel = setclass("HMPinPanel", Dialog)

local display_pin_level_min = 0
local display_pin_level_max = 4

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PinPanel] onInit
--
-- @param #Controller parent parent controller
--
function PinPanel.methods:onInit(parent)
  self.panelCaption = ({"helmod_pin-tab-panel.title"})
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PinPanel] getParentPanel
--
-- @return #LuaGuiElement
--
function PinPanel.methods:getParentPanel()
  return self.parent:getPinTabPanel()
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PinPanel] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function PinPanel.methods:onOpen( event, action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  local close = true
  if globalGui.pinBlock == nil or globalGui.pinBlock ~= item then
    close = false
  end
  globalGui.pinBlock = item
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PinPanel] onClose
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:onClose(event, action, item, item2, item3)
  local globalGui = Player.getGlobalGui()
  globalGui.pinBlock = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PinPanel] getInfoPanel
--
function PinPanel.methods:getInfoPanel()
  local panel = self:getPanel(player)
  if panel["info-panel"] ~= nil and panel["info-panel"].valid then
    return panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = ElementGui.addGuiFrameV(panel, "info-panel", "helmod_frame_resize_row_width")
  return ElementGui.addGuiScrollPane(mainPanel, "scroll-panel", "helmod_scroll_block_pin_tab", "auto", "auto")
end

-------------------------------------------------------------------------------
-- Get or create header panel
--
-- @function [parent=#PinPanel] getHeaderPanel
--
function PinPanel.methods:getHeaderPanel()
  local panel = self:getPanel()
  if panel["header"] ~= nil and panel["header"].valid then
    return panel["header"]
  end
  return ElementGui.addGuiFrameH(panel, "header", "helmod_frame_resize_row_width")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PinPanel] afterOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:afterOpen(event, action, item, item2, item3)
  self:updateHeader(event, action, item, item2, item3)
  self:getInfoPanel()
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PinPanel] onUpdate
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:onUpdate(event, action, item, item2, item3)
  self:updateInfo(event, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PinPanel] updateInfo
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:updateHeader(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", action, item, item2, item3)
  local header_panel = self:getHeaderPanel()
  local model = Model.getModel()

  ElementGui.addGuiButton(header_panel, self:classname().."=CLOSE", nil, "helmod_button_icon_close_red", nil, ({"helmod_button.close"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=down", nil, "helmod_button_icon_arrow_left", nil, ({"helmod_button.minimize"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=up", nil, "helmod_button_icon_arrow_right", nil, ({"helmod_button.minimize"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=min", nil, "helmod_button_icon_minimize", nil, ({"helmod_button.minimize"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID=max", nil, "helmod_button_icon_maximize", nil, ({"helmod_button.maximize"}))

end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PinPanel] updateInfo
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:updateInfo(event, action, item, item2, item3)
  Logging:debug(self:classname(), "updateInfo():", action, item, item2, item3)
  local infoPanel = self:getInfoPanel()
  local model = Model.getModel()
  local globalGui = Player.getGlobalGui()

  for k,guiName in pairs(infoPanel.children_names) do
    infoPanel[guiName].destroy()
  end

  local column = Player.getGlobalSettings("display_pin_level") + 1

  if globalGui.pinBlock ~= nil and model.blocks[globalGui.pinBlock] ~= nil then
    local block = model.blocks[globalGui.pinBlock]

    local resultTable = ElementGui.addGuiTable(infoPanel,"list-data",column, "helmod_table-odd")

    self:addProductionBlockHeader(resultTable)
    for _, recipe in spairs(block.recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addProductionBlockRow(resultTable, globalGui.pinBlock, recipe)
    end

  end
end

-------------------------------------------------------------------------------
-- Add header data tab
--
-- @function [parent=#PinPanel] addProductionBlockHeader
--
-- @param #LuaGuiElement itable container for element
--
function PinPanel.methods:addProductionBlockHeader(itable)
  Logging:debug(self:classname(), "addProductionBlockHeader():", itable)
  local display_pin_level = Player.getGlobalSettings("display_pin_level")
  local model = Model.getModel()

  if display_pin_level > 0 then
    local guiRecipe = ElementGui.addGuiFlowH(itable,"header-recipe")
    ElementGui.addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
  end

  if display_pin_level > 3 then
    local guiProducts = ElementGui.addGuiFlowH(itable,"header-products")
    ElementGui.addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-products"}))
  end

  if display_pin_level > 0 then
    local guiFactory = ElementGui.addGuiFlowH(itable,"header-factory")
    ElementGui.addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))
  end

  if display_pin_level > 2 then
    local guiIngredients = ElementGui.addGuiFlowH(itable,"header-ingredients")
    ElementGui.addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
  end

  if display_pin_level > 1 then
    local guiBeacon = ElementGui.addGuiFlowH(itable,"header-beacon")
    ElementGui.addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
  end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PinPanel] addProductionBlockRow
--
-- @param #LuaGuiElement guiTable
-- @param #string blockId
-- @param #table element production recipe
--
function PinPanel.methods:addProductionBlockRow(guiTable, blockId, recipe)
  Logging:debug(self:classname(), "addProductionBlockRow():", guiTable, blockId, recipe)
  local display_pin_level = Player.getGlobalSettings("display_pin_level")
  local model = Model.getModel()
  local lua_recipe = RecipePrototype.load(recipe).native()
  if display_pin_level > 0 then
    -- col recipe
    local guiRecipe = ElementGui.addGuiFlowH(guiTable,"recipe"..recipe.id, "helmod_flow_default")
    ElementGui.addGuiButtonSprite(guiRecipe, "PinPanel_recipe_"..blockId.."=", Player.getRecipeIconType(recipe), recipe.name, recipe.name, Player.getRecipeLocalisedName(recipe))
  end

  if display_pin_level > 3 then
    -- products
    local tProducts = ElementGui.addGuiTable(guiTable,"products_"..recipe.id, 3)
    if RecipePrototype.getProducts() ~= nil then
      for r, product in pairs(RecipePrototype.getProducts()) do
        local cell = ElementGui.addGuiFlowH(tProducts,"cell_"..product.name, "helmod_flow_default")
        local amount = Product.getElementAmount(product)
        ElementGui.addGuiLabel(cell, product.name, amount, "helmod_label_sm")
        -- product = {type="item", name="steel-plate", amount=8}
        ElementGui.addGuiButtonSpriteSm(cell, self:classname().."=do_noting=ID="..blockId.."="..recipe.name.."=", Player.getIconType(product), product.name, "X"..amount, Player.getLocalisedName(product))
      end
    end
  end

  if display_pin_level > 0 then
    -- col factory
    local guiFactory = ElementGui.addGuiFlowH(guiTable,"factory"..recipe.id, "helmod_flow_default")
    local factory = recipe.factory
    ElementGui.addGuiLabel(guiFactory, factory.name, Format.formatNumberFactory(factory.limit_count), "helmod_label_right_30")
    ElementGui.addGuiButtonSprite(guiFactory, "PinPanel_recipe_"..blockId.."="..recipe.name.."=", Player.getIconType(factory), factory.name, factory.name, Player.getLocalisedName(factory))
    local guiFactoryModule = ElementGui.addGuiTable(guiFactory,"factory-modules"..recipe.name, 2, "helmod_factory_modules")
    -- modules
    for name, count in pairs(factory.modules) do
      for index = 1, count, 1 do
        ElementGui.addGuiButtonSpriteSm(guiFactoryModule, "HMFactorySelector_factory-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
        index = index + 1
      end
    end
  end

  if display_pin_level > 2 then
    -- ingredients
    local tIngredient = ElementGui.addGuiTable(guiTable,"ingredients_"..recipe.id, 3)
    if RecipePrototype.getIngredients() ~= nil then
      for r, ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
        local cell = ElementGui.addGuiFlowH(tIngredient,"cell_"..ingredient.name, "helmod_flow_default")
        local amount = Product.getElementAmount(ingredient)
        ElementGui.addGuiLabel(cell, ingredient.name, amount, "helmod_label_sm")
        -- ingredient = {type="item", name="steel-plate", amount=8}
        ElementGui.addGuiButtonSpriteSm(cell, self:classname().."=do_noting=ID="..blockId.."="..recipe.name.."=", Player.getIconType(ingredient), ingredient.name, "X"..amount, Player.getLocalisedName(ingredient))
      end
    end
  end

  if display_pin_level > 1 then
    -- col beacon
    local guiBeacon = ElementGui.addGuiFlowH(guiTable,"beacon"..recipe.id, "helmod_flow_default")
    local beacon = recipe.beacon
    ElementGui.addGuiLabel(guiBeacon, beacon.name, Format.formatNumberFactory(beacon.limit_count), "helmod_label_right_30")
    ElementGui.addGuiButtonSprite(guiBeacon, "PinPanel_recipe_"..blockId.."="..recipe.name.."=", Player.getIconType(beacon), beacon.name, beacon.name, Player.getLocalisedName(beacon))
    local guiBeaconModule = ElementGui.addGuiTable(guiBeacon,"beacon-modules"..recipe.name, 1, "helmod_beacon_modules")
    -- modules
    for name, count in pairs(beacon.modules) do
      for index = 1, count, 1 do
        ElementGui.addGuiButtonSpriteSm(guiBeaconModule, "HMFactorySelector_beacon-module_"..name.."_"..index, "item", name, nil, ElementGui.getTooltipModule(name))
        index = index + 1
      end
    end
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PinPanel] onEvent
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PinPanel.methods:onEvent(event, action, item, item2, item3)
  Logging:debug(self:classname(), "onEvent():", action, item, item2, item3)
  local model = Model.getModel()
  local global_settings = Player.getGlobalSettings()
  local global_gui = Player.getGlobalGui()

  if action == "change-level" then
    local display_pin_level = Player.getGlobalSettings("display_pin_level")
    Logging:debug(self:classname(), "display_pin_level", display_pin_level)
    if item == "down" and display_pin_level > display_pin_level_min  then global_settings["display_pin_level"] = display_pin_level - 1 end
    if item == "up" and display_pin_level < display_pin_level_max  then global_settings["display_pin_level"] = display_pin_level + 1 end
    if item == "min" then global_settings["display_pin_level"] = display_pin_level_min end
    if item == "max" then global_settings["display_pin_level"] = display_pin_level_max end
    self:updateInfo(event, action, global_gui.pinBlock, item2, item3)
  end
end
