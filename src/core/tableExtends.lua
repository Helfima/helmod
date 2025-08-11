-------------------------------------------------------------------------------
---Clone simple table
---@param org table
---@return table
function table.clone(org)
  return {table.unpack(org)}
end

-------------------------------------------------------------------------------
---Check Table Contains
---@param object table
---@param value any
---@return boolean
function table.contains(object, value)
  for _,compare in pairs(object) do
    if compare == value then return true end
  end
  return false
end

-------------------------------------------------------------------------------
---Deep Copy of table
---@param object table
---@return table
function table.deepcopy(object)
  local lookup_table = {}
  local function _copy(object)
    if type(object) ~= "table" then
      return object
    ---don't copy factorio rich objects
    elseif object.__self then
      return object
    elseif lookup_table[object] then
      return lookup_table[object]
    end
    local new_table = {}
    lookup_table[object] = new_table
    for index, value in pairs(object) do
      new_table[_copy(index)] = _copy(value)
    end
    return setmetatable(new_table, getmetatable(object))
  end
  return _copy(object)
end
-------------------------------------------------------------------------------
---Reindex list
---@param list table
function table.reindex_list(list)
  local index = 0
  for _,element in spairs(list,function(t,a,b) return t[b].index > t[a].index end) do
    element.index = index
    index = index + 1
  end
end

-------------------------------------------------------------------------------
---Up in the list
---@param list table -- element of table must be index field
---@param index number
---@param step number
function table.up_indexed_list(list, index, step)
    if list ~= nil and index > 0 then
      table.reindex_list(list)
      ---defaut step
      if step == nil then step = 1 end
      ---cap le step
      if step > index then step = index end
      for _,element in pairs(list) do
        if element.index == index then
          ---change l'index de l'element cible
          element.index = element.index - step
        elseif element.index >= index - step and element.index <= index then
          ---change les index compris entre index et index -step
          element.index = element.index + 1
        end
      end
    end
  end

-------------------------------------------------------------------------------
---Down in the list
---@param list table -- element of table must be index field
---@param index number
---@param step number
function table.down_indexed_list(list, index, step)
  local list_count = table.size(list)
  if list ~= nil and index + 1 < table.size(list) then
    table.reindex_list(list)
    ---defaut step
    if step == nil then step = 1 end
    ---cap le step
    if step > (list_count - index) then step = list_count - index - 1 end
    for _,element in pairs(list) do
      if element.index == index then
        ---change l'index de l'element cible
        element.index = element.index + step
      elseif element.index > index and element.index <= index + step then
        ---change les index compris entre index et la fin
        element.index = element.index - 1
      end
    end
  end
end

-------------------------------------------------------------------------------
---Get table size
---@param list table
---@return number
function table.size(list)
  if list == nil then return 0 end
  if type(list) == "userdata" then
    return #list
  end
  return table_size(list)
end

-------------------------------------------------------------------------------
---Convert info table with type for element
---@param list table
---@return table
function table.data_help(list)
  local result = {}
  return result
end

-------------------------------------------------------------------------------
---Convert info table with type for element
---@param list table
---@return table
function table.data_info(list)
  if type(list) == 'table' and type(list.__self) == 'userdata' and list.object_name then
    local result = {}
    for k, v in pairs(table.data_help(list)) do
      list[k] = {value=v,type=type(v)}
    end
    return result
  elseif type(list) == 'table' then
    local result = {}
    for k, v in pairs(list) do
      result[k] = {value=v,type=type(v)}
    end
    return result
  end
end

-------------------------------------------------------------------------------
---Convert info table with type for element
---@param list table
---@param index_start uint
---@param index_end? uint
---@return table
table.slice = function(list, index_start, index_end)
  local index_end = index_end or table.size(list)
  local new_list = {}
  local index = 1
  for k, v in pairs(list) do
    if index > index_start and index <= index_end then
      new_list[k] = v
    end
    index= index + 1
  end
  return new_list
end