-------------------------------------------------------------------------------
-- Class to build ArrangeModels panel
--
-- @module ArrangeModels
-- @extends #Form
--

ArrangeModels = newclass(Form)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#ArrangeModels] init
--
function ArrangeModels:onInit()
  self.panelCaption = ({"helmod_panel.arrange-models"})
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#ArrangeModels] onBind
--
function ArrangeModels:onBind()
  Dispatcher:bind("on_gui_location", self, self.updateLocation)
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ArrangeModels] onEvent
--
-- @param #LuaEvent event
--
function ArrangeModels:onEvent(event)

end

local elements = nil

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ArrangeModels] onUpdate
--
-- @param #LuaEvent event
--
function ArrangeModels:onUpdate(event)
  local panel = self:getFramePanel("models")
  panel.style.height = 300
  panel.style.horizontally_stretchable = true
  if elements == nil then
    elements = {}
    local models = Model.getModels()
    local index = 0
    for _,model in pairs(models) do
        self:addModelFrame(index, model)
        index = index + 1
    end
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ArrangeModels] addModelFrame
--
-- @param #LuaEvent event
--
function ArrangeModels:addModelFrame(index, model)
  local parent_panel = self:getPanel()
  local element = Model.firstRecipe(model.blocks)
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
    button = GuiElement.add(grip, GuiButton(self.classname, "move-flow", model.id):sprite("menu", "help", "help"):style("helmod_button_menu"))
    button.style.width = 36
    --button.style.height = 36
  end
  button.style.padding = 0
  button.ignored_by_interaction = true
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ArrangeModels] updateLocation
--
-- @param #LuaEvent event
--
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
-- On close dialog
--
-- @function [parent=#Form] onClose
--
-- @return #boolean if true the next call close dialog
--
function ArrangeModels:onClose()
  local screen = Player.getGui("screen")
  for _, frame in pairs(screen.children) do
      if frame.name:find(self.classname) then frame.destroy() end
  end
  elements = nil
end