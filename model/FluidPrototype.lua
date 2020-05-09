---
-- Description of the module.
-- @module FluidPrototype
-- 

FluidPrototype = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getFluidPrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getFluidPrototype(object.name))
  end
  base.classname = "HMFluidPrototype"
end)

-------------------------------------------------------------------------------
-- Return fuel value
--
-- @function [parent=#FluidPrototype] getFuelValue
--
-- @return #boolean
--
function FluidPrototype:getHeatCapacity()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.heat_capacity
end

-------------------------------------------------------------------------------
-- Return fuel value
--
-- @function [parent=#FluidPrototype] getFuelValue
--
-- @return #number
--
function FluidPrototype:getEmissionMultiplier()
  if self.lua_prototype == nil then return 1 end
  return self.lua_prototype.emissions_multiplier or 1
end

-------------------------------------------------------------------------------
-- Return fuel value
--
-- @function [parent=#FluidPrototype] getFuelValue
--
-- @return #boolean
--
function FluidPrototype:getFuelValue()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.fuel_value
end

-------------------------------------------------------------------------------
-- Return fuel emissions multiplier
--
-- @function [parent=#FluidPrototype] getFuelEmissionsMultiplier
--
-- @return #boolean
--
function FluidPrototype:getFuelEmissionsMultiplier()
  if self.lua_prototype == nil then return 1 end
  return self.lua_prototype.emissions_multiplier or 1
end

