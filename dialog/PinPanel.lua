-------------------------------------------------------------------------------
---Class to build pin dialog
---@class PinPanel
PinPanel = newclass(FormModel)

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
---On Bind Dispatcher
function PinPanel:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
---On initialization
function PinPanel:onInit()
  self.panelCaption = ({"helmod_pin-tab-panel.title"})
  self.otherClose = false
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function PinPanel:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 50,
    maximal_width = 600,
    minimal_height = 0,
    maximal_height = height_main
    }
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function PinPanel:onUpdate(event)
  self:updateHeader(event)
  self:updateInfo(event)
end

local setting_options = {}
table.insert(setting_options, {name="done", icon=defines.sprites.status_ok.white, icon_white=defines.sprites.status_ok.black, tooltip="tooltip.hide-show-done", column=0})
table.insert(setting_options, {name="machine", icon=defines.sprites.factory.white, icon_white=defines.sprites.factory.black, tooltip="tooltip.hide-show-factory", column=1})
table.insert(setting_options, {name="product", icon=defines.sprites.jewel.white, icon_white=defines.sprites.jewel.black, tooltip="tooltip.hide-show-product", column=2})
table.insert(setting_options, {name="beacon", icon=defines.sprites.beacon.white, icon_white=defines.sprites.beacon.black, tooltip="tooltip.hide-show-beacon", column=1})

