-------------------------------------------------------------------------------
---Class to help to build GuiSlider
---@class GuiCell
GuiCell = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiCell"
end)

-------------------------------------------------------------------------------
---Set element
---@param element table
---@return GuiCell
function GuiCell:element(element)
  self.m_element = element
  return self
end

-------------------------------------------------------------------------------
---Set index
---@param index number
---@return GuiCell
function GuiCell:index(index)
  self.m_index = index
  return self
end

-------------------------------------------------------------------------------
---Set color
---@param color string
---@return GuiCell
function GuiCell:color(color)
  self.m_color = color
  return self
end

-------------------------------------------------------------------------------
---Set broken
---@param broken boolean
---@return GuiCell
function GuiCell:broken(broken)
  self.m_broken = broken
  return self
end

-------------------------------------------------------------------------------
---Set width production information
---@return GuiCell
function GuiCell:withProductInfo()
  self.m_with_product_info = true
  return self
end

-------------------------------------------------------------------------------
---Set width logistic information
---@return GuiCell
function GuiCell:withLogistic()
  self.m_with_logistic = true
  return self
end

-------------------------------------------------------------------------------
---Set icon information
---@param type string
---@return GuiCell
function GuiCell:infoIcon(type)
  self.m_info_icon = type
  return self
end

-------------------------------------------------------------------------------
---Set contraint information
---@param type string
---@return GuiCell
function GuiCell:contraintIcon(type)
  self.m_contraint_icon = type
  return self
end

-------------------------------------------------------------------------------
---Set control information
---@param control_info string
---@return GuiCell
function GuiCell:controlInfo(control_info)
  self.m_with_control_info = control_info
  return self
end

-------------------------------------------------------------------------------
---Get option when error
---@return table
function GuiCell:onErrorOptions()
  local options = self:getOptions()
  options.type = "button"
  options.style = nil
  return options
end

-------------------------------------------------------------------------------
---Set by_limit information
---@param by_limit boolean
---@return GuiCell
function GuiCell:byLimit(by_limit)
  self.m_by_limit = by_limit
  return self
end

-------------------------------------------------------------------------------
---Set by_limit information
---@return GuiCell
function GuiCell:byLimitUri(...)
  self.m_by_limit_uri = table.concat({...},"=")
  return self
end

-------------------------------------------------------------------------------
---Set overlay
---@param type string
---@param name string
---@return GuiCell
function GuiCell:overlay(type, name)
  self.m_overlay_type = type
  self.m_overlay_name = name
  return self
end

-------------------------------------------------------------------------------
---Add overlay
---@param button LuaGuiElement
function GuiCell:add_overlay(button)
  if self.m_overlay_type ~= nil then
    local sprite = GuiElement.getSprite(self.m_overlay_type, self.m_overlay_name)
    GuiElement.add(button, GuiSprite("overlay"):sprite(sprite))
  end
end

-------------------------------------------------------------------------------
---Set mask
---@param mask boolean
---@return table
function GuiCell:mask(mask)
  self.m_mask = mask
  return self
end

-------------------------------------------------------------------------------
---Add mask
---@param button LuaGuiElement
---@param color string
---@param size number
function GuiCell:add_mask(button, color, size)
  if self.m_mask == true then
    local mask_frame = GuiElement.add(button, GuiFrameH("layer-mask"):style("helmod_frame_colored", color, 5))
    mask_frame.style.width = size or 32
    mask_frame.style.height = size or 32
    mask_frame.ignored_by_interaction = true
  end
end

