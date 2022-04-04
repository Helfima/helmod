-------------------------------------------------------------------------------
---Description of the module.
---@class FluidPrototype
FluidPrototype = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getFluidPrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getFluidPrototype(object.name))
  end
  base.classname = "HMFluidPrototype"
end)

-------------------------------------------------------------------------------
---Return fuel value
---@return number
function FluidPrototype:getHeatCapacity()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.heat_capacity
end

-------------------------------------------------------------------------------
---Return fuel value
---@return number
function FluidPrototype:getEmissionMultiplier()
  if self.lua_prototype == nil then return 1 end
  return self.lua_prototype.emissions_multiplier or 1
end

-------------------------------------------------------------------------------
---Return fuel value
---@return number
function FluidPrototype:getFuelValue()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.fuel_value
end

-------------------------------------------------------------------------------
---Return fuel emissions multiplier
---@return number
function FluidPrototype:getFuelEmissionsMultiplier()
  if self.lua_prototype == nil then return 1 end
  return self.lua_prototype.emissions_multiplier or 1
end

-------------------------------------------------------------------------------
---Return temperature
---@return number
function FluidPrototype:getTemperature()
  return self.temperature
end

-------------------------------------------------------------------------------
---Return fluid temperature
---@return number or nil
function FluidPrototype:setTemperature(value)
  self.temperature = value
end

-------------------------------------------------------------------------------
---Return minimum temperature
---@return number
function FluidPrototype:getMinimumTemperature()
  if self.lua_prototype == nil then return 15 end
  return self.lua_prototype.default_temperature
end
