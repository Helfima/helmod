---
-- Description of the module.
-- @module Product
--
local Product = {
  -- single-line comment
  classname = "HMProduct",
  -- speed in game/speed data for blue belt
  belt_ratio = 45/0.09375
}

local lua_product = nil

-------------------------------------------------------------------------------
-- Load factorio Product
--
-- @function [parent=#Product] load
--
-- @param #object object
--
-- @return #Product
--
function Product.load(object)
  lua_product = object
  return Product
end

-------------------------------------------------------------------------------
-- Return localised name of Prototype
--
-- @function [parent=#Product] getLocalisedName
--
-- @return #table
--
function Product.getLocalisedName()
  Logging:trace(Product.classname, "getLocalisedName()", lua_product)
  if lua_product ~= nil then
    if not(Player.getSettings("display_real_name", true)) then
      local localisedName = lua_product.name
      if lua_product.type == 0 or lua_product.type == "item" then
        local item = Player.getItemPrototype(lua_product.name)
        if item ~= nil then
          localisedName = item.localised_name
        end
      end
      if lua_product.type == 1 or lua_product.type == "fluid" then
        local item = Player.getFluidPrototype(lua_product.name)
        if item ~= nil then
          localisedName = item.localised_name
        end
      end
      return localisedName
    else
      return lua_product.name
    end
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- new prototype model
--
-- @function [parent=#Product] new
--
-- @return #table
--
function Product.new()
  local prototype = {
    type = lua_product.type,
    name = lua_product.name,
    amount = Product.getElementAmount(lua_product)
  }
  return prototype
end

-------------------------------------------------------------------------------
-- Return factorio Product
--
-- @function [parent=#Product] native
--
-- @return #lua_product
--
function Product.native()
  return lua_product
end

-------------------------------------------------------------------------------
-- Get amount of element
--
-- @function [parent=#Product] getElementAmount
--
-- @param #table element
--
-- @return #number
--
-- @see http://lua-api.factorio.com/latest/Concepts.html#Product
--
function Product.getElementAmount(element)
  Logging:trace(Product.classname, "getElementAmount",element)
  if element == nil then return 0 end

  if element.amount ~= nil then
    -- In 0.17, it seems probability can be used with just 'amount' and it
    -- doesn't need to use amount_min/amount_max
    if element.probability ~= nil then
      return element.amount * element.probability
    else
      return element.amount
    end
  end

  if element.probability ~= nil and element.amount_min ~= nil and  element.amount_max ~= nil then
    return ((element.amount_min + element.amount_max) * element.probability / 2)
  end

  return 0
end

-------------------------------------------------------------------------------
-- Get type of element (item or fluid)
--
-- @function [parent=#Product] getType
--
-- @return #string
--
function Product.getType()
  Logging:trace(Product.classname, "getType()",lua_product)
  if lua_product.type == 1 or lua_product.type == "fluid" then return "fluid" end
  return "item"
end

-------------------------------------------------------------------------------
-- Get amount of element
--
-- @function [parent=#Product] getAmount
--
-- @param #table recipe
--
-- @return #number
--
function Product.getAmount(recipe)
  Logging:trace(Product.classname, "getAmount(recipe)",lua_product)
  local amount = Product.getElementAmount(lua_product)
  if recipe == nil then
    return amount
  end
  return amount + amount * Product.getProductivityBonus(recipe)
end

-------------------------------------------------------------------------------
-- Count product
--
-- @function [parent=#Product] countProduct
--
-- @param #table recipe
--
-- @return #number
--
function Product.countProduct(recipe)
  Logging:trace(Product.classname, "countProduct",lua_product)
  local amount = Product.getElementAmount(lua_product)
  return (amount + amount * Product.getProductivityBonus(recipe) ) * recipe.count
end

-------------------------------------------------------------------------------
-- Count ingredient
--
-- @function [parent=#Product] countIngredient
--
-- @param #table recipe
--
-- @return #number
--
function Product.countIngredient(recipe)
  Logging:trace(Product.classname, "countIngredient",lua_product)
  local amount = Product.getElementAmount(lua_product)
  return amount * recipe.count
end

-------------------------------------------------------------------------------
-- Count container
--
-- @function [parent=#Product] countContainer
--
-- @param #number count
-- @param #string container name
--
-- @return #number
--
function Product.countContainer(count, container)
  Logging:trace(Product.classname, "countContainer",lua_product)
  if lua_product.type == 0 or lua_product.type == "item" then
    EntityPrototype.load(container)
    local cargo_wagon_size = EntityPrototype.getInventorySize(1)
    if EntityPrototype.getType() == "transport-belt" then
      -- ratio = item_per_s / speed_belt (blue belt)
      local belt_speed = EntityPrototype.getBeltSpeed()
      return count / (belt_speed * Product.belt_ratio * (Model.getModel().time or 1))
    elseif EntityPrototype.getType() ~= "logistic-robot" then
      if EntityPrototype.getInventorySize(2) ~= nil and EntityPrototype.getInventorySize(2) > EntityPrototype.getInventorySize(1) then
        cargo_wagon_size = EntityPrototype.getInventorySize(2)
      end
      local stack_size = ItemPrototype.load(lua_product.name).stackSize()
      if cargo_wagon_size * stack_size == 0 then return 0 end
      return count / (cargo_wagon_size * stack_size)
    else
      cargo_wagon_size = EntityPrototype.native().max_payload_size + (Player.getForce().worker_robots_storage_bonus or 0 )
      return count / cargo_wagon_size
    end
  end
  if lua_product.type == 1 or lua_product.type == "fluid" then
    local cargo_wagon_size = EntityPrototype.load(container).getFluidCapacity()
    if cargo_wagon_size == 0 then return 0 end
    return count / cargo_wagon_size
  end
end

-------------------------------------------------------------------------------
-- Get the productivity bonus of the recipe
--
-- @function [parent=#Product] getProductivityBonus
--
-- @param #table recipe
--
-- @return #number
--
function Product.getProductivityBonus(recipe)
  Logging:trace(Product.classname, "getProductivityBonus(recipe)", lua_product)
  if recipe.isluaobject or recipe.factory == nil or recipe.factory.effects == nil then return 1 end
  local productivity = recipe.factory.effects.productivity
  if recipe.type == "resource" then
    productivity = productivity + Player.getForce().mining_drill_productivity_bonus
  end
  return productivity
end

return Product
