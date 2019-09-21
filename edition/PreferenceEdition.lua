-------------------------------------------------------------------------------
-- Class to build product edition dialog
--
-- @module PreferenceEdition
-- @extends #AbstractEdition
--

PreferenceEdition = newclass(Form)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PreferenceEdition] onInit
--
function PreferenceEdition:onInit()
  self.panelCaption = ({"helmod_preferences-edition-panel.title"})
  self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- On before event
--
-- @function [parent=#PreferenceEdition] onBeforeEvent
--
-- @param #LuaEvent event
--
-- @return #boolean if true the next call close dialog
--
function PreferenceEdition:onBeforeEvent(event)
  local close = true
  if User.getParameter(self.parameterLast) == nil or User.getParameter(self.parameterLast) ~= event.item1 then
    close = false
  end
  User.setParameter(self.parameterLast, event.item1)
  return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PreferenceEdition] onClose
--
function PreferenceEdition:onClose()
  User.setParameter(self.parameterLast,nil)
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PreferenceEdition] getInfoPanel
--
function PreferenceEdition:getRecipeCategoryPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  local panel_name = "scroll-recipe-category"
  if content_panel[panel_name] ~= nil and content_panel[panel_name].valid then
    return content_panel[panel_name]["scroll_panel"]
  end
  local panel = ElementGui.addGuiFrameV(content_panel, panel_name, helmod_frame_style.default, "Default factory")
  panel.style.height = 600
  panel.style.width = 900
  local scroll_panel = ElementGui.addGuiScrollPane(panel, "scroll_panel", helmod_frame_style.scroll_pane, true, true)
  scroll_panel.style.horizontally_stretchable = true
  scroll_panel.style.vertically_stretchable = true

  return scroll_panel
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PreferenceEdition] onUpdate
--
-- @param #LuaEvent event
--
function PreferenceEdition:onUpdate(event)
  self:updateRecipeCategory(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PreferenceEdition] updateRecipeCategory
--
-- @param #LuaEvent event
--

function PreferenceEdition:updateRecipeCategory(event)
  Logging:debug(self.classname, "updateRecipeCategory()", event)
  local recipe_category_panel = self:getRecipeCategoryPanel()
  recipe_category_panel.clear()
  local category_table = ElementGui.addGuiTable(recipe_category_panel, "categories", 2, helmod_table_style.panel)
  category_table.vertical_centering = false
  
  for category_name,category in pairs(game.recipe_category_prototypes) do
    ElementGui.addGuiLabel(category_table, category_name, category_name)
    local factory_cell = ElementGui.addGuiFlowH(category_table, string.format("factory_%s",category_name),helmod_flow_style.horizontal)
    factory_cell.style.horizontally_stretchable = false
    local factories = Player.getProductionMachines()
    for _,lua_factory in pairs(factories) do
      if lua_factory.crafting_categories ~= nil and lua_factory.crafting_categories[category_name] then
        local factory = Model.newFactory(lua_factory.name)
        factory.localised_name = lua_factory.localised_name
        Logging:debug(self.classname, "factory", factory)
        ElementGui.addCellFactory(factory_cell, factory, string.format("%s=change-preference=ID=%s", self.classname, factory.name), false, nil, "gray")
      end
    end
  end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PreferenceEdition] onEvent
--
-- @param #LuaEvent event
--
function PreferenceEdition:onEvent(event)
  Logging:debug(self.classname, "onEvent()", event)
  local model = Model.getModel()
  if Player.isAdmin() or model.owner == Player.native().name or (model.share ~= nil and bit32.band(model.share, 2) > 0) then
    if event.action == "product-update" then
      local products = {}

      local operation = event.element.text
      local ok , err = pcall(function()
        local quantity = formula(operation)
        if quantity == 0 then quantity = nil end
        ModelBuilder.updateProduct(event.item1, event.item2, quantity)
        ModelCompute.update()
        self:close()
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end
    if event.action == "product-reset" then
      local products = {}
      ModelBuilder.updateProduct(event.item1, event.item2, nil)
      ModelCompute.update()
      self:close()
      Controller:send("on_gui_refresh", event)
    end
    if event.action == "element-select" then
      local belt_speed = EntityPrototype(event.item1):getBeltSpeed()

      local text = string.format("%s*1", belt_speed * Product().belt_ratio)
      ElementGui.setInputText(input_quantity, text)
      input_quantity.focus()
      input_quantity.select(string.len(text), string.len(text))
    end
  end
end
