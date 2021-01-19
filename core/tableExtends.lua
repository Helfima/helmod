function table.clone(org)
    return {table.unpack(org)}
  end
  
  function table.contains(object, value)
    for _,compare in pairs(object) do
      if compare == value then return true end
    end
    return false
  end
  
  function table.deepcopy(object)
    local lookup_table = {}
    local function _copy(object)
      if type(object) ~= "table" then
        return object
      -- don't copy factorio rich objects
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
  -- Reindex list
  --
  function table.reindex_list(list)
    local index = 0
    for _,element in spairs(list,function(t,a,b) return t[b].index > t[a].index end) do
      element.index = index
      index = index + 1
    end
  end

-------------------------------------------------------------------------------
-- Up in the list
--
-- @function [parent=#table] up_indexed_list
--
-- @param #table list
-- @param #number index
-- @param #number step
--
function table.up_indexed_list(list, index, step)
    if list ~= nil and index > 0 then
      -- defaut step
      if step == nil then step = 1 end
      -- cap le step
      if step > index then step = index end
      for _,element in pairs(list) do
        if element.index == index then
          -- change l'index de l'element cible
          element.index = element.index - step
        elseif element.index >= index - step and element.index <= index then
          -- change les index compris entre index et index -step
          element.index = element.index + 1
        end
      end
    end
  end
  
  -------------------------------------------------------------------------------
-- Down in the list
--
-- @function [parent=#table] down_indexed_list
--
-- @param #table list
-- @param #number index
-- @param #number step
--
function table.down_indexed_list(list, index, step)
    local list_count = table.size(list)
    if list ~= nil and index + 1 < table.size(list) then
      -- defaut step
      if step == nil then step = 1 end
      -- cap le step
      if step > (list_count - index) then step = list_count - index - 1 end
      for _,element in pairs(list) do
        if element.index == index then
          -- change l'index de l'element cible
          element.index = element.index + step
        elseif element.index > index and element.index <= index + step then
          -- change les index compris entre index et la fin
          element.index = element.index - 1
        end
      end
    end
  end
  
  -------------------------------------------------------------------------------
  -- Size list
  --
  function table.size(list)
    if list == nil then return 0 end
    return table_size(list)
  end
    