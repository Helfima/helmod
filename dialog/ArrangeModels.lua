-------------------------------------------------------------------------------
---Class to build ArrangeModels panel
---@class Form
ArrangeModels = newclass(Form)

-------------------------------------------------------------------------------
---Initialization
function ArrangeModels:onInit()
  self.panelCaption = ({"helmod_panel.arrange-models"})
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function ArrangeModels:onBind()
  Dispatcher:bind("on_gui_location", self, self.updateLocation)
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function ArrangeModels:onEvent(event)

end

local elements = nil

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function ArrangeModels:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_width = 50,
    maximal_width = width_main,
    minimal_height = 100,
    maximal_height = 100
    }
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function ArrangeModels:onUpdate(event)
  local parent_panel = self:getPanel()
  if elements == nil then
    elements = {}
    local models = Model.getModels()
    local index = 0
    local table_index = GuiElement.add(parent_panel, GuiTable("table_index"):column(GuiElement.getIndexColumnNumber()):style("helmod_table_list"))
    for _,model in pairs(models) do
        self:addModelButton(table_index, model, index)
        index = index + 1
    end
  end
end

-------------------------------------------------------------------------------
---On update
---@param index number
---@param model table
function ArrangeModels:addModelButton(parent_panel, model, index)
  local element = Model.firstChild(model.blocks)
  local button
  if element ~= nil then
    button = GuiElement.add(parent_panel, GuiButtonSelectSprite(self.classname, "move-item", model.id, index):sprite(element.type, element.name):tooltip(tooltip):color())
  else
    button = GuiElement.add(parent_panel, GuiButton(self.classname, "move-item", model.id, index):sprite("menu", defines.sprites.status_help.black, defines.sprites.status_help.black):style("helmod_button_menu"))
    button.style.width = 36
    --button.style.height = 36
  end
  button.style.padding = 0
end

-------------------------------------------------------------------------------
---On update
---@param index number
---@param model table
function ArrangeModels:addModelFrame(index, model)
  local parent_panel = self:getPanel()
  local element = Model.firstChild(model.blocks)
  local screen = Player.getGui("screen")
  
  local flow = GuiElement.add(screen, GuiFrameV(self.classname, "flow", model.id):style("frame"))
  flow.style.padding = -4
  flow.style.margin = 0
  flow.style.size = 36
  
  local position = parent_panel.location
  position.x = position.x + 15 + index * 38
  position.y = position.y + 50
  flow.location = position
  
  local tooltip = GuiTooltipModel("tooltip.info-model"):element(model)
  
  local grip = GuiElement.add(flow, GuiEmptyWidget(self.classname, "grip", model.id):tooltip(tooltip))
  grip.drag_target = flow
  grip.style.size = 36
  --button.drag_target = flow

  local button
  if element ~= nil then
    button = GuiElement.add(grip, GuiButtonSelectSprite(self.classname, "move-flow", model.id):sprite(element.type, element.name):tooltip(tooltip):color())
  else
    button = GuiElement.add(grip, GuiButton(self.classname, "move-flow", model.id):sprite("menu", defines.sprites.status_help.black, defines.sprites.status_help.black):style("helmod_button_menu"))
    button.style.width = 36
    --button.style.height = 36
  end
  button.style.padding = 0
  button.ignored_by_interaction = true
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function ArrangeModels:updateLocation(event)
  if elements == nil then return end
  local frame = event.element
  if frame.name ~= self.classname and frame.name:find(self.classname) then
  end
  if frame.name == self.classname then
    for _, frame in pairs(elements) do
    end
  end
end

-------------------------------------------------------------------------------
---On close dialog
function ArrangeModels:onClose()
  local screen = Player.getGui("screen")
  for _, frame in pairs(screen.children) do
      if frame.name:find(self.classname) then frame.destroy() end
  end
  elements = nil
end

-------------------------------------------------------------------------------
---On close dialog
function ArrangeModels:Clean()
  local screen = Player.getGui("screen")
  for _, frame in pairs(screen.children) do
      if frame.name:find(string.format("%s-%s", self.classname, "flow")) then frame.destroy() end
  end
  elements = nil
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function ArrangeModels:onEvent(event)
  local models = Model.getModels()
  if event.action == "move-item" then
    self:Clean()
    local model_id = event.item1
    local model = models[model_id]
    local index = event.item2
    self:addModelFrame(index, model)
  end
end