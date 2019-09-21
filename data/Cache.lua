---
-- Description of the module.
-- @module Cache
--
local Cache = {
  -- single-line comment
  classname = "HMCache"
}

local data = {}

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
  Logging:trace(Cache.classname, "getData(classname, name)",classname, name)
  if classname == nil and name == nil then return data end
  if data[classname] == nil or data[classname][name] == nil then return nil end
  Logging:trace(Cache.classname, "--> cache",data[classname][name])
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
  Logging:trace(Cache.classname, "setData(classname, name, value)",classname, name, value)
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
  Logging:trace(Cache.classname, "getData(hasData, name)",classname, name)
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
  Logging:trace(Cache.classname, "getData(hasData, name)",classname, name)
  if data[classname] ~= nil and data[classname][name] ~= nil then
    if type(data[classname][name]) == "string" then
      return data[classname][name] == ""
    else
      return Model.countList(data[classname][name]) == 0
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
  Logging:trace(Cache.classname, "reset(classname, name)", classname, name)
  if classname == nil and name == nil then
    data = {}
  elseif data[classname] ~= nil and name == nil then
    data[classname] = nil
  elseif data[classname] ~= nil then
    data[classname][name] = nil
  end
end

-------------------------------------------------------------------------------
-- Add translate
--
-- @function [parent=#Cache] addTranslate
--
-- @param #table request {player_index=number, localised_string=#string, result=#string, translated=#boolean}
--
function Cache.addTranslate(request)
  local localised_string = request.localised_string
  local result = request.result
  local index = 1
  for translated in string.gmatch(result, "[^|]*") do
    index = index + 1
    if localised_string[index] ~= nil and translated ~= "" then
      if data["translated"] == nil then data["translated"] = {} end
      local _,key = string.match(localised_string[index][1],"([^.]*).([^.]*)")
      data["translated"][key] = translated
    end
  end
end

-------------------------------------------------------------------------------
-- Get translate
--
-- @function [parent=#Cache] getTranslate
--
-- @param #string name
--
function Cache.getTranslate(name)
  if data["translated"] == nil or data["translated"][name] == nil then return name end
  return data["translated"][name]
end

return Cache
