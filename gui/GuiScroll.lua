-------------------------------------------------------------------------------
---Class to help to build GuiScroll
---@class GuiScroll
GuiScroll = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiScroll"
  base.options.type = "scroll-pane"
  base.options.style = "scroll_pane"
end)

-------------------------------------------------------------------------------
---Set policy
---@param policy string
---@return GuiScroll
function GuiScroll:policy(policy)
  self.options.horizontal_scroll_policy = "auto"
  if policy == true then
    self.options.vertical_scroll_policy = "auto"
  end
  return self
end