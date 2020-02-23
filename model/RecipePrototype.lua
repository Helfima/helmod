---
-- Description of the module.
-- @module RecipePrototype
--
RecipePrototype = newclass(Prototype,function(base, object, object_type)
  Logging:debug("HMRecipePrototype", "constructor", type(object), object, object_type)
  base.classname = "HMRecipePrototype"
  base.is_voider = nil
  if type(object) == "string" then
    base.object_name = object
    base.lua_type = object_type
  elseif object.name ~= nil then
    base.object_name = object.name
    base.lua_type = object_type or object.type
  end
  Logging:trace(base.classname, "object_name", base.object_name, "lua_type", base.lua_type)
  if base.lua_type == nil or base.lua_type == "recipe" then
    Prototype.init(base, Player.getRecipePrototype(base.object_name))
    base.lua_type = "recipe"
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
  end
  if base.lua_prototype == nil then
    Logging:error("HMRecipePrototype", "recipe not found", type(object), object)
    Logging:line("HMRecipePrototype", 3)
    Logging:line("HMRecipePrototype", 4)
    Logging:line("HMRecipePrototype", 5)
    Logging:line("HMRecipePrototype", 6)
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
  if self.lua_prototype ~= nil and (self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid") then
    return self.lua_prototype.category or "crafting"
  elseif self.lua_type == "technology" then
    return "technology"
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
function RecipePrototype:getProducts()
  local model = Model.getModel()
  local raw_products = self:getRawProducts()
  --Logging:debug(RecipePrototype.classname, "raw_products", raw_products)
  -- if recipe is a voider
  if #raw_products == 1 and Product(raw_products[1]):getElementAmount() == 0 then
    self.is_voider = true
    return {}
  else
    self.is_voider = false
  end
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
  end
  -- convert map to array
  local raw_products = {}
  for _, lua_product in pairs(lua_products) do
    table.insert(raw_products,lua_product)
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
    local model = Model.getModel()
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
      return self.lua_prototype.products
    elseif self.lua_type == "technology" then
      return {{name=self.lua_prototype.name, type="technology", amount=1}}
    elseif self.lua_type == "energy" then
      local products = {}
      local prototype = EntityPrototype(self.lua_prototype.name)
      if prototype:getType() == EntityType.solar_panel then
        local amount = prototype:getEnergyNominal()
        local product = {name="energy", type="energy", amount=amount}
        table.insert(products, product)
      end
      if prototype:getType() == EntityType.boiler then
        local fluidboxes = prototype:getFluidboxPrototypes()
        if fluidboxes ~= nil then
          for _,fluidbox in pairs(fluidboxes) do
            local fluidbox_prototype = FluidboxPrototype(fluidbox)
            if fluidbox_prototype:native() ~= nil and fluidbox_prototype:isOutput() then
              local filter = fluidbox_prototype:native().filter
              if filter ~= nil then
                local amount = prototype:getFluidConsumption()
                local product = {name=filter.name, type="fluid", amount=amount * model.time}
                table.insert(products, product)
              end
            end
          end
        end
      end
      if prototype:getType() == EntityType.accumulator then
        local energy_prototype = prototype:getEnergySource()
        local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
        local dark_ratio = (gameDay.dust / 2 + gameDay.night + gameDay.dawn / 2)
        local amount = energy_prototype:getOutputFlowLimit()/60
        local product = {name="energy", type="energy", amount=amount}
        --Logging:debug("HMRecipePrototype", "capacity", energy_prototype:getBufferCapacity(), "dark", (gameDay.dust / 2 + gameDay.night + gameDay.dawn / 2))
        --Logging:debug("HMRecipePrototype", "product", product)
        table.insert(products, product)
      end
      if prototype:getType() == EntityType.generator then
        local amount = prototype:getEnergyNominal()
        local product = {name="energy", type="energy", amount=amount}
        table.insert(products, product)
      end
      if prototype:getType() == EntityType.reactor then
        local amount = prototype:getMaxEnergyUsage()
        local product = {name="steam-heat", type="energy", amount=amount}
        table.insert(products, product)
      end
      return products
    end
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
    local model = Model.getModel()
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
      return self.lua_prototype.ingredients
    elseif self.lua_type == "technology" then
      return self.lua_prototype.research_unit_ingredients
    elseif self.lua_type == "energy" then
      local ingredients = {}
      local prototype = EntityPrototype(self.lua_prototype.name)
      if prototype:getType() == EntityType.solar_panel then
      end
      if prototype:getType() == EntityType.boiler then
        local fluidboxes = prototype:getFluidboxPrototypes()
        if fluidboxes ~= nil then
          for _,fluidbox in pairs(fluidboxes) do
            local fluidbox_prototype = FluidboxPrototype(fluidbox)
            if fluidbox_prototype:native() ~= nil and fluidbox_prototype:isInput() then
              local filter = fluidbox_prototype:native().filter
              if filter ~= nil then
                local amount = prototype:getFluidConsumption()
                local ingredient = {name=filter.name, type="fluid", amount=amount * model.time}
                table.insert(ingredients, ingredient)
              end
            end
          end
        end
        if prototype:getTargetTemperature() > 200 then
            local amount = prototype:getMaxEnergyUsage()
            local ingredient = {name="steam-heat", type="energy", amount=amount}
            table.insert(ingredients, ingredient)
        end
      end
      if prototype:getType() == EntityType.accumulator then
        local energy_prototype = prototype:getEnergySource()
        local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
        local dark_ratio = (gameDay.dust / 2 + gameDay.night + gameDay.dawn / 2)
        local amount = energy_prototype:getInputFlowLimit()/60
        local ingredient = {name="energy", type="energy", amount=amount}
        table.insert(ingredients, ingredient)
      end
      if prototype:getType() == EntityType.generator then
        local fluidboxes = prototype:getFluidboxPrototypes()
        if fluidboxes ~= nil then
          for _,fluidbox in pairs(fluidboxes) do
            local fluidbox_prototype = FluidboxPrototype(fluidbox)
            if fluidbox_prototype:native() ~= nil and fluidbox_prototype:isInput() then
              local filter = fluidbox_prototype:native().filter
              if filter ~= nil then
                local amount = prototype:getFluidUsagePerTick() * 60
                local ingredient = {name=filter.name, type="fluid", amount=amount * model.time}
                table.insert(ingredients, ingredient)
              end
            end
          end
        end
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
  Logging:trace(self.classname, "getIngredients()", self.lua_prototype, self.lua_type)
  local model = Model.getModel()
  local raw_ingredients = self:getRawIngredients()
  if self.lua_prototype ~= nil then
    if self.lua_type == "recipe" then
      local factory_prototype = EntityPrototype(factory)
      if factory ~= nil and factory_prototype:getEnergyType() ~= "electric" then
        local energy_usage = factory_prototype:getEnergyUsage()
        local speed_factory = factory_prototype:getCraftingSpeed()
        
        local energy_type = factory_prototype:getEnergyType()
        if energy_type == "burner" or energy_type == "fluid" then
          local energy_prototype = factory_prototype:getEnergySource()
          local burner_effectivity = energy_prototype:getEffectivity()
          local factory_fuel = energy_prototype:getFuelPrototype(factory)
          local fuel_value = (energy_usage/burner_effectivity)*(self:getEnergy()/speed_factory)
          local burner_count = fuel_value/factory_fuel:getFuelValue()
          local ingredient_type = "item"
          if energy_type == "fluid" then ingredient_type = "fluid" end
          local burner_ingredient = {name=factory_fuel:native().name, type=ingredient_type, amount=burner_count}
          table.insert(raw_ingredients, burner_ingredient)
        end
      end
    elseif self.lua_type == "resource" then
      -- ajouter le liquide obligatoire, s'il y en a
      local entity_prototype = EntityPrototype(self.lua_prototype)
      -- computing burner
      -- @see https://wiki.factorio.com/Fuel
      -- Burn time (s) = Fuel value (MJ) ÷ Energy consumption (MW)
      -- source energy en kJ
      local hardness = entity_prototype:getMineableHardness()
      local mining_time = entity_prototype:getMineableMiningTime()
      local factory_prototype = EntityPrototype(factory)
      Logging:debug(self.classname, "getEnergyType()", self.lua_prototype, self.lua_type)
      if factory ~= nil and factory_prototype:getEnergyType() ~= "electric" then
        local energy_usage = factory_prototype:getEnergyUsage()
        local mining_speed = factory_prototype:getMiningSpeed()
        
        local energy_type = factory_prototype:getEnergyType()
        if energy_type == "burner" or energy_type == "fluid" then
          local energy_prototype = factory_prototype:getEnergySource()
          local burner_effectivity = energy_prototype:getEffectivity()
          local factory_fuel = energy_prototype:getFuelPrototype(factory)
          local speed_factory = hardness * mining_speed / mining_time
          --Logging:debug(RecipePrototype.classname, "resource burner", energy_usage,speed_factory,burner_effectivity,burner_emission)
          local fuel_value = (energy_usage/burner_effectivity)*(1/speed_factory)
          local burner_count = fuel_value/factory_fuel:getFuelValue()
          local ingredient_type = "item"
          if energy_type == "fluid" then ingredient_type = "fluid" end
          local burner_ingredient = {name=factory_fuel:native().name, type=ingredient_type, amount=burner_count}
          table.insert(raw_ingredients, burner_ingredient)
        end
      end
    elseif self.lua_type == "fluid" then
      if self.lua_prototype.name == "steam" then
        local factory_prototype = EntityPrototype(factory)
        if factory ~= nil and factory_prototype:getEnergyType() ~= "electric" then
          local energy_type = factory_prototype:getEnergyType()
          if energy_type == "burner" or energy_type == "fluid" then
            local energy_prototype = factory_prototype:getEnergySource()
            local burner_effectivity = energy_prototype:getEffectivity()
            local factory_fuel = energy_prototype:getFuelPrototype(factory)
            -- source energy en kJ
            local power_extract = factory_prototype:getPowerExtract()
            local fuel_value = factory_fuel:getFuelValue()
            local burner_count = power_extract/(fuel_value*burner_effectivity)
            local ingredient_type = "item"
            if energy_type == "fluid" then ingredient_type = "fluid" end
            local burner_ingredient = {name=factory_fuel:native().name, type=ingredient_type, amount=burner_count}
            table.insert(raw_ingredients, burner_ingredient)
          end
        end
      end
    elseif self.lua_type == "energy" then
      local factory_prototype = EntityPrototype(factory)
      if factory ~= nil and factory_prototype:getEnergyType() ~= "electric" then
        local energy_usage = factory_prototype:getMaxEnergyUsage()
        
        local energy_type = factory_prototype:getEnergyType()
        if energy_type == "burner" or energy_type == "fluid" then
          local energy_prototype = factory_prototype:getEnergySource()
          local burner_effectivity = energy_prototype:getEffectivity()
          local factory_fuel = energy_prototype:getFuelPrototype(factory)
          local fuel_value = factory_fuel:getFuelValue()
          local burner_count = energy_usage/(fuel_value*burner_effectivity)
          local ingredient_type = "item"
          if energy_type == "fluid" then ingredient_type = "fluid" end
          local burner_ingredient = {name=factory_fuel:native().name, type=ingredient_type, amount=burner_count * model.time}
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
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
      return self.lua_prototype.energy
    elseif self.lua_type == "technology" then
      return self.lua_prototype.research_unit_energy/60
    elseif self.lua_type == "energy" then
      return 1
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
    if self.lua_type == "recipe" then
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
-- Return hidden of Prototype
--
-- @function [parent=#RecipePrototype] getHidden
--
-- @return #boolean
--
function RecipePrototype:getHidden()
  if self.lua_prototype ~= nil then
    if self.lua_type == "recipe" or self.lua_type == "resource" then
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
