-------------------------------------------------------------------------------
-- Class to help to build GuiSlider
--
-- @module GuiCell
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCell
--
GuiCell = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiCell"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] element
-- @param #table element
-- @return #GuiCell
--
function GuiCell:element(element)
  self.element = element
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] index
-- @param #number index
-- @return #GuiCell
--
function GuiCell:index(index)
  self.m_index = index
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] color
-- @param #string color
-- @return #GuiCell
--
function GuiCell:color(color)
  self.m_color = color
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] broken
-- @param #boolean broken
-- @return #GuiCell
--
function GuiCell:broken(broken)
  self.m_broken = broken
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] withProductInfo
-- @return #GuiCell
--
function GuiCell:withProductInfo()
  self.m_with_product_info = true
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] withLogistic
-- @return #GuiCell
--
function GuiCell:withLogistic()
  self.m_with_logistic = true
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] infoIcon
-- @param #string type
-- @return #GuiCell
--
function GuiCell:infoIcon(type)
  self.m_info_icon = type
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] contraintIcon
-- @param #string type
-- @return #GuiCell
--
function GuiCell:contraintIcon(type)
  self.m_contraint_icon = type
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] controlInfo
-- @param #string control_info
-- @return #GuiCell
--
function GuiCell:controlInfo(control_info)
  self.m_with_control_info = control_info
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] onErrorOptions
-- @return #table
--
function GuiCell:onErrorOptions()
  local options = self:getOptions()
  options.type = "button"
  options.style = nil
  return options
end

