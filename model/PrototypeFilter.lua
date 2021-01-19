require "core.Object"

-------------------------------------------------------------------------------
--
-- @module PrototypeFilter
-- @extends Object#Object
--
PrototypeFilter = newclass(Object,function(base,type)
  Object.init(base,"PrototypeFilter")
  base.type = type
  base.filters = {}
end)

-------------------------------------------------------------------------------
-- Add filter
--
-- @function [parent=#PrototypeFilter] addFilter
--
-- @param #string filter name
-- @param #table options
--
function PrototypeFilter:addFilter(filter, options)
  if self.filters[filter] == nil then self.filters[filter] = {} end
  if options ~= nil then
    if type(options) == "string" then
      self.filters[filter] = options
    else
      for key, option in pairs(options) do
        self.filters[filter][key] = option
      end
    end
  end
end

-------------------------------------------------------------------------------
-- Get filters
--
-- @function [parent=#PrototypeFilter] getFilters
--
-- @return #table
--
function PrototypeFilter:getFilters()
  local filters = {}
  if self.filters ~= nil and table.size(self.filters) > 0 then
    for key,options in spairs(self.filters,function(t,a,b) return b > a end) do
      table.insert(filters,key)
    end
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
function PrototypeFilter:getOptions(filter)
  local options = {}
  local filters = self.filters
  if filters[filter] ~= nil then
    if type(filters[filter]) == "string" then
      return filters[filter]
    elseif table.size(filters[filter]) > 0 then
      for key,option in spairs(filters[filter],function(t,a,b) return b > a end) do
        table.insert(options,key)
      end
    end
  end
  return options
end

-------------------------------------------------------------------------------
-- Add mapping
--
-- @function [parent=#PrototypeFilter] addMapping
--
-- @param #table mapping
--
function PrototypeFilter:addMapping(mapping)
  self.mapping = mapping
end

-------------------------------------------------------------------------------
-- Set Game Function
--
-- @function [parent=#PrototypeFilter] setGameFunction
--
-- @param #string game_function
--
function PrototypeFilter:setGameFunction(game_function)
  self.game_function = game_function
end

-------------------------------------------------------------------------------
-- Get elements
--
-- @function [parent=#PrototypeFilter] getElements
--
-- @param  filters
--
-- @return #table
--
function PrototypeFilter:getElements(filters)
  if self.mapping ~= nil then
    for key,filter in pairs(filters) do
      for key, name in pairs(self.mapping) do
        filter[name] = filter[key]
        filter[key] = nil
      end
    end
  end
  if self.type == "entity" then
    return game.get_filtered_entity_prototypes(filters)
  elseif self.type == "item" then
    return game.get_filtered_item_prototypes(filters)
  elseif self.type == "equipment" then
    return game.get_filtered_equipment_prototypes(filters)
  elseif self.type == "mod" then
    return game.get_filtered_mod_setting_prototypes(filters)
  elseif self.type == "achievement" then
    return game.get_filtered_achievement_prototypes(filters)
  elseif self.type == "tile" then
    return game.get_filtered_tile_prototypes(filters)
  elseif self.type == "decorative" then
    return game.get_filtered_decorative_prototypes(filters)
  elseif self.type == "fluid" then
    return game.get_filtered_fluid_prototypes(filters)
  elseif self.type == "recipe" then
    return game.get_filtered_recipe_prototypes(filters)
  elseif self.type == "technology" then
    return game.get_filtered_technology_prototypes(filters)
  end
  return {}
end
