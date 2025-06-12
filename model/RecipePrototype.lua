---
---Description of the module.
---@class RecipePrototype : Prototype
RecipePrototype = newclass(Prototype, function(base, object, object_type)
    base.classname = "HMRecipePrototype"
    base.is_voider = nil
    base.is_support_quality = false
    if object ~= nil then
        if type(object) == "string" then
            base.object_name = object
            base.lua_type = object_type
        elseif object.name ~= nil then
            base.object_name = object.name
            base.lua_type = object_type or object.type
        end
        if base.lua_type == nil or base.lua_type == "recipe" then
            Prototype.init(base, Player.getRecipe(base.object_name))
            base.lua_type = "recipe"
            if Player.hasFeatureQuality() then
                for _, ingredient in pairs(base.lua_prototype.ingredients) do
                    if ingredient.type == "item" then
                        base.is_support_quality = true
                    end
                end
            end
        elseif base.lua_type == "recipe-burnt" then
            Prototype.init(base, Player.getBurntRecipe(base.object_name))
        elseif base.lua_type == "energy" then
            Prototype.init(base, Player.getEnergyRecipe(base.object_name))
        elseif base.lua_type == "resource" then
            Prototype.init(base, Player.getResourceRecipe(base.object_name))
        elseif base.lua_type == "fluid" then
            Prototype.init(base, Player.getFluidRecipe(base.object_name))
        elseif base.lua_type == "boiler" then
            local recipe = Player.getBoilerRecipe(base.object_name)
            Prototype.init(base, recipe)
            base.input_fluid_name = recipe.input_fluid_name
            base.output_fluid_temperature = recipe.output_fluid_temperature
            base.output_fluid_name = recipe.output_fluid_name
        elseif base.lua_type == "technology" then
            Prototype.init(base, Player.getTechnology(base.object_name))
        elseif base.lua_type == "rocket" then
            local recipe = Player.getRocketRecipe(base.object_name)
            Prototype.init(base, recipe)
        elseif base.lua_type == "agricultural" then
            Prototype.init(base, Player.getAgriculturalRecipe(base.object_name))
        elseif base.lua_type == "spoiling" then
            Prototype.init(base, Player.getSpoilableRecipe(base.object_name))
        end
        if base.lua_prototype == nil then
            Logging:error("HMRecipePrototype", "recipe not found", type(object), object)
            Logging:line("HMRecipePrototype", 3)
            Logging:line("HMRecipePrototype", 4)
            Logging:line("HMRecipePrototype", 5)
            Logging:line("HMRecipePrototype", 6)
        end
    end
end)

-------------------------------------------------------------------------------
---Try to find prototype
---@param object table --prototype
---@return RecipePrototype
function RecipePrototype.find(object)
    local object_name = nil
    if type(object) == "string" then
        object_name = object
    elseif object.name ~= nil then
        object_name = object.name
    end
    local lua_prototype = Player.getPlayerRecipe(object_name)
    local lua_type = "recipe"
    if lua_prototype == nil then
        lua_prototype = Player.getPlayerTechnology(object_name)
        lua_type = "technology"
    end
    if lua_prototype == nil then
        lua_prototype = Player.getEntityPrototype(object_name)
        lua_type = "resource"
    end
    if lua_prototype == nil then
        lua_prototype = Player.getFluidPrototype(object_name)
        lua_type = "fluid"
    end
    return RecipePrototype(lua_prototype, lua_type)
end

-------------------------------------------------------------------------------
---Return type Prototype
---@return string
function RecipePrototype:getType()
    return self.lua_type
end

-------------------------------------------------------------------------------
---Return Allowed Effects
---@return table
function RecipePrototype:getAllowedEffects()
    if self.lua_prototype == nil then return {} end
    if self.lua_prototype.object_name == "LuaTechnologyPrototype" then return {} end
    return self.lua_prototype.allowed_effects
end

