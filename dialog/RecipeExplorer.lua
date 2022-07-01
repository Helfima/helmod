-------------------------------------------------------------------------------
---Class to build RecipeExplorer panel
---@class RecipeExplorer
RecipeExplorer = newclass(Form)

local display_panel = nil

-------------------------------------------------------------------------------
---Initialization
function RecipeExplorer:onInit()
  self.panelCaption = ({"helmod_recipe-explorer-panel.title"})
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function RecipeExplorer:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 300,
    maximal_width = width_main,
    minimal_height = 200,
    maximal_height = height_main
  }
end

------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function RecipeExplorer:getButtonSprites()
  return defines.sprites.search.white, defines.sprites.search.black
end

-------------------------------------------------------------------------------
---Is tool
---@return boolean
function RecipeExplorer:isTool()
  return true
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function RecipeExplorer:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
  --Dispatcher:bind("on_gui_selected", self, self.event)
end

-------------------------------------------------------------------------------
---Get or create info panel
function RecipeExplorer:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info-panel"] ~= nil and content_panel["info-panel"].valid then
    return content_panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = GuiElement.add(content_panel, GuiFrameV("info-panel"):style(helmod_frame_style.panel))
  mainPanel.style.horizontally_stretchable = true
  mainPanel.style.vertically_stretchable = true
  local scroll_panel = GuiElement.add(mainPanel, GuiScroll("scroll-panel"))
  scroll_panel.style.horizontally_stretchable = false
  return  scroll_panel
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function RecipeExplorer:updateHeader(event)
  local action_panel, _ = self:getMenuPanel()
  action_panel.clear()
  local group1 = GuiElement.add(action_panel, GuiFlowH("group1"))
  group1.style.horizontal_spacing = 10
  GuiElement.add(group1, GuiButton(self.classname, "open-recipe-selector", self.classname):sprite("menu", defines.sprites.script.black, defines.sprites.script.black):style("helmod_button_menu_actived_green"):tooltip({"helmod_result-panel.add-button-recipe"}))
  GuiElement.add(group1, GuiButton(self.classname, "generate-block", self.classname):sprite("menu", defines.sprites.settings.black, defines.sprites.settings.black):style("helmod_button_menu"):tooltip({"helmod_recipe-explorer-panel.generate-block"}))
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function RecipeExplorer:onEvent(event)
  local recipe_explore = User.getParameter("explore_recipe")
  if event.action == "remove-child" then
    self:removeRecipe(recipe_explore, event.item3)
    self:updateDisplay()
  end
  
  if event.action == "generate-block" then
    local parameter_name = string.format("%s_%s", "HMProductionPanel", "objects")
    local parameter_objects = User.getParameter(parameter_name)
    local model, _, _ = Model.getParameterObjects(parameter_objects)
    local block = self:generateBlock(model, nil, recipe_explore)
    ModelCompute.update(model)
    User.setParameter(parameter_name, {name=parameter_name, model=model.id, block=block.id})
    Controller:send("on_gui_update", event)
  end

  if event.action == "add-parent" then
    User.setParameter("explore_recipe_mode", "add-parent")
    local recipes = Player.searchRecipe(event.item2, true)
    if #recipes == 1 then
      local recipe = recipes[1]
      local new_recipe = {type = recipe.type, name = recipe.name, id=game.tick }
      self:addRecipe(new_recipe, recipe_explore, event.item3)
      self:updateDisplay()
    else
      User.setParameter("explore_recipe_id", event.item3)
      event.item1 = self.classname
      event.item3 = event.item2
      event.action = "OPEN"
      event.button = defines.mouse_button_type.right
      Dispatcher:send("on_gui_open", event, "HMRecipeSelector")
    end
  end

  if event.action == "add-child" then
    User.setParameter("explore_recipe_mode", "add-child")
    local recipes = Player.searchRecipe(event.item2)
    if #recipes == 1 then
      local recipe = recipes[1]
      local new_recipe = {type = recipe.type, name = recipe.name, id=game.tick }
      self:addRecipe(recipe_explore, new_recipe, event.item3)
      self:updateDisplay()
    else
      User.setParameter("explore_recipe_id", event.item3)
      event.item1 = self.classname
      event.item3 = event.item2
      event.action = "OPEN"
      Dispatcher:send("on_gui_open", event, "HMRecipeSelector")
    end
  end
  ---from RecipeSelector
  if event.action == "open-recipe-selector" then
    User.setParameter("explore_recipe_mode", "add-child")
    User.setParameter("explore_recipe_id", nil)
    event.item1 = self.classname
    event.action = "OPEN"
    Dispatcher:send("on_gui_open", event, "HMRecipeSelector")
  end  

  ---from RecipeSelector
  if event.action == "element-select" then
    local explore_recipe_mode = User.getParameter("explore_recipe_mode")
    local explore_recipe_id = User.getParameter("explore_recipe_id")
    local new_recipe = {type = event.item1, name = event.item2, id=game.tick }
    if explore_recipe_id == nil then
      User.setParameter("explore_recipe", new_recipe)
    else
      if explore_recipe_mode == "add-parent" then
        self:addRecipe(new_recipe, recipe_explore, explore_recipe_id)
        User.setParameter("explore_recipe", new_recipe)
      else
        self:addRecipe(recipe_explore, new_recipe, explore_recipe_id)
      end
    end
    self:updateDisplay()
  end