-------------------------------------------------------------------------------
-- By Limit
--
-- @function [parent=#GuiCell] byLimit
--
function GuiCell:byLimit(by_limit)
  self.m_by_limit = by_limit
  return self
end

-------------------------------------------------------------------------------
-- By Limit
--
-- @function [parent=#GuiCell] byLimit
--
function GuiCell:byLimitUri(...)
  self.m_by_limit_uri = table.concat({...},"=")
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] overlay
-- @param #string type
-- @return #GuiCell
--
function GuiCell:overlay(type, name)
  self.m_overlay_type = type
  self.m_overlay_name = name
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] add_overlay
-- @return #table
--
function GuiCell:add_overlay(button)
  if self.m_overlay_type ~= nil then
    local sprite = GuiElement.getSprite(self.m_overlay_type, self.m_overlay_name)
    GuiElement.add(button, GuiSprite("overlay"):sprite(sprite))
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] mask
-- @param #string type
-- @return #GuiCell
--
function GuiCell:mask(mask)
  self.m_mask = mask
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] add_mask
-- @return #table
--
function GuiCell:add_mask(button, color, size)
  if self.m_mask == true then
    local mask_frame = GuiElement.add(button, GuiFrameH("layer-mask"):style("helmod_frame_colored", color, 5))
    mask_frame.style.width = size or 32
    mask_frame.style.height = size or 32
    mask_frame.ignored_by_interaction = true
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] add_infoIcon
-- @return #table
--
function GuiCell:add_infoIcon(button, info_icon)
  local type = info_icon or self.m_info_icon
  if type == nil then return end
  if type == "recipe-burnt" then 
    local tooltip = "tooltip.burnt-recipe"
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({tooltip}))
    sprite.style.top_padding = -8
  end
  if type == "rocket" then 
    local tooltip = "tooltip.rocket-recipe"
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({tooltip}))
    sprite.style.top_padding = -8
  end
  if type == "fluid" then 
    local tooltip = "tooltip.resource-recipe"
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("developer"):tooltip({tooltip}))
    sprite.style.top_padding = -8
  end
  if type == "resource" then 
    local tooltip = "tooltip.resource-recipe"
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("helmod-tool-jewel"):tooltip({tooltip}))
    sprite.style.top_padding = -4
  end
  if type == "technology" then 
    local tooltip = "tooltip.technology-recipe"
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("helmod-tool-graduation"):tooltip({tooltip}))
    sprite.style.top_padding = -4
  end
  if type == "energy" then 
    local tooltip = "tooltip.energy-recipe"
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("helmod-tool-nuclear"):tooltip({tooltip}))
    sprite.style.top_padding = -4
  end
  if type == "burnt" then 
    local tooltip = "tooltip.burnt-product"
    local sprite = GuiElement.add(button, GuiSprite("burnt"):sprite("helmod-tool-burnt"):tooltip({tooltip}))
    sprite.style.top_padding = -4
  end
  if type == "block" then
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("helmod-tool-hangar"))
    sprite.style.top_padding = -2
    sprite.style.left_padding = 22
    sprite.ignored_by_interaction = true
  end
  if type == "root_block" then
    local sprite = GuiElement.add(button, GuiSprite("info"):sprite("helmod-tool-factory"))
    sprite.style.top_padding = -2
    sprite.style.left_padding = 22
    sprite.ignored_by_interaction = true
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] add_contraintIcon
-- @return #table
--
function GuiCell:add_contraintIcon(button)
  if self.m_contraint_icon == nil then return end
  if self.m_contraint_icon == "linked" then 
    local sprite = GuiElement.add(button, GuiSprite("contraint"):sprite("helmod-tool-arrow-up"))
    sprite.style.top_padding = -4
    sprite.style.left_padding = 22
  end
  if self.m_contraint_icon == "master" then 
    local sprite = GuiElement.add(button, GuiSprite("contraint"):sprite("helmod-tool-plus"))
    sprite.style.top_padding = -4
  end
  if self.m_contraint_icon == "exclude" then 
    local sprite = GuiElement.add(button, GuiSprite("contraint"):sprite("helmod-tool-minus"))
    sprite.style.top_padding = -4
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] appendRowLogistic
-- @return #GuiCell
--
function GuiCell:add_row_logistic(parent, element)
  local tooltip = {"tooltip.logistic-row-choose"}
  -- solid logistic
  if element.type == 0 or element.type == "item" then
    local type = User.getParameter("logistic_row_item") or "belt"
    local item_logistic = Player.getDefaultItemLogistic(type)
    local item_prototype = Product(element)
    local total_value = Format.formatNumberElement(item_prototype:countContainer(element.count, item_logistic, element.time))
    
    --local tooltip = GuiTooltipModule("tooltip.info-module"):element({type="item", name=name})
    local logistic_cell = GuiElement.add(parent, GuiFlowH("logistic-cell", item_logistic))
    GuiElement.add(logistic_cell, GuiButtonSelectSpriteSm("HMLogisticEdition", "OPEN", "item", item_logistic):sprite("entity", item_logistic):color("flat"):tooltip(tooltip))
    if element.limit_count ~= nil and element.limit_count > 0 then
      local limit_value = Format.formatNumberElement(item_prototype:countContainer(element.limit_count, item_logistic, element.time))
      GuiElement.add(logistic_cell, GuiLabel("label", item_logistic):caption({"", "x", limit_value, "/", total_value}):style("helmod_label_element"))
    else
      GuiElement.add(logistic_cell, GuiLabel("label", item_logistic):caption({"", "x", total_value}):style("helmod_label_element"))
    end
  end
  -- fluid logistic
  if element.type == 1 or element.type == "fluid" then
    local type = User.getParameter("logistic_row_fluid") or "pipe"
    local fluid_logistic = Player.getDefaultFluidLogistic(type)
    local fluid_prototype = Product(element)
    local count = element.count
    if type == "pipe" then count = count / element.time end
    local total_value = Format.formatNumberElement(fluid_prototype:countContainer(count, fluid_logistic, element.time))
    
    --local tooltip = GuiTooltipModule("tooltip.info-module"):element({type="item", name=name})
    local logistic_cell = GuiElement.add(parent, GuiFlowH("logistic-cell", fluid_logistic))
    GuiElement.add(logistic_cell, GuiButtonSelectSpriteSm("HMLogisticEdition", "OPEN", "fluid", fluid_logistic):sprite("entity", fluid_logistic):color("flat"):tooltip(tooltip))
    if element.limit_count ~= nil and element.limit_count > 0 then
      local limit_count = element.limit_count
      if type == "pipe" then limit_count = limit_count / element.time end
      local limit_value = Format.formatNumberElement(fluid_prototype:countContainer(limit_count, fluid_logistic, element.time))
      GuiElement.add(logistic_cell, GuiLabel("label", fluid_logistic):caption({"", "x", limit_value, "/", total_value}):style("helmod_label_element"))
    else
      GuiElement.add(logistic_cell, GuiLabel("label", fluid_logistic):caption({"", "x", total_value}):style("helmod_label_element"))
    end
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellFactory
--
GuiCellFactory = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- By Factory
--
-- @function [parent=#GuiCellFactory] byFactory
--
function GuiCellFactory:byFactory(...)
  self.m_by_factory = true
  self.m_by_factory_uri = table.concat({...},"=")
end

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellFactory] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellFactory:create(parent)
  local color = self.m_color or "gray"
  local factory = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(factory.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element", color, 1))

  local tooltip = GuiTooltipElement(self.options.tooltip):element(factory):withEnergy():withControlInfo(self.m_with_control_info)
  local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("entity", factory.name):tooltip(tooltip))
  
  self:add_mask(button, color)

  local cell_factory_info = GuiElement.add(row1, GuiTable("factory-info"):column(1):style("helmod_factory_info"))
  if factory.per_factory then
    local per_factory = factory.per_factory or 0
    local per_factory_constant = factory.per_factory_constant or 0
    GuiElement.add(cell_factory_info, GuiLabel("per_factory"):caption({"", "x", per_factory}):style("helmod_label_element"):tooltip({"tooltip.beacon-per-factory"}))
    GuiElement.add(cell_factory_info, GuiLabel("per_factory_constant"):caption({"", "+", per_factory_constant}):style("helmod_label_element"):tooltip({"tooltip.beacon-per-factory-constant"}))
  end

  local col_size = math.ceil(table.size(factory.modules)/2)
  if col_size < 2 then col_size = 1 end
  local cell_factory_module = GuiElement.add(row1, GuiTable("factory-modules"):column(col_size):style("helmod_factory_modules"))

  -- modules
  if factory.modules ~= nil then
    for name, count in pairs(factory.modules) do
      if count > 0 then
        local module_cell = GuiElement.add(cell_factory_module, GuiFlowH("module-cell", name))
        local tooltip = GuiTooltipModule("tooltip.info-module"):element({type="item", name=name})
        local module_icon = GuiElement.add(module_cell, GuiButtonSpriteSm("module"):sprite("item", name):tooltip(tooltip))
        
        self:add_mask(module_icon, color, 16)
        
        GuiElement.add(module_cell, GuiLabel("module-amount"):caption({"", "x", count}):style("helmod_label_element"))
      end
    end
  end

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element", color, 2))
    local limit_value = factory.limit_count or 0
    if type(factory.limit) == "number" and factory.limit > 0 then
      limit_value = factory.limit
    end
    if self.m_by_limit_uri ~= nil then
      local style = "helmod_textfield_element"
      if type(factory.limit) == "number" and factory.limit > 0 then
        style = "helmod_textfield_element_red"
      end
      local text_field = GuiElement.add(row2, GuiTextField(self.m_by_limit_uri):text(Format.formatNumberFactory(limit_value)):style(style):tooltip({"helmod_common.per-sub-block"}))
      text_field.style.height = 15
      text_field.style.width = 70
    else
      GuiElement.add(row2, GuiLabel("label2", factory.name):caption(Format.formatNumberFactory(limit_value)):style("helmod_label_element"):tooltip({"helmod_common.per-sub-block"}))
    end
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element", color, 3))
  if self.m_by_factory then
    local style = "helmod_textfield_element"
    if factory.input ~= nil then
      style = "helmod_textfield_element_red"
    end
    local text_field = GuiElement.add(row3, GuiTextField(self.m_by_factory_uri):text(Format.formatNumberFactory(factory.input or factory.count or 0)):style(style):tooltip({"helmod_common.total"}))
    text_field.style.height = 15
    text_field.style.width = 70
  else
    GuiElement.add(row3, GuiLabel("label3", factory.name):caption(Format.formatNumberFactory(factory.count)):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end
  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellRecipe
--
GuiCellRecipe = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellRecipe] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellRecipe:create(parent)
  local color = self.m_color or "gray"
  local recipe = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(recipe.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))

  local tooltip = GuiTooltipElement(self.options.tooltip):element(recipe)
  local recipe_icon = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(recipe.type, recipe.name):tooltip(tooltip))
  
  self:add_overlay(recipe_icon)
  self:add_infoIcon(recipe_icon)
  self:add_mask(recipe_icon, color)
    
  if self.m_broken == true then
    recipe_icon.tooltip = "ERROR: Recipe ".. recipe.name .." not exist in game"
    recipe_icon.sprite = "utility/warning_icon"
    row1.style = "helmod_frame_product_red_1"
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  GuiElement.add(row3, GuiLabel("label2", recipe.name):caption(Format.formatPercent(recipe.production or 1).."%"):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  return cell, recipe_icon
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellProduct
--
GuiCellProduct = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellProduct] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellProduct:create(parent)
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))

  if string.find(element.name, "helmod") then
    GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", element.hovered, element.sprite):style(element.name):tooltip({element.localised_name}))
  else
    local product_icon = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(element.type, element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip({self.options.tooltip, Player.getLocalisedName(element)}))
    self:add_mask(product_icon, color)
  end
  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(Format.formatNumber(element.count, 5)):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellProductSm
