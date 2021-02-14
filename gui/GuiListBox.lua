-------------------------------------------------------------------------------
---Class to help to build GuiListBox
---@class GuiListBox
GuiListBox = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiListBox"
  base.options.type = "list-box"
end)

-------------------------------------------------------------------------------
---Set Items
---@param items table
---@param selected any
---@return GuiListBox
function GuiListBox:items(items, selected)
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