-------------------------------------------------------------------------------
---Return Allowed Effects
---@return table | nil
function RecipePrototype:getAllowedEffectMessage(effect_name)
    if self.lua_prototype == nil then return nil end
    if self.lua_prototype.object_name == "LuaTechnologyPrototype" then return nil end
    if self.lua_prototype.effect_limitation_messages ~= nil then
        local message_name = string.format("allow_%s_message", effect_name)
        local effect_limitation_messages = self.lua_prototype.effect_limitation_messages
        return effect_limitation_messages[message_name]
    else
        local message_name = string.format("item-limitation.%s-effect", effect_name)
        return {message_name}
    end
    return nil
end

-------------------------------------------------------------------------------
---Return Allowed Module Categories
---@return table
function RecipePrototype:getAllowedModuleCategories()
    if self.lua_prototype == nil then return nil end
    if self.lua_prototype.object_name == "LuaTechnologyPrototype" then return nil end
    return self.lua_prototype.allowed_module_categories
  end

  -------------------------------------------------------------------------------
---Return if recipe void ingredient
---for flare stack/clarifier ect...
---@return boolean
function RecipePrototype:isVoid()
    if self.is_voider == nil then self:getProducts() end
    return self.is_voider
end

-------------------------------------------------------------------------------
---Return category of Prototype
---@return string
function RecipePrototype:getCategory()
    if self.lua_type == "technology" then
        return "technology"
    end
    if self.lua_prototype ~= nil then
        return self.lua_prototype.category or "crafting"
    end
    return nil
end

-------------------------------------------------------------------------------
---Return products array of Prototype (duplicates are combined into one entry)
---@param factory table
---@return table
function RecipePrototype:getProducts(factory)
    local raw_products = self:getRawProducts(factory)
    ---if recipe is a voider
    if #raw_products == 1 and Product(raw_products[1]):getElementAmount() == 0 then
        self.is_voider = true
        return {}
    else
        self.is_voider = false
    end
    local factory_prototype = EntityPrototype(factory)
    local lua_products = {}
    for r, raw_product in pairs(raw_products) do
        local product_id = raw_product.type .. "/" .. raw_product.name
        if raw_product.temperature then
            product_id = product_id .. "#" .. raw_product.temperature
        end
        if lua_products[product_id] ~= nil then
            ---make a new product table for the combined result
            ---combine product amounts, averaging in variable and probabilistic outputs
            local amount_a = Product(lua_products[product_id]):getElementAmount()
            local amount_b = Product(raw_product):getElementAmount()
            lua_products[product_id] = { type = raw_product.type, name = raw_product.name, amount = amount_a + amount_b }
        else
            lua_products[product_id] = raw_product
        end
        if self.lua_type == "recipe-burnt" and raw_product.type == "item" then
            local item = ItemPrototype(raw_product.name)
            local burnt_result = item:getBurntResult()
            if burnt_result ~= nil then
                local burnt_id = burnt_result.type .. "/" .. burnt_result.name
                lua_products[burnt_id] = { type = burnt_result.type, name = burnt_result.name,
                    amount = lua_products[product_id].amount }
            end
        end
        if factory ~= nil and factory_prototype:getType() == "boiler" then
            local fluid_name = "steam"
            local fluid_production = factory_prototype:getFluidProductionFilter()
            if fluid_production ~= nil and fluid_production.name ~= nil then
                fluid_name = fluid_production.name
            end
            if lua_products[product_id] ~= nil and fluid_name == raw_product.name then
                local amount = factory_prototype:getFluidProductionOfBoiler()
                lua_products[product_id].amount = amount
                lua_products[product_id].temperature = factory_prototype:getTargetTemperature()
            end
        end
    end

    ---convert map to array
    local raw_products = {}
    for _, lua_product in pairs(lua_products) do
        table.insert(raw_products, lua_product)
    end

    if self.lua_type == "energy" then
        if factory_prototype:getType() == "reactor" then
            local bonus = factory_prototype:getNeighbourBonus()
            for _, raw_product in pairs(raw_products) do
                if raw_product.name == "steam-heat" then
                    raw_product.amount = raw_product.amount * (1 + bonus)
                end
            end
        end
    end

    ---insert burnt
    if factory ~= nil and factory_prototype:getEnergyType() == "burner" then
        local energy_prototype = factory_prototype:getEnergySource()
        if energy_prototype ~= nil and energy_prototype:getFuelCount() ~= nil then
            local fuel_count = energy_prototype:getFuelCount()
            if fuel_count ~= nil and fuel_count.type == "item" then
                local item = ItemPrototype(fuel_count.name)
                local burnt_result = item:getBurntResult()
                if burnt_result ~= nil then
                    local factor = 1
                    if self.lua_type ~= "energy" then
                        local consumption_effect = 1
                        if factory.effects ~= nil then
                            consumption_effect = 1 + (factory.effects.consumption or 0)
                        end
                        factor = self:getEnergy() * consumption_effect / factory.speed
                    end
                    table.insert(raw_products,
                        { type = burnt_result.type, name = burnt_result.name, amount = fuel_count.count * factor,
                            catalyst_amount = fuel_count.count * factor })
                end
            end
        end
    end
    return raw_products