--
GuiCellProductSm = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellProductSm] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellProductSm:create(parent)
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))

  if string.find(element.name, "helmod") then
    GuiElement.add(row1, GuiButton(unpack(self.name)):style(element.name):tooltip({element.localised_name}))
  else
    GuiElement.add(row1, GuiButtonSpriteSm(unpack(self.name)):sprite(element.type, element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip({self.options.tooltip, Player.getLocalisedName(element)}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  local caption3 = Format.formatNumber(element.count, 5)
  if element.type == "energy" then caption3 = Format.formatNumberKilo(element.count, "W") end
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element_sm"):tooltip({"helmod_common.total"}))
  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellBlock
--
GuiCellBlock = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellBlock] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellBlock:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))

  local first_recipe = Model.firstRecipe(element.recipes)
  if first_recipe ~= nil then
    local tooltip = GuiTooltipElement(self.options.tooltip):element(element)
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(first_recipe.type, element.name):tooltip(tooltip))
    
    self:add_infoIcon(button, "block")
    
    GuiElement.infoRecipe(button, first_recipe)
  else
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("menu", "help-white", "help"))
    button.style.width = 36
  end

  if element.limit_count ~= nil then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_product", color, 2))
    local caption2 = Format.formatNumberFactory(element.limit_count)
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_count) end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  local caption3 = Format.formatNumberFactory(element.count)
  if display_cell_mod == "by-kilo" then caption3 = Format.formatNumberKilo(element.count) end
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellModel
--
GuiCellModel = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellModel] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellModel:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))

  local first_block = Model.firstRecipe(element.blocks)
  if first_block ~= nil then
    local tooltip = GuiTooltipModel(self.options.tooltip):element(element)
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(first_block.type, first_block.name):tooltip(tooltip))
    --self:add_infoIcon(button, "root_block")
  else
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("menu", "help-white", "help"))
    button.style.width = 36
  end
  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  local caption3 = Format.formatNumberFactory(table.size(element.blocks))
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end
-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellBlockInfo
--
GuiCellBlockInfo = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellBlockInfo] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellBlockInfo:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipBlock(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", "hangar-white", "hangar"):style("helmod_button_menu_flat"):tooltip(tooltip))

  if element.limit_count ~= nil then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_product", color, 2))
    local caption2 = Format.formatNumberFactory(element.limit_count)
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_count) end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  local caption3 = Format.formatNumberFactory(element.count)
  if display_cell_mod == "by-kilo" then caption3 = Format.formatNumberKilo(element.count) end
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellEnergy
--
GuiCellEnergy = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellEnergy] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellEnergy:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, "energy", self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipEnergyConsumption(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", "energy-white", "energy"):style("helmod_button_menu_flat"):tooltip(tooltip))

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element", color, 2))
    local caption2 = Format.formatNumberKilo(element.limit_energy or 0, "W")
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_energy) end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element", color, 3))
  local caption3 = Format.formatNumberKilo(element.energy_total or element.power, "W")
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellPollution
--
GuiCellPollution = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellPollution] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellPollution:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, "pollution", self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipPollution(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", "gas-mask-white", "gas-mask"):style("helmod_button_menu_flat"):tooltip(tooltip))

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_product", color, 2))
    local caption2 = Format.formatNumber(element.limit_pollution or 0)
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_pollution) end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  local caption3 = Format.formatNumber(element.pollution_total)
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellBuilding
--
GuiCellBuilding = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellBuilding] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellBuilding:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, "building", self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_product", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipBuilding(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", "factory-white", "factory"):style("helmod_button_menu_flat"):tooltip(tooltip))

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_product", color, 2))
    local caption2 = Format.formatNumber(element.summary.limit_building or 0)
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.summary.limit_building) end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_product", color, 3))
  local caption3 = Format.formatNumber(element.summary.building)
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellElement
--
GuiCellElement = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellElement] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellElement:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or GuiElement.color_button_none
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index or 1))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element", color, 1))

  local tooltip = ""
  if element.type == "energy" then
    tooltip = GuiTooltipEnergy(self.options.tooltip):element(element):withLogistic():withProductInfo():withControlInfo(self.m_with_control_info)
  else
    tooltip = GuiTooltipElement(self.options.tooltip):element(element):withLogistic():withProductInfo():withControlInfo(self.m_with_control_info)
  end
  local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(element.type or "entity", element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip(tooltip))
  GuiElement.infoTemperature(row1, element)
  
  if element.burnt then self:add_infoIcon(button, "burnt") end
  self:add_infoIcon(button)
  self:add_contraintIcon(button)
  self:add_mask(button, color)

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element", color, 2))
    local caption2 = Format.formatNumberElement(element.limit_count)
    if element.type == "energy" then caption2 = Format.formatNumberKilo(element.limit_count, "W") end
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_count) end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element", color, 3))
  local caption3 = Format.formatNumberElement(element.count)
  if element.type == "energy" then caption3 = Format.formatNumberKilo(element.count, "W") end
  if display_cell_mod == "by-kilo" then caption3 = Format.formatNumberKilo(element.count) end
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  if User.getParameter("display_logistic_row") == true then
    local row4 = GuiElement.add(cell, GuiFrameH("row4"):style("helmod_frame_element", color, 4))
    self:add_row_logistic(row4, element)
    GuiElement.add(row4, GuiLabel("label-empty"):caption(""):style("helmod_label_element"))
  end
  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellElementSm
