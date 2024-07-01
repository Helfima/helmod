-------------------------------------------------------------------------------
---Class to help to build GuiTooltip
---@class GuiTooltip
GuiTooltip = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Set element
---@param element table
---@return GuiTooltip
function GuiTooltip:element(element)
  self.m_element = element
  return self
end

-------------------------------------------------------------------------------
---Set with logistic information
---@return GuiTooltip
function GuiTooltip:withLogistic()
  self.m_with_logistic = true
  return self
end

-------------------------------------------------------------------------------
---Set with energy information
---@return GuiTooltip
function GuiTooltip:withEnergy()
  self.m_with_energy = true
  return self
end

-------------------------------------------------------------------------------
---Set with effect information
---@return GuiTooltip
function GuiTooltip:withEffectInfo(value)
  self.m_with_effect_info = value
  return self
end

-------------------------------------------------------------------------------
---Set with product information
---@return GuiTooltip
function GuiTooltip:withProductInfo()
  self.m_with_product_info = true
  return self
end

-------------------------------------------------------------------------------
---Set with control information
---@param control_info string
---@return GuiTooltip
function GuiTooltip:withControlInfo(control_info)
  self.m_with_control_info = control_info
  return self
end

-------------------------------------------------------------------------------
---Set by_limit information
---@param by_limit boolean
---@return GuiTooltip
function GuiTooltip:byLimit(by_limit)
  self.m_by_limit = by_limit
  return self
end

-------------------------------------------------------------------------------
---Add control information
---@param tooltip table
---@param element table
function GuiTooltip:appendControlInfo(tooltip, element)
  if self.m_with_control_info ~= nil then
    local tooltip_section = {""}
    table.insert(tooltip_section, {"", "\n", "----------------------"})
    table.insert(tooltip_section, {"", "\n", helmod_tag.font.default_bold, {"tooltip.info-control"}, helmod_tag.font.close})
    if self.m_with_control_info == "contraint" then
      table.insert(tooltip_section, {"", "\n", "[img=helmod-tooltip-blank]", " ", {"controls.contraint-plus"}})
      table.insert(tooltip_section, {"", "\n", "[img=helmod-tooltip-blank]", " ", {"controls.contraint-minus"}})
    end
    if self.m_with_control_info == "link-intermediate" then
      table.insert(tooltip_section, {"", "\n", "[img=helmod-tooltip-blank]", " ", {"controls.link-intermediate"}})
    end
    if self.m_with_control_info == "module-add" then
      table.insert(tooltip_section, {"", "\n", "[img=helmod-tooltip-blank]", " ", {"controls.module-add"}})
    end
    if self.m_with_control_info == "module-remove" then
      table.insert(tooltip_section, {"", "\n", "[img=helmod-tooltip-blank]", " ", {"controls.module-remove"}})
    end
    if self.m_with_control_info == "crafting-add" then
      table.insert(tooltip_section, {"", "\n", "[img=helmod-tooltip-blank]", " ", {"controls.crafting-add"}})
    end
    table.insert(tooltip, tooltip_section)
  end
end

-------------------------------------------------------------------------------
---Add energy information
---@param tooltip table
---@param element table
function GuiTooltip:appendEnergyConsumption(tooltip, element)
  if self.m_with_energy == true then
    ---energy
    local total_power = Format.formatNumberKilo(element.energy_total, "W")
    if self.m_by_limit then
      local limit_power = Format.formatNumberKilo(element.energy_limit, "W")
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.energy-consumption"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_power or 0, "/", total_power, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.energy-consumption"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_power or 0, helmod_tag.font.close})
    end
  end
end

-------------------------------------------------------------------------------
---Add flow information
---@param tooltip table
---@param element table
function GuiTooltip:appendFlow(tooltip, element)
  if self.m_with_logistic == true then
    if element.type == "item" then
      local item_prototype = ItemPrototype(element.name)
      local stack_size = 0
      if item_prototype ~= nil then
        stack_size = item_prototype:stackSize()
      end
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.stack-size"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, stack_size or 0, helmod_tag.font.close})      
    end

    local total_flow = Format.formatNumberElement(element.count/((element.time or 1)/60))
    if self.m_by_limit then
      local limit_flow = Format.formatNumberElement(element.count_limit/((element.time or 1)/60))
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.outflow-per-minuite"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_flow or 0, "/", total_flow, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.outflow-per-minuite"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_flow, helmod_tag.font.close})
    end
  end
