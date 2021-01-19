---
-- Description of the module.
-- @module RecipePrototype
--
RecipePrototype = newclass(Prototype,function(base, object, object_type)
  base.classname = "HMRecipePrototype"
  base.is_voider = nil
  if object ~= nil then
    if type(object) == "string" then
      base.object_name = object
      base.lua_type = object_type
    elseif object.name ~= nil then
      base.object_name = object.name
      base.lua_type = object_type or object.type
    end
    if base.lua_type == nil or base.lua_type == "recipe" then
      Prototype.init(base, Player.getRecipePrototype(base.object_name))
      base.lua_type = "recipe"
    elseif base.lua_type == "recipe-burnt" then
      Prototype.init(base, Player.getRecipeBurnt(base.object_name))
      base.lua_type = "recipe-burnt"
    elseif base.lua_type == "energy" then
      Prototype.init(base, Player.getRecipeEntity(base.object_name))
      base.lua_type = "energy"
    elseif base.lua_type == "resource" then
      Prototype.init(base, Player.getRecipeEntity(base.object_name))
      base.lua_type = "resource"
    elseif base.lua_type == "fluid" then
      Prototype.init(base, Player.getRecipeFluid(base.object_name))
      base.lua_type = "fluid"
    elseif base.lua_type == "technology" then
      Prototype.init(base, Player.getTechnology(base.object_name))
      base.lua_type = "technology"
    elseif base.lua_type == "rocket" then
      Prototype.init(base, Player.getRecipeRocket(base.object_name))
      base.lua_type = "rocket"
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
-- Try to find prototype
--
-- @function [parent=#RecipePrototype] find
--
-- @param #object object prototype
--
-- @return #RecipePrototype
--
function RecipePrototype.find(object)
  local object_name = nil
  if type(object) == "string" then
    object_name = object
  elseif object.name ~= nil then
    object_name = object.name
  end
  local lua_prototype = Player.getRecipe(object_name)
  local lua_type = "recipe"
  if lua_prototype == nil then
    lua_prototype = Player.getTechnology(object_name)
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
-- Return type Prototype
--
-- @function [parent=#RecipePrototype] getType
--
-- @return #lua_type
--
function RecipePrototype:getType()
  return self.lua_type
end

-------------------------------------------------------------------------------
-- Return if recipe void ingredient
-- for flare stack/clarifier ect...
-- @function [parent=#RecipePrototype] isVoid
--
-- @return #boolean
--
function RecipePrototype:isVoid()
  if self.is_voider == nil then self:getProducts() end
  return self.is_voider
end

-------------------------------------------------------------------------------
-- Return category of Prototype
--
-- @function [parent=#RecipePrototype] getCategory
--
-- @return #table
--
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
-- Return products array of Prototype (duplicates are combined into one entry)
--
-- @function [parent=#RecipePrototype] getProducts
--
-- @return #table
--
function RecipePrototype:getProducts(factory)
  local raw_products = self:getRawProducts()
  -- if recipe is a voider
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
    if lua_products[product_id] ~= nil then
      -- make a new product table for the combined result
      -- combine product amounts, averaging in variable and probabilistic outputs
      local amount_a = Product(lua_products[product_id]):getElementAmount()
      local amount_b = Product(raw_product):getElementAmount()
      lua_products[product_id] = {type=raw_product.type,name=raw_product.name,amount=amount_a + amount_b}
    else
      lua_products[product_id] = raw_product
    end
    if self.lua_type == "recipe-burnt" and raw_product.type == "item" then
      local item = ItemPrototype(raw_product.name)
      local burnt_result = item:getBurntResult()
      if burnt_result ~= nil then
        local burnt_id = burnt_result.type .. "/" .. burnt_result.name
        lua_products[burnt_id] = {type=burnt_result.type,name=burnt_result.name,amount=lua_products[product_id].amount}
      end
    end
    if factory ~= nil and factory.temperature_enabled == true and factory_prototype:getType() == "boiler" then
      local fluid_production = factory_prototype:getFluidProductionFilter()
      if lua_products[product_id] ~= nil and fluid_production.name == raw_product.name then
        lua_products[product_id].temperature = factory_prototype:getTargetTemperature()
      end
    end
  end
  -- convert map to array
  local raw_products = {}
  for _, lua_product in pairs(lua_products) do
    table.insert(raw_products,lua_product)
  end
  -- insert burnt
  if self.lua_type == "energy" then
    if factory_prototype:getType() == "reactor" then
      local bonus = factory_prototype:getNeighbourBonus()
      for _, raw_product in pairs(raw_products) do
        if raw_product.name == "steam-heat" then
          raw_product.amount = raw_product.amount * (1 + bonus)
        end
      end
    end
    if factory ~= nil and factory_prototype:getEnergyType() == "burner" then
      local energy_prototype = factory_prototype:getEnergySource()
      if energy_prototype ~= nil and energy_prototype:getFuelCount() ~= nil then
        local fuel_count = energy_prototype:getFuelCount()
        if fuel_count ~= nil and fuel_count.type == "item" then
          local item = ItemPrototype(fuel_count.name)
          local burnt_result = item:getBurntResult()
          if burnt_result ~= nil then
            table.insert(raw_products, {type=burnt_result.type, name=burnt_result.name, amount=fuel_count.count, by_time=true})
          end
        end
      end
    end
  end

  return raw_products
end

-------------------------------------------------------------------------------
-- Return products array of Prototype (may contain duplicate products)
--
-- @function [parent=#RecipePrototype] getRawProducts
--
-- @return #table
--
function RecipePrototype:getRawProducts()
  if self.lua_prototype ~= nil then
    if self.lua_type == "energy" then
      return self:getEnergyProducts()
    elseif self.lua_type == "technology" then
      return {{name=self.lua_prototype.name, type="technology", amount=1}}
    else
      return self.lua_prototype.products
    end
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return products array of Prototype (may contain duplicate products)
--
-- @function [parent=#RecipePrototype] getEnergyProducts
--
-- @return #table
--
function RecipePrototype:getEnergyProducts()
  if self.lua_prototype ~= nil then
    local products = {}
    local prototype = EntityPrototype(self.lua_prototype.name)
    if prototype:getType() == "solar-panel" then
      local amount = prototype:getEnergyProduction()
      local product = {name="energy", type="energy", amount=amount}
      table.insert(products, product)
    end
    if prototype:getType() == "boiler" then
      local amount = prototype:getFluidProduction()
      local fluid_production = prototype:getFluidProductionFilter()
      if fluid_production ~= nil then
        local product = {name=fluid_production.name, type="fluid", amount=amount, by_time=true}
        table.insert(products, product)
      end
    end
    if prototype:getType() == "accumulator" then
      local energy_prototype = prototype:getEnergySource()
      local capacity = energy_prototype:getBufferCapacity()
      -- vanilla day=25000,dusk=5000,night=2500,dawn=5000
      local day,dusk,night,dawn = Player.getGameDay()
      local t1 = day-dusk-night-dawn
      local t2 = night
      local t3 = (dusk+dawn)/2
      local T = day
      -- E_acc = P * (t2 + t2 + 2 * (t3 * P/P')) / 2 = P * (t2 + t3*P/P')
      -- P' = P * T / (t1 + t3)
      -- @see https://forums.factorio.com/viewtopic.php?f=5&t=5594
      local R = 60/(t2+t3*(t1+t3)/T)
      local amount = capacity*R

      local product = {name="energy", type="energy", amount=amount}
      table.insert(products, product)
    end
    if prototype:getType() == "generator" then
      local amount = prototype:getEnergyProduction()
      local product = {name="energy", type="energy", amount=amount}
      table.insert(products, product)
    end
    if prototype:getType() == "reactor" then
      local amount = prototype:getEnergyConsumption()
      local product = {name="steam-heat", type="energy", amount=amount}
      table.insert(products, product)
    end
    if prototype:getType() == "offshore-pump" or prototype:getType() == "seafloor-pump" then
      local amount = prototype:getPumpingSpeed()
      local product = {name="water", type="fluid", amount=amount, by_time=true}
      table.insert(products, product)
    end
    return products
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return products array of Prototype (may contain duplicate products)
--
-- @function [parent=#RecipePrototype] getRawIngredients
--
-- @return #table
--
function RecipePrototype:getRawIngredients()
  if self.lua_prototype ~= nil then
    if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" or self.lua_type == "resource" or self.lua_type == "fluid" or self.lua_type == "rocket" then
      return self.lua_prototype.ingredients
    elseif self.lua_type == "technology" then
      return self.lua_prototype.research_unit_ingredients
    elseif self.lua_type == "energy" then
      local ingredients = {}
      local prototype = EntityPrototype(self.lua_prototype.name)
      local energy_source = prototype:getEnergySource()
      local usage_priority = "none"
      if energy_source ~= nil then
        energy_source:getUsagePriority()
      end

      if prototype:getType() == "boiler" then
        -- water
        local amount = prototype:getFluidProduction()
        local ingredient = {name="water", type="fluid", amount=amount, by_time=true}
        table.insert(ingredients, ingredient)
      end
      if prototype:getType() == "accumulator" then
        local energy_prototype = prototype:getEnergySource()
        local capacity = energy_prototype:getBufferCapacity()
        -- vanilla day=25000,dusk=5000,night=2500,dawn=5000
        local day,dusk,night,dawn = Player.getGameDay()
        local t1 = day-dusk-night-dawn
        local t2 = night
        local t3 = (dusk+dawn)/2
        local T = day
        -- E_acc = P * (t2 + t2 + 2 * (t3 * P/P')) / 2 = P * (t2 + t3*P/P')
        -- P' = P * T / (t1 + t3)
        -- @see https://forums.factorio.com/viewtopic.php?f=5&t=5594
        local R = 60/(t2+t3*(t1+t3)/T)
        local amount = capacity*R*T/(t1+t3)
        local ingredient = {name="energy", type="energy", amount=amount}
        table.insert(ingredients, ingredient)
      end

      local energy_type = prototype:getEnergyTypeInput()
      if prototype:getType() ~= "accumulator" and energy_type == "electric" then
        local amount = prototype:getEnergyConsumption()
        local ingredient = {name="energy", type="energy", amount=amount}
        table.insert(ingredients, ingredient)
      end
      if energy_type == "heat" then
        local amount = prototype:getEnergyConsumption()
        local ingredient = {name="steam-heat", type="energy", amount=amount}
        table.insert(ingredients, ingredient)
      end

      return ingredients
    end
  end
  return {}
end

-------------------------------------------------------------------------------
-- Return solid ingredient number of Prototype
--
-- @function [parent=#RecipePrototype] getIngredientCount
--
-- @return #number
--
function RecipePrototype:getIngredientCount(factory)
  local count = 0
  if self.lua_prototype ~= nil and self:getIngredients(factory) ~= nil then
    for _,lua_ingredient in pairs(self:getIngredients(factory)) do
      if Product(lua_ingredient):getType() == "item" then
        count = count + 1
      end
    end
  end
  return count
end
-------------------------------------------------------------------------------
-- Return ingredients array of Prototype
--
-- @function [parent=#RecipePrototype] getIngredients
--
-- @param factory
--
-- @return #table
--
function RecipePrototype:getIngredients(factory)
  local raw_ingredients = self:getRawIngredients()
  if self.lua_prototype ~= nil then
    local speed_factory = 1
    local consumption_effect = 1
    if factory ~= nil then
      speed_factory = factory.speed
      if factory.effects ~= nil then
        consumption_effect = 1 + (factory.effects.consumption or 0)
      end
    end
    local factory_prototype = EntityPrototype(factory)
    local energy_prototype = factory_prototype:getEnergySource()
    local energy_type = factory_prototype:getEnergyTypeInput()
    if factory_prototype:getType() == "offshore-pump" then
      return {}
    end

    if self.lua_type ~= "energy" then
      -- recipe
      if energy_type == "burner" then
        if energy_prototype ~= nil and energy_prototype:getFuelCount() ~= nil then
          local fuel_count = energy_prototype:getFuelCount()
          local factor = self:getEnergy()/speed_factory
          local burner_ingredient = {name=fuel_count.name, type=fuel_count.type, amount=fuel_count.count*factor, burnt=true}
          table.insert(raw_ingredients, burner_ingredient)
        end
      end
      if energy_type == "heat" then
        local amount = factory_prototype:getEnergyConsumption()
        local ingredient = {name="steam-heat", type="energy", amount=amount}
        table.insert(raw_ingredients, ingredient)
      end
      if energy_type == "fluid" then
        local fluid_fuel = factory_prototype:getFluidFuelPrototype(true)
        if fluid_fuel ~= nil and fluid_fuel:native() ~= nil then
          local amount = factory_prototype:getFluidConsumption()
          local factor = self:getEnergy()*consumption_effect/speed_factory
          local burner_ingredient = {name=fluid_fuel:native().name, type="fluid", amount=amount*factor, burnt=true}
          table.insert(raw_ingredients, burner_ingredient)
        end
      end
    else
      -- recipe energy
      if energy_type == "burner" then
        if energy_prototype ~= nil and energy_prototype:getFuelCount() ~= nil then
          local fuel_count = energy_prototype:getFuelCount()
          local factor = self:getEnergy()/speed_factory
          local burner_ingredient = {name=fuel_count.name, type=fuel_count.type, amount=fuel_count.count*factor, by_time=true, burnt=true}
          table.insert(raw_ingredients, burner_ingredient)
        end
      end
      if energy_type == "fluid" then
        local fluid_fuel = factory_prototype:getFluidFuelPrototype(true)
        if fluid_fuel ~= nil and fluid_fuel:native() ~= nil then
          local amount = factory_prototype:getFluidConsumption()
          local factor = self:getEnergy()*consumption_effect/speed_factory
          local burner_ingredient = {name=fluid_fuel:native().name, type="fluid", amount=amount*factor, by_time=true, burnt=true}
          table.insert(raw_ingredients, burner_ingredient)
        end
      end
    end
  end
  return raw_ingredients
end

-------------------------------------------------------------------------------
-- Return energy of Prototype
--
-- @function [parent=#RecipePrototype] getEnergy
--
-- @return #table
--
function RecipePrototype:getEnergy()
  if self.lua_prototype ~= nil then
    if self.lua_type == "energy" then
      return 1
    elseif self.lua_type == "technology" then	
      return self.lua_prototype.research_unit_energy/60
    else
      return self.lua_prototype.energy
    end
  end
  return 0
end

-------------------------------------------------------------------------------
-- Return enable of Prototype
--
-- @function [parent=#RecipePrototype] getEnabled
--
-- @return #boolean
--
function RecipePrototype:getEnabled()
  if self.lua_prototype ~= nil then
    if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" then
      local lua_recipe = Player.getRecipe(self.lua_prototype.name)
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
-- Return unlock of Prototype
--
-- @function [parent=#RecipePrototype] getUnlock
--
-- @return #boolean
--
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
-- Return hidden of Prototype
--
-- @function [parent=#RecipePrototype] getHidden
--
-- @return #boolean
--
function RecipePrototype:getHidden()
  if self.lua_prototype ~= nil then
    if self.lua_type == "recipe" or self.lua_type == "recipe-burnt" or self.lua_type == "resource" then
      return self.lua_prototype.hidden
    elseif self.lua_type == "technology" then
      return false
    elseif self.lua_type == "fluid" then
      return not(self.lua_prototype.name == "water" or self.lua_prototype.name == "steam")
    end
  end
  return false
end

-------------------------------------------------------------------------------
-- Return hidden player crafting of Prototype
--
-- @function [parent=#RecipePrototype] getHiddenPlayerCrafting
--
-- @return #boolean
--
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
-- Return emissions multiplier of Prototype
--
-- @function [parent=#RecipePrototype] getEmissionsMultiplier
--
-- @return #number
--
function RecipePrototype:getEmissionsMultiplier()
  if self.lua_prototype ~= nil then
    local prototype = Player.getRecipePrototype(self.lua_prototype.name)
    if prototype == nil then return 1 end
    return prototype.emissions_multiplier or 1
  end
  return 1
end