--
GuiCellElementSm = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellElementSm] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellElementSm:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or GuiElement.color_button_none
  if self.m_mask == true then color = "gray" end
  local element = self.element or {}

  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_sm", color, 1))
  local tooltip = ""
  if element.type == "energy" then
    tooltip = GuiTooltipEnergy(self.options.tooltip):element(element):withLogistic():withProductInfo()
  else
    tooltip = GuiTooltipElement(self.options.tooltip):element(element):withLogistic():withProductInfo()
  end
  local button = GuiElement.add(row1, GuiButtonSpriteSm(unpack(self.name)):sprite(element.type, element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip(tooltip))
  
  self:add_mask(button, color, 16)

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element_sm", color, 2))
    local caption2 = Format.formatNumberElement(element.limit_count)
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_count) end
    if element.type == "energy" then caption2 = Format.formatNumberKilo(element.limit_count, "W") end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element_sm"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_sm", color, 3))
  local caption3 = Format.formatNumberElement(element.count)
  if display_cell_mod == "by-kilo" then caption3 = Format.formatNumberKilo(element.count) end
  if element.type == "energy" then caption3 = Format.formatNumberKilo(element.count, "W") end
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element_sm"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellElementM
--
GuiCellElementM = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellElementM] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellElementM:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or GuiElement.color_button_none
  local element = self.element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index or 1))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_m", color, 1))

  local tooltip = ""
  if element.type == "energy" then
    tooltip = GuiTooltipEnergy(self.options.tooltip):element(element):withLogistic():withProductInfo():withControlInfo(self.m_with_control_info)
  else
    tooltip = GuiTooltipElement(self.options.tooltip):element(element):withLogistic():withProductInfo():withControlInfo(self.m_with_control_info)
  end
  local button = GuiElement.add(row1, GuiButtonSpriteM(unpack(self.name)):sprite(element.type or "entity", element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip(tooltip))
  GuiElement.infoTemperature(row1, element)

  self:add_infoIcon(button)
  self:add_contraintIcon(button)
  self:add_mask(button, color)

  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element_m", color, 2))
    local caption2 = Format.formatNumberElement(element.limit_count)
    if display_cell_mod == "by-kilo" then caption2 = Format.formatNumberKilo(element.limit_count) end
    if element.type == "energy" then caption2 = Format.formatNumberKilo(element.limit_count, "W") end
    GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element_m"):tooltip({"helmod_common.total"}))
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_m", color, 3))
  local caption3 = Format.formatNumberElement(element.count)
  if display_cell_mod == "by-kilo" then caption3 = Format.formatNumberKilo(element.count) end
  if element.type == "energy" then caption3 = Format.formatNumberKilo(element.count, "W") end
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element_m"):tooltip({"helmod_common.total"}))

  return cell
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellInput
--
GuiCellInput = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCellInput] text
-- @param #string text
-- @return #GuiTextField
--
function GuiCellInput:text(text)
  self.m_text = text
  return self