-------------------------------------------------------------------------------
---Add icon information
---@param button LuaGuiElement
---@param info_icon string
function GuiCell:add_infoIcon(button, info_icon)
  local type = info_icon or self.m_info_icon
  if type == nil then return end
  local sprite_name = nil
  local tooltip = nil
  if type == "recipe-burnt" then 
    tooltip = "tooltip.burnt-recipe"
    sprite_name = GuiElement.getSprite(defines.sprite_info.burnt)
  end
  if type == "rocket" then 
    tooltip = "tooltip.rocket-recipe"
    sprite_name = GuiElement.getSprite(defines.sprite_info.rocket)
  end
  if type == "fluid" then 
    tooltip = "tooltip.resource-recipe"
    sprite_name = GuiElement.getSprite(defines.sprite_info.developer)
  end
  if type == "resource" then 
    tooltip = "tooltip.resource-recipe"
    sprite_name = GuiElement.getSprite(defines.sprite_info.developer)
  end
  if type == "technology" then 
    tooltip = "tooltip.technology-recipe"
    sprite_name = GuiElement.getSprite(defines.sprite_info.education)
  end
  if type == "energy" then 
    tooltip = "tooltip.energy-recipe"
    sprite_name = GuiElement.getSprite(defines.sprite_info.energy)    
  end
  if type == "burnt" then 
    tooltip = "tooltip.burnt-product"
    sprite_name = GuiElement.getSprite(defines.sprite_info.burnt)    
  end
  if type == "block" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.block)    
  end
  if sprite_name ~= nil then
    local container = GuiElement.add(button, GuiFlow(type))
    if type == "block" then
      container.style.top_padding = 16
      container.ignored_by_interaction = true
    else
      container.style.top_padding = -4
    end

    local gui_sprite = GuiSprite("info"):sprite(sprite_name)
    if tooltip ~= nil then
      gui_sprite:tooltip({tooltip})
    end
    local sprite = GuiElement.add(container, gui_sprite)
    sprite.style.width = defines.sprite_size
    sprite.style.height = defines.sprite_size
    sprite.style.stretch_image_to_widget_size = true
  end
end

-------------------------------------------------------------------------------
---Add contraint information
---@param button LuaGuiElement
function GuiCell:add_contraintIcon(button)
  if self.m_contraint_icon == nil then return end
  local sprite_name = nil
  if self.m_contraint_icon == "linked" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.linked)
  end
  if self.m_contraint_icon == "master" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.master)
  end
  if self.m_contraint_icon == "exclude" then
    sprite_name = GuiElement.getSprite(defines.sprite_info.exclude)
  end
  if sprite_name ~= nil then
    local sprite = GuiElement.add(button, GuiSprite("contraint"):sprite(sprite_name))
    sprite.style.width = defines.sprite_size
    sprite.style.height = defines.sprite_size
    sprite.style.stretch_image_to_widget_size = true
    sprite.ignored_by_interaction = true
  end
end

-------------------------------------------------------------------------------
---Add logistic information
---@param parent LuaGuiElement
---@param element table
function GuiCell:add_row_logistic(parent, element)
  local tooltip = {"tooltip.logistic-row-choose"}
  ---solid logistic
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
  ---fluid logistic
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
---Add logistic information
---@param parent LuaGuiElement
---@param width int
---@param name string
---@param count number
---@param color string
---@param color_level int
---@param tooltip any
function GuiCell:add_row_label(parent, width, name, count, color, color_level, tooltip)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local row = GuiElement.add(parent, GuiFrameH(name):style("helmod_frame_element_w50", color, color_level))
  row.style.minimal_width=width
  row.style.height = 18
  -- total deep count
  local caption = nil
  if type(count) == "table" then
    caption = Format.formatNumberKilo(count[1], count[2])
  elseif display_cell_mod == "by-kilo" then
    caption = Format.formatNumberKilo(count)
  else
    caption = Format.formatNumber(count)
  end
  GuiElement.add(row, GuiLabel("label2", name):caption(caption):style("helmod_label_element"):tooltip(tooltip))
end

-------------------------------------------------------------------------------
---Add logistic information
---@param parent LuaGuiElement
---@param width int
---@param name string
---@param count number
---@param color string
---@param color_level int
---@param tooltip any
function GuiCell:add_row_label_m(parent, width, name, count, color, color_level, tooltip)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local row = GuiElement.add(parent, GuiFrameH(name):style("helmod_frame_element_w50", color, color_level))
  row.style.minimal_width=width
  row.style.height = 15
  -- total deep count
  local caption = nil
  if type(count) == "table" then
    caption = Format.formatNumberKilo(count[1], count[2])
  elseif display_cell_mod == "by-kilo" then
    caption = Format.formatNumberKilo(count)
  else
    caption = Format.formatNumber(count)
  end
  GuiElement.add(row, GuiLabel("label2", name):caption(caption):style("helmod_label_element_m"):tooltip(tooltip))
