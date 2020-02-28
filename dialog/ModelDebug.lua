-------------------------------------------------------------------------------
-- Class to build ModelDebug panel
--
-- @module ModelDebug
-- @extends #Form
--

ModelDebug = newclass(Form)

local display_panel = nil

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#ModelDebug] init
--
function ModelDebug:onInit()
  self.panelCaption = "Model Debug"
end

-------------------------------------------------------------------------------
-- On Bind Dispatcher
--
-- @function [parent=#ModelDebug] onBind
--
function ModelDebug:onBind()
  Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#ModelDebug] getInfoPanel
--
function ModelDebug:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info-panel"] ~= nil and content_panel["info-panel"].valid then
    return content_panel["info-panel"]
  end
  local panel = GuiElement.add(content_panel, GuiFrameV("info-panel"):style(helmod_frame_style.panel))
  panel.style.horizontally_stretchable = true
  return  panel
end

-------------------------------------------------------------------------------
-- Build matrix
--
-- @function [parent=#ModelDebug] buildMatrix
--
-- @param #GuiElement matrix_panel
-- @param #table matrix
-- @param #table pivot
--
function ModelDebug:buildMatrix(matrix_panel, matrix, pivot)
  Logging:debug("ProductionBlockTab", "buildMatrix()")
  if matrix ~= nil then
    local num_col = #matrix[1]

    local matrix_table = GuiElement.add(matrix_panel, GuiTable("matrix_data"):column(num_col):style("helmod_table-rule-odd"))

    for irow,row in pairs(matrix) do
      for icol,value in pairs(row) do
        local frame = GuiFrameH("cell", irow, icol):style("helmod_frame_product", "none", 1)
        if pivot ~= nil then
          if matrix[1][icol].name == "T" then frame:style("helmod_frame_product", GuiElement.color_button_default_ingredient, 2) end
          if pivot.x == icol then frame:style("helmod_frame_product", GuiElement.color_button_edit, 2) end
          if pivot.y == irow then frame:style("helmod_frame_product", GuiElement.color_button_none, 2) end
          if pivot.x == icol and pivot.y == irow then frame:style("helmod_frame_product", GuiElement.color_button_rest, 2) end
        end
        local cell = GuiElement.add(matrix_table, frame)
        if type(value) == "table" then
          if value.type == "none" then
            GuiElement.add(cell, GuiLabel("cell_value"):caption(value.name))
          else
            GuiElement.add(cell, GuiButtonSprite("cell_value"):sprite(value.type, value.name):tooltip(value.tooltip))
          end
        else
          GuiElement.add(cell, GuiLabel("cell_value"):caption(Format.formatNumber(value,4)))
        end
      end
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#ModelDebug] onEvent
--
-- @param #LuaEvent event
--
function ModelDebug:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local model = Model.getModel()
  local current_block = User.getParameter("current_block")
  if model.blocks[current_block] ~= nil and model.blocks[current_block].runtimes ~= nil then
    local runtimes = model.blocks[current_block].runtimes
    if event.action == "change-stage" then
      local stage = User.getParameter("model_stage") or 1
      if event.item1 == "initial" then stage = 1 end
      if event.item1 == "previous" and stage > 1 then stage = stage - 1 end
      if event.item1 == "next" and stage < #runtimes then stage = stage + 1 end
      if event.item1 == "final" then stage = #runtimes end
      User.setParameter("model_stage", stage)
    end
    self:onUpdate(event)
  end
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#ModelDebug] onUpdate
--
-- @param #LuaEvent event
--
function ModelDebug:onUpdate(event)
  self:updateHeader(event)
  self:updateDebugPanel(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ModelDebug] updateHeader
--
-- @param #LuaEvent event
--
function ModelDebug:updateHeader(event)
  Logging:debug(self.classname, "updateHeader()", event)
  local left_menu_panel = self:getLeftMenuPanel()
  left_menu_panel.clear()
  local group1 = GuiElement.add(left_menu_panel, GuiFlowH("group1"))
  GuiElement.add(group1, GuiButton(self.classname, "change-stage", "initial"):sprite("menu", "record-white", "record"):style("helmod_button_menu"):tooltip("Initial"))
  GuiElement.add(group1, GuiButton(self.classname, "change-stage", "previous"):sprite("menu", "arrow-left-white", "arrow-left"):style("helmod_button_menu"):tooltip("Previous Step"))
  GuiElement.add(group1, GuiButton(self.classname, "change-stage", "next"):sprite("menu", "arrow-right-white", "arrow-right"):style("helmod_button_menu"):tooltip("Next Step"))
  GuiElement.add(group1, GuiButton(self.classname, "change-stage", "final"):sprite("menu", "end-white", "end"):style("helmod_button_menu"):tooltip("Final"))
end

-------------------------------------------------------------------------------
-- Add cell header
--
-- @function [parent=#ModelDebug] addCellHeader
--
-- @param #LuaGuiElement guiTable
-- @param #string name
-- @param #string caption
--
function ModelDebug:addCellHeader(guiTable, name, caption)
  local cell = GuiElement.add(guiTable, GuiFrameH("header", name):style(helmod_frame_style.hidden))
  GuiElement.add(cell, GuiLabel("label"):caption(caption))
end

-------------------------------------------------------------------------------
-- Update debug panel
--
-- @function [parent=#ModelDebug] updateDebugPanel
--
-- @param #LuaEvent event
--
function ModelDebug:updateDebugPanel(event)
  Logging:debug(self.classname, "updateDebugPanel()", event)
  local info_panel = self:getInfoPanel()
  local model = Model.getModel()

  local current_block = User.getParameter("current_block")

  local countRecipes = Model.countBlockRecipes(current_block)

  if countRecipes > 0 then

    info_panel.clear()
    local block = model.blocks[current_block]

    -- product
--    local product_panel = GuiElement.add(info_panel, GuiFrameV("product_panel"):style(helmod_frame_style.hidden):caption("Product data"))
--    local product_table = GuiElement.add(product_panel, GuiTable("product-data"):column(3):style("helmod_table-rule-odd"))
--    self:addCellHeader(product_table, "title", "Product")
--    self:addCellHeader(product_table, "value", {"helmod_result-panel.col-header-value"})
--    self:addCellHeader(product_table, "state", {"helmod_result-panel.col-header-state"})
--
--
--    if block.products ~= nil then
--      for _,product in pairs(block.products) do
--        GuiElement.add(product_table, GuiLabel(product.name, "title"):caption(product.name))
--        GuiElement.add(product_table, GuiLabel(product.name, "value"):caption(product.count))
--        GuiElement.add(product_table, GuiLabel(product.name, "state"):caption(product.state))
--      end
--    end


    if block.runtimes ~= nil then
      local scroll_panel = GuiElement.add(info_panel, GuiScroll("scroll_stage"))
      scroll_panel.style.maximal_width = 800
      scroll_panel.style.maximal_height = 700
      local stage = User.getParameter("model_stage") or 1
      if block.runtimes[stage] == nil then
        stage = 1
        User.setParameter("model_stage", stage)
      end
      Logging:debug(self.classname, "stage", stage, "block", block)
      local runtime = block.runtimes[stage]
      local ma_panel = GuiElement.add(scroll_panel, GuiFrameV("stage_panel"):style(helmod_frame_style.hidden):caption(runtime.name))
      self:buildMatrix(ma_panel, runtime.matrix, runtime.pivot)
    end
  end
end

-------------------------------------------------------------------------------
-- Update display
--
-- @function [parent=#ModelDebug] updateDisplay
--
function ModelDebug:updateDisplay()
  Logging:debug(self.classname, "updateDisplay()")
  local content_panel = self:getInfoPanel()
  content_panel.clear()
end
