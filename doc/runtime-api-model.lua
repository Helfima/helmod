---@class LuaEvent : EventData
---@field classname string
---@field element LuaGuiElement
---@field action string
---@field item1 string
---@field item2 string
---@field item3 string
---@field item4 string
---@field item5 string
---@field alt boolean
---@field control boolean
---@field shift boolean

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
---@field effects ModuleEffectsData
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

---@class ParametersData
---@field effects ModuleEffectsData

---@class BlockData

---@class ModelData
---@field id string
---@field index_id number
---@field time number
---@field version number
---@field owner string
---@field block_id number
---@field recipe_id number
---@field resource_id number
---@field blocks any
---@field ingredients any
---@field products any
---@field ressources any
---@field summary any
---@field generators any
---@field parameters ParametersData
