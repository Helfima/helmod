-------------------------------------------------------------------------------
-- Class to build pin tab dialog
--
-- @module PinPanel
-- @extends #Form
--

PinPanel = newclass(Form)

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
function PinPanel:onInit(parent)
  self.panelCaption = ({"helmod_pin-tab-panel.title"})
  self.otherClose = false
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#PinPanel] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function PinPanel:onBeforeEvent(event)
  Logging:debug(self.classname, "onBeforeEvent()", event)
  local close = (event.action == "OPEN") -- only on open event
  if event.action == "OPEN" then
    if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) then
      close = false
    end
    User.setParameter(self.parameterLast, event.item1)
    User.setParameter("pin_block_id", event.item1)
  end
  return close
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PinPanel] getInfoPanel
--
function PinPanel:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info-panel"] ~= nil and content_panel["info-panel"].valid then
    return content_panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = ElementGui.addGuiFrameV(content_panel, "info-panel", helmod_frame_style.panel)
  return ElementGui.addGuiScrollPane(mainPanel, "scroll-panel", helmod_scroll_style.pin_tab)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PinPanel] onUpdate
--
-- @param #LuaEvent event
--
function PinPanel:onUpdate(event)
  self:updateHeader(event)
  self:updateInfo(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PinPanel] updateHeader
--
-- @param #LuaEvent event
--
function PinPanel:updateHeader(event)
  Logging:debug(self.classname, "updateHeader()", event)
  local left_menu_panel = self:getLeftMenuPanel()
  local model = Model.getModel()
  left_menu_panel.clear()
  local group1 = ElementGui.addGuiFlowH(left_menu_panel,"group1",helmod_flow_style.horizontal)
  ElementGui.addGuiButton(group1, self.classname.."=change-level=ID=down", nil, "helmod_button_icon_arrow_left", nil, ({"helmod_button.decrease"}))
  ElementGui.addGuiButton(group1, self.classname.."=change-level=ID=up", nil, "helmod_button_icon_arrow_right", nil, ({"helmod_button.expand"}))
  ElementGui.addGuiButton(group1, self.classname.."=change-level=ID=min", nil, "helmod_button_icon_minimize", nil, ({"helmod_button.minimize"}))
  ElementGui.addGuiButton(group1, self.classname.."=change-level=ID=max", nil, "helmod_button_icon_maximize", nil, ({"helmod_button.maximize"}))

end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PinPanel] updateInfo
--
-- @param #LuaEvent event
--
function PinPanel:updateInfo(event)
  Logging:debug(self.classname, "updateInfo()", event)
  local infoPanel = self:getInfoPanel()
  local model = Model.getModel()
  local pin_block_id = User.getParameter("pin_block_id")
  local order = User.getParameter("order")

  infoPanel.clear()

  local column = User.getSetting("display_pin_level") + 1

  Logging:debug(self.classname, "updateInfo", pin_block_id, model.blocks[pin_block_id])
  if pin_block_id ~= nil and model.blocks[pin_block_id] ~= nil then
    local block = model.blocks[pin_block_id]

    local resultTable = ElementGui.addGuiTable(infoPanel,"list-data",column, "helmod_table-odd")

    self:addProductionBlockHeader(resultTable)
    for _, recipe in spairs(block.recipes, function(t,a,b) return t[b]["index"] > t[a]["index"] end) do
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
function PinPanel:addProductionBlockHeader(itable)
  Logging:debug(self.classname, "addProductionBlockHeader()", itable)
  local display_pin_level = User.getSetting("display_pin_level")
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
function PinPanel:addProductionBlockRow(gui_table, block, recipe)
  Logging:debug(self.classname, "addProductionBlockRow()", gui_table, block, recipe)
  local display_pin_level = User.getSetting("display_pin_level")
  local model = Model.getModel()
  local recipe_prototype = RecipePrototype(recipe)
  if display_pin_level > display_level.base then
    -- col recipe
    local cell_recipe = ElementGui.addGuiFrameH(gui_table,"recipe"..recipe.id, helmod_frame_style.hidden)
    ElementGui.addCellRecipe(cell_recipe, recipe, self.classname.."=do_noting=ID=", true, "tooltip.product", "gray")
  end

  if display_pin_level > display_level.products then
    -- products
    local cell_products = ElementGui.addGuiTable(gui_table,"products_"..recipe.id, 3)
    if recipe_prototype:getProducts() ~= nil then
      for index, lua_product in pairs(recipe_prototype:getProducts()) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:countProduct(recipe)
        if block.count > 1 then
          product.limit_count = product.count / block.count
        end
        ElementGui.addCellElementSm(cell_products, product, self.classname.."=do_noting=ID=", false, "tooltip.product", nil, index)
      end
    end
  end

  if display_pin_level > display_level.factory then
    -- col factory
    local cell_factory =ElementGui.addCell(gui_table, "factory-"..recipe.id)
    local factory = recipe.factory
    ElementGui.addCellFactory(cell_factory, factory, self.classname.."=do_noting=ID=", false, "tooltip.product", "gray")
  end

  if display_pin_level > display_level.ingredients then
    -- ingredients
    local cell_ingredients = ElementGui.addGuiTable(gui_table,"ingredients_"..recipe.id, 3)
    if recipe_prototype:getIngredients() ~= nil then
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:countIngredient(recipe)
        if block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        ElementGui.addCellElementSm(cell_ingredients, ingredient, self.classname.."=do_noting=ID=", true, "tooltip.product", ElementGui.color_button_add, index)
      end
    end
  end

  if display_pin_level > display_level.beacon then
    -- col beacon
    local beacon = recipe.beacon
    if block.count > 1 then
      beacon.limit_count = beacon.count / block.count
    else
      beacon.limit_count = nil
    end
    local cell_beacon = ElementGui.addCell(gui_table, "beacon-"..recipe.id)
    ElementGui.addCellFactory(cell_beacon, beacon, self.classname.."=do_noting=ID="..block.id.."="..recipe.id.."=", false, "tooltip.product", "gray")
  end

end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PinPanel] onEvent
--
-- @param #LuaEvent event
--
function PinPanel:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local model = Model.getModel()
  local pin_block_id = User.getParameter("pin_block_id")

  if event.action == "change-level" then
    local display_pin_level = User.getSetting("display_pin_level")
    Logging:debug(self.classname, "display_pin_level", display_pin_level)
    if event.item1 == "down" and display_pin_level > display_pin_level_min  then User.setSetting("display_pin_level",display_pin_level - 1) end
    if event.item1 == "up" and display_pin_level < display_pin_level_max  then User.setSetting("display_pin_level",display_pin_level + 1) end
    if event.item1 == "min" then User.setParameter("display_pin_level",display_pin_level_min) end
    if event.item1 == "max" then User.setParameter("display_pin_level",display_pin_level_max) end
    self:updateInfo(event)
  end
end
