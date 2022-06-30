-------------------------------------------------------------------------------
---@class ItemPrototype
ItemPrototype = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getItemPrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getItemPrototype(object.name))
  end
  base.classname = "HMItemPrototype"
end)

-------------------------------------------------------------------------------
---Return fuel value
---@return number
function ItemPrototype:getFuelValue()
  if self.lua_prototype == nil then return 0 end
  return self.lua_prototype.fuel_value
end

-------------------------------------------------------------------------------
---Return burnt result
---@return number
function ItemPrototype:getBurntResult()
  if self.lua_prototype == nil then return nil end
  if self:getFuelValue() > 0 then return self.lua_prototype.burnt_result end
  return nil
end

-------------------------------------------------------------------------------
---Return fuel emissions multiplier
---@return number
function ItemPrototype:getFuelEmissionsMultiplier()
  if self.lua_prototype == nil then return 1 end
  return self.lua_prototype.fuel_emissions_multiplier or 1
end

-------------------------------------------------------------------------------
---Return stack size
---@return number
function ItemPrototype:stackSize()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.stack_size or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return hidden of Prototype
---@return boolean
function ItemPrototype:getHidden()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.has_flag("hidden")
  end
  return false
end