end

-------------------------------------------------------------------------------
---Add flow information
---@param tooltip table
---@param element table
function GuiTooltip:appendEffectInfo(tooltip, element)
  if self.m_with_effect_info == true then
    ---energy
    local sign = ""
    if element.effects.consumption > 0 then sign = "+" end
    local energy = Format.formatNumberKilo(element.energy, "W").." ("..sign..Format.formatPercent(element.effects.consumption).."%)"
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.energy"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, energy or 0, helmod_tag.font.close})

    ---speed
    local sign = ""
    if element.effects.speed > 0 then sign = "+" end
    local speed = Format.formatNumber(element.speed).." ("..sign..Format.formatPercent(element.effects.speed).."%)"
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.speed"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, speed or 0, helmod_tag.font.close})

    ---productivity
    local sign = ""
    if element.effects.productivity > 0 then sign = "+" end
    local productivity = sign..Format.formatPercent(element.effects.productivity).."%"
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.productivity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, productivity or 0, helmod_tag.font.close})

    ---pollution
    local pollution = Format.formatNumberElement((element.pollution or 0)*60 )
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.pollution"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, pollution or 0, helmod_tag.font.close})
  end
end

-------------------------------------------------------------------------------
---Add logistic information
---@param tooltip table
---@param element table
function GuiTooltip:appendLogistic(tooltip, element)
  if self.m_with_logistic == true then
    local tooltip_section = {""}
    table.insert(tooltip_section, {"", "\n", "----------------------"})
    table.insert(tooltip_section, {"", "\n", helmod_tag.font.default_bold, {"tooltip.info-logistic"}, helmod_tag.font.close})
    ---solid logistic
    if element.type == 0 or element.type == "item" then
      for _,type in pairs({"inserter", "belt", "container", "transport"}) do
        local item_logistic = Player.getDefaultItemLogistic(type)
        local item_prototype = Product(element)
        local total_value = item_prototype:countContainer(element.count, item_logistic, element.time)
        local formated_total_value = Format.formatNumberElement(total_value)
        local info = ""
        if type == "inserter" then
          info = {"", " (", {"helmod_common.capacity"}, string.format(":%s", EntityPrototype(item_logistic):getInserterCapacity()), ")"}
        end
        if self.m_by_limit then
          local limit_value = Format.formatNumberElement(item_prototype:countContainer(element.count_limit, item_logistic, element.time))
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", item_logistic), " ", helmod_tag.font.default_bold, " x ", limit_value, "/", formated_total_value, helmod_tag.font.close, info})
        else
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", item_logistic), " ", helmod_tag.font.default_bold, " x ", formated_total_value, helmod_tag.font.close, info})
        end
      end
    end
    ---fluid logistic
    if element.type == 1 or element.type == "fluid" then
      for _,type in pairs({"pipe", "container", "transport"}) do
        local fluid_logistic = Player.getDefaultFluidLogistic(type)
        local fluid_prototype = Product(element)
        local count = element.count
        if type == "pipe" then count = count / element.time end
        local total_value = fluid_prototype:countContainer(count, fluid_logistic, element.time)
        local formated_total_value = Format.formatNumberElement(total_value)
        if self.m_by_limit then
          local limit_count = element.count_limit
          if type == "pipe" then limit_count = limit_count / element.time end
          local limit_value = Format.formatNumberElement(fluid_prototype:countContainer(limit_count, fluid_logistic, element.time))
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", fluid_logistic), " ", helmod_tag.font.default_bold, " x ", limit_value, "/", formated_total_value, helmod_tag.font.close})
        else
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", fluid_logistic), " ", helmod_tag.font.default_bold, " x ", formated_total_value, helmod_tag.font.close})
        end
      end
    end
    table.insert(tooltip, tooltip_section)
  end