end

-------------------------------------------------------------------------------
---Add logistic information
---@param parent LuaGuiElement
---@param width int
---@param name string
---@param count number
---@param color string
---@param color_level int
---@param tooltip any
function GuiCell:add_row_label_sm(parent, width, name, count, color, color_level, tooltip)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local row = GuiElement.add(parent, GuiFrameH(name):style("helmod_frame_element_w50", color, color_level))
  row.style.minimal_width=width
  row.style.height = 15
  -- total deep count
  local caption = nil
  if type(count) == "table" then
    caption = Format.formatNumberKilo(count[1], count[2])
  elseif display_cell_mod == "by-kilo" then
    caption = Format.formatNumberKilo(count)
  else
    caption = Format.formatNumber(count)
  end
  GuiElement.add(row, GuiLabel("label2", name):caption(caption):style("helmod_label_element_sm"):tooltip(tooltip))
end

-------------------------------------------------------------------------------
---@class GuiCellFactory : GuiCell
GuiCellFactory = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---By Factory
function GuiCellFactory:byFactory(...)
  self.m_by_factory = true
  self.m_by_factory_uri = table.concat({...},"=")
end

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellFactory:create(parent)
  local color = self.m_color or "gray"
  local factory = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(factory.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w80", color, 1))
  row1.style.top_padding=2
  row1.style.bottom_padding=3

  local tooltip = GuiTooltipElement(self.options.tooltip):element(factory):withEnergy():withEffectInfo(factory.effects ~= nil):withControlInfo(self.m_with_control_info)
  local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("entity", factory.name):tooltip(tooltip))
  
  self:add_mask(button, color)

  local cell_factory_info = GuiElement.add(row1, GuiTable("factory-info"):column(1):style("helmod_factory_info"))
  cell_factory_info.style.margin = 0
  cell_factory_info.style.padding = 0
  if factory.per_factory then
    local per_factory = factory.per_factory or 0
    local per_factory_constant = factory.per_factory_constant or 0
    GuiElement.add(cell_factory_info, GuiLabel("per_factory"):caption({"", "x", per_factory}):style("helmod_label_element"):tooltip({"tooltip.beacon-per-factory"}))
    GuiElement.add(cell_factory_info, GuiLabel("per_factory_constant"):caption({"", "+", per_factory_constant}):style("helmod_label_element2"):tooltip({"tooltip.beacon-per-factory-constant"}))
  end

  local col_size = math.ceil(table.size(factory.modules)/2)
  if col_size < 2 then col_size = 1 end
  local cell_factory_module = GuiElement.add(row1, GuiTable("factory-modules"):column(col_size):style("helmod_factory_modules"))

  ---modules
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

  local width = 80
  if self.m_by_limit then
    local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element_w80", color, 2))
    local limit_value = factory.count_limit or factory.count
    if type(factory.limit) == "number" and factory.limit > 0 then
      limit_value = factory.limit
    end
    if self.m_by_limit_uri ~= nil then
      local style = "helmod_textfield_element"
      if type(factory.limit) == "number" and factory.limit > 0 then
        style = "helmod_textfield_element_red"
      end
      local text_field = GuiElement.add(row2, GuiTextField(self.m_by_limit_uri):text(Format.formatNumberFactory(limit_value)):style(style):tooltip({"helmod_common.per-sub-block"}))
      text_field.style.height = 16
      text_field.style.width = 70
    else
      GuiElement.add(row2, GuiLabel("label2", factory.name):caption(Format.formatNumberFactory(limit_value)):style("helmod_label_element"):tooltip({"helmod_common.per-sub-block"}))
    end
  elseif self.m_by_factory then
    local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_w80", color, 2))
    local style = "helmod_textfield_element"
    if factory.input ~= nil then
      style = "helmod_textfield_element_red"
    end
    local text_field = GuiElement.add(row3, GuiTextField(self.m_by_factory_uri):text(Format.formatNumberFactory(factory.input or factory.count or 0)):style(style):tooltip({"helmod_common.total"}))
    text_field.style.height = 16
    text_field.style.width = 70
  else
    self:add_row_label(cell, width, "row3", factory.count, color, 2, {"helmod_common.quantity"})
  end

  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label(cell, width, "row4", factory.count_deep, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellRecipe
GuiCellRecipe = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellRecipe:create(parent)
  local color = self.m_color or "gray"
  local recipe = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(recipe.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))
  row1.style.top_padding=2
  row1.style.bottom_padding=3

  local recipe_prototype = RecipePrototype(recipe)
  local icon_name, icon_type = recipe_prototype:getIcon()
  local tooltip = GuiTooltipRecipe(self.options.tooltip):element(recipe)
  local recipe_icon = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(icon_type, icon_name):tooltip(tooltip))
  
  self:add_overlay(recipe_icon)
  self:add_infoIcon(recipe_icon)
  self:add_mask(recipe_icon, color)
    
  if self.m_broken == true then
    recipe_icon.tooltip = "ERROR: Recipe ".. recipe.name .." not exist in game"
    recipe_icon.sprite = "utility/warning_icon"
    row1.style = "helmod_frame_element_w50_red_1"
  end

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_w50", color, 3))
  GuiElement.add(row3, GuiLabel("label2", recipe.name):caption(Format.formatPercent(recipe.production or 1).."%"):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  return cell, recipe_icon
end

-------------------------------------------------------------------------------
---@class GuiCellProduct
GuiCellProduct = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellProduct:create(parent)
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))

  if string.find(element.name, "helmod") then
    GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", element.hovered, element.sprite):style(element.name):tooltip({element.localised_name}))
  else
    local product_icon = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(element.type, element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip({self.options.tooltip, Player.getLocalisedName(element)}))
    self:add_mask(product_icon, color)
  end
  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_w50", color, 3))
    GuiElement.add(row3, GuiLabel("label2", element.name):caption(Format.formatNumber(element.count, 5)):style("helmod_label_element"):tooltip({"helmod_common.total"}))
  end
  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellProductSm
