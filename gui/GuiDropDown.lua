-------------------------------------------------------------------------------
---Class to help to build GuiDropDown
---@class GuiDropDown
GuiDropDown = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiDropDown"
  base.options.type = "drop-down"
end)

-------------------------------------------------------------------------------
---comment
---@param items table
---@param selected string|table
---@return GuiDropDown
function GuiDropDown:items(items, selected)
  local selected_index = 1
  if items ~= nil then
    self.options.items = items
    for index,item in ipairs(items) do
      if item == selected then
        selected_index = index
      end
    end
  end
  self.options.selected_index = 1
  if selected_index ~= nil and selected ~= nil then
    self.options.selected_index = selected_index
  end
  return self
end