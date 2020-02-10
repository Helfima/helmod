---
-- Description of the module.
-- @module RecipePrototype
--
RecipePrototype = newclass(Prototype,function(base, object, object_type)
  --Logging:debug("HMRecipePrototype", "constructor", type(object), object, object_type)
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
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
      return self.lua_prototype.products
    elseif self.lua_type == "technology" then
      return {{name=self.lua_prototype.name, type="technology", amount=1}}
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
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
      return self.lua_prototype.ingredients
    elseif self.lua_type == "technology" then
      return self.lua_prototype.research_unit_ingredients
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
-- @return #table
--
function RecipePrototype:getIngredients(factory)
  Logging:trace(self.classname, "getIngredients()", self.lua_prototype, self.lua_type)
  if self.lua_prototype ~= nil then
    local first_fuel = EntityPrototype(factory):getBurnerPrototype():getFirstFuelItemPrototype()
    local factory_fuel = first_fuel.name
    if self.lua_type == "recipe" then
      local ingredients = self.lua_prototype.ingredients
      local entity_prototype = EntityPrototype(factory)
      if factory ~= nil and entity_prototype:getEnergyType() == "burner" then
        local energy_usage = entity_prototype:getEnergyUsage()
        local burner_effectivity = entity_prototype:getBurnerEffectivity()
        local speed_factory = entity_prototype:getCraftingSpeed()
        factory_fuel = factory.fuel or factory_fuel

        --Logging:debug(RecipePrototype.classname, "burner", energy_usage,speed_factory,burner_effectivity,burner_emission)
        local fuel_value = (energy_usage/burner_effectivity)*(self:getEnergy()/speed_factory)
        local burner_count = fuel_value/ItemPrototype(factory_fuel):getFuelValue()
        local burner_ingredient = {name=factory_fuel, type="item", amount=burner_count}
        table.insert(ingredients, burner_ingredient)
      end
      return ingredients
    elseif self.lua_type == "resource" then
      local ingredients = self.lua_prototype.ingredients
      -- ajouter le liquide obligatoire, s'il y en a
      local entity_prototype = EntityPrototype(self.lua_prototype)
      -- computing burner
      -- @see https://wiki.factorio.com/Fuel
      -- Burn time (s) = Fuel value (MJ) ÷ Energy consumption (MW)
      -- source energy en kJ
      local hardness = entity_prototype:getMineableHardness()
      local mining_time = entity_prototype:getMineableMiningTime()
      local factory_prototype = EntityPrototype(factory)
      if factory ~= nil and factory_prototype:getEnergyType() == "burner" then
        local energy_usage = factory_prototype:getEnergyUsage()
        local burner_effectivity = factory_prototype:getBurnerEffectivity()
        local mining_speed = factory_prototype:getMiningSpeed()
        factory_fuel = factory.fuel or factory_fuel
        local speed_factory = hardness * mining_speed / mining_time
        --Logging:debug(RecipePrototype.classname, "resource burner", energy_usage,speed_factory,burner_effectivity,burner_emission)
        local fuel_value = (energy_usage/burner_effectivity)*(1/speed_factory)
        local burner_count = fuel_value/ItemPrototype(factory_fuel):getFuelValue()
        local burner_ingredient = {name=factory_fuel, type="item", amount=burner_count}
        table.insert(ingredients, burner_ingredient)
      end
      return ingredients
    elseif self.lua_type == "fluid" then
      local ingredients = self.lua_prototype.ingredients
      if self.lua_prototype.name == "steam" then
        local factory_prototype = EntityPrototype(factory)
        if factory ~= nil and factory_prototype:getEnergyType() == "burner" then
          factory_fuel = factory.fuel or factory_fuel
          -- source energy en kJ
          local power_extract = factory_prototype:getPowerExtract()
          local amount = power_extract/(ItemPrototype(factory_fuel):getFuelValue()*factory_prototype:getBurnerEffectivity())
          table.insert(ingredients, {name=factory_fuel, type="item", amount=amount})
        end
      end
      return ingredients
    elseif self.lua_type == "technology" then
      return self.lua_prototype.research_unit_ingredients
    end
  end
  return {}
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
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
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
    if self.lua_type == "recipe" or self.lua_type == "resource" or self.lua_type == "fluid" then
      return self.lua_prototype.hidden
    elseif self.lua_type == "technology" then
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
