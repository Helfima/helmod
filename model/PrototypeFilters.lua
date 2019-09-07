require "model.PrototypeFilter"
---
-- Description of the module.
-- @module PrototypeFilters
--
local PrototypeFilters = {
  classname = "HMPrototypeFilters"
}

local prototype_filters = {}
-------------------------------------------------------------------------------
-- Get types
--
-- @function [parent=#PrototypeFilter] getTypes
--
-- @return #table
--
function PrototypeFilters.getTypes()
  local types = {}
  for type,_ in pairs(prototype_filters) do
    table.insert(types, type)
  end
  return types
end

-------------------------------------------------------------------------------
-- Get modes
--
-- @function [parent=#PrototypeFilter] getModes
--
-- @return #table
--
function PrototypeFilters.getModes()
  local modes = {"or","and"}
  return modes
end

-------------------------------------------------------------------------------
-- Get inverts
--
-- @function [parent=#PrototypeFilter] getInverts
--
-- @return #table
--
function PrototypeFilters.getInverts()
  local modes = {"false","true"}
  return modes
end

-------------------------------------------------------------------------------
-- Add filter type
--
-- @function [parent=#PrototypeFilter] addFilterType
--
-- @param #string filter
--
-- @return PrototypeFilter
--
function PrototypeFilters.addFilterType(filter)
  prototype_filters[filter] = PrototypeFilter(filter)
  return prototype_filters[filter]
end

-------------------------------------------------------------------------------
-- Get filter type
--
-- @function [parent=#PrototypeFilter] getFilterType
--
-- @param #string filter_type
--
-- @return PrototypeFilter
--
function PrototypeFilters.getFilterType(filter_type)
  return prototype_filters[filter_type]
end

-------------------------------------------------------------------------------
-- initialization
--
-- @function [parent=#PrototypeFilter] initialization
--
function PrototypeFilters.initialization()

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterEntity = PrototypeFilters.addFilterType("entity")
  PrototypeFilterEntity:addMapping({["collision-mask"]="mask"})
  PrototypeFilterEntity:setGameFunction("get_filtered_entity_prototypes")

  PrototypeFilterEntity:addFilter("type", Player.getEntityPrototypeTypes())
  PrototypeFilterEntity:addFilter("flying-robot")
  PrototypeFilterEntity:addFilter("robot-with-logistics-interface")
  PrototypeFilterEntity:addFilter("rail")
  PrototypeFilterEntity:addFilter("particle")
  PrototypeFilterEntity:addFilter("ghost")
  PrototypeFilterEntity:addFilter("explosion")
  PrototypeFilterEntity:addFilter("vehicle")
  PrototypeFilterEntity:addFilter("crafting-machine")
  PrototypeFilterEntity:addFilter("rolling-stock")
  PrototypeFilterEntity:addFilter("turret")
  PrototypeFilterEntity:addFilter("transport-belt-connectable")
  PrototypeFilterEntity:addFilter("wall-connectable")
  PrototypeFilterEntity:addFilter("buildable")
  PrototypeFilterEntity:addFilter("placable-in-editor")
  PrototypeFilterEntity:addFilter("clonable")
  PrototypeFilterEntity:addFilter("selectable")
  PrototypeFilterEntity:addFilter("hidden")
  PrototypeFilterEntity:addFilter("entity-with-health")
  PrototypeFilterEntity:addFilter("building")
  PrototypeFilterEntity:addFilter("fast-replaceable")
  PrototypeFilterEntity:addFilter("uses-direction")
  PrototypeFilterEntity:addFilter("minable")
  PrototypeFilterEntity:addFilter("circuit-connectable")
  PrototypeFilterEntity:addFilter("autoplace")
  PrototypeFilterEntity:addFilter("blueprintable")
  local collision_mask = {}
  collision_mask["ground-tile"]=true
  collision_mask["water-tile"]=true
  collision_mask["resource-layer"]=true
  collision_mask["doodad-layer"]=true
  collision_mask["floor-layer"]=true
  collision_mask["item-layer"]=true
  collision_mask["ghost-layer"]=true
  collision_mask["object-layer"]=true
  collision_mask["player-layer"]=true
  collision_mask["train-layer"]=true
  collision_mask["layer-11"]=true
  collision_mask["layer-12"]=true
  collision_mask["layer-13"]=true
  collision_mask["layer-14"]=true
  collision_mask["layer-15"]=true
  collision_mask["not-setup"]=true
  PrototypeFilterEntity:addFilter("collision-mask", collision_mask)
  local entity_flag={}
  entity_flag["not-rotatable"]=true
  entity_flag["placeable-neutral"]=true
  entity_flag["placeable-player"]=true
  entity_flag["placeable-enemy"]=true
  entity_flag["placeable-off-grid"]=true
  entity_flag["player-creation"]=true
  entity_flag["building-direction-8-way"]=true
  entity_flag["filter-directions"]=true
  entity_flag["fast-replaceable-no-build-while-moving"]=true
  entity_flag["breaths-air"]=true
  entity_flag["not-repairable"]=true
  entity_flag["not-on-map"]=true
  entity_flag["not-deconstructable"]=true
  entity_flag["not-blueprintable"]=true
  entity_flag["hide-from-bonus-gui"]=true
  entity_flag["hide-alt-info"]=true
  entity_flag["fast-replaceable-no-cross-type-while-moving"]=true
  entity_flag["no-gap-fill-while-building"]=true
  entity_flag["not-flammable"]=true
  entity_flag["no-automated-item-removal"]=true
  entity_flag["no-automated-item-insertion"]=true
  entity_flag["no-copy-paste"]=true
  entity_flag["not-selectable-in-game"]=true
  entity_flag["not-upgradable"]=true
  PrototypeFilterEntity:addFilter("flag", entity_flag)

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterItem = PrototypeFilters.addFilterType("item")
  PrototypeFilterItem:addMapping(nil)
  PrototypeFilterItem:setGameFunction("get_filtered_item_prototypes")
  PrototypeFilterItem:addFilter("type", Player.getItemPrototypeTypes())
  PrototypeFilterItem:addFilter("tool")
  PrototypeFilterItem:addFilter("mergeable")
  PrototypeFilterItem:addFilter("item-with-inventory")
  PrototypeFilterItem:addFilter("selection-tool")
  PrototypeFilterItem:addFilter("item-with-label")
  PrototypeFilterItem:addFilter("fuel")
  PrototypeFilterItem:addFilter("place-as-tile")
  PrototypeFilterItem:addFilter("place-result")
  PrototypeFilterItem:addFilter("placed-as-equipment-result")
  PrototypeFilterItem:addFilter("burnt-result")

  local item_flag = {}
  item_flag["hidden"] = true
  item_flag["hide-from-bonus-gui"] = true
  item_flag["hide-from-fuel-tooltip"] = true
  item_flag["not-stackable"] = true
  item_flag["can-extend-inventory"] = true
  item_flag["primary-place-result"] = true
  item_flag["mod-openable"] = true
  item_flag["only-in-cursor"] = true
  PrototypeFilterItem:addFilter("flag", item_flag)
  PrototypeFilterItem:addFilter("subgroup", game.item_subgroup_prototypes)
  PrototypeFilterItem:addFilter("fuel-category", game.fuel_category_prototypes)

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterEquipement = PrototypeFilters.addFilterType("equipment")
  PrototypeFilterEquipement:addMapping(nil)
  PrototypeFilterEquipement:setGameFunction("get_filtered_equipment_prototypes")
  PrototypeFilterEquipement:addFilter("type")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterEquipement = PrototypeFilters.addFilterType("mod")
  PrototypeFilterEquipement:addMapping({["setting-type"]="type"})
  PrototypeFilterEquipement:setGameFunction("get_filtered_mod_setting_prototypes")
  PrototypeFilterEquipement:addFilter("type")
  PrototypeFilterEquipement:addFilter("mod")
  local setting_type = {}
  setting_type["startup"] = true
  setting_type["runtime-global"] = true
  setting_type["runtime-per-user"] = true
  PrototypeFilterEquipement:addFilter("setting-type", setting_type)

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterAchievement = PrototypeFilters.addFilterType("achievement")
  PrototypeFilterAchievement:addMapping(nil)
  PrototypeFilterAchievement:setGameFunction("get_filtered_achievement_prototypes")
  PrototypeFilterAchievement:addFilter("type")
  PrototypeFilterAchievement:addFilter("allowed-without-fight")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterRecipe = PrototypeFilters.addFilterType("recipe")
  PrototypeFilterRecipe:addMapping(nil)
  PrototypeFilterRecipe:setGameFunction("get_filtered_recipe_prototypes")
  PrototypeFilterRecipe:addFilter("enabled")
  PrototypeFilterRecipe:addFilter("hidden")
  PrototypeFilterRecipe:addFilter("hidden-from-flow-stats")
  PrototypeFilterRecipe:addFilter("hidden-from-player-crafting")
  PrototypeFilterRecipe:addFilter("allow-as-intermediate")
  PrototypeFilterRecipe:addFilter("allow-intermediates")
  PrototypeFilterRecipe:addFilter("allow-decomposition")
  PrototypeFilterRecipe:addFilter("always-show-made-in")
  PrototypeFilterRecipe:addFilter("always-show-products")
  PrototypeFilterRecipe:addFilter("show-amount-in-title")
  PrototypeFilterRecipe:addFilter("has-ingredients")
  PrototypeFilterRecipe:addFilter("has-products")
  PrototypeFilterRecipe:addFilter("subgroup")
  PrototypeFilterRecipe:addFilter("category", game.recipe_category_prototypes)
  PrototypeFilterRecipe:addFilter("energy")
  PrototypeFilterRecipe:addFilter("emissions-multiplier")
  PrototypeFilterRecipe:addFilter("request-paste-multiplier")
  PrototypeFilterRecipe:addFilter("overload-multiplier")
end

return PrototypeFilters