end

function RecipeExplorer:generateBlock(model, block, recipe)
  block = ModelBuilder.addRecipeIntoProductionBlock(model, block, recipe.name, recipe.type)
  if recipe.children then
    for _,child in pairs(recipe.children) do
      self:generateBlock(model, block, child)
    end
  end
  return block
end

-------------------------------------------------------------------------------
---On update
---@param parent table
---@param recipe any
---@param id any
function RecipeExplorer:addRecipe(parent, recipe, id)
  local explore_recipe_mode = User.getParameter("explore_recipe_mode")
  if explore_recipe_mode == "add-parent" then
    if recipe.id == tonumber(id or 0) then
      if parent.children == nil then parent.children = {} end
      table.insert(parent.children, recipe)
    elseif recipe.children then
      for _,child in pairs(recipe.children) do
        self:addRecipe(parent, child, id)
      end
    end
  else
    if parent.id == tonumber(id or 0) then
      if parent.children == nil then parent.children = {} end
      table.insert(parent.children, recipe)
    elseif parent.children then
      for _,child in pairs(parent.children) do
        self:addRecipe(child, recipe, id)
      end
    end
  end
end

-------------------------------------------------------------------------------
---On update
---@param parent table
---@param id any
function RecipeExplorer:removeRecipe(parent, id)
  if parent.children then
    local index_remove = nil
    for index,child in pairs(parent.children) do
      if child.id == tonumber(id or 0) then
        index_remove = index
      end
    end
    if index_remove == nil then
      for _,child in pairs(parent.children) do
        self:removeRecipe(child, id)
      end
    else
      table.remove(parent.children,index_remove)
    end
  end
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeExplorer:onUpdate(event)
  self:updateHeader(event)
  self:updateDisplay()
end

-------------------------------------------------------------------------------
---Update display
function RecipeExplorer:updateDisplay()
  local content_panel = self:getInfoPanel()
  content_panel.clear()
  local recipe_explore = User.getParameter("explore_recipe")
  self:addCell(content_panel, recipe_explore, 0)
end

-------------------------------------------------------------------------------
---Add cell
---@param parent any
---@param recipe table
---@param index any
function RecipeExplorer:addCell(parent, recipe, index)
  if recipe ~= nil then
    local recipe_prototype = RecipePrototype(recipe)
    if recipe_prototype:native() ~= nil then
      local cell = GuiElement.add(parent, GuiTable("cell-recipe", index):column(2))
      local cell_recipe = GuiElement.add(cell, GuiFrameH("cell-recipe"):style("helmod_frame_element", "gray", 1))
      cell_recipe.style.padding=5
      
      cell_recipe.style.horizontally_stretchable = false
      local cell_table = GuiElement.add(cell_recipe, GuiTable("cell-table"):column(3))
      cell_table.style.horizontal_spacing=5
      ---products
      local cell_products = GuiElement.add(cell_table, GuiFlowV("cell-products"))
      for index, lua_product in pairs(recipe_prototype:getProducts(recipe.factory)) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:getElementAmount()
        product.time = 1
        GuiElement.add(cell_products, GuiCellElementSm(self.classname, "add-parent", product.type, product.name, recipe.id or 0):element(product):tooltip("tooltip.add-recipe"):index(index):color(GuiElement.color_button_none))
      end
      ---recipe
      local icon_name, icon_type = recipe_prototype:getIcon()
      local button = GuiElement.add(cell_table, GuiButtonSprite(self.classname, "remove-child", recipe.type, recipe.name, recipe.id or 0):choose(icon_type, icon_name, recipe_prototype.name))
      button.locked = true
      if recipe.type ~= "recipe" then
        local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({"tooltip.resource-recipe"}))
        sprite.style.top_padding = -8
      end
      ---ingredients
      local cell_ingredients = GuiElement.add(cell_table, GuiFlowV("cell-ingredients"))
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:getElementAmount()
        ingredient.time = 1
        GuiElement.add(cell_ingredients, GuiCellElementSm(self.classname, "add-child", ingredient.type, ingredient.name, recipe.id or 0):element(ingredient):tooltip("tooltip.add-recipe"):index(index):color(GuiElement.color_button_add))
      end
      local cell_children = GuiElement.add(cell, GuiFlowV("cell-children"))
      cell_children.style.vertical_spacing=10
      if recipe.children ~= nil then
        for child_index, child_recipe in pairs(recipe.children) do
          self:addCell(cell_children, child_recipe, child_index)
        end
      end
    end
  end
end