-------------------------------------------------------------------------------
---Update header
---@param event LuaEvent
function PinPanel:updateHeader(event)
  local action_panel = self:getMenuPanel()
  action_panel.clear()
  local group1 = GuiElement.add(action_panel, GuiFlowH("group1"))

  ---setting options
  
  for _,setting_option in pairs(setting_options) do
    local setting_name = string.format("pin_panel_column_hide_%s", setting_option.name)
    local setting_value = User.getSetting(setting_name)
    if setting_value == true then
      GuiElement.add(group1, GuiButton(self.classname, "change-hide", setting_option.name):sprite("menu", setting_option.icon_white, setting_option.icon):style("helmod_button_menu"):tooltip({setting_option.tooltip}))
    else
      GuiElement.add(group1, GuiButton(self.classname, "change-hide", setting_option.name):sprite("menu", setting_option.icon, setting_option.icon):style("helmod_button_menu_selected"):tooltip({setting_option.tooltip}))
    end
  end

  local group2 = GuiElement.add(action_panel, GuiFlowH("group2"))
  GuiElement.add(group2, GuiButton(self.classname, "recipe-done-remove"):sprite("menu", defines.sprites.checkmark.black,defines.sprites.checkmark.black):style("helmod_button_menu_actived_red"):tooltip({"helmod_button.remove-done"}))

  local parameter_objects = User.getParameter(self.parameter_objects)
  local group3 = GuiElement.add(action_panel, GuiFlowH("group3"))
  GuiElement.add(group3, GuiButton("HMSummaryPanel", "OPEN", parameter_objects.model, parameter_objects.block):sprite("menu", defines.sprites.list_view.black, defines.sprites.list_view.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.tab-button-summary"}))

  local group4 = GuiElement.add(action_panel, GuiFlowH("group4"))
  GuiElement.add(group4, GuiButton("HMProductionPanel", "OPEN", parameter_objects.model, parameter_objects.block):sprite("menu", defines.sprites.hangar.black,defines.sprites.hangar.black):style("helmod_button_menu"):tooltip({"helmod_result-panel.tab-button-production-block"}))
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function PinPanel:updateInfo(event)
  local infoPanel = self:getScrollFramePanel("info-panel")
  infoPanel.clear()

  local column = 2
  for _,setting_option in pairs(setting_options) do
    local setting_name = string.format("pin_panel_column_hide_%s", setting_option.name)
    local setting_value = User.getSetting(setting_name)
    if not(setting_value) then column = column + setting_option.column end
  end

  local model, block, recipe = self:getParameterObjects()

  if block ~= nil then
    local resultTable = GuiElement.add(infoPanel, GuiTable("list-data"):column(column):style("helmod_table-odd"))
    resultTable.vertical_centering = false
    resultTable.style.horizontally_stretchable = false

    self:addProductionBlockHeader(resultTable)
    for _, recipe in spairs(block.children, defines.sorters.block.sort) do
      local is_done = recipe.is_done or false
      if not(is_done and User.getSetting("pin_panel_column_hide_done")) then
        self:addProductionBlockRow(resultTable, model, block, recipe)
      end
    end
  end
end

-------------------------------------------------------------------------------
---Add header data tab
---@param itable LuaGuiElement
function PinPanel:addProductionBlockHeader(itable)

  local gui_done = GuiElement.add(itable, GuiFrameH("header-done"):style(helmod_frame_style.hidden))
  GuiElement.add(gui_done, GuiLabel("header-done"):caption({"helmod_result-panel.col-header-done"}))

  local guiRecipe = GuiElement.add(itable, GuiFrameH("header-recipe"):style(helmod_frame_style.hidden))
  GuiElement.add(guiRecipe, GuiLabel("header-recipe"):caption({"helmod_result-panel.col-header-recipe"}))

  if not(User.getSetting("pin_panel_column_hide_product")) then
    local guiProducts = GuiElement.add(itable, GuiFrameH("header-products"):style(helmod_frame_style.hidden))
    GuiElement.add(guiProducts, GuiLabel("header-products"):caption({"helmod_result-panel.col-header-products"}))
  end

  if not(User.getSetting("pin_panel_column_hide_machine")) then
    local guiFactory = GuiElement.add(itable, GuiFrameH("header-factory"):style(helmod_frame_style.hidden))
    GuiElement.add(guiFactory, GuiLabel("header-factory"):caption({"helmod_result-panel.col-header-factory"}))
  end

  if not(User.getSetting("pin_panel_column_hide_product")) then
    local guiIngredients = GuiElement.add(itable, GuiFrameH("header-ingredients"):style(helmod_frame_style.hidden))
    GuiElement.add(guiIngredients, GuiLabel("header-ingredients"):caption({"helmod_result-panel.col-header-ingredients"}))
  end

  if not(User.getSetting("pin_panel_column_hide_beacon")) then
    local guiBeacon = GuiElement.add(itable, GuiFrameH("header-beacon"):style(helmod_frame_style.hidden))
    GuiElement.add(guiBeacon, GuiLabel("header-beacon"):caption({"helmod_result-panel.col-header-beacon"}))
  end

  
end

-------------------------------------------------------------------------------
---Add row data tab
---@param gui_table LuaGuiElement
---@param model table
---@param block table
---@param recipe table
function PinPanel:addProductionBlockRow(gui_table, model, block, recipe)
  local recipe_prototype = RecipePrototype(recipe)
  local is_done = recipe.is_done or false

  ---col done
  if is_done == true then
    GuiElement.add(gui_table, GuiButton(self.classname, "recipe-done", recipe.id):sprite("menu", defines.sprites.status_ok.black, defines.sprites.status_ok.black):style("helmod_button_menu_selected_green"):tooltip({"helmod_button.done"}))
  else
    GuiElement.add(gui_table, GuiButton(self.classname, "recipe-done", recipe.id):sprite("menu", defines.sprites.checkmark.black, defines.sprites.checkmark.black):style("helmod_button_menu_actived_green"):tooltip({"helmod_button.done"}))
  end
  ---col recipe
  local cell_recipe = GuiElement.add(gui_table, GuiFrameH("recipe", recipe.id):style(helmod_frame_style.hidden))
  local button_recipe = GuiCellRecipe("HMRecipeEdition", "OPEN", model.id, block.id, recipe.id):element(recipe):infoIcon(recipe.type):tooltip("tooltip.edit-recipe"):color(GuiElement.color_button_default):mask(is_done)
  --local button_recipe = GuiCellRecipe(self.classname, "do_noting", "recipe"):element(recipe):infoIcon(recipe.type):tooltip("tooltip.info-product"):color(GuiElement.color_button_default):mask(is_done)
  GuiElement.add(cell_recipe, button_recipe)

  if not(User.getSetting("pin_panel_column_hide_product")) then
    ---products
    local cell_products = GuiElement.add(gui_table, GuiTable("products",recipe.id):column(3))
    cell_products.style.horizontally_stretchable = false
    local lua_products = recipe_prototype:getProducts(recipe.factory)
    if lua_products ~= nil then
      for index, lua_product in pairs(lua_products) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.time = model.time
        product.count = product_prototype:countProduct(recipe)
        if block.by_limit == true and block.count > 1 then
          product.limit_count = product.count / block.count
        end
        GuiElement.add(cell_products, GuiCellElementSm(self.classname, "do_noting", "product"):index(index):element(product):tooltip("tooltip.info-product"):color(GuiElement.color_button_none):byLimit(block.by_limit):mask(is_done))
      end
    end
  end

  if not(User.getSetting("pin_panel_column_hide_machine")) then
    ---col factory
    local factory = recipe.factory
    GuiElement.add(gui_table, GuiCellFactory(self.classname, "pipette-entity", recipe.id, "factory"):index(recipe.id):element(factory):tooltip("controls.smart-pipette"):color(GuiElement.color_button_default):byLimit(block.by_limit):mask(is_done))
  end

  if not(User.getSetting("pin_panel_column_hide_product")) then
    ---ingredients
    local cell_ingredients = GuiElement.add(gui_table, GuiTable("ingredients", recipe.id):column(3))
    cell_ingredients.style.horizontally_stretchable = false
    local lua_ingredients = recipe_prototype:getIngredients(recipe.factory)
    if lua_ingredients ~= nil then
      for index, lua_ingredient in pairs(lua_ingredients) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.time = model.time
        ingredient.count = ingredient_prototype:countIngredient(recipe)
        if block.by_limit == true and block.count > 1 then
          ingredient.limit_count = ingredient.count / block.count
        end
        GuiElement.add(cell_ingredients, GuiCellElementSm(self.classname, "do_noting", "ingredient"):index(index):element(ingredient):tooltip("tooltip.info-product"):color(GuiElement.color_button_add):byLimit(block.by_limit):mask(is_done))
      end
    end
  end

  if not(User.getSetting("pin_panel_column_hide_beacon")) then
    ---col beacon
    local beacons = recipe.beacons
    local cell_beacons = GuiElement.add(gui_table, GuiFlowH("beacon", recipe.id))
    cell_beacons.style.horizontally_stretchable = false
    cell_beacons.style.horizontal_spacing = 2
    if beacons ~= nil then
      for index, beacon in pairs(beacons) do
        if block.by_limit == true and block.count > 1 then
          beacon.limit_count = beacon.count / block.count
        else
          beacon.limit_count = nil
        end
        GuiElement.add(cell_beacons, GuiCellFactory(self.classname, "pipette-entity", recipe.id, "beacons", index):index(index):element(beacon):tooltip("controls.smart-pipette"):color(GuiElement.color_button_default):byLimit(block.by_limit):mask(is_done))
      end
    end
  end

end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function PinPanel:onEvent(event)

  if event.action == "change-hide" then
    local element = event.item1
    local setting_name = string.format("pin_panel_column_hide_%s", element)
    local setting_value = User.getSetting(setting_name)
    User.setSetting(setting_name, not(setting_value))
    self:onUpdate(event)
  end
  
  local model, block, recipe = self:getParameterObjects()

  if block == nil then return end

  if event.action == "pipette-entity" then
    local children = block.children
    local index = tonumber(event.item3)
    Player.setSmartTool(children[event.item1], event.item2, index)
  end
  if event.action == "recipe-done" then
    local children = block.children
    children[event.item1].is_done = not(children[event.item1].is_done)
    self:updateInfo(event)
  end
  if event.action == "recipe-done-remove" then
    local children = block.children
    for _,child in pairs(children) do
      child.is_done = nil
    end
    self:updateInfo(event)
  end
end
