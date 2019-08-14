require "edition.AbstractEdition"

-------------------------------------------------------------------------------
-- Class to build recipe edition dialog
--
-- @module RecipeEdition
-- @extends #AbstractEdition
--

RecipeEdition = setclass("HMRecipeEdition", AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#RecipeEdition] onInit
--
-- @param #Controller parent parent controller
--
function RecipeEdition.methods:onInit(parent)
  self.panelCaption = ({"helmod_recipe-edition-panel.title"})
end

-------------------------------------------------------------------------------
-- Get or create recipe info panel
--
-- @function [parent=#RecipeEdition] getObjectInfoPanel
--
-- @return #LuaGuiElement
--
function RecipeEdition.methods:getObjectInfoPanel()
  local panel = self:getPanel()
  if panel["info"] ~= nil and panel["info"].valid then
    return panel["info"]
  end
  local panel = ElementGui.addGuiFrameV(panel, "info", helmod_frame_style.default)
  
  return panel
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#RecipeEdition] getOtherInfoPanel
--
-- @return #LuaGuiElement
--
function RecipeEdition.methods:getOtherInfoPanel()
  local panel = self:getRecipePanel()
  if panel["other_info_panel"] ~= nil and panel["other_info_panel"].valid then
    return panel["other_info_panel"]
  end
  local table_panel = ElementGui.addGuiTable(panel, "other_info_panel", 1, helmod_table_style.panel)
  return table_panel
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#RecipeEdition] getObject
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RecipeEdition.methods:getObject(item, item2, item3)
  Logging:debug(self:classname(), "getObject():", item, item2, item3)
  local model = Model.getModel()
  if  model.blocks[item] ~= nil and model.blocks[item].recipes[item2] ~= nil then
    -- return recipe
    return model.blocks[item].recipes[item2]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#RecipeEdition] buildHeaderPanel
--
function RecipeEdition.methods:buildHeaderPanel()
  Logging:debug(self:classname(), "buildHeaderPanel()")
  self:getObjectInfoPanel()
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#RecipeEdition] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RecipeEdition.methods:updateHeader(item, item2, item3)
  Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
  self:updateObjectInfo(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeEdition] updateObjectInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function RecipeEdition.methods:updateObjectInfo(item, item2, item3)
  Logging:debug(self:classname(), "updateObjectInfo():", item, item2, item3)
  local info_panel = self:getObjectInfoPanel()
  local model = Model.getModel()
  if  model.blocks[item] ~= nil then
    local recipe = self:getObject(item, item2, item3)
    if recipe ~= nil then
      Logging:debug(self:classname(), "updateObjectInfo():recipe=",recipe)
      info_panel.clear()

      RecipePrototype.load(recipe).native()
      local recipe_table = ElementGui.addGuiTable(info_panel,"list-data",4)
      recipe_table.vertical_centering = false

      ElementGui.addGuiLabel(recipe_table, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
      ElementGui.addGuiLabel(recipe_table, "header-energy", ({"helmod_result-panel.col-header-energy"}))
      ElementGui.addGuiLabel(recipe_table, "header-products", ({"helmod_result-panel.col-header-products"}))
      ElementGui.addGuiLabel(recipe_table, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
      local cell_recipe = ElementGui.addGuiFrameH(recipe_table,"recipe"..recipe.id, helmod_frame_style.hidden)
      ElementGui.addCellRecipe(cell_recipe, recipe, self:classname().."=do_noting=ID=", true, "tooltip.product", "gray")


      -- energy
      local cell_energy = ElementGui.addGuiFrameH(recipe_table,"energy"..recipe.id, helmod_frame_style.hidden)
      local element_energy = {name = "helmod_button_icon_clock_flat2" ,count = RecipePrototype.getEnergy(),localised_name = "helmod_label.energy"}
      ElementGui.addCellProduct(cell_energy, element_energy, self:classname().."=do_noting=ID=", true, "tooltip.product", "gray")
      
      -- products
      local cell_products = ElementGui.addGuiTable(recipe_table,"products_"..recipe.id, 3)
      if RecipePrototype.getProducts() ~= nil then
        for index, lua_product in pairs(RecipePrototype.getProducts()) do
          local product = Product.load(lua_product).new()
          product.count = Product.getElementAmount(lua_product)
          ElementGui.addCellProductSm(cell_products, product, self:classname().."=do_noting=ID=", false, "tooltip.product", nil, index)
        end
      end
      
      -- ingredients
      local cell_ingredients = ElementGui.addGuiTable(recipe_table,"ingredients_"..recipe.id, 3)
      if RecipePrototype.getIngredients() ~= nil then
        for index, lua_ingredient in pairs(RecipePrototype.getIngredients(recipe.factory)) do
          local ingredient = Product.load(lua_ingredient).new()
          ingredient.count = Product.getElementAmount(lua_ingredient)
          ElementGui.addCellProductSm(cell_ingredients, ingredient, self:classname().."=do_noting=ID=", true, "tooltip.product", ElementGui.color_button_add, index)
        end
      end

      local tablePanel = ElementGui.addGuiTable(info_panel,"table-input",3)
      ElementGui.addGuiLabel(tablePanel, "label-production", ({"helmod_recipe-edition-panel.production"}))
      ElementGui.addGuiText(tablePanel, "production", (recipe.production or 1)*100, "helmod_textfield")

      ElementGui.addGuiButton(tablePanel, self:classname().."=object-update=ID="..item.."=", recipe.id, "helmod_button_default", ({"helmod_button.update"}))
    end
  end
end