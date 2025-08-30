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

local current_recipe = nil
-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeCustomization:onUpdate(event)
    local model, block, recipe = self:getParameterObjects()
    if current_recipe == nil then
        current_recipe = Model.newCustomizedRecipe()
    end
    self:updateSelector(event)
    self:updateCreateRecipe(event)
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeCustomization:updateSelector(event)
    local info_panel = self:getFramePanel("selector-recipe")
    local selector_table = GuiElement.add(info_panel, GuiTable("selector-recipe"):column(10))
    local customized_recipes = Player.getCustomizedRecipes()
    if table.size(customized_recipes) > 0 then
        for key, customized_recipe in pairs(customized_recipes) do
            local recipe_prototype = RecipePrototype(customized_recipe)
            local icon_name, icon_type = recipe_prototype:getIcon()
            local button_prototype = nil
            if icon_name ~= nil then
                button_prototype = GuiButtonSelectSprite(self.classname, "recipe-select", customized_recipe.name):choose(icon_type, icon_name, customized_recipe.name)
            else
                button_prototype = GuiButton(self.classname, "recipe-select", customized_recipe.name):sprite("menu", defines.sprites.status_help.white, defines.sprites.status_help.black)
            end
            local button = GuiElement.add(selector_table, button_prototype)
            button.locked = true
            GuiElement.infoRecipe(button, customized_recipe)
        end
    end
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function RecipeCustomization:updateCreateRecipe(event)
    if current_recipe == nil then
        return
    end
    local model, block, recipe = self:getParameterObjects()
    local info_panel = self:getFramePanel("create-recipe")
    info_panel.clear()

    local actions_panel = GuiElement.add(info_panel, GuiFlowH())
    actions_panel.style.horizontal_spacing = 5
    GuiElement.add(actions_panel, GuiButton(self.classname, "recipe-new"):sprite("menu", defines.sprites.create.black, defines.sprites.create.black):style("helmod_button_menu_actived_green"):tooltip({"helmod_button.new"}))
    GuiElement.add(actions_panel, GuiButton(self.classname, "recipe-save"):sprite("menu", defines.sprites.save.black, defines.sprites.save.black):style("helmod_button_menu"):tooltip({"helmod_button.save"}))
    GuiElement.add(actions_panel, GuiButton(self.classname, "recipe-add"):sprite("menu", defines.sprites.add.black, defines.sprites.add.black):style("helmod_button_menu"):tooltip({"helmod_button.add"}))
    GuiElement.add(actions_panel, GuiButton(self.classname, "recipe-remove"):sprite("menu", defines.sprites.close.black, defines.sprites.close.black):style("helmod_button_menu_actived_red"):tooltip({"helmod_button.remove"}))

    local create_table = GuiElement.add(info_panel, GuiTable("create-table"):column(2))

    -- recipe name
    GuiElement.add(create_table, GuiLabel("label-name"):caption({ "helmod_recipe-customization-panel.recipe-name" }))
    local recipe_name = current_recipe.name
    local input_name = GuiElement.add(create_table, GuiLabel(self.classname, "recipe-update", "name", model.id, block.id):caption(recipe_name))
    input_name.style.width = 250

    -- recipe localised_name
    GuiElement.add(create_table, GuiLabel("label-localized-name"):caption({ "helmod_recipe-customization-panel.recipe-localised-name" }))
    local recipe_localised_name = current_recipe.localised_name
    local input_localised_name = GuiElement.add(create_table, GuiTextField(self.classname, "recipe-update", "localized-name", model.id, block.id):text(recipe_localised_name):style("helmod_textfield"))
    input_localised_name.style.width = 250
    
    -- recipe type
    GuiElement.add(create_table, GuiLabel("label-type"):caption({ "helmod_recipe-customization-panel.recipe-type" }))
    local recipe_type = current_recipe.type or defines.mod.recipes.recipe.name
    local items = {}
    for _, recipe_type in pairs(defines.mod.recipes) do
        if recipe_type.is_customizable then
            table.insert(items, recipe_type.name)
        end
    end
    local input_type = GuiElement.add(create_table, GuiDropDown(self.classname, "recipe-type", model.id, block.id):items(items, recipe_type))
    input_type.style.width = 250

    if current_recipe.type == defines.mod.recipes.recipe.name then
        -- recipe category
        GuiElement.add(create_table, GuiLabel("label-category"):caption({ "helmod_recipe-customization-panel.recipe-category" }))
        local recipe_category = current_recipe.category or defines.mod.recipe_customized_category
        local recipe_categories = Player.getRecipeCategories()
        local items = {}
        for _, item in pairs(recipe_categories) do
            table.insert(items, item.name)
        end
        local input_category = GuiElement.add(create_table, GuiDropDown(self.classname, "recipe-category", model.id, block.id):items(items, recipe_category))
        input_category.style.width = 250

        local empty_panel = GuiElement.add(create_table, GuiFlow())
        local crafting_table = GuiElement.add(create_table, GuiTable("crafting-table"):column(10))
        local crafting_machines = Player.getProductionsCrafting(recipe_category, current_recipe)
        for key, crafting_machine in pairs(crafting_machines) do
            local choose_type = "entity"
            local choose_name = crafting_machine.name
            local machine_button = GuiElement.add(crafting_table, GuiButtonSelectSprite("machine"):choose(choose_type, choose_name))
            machine_button.locked = true
        end
    end
    
    -- recipe energy
    GuiElement.add(create_table, GuiLabel("label-energy"):caption({ "helmod_recipe-customization-panel.recipe-energy" }))
    local recipe_energy = current_recipe.energy
    local input_energy = GuiElement.add(create_table, GuiTextField(self.classname, "recipe-update", "energy", model.id, block.id):text(recipe_energy):style("helmod_textfield"))

    -- recipe products
    GuiElement.add(info_panel, GuiLabel("label-products"):caption({ "helmod_recipe-customization-panel.recipe-products" }))
    local cell_actions = GuiElement.add(info_panel, GuiTable("products-actions"):column(10))
    local button = GuiElement.add(cell_actions, GuiButtonSelectSpriteM(self.classname, "element-add", "products", "item"):choose_with_quality("item"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-stack-size", nil)
    local button = GuiElement.add(cell_actions, GuiButtonSelectSpriteM(self.classname, "element-add", "products", "fluid"):choose("fluid"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-liquid", nil)

    local products_table = GuiElement.add(info_panel, GuiTable("products-table"):column(10))
    local lua_products = current_recipe.products
    for key, lua_product in pairs(lua_products) do
        local cell = GuiElement.add(products_table, GuiFlowV())
        local element_type = lua_product.type
        local element_name = lua_product.name
        local element_quality = lua_product.quality
        local element_amount = tostring(lua_product.amount)
        local button = GuiElement.add(cell, GuiButtonSelectSprite(self.classname, "element-remove", "products", key):choose_with_quality(element_type, element_name, element_quality))
        button.locked = true

        local text_field = GuiElement.add(cell, GuiTextField(self.classname, "element-amount", "products", key):text(element_amount):style("helmod_textfield"))
        text_field.style.height = 16
        text_field.style.width = 38
    end
    
    -- recipe ingredients
    GuiElement.add(info_panel, GuiLabel("label-ingredients"):caption({ "helmod_recipe-customization-panel.recipe-ingredients" }))
    local cell_actions = GuiElement.add(info_panel, GuiTable("ingredients-actions"):column(10))
    local button = GuiElement.add(cell_actions, GuiButtonSelectSpriteM(self.classname, "element-add", "ingredients", "item"):choose_with_quality("item"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-stack-size", nil)
    local button = GuiElement.add(cell_actions, GuiButtonSelectSpriteM(self.classname, "element-add", "ingredients", "fluid"):choose("fluid"):color("green"))
    GuiElement.maskIcon(button, "virtual", "signal-liquid", nil)

    local ingredients_table = GuiElement.add(info_panel, GuiTable("ingredients-table"):column(10))
    local lua_ingredients = current_recipe.ingredients
    for key, lua_ingredient in pairs(lua_ingredients) do
        local cell = GuiElement.add(ingredients_table, GuiFlowV())
        local element_type = lua_ingredient.type
        local element_name = lua_ingredient.name
        local element_quality = lua_ingredient.quality
        local element_amount = tostring(lua_ingredient.amount)
        local button = GuiElement.add(cell, GuiButtonSelectSprite(self.classname, "element-remove", "ingredients", key):choose_with_quality(element_type, element_name, element_quality))
        button.locked = true

        local text_field = GuiElement.add(cell, GuiTextField(self.classname, "element-amount", "ingredients", key):text(element_amount):style("helmod_textfield"))
        text_field.style.height = 16
        text_field.style.width = 38
    end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function RecipeCustomization:onEvent(event)
    local model, block, recipe = self:getParameterObjects()

    if event.action == "recipe-select" then
        local recipe_name = event.item1
        current_recipe = Player.getCustomizedRecipe(recipe_name)
        Controller:send("on_gui_update", event)
    end

    if event.action == "element-add" then
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
            Controller:send("on_gui_update", event)
        end
    end

    if event.action == "element-amount" then
        local table_name = event.item1
        local index = tonumber(event.item2)
        local amount = event.element.text
        current_recipe[table_name][index].amount = tonumber(amount)
        Controller:send("on_gui_update", event)
    end

    if event.action == "element-remove" then
        local table_name = event.item1
        local index = tonumber(event.item2)
        table.remove(current_recipe[table_name], index)
        Controller:send("on_gui_update", event)
    end

    if event.action == "recipe-type" then
        local index = event.element.selected_index
        local value = event.element.items[index]
        current_recipe.type = value
        if current_recipe.type ~= defines.mod.recipes.recipe.name then
            current_recipe.category = nil
        end
        Player.setCustomizedRecipe(current_recipe)
        ModelCompute.update(model)
        Controller:send("on_gui_update", event)
    end

    if event.action == "recipe-save" then
        Player.setCustomizedRecipe(current_recipe)
        ModelBuilder.blockUpdateIcon(block)
        ModelCompute.update(model)
        Controller:send("on_gui_update", event)
    end

    if event.action == "recipe-add" then
        local recipe_name = current_recipe.name
        local recipe_type = current_recipe.type
        ModelBuilder.addRecipeIntoProductionBlock(model, block, recipe_name, recipe_type, 0)
        ModelCompute.update(model)
        Controller:send("on_gui_update", event)
    end

    if event.action == "recipe-new" then
        current_recipe = Model.newCustomizedRecipe()
        Controller:send("on_gui_update", event)
    end

    if event.action == "recipe-remove" then
        Player.removeCustomizedRecipe(current_recipe)
        current_recipe = Model.newCustomizedRecipe()
        Controller:send("on_gui_update", event)
    end

    if event.action == "recipe-category" then
        local index = event.element.selected_index
        local value = event.element.items[index]
        if value == "" then
            value = nil
        end
        current_recipe.category = value
        Controller:send("on_gui_update", event)
    end
end

