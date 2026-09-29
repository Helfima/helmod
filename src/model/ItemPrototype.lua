-------------------------------------------------------------------------------
---@class ItemPrototype
ItemPrototype = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getItemPrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getItemPrototype(object.name))
  end
  if object ~= nil and type(object) == "table" then
    base.quality = object.quality
  end
  base.classname = "HMItemPrototype"
end)

-------------------------------------------------------------------------------
---Return module effect
---@return table
function ItemPrototype:getModuleEffects()
  if self.lua_prototype == nil then return {} end
  local quality = self.quality or "normal"
  return self.lua_prototype.get_module_effects(quality)
end

-------------------------------------------------------------------------------
---Return module effect
---@return number
function ItemPrototype:getIngredientToWeightCoefficient()
  if self.lua_prototype == nil then return 1 end
  return self.lua_prototype.ingredient_to_weight_coefficient or 1
end

-------------------------------------------------------------------------------
---Return module effect
---@return number
function ItemPrototype:geRocketCapacity()
  if self.lua_prototype == nil then return 0 end
  local weight = self:getWeight()
  local capacity = 1000*1000
  local rocket_capacity = capacity / weight
  return rocket_capacity
end

-------------------------------------------------------------------------------
---Return Category
---@return string
function ItemPrototype:getCategory()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.category
end

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
---Return weight
---@return number
function ItemPrototype:getWeight()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.weight or 0
  end
  return 0
end

-------------------------------------------------------------------------------
---Return hidden of Prototype
---@return boolean
function ItemPrototype:getHidden()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.hidden
  end
  return false
end

-------------------------------------------------------------------------------
---Return stack size
---@return number
function ItemPrototype:getSpoilTicks()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.get_spoil_ticks(self.quality)
  end
  return 0
end

-------------------------------------------------------------------------------
---Return spoil result quality
---@return string
function ItemPrototype:getSpoilQuality()
  local quality = Player.getQualityPrototype(self.quality or "normal")
  if self.lua_prototype ~= nil then
    local change = self.lua_prototype.spoil_quality_change
    for _ = 1, math.abs(change) do
      local next_quality
      if change > 0 then
        next_quality = quality.next
      else
        next_quality = quality.previous
      end
      if next_quality == nil then break end
      quality = next_quality
    end
    local minimum = self.lua_prototype.spoil_quality_min
    local maximum = self.lua_prototype.spoil_quality_max
    if minimum ~= nil and quality.level < minimum.level then
      quality = minimum
    end
    if maximum ~= nil and quality.level > maximum.level then
      quality = maximum
    end
  end
  return quality.name
end