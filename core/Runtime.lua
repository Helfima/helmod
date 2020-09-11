-------------------------------------------------------------------------------
-- Class Object
--
-- @module Runtime
--
Runtime = newclass(function(base)
    base.classname = "HMRuntime"
    base.caches = {}
end)
  
-------------------------------------------------------------------------------
-- Get runtime variable
--
-- @function [parent=#Runtime] get
--
-- @param #string key
--
function Runtime:clear()
    self.caches = {}
end

-------------------------------------------------------------------------------
-- Get runtime variable
--
-- @function [parent=#Runtime] get
--
-- @param #string key
--
-- @return #table
--
function Runtime:get(key)
    if self.caches[key] == nil then self.caches[key] = {} end
    return self.caches[key]
end

-------------------------------------------------------------------------------
-- Set parameter
--
-- @function [parent=#Runtime] setParameter
--
-- @param #string property
-- @param #object value
--
function Runtime:setParameter(property, value)
    if property == nil then
        return nil
    end
    local parameter = self:get("parameter")
    parameter[property] = value
    return value
end

  -------------------------------------------------------------------------------
-- Get parameter
--
-- @function [parent=#Runtime] getParameter
--
-- @param #string property
--
function Runtime:getParameter(property)
    local parameter = self:get("parameter")
    if parameter ~= nil and property ~= nil then
      return parameter[property]
    end
    return parameter
end