GuiCellProductSm = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellProductSm:create(parent)
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))

  if string.find(element.name, "helmod") then
    GuiElement.add(row1, GuiButton(unpack(self.name)):style(element.name):tooltip({element.localised_name}))
  else
    GuiElement.add(row1, GuiButtonSpriteSm(unpack(self.name)):sprite(element.type, element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip({self.options.tooltip, Player.getLocalisedName(element)}))
  end
  GuiElement.infoTemperature(row1, element)
  
  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_w50", color, 3))
    local caption3 = Format.formatNumber(element.count, 5)
    if element.type == "energy" then caption3 = Format.formatNumberKilo(element.count, "J") end
    GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element_sm"):tooltip({"helmod_common.total"}))
  end
  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellBlock : GuiCell
GuiCellBlock = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellBlock:create(parent)
  local color = self.m_color or "silver"
  ---@type BlockData
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))
  row1.style.top_padding=2
  row1.style.bottom_padding=3

  local first_recipe = Model.firstChild(element.children)
  if first_recipe ~= nil then
    local tooltip = GuiTooltipElement(self.options.tooltip):element(element)
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(first_recipe.type, element.name):tooltip(tooltip))
    
    self:add_infoIcon(button, "block")
    
    GuiElement.infoRecipe(button, first_recipe)
  else
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("menu", defines.sprites.status_help.white, defines.sprites.status_help.black))
    button.style.width = 36
  end

  local width = 50
  if self.m_by_limit then
    self:add_row_label(cell, width, "row2", element.count_limit or 0, color, 2, {"helmod_common.quantity"})
  else
    self:add_row_label(cell, width, "row2", element.count or 0, color, 2, {"helmod_common.quantity"})
  end
  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label(cell, width, "row3", element.count_deep or 0, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellBlockM : GuiCell
GuiCellBlockM = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellBlockM:create(parent)
  local color = self.m_color or "silver"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))
  row1.style.top_padding=2
  row1.style.bottom_padding=3

  local first_recipe = Model.firstChild(element.children)
  if first_recipe ~= nil then
    local tooltip = GuiTooltipElement(self.options.tooltip):element(element)
    local button = GuiElement.add(row1, GuiButtonSpriteM(unpack(self.name)):sprite(first_recipe.type, element.name):tooltip(tooltip))
    
    self:add_infoIcon(button, "block")
    
    GuiElement.infoRecipe(button, first_recipe)
  else
    local button = GuiElement.add(row1, GuiButtonSpriteM(unpack(self.name)):sprite("menu", defines.sprites.status_help.white, defines.sprites.status_help.black))
    button.style.width = 36
  end

  local width = 30
  self:add_row_label_m(cell, width, "row2", element.count or 0, color, 2, {"helmod_common.quantity"})

  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label_m(cell, width, "row3", element.count_deep or 0, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellModel
GuiCellModel = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellModel:create(parent)
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))

  local first_block = element.block_root or Model.firstChild(element.blocks)
  if first_block ~= nil and first_block.name ~= "" then
    local tooltip = GuiTooltipModel(self.options.tooltip):element(element)
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite(first_block.type, first_block.name):tooltip(tooltip))
  else
    local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("menu", defines.sprites.status_help.white, defines.sprites.status_help.black))
    button.style.width = 36
  end
  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_w50", color, 3))
  local count = 1
  local caption3 = Format.formatNumberFactory(count)
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  return cell
end
-------------------------------------------------------------------------------
---@class GuiCellBlockInfo : GuiCell
GuiCellBlockInfo = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellBlockInfo:create(parent)
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipBlock(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", defines.sprites.hangar.white, defines.sprites.hangar.black):style("helmod_button_menu_flat"):tooltip(tooltip))

  local width = 50
  if self.m_by_limit then
    self:add_row_label(cell, width, "row2", element.count_limit or 0, color, 2, {"helmod_common.quantity"})
  else
    self:add_row_label(cell, width, "row2", element.count or 0, color, 2, {"helmod_common.quantity"})
  end

  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label(cell, width, "row3", element.count_deep or 0, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellEnergy : GuiCell
GuiCellEnergy = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellEnergy:create(parent)
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, "energy", self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w80", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipEnergyConsumption(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", defines.sprites.event.white, defines.sprites.event.black):style("helmod_button_menu_flat"):tooltip(tooltip))

  local width = 80
  if self.m_by_limit then
    self:add_row_label(cell, width, "row2", {element.power_limit, "W"}, color, 2, {"helmod_common.quantity"})
  else
    self:add_row_label(cell, width, "row2", {element.power, "W"}, color, 2, {"helmod_common.quantity"})
  end

  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label(cell, width, "row3", {element.power_deep, "W"}, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellPollution : GuiCell
GuiCellPollution = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellPollution:create(parent)
  local width = 60
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, "pollution", self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4
  row1.style.minimal_width=width

  local tooltip = GuiTooltipPollution(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", defines.sprites.skull.white, defines.sprites.skull.black):style("helmod_button_menu_flat"):tooltip(tooltip))

  if self.m_by_limit then
    self:add_row_label(cell, width, "row2", element.pollution_limit, color, 2, {"helmod_common.quantity"})
  else
    self:add_row_label(cell, width, "row2", element.pollution, color, 2, {"helmod_common.quantity"})
  end
  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label(cell, width, "row3", element.pollution_deep, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellBuilding
GuiCellBuilding = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellBuilding:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local color = self.m_color or "gray"
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, "building", self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))
  row1.style.top_padding=4
  row1.style.bottom_padding=4

  local tooltip = GuiTooltipBuilding(self.options.tooltip):element(element)
  local button = GuiElement.add(row1, GuiButton(unpack(self.name)):sprite("menu", defines.sprites.factory.white, defines.sprites.factory.black):style("helmod_button_menu_flat"):tooltip(tooltip))

  local building = 0
  if element.summary ~= nil then
    building = element.summary.building or 0
  end
  local width = 50
  self:add_row_label(cell, width, "row2", building, color, 2, {"helmod_common.quantity"})

  local display_count_deep = User.getParameter("display_count_deep")
  if display_count_deep then
    self:add_row_label(cell, width, "row3", building, color, 3, {"helmod_common.total"})
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellThumbnail
GuiCellThumbnail = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellThumbnail:create(parent)
  local color = self.m_color or GuiElement.color_button_none
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index or 1))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w80", color, 1))

  local tooltip = self.options.tooltip
  local button = GuiElement.add(row1, GuiButtonSprite(unpack(self.name)):sprite("menu", element.sprite1, element.sprite2):tooltip(tooltip))
  
  local row2 = GuiElement.add(cell, GuiFrameH("row2"):style("helmod_frame_element_w80", color, 2))
  local caption2 = Format.formatNumberElement(100)
  GuiElement.add(row2, GuiLabel("label1", element.name):caption(caption2):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  local row3 = GuiElement.add(cell, GuiFrameH("row3"):style("helmod_frame_element_w80", color, 3))
  local caption3 = Format.formatNumberElement(1000)
  GuiElement.add(row3, GuiLabel("label2", element.name):caption(caption3):style("helmod_label_element"):tooltip({"helmod_common.total"}))

  local row4 = GuiElement.add(cell, GuiFrameH("row4"):style("helmod_frame_element_w80", color, 4))
  GuiElement.add(row4, GuiLabel("label-empty"):caption("XXX"):style("helmod_label_element"))
  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellElement : GuiCell
GuiCellElement = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellElement:create(parent)
  local color = self.m_color or GuiElement.color_button_none
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index or 1))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w80", color, 1))

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

  local display_count_deep = User.getParameter("display_count_deep")
  local width = 80
  if element.type == "energy" then
    if self.m_by_limit then
      self:add_row_label(cell, width, "row2", {element.count_limit or 0, "J"}, color, 2, {"helmod_common.quantity"})
    else
      self:add_row_label(cell, width, "row2", {element.count or 0, "J"}, color, 2, {"helmod_common.quantity"})
    end
    if display_count_deep then
      self:add_row_label(cell, width, "row3", {element.count_deep or 0, "J"}, color, 3, {"helmod_common.total"})
    end
  else
    if self.m_by_limit then
      self:add_row_label(cell, width, "row2", element.count_limit or 0, color, 2, {"helmod_common.quantity"})
    else
      self:add_row_label(cell, width, "row2", element.count or 0, color, 2, {"helmod_common.quantity"})
    end
    if display_count_deep then
      self:add_row_label(cell, width, "row3", element.count_deep or 0, color, 3, {"helmod_common.total"})
    end
  end

  if User.getParameter("display_logistic_row") == true then
    local row4 = GuiElement.add(cell, GuiFrameH("row5"):style("helmod_frame_element_w80", color, 4))
    self:add_row_logistic(row4, element)
    GuiElement.add(row4, GuiLabel("label-empty"):caption(""):style("helmod_label_element"))
  end
  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellElementSm : GuiCell
