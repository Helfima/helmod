-------------------------------------------------------------------------------
---Class Object
---@class Runtime
Runtime = newclass(function(base)
    base.classname = "HMRuntime"
    base.caches = {}
end)
  
-------------------------------------------------------------------------------
---Clear
function Runtime:clear()
    self.caches = {}
end

-------------------------------------------------------------------------------
---Get runtime variable
---@param key string
---@return table
function Runtime:get(key)
    if self.caches[key] == nil then self.caches[key] = {} end
    return self.caches[key]
end

-------------------------------------------------------------------------------
---Set parameter
---@param property string
---@param value any
---@return any
function Runtime:setParameter(property, value)
    if property == nil then
        return nil
    end
    local parameter = self:get("parameter")
    parameter[property] = value
    return value
end

-------------------------------------------------------------------------------
---Get parameter
---@param property string
---@return any
function Runtime:getParameter(property)
    local parameter = self:get("parameter")
    if parameter ~= nil and property ~= nil then
      return parameter[property]
    end
    return parameter
end