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
-- On Bind Dispatcher
--
-- @function [parent=#PinPanel] onBind
--
function PinPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PinPanel] onInit
--
function PinPanel:onInit()
  self.panelCaption = ({"helmod_pin-tab-panel.title"})
  self.otherClose = false
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#PinPanel] onBeforeOpen
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function PinPanel:onBeforeOpen(event)
  Logging:debug(self.classname, "onBeforeEvent()", event)
  local close = (event.action == "OPEN") -- only on open event
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) then
    close = false
  end
  User.setParameter(self.parameterLast, event.item1)
  User.setParameter("pin_block_id", event.item1)
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
  local mainPanel = GuiElement.add(content_panel, GuiFrameV("info-panel"):style(helmod_frame_style.panel))
  local scroll_panel = GuiElement.add(mainPanel, GuiScroll("scroll-panel"))
  scroll_panel.style.horizontally_stretchable = false
  return  scroll_panel
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
  local pin_block_id = User.getParameter("pin_block_id")
  left_menu_panel.clear()
  local group1 = GuiElement.add(left_menu_panel, GuiFlowH("group1"))
  GuiElement.add(group1, GuiButton(self.classname, "change-level=ID", "down"):sprite("menu", "arrow-left-white", "arrow-left"):style("helmod_button_menu"):tooltip({"helmod_button.decrease"}))
  GuiElement.add(group1, GuiButton(self.classname, "change-level=ID", "up"):sprite("menu", "arrow-right-white", "arrow-right"):style("helmod_button_menu"):tooltip({"helmod_button.expand"}))
  GuiElement.add(group1, GuiButton(self.classname, "change-level=ID", "min"):sprite("menu", "minimize-window-white", "minimize-window"):style("helmod_button_menu"):tooltip({"helmod_button.minimize"}))
  GuiElement.add(group1, GuiButton(self.classname, "change-level=ID", "max"):sprite("menu", "maximize-window-white", "maximize-window"):style("helmod_button_menu"):tooltip({"helmod_button.maximize"}))

  local group2 = GuiElement.add(left_menu_panel, GuiFlowH("group2"))
  GuiElement.add(group2, GuiButton("HMSummaryPanel=OPEN=ID", pin_block_id):sprite("menu", "brief-white","brief"):style("helmod_button_menu"):tooltip({"helmod_result-panel.tab-button-summary"}))
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

    local resultTable = GuiElement.add(infoPanel, GuiTable("list-data"):column(column):style("helmod_table-odd"))
    resultTable.vertical_centering = false
    resultTable.style.horizontally_stretchable = false

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
    local guiRecipe = GuiElement.add(itable, GuiFrameH("header-recipe"):style(helmod_frame_style.hidden))
    GuiElement.add(guiRecipe, GuiLabel("header-recipe"):caption({"helmod_result-panel.col-header-recipe"}))
  end

  if display_pin_level > display_level.products then
    local guiProducts = GuiElement.add(itable, GuiFrameH("header-products"):style(helmod_frame_style.hidden))
    GuiElement.add(guiProducts, GuiLabel("header-products"):caption({"helmod_result-panel.col-header-products"}))
  end

  if display_pin_level > display_level.factory then
    local guiFactory = GuiElement.add(itable, GuiFrameH("header-factory"):style(helmod_frame_style.hidden))
    GuiElement.add(guiFactory, GuiLabel("header-factory"):caption({"helmod_result-panel.col-header-factory"}))
  end

  if display_pin_level > display_level.ingredients then
    local guiIngredients = GuiElement.add(itable, GuiFrameH("header-ingredients"):style(helmod_frame_style.hidden))
    GuiElement.add(guiIngredients, GuiLabel("header-ingredients"):caption({"helmod_result-panel.col-header-ingredients"}))
  end

  if display_pin_level > display_level.beacon then
    local guiBeacon = GuiElement.add(itable, GuiFrameH("header-beacon"):style(helmod_frame_style.hidden))
    GuiElement.add(guiBeacon, GuiLabel("header-beacon"):caption({"helmod_result-panel.col-header-beacon"}))
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
  local recipe_prototype = RecipePrototype(recipe)
  if display_pin_level > display_level.base then
    -- col recipe
    local cell_recipe = GuiElement.add(gui_table, GuiFrameH("recipe", recipe.id):style(helmod_frame_style.hidden))
    GuiElement.add(cell_recipe, GuiCellRecipe(self.classname, "do_noting=ID"):element(recipe):tooltip("tooltip.info-product"):color(GuiElement.color_button_default))
  end

  if display_pin_level > display_level.products then
    -- products
    local cell_products = GuiElement.add(gui_table, GuiTable("products",recipe.id):column(3))
    cell_products.style.horizontally_stretchable = false
    if recipe_prototype:getProducts() ~= nil then
      for index, lua_product in pairs(recipe_prototype:getProducts()) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:countProduct(recipe)
        if block.count > 1 then
          product.limit_count = product.count / block.count
        end
        GuiElement.add(cell_products, GuiCellElementSm(self.classname, "do_noting=ID", "product"):index(index):element(product):tooltip("tooltip.info-product"):color(GuiElement.color_button_none))
      end
    end
  end

  if display_pin_level > display_level.factory then
    -- col factory
    local factory = recipe.factory
    GuiElement.add(gui_table, GuiCellFactory(self.classname, "pipette-entity=ID", recipe.id, "factory"):index(recipe.id):element(factory):tooltip("controls.smart-pipette"):color(GuiElement.color_button_default))
  end

  if display_pin_level > display_level.ingredients then
    -- ingredients
    local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients", recipe.id):column(3))
    cell_ingredients.style.horizontally_stretchable = false
    if recipe_prototype:getIngredients() ~= nil then
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:countIngredient(recipe)
        if block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        GuiElement.add(cell_ingredients, GuiCellElementSm(self.classname, "do_noting=ID", "ingredient"):index(index):element(ingredient):tooltip("tooltip.info-product"):color(GuiElement.color_button_add))
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
    GuiElement.add(gui_table, GuiCellFactory(self.classname, "pipette-entity=ID", recipe.id, "beacon"):index(recipe.id):element(beacon):tooltip("controls.smart-pipette"):color(GuiElement.color_button_default))
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
    if event.item1 == "min" then User.setSetting("display_pin_level",display_pin_level_min) end
    if event.item1 == "max" then User.setSetting("display_pin_level",display_pin_level_max) end
    self:updateInfo(event)
  end
  
  if event.action == "pipette-entity" then
    --Player.setPipette(event.item2)
    if pin_block_id ~= nil and model.blocks[pin_block_id] ~= nil then
      local recipes = model.blocks[pin_block_id].recipes
      Player.setSmartTool(recipes[event.item1], event.item2)
    end
  end
end