GuiCellElementSm = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellElementSm:create(parent)
  local color = self.m_color or GuiElement.color_button_none
  if self.m_mask == true then color = "gray" end
  local element = self.m_element or {}

  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w30", color, 1))
  local tooltip = ""
  if element.type == "energy" then
    tooltip = GuiTooltipEnergy(self.options.tooltip):element(element):withLogistic():withProductInfo()
  else
    tooltip = GuiTooltipElement(self.options.tooltip):element(element):withLogistic():withProductInfo()
  end
  local button = GuiElement.add(row1, GuiButtonSpriteSm(unpack(self.name)):sprite(element.type, element.name):index(Product(element):getTableKey()):caption("X"..Product(element):getElementAmount()):tooltip(tooltip))
  
  self:add_mask(button, color, 16)

  local display_count_deep = User.getParameter("display_count_deep")
  local width = 30
  if element.type == "energy" then
    if self.m_by_limit then
      self:add_row_label_sm(cell, width, "row2", {element.count_limit or 0, "J"}, color, 2, {"helmod_common.quantity"})
    else
      self:add_row_label_sm(cell, width, "row2", {element.count or 0, "J"}, color, 2, {"helmod_common.quantity"})
    end
    if display_count_deep then
      self:add_row_label_sm(cell, width, "row3", {element.count_deep or 0, "J"}, color, 3, {"helmod_common.total"})
    end
  else
    if self.m_by_limit then
      self:add_row_label_sm(cell, width, "row2", element.count_limit or 0, color, 2, {"helmod_common.quantity"})
    else
      self:add_row_label_sm(cell, width, "row2", element.count or 0, color, 2, {"helmod_common.quantity"})
    end
    if display_count_deep then
      self:add_row_label_sm(cell, width, "row3", element.count_deep or 0, color, 3, {"helmod_common.total"})
    end
  end
  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellElementM : GuiCell