end

---Compute quality of products
---@param quality_products table
---@param raw_product ProductData
---@param lua_quality LuaQualityPrototype
---@param quality_effect number
---@return number
function RecipePrototype:getNextQualityProducts(quality_products, raw_product, lua_quality, quality_effect)
    local quality_product = Product(raw_product):clone()
    quality_product.quality = lua_quality.name
    quality_product.amount = quality_product.amount * quality_effect
    raw_product.amount = raw_product.amount - quality_product.amount
    table.insert(quality_products, quality_product)

    local next_probability = lua_quality.next_probability
    if next_probability > 0 and quality_effect > 0  then
        self:getNextQualityProducts(quality_products, raw_product, lua_quality.next, quality_effect * next_probability)
    end
end

-------------------------------------------------------------------------------
---Return products array of Prototype
---@param factory table
---@param quality string
---@return table
function RecipePrototype:getQualityProducts(factory, quality)
    local raw_products = self:getProducts(factory)
    if quality == nil then
        quality = "normal"
    end
    -- can't do use greater quality
    if self.is_support_quality == false then
        quality = "normal"
    end
    local quality_products = {}
    local lua_quality = Player.getQualityPrototype(quality)
    local quality_effect = 0 
    if factory ~= nil and factory.effects ~= nil then
        quality_effect = factory.effects.quality or 0
    end
    
    local next_probability = lua_quality.next_probability
    for _, raw_product in pairs(raw_products) do
        if raw_product.type == "item" then
            raw_product.quality = quality
            if next_probability > 0 and quality_effect > 0  then
                self:getNextQualityProducts(quality_products, raw_product, lua_quality.next, quality_effect)
            end
        end
    end
    if #quality_products > 0 then
        for _, quality_product in pairs(quality_products) do
            table.insert(raw_products, quality_product)
        end
    end
    return raw_products
end

-------------------------------------------------------------------------------
---Return ingredients array of Prototype
---@param factory table
---@param quality string
---@return table
function RecipePrototype:getQualityIngredients(factory, quality)
    local raw_ingredients = self:getIngredients(factory)
    if self.is_support_quality == false then
        return raw_ingredients
    end
    for _, raw_ingredient in pairs(raw_ingredients) do
        if raw_ingredient.type == "item" then
            raw_ingredient.quality = quality
        end
    end
    return raw_ingredients
end

-------------------------------------------------------------------------------
---Return products array of Prototype (may contain duplicate products)
---@param factory table
---@return table
function RecipePrototype:getRawProducts(factory)
    if self.lua_prototype ~= nil then
        if self.lua_type == "energy" then
            return self:getEnergyProducts(factory)
        elseif self.lua_type == "technology" then
            return { { name = self.lua_prototype.name, type = "technology", amount = 1 } }
        else
            return self.lua_prototype.products
        end
    end
    return {}
end

