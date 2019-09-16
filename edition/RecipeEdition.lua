require "edition.AbstractEdition"

-------------------------------------------------------------------------------
-- Class to build recipe edition dialog
--
-- @module RecipeEdition
-- @extends #AbstractEdition
--

RecipeEdition = newclass(AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#RecipeEdition] onInit
--
function RecipeEdition:onInit()
  self.panelCaption = ({"helmod_recipe-edition-panel.title"})
  self.parameterLast = string.format("%s_%s",self.classname,"last")
  self.content_verticaly = true
end

-------------------------------------------------------------------------------
-- Get or create recipe info panel
--
-- @function [parent=#RecipeEdition] getObjectInfoPanel
--
-- @return #LuaGuiElement
--
function RecipeEdition:getObjectInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info"] ~= nil and content_panel["info"].valid then
    return content_panel["info"]
  end
  local panel = ElementGui.addGuiFrameV(content_panel, "info", helmod_frame_style.default)
  
  return panel
end

-------------------------------------------------------------------------------
-- Get or create other info panel
--
-- @function [parent=#RecipeEdition] getOtherInfoPanel
--
-- @return #LuaGuiElement
--
function RecipeEdition:getOtherInfoPanel()
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
-- @param #LuaEvent event
--
function RecipeEdition:getObject(event)
  Logging:debug(self.classname, "getObject()", event)
  local model = Model.getModel()
  if  model.blocks[event.item1] ~= nil and model.blocks[event.item1].recipes[event.item2] ~= nil then
    -- return recipe
    return model.blocks[event.item1].recipes[event.item2]
  end
  return nil
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#RecipeEdition] buildHeaderPanel
--
function RecipeEdition:buildHeaderPanel()
  Logging:debug(self.classname, "buildHeaderPanel()")
  self:getObjectInfoPanel()
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#RecipeEdition] updateHeader
--
-- @param #LuaEvent event
--
function RecipeEdition:updateHeader(event)
  Logging:debug(self.classname, "updateHeader()", event)
  self:updateObjectInfo(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#RecipeEdition] updateObjectInfo
--
-- @param #LuaEvent event
--
function RecipeEdition:updateObjectInfo(event)
  Logging:debug(self.classname, "updateObjectInfo()", event)
  local info_panel = self:getObjectInfoPanel()
  local model = Model.getModel()
  if  model.blocks[event.item1] ~= nil then
    local recipe = self:getObject(event)
    if recipe ~= nil then
      Logging:debug(self.classname, "updateObjectInfo():recipe=",recipe)
      info_panel.clear()

      local recipe_prototype = RecipePrototype(recipe)
      local recipe_table = ElementGui.addGuiTable(info_panel,"list-data",4)
      recipe_table.vertical_centering = false

      ElementGui.addGuiLabel(recipe_table, "header-recipe", ({"helmod_result-panel.col-header-recipe"}))
      ElementGui.addGuiLabel(recipe_table, "header-energy", ({"helmod_result-panel.col-header-energy"}))
      ElementGui.addGuiLabel(recipe_table, "header-products", ({"helmod_result-panel.col-header-products"}))
      ElementGui.addGuiLabel(recipe_table, "header-ingredients", ({"helmod_result-panel.col-header-ingredients"}))
      local cell_recipe = ElementGui.addGuiFrameH(recipe_table,"recipe"..recipe.id, helmod_frame_style.hidden)
      ElementGui.addCellRecipe(cell_recipe, recipe, self.classname.."=do_noting=ID=", true, "tooltip.product", "gray")


      -- energy
      local cell_energy = ElementGui.addGuiFrameH(recipe_table,"energy"..recipe.id, helmod_frame_style.hidden)
      local element_energy = {name = "helmod_button_icon_clock_flat2" ,count = recipe_prototype:getEnergy(),localised_name = "helmod_label.energy"}
      ElementGui.addCellProduct(cell_energy, element_energy, self.classname.."=do_noting=ID=", true, "tooltip.product", "gray")
      
      -- products
      local cell_products = ElementGui.addGuiTable(recipe_table,"products_"..recipe.id, 3)
      if recipe_prototype:getProducts() ~= nil then
        for index, lua_product in pairs(recipe_prototype:getProducts()) do
          local product_prototype = Product(lua_product)
          local product = product_prototype:clone()
          product.count = product_prototype:getElementAmount()
          ElementGui.addCellProductSm(cell_products, product, self.classname.."=do_noting=ID=", false, "tooltip.product", nil, index)
        end
      end
      
      -- ingredients
      local cell_ingredients = ElementGui.addGuiTable(recipe_table,"ingredients_"..recipe.id, 3)
      if recipe_prototype:getIngredients() ~= nil then
        for index, lua_ingredient in pairs(recipe_prototype:getIngredients(recipe.factory)) do
          local ingredient_prototype = Product(lua_ingredient)
          local ingredient = ingredient_prototype:clone()
          ingredient.count = ingredient_prototype:getElementAmount()
          ElementGui.addCellProductSm(cell_ingredients, ingredient, self.classname.."=do_noting=ID=", true, "tooltip.product", ElementGui.color_button_add, index)
        end
      end

      local tablePanel = ElementGui.addGuiTable(info_panel,"table-input",3)
      ElementGui.addGuiLabel(tablePanel, "label-production", ({"helmod_recipe-edition-panel.production"}))
      ElementGui.addGuiText(tablePanel, string.format("%s=object-update=ID=%s=%s", self.classname, event.item1, recipe.id), (recipe.production or 1)*100, "helmod_textfield")

    end
  end
end