-------------------------------------------------------------------------------
---@class TilePrototype
TilePrototype = newclass(Prototype,function(base, object)
  if object ~= nil and type(object) == "string" then
    Prototype.init(base, Player.getTilePrototype(object))
  elseif object ~= nil and object.name ~= nil then
    Prototype.init(base, Player.getTilePrototype(object.name))
  end
  base.classname = "HMTilePrototype"
end)

-------------------------------------------------------------------------------
---Return Category
---@return string
function TilePrototype:getCategory()
  if self.lua_prototype == nil then return nil end
  return self.lua_prototype.category
end

-------------------------------------------------------------------------------
---Return hidden of Prototype
---@return boolean
function TilePrototype:getHidden()
  if self.lua_prototype ~= nil then
    return self.lua_prototype.hidden
  end
  return false
end
