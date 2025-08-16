-------------------------------------------------------------------------------
---Class to build recipe customization dialog
---@class RecipeCustomization : FormModel
RecipeCustomization = newclass(FormModel)

-------------------------------------------------------------------------------
---On Bind Dispatcher
function RecipeCustomization:onBind()
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function RecipeCustomization:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_height = 100,
        maximal_height = math.max(height_main, 800),
    }
end

-------------------------------------------------------------------------------
---On initialization
function RecipeCustomization:onInit()
    self.panelCaption = ({ "helmod_recipe-customization-panel.title" })
    self.panel_close_before_main = true
end

local current_recipe = {}
-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeCustomization:onUpdate(event)
    local model, block, recipe = self:getParameterObjects()
    if recipe == nil then
        local customized_recipes = Player.getCustomizedRecipes()
        local name = string.format("customized_%s", #customized_recipes)
        current_recipe = {
            name = name,
            energy = 1,
            products = {},
            ingredients = {},
            owner = Player.getName()
        }
    else
        current_recipe = Player.getCustomizedRecipe(recipe.name)
    end
    self:onCreateRecipe(event)
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeCustomization:onCreateRecipe(event)
    local model, block, recipe = self:getParameterObjects()
    local info_panel = self:getFramePanel("create-recipe")
    info_panel.clear()

    local create_table = GuiElement.add(info_panel, GuiTable("create-table"):column(2))

    GuiElement.add(create_table, GuiLabel("label-name"):caption({ "helmod_recipe-customization-panel.recipe-name" }))
    local recipe_name = current_recipe.name
    local input_name = GuiElement.add(create_table, GuiTextField(self.classname, "recipe-update", "name", model.id, block.id):text(recipe_name):style("helmod_textfield"))
    input_name.style.width = 250

    if false then
        GuiElement.add(create_table, GuiLabel("label-localized-name"):caption({ "helmod_recipe-customization-panel.recipe-localized-name" }))
        local recipe_localized_name = recipe.localized_name
        local input_localized_name = GuiElement.add(create_table, GuiTextField(self.classname, "recipe-update", "localized-name", model.id, block.id):text(recipe_localized_name):style("helmod_textfield"))
        input_localized_name.style.width = 250

        GuiElement.add(create_table, GuiLabel("label-category"):caption({ "helmod_recipe-customization-panel.recipe-category" }))
        local recipe_category = current_recipe.category
        local input_category = GuiElement.add(create_table, GuiTextField(self.classname, "recipe-update", "category", model.id, block.id):text(recipe_category):style("helmod_textfield"))
        input_category.style.width = 250
    end

    GuiElement.add(create_table, GuiLabel("label-energy"):caption({ "helmod_recipe-customization-panel.recipe-energy" }))
    local recipe_energy = current_recipe.energy
    local input_energy = GuiElement.add(create_table, GuiTextField(self.classname, "recipe-update", "energy", model.id, block.id):text(recipe_energy):style("helmod_textfield"))

    GuiElement.add(info_panel, GuiLabel("label-products"):caption({ "helmod_recipe-customization-panel.recipe-products" }))
    local cell_actions = GuiElement.add(info_panel, GuiTable("products-actions"):column(10))
    local button = GuiElement.add(cell_actions, GuiButtonSelectSprite(self.classname, "add-element", "products", "item"):choose_with_quality("item"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-stack-size", nil)
    local button = GuiElement.add(cell_actions, GuiButtonSelectSprite(self.classname, "add-element", "products", "fluid"):choose("fluid"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-liquid", nil)

    local products_table = GuiElement.add(info_panel, GuiTable("products-table"):column(10))
    local lua_products = current_recipe.products
    for key, lua_product in pairs(lua_products) do
        local cell = GuiElement.add(products_table, GuiFlowV())
        local element_type = lua_product.type
        local element_name = lua_product.name
        local element_quality = lua_product.quality
        local button = GuiElement.add(cell, GuiButtonSelectSprite(self.classname, "update-element", "products", key):choose_with_quality(element_type, element_name, element_quality))
        button.locked = true
    end
    
    GuiElement.add(info_panel, GuiLabel("label-ingredients"):caption({ "helmod_recipe-customization-panel.recipe-ingredients" }))
    local cell_actions = GuiElement.add(info_panel, GuiTable("ingredients-actions"):column(10))
    local button = GuiElement.add(cell_actions, GuiButtonSelectSprite(self.classname, "add-element", "ingredients", "item"):choose_with_quality("item"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-stack-size", nil)
    local button = GuiElement.add(cell_actions, GuiButtonSelectSprite(self.classname, "add-element", "ingredients", "fluid"):choose("fluid"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-liquid", nil)

    local ingredients_table = GuiElement.add(info_panel, GuiTable("ingredients-table"):column(10))
    local lua_ingredients = current_recipe.ingredients
    for key, lua_ingredient in pairs(lua_ingredients) do
        local cell = GuiElement.add(ingredients_table, GuiFlowV())
        local element_type = lua_ingredient.type
        local element_name = lua_ingredient.name
        local element_quality = lua_ingredient.quality
        local button = GuiElement.add(cell, GuiButtonSelectSprite(self.classname, "update-element", "ingredients", key):choose_with_quality(element_type, element_name, element_quality))
        button.locked = true
    end

    local button = GuiElement.add(info_panel, GuiButton(self.classname, "save-recipe"):caption("Save"))
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function RecipeCustomization:onEvent(event)
    local model, block, recipe = self:getParameterObjects()
    if model == nil or block == nil then return end
    if event.action == "add-element" then
        local table_name = event.item1
        local element_type = string.match(event.element.elem_type, "([a-z]*)-?(.*)")
        --local element_type = event.element.elem_type
        local element_name = event.element.elem_value
        local element_quality = "normal"
        if element_type ~= nil and  element_name ~= nil then
            if type(event.element.elem_value) ~= "string" then
                element_name = event.element.elem_value.name
                element_quality = event.element.elem_value.quality
            end
            local lua_product = {type=element_type, name=element_name, quality=element_quality, amount=1}
            table.insert(current_recipe[table_name], lua_product)
            self:onCreateRecipe(event)
        end
    end

    if event.action == "save-recipe" then
        Player.setCustomizedRecipe(current_recipe)
    end
end

