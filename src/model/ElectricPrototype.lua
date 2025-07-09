require "model.Prototype"
-------------------------------------------------------------------------------
-- Class Object
--
-- @module ElectricPrototype
--
ElectricPrototype = newclass(Prototype)

function ElectricPrototype:toString()
  local data = {}
  data.emissions = self.lua_prototype.emissions
  data.buffer_capacity = self.lua_prototype.buffer_capacity
  data.usage_priority = self.lua_prototype.usage_priority
  data.input_flow_limit = self.lua_prototype.input_flow_limit
  data.output_flow_limit = self.lua_prototype.output_flow_limit
  data.drain = self.lua_prototype.drain
  data.render_no_network_icon = self.lua_prototype.render_no_network_icon
  data.render_no_power_icon = self.lua_prototype.render_no_power_icon
  data.valid = self.lua_prototype.valid
  return string.format("%s",game.table_to_json(data))
end