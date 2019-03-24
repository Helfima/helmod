-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module PinPanel
-- @extends #Dialog
--

PinPanel = setclass("HMPinPanel", Form)

local display_pin_level_min = 0
local display_pin_level_max = 4

local display_level = {
  base = 0,
  factory = 0,
  products = 1,
  ingredients = 2,
  beacon = 3
}

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PinPanel] onInit
--
-- @param #Controller parent parent controller
--
function PinPanel.methods:onInit(parent)
  self.panelCaption = ({"helmod_pin-tab-panel.title"})
  self.otherClose = false
end


-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PinPanel] getParentPanel
--
-- @return #LuaGuiElement
--
function PinPanel.methods:getParentPanel()
  local lua_player = Player.native()
  local guiMain = lua_player.gui[self.pinLocate]
  if guiMain["helmod_planner_pin_tab"] ~= nil and guiMain["helmod_planner_pin_tab"].valid then
    return guiMain["helmod_planner_pin_tab"]
  end
  return ElementGui.addGuiFrameV(guiMain, "helmod_planner_pin_tab", helmod_frame_style.hidden)
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
function PinPanel.methods:onClose()
  local globalGui = Player.getGlobalGui()
  globalGui.pinBlock = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PinPanel] getInfoPanel
--
function PinPanel.methods:getInfoPanel()
  local panel = self:getPanel()
  if panel["info-panel"] ~= nil and panel["info-panel"].valid then
    return panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = ElementGui.addGuiFrameV(panel, "info-panel", helmod_frame_style.panel)
  return ElementGui.addGuiScrollPane(mainPanel, "scroll-panel", helmod_scroll_style.pin_tab)
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
  return ElementGui.addGuiFrameH(panel, "header", helmod_frame_style.panel)
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
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID="..item.."=down", nil, "helmod_button_icon_arrow_left", nil, ({"helmod_button.decrease"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID="..item.."=up", nil, "helmod_button_icon_arrow_right", nil, ({"helmod_button.expand"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID="..item.."=min", nil, "helmod_button_icon_minimize", nil, ({"helmod_button.minimize"}))
  ElementGui.addGuiButton(header_panel, self:classname().."=change-level=ID="..item.."=max", nil, "helmod_button_icon_maximize", nil, ({"helmod_button.maximize"}))

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

  Logging:debug(self:classname(), "updateInfo", globalGui.pinBlock, model.blocks[globalGui.pinBlock])
  if globalGui.pinBlock ~= nil and model.blocks[globalGui.pinBlock] ~= nil then
    local block = model.blocks[globalGui.pinBlock]

    local resultTable = ElementGui.addGuiTable(infoPanel,"list-data",column, "helmod_table-odd")

    self:addProductionBlockHeader(resultTable)
    for _, recipe in spairs(block.recipes, function(t,a,b) if globalGui.order.ascendant then return t[b][globalGui.order.name] > t[a][globalGui.order.name] else return t[b][globalGui.order.name] < t[a][globalGui.order.name] end end) do
      self:addProductionBlockRow(resultTable, block, recipe)
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

  if display_pin_level > display_level.base then
    local guiRecipe = ElementGui.addGuiFrameH(itable,"header-recipe", helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiRecipe, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
  end

  if display_pin_level > display_level.products then
    local guiProducts = ElementGui.addGuiFrameH(itable,"header-products", helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiProducts, "header-products", ({"helmod_result-panel.col-header-products"}))
  end

  if display_pin_level > display_level.factory then
    local guiFactory = ElementGui.addGuiFrameH(itable,"header-factory", helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiFactory, "header-factory", ({"helmod_result-panel.col-header-factory"}))
  end

  if display_pin_level > display_level.ingredients then
    local guiIngredients = ElementGui.addGuiFrameH(itable,"header-ingredients", helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiIngredients, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
  end

  if display_pin_level > display_level.beacon then
    local guiBeacon = ElementGui.addGuiFrameH(itable,"header-beacon", helmod_frame_style.hidden)
    ElementGui.addGuiLabel(guiBeacon, "header-beacon", ({"helmod_result-panel.col-header-beacon"}))
  end
end

-------------------------------------------------------------------------------
-- Add row data tab
--
-- @function [parent=#PinPanel] addProductionBlockRow
--
-- @param #LuaGuiElement gui_table
-- @param #string blockId
-- @param #table element production recipe
--
function PinPanel.methods:addProductionBlockRow(gui_table, block, recipe)
  Logging:debug(self:classname(), "addProductionBlockRow():", gui_table, block, recipe)
  local display_pin_level = Player.getGlobalSettings("display_pin_level")
  local model = Model.getModel()
  local lua_recipe = RecipePrototype.load(recipe).native()
  if display_pin_level > display_level.base then
    -- col recipe
    local cell_recipe = ElementGui.addGuiFrameH(gui_table,"recipe"..recipe.id, helmod_frame_style.hidden)
    ElementGui.addCellRecipe(cell_recipe, recipe, self:classname().."=do_noting=ID=", true, "tooltip.product", "gray")
  end

  if display_pin_level > display_level.products then
    -- products
    local cell_products = ElementGui.addGuiTable(gui_table,"products_"..recipe.id, 3)
    if RecipePrototype.getProducts() ~= nil then
      for r, lua_product in pairs(RecipePrototype.getProducts()) do
        local product = Product.load(lua_product).new()
        product.count = Product.countProduct(recipe)
        if block.count > 1 then
          product.limit_count = product.count / block.count
        end
        ElementGui.addCellElement(cell_products, product, self:classname().."=do_noting=ID=", false, "tooltip.product", nil, index)
      end
    end
  end

  if display_pin_level > display_level.factory then
    -- col factory
    local cell_factory =ElementGui.addCell(gui_table, "factory-"..recipe.id)
    local factory = recipe.factory
    ElementGui.addCellFactory(cell_factory, factory, self:classname().."=do_noting=ID=", false, "tooltip.product", "gray")
  end

  if display_pin_level > display_level.ingredients then
    -- ingredients
    local cell_ingredients = ElementGui.addGuiTable(gui_table,"ingredients_"..recipe.id, 3)
    if RecipePrototype.getIngredients() ~= nil then
      for r, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
        local ingredient = Product.load(lua_ingredient).new()
        ingredient.count = Product.countIngredient(recipe)
        if block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        ElementGui.addCellElement(cell_ingredients, ingredient, self:classname().."=do_noting=ID=", true, "tooltip.product", self.color_button_add, index)
      end
    end
  end

  if display_pin_level > display_level.beacon then
    -- col beacon
    local beacon = recipe.beacon
    if block.count > 1 then
      beacon.limit_count = factory.count / block.count
    else
      beacon.limit_count = nil
    end
    local cell_beacon = ElementGui.addCell(gui_table, "beacon-"..recipe.id)
    ElementGui.addCellFactory(cell_beacon, beacon, self:classname().."=do_noting=ID="..block.id.."="..recipe.id.."=", false, "tooltip.product", "gray")
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
    if item2 == "down" and display_pin_level > display_pin_level_min  then global_settings["display_pin_level"] = display_pin_level - 1 end
    if item2 == "up" and display_pin_level < display_pin_level_max  then global_settings["display_pin_level"] = display_pin_level + 1 end
    if item2 == "min" then global_settings["display_pin_level"] = display_pin_level_min end
    if item2 == "max" then global_settings["display_pin_level"] = display_pin_level_max end
    self:updateInfo(event, action, global_gui.pinBlock, item2, item3)
  end
end
