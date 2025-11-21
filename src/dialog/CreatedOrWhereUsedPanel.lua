
-------------------------------------------------------------------------------
---Class to build CreatedOrWhereUsedPanel
---@class CreatedOrWhereUsedPanel
CreatedOrWhereUsedPanel = newclass(FormModel)

-------------------------------------------------------------------------------
---On Bind Dispatcher
function CreatedOrWhereUsedPanel:onBind()
    Dispatcher:bind("on_gui_refresh", self, self.update)
  end

-------------------------------------------------------------------------------
---On initialization
function CreatedOrWhereUsedPanel:onInit()
    self.panelCaption = ({"helmod_created-or-where-used-panel.title"})
    self.otherClose = false
end

------------------------------------------------------------------------------
---Get Button Sprites
---@return string, string
function CreatedOrWhereUsedPanel:getButtonSprites()
    return defines.sprites.script.white,defines.sprites.script.black
  end
  
  -------------------------------------------------------------------------------
  ---Is tool
  ---@return boolean
  function CreatedOrWhereUsedPanel:isTool()
    return true
  end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function CreatedOrWhereUsedPanel:onStyle(styles, width_main, height_main)
    styles.flow_panel = {
        minimal_width = width_main,
        minimal_height = 0,
        maximal_height = height_main
        }
end
-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function CreatedOrWhereUsedPanel:onUpdate(event)
    self:updateMenu(event)
    self:updateInfo(event)
end

-------------------------------------------------------------------------------
---Update information
---@param event LuaEvent
function CreatedOrWhereUsedPanel:updateInfo(event)
    local content_panel = self:getScrollFramePanel("info-panel")
    content_panel.style.horizontally_stretchable = true
    --content_panel.style.vertically_stretchable = true
    content_panel.clear()
    local item = User.getParameter("CreatedOrWhereUsed_item")
    -- to test missing item
    -- item = {type="item", name="YARM-fake-stone"}
    if item ~= nil then

        local headers_table = GuiElement.add(content_panel, GuiTable("headers"):column(2))
        headers_table.vertical_centering = false
        headers_table.style.cell_padding = 2

        local element_panel = GuiElement.add(headers_table, GuiFrameV("current-element"):caption({"helmod_created-or-where-used-panel.current-element"}):style(defines.styles.frame.bordered))
        if self:CheckExists(item) then
            local element_icon = GuiElement.add(element_panel, GuiButtonSelectSprite("current-element"):choose(item.type, item.name, item.name):color("flat"))
            element_icon.locked = true
        else
            local error = string.format("Unknown %s name: %s", item.type, item.name)
            GuiElement.add(element_panel, GuiSprite(item.type, item.name):sprite("helmod-event-error-32"):tooltip(error))
        end

        local element_panel = GuiElement.add(headers_table, GuiFrameV("recent-elements"):caption({"helmod_created-or-where-used-panel.recent-elements"}):style(defines.styles.frame.bordered))
        local recent_cell = GuiElement.add(element_panel, GuiFlowH())
        local recent_items = User.getParameter("CreatedOrWhereUsed_recent") or {}
        for index, recent_item in pairs(recent_items) do
            if self:CheckExists(recent_item) then
                local element_icon = GuiElement.add(recent_cell, GuiButtonSelectSprite(self.classname, "element-select", recent_item.type, recent_item.name, recent_item.id):choose(recent_item.type, recent_item.name, recent_item.name):color("flat"))
                element_icon.locked = true
            end
        end
        

        local created_filter = "has-product-item"
        if item.type == "fluid" then
            created_filter = "has-product-fluid"
        end
        local created_recipes= prototypes.get_recipe_filtered({{filter = created_filter, elem_filters = {{filter = "name", name = item.name}}}})

        local created_count = #created_recipes
        local created_panel = GuiElement.add(content_panel, GuiFrameV("product_recipes"):caption({"helmod_created-or-where-used-panel.created",created_count}):style(defines.styles.frame.bordered))
        created_panel.style.horizontally_stretchable = true
        self:AddTableRecipes(created_panel, created_recipes)

        
        local where_used_filter = "has-ingredient-item"
        if item.type == "fluid" then
            where_used_filter = "has-ingredient-fluid"
        end
        local where_used_recipes= prototypes.get_recipe_filtered({{filter = where_used_filter, elem_filters = {{filter = "name", name = item.name}}}})

        local where_used_count = #where_used_recipes
        local where_used_panel = GuiElement.add(content_panel, GuiFrameV("where_used_recipes"):caption({"helmod_created-or-where-used-panel.where-used", where_used_count}):style(defines.styles.frame.bordered))
        where_used_panel.style.horizontally_stretchable = true
        self:AddTableRecipes(where_used_panel, where_used_recipes)
        
    end
end

function CreatedOrWhereUsedPanel:CheckExists(item)
    if item.type == "fluid" then
        return Player.getFluidPrototype(item.name) ~= nil
    else
        return Player.getItemPrototype(item.name) ~= nil
    end
end

