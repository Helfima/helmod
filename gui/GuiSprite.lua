-------------------------------------------------------------------------------
---Class to help to build GuiSprite
---@class GuiSprite
GuiSprite = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiSprite"
  base.options.type = "sprite"
end)

-------------------------------------------------------------------------------
---Set sprite
---@param type string
---@param name string
---@return GuiSprite
function GuiSprite:sprite(type, name)
  if type == "menu" then
    self.options.sprite = GuiElement.getSprite(name)
  elseif name == nil then
    self.options.sprite = type
  else
    self.options.sprite = string.format("%s/%s", type, name)
  end
  return self
end