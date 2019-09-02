---
-- Description of the module.
-- @module PrototypeFilter
--
local PrototypeFilter = {
  -- single-line comment
  classname = "HMPrototypeFilter"
}

local lua_PrototypeFilter = nil

-------------------------------------------------------------------------------
-- Load factorio PrototypeFilters
--
-- @function [parent=#PrototypeFilter] load
--
-- @param #object object
--
-- @return #PrototypeFilter
--
function PrototypeFilter.load(object)
  lua_PrototypeFilters = object
  return PrototypeFilter
end

-------------------------------------------------------------------------------
-- Get types
--
-- @function [parent=#PrototypeFilter] getTypes
--
-- @return #table
--
function PrototypeFilter.getTypes()
  local types = {"entity","item","equipment","mod","achievement"}
  return types
end

-------------------------------------------------------------------------------
-- Get modes
--
-- @function [parent=#PrototypeFilter] getModes
--
-- @return #table
--
function PrototypeFilter.getModes()
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
function PrototypeFilter.getInverts()
  local modes = {"false","true"}
  return modes
end

-------------------------------------------------------------------------------
-- Get prototype filters
--
-- @function [parent=#PrototypeFilter] getPototypeFilters
--
-- @return #table
--
function PrototypeFilter.getPototypeFilters(type)
  local filters = {}
  filters["entity"] = {}
  filters["entity"]["type"]=Player.getEntityPrototypeTypes()
  filters["entity"]["flying-robot"]={}
  filters["entity"]["robot-with-logistics-interface"]={}
  filters["entity"]["rail"]={}
  filters["entity"]["particle"]={}
  filters["entity"]["ghost"]={}
  filters["entity"]["explosion"]={}
  filters["entity"]["vehicle"]={}
  filters["entity"]["crafting-machine"]={}
  filters["entity"]["rolling-stock"]={}
  filters["entity"]["turret"]={}
  filters["entity"]["transport-belt-connectable"]={}
  filters["entity"]["wall-connectable"]={}
  filters["entity"]["buildable"]={}
  filters["entity"]["placable-in-editor"]={}
  filters["entity"]["clonable"]={}
  filters["entity"]["selectable"]={}
  filters["entity"]["hidden"]={}
  filters["entity"]["entity-with-health"]={}
  filters["entity"]["building"]={}
  filters["entity"]["fast-replaceable"]={}
  filters["entity"]["uses-direction"]={}
  filters["entity"]["minable"]={}
  filters["entity"]["circuit-connectable"]={}
  filters["entity"]["autoplace"]={}
  filters["entity"]["blueprintable"]={}
  filters["entity"]["collision-mask"]={}
  filters["entity"]["collision-mask"]["ground-tile"]=true
  filters["entity"]["collision-mask"]["water-tile"]=true
  filters["entity"]["collision-mask"]["resource-layer"]=true
  filters["entity"]["collision-mask"]["doodad-layer"]=true
  filters["entity"]["collision-mask"]["floor-layer"]=true
  filters["entity"]["collision-mask"]["item-layer"]=true
  filters["entity"]["collision-mask"]["ghost-layer"]=true
  filters["entity"]["collision-mask"]["object-layer"]=true
  filters["entity"]["collision-mask"]["player-layer"]=true
  filters["entity"]["collision-mask"]["train-layer"]=true
  filters["entity"]["collision-mask"]["layer-11"]=true
  filters["entity"]["collision-mask"]["layer-12"]=true
  filters["entity"]["collision-mask"]["layer-13"]=true
  filters["entity"]["collision-mask"]["layer-14"]=true
  filters["entity"]["collision-mask"]["layer-15"]=true
  filters["entity"]["collision-mask"]["not-setup"]=true
  filters["entity"]["flag"]={}
  filters["entity"]["flag"]["not-rotatable"]=true
  filters["entity"]["flag"]["placeable-neutral"]=true
  filters["entity"]["flag"]["placeable-player"]=true
  filters["entity"]["flag"]["placeable-enemy"]=true
  filters["entity"]["flag"]["placeable-off-grid"]=true
  filters["entity"]["flag"]["player-creation"]=true
  filters["entity"]["flag"]["building-direction-8-way"]=true
  filters["entity"]["flag"]["filter-directions"]=true
  filters["entity"]["flag"]["fast-replaceable-no-build-while-moving"]=true
  filters["entity"]["flag"]["breaths-air"]=true
  filters["entity"]["flag"]["not-repairable"]=true
  filters["entity"]["flag"]["not-on-map"]=true
  filters["entity"]["flag"]["not-deconstructable"]=true
  filters["entity"]["flag"]["not-blueprintable"]=true
  filters["entity"]["flag"]["hide-from-bonus-gui"]=true
  filters["entity"]["flag"]["hide-alt-info"]=true
  filters["entity"]["flag"]["fast-replaceable-no-cross-type-while-moving"]=true
  filters["entity"]["flag"]["no-gap-fill-while-building"]=true
  filters["entity"]["flag"]["not-flammable"]=true
  filters["entity"]["flag"]["no-automated-item-removal"]=true
  filters["entity"]["flag"]["no-automated-item-insertion"]=true
  filters["entity"]["flag"]["no-copy-paste"]=true
  filters["entity"]["flag"]["not-selectable-in-game"]=true
  filters["entity"]["flag"]["not-upgradable"]=true

  filters["item"] = {}
  filters["item"]["type"] = Player.getItemPrototypeTypes()
  filters["item"]["tool"] = {}
  filters["item"]["mergeable"] = {}
  filters["item"]["item-with-inventory"] = {}
  filters["item"]["selection-tool"] = {}
  filters["item"]["item-with-label"] = {}
  filters["item"]["fuel"] = {}
  filters["item"]["place-as-tile"] = {}
  filters["item"]["place-result"] = {}
  filters["item"]["placed-as-equipment-result"] = {}
  filters["item"]["burnt-result"] = {}
  filters["item"]["flag"] = {}
  filters["item"]["flag"]["hidden"] = true
  filters["item"]["flag"]["hide-from-bonus-gui"] = true
  filters["item"]["flag"]["hide-from-fuel-tooltip"] = true
  filters["item"]["flag"]["not-stackable"] = true
  filters["item"]["flag"]["can-extend-inventory"] = true
  filters["item"]["flag"]["primary-place-result"] = true
  filters["item"]["flag"]["mod-openable"] = true
  filters["item"]["flag"]["only-in-cursor"] = true
  filters["item"]["subgroup"] = game.item_subgroup_prototypes
  filters["item"]["fuel-category"] = game.fuel_category_prototypes

  filters["equipment"] = {}
  filters["equipment"]["type"] = {}

  filters["mod"] = {}
  filters["mod"]["type"] = {}
  filters["mod"]["mod"] = {}
  filters["mod"]["setting-type"] = {}
  filters["mod"]["setting-type"]["startup"] = true
  filters["mod"]["setting-type"]["runtime-global"] = true
  filters["mod"]["setting-type"]["runtime-per-user"] = true

  filters["achievement"] = {}
  filters["achievement"]["type"] = {}
  filters["achievement"]["allowed-without-fight"] = {}
  return filters[type]
end

-------------------------------------------------------------------------------
-- Get filters
--
-- @function [parent=#PrototypeFilter] getFilters
--
-- @return #table
--
function PrototypeFilter.getFilters(type)
  local filters = {}
  for key,options in spairs(PrototypeFilter.getPototypeFilters(type),function(t,a,b) return b > a end) do
    table.insert(filters,key)
  end
  return filters
end

-------------------------------------------------------------------------------
-- Get options
--
-- @function [parent=#PrototypeFilter] getOptions
--
-- @return #table
--
function PrototypeFilter.getOptions(type, filter)
  local options = {}
  local filters = PrototypeFilter.getPototypeFilters(type)
  for key,option in spairs(filters[filter],function(t,a,b) return b > a end) do
    table.insert(options,key)
  end
  return options
end

-------------------------------------------------------------------------------
-- Get elements
--
-- @function [parent=#PrototypeFilter] getElements
--
-- @return #table
--
function PrototypeFilter.getElements(type ,filters)
  for key,filter in pairs(filters) do
    if type == "entity" then
      if filter["collision-mask"] then
        filter["mask"] = filter["collision-mask"]
        filter["collision-mask"] = nil
      end
    elseif type == "item" then
    elseif type == "equipment" then
    elseif type == "mod" then
      if filter["setting-type"] then
        filter["type"] = filter["setting-type"]
        filter["setting-type"] = nil
      end
    elseif type == "achievement" then
    end
    filters[key] = filter
  end
  if type == "entity" then
    return game.get_filtered_entity_prototypes(filters)
  elseif type == "item" then
    return game.get_filtered_item_prototypes(filters)
  elseif type == "equipment" then
    return game.get_filtered_equipment_prototypes(filters)
  elseif type == "mod" then
    return game.get_filtered_mod_setting_prototypes(filters)
  elseif type == "achievement" then
    return game.get_filtered_achievement_prototypes(filters)
  end
  return {}
end

return PrototypeFilter