function CreatedOrWhereUsedPanel:AddTableRecipes(parent, recipes)
    local recipes_table = GuiElement.add(parent, GuiTable("product_recipes"):column(5))
    recipes_table.vertical_centering = false
    recipes_table.style.cell_padding = 2
    GuiElement.add(recipes_table, GuiLabel("header-recipe"):caption({"helmod_result-panel.col-header-recipe"}))
    GuiElement.add(recipes_table, GuiLabel("header-duration"):caption({"helmod_result-panel.col-header-duration"}))
    GuiElement.add(recipes_table, GuiLabel("header-products"):caption({"helmod_result-panel.col-header-products"}))
    GuiElement.add(recipes_table, GuiLabel("header-ingredients"):caption({"helmod_result-panel.col-header-ingredients"}))
    GuiElement.add(recipes_table, GuiLabel("header-factories"):caption({"helmod_result-panel.col-header-technologies"}))

    for _, recipe in pairs(recipes) do
        local color = nil

        local ok , err = pcall(function()
            local recipe_prototype = RecipePrototype(recipe.name)
            local icon_type, icon_name = recipe_prototype:getIcon()

            -- recipe
            local cell = GuiElement.add(recipes_table, GuiFlowH())
            local button_prototype = GuiButtonSelectSprite("recipe.name", recipe.name):choose(icon_type, icon_name, recipe.name):color(color)
            local button = GuiElement.add(cell, button_prototype)
            button.enabled = false
            
            ---duration
            local cell_duration = GuiElement.add(recipes_table, GuiFlowH())
            cell_duration.style.horizontally_stretchable = false
            local element_duration = {name = "helmod", hovered = defines.sprites.time.white, sprite = defines.sprites.time.white , count = recipe_prototype:getEnergy(),localised_name = "helmod_label.duration"}
            local duration = GuiElement.add(cell_duration, GuiCellProduct("duration"):element(element_duration):tooltip("tooltip.product"))
            duration.style.horizontally_stretchable = false

            local cell_products = GuiElement.add(recipes_table, GuiFlowH())
            cell_products.style.horizontally_stretchable = false
            cell_products.style.horizontal_spacing = 2
            for index, lua_product in pairs(recipe_prototype:getProducts()) do
                local product_prototype = Product(lua_product)
                local product = product_prototype:clone()
                product.count = product_prototype:getElementAmount()
                GuiElement.add(cell_products, GuiCellProduct(self.classname,"element-select", product.type, product.name, index):element(product):color(GuiElement.color_button_none))
            end

            local cell_ingredients = GuiElement.add(recipes_table, GuiFlowH())
            cell_ingredients.style.horizontally_stretchable = false
            cell_ingredients.style.horizontal_spacing = 2
            for index, lua_ingredient in pairs(recipe_prototype:getIngredients()) do
                local ingredient_prototype = Product(lua_ingredient)
                local ingredient = ingredient_prototype:clone()
                ingredient.count = ingredient_prototype:getElementAmount()
                GuiElement.add(cell_ingredients, GuiCellProduct(self.classname, "element-select", ingredient.type, ingredient.name, index):element(ingredient):color(GuiElement.color_button_add))
            end

            local technologies = self:getTechnology(recipe)

            local cell_technology = GuiElement.add(recipes_table, GuiFlowH())
            cell_technology.style.horizontally_stretchable = false
            cell_technology.style.horizontal_spacing = 2

            for index, technology in pairs(technologies) do
                local button_technology = GuiButtonSelectSprite("technology.name", technology.name):choose("technology", technology.name, technology.name):color(color)
                local gui_technology = GuiElement.add(cell_technology, button_technology)
                gui_technology.enabled = false
            end
        end)
    end
end
-------------------------------------------------------------------------------
---Update menu
---@param event LuaEvent
function CreatedOrWhereUsedPanel:updateMenu(event)
    local action_panel = self:getMenuPanel()
    action_panel.clear()
    --GuiElement.add(action_panel, GuiButton("HMEntitySelector", "OPEN", "HMCreatedOrWhereUsedPanel"):caption({"helmod_result-panel.select-button-entity"}))
    GuiElement.add(action_panel, GuiButton("HMItemSelector", "OPEN", "HMCreatedOrWhereUsedPanel"):caption({"helmod_result-panel.select-button-item"}))
    GuiElement.add(action_panel, GuiButton("HMFluidSelector", "OPEN", "HMCreatedOrWhereUsedPanel"):caption({"helmod_result-panel.select-button-fluid"}))
    --GuiElement.add(action_panel, GuiButton("HMRecipeSelector", "OPEN", "HMCreatedOrWhereUsedPanel"):caption({"helmod_result-panel.select-button-recipe"}))
    --GuiElement.add(action_panel, GuiButton("HMTechnologySelector", "OPEN", "HMCreatedOrWhereUsedPanel"):caption({"helmod_result-panel.select-button-technology"}))
  end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function CreatedOrWhereUsedPanel:onEvent(event)
    ---from RecipeSelector
    if event.action == "element-select" then
        local new_item = {type = event.item1, name = event.item2, id=game.tick }
        self:addRecent(new_item)
        User.setParameter("CreatedOrWhereUsed_item", new_item)
        Controller:send("on_gui_refresh", event)
    end
end

function CreatedOrWhereUsedPanel:addRecent(item)
    local limit = 20
    local recent_items = User.getParameter("CreatedOrWhereUsed_recent") or {}
    local can_insert = true
    for _, recent_item in pairs(recent_items) do
        if recent_item.type == item.type and recent_item.name == item.name then
            can_insert = false
            break; 
        end
    end
    if can_insert then
        table.insert(recent_items, 1, item)
        if #recent_items >= limit then
            table.remove(recent_items, limit)
        end
    end
    User.setParameter("CreatedOrWhereUsed_recent", recent_items)
end

function CreatedOrWhereUsedPanel:getTechnology(recipe)
    local filter = {filter="unlocks-recipe", recipe=recipe.name}
    local technologies = prototypes.get_technology_filtered({filter})
    return technologies
end