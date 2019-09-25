---
-- Description of the module.
-- @module Product
--
Product = newclass(Prototype,function(base, object)
  Prototype.init(base, object)
  base.classname = "HMProduct"
  base.belt_ratio = 45/0.09375
end)

Product.classname = "HMProduct"
-------------------------------------------------------------------------------
-- Return localised name of Prototype
--
-- @function [parent=#Product] getLocalisedName
--
-- @return #table
--
function Product:getLocalisedName()
  Logging:trace(self.classname, "getLocalisedName()", self.lua_prototype)
  if self.lua_prototype ~= nil then
    if not(User.getModGlobalSetting("display_real_name")) then
      local localisedName = self.lua_prototype.name
      if self.lua_prototype.type == 0 or self.lua_prototype.type == "item" then
        local item = Player.getItemPrototype(self.lua_prototype.name)
        if item ~= nil then
          localisedName = item.localised_name
        end
      end
      if self.lua_prototype.type == 1 or self.lua_prototype.type == "fluid" then
        local item = Player.getFluidPrototype(self.lua_prototype.name)
        if item ~= nil then
          localisedName = item.localised_name
        end
      end
      return localisedName
    else
      return self.lua_prototype.name
    end
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Clone prototype model
--
-- @function [parent=#Product] clone
--
-- @return #table
--
function Product:clone()
  local prototype = {
    type = self.lua_prototype.type,
    name = self.lua_prototype.name,
    amount = self:getElementAmount()
  }
  return prototype
end

-------------------------------------------------------------------------------
-- Get amount of element
--
-- @function [parent=#Product] getElementAmount
--
-- @return #number
--
-- @see http://lua-api.factorio.com/latest/Concepts.html#Product
--
function Product:getElementAmount()
  Logging:trace(self.classname, "getElementAmount",self.lua_prototype)
  local element = self.lua_prototype
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
-- Get amount of element for bonus
--
-- @function [parent=#Product] getBonusAmount
--
-- @return #number
--
function Product:getBonusAmount()
  Logging:trace(self.classname, "getBonusAmount",self.lua_prototype)
  local element = self.lua_prototype
  if element == nil then return 0 end

  local catalyst_amount = element.catalyst_amount or 0
  local probability = element.probability or 1
  local amount = 0
  -- If amount not specified, amount_min, amount_max and probability must all be specified.
  -- Minimal amount of the item or fluid to give. Has no effect when amount is specified.
  -- Maximum amount of the item or fluid to give. Has no effect when amount is specified.
  if element.probability ~= nil and element.amount_min ~= nil and  element.amount_max ~= nil then
    amount = (element.amount_min + element.amount_max) / 2
  end

  if element.amount ~= nil then
    amount = element.amount
  end
  Logging:debug(self.classname, "getBonusAmount", amount, catalyst_amount, probability)
  if amount >= catalyst_amount then
    return (amount - catalyst_amount) * probability
  end
  return amount * probability
end

-------------------------------------------------------------------------------
-- Get type of element (item or fluid)
--
-- @function [parent=#Product] getType
--
-- @return #string
--
function Product:getType()
  Logging:trace(self.classname, "getType()",self.lua_prototype)
  if self.lua_prototype.type == 1 or self.lua_prototype.type == "fluid" then return "fluid" end
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
function Product:getAmount(recipe)
  Logging:trace(self.classname, "getAmount(recipe)",self.lua_prototype)
  local amount = self:getElementAmount()
  local bonus_amount = self:getBonusAmount() -- if there are no catalyst amount = bonus_amount
  if recipe == nil then
    return amount
  end
  return amount + bonus_amount * self:getProductivityBonus(recipe)
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
function Product:countProduct(recipe)
  Logging:trace(self.classname, "countProduct",self.lua_prototype)
  local amount = self:getElementAmount()
  local bonus_amount = self:getBonusAmount() -- if there are no catalyst amount = bonus_amount
  return (amount + bonus_amount * self:getProductivityBonus(recipe) ) * recipe.count
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
function Product:countIngredient(recipe)
  Logging:trace(self.classname, "countIngredient",self.lua_prototype)
  local amount = self:getElementAmount()
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
function Product:countContainer(count, container)
  Logging:trace(self.classname, "countContainer",self.lua_prototype)
  if count == nil then return 0 end
  if self.lua_prototype.type == 0 or self.lua_prototype.type == "item" then
    local entity_prototype = EntityPrototype(container)
    local cargo_wagon_size = entity_prototype:getInventorySize(1)
    if entity_prototype:getType() == "transport-belt" then
      -- ratio = item_per_s / speed_belt (blue belt)
      local belt_speed = entity_prototype:getBeltSpeed()
      return count / (belt_speed * self.belt_ratio * (Model.getModel().time or 1))
    elseif entity_prototype:getType() ~= "logistic-robot" then
      if entity_prototype:getInventorySize(2) ~= nil and entity_prototype:getInventorySize(2) > entity_prototype:getInventorySize(1) then
        cargo_wagon_size = entity_prototype:getInventorySize(2)
      end
      local stack_size = ItemPrototype(self.lua_prototype.name):stackSize()
      if cargo_wagon_size * stack_size == 0 then return 0 end
      return count / (cargo_wagon_size * stack_size)
    else
      cargo_wagon_size = entity_prototype:native().max_payload_size + (Player.getForce().worker_robots_storage_bonus or 0 )
      return count / cargo_wagon_size
    end
  end
  if self.lua_prototype.type == 1 or self.lua_prototype.type == "fluid" then
    local cargo_wagon_size = EntityPrototype(container):getFluidCapacity()
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
function Product:getProductivityBonus(recipe)
  Logging:trace(self.classname, "getProductivityBonus(recipe)", self.lua_prototype)
  if recipe.isluaobject or recipe.factory == nil or recipe.factory.effects == nil then return 1 end
  local productivity = recipe.factory.effects.productivity
  
  return productivity
end
