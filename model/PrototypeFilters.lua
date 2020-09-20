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
-- Get comparison
--
-- @function [parent=#PrototypeFilter] getComparison
--
-- @return #table
--
function PrototypeFilters.getComparison()
  local modes = {"<", ">", "=", "≥", "≤", "≠"}
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
-- Get Collision Mask
--
-- @function [parent=#PrototypeFilter] getCollisionMask
--
-- @return #table
--
function PrototypeFilters.getCollisionMask()
  local collision_mask = {}
  table.insert(collision_mask, "ground-tile")
  table.insert(collision_mask, "water-tile")
  table.insert(collision_mask, "resource-layer")
  table.insert(collision_mask, "doodad-layer")
  table.insert(collision_mask, "floor-layer")
  table.insert(collision_mask, "item-layer")
  table.insert(collision_mask, "ghost-layer")
  table.insert(collision_mask, "object-layer")
  table.insert(collision_mask, "player-layer")
  table.insert(collision_mask, "train-layer")
  table.insert(collision_mask, "layer-11")
  table.insert(collision_mask, "layer-12")
  table.insert(collision_mask, "layer-13")
  table.insert(collision_mask, "layer-14")
  table.insert(collision_mask, "layer-15")
  table.insert(collision_mask, "not-setup")
  table.insert(collision_mask, "not-colliding-with-itself")
  table.insert(collision_mask, "consider-tile-transitions")
  table.insert(collision_mask, "colliding-with-tiles-only")
  return collision_mask
end

-------------------------------------------------------------------------------
-- Get Collision Mask Mode
--
-- @function [parent=#PrototypeFilter] getCollisionMaskMode
--
-- @return #table
--
function PrototypeFilters.getCollisionMaskMode()
  local collision_mask_mode = {}
  table.insert(collision_mask_mode, "collides")
  table.insert(collision_mask_mode, "layers-equals")
  return collision_mask_mode
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
  PrototypeFilterEntity:addMapping({["crafting-category"]="crafting_category"})

  PrototypeFilterEntity:addFilter("type", Player.getEntityPrototypeTypes())
  PrototypeFilterEntity:addFilter("name")
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
  PrototypeFilterEntity:addFilter("item-to-place")
  PrototypeFilterEntity:addFilter("collision-mask")
  
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
  PrototypeFilterEntity:addFilter("build-base-evolution-requirement", "comparison")
  PrototypeFilterEntity:addFilter("selection-priority", "comparison")
  PrototypeFilterEntity:addFilter("emissions", "comparison")
  PrototypeFilterEntity:addFilter("crafting-category", game.recipe_category_prototypes)

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterItem = PrototypeFilters.addFilterType("item")
  PrototypeFilterItem:addMapping(nil)
  PrototypeFilterItem:addFilter("type", Player.getItemPrototypeTypes())
  PrototypeFilterItem:addFilter("name")
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
  PrototypeFilterItem:addFilter("show-in-blueprint-library")

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
  PrototypeFilterItem:addFilter("stack-size", "comparison")
  PrototypeFilterItem:addFilter("default-request-amount", "comparison")
  PrototypeFilterItem:addFilter("wire-count", "comparison")
  PrototypeFilterItem:addFilter("fuel-value", "comparison")
  PrototypeFilterItem:addFilter("fuel-acceleration-multiplier", "comparison")
  PrototypeFilterItem:addFilter("fuel-top-speed-multiplier", "comparison")
  PrototypeFilterItem:addFilter("fuel-emissions-multiplier", "comparison")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterEquipement = PrototypeFilters.addFilterType("equipment")
  PrototypeFilterEquipement:addMapping(nil)
  PrototypeFilterEquipement:addFilter("type")
  PrototypeFilterEquipement:addFilter("item-to-place")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterModSetting = PrototypeFilters.addFilterType("mod")
  PrototypeFilterModSetting:addMapping({["setting-type"]="type"})
  PrototypeFilterModSetting:addFilter("type")
  PrototypeFilterModSetting:addFilter("mod")
  local setting_type = {}
  setting_type["startup"] = true
  setting_type["runtime-global"] = true
  setting_type["runtime-per-user"] = true
  PrototypeFilterModSetting:addFilter("setting-type", setting_type)

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterAchievement = PrototypeFilters.addFilterType("achievement")
  PrototypeFilterAchievement:addMapping(nil)
  PrototypeFilterAchievement:addFilter("type")
  PrototypeFilterAchievement:addFilter("allowed-without-fight")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterTile = PrototypeFilters.addFilterType("tile")
  PrototypeFilterTile:addMapping(nil)
  PrototypeFilterTile:addFilter("minable")
  PrototypeFilterTile:addFilter("autoplace")
  PrototypeFilterTile:addFilter("blueprintable")
  PrototypeFilterTile:addFilter("item-to-place")
  PrototypeFilterTile:addFilter("collision-mask")
  PrototypeFilterTile:addFilter("walking-speed-modifier", "comparison")
  PrototypeFilterTile:addFilter("vehicle-friction-modifier", "comparison")
  PrototypeFilterTile:addFilter("decorative-removal-probability", "comparison")
  PrototypeFilterTile:addFilter("emissions", "comparison")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterDecorative = PrototypeFilters.addFilterType("decorative")
  PrototypeFilterDecorative:addMapping(nil)
  PrototypeFilterDecorative:addFilter("decal")
  PrototypeFilterDecorative:addFilter("autoplace")
  PrototypeFilterDecorative:addFilter("collision-mask")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterFluid = PrototypeFilters.addFilterType("fluid")
  PrototypeFilterFluid:addMapping(nil)
  PrototypeFilterFluid:addFilter("name")
  PrototypeFilterFluid:addFilter("hidden")
  PrototypeFilterFluid:addFilter("subgroup", Player.getFluidPrototypeSubgroups())
  PrototypeFilterFluid:addFilter("default-temperature", "comparison")
  PrototypeFilterFluid:addFilter("max-temperature", "comparison")
  PrototypeFilterFluid:addFilter("heat-capacity", "comparison")
  PrototypeFilterFluid:addFilter("fuel-value", "comparison")
  PrototypeFilterFluid:addFilter("emissions-multiplier", "comparison")
  PrototypeFilterFluid:addFilter("gas-temperature", "comparison")

  -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterRecipe = PrototypeFilters.addFilterType("recipe")
  PrototypeFilterRecipe:addMapping(nil)
  PrototypeFilterRecipe:addFilter("name")
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
  PrototypeFilterRecipe:addFilter("subgroup", game.item_subgroup_prototypes)
  PrototypeFilterRecipe:addFilter("category", game.recipe_category_prototypes)
  PrototypeFilterRecipe:addFilter("energy", "comparison")
  PrototypeFilterRecipe:addFilter("emissions-multiplier", "comparison")
  PrototypeFilterRecipe:addFilter("request-paste-multiplier", "comparison")
  PrototypeFilterRecipe:addFilter("overload-multiplier", "comparison")
  
    -------------------------------------------------------------------------------
  -------------------------------------------------------------------------------
  local PrototypeFilterTechnology = PrototypeFilters.addFilterType("technology")
  PrototypeFilterTechnology:addMapping({["research-unit-ingredient"]="ingredient"})
  PrototypeFilterTechnology:addFilter("enabled")
  PrototypeFilterTechnology:addFilter("hidden")
  PrototypeFilterTechnology:addFilter("upgrade")
  PrototypeFilterTechnology:addFilter("visible-when-disabled")
  PrototypeFilterTechnology:addFilter("has-effects")
  PrototypeFilterTechnology:addFilter("has-prerequisites")
  PrototypeFilterTechnology:addFilter("research-unit-ingredient", PrototypeFilter("item"):getElements({{filter="type", type="tool"}}))
  PrototypeFilterTechnology:addFilter("level", "comparison")
  PrototypeFilterTechnology:addFilter("max-level", "comparison")
  PrototypeFilterTechnology:addFilter("time", "comparison")

end

return PrototypeFilters