end

-------------------------------------------------------------------------------
---Add product information
---@param tooltip table
---@param element table
function GuiTooltip:appendProductInfo(tooltip, element)
  if self.m_with_product_info == true then
    ---solid logistic
    if element.type == 0 or element.type == "item" then
      local item_prototype = ItemPrototype(element)
      if item_prototype:getFuelValue() > 0 then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.fuel-value"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, Format.formatNumberKilo(item_prototype:getFuelValue() or 0, "J"), helmod_tag.font.close})
      end
    end
    ---fluid logistic
    if element.type == 1 or element.type == "fluid" then
      local fluid_prototype = FluidPrototype(element)
      if fluid_prototype:getHeatCapacity() > 0  then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.heat-capacity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, fluid_prototype:getHeatCapacity() or 0, "J", helmod_tag.font.close})
      end
      if fluid_prototype:getFuelValue() > 0  then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.fuel-value"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, Format.formatNumberKilo(fluid_prototype:getFuelValue() or 0, "J"), helmod_tag.font.close})
      end
      if element.temperature then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.temperature"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.temperature or 0, "°c", helmod_tag.font.close})
      end
      if element.minimum_temperature and (element.minimum_temperature >= -1e300) then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.temperature-min"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.minimum_temperature or 0, "°c", helmod_tag.font.close})
      end
      if element.maximum_temperature and (element.maximum_temperature <= 1e300) then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.temperature-max"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.maximum_temperature or 0, "°c", helmod_tag.font.close})
      end
    end
  end
end

-------------------------------------------------------------------------------
---Add debug information
---@param tooltip table
---@param element table
function GuiTooltip:appendDebug(tooltip, element)
    ---debug     
    if User.getModGlobalSetting("debug_solver") == true then
      table.insert(tooltip, {"", "\n", "----------------------"})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Id", ": ", helmod_tag.font.default_bold, element.id or "nil", helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Name", ": ", helmod_tag.font.default_bold, element.name or "nil", helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Type", ": ", helmod_tag.font.default_bold, element.type or "nil", helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "State", ": ", helmod_tag.font.default_bold, element.state or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Amount", ": ", helmod_tag.font.default_bold, element.amount or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Count", ": ", helmod_tag.font.default_bold, element.count or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Count limit", ": ", helmod_tag.font.default_bold, element.count_limit or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Count deep", ": ", helmod_tag.font.default_bold, element.count_deep or 0, helmod_tag.font.close})
    end
