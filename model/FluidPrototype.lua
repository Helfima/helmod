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