-------------------------------------------------------------------------------
---Return products array of Prototype (may contain duplicate products)
---@param factory table
---@return table
function RecipePrototype:getEnergyProducts(factory)
    if self.lua_prototype ~= nil then
        local products = {}
        local prototype
        if factory ~= nil then
            prototype = EntityPrototype(factory)
        else
            prototype = EntityPrototype(self.lua_prototype.name)
        end
        local prototype_type = prototype:getType()
        if prototype_type == "solar-panel" or prototype_type == "electric-energy-interface" then
            local amount = prototype:getEnergyProduction()
            if amount > 0 then
                local product = { name = "energy", type = "energy", amount = amount }
                table.insert(products, product)
            end
        elseif prototype_type == "accumulator" then
            local energy_prototype = prototype:getEnergySource()
            local capacity = energy_prototype:getBufferCapacity()
            ---vanilla day=25000,dusk=5000,night=2500,dawn=5000
            local day, dusk, night, dawn = Player.getGameDay()
            local t1 = day - dusk - night - dawn
            local t2 = night
            local t3 = (dusk + dawn) / 2
            local T = day
            ---E_acc = P * (t2 + t2 + 2 * (t3 * P/P')) / 2 = P * (t2 + t3*P/P')
            ---P' = P * T / (t1 + t3)
            ---@see https://forums.factorio.com/viewtopic.php?f=5&t=5594
            local R = 60 / (t2 + t3 * (t1 + t3) / T)
            local amount = capacity * R

            local product = { name = "energy", type = "energy", amount = amount }
            table.insert(products, product)
        elseif prototype_type == "generator" or prototype_type == "burner-generator" then
            local amount = prototype:getEnergyProduction()
            local product = { name = "energy", type = "energy", amount = amount }
            table.insert(products, product)
        elseif prototype_type == "reactor" then
            local amount = prototype:getEnergyProduction()
            local product = { name = "steam-heat", type = "energy", amount = amount }
            table.insert(products, product)
        elseif prototype_type == "fusion-reactor" then
            local fluid_name = "fusion-plasma"
            local fluid_production = prototype:getFluidProductionFilter()
            if fluid_production ~= nil and fluid_production.name ~= nil then
                fluid_name = fluid_production.name
            end
            if fluid_name ~= nil then
                local amount = prototype:getFluidProductionFusionReactor()
                local product = { name = fluid_name, type = "fluid", amount = amount }
                table.insert(products, product)
            end
        elseif prototype_type == "fusion-generator" then
            -- value per tick
            local amount = prototype:getMaxEnergyProduction() * 60
            local product = { name = "energy", type = "energy", amount = amount }
            table.insert(products, product)

            if prototype_type == "fusion-generator" then
                local fluid_name = "fluoroketone-hot"
                local fluid_consumption = prototype:getFluidProductionFilter()
                if fluid_consumption ~= nil and fluid_consumption.name ~= nil then
                    fluid_name = fluid_consumption.name
                end
                if fluid_name ~= nil then
                    local amount = prototype:getFluidConsumptionFusionGenerator()
                    local ingredient = { name = fluid_name, type = "fluid", amount = amount }
                    table.insert(products, ingredient)
                end
            end
        end
        return products
    end
    return {}
end

-------------------------------------------------------------------------------
---Return products array of Prototype (may contain duplicate products)
---@return table
function RecipePrototype:getRawIngredients()
    if self.lua_prototype ~= nil then
        if self.lua_type == "technology" then
            return self.lua_prototype.research_unit_ingredients
        elseif self.lua_type == "energy" then
            local ingredients = {}
            local prototype = EntityPrototype(self.lua_prototype.name)
            local prototype_type = prototype:getType()

            if prototype_type == "accumulator" then
                local energy_prototype = prototype:getEnergySource()
                local capacity = energy_prototype:getBufferCapacity()
                ---vanilla day=25000,dusk=5000,night=2500,dawn=5000
                local day, dusk, night, dawn = Player.getGameDay()
                local t1 = day - dusk - night - dawn
                local t2 = night
                local t3 = (dusk + dawn) / 2
                local T = day
                ---E_acc = P * (t2 + t2 + 2 * (t3 * P/P')) / 2 = P * (t2 + t3*P/P')
                ---P' = P * T / (t1 + t3)
                ---@see https://forums.factorio.com/viewtopic.php?f=5&t=5594
                local R = 60 / (t2 + t3 * (t1 + t3) / T)
                local amount = capacity * R * T / (t1 + t3)
                local ingredient = { name = "energy", type = "energy", amount = amount }
                table.insert(ingredients, ingredient)
            end

            local energy_type = prototype:getEnergyTypeInput()
            if prototype_type  ~= "accumulator" and energy_type == "electric" then
                local amount = prototype:getEnergyConsumption()
                if amount > 0 then
                    local ingredient = { name = "energy", type = "energy", amount = amount }
                    table.insert(ingredients, ingredient)
                end
            elseif energy_type == "heat" then
                local amount = prototype:getEnergyConsumption()
                local ingredient = { name = "steam-heat", type = "energy", amount = amount }
                table.insert(ingredients, ingredient)
            end

            local prototype = EntityPrototype(self.lua_prototype.name)
            local prototype_type = prototype:getType()

            if prototype_type == "fusion-reactor" then
                local fluid_name = "fluoroketone-cold"
                local fluid_production = prototype:getFluidConsumptionFilter()
                if fluid_production ~= nil and fluid_production.name ~= nil then
                    fluid_name = fluid_production.name
                end
                if fluid_name ~= nil then
                    local amount = prototype:getFluidProductionFusionReactor()
                    local product = { name = fluid_name, type = "fluid", amount = amount }
                    table.insert(ingredients, product)
                end
            end

            if prototype_type == "fusion-generator" then
                local fluid_name = "fusion-plasma"
                local fluid_consumption = prototype:getFluidConsumptionFilter()
                if fluid_consumption ~= nil and fluid_consumption.name ~= nil then
                    fluid_name = fluid_consumption.name
                end
                if fluid_name ~= nil then
                    local amount = prototype:getFluidConsumptionFusionGenerator()
                    local ingredient = { name = fluid_name, type = "fluid", amount = amount }
                    table.insert(ingredients, ingredient)
                end
            end

            return ingredients
        else
            return self.lua_prototype.ingredients
        end
    end
    return {}
end

-------------------------------------------------------------------------------
---Return solid ingredient number of Prototype
---@return number
function RecipePrototype:getIngredientCount()
    local count = 0
    local ingredients = self:getIngredients()
    if self.lua_prototype ~= nil and ingredients ~= nil then
        for _, lua_ingredient in pairs(ingredients) do
            if Product(lua_ingredient):getType() == "item" then
                count = count + 1
            end
        end
    end
    return count
end

function RecipePrototype:getRocketPenalty(factory)
    local factory_prototype = EntityPrototype(factory)
    local rocket_prototype = factory_prototype:native()
    local recipe_part_name = rocket_prototype.fixed_recipe
    local rocket_part_prototype = RecipePrototype(recipe_part_name):native()
    local factory_speed = factory.speed_total
    local cycles_time = rocket_part_prototype.energy * rocket_prototype.rocket_parts_required / factory_speed
    cycles_time = cycles_time / (1 + factory.effects.productivity)
    local total_time = defines.constant.rocket_deploy_delay + cycles_time 
    local factor = cycles_time / total_time
    return factor
end

function RecipePrototype:getRocketEnergy(factory)
    local factory_prototype = EntityPrototype(factory)
    local rocket_prototype = factory_prototype:native()
    local recipe_part_name = rocket_prototype.fixed_recipe
    local rocket_part_prototype = RecipePrototype(recipe_part_name):native()
    local rocket_energy = rocket_part_prototype.energy * rocket_prototype.rocket_parts_required
    return rocket_energy
end

-------------------------------------------------------------------------------
---Return ingredients array of Prototype
---@param factory table
---@return table
function RecipePrototype:getIngredients(factory)
    local raw_ingredients = self:getRawIngredients()
    if self.lua_prototype ~= nil then
        local factory_prototype = EntityPrototype(factory)
        local energy_prototype = factory_prototype:getEnergySource()
        local energy_type = factory_prototype:getEnergyTypeInput()

        if factory_prototype:getType() == "offshore-pump" then
            return {}
        end

        if self.lua_type == "boiler" then
            local fluid_name = "water"
            local fluid_consumption = factory_prototype:getFluidConsumptionFilter()
            if fluid_consumption ~= nil and fluid_consumption.name ~= nil then
                fluid_name = fluid_consumption.name
            end
            if fluid_name ~= nil then
                local amount = factory_prototype:getFluidConsumptionOfBoiler()
                local ingredient = { name = fluid_name, type = "fluid", amount = amount }
                raw_ingredients = {}
                table.insert(raw_ingredients, ingredient)
            end
        end

        if self.lua_type == "rocket" then
            local rocket_prototype = factory_prototype:native()
            local recipe_part_name = rocket_prototype.fixed_recipe
            local rocket_part_prototype = RecipePrototype(recipe_part_name):native()
            local ingredients = rocket_part_prototype.ingredients
            for _, ingredient in pairs(ingredients) do
                ingredient.amount = ingredient.amount * rocket_prototype.rocket_parts_required
                table.insert(raw_ingredients, ingredient)
            end
        elseif self.lua_type ~= "energy" then
            local consumption_effect = 1
            if factory ~= nil then
                if factory.effects ~= nil then
                    consumption_effect = 1 + (factory.effects.consumption or 0)
                end
            end
            ---recipe
            if energy_type == "burner" then
                if energy_prototype ~= nil and energy_prototype:getFuelCount() ~= nil then
                    local fuel_count = energy_prototype:getFuelCount()
                    local factor = self:getEnergy() * consumption_effect / factory.speed
                    local burner_ingredient = { name = fuel_count.name, type = fuel_count.type,
                        amount = fuel_count.count * factor, burnt = true }
                    table.insert(raw_ingredients, burner_ingredient)
                end
            elseif energy_type == "heat" then
                local amount = factory_prototype:getEnergyConsumption()
                local factor = self:getEnergy() * consumption_effect / factory.speed
                local ingredient = { name = "steam-heat", type = "energy", amount = amount * factor }
                table.insert(raw_ingredients, ingredient)
            elseif energy_type == "fluid" then
                local fluid_fuel = factory_prototype:getFluidFuelPrototype()
                if fluid_fuel ~= nil and fluid_fuel:native() ~= nil then
                    local amount = factory_prototype:getFluidConsumption()
                    local factor = self:getEnergy() * consumption_effect / factory.speed
                    local burner_ingredient = { name = fluid_fuel:native().name, type = "fluid", amount = amount * factor,
                        burnt = true, temperature = fluid_fuel.temperature }
                    table.insert(raw_ingredients, burner_ingredient)
                end
            end

        else
            ---recipe energy
            if energy_type == "burner" then
                if energy_prototype ~= nil and energy_prototype:getFuelCount() ~= nil then
                    local fuel_count = energy_prototype:getFuelCount()
                    local factor = self:getEnergy()
                    local burner_ingredient = { name = fuel_count.name, type = fuel_count.type,
                        amount = fuel_count.count * factor, burnt = true }
                    table.insert(raw_ingredients, burner_ingredient)
                end
            elseif energy_type == "fluid" then
                local fluid_fuel = factory_prototype:getFluidFuelPrototype()
                if fluid_fuel ~= nil and fluid_fuel:native() ~= nil then
                    local amount = factory_prototype:getFluidConsumption()
                    local factor = self:getEnergy()
                    local burner_ingredient = { name = fluid_fuel:native().name, type = "fluid", amount = amount * factor,
                        burnt = true, temperature = fluid_fuel.temperature }
                    table.insert(raw_ingredients, burner_ingredient)
                end
            end
        end
    end
    return raw_ingredients
end

-------------------------------------------------------------------------------
---Return energy of Prototype
---@param factory? table
---@return number
function RecipePrototype:getEnergy(factory)
    if self.lua_prototype ~= nil then
        if self.lua_type == "energy" then
            return 1
        elseif self.lua_type == "technology" then
            return self.lua_prototype.research_unit_energy / 60
        elseif self.lua_type == "rocket" then
            return self:getRocketEnergy(factory)
        else
            return self.lua_prototype.energy
        end
    end
    return 0
end

-------------------------------------------------------------------------------
---Return enable of Prototype
---@return boolean
function RecipePrototype:getEnabled()
    if self.lua_prototype ~= nil then
        if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" then
            local lua_recipe = Player.getPlayerRecipe(self.lua_prototype.name)
            if lua_recipe == nil then return false end
            return lua_recipe.enabled
        elseif self.lua_type == "resource" or self.lua_type == "fluid" then
            return self.lua_prototype.enabled
        elseif self.lua_type == "technology" then
            return true
        end
    end
    return true
end

-------------------------------------------------------------------------------
---Return unlock of Prototype
---@return boolean
function RecipePrototype:getUnlock()
    if self.lua_prototype ~= nil then
        if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" then
            local unlock_recipes = Cache.getData("other", "unlock_recipes") or {}
            return unlock_recipes[self.lua_prototype.name]
        end
        return true
    end
    return false
end

-------------------------------------------------------------------------------
---Return hidden of Prototype
---@return boolean
function RecipePrototype:getHidden()
    if self.lua_prototype ~= nil then
        if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" or self.lua_type == "resource" or self.lua_type == "energy" then
            return self.lua_prototype.hidden
        elseif self.lua_type == "technology" then
            return false
        elseif self.lua_type == "fluid" then
            local fluid = Player.getFluidPrototype(self.lua_prototype.name)
            if fluid ~= nil then
                return fluid.hidden
            end
            return false
        elseif self.lua_type == "boiler" then
            for _, entity in pairs(Player.getBoilersForRecipe(self.lua_prototype.name)) do
                return false
            end
            return false
        end
    end
    return false
end

-------------------------------------------------------------------------------
---Return hidden player crafting of Prototype
---@return boolean
function RecipePrototype:getHiddenPlayerCrafting()
    if self.lua_prototype ~= nil then
        if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" then
            return self.lua_prototype.hidden_from_player_crafting
        else
            return false
        end
    end
    return false
end

-------------------------------------------------------------------------------
---Return emissions multiplier of Prototype
---@return number
function RecipePrototype:getEmissionsMultiplier()
    if self.lua_prototype ~= nil then
        local prototype = Player.getRecipe(self.lua_prototype.name)
        if prototype == nil then return 1 end
        return prototype.emissions_multiplier or 1
    end
    return 1
end

-------------------------------------------------------------------------------
---Return true if result item has a burnt result
---@return boolean
function RecipePrototype:getHasBurntResult()
    if self.lua_prototype ~= nil then
        for key, raw_product in pairs(self:getRawProducts(self.lua_prototype)) do
            local product = Product(raw_product)
            if product:hasBurntResult() == true then
                return true
            end
        end
    end
    return false
end

---@return string, string
function RecipePrototype:getIcon()
    if self.lua_prototype == nil then return "utility","warning_icon" end
    local icon_name = self.lua_prototype.name
    local icon_type = self.lua_type

    if self.lua_type == "recipe-burnt" then
        icon_type = "recipe"
    elseif self.lua_type == "resource" then
        icon_type = "entity"
    elseif self.lua_type == "rocket" then
        icon_type = "item"
    elseif self.lua_type == "energy" then
        icon_type = "entity"
    elseif self.lua_type == "boiler" then
        icon_type = "fluid"
        icon_name = self.output_fluid_name
    elseif self.lua_type == "agricultural" then
        icon_type = "item"
    elseif self.lua_type == "spoiling" then
        icon_type = "item"
    end

    return icon_name, icon_type
end
