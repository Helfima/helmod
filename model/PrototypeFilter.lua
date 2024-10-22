require "core.Object"

-------------------------------------------------------------------------------
---@class PrototypeFilter
PrototypeFilter = newclass(Object,function(base,type)
  Object.init(base,"PrototypeFilter")
  base.type = type
  base.filters = {}
end)

-------------------------------------------------------------------------------
---Add filter
---@param filter string
---@param options table
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
---Get filters
---@return table
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
---Get options
---@param filter string
---@return table
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
---Add mapping
---@param mapping table
function PrototypeFilter:addMapping(mapping)
  self.mapping = mapping
end

-------------------------------------------------------------------------------
---Set Game Function
---@param game_function function
function PrototypeFilter:setGameFunction(game_function)
  self.game_function = game_function
end

-------------------------------------------------------------------------------
---Get elements
---@param filters table
---@return table
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
    return prototypes.get_entity_filtered(filters)
  elseif self.type == "item" then
    return prototypes.get_item_filtered(filters)
  elseif self.type == "equipment" then
    return prototypes.get_equipment_filtered(filters)
  elseif self.type == "mod" then
    return prototypes.get_mod_setting_filtered(filters)
  elseif self.type == "achievement" then
    return prototypes.get_achievement_filtered(filters)
  elseif self.type == "tile" then
    return prototypes.get_tile_filtered(filters)
  elseif self.type == "decorative" then
    return prototypes.get_decorative_filtered(filters)
  elseif self.type == "fluid" then
    return prototypes.get_fluid_filtered(filters)
  elseif self.type == "recipe" then
    return prototypes.get_recipe_filtered(filters)
  elseif self.type == "technology" then
    return prototypes.get_technology_filtered(filters)
  end
  return {}
end