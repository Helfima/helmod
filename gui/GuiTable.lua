-------------------------------------------------------------------------------
---Class to help to build GuiTable
---@class GuiTable
GuiTable = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTable"
  base.options.type = "table"
  base.options.style = "helmod_table_default"
end)

-------------------------------------------------------------------------------
---Set column
---@param column_count number
---@return GuiTable
function GuiTable:column(column_count)
  self.options.column_count = column_count
  return self
end