end
-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltip:create()
  local tooltip = {""}
  if string.find(self.name[1], "edit[-]") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.edit)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "add[-]") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.add)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "remove[-]") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.remove)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "info[-]") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.info)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.white, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "set[-]default") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.favorite)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "apply[-]block") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.expand_right)
    table.insert(self.name, {self.options.tooltip})
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "apply[-]line") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.expand_right_group)
    table.insert(self.name, {self.options.tooltip})
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "module[-]clear") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.erase)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "pipette") then
    local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.pipette)
    table.insert(tooltip, {"", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  else
    table.insert(tooltip, {"", "[img=helmod-tooltip-blank]", " ", helmod_tag.font.default_bold, self.name, helmod_tag.font.close})
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipModel
GuiTooltipModel = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipModel:create()
  local tooltip = self._super.create(self)
  local element = self.m_element
  local first_block = element.block_root or Model.firstChild(element.blocks or {})
  if first_block ~= nil then
    local type = first_block.type
    if type == nil then type = "entity" end
    if type == "resource" or type == "energy" then type = "entity" end
    if type == "rocket" then type = "item" end
    if type == "recipe-burnt" then type = "recipe" end
    local element_sprite = GuiElement.getSprite(type, first_block.name, "[%s=%s]")
    table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=type, name=first_block.name}), helmod_tag.font.close, helmod_tag.color.close})
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_result-panel.col-header-owner"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.owner or "", helmod_tag.font.close})
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.group"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.group or "", helmod_tag.font.close})
    if element.note ~= nil and element.note ~= "" then
      table.insert(tooltip, {"", "\n", "----------------------"})
      table.insert(tooltip, {"", "\n", helmod_tag.font.default_bold, {"helmod_common.note"}, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", element.note or ""})
    end
    self:appendDebug(tooltip, element.block_root)
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipRecipe
GuiTooltipRecipe = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipRecipe:create()
  local tooltip = self._super.create(self)
  local element = self.m_element
  if element ~= nil then
    local recipe_prototype = RecipePrototype(element)
    local icon_name, icon_type = recipe_prototype:getIcon()
    local element_sprite = GuiElement.getSprite(icon_type, icon_name, "[%s=%s]")
    table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=icon_type, name=icon_name}), helmod_tag.font.close, helmod_tag.color.close})
    ---quantity
    local total_count = Format.formatNumberElement(element.count)
    if self.m_by_limit then
      local limit_count = Format.formatNumberElement(element.count_limit)
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_count or 0, "/", total_count, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_count or 0, helmod_tag.font.close})
    end
    
    self:appendProductInfo(tooltip, element);
    self:appendEnergyConsumption(tooltip, element);
    self:appendFlow(tooltip, element);
    self:appendLogistic(tooltip, element);
    self:appendControlInfo(tooltip, element);
    self:appendDebug(tooltip, element)

  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipElement
GuiTooltipElement = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipElement:create()
  local tooltip = self._super.create(self)
  local element = self.m_element
  if element ~= nil then
    local type = element.type
    if type == nil then type = "entity" end
    if type == "resource" or type == "energy" then type = "entity" end
    if type == "rocket" then type = "item" end
    if type == "recipe-burnt" then type = "recipe" end
    if type == "boiler" then type = "fluid" end
    local element_icon = GuiElement.getSprite(type, element.name, "[%s=%s]")
    table.insert(tooltip, {"", "\n", element_icon, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=type, name=element.name}), helmod_tag.font.close, helmod_tag.color.close})
    ---quantity
    local total_count = Format.formatNumberElement(element.count)
    if self.m_by_limit then
      local count_limit = Format.formatNumberElement(element.count_limit)
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, count_limit or 0, "/", total_count, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_count or 0, helmod_tag.font.close})
    end
    
    self:appendProductInfo(tooltip, element);
    self:appendEnergyConsumption(tooltip, element);
    self:appendEffectInfo(tooltip, element);
    self:appendFlow(tooltip, element);
    self:appendLogistic(tooltip, element);
    self:appendControlInfo(tooltip, element);
    self:appendDebug(tooltip, element)

  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipEnergy
GuiTooltipEnergy = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipEnergy:create()
  local tooltip = self._super.create(self)
  local element = self.m_element
  if element ~= nil then
    local type = element.type
    if type == nil then type = "entity" end
    if element == "resource" then type = "entity" end
    local element_icon = GuiElement.getSprite(type, element.name, "[%s=%s]")
    if defines.sprite_tooltips[element.name] ~= nil then
      local sprite = GuiElement.getSprite(defines.sprite_tooltips[element.name])
      element_icon = string.format("[img=%s]", sprite)
    end
    table.insert(tooltip, {"", "\n", element_icon, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=type, name=element.name}), helmod_tag.font.close, helmod_tag.color.close})
    ---quantity
    local total_count = Format.formatNumberKilo(element.count, "J")
    if self.m_by_limit then
      local limit_count = Format.formatNumberElement(element.count_limit)
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_count or 0, "/", total_count, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_count or 0, helmod_tag.font.close})
    end
    
    self:appendEnergyConsumption(tooltip, element);
    self:appendDebug(tooltip, element)
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipFactory
GuiTooltipFactory = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipFactory:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    GuiTooltipFactory.AppendFactory(tooltip, self.m_element)
  end
  return tooltip
end

