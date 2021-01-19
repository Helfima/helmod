---
-- Description of the module.
-- @module Cache
--
local Cache = {
  -- single-line comment
  classname = "HMCache"
}

-------------------------------------------------------------------------------
-- Return Cache
--
-- @function [parent=#Cache] get
--
-- @return #table
--
function Cache.get()
  if global.caches == nil then global.caches = {} end
  return global.caches
end

-------------------------------------------------------------------------------
-- Return data Cache
--
-- @function [parent=#Cache] getData
--
-- @param #string classname
-- @param #string name
--
-- @return #table
--
function Cache.getData(classname, name)
  local data = Cache.get()
  if classname == nil and name == nil then return data end
  if data[classname] == nil or data[classname][name] == nil then return nil end
  return data[classname][name]
end

-------------------------------------------------------------------------------
-- Set data Cache
--
-- @function [parent=#Cache] setData
--
-- @param #string classname
-- @param #string name
-- @param #object value
--
-- @return #object
--
function Cache.setData(classname, name, value)
  local data = Cache.get()
  if data[classname] == nil then data[classname] = {} end
  data[classname][name] = value
end

-------------------------------------------------------------------------------
-- Has data
--
-- @function [parent=#Cache] hasData
--
-- @param #string classname
-- @param #string name
--
-- @return #boolean
--
function Cache.hasData(classname, name)
  local data = Cache.get()
  return data[classname] ~= nil and data[classname][name] ~= nil
end

-------------------------------------------------------------------------------
-- Is empty
--
-- @function [parent=#Cache] isEmpty
--
-- @param #string classname
-- @param #string name
--
-- @return #boolean
--
function Cache.isEmpty(classname, name)
  local data = Cache.get()
  if data[classname] ~= nil and data[classname][name] ~= nil then
    if type(data[classname][name]) == "string" then
      return data[classname][name] == ""
    else
      return table.size(data[classname][name]) == 0
    end
  end
  return true
end

-------------------------------------------------------------------------------
-- Reset data
--
-- @function [parent=#Cache] reset
--
-- @param #string classname
-- @param #string name
--
function Cache.reset(classname, name)
  local data = Cache.get()
  if classname == nil and name == nil then
    global.caches = {}
  elseif data[classname] ~= nil and name == nil then
    data[classname] = nil
  elseif data[classname] ~= nil then
    data[classname][name] = nil
  end
end

return Cache