GuiCellElementM = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellElementM:create(parent)
  local color = self.m_color or GuiElement.color_button_none
  local element = self.m_element or {}
  local cell = GuiElement.add(parent, GuiFlowV(element.name, self.m_index or 1))
  local row1 = GuiElement.add(cell, GuiFrameH("row1"):style("helmod_frame_element_w50", color, 1))

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

  local display_count_deep = User.getParameter("display_count_deep")
  local width = 50
  if element.type == "energy" then
    if self.m_by_limit then
      self:add_row_label_m(cell, width, "row2", {element.count_limit or 0, "J"}, color, 2, {"helmod_common.quantity"})
    else
      self:add_row_label_m(cell, width, "row2", {element.count or 0, "J"}, color, 2, {"helmod_common.quantity"})
    end
    if display_count_deep then
      self:add_row_label_m(cell, width, "row3", {element.count_deep or 0, "J"}, color, 3, {"helmod_common.total"})
    end
  else
    if self.m_by_limit then
      self:add_row_label_m(cell, width, "row2", element.count_limit or 0, color, 2, {"helmod_common.quantity"})
    else
      self:add_row_label_m(cell, width, "row2", element.count or 0, color, 2, {"helmod_common.quantity"})
    end
    if display_count_deep then
      self:add_row_label_m(cell, width, "row3", element.count_deep or 0, color, 3, {"helmod_common.total"})
    end
  end

  return cell
