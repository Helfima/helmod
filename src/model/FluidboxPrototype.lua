require "model.Prototype"
-------------------------------------------------------------------------------
---Class Object
---@Class FluidboxPrototype
FluidboxPrototype = newclass(Prototype)

-------------------------------------------------------------------------------
---Is input
---@return boolean
function FluidboxPrototype:isInput()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.production_type ~= "output"
  end
  return false
end

-------------------------------------------------------------------------------
---Is output
---@return boolean
function FluidboxPrototype:isOutput()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.production_type == "output"
  end
  return false
end

-------------------------------------------------------------------------------
---Return filter
---@return string
function FluidboxPrototype:getFilter()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.filter
  end
  return nil
end

-------------------------------------------------------------------------------
---Return data
---@return table
function FluidboxPrototype:toData()
  local data = {}
  local entity = self.lua_prototype.entity
  if entity == nil then 
    data.entity = "nil"
  else
    data.entity = {name=entity.name, type=entity.type}
  end
  data.index = self.lua_prototype.index
  data.pipe_connections = self.lua_prototype.pipe_connections
  data.production_type = self.lua_prototype.production_type
  data.base_area = self.lua_prototype.base_area
  data.base_level = self.lua_prototype.base_level
  data.height = self.lua_prototype.height
  data.volume = self.lua_prototype.volume
  local filter = self.lua_prototype.filter
  if filter == nil then 
    data.filter = "nil"
  else
    data.filter = {name=filter.name, type="fluid"}
  end
  data.minimum_temperature = self.lua_prototype.minimum_temperature
  data.maximum_temperature = self.lua_prototype.maximum_temperature
  data.secondary_draw_orders = self.lua_prototype.secondary_draw_orders
  data.render_layer = self.lua_prototype.render_layer
  data.valid = self.lua_prototype.valid
  return data
end

-------------------------------------------------------------------------------
---Return string
---@return string
function FluidboxPrototype:toString()
  return game.table_to_json(self:toData())
end