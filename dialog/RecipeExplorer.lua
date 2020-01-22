-------------------------------------------------------------------------------
-- Class to build RecipeExplorer panel
--
-- @module RecipeExplorer
-- @extends #Form
--

RecipeExplorer = newclass(Form)

local display_panel = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#RecipeExplorer] init
--
function RecipeExplorer:onInit()
  self.panelCaption = ({"helmod_recipe-explorer-panel.title"})
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#RecipeExplorer] onBind
--
function RecipeExplorer:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
  --Dispatcher:bind("on_gui_selected", self, self.event)
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#RecipeExplorer] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function RecipeExplorer:onBeforeEvent(event)
  -- close si nouvel appel
  return true
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#RecipeExplorer] getInfoPanel
--
function RecipeExplorer:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info-panel"] ~= nil and content_panel["info-panel"].valid then
    return content_panel["info-panel"]["scroll-panel"]
  end
  local mainPanel = GuiElement.add(content_panel, GuiFrameV("info-panel"):style(helmod_frame_style.panel))
  mainPanel.style.horizontally_stretchable = true
  GuiElement.setStyle(mainPanel, self.classname, "minimal_width")
  GuiElement.setStyle(mainPanel, self.classname, "maximal_width")
  GuiElement.setStyle(mainPanel, self.classname, "minimal_height")
  GuiElement.setStyle(mainPanel, self.classname, "maximal_height")
  mainPanel.style.horizontally_stretchable = true
  local scroll_panel = GuiElement.add(mainPanel, GuiScroll("scroll-panel"))
  scroll_panel.style.horizontally_stretchable = false
  return  scroll_panel
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeExplorer] updateHeader
--
-- @param #LuaEvent event
--
function RecipeExplorer:updateHeader(event)
  Logging:debug(self.classname, "updateHeader()", event)
  local left_menu_panel = self:getLeftMenuPanel()
  left_menu_panel.clear()
  local group1 = GuiElement.add(left_menu_panel, GuiFlowH("group1"))
  GuiElement.add(group1, GuiButton(self.classname, "open-recipe-selector", self.classname):sprite("menu", "wrench-white", "wrench"):style("helmod_button_menu"):tooltip({"helmod_result-panel.add-button-recipe"}))
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#RecipeExplorer] onEvent
--
-- @param #LuaEvent event
--
function RecipeExplorer:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local recipe_explore = User.getParameter("explore_recipe")
--  if event.action == "add-parent" then
--    local recipes = Player.searchRecipe(event.item3, true)
--    if #recipes == 1 then
--      local recipe = recipes[1]
--      
--      User.setParameter("scroll_element", new_recipe.id)
--      self:send("on_gui_update", event)
--    else
--      -- pour ouvrir avec le filtre ingredient
--      event.button = defines.mouse_button_type.right
--      Dispatcher:send("on_gui_open", event, "HMRecipeSelector")
--    end
--  end
  if event.action == "remove-child" then
    self:removeRecipe(recipe_explore, event.item3)
    self:updateDisplay()
  end
  
  if event.action == "add-child" then
    local recipes = Player.searchRecipe(event.item2)
    if #recipes == 1 then
      local recipe = recipes[1]
      local new_recipe = {type = recipe.type, name = recipe.name, id=game.tick }
      Logging:debug(self.classname, "-->recipe", new_recipe, event.item3, recipe_explore)
      self:addRecipe(recipe_explore, new_recipe, event.item3)
      --User.setParameter("explore_recipe", recipe_explore)
      self:updateDisplay()
    else
      User.setParameter("explore_recipe_id", event.item3)
      event.item1 = self.classname
      event.item3 = event.item2
      event.action = "OPEN"
      Dispatcher:send("on_gui_open", event, "HMRecipeSelector")
    end
  end
  -- from RecipeSelector
  if event.action == "open-recipe-selector" then
    User.setParameter("explore_recipe_id", nil)
    event.item1 = self.classname
    event.action = "OPEN"
    Dispatcher:send("on_gui_open", event, "HMRecipeSelector")
  end  
  -- from RecipeSelector
  if event.action == "element-select" then
    local explore_recipe_id = User.getParameter("explore_recipe_id")
    if explore_recipe_id == nil then
      User.setParameter("explore_recipe", {type = event.item1, name = event.item2, id=game.tick })
    else
      self:addRecipe(recipe_explore, {type = event.item1, name = event.item2, id=game.tick }, explore_recipe_id)
      --User.setParameter("explore_recipe", recipe_explore)
    end
    self:updateDisplay()
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RecipeExplorer] onUpdate
--
-- @param #LuaEvent event
--
function RecipeExplorer:addRecipe(parent, recipe, id)
  if parent.id == tonumber(id or 0) then
    if parent.children == nil then parent.children = {} end
    table.insert(parent.children, recipe)
  elseif parent.children then
    for _,child in pairs(parent.children) do
      self:addRecipe(child, recipe, id)
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#RecipeExplorer] onUpdate
--
-- @param #LuaEvent event
--
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
-- On update
--
-- @function [parent=#RecipeExplorer] onUpdate
--
-- @param #LuaEvent event
--
function RecipeExplorer:onUpdate(event)
  self:updateHeader(event)
  self:updateDisplay()
end

-------------------------------------------------------------------------------
-- Update display
--
-- @function [parent=#RecipeExplorer] updateDisplay
--
function RecipeExplorer:updateDisplay()
  Logging:debug(self.classname, "updateDisplay()")
  local content_panel = self:getInfoPanel()
  content_panel.clear()
  local recipe_explore = User.getParameter("explore_recipe")
  self:addCell(content_panel, recipe_explore, 0)
end

-------------------------------------------------------------------------------
-- Add cell
--
-- @function [parent=#RecipeExplorer] addCell
--
-- @param #LuaGuiElement parent
-- @param #table recipe
--
function RecipeExplorer:addCell(parent, recipe, index)
  Logging:debug(self.classname, "addCell()", recipe)
  if recipe ~= nil then
    local recipe_prototype = RecipePrototype(recipe)
    if recipe_prototype:native() ~= nil then
      local cell = GuiElement.add(parent, GuiTable("cell-recipe", index):column(2))
      local cell_recipe = GuiElement.add(cell, GuiFrameH("cell-recipe"):style("helmod_frame_element", "gray", 1))
      cell_recipe.style.padding=5
      
      cell_recipe.style.horizontally_stretchable = false
      local cell_table = GuiElement.add(cell_recipe, GuiTable("cell-table"):column(3))
      cell_table.style.horizontal_spacing=5
      -- products
      local cell_products = GuiElement.add(cell_table, GuiFlowV("cell-products"))
      for index, lua_product in pairs(recipe_prototype:getProducts()) do
        local product_prototype = Product(lua_product)
        local product = product_prototype:clone()
        product.count = product_prototype:getElementAmount()
        GuiElement.add(cell_products, GuiCellElementSm(self.classname, "add-parent", product.type, product.name, recipe.id or 0):element(product):tooltip("tooltip.add-recipe"):index(index):color(GuiElement.color_button_none))
      end
      -- recipe
      local button = GuiElement.add(cell_table, GuiButtonSprite(self.classname, "remove-child", recipe.type, recipe.name, recipe.id or 0):choose(recipe.type, recipe.name))
      button.locked = true
      if recipe.type ~= "recipe" then
        local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({"tooltip.resource-recipe"}))
        sprite.style.top_padding = -8
      end
      -- ingredients
      local cell_ingredients = GuiElement.add(cell_table, GuiFlowV("cell-ingredients"))
      for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
        local ingredient_prototype = Product(lua_ingredient)
        local ingredient = ingredient_prototype:clone()
        ingredient.count = ingredient_prototype:getElementAmount()
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