end

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellInput] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellInput:create(parent)
  local cell_name = table.clone(self.name)
  table.insert(cell_name, "cell")
  local button_name = table.clone(self.name)
  table.insert(button_name, "validation")
  local cell = GuiElement.add(parent, GuiTable(unpack(cell_name)):column(2))
  local input = GuiElement.add(cell, GuiTextField(unpack(self.name)):text(self.m_text):tooltip({"tooltip.formula-allowed"}))
  local button = GuiElement.add(cell, GuiButton(unpack(button_name)):sprite("menu", "ok-white", "ok"):style("helmod_button_menu"):tooltip({"helmod_button.apply"}))
  return cell, input, button
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiCell] constructor
-- @param #arg name
-- @return #GuiCellLabel
--
GuiCellLabel = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
-- Create cell
--
-- @function [parent=#GuiCellLabel] create
--
-- @param #LuaGuiElement parent container for element
--
function GuiCellLabel:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local cell_name = table.clone(self.name)
  table.insert(cell_name, "cell")
  local cell = GuiElement.add(parent, GuiTable(unpack(cell_name)))

  if display_cell_mod == "small-text"then
    -- small
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_icon_text_sm"):tooltip({"helmod_common.total"})).style["minimal_width"] = 45
  elseif display_cell_mod == "small-icon" then
    -- small
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_icon_sm"):tooltip({"helmod_common.total"})).style["minimal_width"] = 45
  elseif display_cell_mod == "by-kilo" then
    -- by-kilo
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_row_right"):tooltip({"helmod_common.total"})).style["minimal_width"] = 50
  else
    -- default
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_row_right"):tooltip({"helmod_common.total"})).style["minimal_width"] = 60
  end
  return cell
end