function GuiTooltipFactory.AppendFactory(tooltip, element)
  local type = "entity"
  local prototype = EntityPrototype(element)
  local element_sprite = GuiElement.getSprite(type, element.name, "[%s=%s]")
  table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, prototype:getLocalisedName(), helmod_tag.font.close, helmod_tag.color.close})
  if element.combo then
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.beacon-on-factory"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.combo, helmod_tag.font.close})
  end
  if element.per_factory then
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.beacon-per-factory"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.per_factory, helmod_tag.font.close})
  end
  if element.per_factory_constant then
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.beacon-per-factory-constant"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.per_factory_constant, helmod_tag.font.close})
  end
  local fuel = prototype:getFluel()
  if fuel ~= nil then
      if fuel.temperature then
        table.insert(tooltip, {"", "\n", string.format("[%s=%s] %s °C", fuel.type, fuel.name, fuel.temperature), " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName(fuel), helmod_tag.font.close, helmod_tag.color.close})
      else
        table.insert(tooltip, {"", "\n", string.format("[%s=%s]", fuel.type, fuel.name), " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName(fuel), helmod_tag.font.close, helmod_tag.color.close})
      end
  end
  if element.module_priority then
      for _, module_priority in pairs(element.module_priority) do
      local module_prototype = ItemPrototype(module_priority.name)
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", string.format("[%s=%s]", "item", module_priority.name), " ", helmod_tag.font.default_bold, module_priority.value, " x ", helmod_tag.font.close, " ", helmod_tag.color.gold, module_prototype:getLocalisedName(), helmod_tag.color.close})
      end
  end
end

-------------------------------------------------------------------------------
---@class GuiTooltipBeacons
GuiTooltipBeacons = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipBeacons:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    for _, beacon in pairs(self.m_element) do
      local beacon_tooltip = {""}
      table.insert(tooltip, beacon_tooltip)
      GuiTooltipFactory.AppendFactory(beacon_tooltip, beacon)
    end
  end
  return tooltip
end


-------------------------------------------------------------------------------
---@class GuiTooltipEnergyConsumption
GuiTooltipEnergyConsumption = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipEnergyConsumption:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local power = Format.formatNumberKilo(self.m_element.energy_total or self.m_element.power, "J")
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.energy-consumption"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, power, helmod_tag.font.close})
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipPollution
GuiTooltipPollution = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipPollution:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local pollution = self.m_element.pollution or 0
    local total_pollution = Format.formatNumberElement(pollution)
    local total_flow = Format.formatNumberElement(pollution/((self.m_element.time or 1)/60))
    if self.m_by_limit then
      local limit_flow = Format.formatNumberElement(self.m_element.pollution_limit/((self.m_element.time or 1)/60))
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.pollution"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_pollution, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.outflow"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_flow or 0, "/", {"helmod_si.per-minute",total_flow or 0}, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.pollution"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_pollution, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.outflow"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, {"helmod_si.per-minute",total_flow or 0}, helmod_tag.font.close})
    end
    end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipBuilding
GuiTooltipBuilding = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipBuilding:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local block = self.m_element
    local overflow = false
    if block.summary ~= nil then
      ---factories
      for _, element in pairs(block.summary.factories) do
        if #tooltip < 19 then
          local element_sprite = GuiElement.getSprite(element.type, element.name, "[%s=%s]")
          
          if self.m_by_limit then
            table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, "x ", math.ceil(element.count_limit), helmod_tag.font.close})
          else
            table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, "x ", math.ceil(element.count), helmod_tag.font.close})
          end
        else
          overflow = true
        end
      end

      ---beacons
      for _, element in pairs(block.summary.beacons) do
        if #tooltip < 19 then
          local element_sprite = GuiElement.getSprite(element.type, element.name, "[%s=%s]")
          if self.m_by_limit then
            table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, "x ", math.ceil(element.count_limit), helmod_tag.font.close})
          else
            table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, "x ", math.ceil(element.count), helmod_tag.font.close})
          end
        else
          overflow = true
        end
      end

      for _, element in pairs(block.summary.modules) do
        if #tooltip < 19 then
          local element_sprite = GuiElement.getSprite(element.type, element.name, "[%s=%s]")
          if self.m_by_limit then
            table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, "x ", math.ceil(element.count_limit), helmod_tag.font.close})
          else
            table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, "x ", math.ceil(element.count), helmod_tag.font.close})
          end
        else
          overflow = true
        end
      end
      if overflow then
        table.insert(tooltip, {"", "\n", "..."})
      end
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipBlock
GuiTooltipBlock = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipBlock:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local quantity = self.m_element.count or 0
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, quantity, helmod_tag.font.close})
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipModule
GuiTooltipModule = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipModule:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local module_prototype = ItemPrototype(self.m_element.name)
    local module = module_prototype:native()
    if module ~= nil then
      local element_sprite = GuiElement.getSprite(self.m_element.type, self.m_element.name, "[%s=%s]")
      table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, module_prototype:getLocalisedName(), helmod_tag.font.close, helmod_tag.color.close})
      local bonus_consumption = Player.getModuleBonus(module.name, "consumption")
      local bonus_speed = Player.getModuleBonus(module.name, "speed")
      local bonus_productivity = Player.getModuleBonus(module.name, "productivity")
      local bonus_pollution = Player.getModuleBonus(module.name, "pollution")

      local bonus_consumption_positive = "+"
      if bonus_consumption <= 0 then bonus_consumption_positive = "" end
      if bonus_consumption ~= 0 then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"description.consumption-bonus"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, bonus_consumption_positive, Format.formatPercent(bonus_consumption), "%", helmod_tag.font.close})
      end
      local bonus_speed_positive = "+"
      if bonus_speed <= 0 then bonus_speed_positive = "" end
      if bonus_speed ~= 0 then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"description.speed-bonus"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, bonus_speed_positive, Format.formatPercent(bonus_speed), "%", helmod_tag.font.close})
      end
      local bonus_productivity_positive = "+"
      if bonus_productivity <= 0 then bonus_productivity_positive = "" end
      if bonus_productivity ~= 0 then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"description.productivity-bonus"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, bonus_productivity_positive, Format.formatPercent(bonus_productivity), "%", helmod_tag.font.close})
      end
      local bonus_pollution_positive = "+"
      if bonus_pollution <= 0 then bonus_pollution_positive = "" end
      if bonus_pollution ~= 0 then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"description.pollution-bonus"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, bonus_pollution_positive, Format.formatPercent(bonus_pollution), "%", helmod_tag.font.close})
      end
      self:appendControlInfo(tooltip, self.m_element.name);
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipPriority
GuiTooltipPriority = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipPriority:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    for i,priority in pairs(self.m_element) do
      local module_prototype = ItemPrototype(priority.name)
      local element_sprite = GuiElement.getSprite("item", priority.name, "[%s=%s]")
      table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.font.default_bold, priority.value, " x ", helmod_tag.font.close, helmod_tag.color.gold, module_prototype:getLocalisedName(), helmod_tag.color.close})
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipPriorities
GuiTooltipPriorities = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipPriorities:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    for i,factory in pairs(self.m_element) do
      GuiTooltipPriorities.AppendPriority(tooltip, factory)
    end
  end
  return tooltip
end

function GuiTooltipPriorities.AppendPriority(tooltip, element)
  local type = "entity"
  local prototype = EntityPrototype(element)
  local element_sprite = GuiElement.getSprite(type, element.name, "[%s=%s]")
  table.insert(tooltip, {"", "\n", element_sprite, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, prototype:getLocalisedName(), helmod_tag.font.close, helmod_tag.color.close})
  if element.module_priority then
      for _, module_priority in pairs(element.module_priority) do
      local module_prototype = ItemPrototype(module_priority.name)
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", string.format("[%s=%s]", "item", module_priority.name), " ", helmod_tag.font.default_bold, module_priority.value, " x ", helmod_tag.font.close, " ", helmod_tag.color.gold, module_prototype:getLocalisedName(), helmod_tag.color.close})
      end
  end
end
