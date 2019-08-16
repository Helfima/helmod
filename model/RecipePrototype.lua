---
-- Description of the module.
-- @module RecipePrototype
--
local RecipePrototype = {
  -- single-line comment
  classname = "HMRecipePrototype"
}

local lua_prototype = nil
local lua_type = nil
local is_voider = nil

-------------------------------------------------------------------------------
-- Load factorio RecipePrototype
--
-- @function [parent=#RecipePrototype] load
--
-- @param #object object prototype
-- @param #string object_type prototype type
--
-- @return #RecipePrototype
--
function RecipePrototype.load(object, object_type)
  Logging:trace(RecipePrototype.classname, "load(object, object_type)", object, object_type)
  local object_name = nil
  is_voider = nil
  if type(object) == "string" then
    object_name = object
    lua_type = object_type
  elseif object.name ~= nil then
    object_name = object.name
    lua_type = object_type or object.type
  end
  Logging:trace(RecipePrototype.classname, "object_name", object_name, "lua_type", lua_type)
  if lua_type == nil or lua_type == "recipe" then
    lua_prototype = Player.getRecipe(object_name)
    lua_type = "recipe"
  elseif lua_type == "resource" then
    lua_prototype = Player.getEntityPrototype(object_name)
    lua_type = "resource"
  elseif lua_type == "fluid" then
    lua_prototype = Player.getFluidPrototype(object_name)
    lua_type = "fluid"
  elseif lua_type == "technology" then
    lua_prototype = Player.getTechnology(object_name)
    lua_type = "technology"
  end
  if lua_prototype == nil then
    RecipePrototype.find(object)
  end
  return RecipePrototype
end

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
  Logging:trace(RecipePrototype.classname, "find(object)", object)
  local object_name = nil
  if type(object) == "string" then
    object_name = object
  elseif object.name ~= nil then
    object_name = object.name
  end
  lua_prototype = Player.getRecipe(object_name)
  lua_type = "recipe"
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
  return RecipePrototype
end

-------------------------------------------------------------------------------
-- set prototype model
--
-- @function [parent=#RecipePrototype] set
--
-- @param #object object prototype
-- @param #string object_type prototype type
--
-- @return #RecipePrototype
--
function RecipePrototype.set(prototype, object_type)
  lua_prototype = prototype
  lua_type = object_type
  return RecipePrototype
end

-------------------------------------------------------------------------------
-- new prototype model
--
-- @function [parent=#RecipePrototype] new
--
-- @param #string type
-- @param #string name
--
-- @return #table
--
function RecipePrototype.new(type, name)
  local prototype = {
    type = type,
    name = name
  }
  return prototype
end

-------------------------------------------------------------------------------
-- Return factorio Prototype
--
-- @function [parent=#RecipePrototype] native
--
-- @return #lua_prototype
--
function RecipePrototype.native()
  return lua_prototype
end

-------------------------------------------------------------------------------
-- Return type Prototype
--
-- @function [parent=#RecipePrototype] type
--
-- @return #lua_type
--
function RecipePrototype.type()
  return lua_type
end

-------------------------------------------------------------------------------
-- Return if recipe void ingredient
-- for flare stack/clarifier ect...
-- @function [parent=#RecipePrototype] isVoid
-- 
-- @return #boolean
--
function RecipePrototype.isVoid()
  if is_voider == nil then RecipePrototype.getProducts() end
  return is_voider
end

-------------------------------------------------------------------------------
-- Return localised name of Prototype
--
-- @function [parent=#RecipePrototype] getLocalisedName
--
-- @return #table
--
function RecipePrototype.getLocalisedName()
  if lua_prototype ~= nil then
    if not(Player.getSettings("display_real_name", true)) then
      return lua_prototype.localised_name
    else
      return lua_prototype.name
    end
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return category of Prototype
--
-- @function [parent=#RecipePrototype] getCategory
--
-- @return #table
--
function RecipePrototype.getCategory()
  if lua_type == "recipe" and lua_prototype ~= nil then
    return lua_prototype.category or "crafting"
  elseif lua_type == "resource" then
    return "extraction-machine"
  elseif lua_type == "fluid" then
    return "chemistry"
  elseif lua_type == "technology" then
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
function RecipePrototype.getProducts()
  local raw_products = RecipePrototype.getRawProducts()
  --Logging:debug(RecipePrototype.classname, "raw_products", raw_products)
  -- if recipe is a voider
  if #raw_products == 1 and Product.getElementAmount(raw_products[1]) == 0 then
    is_voider = true
    return {}
  else
    is_voider = false
  end
  local lua_products = {}
  for r, raw_product in pairs(RecipePrototype.getRawProducts()) do
    local product_id = raw_product.type .. "/" .. raw_product.name
    if lua_products[product_id] ~= nil then
      -- make a new product table for the combined result
      -- combine product amounts, averaging in variable and probabilistic outputs
      local amount_a = Product.getElementAmount(lua_products[product_id])
      local amount_b = Product.getElementAmount(raw_product)
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
function RecipePrototype.getRawProducts()
  if lua_prototype ~= nil then
    if lua_type == "recipe" then
      return lua_prototype.products
    elseif lua_type == "resource" then
      return EntityPrototype.load(lua_prototype).getMineableMiningProducts()
    elseif lua_type == "fluid" then
      return {{name=lua_prototype.name, type="fluid", amount=1}}
    elseif lua_type == "technology" then
      return {{name=lua_prototype.name, type="technology", amount=1}}
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
function RecipePrototype.getIngredientCount(factory)
  local count = 0
  if lua_prototype ~= nil and RecipePrototype.getIngredients(factory) ~= nil then
    for _,lua_ingredient in pairs(RecipePrototype.getIngredients(factory)) do
      if Product.load(lua_ingredient).getType() == "item" then
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
function RecipePrototype.getIngredients(factory)
  Logging:trace(RecipePrototype.classname, "getIngredients()", lua_prototype, lua_type)
  if lua_prototype ~= nil then
    local factory_fuel = "coal"
    if lua_type == "recipe" then
      return lua_prototype.ingredients
    elseif lua_type == "resource" then
      local ingredients = {{name=lua_prototype.name, type="item", amount=1}}
      -- ajouter le liquide obligatoire, s'il y en a
      if EntityPrototype.load(lua_prototype).getMineableMiningFluidRequired() then
        local fluid_ingredient = {name=EntityPrototype.getMineableMiningFluidRequired(), type="fluid", amount=EntityPrototype.getMineableMiningFluidAmount()}
        table.insert(ingredients, fluid_ingredient)
      end
      -- computing burner
      -- @see https://wiki.factorio.com/Fuel
      -- Burn time (s) = Fuel value (MJ) ÷ Energy consumption (MW)
      -- source energy en kJ
      local hardness = EntityPrototype.getMineableHardness()
      local mining_time = EntityPrototype.getMineableMiningTime()
      EntityPrototype.load(factory)
      if factory ~= nil and EntityPrototype.getEnergyType() == "burner" then
        local energy_usage = EntityPrototype.getEnergyUsage()
        local burner_effectivity = EntityPrototype.getBurnerEffectivity()
        local mining_speed = EntityPrototype.getMiningSpeed()
        factory_fuel = factory.fuel or factory_fuel
        local speed_factory = hardness * mining_speed / mining_time
        local fuel_value = energy_usage*speed_factory*12.5
        local burner_count = fuel_value/ItemPrototype.load(factory_fuel).getFuelValue()
        local burner_ingredient = {name=factory_fuel, type="item", amount=burner_count}
        table.insert(ingredients, burner_ingredient)
      end
      return ingredients
    elseif lua_type == "fluid" then
      if lua_prototype.name == "steam" then
        EntityPrototype.load(factory)
        if factory ~= nil and EntityPrototype.getEnergyType() == "burner" then
          factory_fuel = factory.fuel or factory_fuel
          -- source energy en kJ
          local power_extract = EntityPrototype.getPowerExtract()
          local amount = power_extract/(ItemPrototype.load(factory_fuel).getFuelValue()*EntityPrototype.getBurnerEffectivity())
          return {{name="water", type="fluid", amount=1},{name=factory_fuel, type="item", amount=amount}}
        else
          return {{name="water", type="fluid", amount=1}}
        end
      end
      return {{name=lua_prototype.name, type="fluid", amount=1}}
    elseif lua_type == "technology" then
      return lua_prototype.research_unit_ingredients
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
function RecipePrototype.getEnergy()
  if lua_prototype ~= nil then
    if lua_type == "recipe" then
      return lua_prototype.energy
    elseif lua_type == "resource" then
      return 1
    elseif lua_type == "fluid" then
      return 1
    elseif lua_type == "technology" then
      return lua_prototype.research_unit_energy/60
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
function RecipePrototype.getEnabled()
  if lua_prototype ~= nil then
    if lua_type == "recipe" then
      return lua_prototype.enabled
    elseif lua_type == "resource" then
      return true
    elseif lua_type == "fluid" then
      return true
    elseif lua_type == "technology" then
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
function RecipePrototype.getHidden()
  if lua_prototype ~= nil then
    if lua_type == "recipe" then
      return lua_prototype.hidden
    elseif lua_type == "resource" then
      return false
    elseif lua_type == "fluid" then
      return false
    elseif lua_type == "technology" then
      return false
    end
  end
  return false
end

return RecipePrototype