end

-------------------------------------------------------------------------------
---@class GuiCellInput
GuiCellInput = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Set text
---@return GuiCellInput
function GuiCellInput:text(text)
  self.m_text = text
  return self
end

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellInput:create(parent)
  local cell_name = table.clone(self.name)
  table.insert(cell_name, "cell")
  local button_name = table.clone(self.name)
  table.insert(button_name, "validation")
  local cell = GuiElement.add(parent, GuiTable(unpack(cell_name)):column(2))
  local input = GuiElement.add(cell, GuiTextField(unpack(self.name)):text(self.m_text):tooltip({"tooltip.formula-allowed"}))
  local button = GuiElement.add(cell, GuiButton(unpack(button_name)):sprite("menu", defines.sprites.status_ok.white, defines.sprites.status_ok.black):style("helmod_button_menu"):tooltip({"helmod_button.apply"}))
  return cell, input, button
end

-------------------------------------------------------------------------------
---@class GuiCellLabel
GuiCellLabel = newclass(GuiCell,function(base,...)
  GuiCell.init(base,...)
end)

-------------------------------------------------------------------------------
---Create cell
---@param parent LuaGuiElement --container for element
---@return LuaGuiElement
function GuiCellLabel:create(parent)
  local display_cell_mod = User.getModSetting("display_cell_mod")
  local cell_name = table.clone(self.name)
  table.insert(cell_name, "cell")
  local cell = GuiElement.add(parent, GuiTable(unpack(cell_name)))

  if display_cell_mod == "small-text"then
    ---small
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_icon_text_sm"):tooltip({"helmod_common.total"})).style["minimal_width"] = 45
  elseif display_cell_mod == "small-icon" then
    ---small
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_icon_sm"):tooltip({"helmod_common.total"})).style["minimal_width"] = 45
  elseif display_cell_mod == "by-kilo" then
    ---by-kilo
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_row_right"):tooltip({"helmod_common.total"})).style["minimal_width"] = 50
  else
    ---default
    GuiElement.add(cell, GuiLabel("label1"):caption(self.m_caption):style("helmod_label_row_right"):tooltip({"helmod_common.total"})).style["minimal_width"] = 60
  end
  return cell
end