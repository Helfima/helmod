-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
function newclass(super, init)
  local c = {}    -- a new class instance
  if not init and type(super) == 'function' then
    init = super
    super = nil
  elseif type(super) == 'table' then
    -- our new class is a shallow copy of the super class!
    for i,v in pairs(super) do
      c[i] = v
    end
    c._super = super
  end
  -- the class will be the metatable for all its objects,
  -- and they will look up their methods in it.
  c.__index = c

  -- expose a constructor which can be called by <classname>(<args>)
  local mt = {}
  mt.__call = function(class_tbl, ...)
    local obj = {}
    setmetatable(obj,c)
    if init then
      init(obj,...)
    else
      -- make sure that any stuff from the super class is initialized!
      if super and super.init then
        super.init(obj, ...)
      end
    end
    return obj
  end
  c.init = init
  c.is_a = function(self, klass)
    local m = getmetatable(self)
    while m do
      if m == klass then return true end
      m = m._super
    end
    return false
  end
  setmetatable(c, mt)
  return c
end
