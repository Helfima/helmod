require "model.Prototype"
-------------------------------------------------------------------------------
-- Class Object
--
-- @module EnergyPrototype
--
EnergyPrototype = newclass(Prototype)

-------------------------------------------------------------------------------
-- Return products array of Prototype
--
-- @function [parent=#EnergyPrototype] getProducts
--
-- @return #table
--
function EnergyPrototype:getProducts()
  local products = {}
  if self.lua_prototype ~= nil then
    local prototype = EntityPrototype(self.lua_prototype.name)
    if prototype:getType() == EntityType.solar_panel then
      local product = {name="energy", type="energy", amount=1}
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
              local product = {name=filter.name, type="fluid", amount=1}
              table.insert(products, product)
            end
          end
        end
      end
    end
    if prototype:getType() == EntityType.accumulator then
      local product = {name="energy", type="energy", amount=1}
      table.insert(products, product)
    end
    if prototype:getType() == EntityType.generator then
      local product = {name="energy", type="energy", amount=1}
      table.insert(products, product)
    end
  end
  return products
end

-------------------------------------------------------------------------------
-- Return ingredients array of Prototype
--
-- @function [parent=#EnergyPrototype] getIngredients
--
-- @return #table
--
function EnergyPrototype:getIngredients()
  local ingredients = {}
  if self.lua_prototype ~= nil then
    local prototype = EntityPrototype(self.lua_prototype.name)
    if prototype:getType() == EntityType.solar_panel then
      local ingredient = {name="energy", type="energy", amount=1}
      table.insert(ingredients, ingredient)
    end
    if prototype:getType() == EntityType.boiler then
      local fluidboxes = prototype:getFluidboxPrototypes()
      if fluidboxes ~= nil then
        for _,fluidbox in pairs(fluidboxes) do
          local fluidbox_prototype = FluidboxPrototype(fluidbox)
          if fluidbox_prototype:native() ~= nil and fluidbox_prototype:isInput() then
            local filter = fluidbox_prototype:native().filter
            if filter ~= nil then
              local ingredient = {name=filter.name, type="fluid", amount=1, temperature=prototype:getTargetTemperature()}
              table.insert(ingredients, ingredient)
            end
          end
        end
      end
    end
    if prototype:getType() == EntityType.accumulator then
      local ingredient = {name="energy", type="energy", amount=1}
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
              local ingredient = {name=filter.name, type="fluid", amount=1, temperature=prototype:getTargetTemperature()}
              table.insert(ingredients, ingredient)
            end
          end
        end
      end
    end
  end
  return ingredients
end