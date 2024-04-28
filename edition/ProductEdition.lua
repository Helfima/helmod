-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class ProductEdition
ProductEdition = newclass(FormModel)

-------------------------------------------------------------------------------
---On initialization
function ProductEdition:onInit()
  self.panelCaption = ({"helmod_product-edition-panel.title"})
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function ProductEdition:onStyle(styles, width_main, height_main)
  styles.flow_panel = {
    minimal_height = 100,
    maximal_height = height_main,
  }
end

-------------------------------------------------------------------------------
---Get or create info panel
---@return LuaGuiElement
function ProductEdition:getInfoPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["info"] ~= nil and content_panel["info"].valid then
    return content_panel["info"]
  end
  local info_panel = GuiElement.add(content_panel, GuiFrameV("info"):style(helmod_frame_style.panel))
  info_panel.style.horizontally_stretchable = true
  return info_panel
end

-------------------------------------------------------------------------------
---Get or create tool panel
---@return LuaGuiElement
function ProductEdition:getToolPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["tool_panel"] ~= nil and content_panel["tool_panel"].valid then
    return content_panel["tool_panel"]
  end
  local tool_panel = GuiElement.add(content_panel, GuiFrameV("tool_panel"):style(helmod_frame_style.panel):caption({"helmod_product-edition-panel.tool"}))
  tool_panel.style.horizontally_stretchable = true
  return tool_panel
end

-------------------------------------------------------------------------------
---Get or create action panel
---@return LuaGuiElement
function ProductEdition:getActionPanel()
  local flow_panel, content_panel, menu_panel = self:getPanel()
  if content_panel["action_panel"] ~= nil and content_panel["action_panel"].valid then
    return content_panel["action_panel"]
  end
  local action_panel = GuiElement.add(content_panel, GuiFrameV("action_panel"):style(helmod_frame_style.panel))
  action_panel.style.horizontally_stretchable = true
  return action_panel
end

-------------------------------------------------------------------------------
---After open
---@param event LuaEvent
function ProductEdition:after_open(event)
  self:getInfoPanel()
end

local product = nil
local product_count = 0

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function ProductEdition:onUpdate(event)
  local model, block, recipe = self:getParameterObjects()
  product = nil
  if block ~= nil then
    local block_elements = block.products
    if block.by_product == false then
      block_elements = block.ingredients
    end
    local element_name = event.item5
    if block_elements ~= nil and block_elements[element_name] ~= nil then
      product = block_elements[element_name]
      product_count = product.input or 0
    end
  end

  self:updateInfo(model, block)
  if product ~= nil and product.type ~= "fluid" and product.type ~= "energy" then
    self:updateTool(model, block)
  end
end

-------------------------------------------------------------------------------
---Update information
---@param model table
---@param block table
local input_quantity = nil
function ProductEdition:updateInfo(model, block)
  local info_panel = self:getInfoPanel()
  if product ~= nil then
    info_panel.clear()

    local table_panel = GuiElement.add(info_panel, GuiTable("input-table"):column(2))
    GuiElement.add(table_panel, GuiButtonSprite("product"):sprite(product.type, product.name))
    GuiElement.add(table_panel, GuiLabel("product-label"):caption(Player.getLocalisedName(product)))

    local caption = {"helmod_common.quantity"}
    local count = product_count or 0
    if (product.name == "steam-heat") or (product.name == "energy") then
      caption = {"", {"helmod_common.quantity"}, " (MJ)"}
      count = count/1e6
    end
    
    GuiElement.add(table_panel, GuiLabel("quantity-label"):caption(caption))
    local cell, button
    cell, input_quantity, button = GuiCellInput(self.classname, "product-update", model.id, block.id, product.name, Product(product):getTableKey()):text(count):create(table_panel)
    input_quantity.focus()
    input_quantity.select_all()
    input_quantity.style.minimal_width = 100
  end
end

-------------------------------------------------------------------------------
---Update action
---@param model table
---@param block table
function ProductEdition:updateAction(model, block)
  local action_panel = self:getActionPanel()
  if product ~= nil then
    action_panel.clear()
    local action_panel = GuiElement.add(action_panel, GuiTable("table_action"):column(3))
    GuiElement.add(action_panel, GuiButton(self.classname, "product-reset", product.name):caption({"helmod_button.reset"}))
  end
end

-------------------------------------------------------------------------------
---Update tool
---@param model table
---@param block table
function ProductEdition:updateTool(model, block)
  local tool_panel = self:getToolPanel()
  tool_panel.clear()
  local table_panel = GuiElement.add(tool_panel, GuiTable("table-belt"):column(5))
  for key, prototype in pairs(Player.getEntityPrototypes({{filter="type", mode="or", invert=false, type="transport-belt"}})) do
    GuiElement.add(table_panel, GuiButtonSelectSprite(self.classname, "element-select"):sprite("entity", prototype.name):tooltip(EntityPrototype(prototype):getLocalisedName()))
  end
end
-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function ProductEdition:onEvent(event)
  local model, block, recipe = self:getParameterObjects()
  if User.isWriter(model) then
    if event.action == "product-update" then
      local products = {}
      local operation = input_quantity.text
      local ok , err = pcall(function()
        local quantity = nil 
        if operation ~= "" then
          quantity = formula(operation)
          if (event.item4 == "steam-heat") or (event.item4 == "energy") then
            quantity = quantity * 1e6
          end
          --if quantity == 0 then quantity = nil end
        end
        ModelBuilder.updateProduct(block, event.item4, quantity)
        ModelCompute.update(model)
        self:close()
        Controller:send("on_gui_refresh", event)
      end)
      if not(ok) then
        Player.print("Formula is not valid!")
      end
    end
    if event.action == "element-select" then
      local belt_speed = EntityPrototype(event.item1):getBeltSpeed()

      local text = string.format("%s*%s", belt_speed * Product().belt_ratio, model.time)
      GuiElement.setInputText(input_quantity, text)
      input_quantity.focus()
      input_quantity.select(1, string.len(text))
    end
  end
end