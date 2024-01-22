---@class ModulePriorityData
---@field name string
---@field value uint

---@class FuelData
---@field name string
---@field temperature number

---@class ModuleEffectsData
---@field speed number
---@field productivity number
---@field consumption number
---@field pollution number


---@class FactoryData
---@field name string
---@field type string
---@field count number
---@field energy number
---@field speed number
---@field fuel string | FuelData
---@field limit number
---Dictionnary {[module.name] : int}
---@field modules {[string] : uint}
---@field effects ModuleEffects
---@field cap ModuleEffects
---@field energy_total number
---@field polution_total number
---@field speed_total number
---@field module_priority {[uint] : ModulePriorityData}

---@class BeaconData : FactoryData
---@field combo number
---@field per_factory number
---@field per_factory_constant number

---@class RecipeData
---@field id string
---@field index uint
---@field name string
---@field type string
---@field count number
---@field production number
---@field factory FactoryData
---@field beacons {[uint] : BeaconData}
---@field time uint
---@field energy_total number
---@field polution_total number
---@field is_done boolean
---@field base_time uint
