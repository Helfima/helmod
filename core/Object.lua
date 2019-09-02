-------------------------------------------------------------------------------
-- Class Object
--
-- @module Object
--
Object = newclass(function(base,classname)
  base.classname = classname
  base:onInit()
end)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#Object] onInit
--
function Object:onInit()
end
