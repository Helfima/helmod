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
  if self.lua_prototype ~= nil then
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
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return table key
--
-- @function [parent=#Product] getTableKey
--
-- @return #table
--
function Product:getTableKey()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.type == 1 or self.lua_prototype.type == "fluid" then
      local T = self.lua_prototype.temperature
      if T ~= nil then
        return string.format("%s#%s", self.lua_prototype.name,T)
      end
      local Tmin = self.lua_prototype.minimum_temperature 
      local Tmax = self.lua_prototype.maximum_temperature
      if Tmin ~= nil or Tmax ~= nil then
        Tmin = Tmin or -1e300
        Tmax = Tmax or 1e300
        if Tmin < -1e300 and Tmax < 1e300 then
          return string.format("%s#inf#%s", self.lua_prototype.name, Tmax)
        end
        if Tmin > -1e300 and Tmax > 1e300 then
          return string.format("%s#%s#inf", self.lua_prototype.name, Tmin)
        end
        if Tmin > -1e300 and Tmax < 1e300 then
          return string.format("%s#%s#%s", self.lua_prototype.name, Tmin, Tmax)
        end
      end
    end
    return self.lua_prototype.name
  end
  return "unknow"
end

-------------------------------------------------------------------------------
-- Return localised name of Prototype
--
-- @function [parent=#Product] getLocalisedName
--
-- @return #table
--
function Product:hasBurntResult()
  if self.lua_prototype ~= nil then
    if self.lua_prototype.type == 0 or self.lua_prototype.type == "item" then
      local item = Player.getItemPrototype(self.lua_prototype.name)
      return item.burnt_result ~= nil
    end
  end
  return false
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
    amount = self:getElementAmount(),
    state = self.lua_prototype.state,
    temperature = self.lua_prototype.temperature,
    minimum_temperature  = self.lua_prototype.minimum_temperature,
    maximum_temperature  = self.lua_prototype.maximum_temperature,
    by_time = self.lua_prototype.by_time,
    burnt = self.lua_prototype.burnt,
    constant = self.lua_prototype.constant
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
  local amount = self:getElementAmount()
  local bonus_amount = self:getBonusAmount() -- if there are no catalyst amount = bonus_amount
  if recipe == nil then
    return amount
  end
  return amount + bonus_amount * self:getProductivityBonus(recipe)
end

-------------------------------------------------------------------------------
-- Factor by time
--
-- @function [parent=#Product] factorByTime
--
-- @param #table recipe
--
-- @return #number
--
function Product:factorByTime(model)
  if self.lua_prototype.by_time == true then
    return model.time
  end
  return 1
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
function Product:countProduct(model, recipe)
  local amount = self:getElementAmount()
  local bonus_amount = self:getBonusAmount() -- if there are no catalyst amount = bonus_amount
  return (amount + bonus_amount * self:getProductivityBonus(recipe) ) * recipe.count * self:factorByTime(model)
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
function Product:countIngredient(model, recipe)
  local amount = self:getElementAmount() * self:factorByTime(model)
  return amount * recipe.count
end

-------------------------------------------------------------------------------
-- Count container
--
-- @function [parent=#Product] countContainer
--
--- @param count number
--- @param container string
--
--- @return number
--
function Product:countContainer(count, container, time)
  if count == nil then return 0 end
  if self.lua_prototype.type == 0 or self.lua_prototype.type == "item" then
    local entity_prototype = EntityPrototype(container)
    if entity_prototype:getType() == "inserter" then
      local inserter_capacity = entity_prototype:getInserterCapacity()
      local inserter_speed = entity_prototype:getInserterRotationSpeed()
      -- temps pour 360� t=360/360*inserter_speed
      local inserter_time = 1 / inserter_speed
      return count * inserter_time / (inserter_capacity * (time or 1))
    elseif entity_prototype:getType() == "transport-belt" then
      -- ratio = item_per_s / speed_belt (blue belt)
      local belt_speed = entity_prototype:getBeltSpeed()
      return count / (belt_speed * self.belt_ratio * (time or 1))
    elseif entity_prototype:getType() ~= "logistic-robot" then
      local cargo_wagon_size = entity_prototype:getInventorySize(1)
      if cargo_wagon_size == nil then return 0 end
      if entity_prototype:getInventorySize(2) ~= nil and entity_prototype:getInventorySize(2) > entity_prototype:getInventorySize(1) then
        cargo_wagon_size = entity_prototype:getInventorySize(2)
      end
      local stack_size = ItemPrototype(self.lua_prototype.name):stackSize()
      if cargo_wagon_size * stack_size == 0 then return 0 end
      return count / (cargo_wagon_size * stack_size)
    else
      local cargo_wagon_size = entity_prototype:native().max_payload_size + (Player.getForce().worker_robots_storage_bonus or 0 )
      return count / cargo_wagon_size
    end
  end
  if self.lua_prototype.type == 1 or self.lua_prototype.type == "fluid" then
    local entity_prototype = EntityPrototype(container)
    if entity_prototype:getType() == "pipe" then
      local fluids_logistic_maximum_flow = User.getParameter("fluids_logistic_maximum_flow")
      return count / (fluids_logistic_maximum_flow or helmod_logistic_flow_default)
    else
      local cargo_wagon_size = EntityPrototype(container):getFluidCapacity()
      if cargo_wagon_size == 0 then return 0 end
      return count / cargo_wagon_size
    end
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
  if recipe.isluaobject or recipe.factory == nil or recipe.factory.effects == nil then return 1 end
  local productivity = recipe.factory.effects.productivity

  return productivity
end
