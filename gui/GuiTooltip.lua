-------------------------------------------------------------------------------
-- Class to help to build GuiTooltip
--
-- @module GuiTooltip
--

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltip
--
GuiTooltip = newclass(GuiElement,function(base,...)
  GuiElement.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] element
-- @param #table element
-- @return #GuiCell
--
function GuiTooltip:element(element)
  self.m_element = element
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] withLogistic
-- @return #GuiCell
--
function GuiTooltip:withLogistic()
  self.m_with_logistic = true
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] withEnergy
-- @return #GuiCell
--
function GuiTooltip:withEnergy()
  self.m_with_energy = true
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] withProductInfo
-- @return #GuiCell
--
function GuiTooltip:withProductInfo()
  self.m_with_product_info = true
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] withControlInfo
-- @return #GuiCell
--
function GuiTooltip:withControlInfo(control_info)
  self.m_with_control_info = control_info
  return self
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] appendControlInfo
-- @return #GuiCell
--
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
--
-- @function [parent=#GuiTooltip] appendEnergyConsumption
-- @return #GuiCell
--
function GuiTooltip:appendEnergyConsumption(tooltip, element)
  if self.m_with_energy == true then
    -- energy
    local total_power = Format.formatNumberKilo(element.energy_total, "W")
    if element.limit_energy ~= nil then
      local limit_power = Format.formatNumberKilo(element.limit_energy, "W")
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.energy-consumption"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_power or 0, "/", total_power, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.energy-consumption"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, total_power or 0, helmod_tag.font.close})
    end
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] appendFlow
-- @return #GuiCell
--
function GuiTooltip:appendFlow(tooltip, element)
  if self.m_with_logistic == true then
    local total_flow = Format.formatNumberElement(element.count/((element.time or 1)/60))
    if element.limit_count ~= nil then
      local limit_flow = Format.formatNumberElement(element.limit_count/((element.time or 1)/60))
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.outflow"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, limit_flow or 0, "/", {"helmod_si.per-minute",total_flow or 0}, helmod_tag.font.close})
    else
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.outflow"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, {"helmod_si.per-minute",total_flow or 0}, helmod_tag.font.close})
    end
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] appendLogistic
-- @return #GuiCell
--
function GuiTooltip:appendLogistic(tooltip, element)
  if self.m_with_logistic == true then
    local tooltip_section = {""}
    table.insert(tooltip_section, {"", "\n", "----------------------"})
    table.insert(tooltip_section, {"", "\n", helmod_tag.font.default_bold, {"tooltip.info-logistic"}, helmod_tag.font.close})
    -- solid logistic
    if element.type == 0 or element.type == "item" then
      for _,type in pairs({"inserter", "belt", "container", "transport"}) do
        local item_logistic = Player.getDefaultItemLogistic(type)
        local item_prototype = Product(element)
        local total_value = Format.formatNumberElement(item_prototype:countContainer(element.count, item_logistic, element.time))
        local info = ""
        if type == "inserter" then
          info = {"", " (", {"helmod_common.capacity"}, string.format(":%s", EntityPrototype(item_logistic):getInserterCapacity()), ")"}
        end
        if element.limit_count ~= nil and element.limit_count > 0 then
          local limit_value = Format.formatNumberElement(item_prototype:countContainer(element.limit_count, item_logistic, element.time))
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", item_logistic), " ", helmod_tag.font.default_bold, " x ", limit_value, "/", total_value, helmod_tag.font.close, info})
        else
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", item_logistic), " ", helmod_tag.font.default_bold, " x ", total_value, helmod_tag.font.close, info})
        end
      end
    end
    -- fluid logistic
    if element.type == 1 or element.type == "fluid" then
      for _,type in pairs({"pipe", "container", "transport"}) do
        local fluid_logistic = Player.getDefaultFluidLogistic(type)
        local fluid_prototype = Product(element)
        local count = element.count
        if type == "pipe" then count = count / element.time end
        local total_value = Format.formatNumberElement(fluid_prototype:countContainer(count, fluid_logistic, element.time))
        if element.limit_count ~= nil and element.limit_count > 0 then
          local limit_count = element.limit_count
          if type == "pipe" then limit_count = limit_count / element.time end
          local limit_value = Format.formatNumberElement(fluid_prototype:countContainer(limit_count, fluid_logistic, element.time))
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", fluid_logistic), " ", helmod_tag.font.default_bold, " x ", limit_value, "/", total_value, helmod_tag.font.close})
        else
          table.insert(tooltip_section, {"", "\n", string.format("[%s=%s]", "entity", fluid_logistic), " ", helmod_tag.font.default_bold, " x ", total_value, helmod_tag.font.close})
        end
      end
    end
    table.insert(tooltip, tooltip_section)
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] appendProductInfo
-- @return #GuiCell
--
function GuiTooltip:appendProductInfo(tooltip, element)
  if self.m_with_product_info == true then
    -- solid logistic
    if element.type == 0 or element.type == "item" then
      local item_prototype = ItemPrototype(element)
      if item_prototype:getFuelValue() > 0 then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.fuel-value"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, Format.formatNumberKilo(item_prototype:getFuelValue() or 0, "J"), helmod_tag.font.close})
      end
    end
    -- fluid logistic
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
      if element.minimum_temperature then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.temperature-min"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.minimum_temperature or 0, "°c", helmod_tag.font.close})
      end
      if element.maximum_temperature then
        table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.temperature-max"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.maximum_temperature or 0, "°c", helmod_tag.font.close})
      end
    end
  end
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] appendDebug
-- @return #GuiCell
--
function GuiTooltip:appendDebug(tooltip, element)
    -- debug     
    if User.getModGlobalSetting("debug_solver") == true then
      table.insert(tooltip, {"", "\n", "----------------------"})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Name", ": ", helmod_tag.font.default_bold, self.m_element.name or "nil", helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Type", ": ", helmod_tag.font.default_bold, self.m_element.type or "nil", helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "State", ": ", helmod_tag.font.default_bold, self.m_element.state or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Amount", ": ", helmod_tag.font.default_bold, self.m_element.amount or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Count", ": ", helmod_tag.font.default_bold, self.m_element.count or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "Count limit", ": ", helmod_tag.font.default_bold, self.m_element.limit_count or 0, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", "[img=developer]", " ", "By Time", ": ", helmod_tag.font.default_bold, self.m_element.by_time or "false", helmod_tag.font.close})
    end
end
-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltip] create
--
function GuiTooltip:create()
  local tooltip = {""}
  if string.find(self.name[1], "edit[-]") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-edit]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "add[-]") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-add]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "remove[-]") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-remove]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "info[-]") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-info]", " ", helmod_tag.color.white, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "set[-]default") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-record]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "apply[-]block") then
    table.insert(self.name, {self.options.tooltip})
    table.insert(tooltip, {"", "[img=helmod-tooltip-play]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "apply[-]line") then
    table.insert(self.name, {self.options.tooltip})
    table.insert(tooltip, {"", "[img=helmod-tooltip-end]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "module[-]clear") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-erase]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  elseif string.find(self.name[1], "pipette") then
    table.insert(tooltip, {"", "[img=helmod-tooltip-pipette]", " ", helmod_tag.color.yellow, helmod_tag.font.default_bold, self.name, helmod_tag.font.close, helmod_tag.color.close})
  else
    table.insert(tooltip, {"", "[img=helmod-tooltip-blank]", " ", helmod_tag.font.default_bold, self.name, helmod_tag.font.close})
  end
  return tooltip
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipModel
--
GuiTooltipModel = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipModel] create
--
function GuiTooltipModel:create()
  local tooltip = self._super.create(self)
  local element = self.m_element
  local first_block = Model.firstRecipe(element.blocks or {})
  if first_block ~= nil then
    local type = "recipe"
    local element_icon = string.format("[%s=%s]", type, first_block.name)
    table.insert(tooltip, {"", "\n", element_icon, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=type, name=first_block.name}), helmod_tag.font.close, helmod_tag.color.close})
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_result-panel.col-header-owner"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.owner or "", helmod_tag.font.close})
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.group"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, element.group or "", helmod_tag.font.close})
    if element.note ~= nil and element.note ~= "" then
      table.insert(tooltip, {"", "\n", "----------------------"})
      table.insert(tooltip, {"", "\n", helmod_tag.font.default_bold, {"helmod_common.note"}, helmod_tag.font.close})
      table.insert(tooltip, {"", "\n", element.note or ""})
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipElement
--
GuiTooltipElement = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipElement] create
--
function GuiTooltipElement:create()
  local tooltip = self._super.create(self)
  --self:appendContraint(tooltip, element);
  local element = self.m_element
  if element ~= nil then
    local type = element.type
    if type == "resource" or type == "energy" then type = "entity" end
    if type == "rocket" then type = "item" end
    local element_icon = string.format("[%s=%s]", type, element.name)
    if type == "energy" and (element.name == "energy" or element.name == "steam-heat") then
      element_icon = string.format("[img=helmod-%s-white]", element.name)
    end
    table.insert(tooltip, {"", "\n", element_icon, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=type, name=element.name}), helmod_tag.font.close, helmod_tag.color.close})
    -- quantity
    local total_count = Format.formatNumberElement(element.count)
    if element.limit_count ~= nil then
      local limit_count = Format.formatNumberElement(element.limit_count)
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
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipEnergy
--
GuiTooltipEnergy = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipEnergy] create
--
function GuiTooltipEnergy:create()
  local tooltip = self._super.create(self)
  local element = self.m_element
  if element ~= nil then
    local type = element.type
    if element == "resource" then type = "entity" end
    local element_icon = string.format("[%s=%s]", type, element.name)
    if element.name == "energy" or element.name == "steam-heat" then
      element_icon = string.format("[img=helmod-%s-white]", element.name)
    end
    table.insert(tooltip, {"", "\n", element_icon, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({type=type, name=element.name}), helmod_tag.font.close, helmod_tag.color.close})
    -- quantity
    local total_count = Format.formatNumberKilo(element.count, "W")
    if element.limit_count ~= nil then
      local limit_count = Format.formatNumberElement(element.limit_count)
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
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipFactory
--
GuiTooltipFactory = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipFactory] create
--
function GuiTooltipFactory:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local type = "entity"
    local prototype = EntityPrototype(self.m_element)
    table.insert(tooltip, {"", "\n", string.format("[%s=%s]", type, self.m_element.name), " ", helmod_tag.color.gold, helmod_tag.font.default_bold, prototype:getLocalisedName(), helmod_tag.font.close, helmod_tag.color.close})
    if self.m_element.combo then
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.beacon-on-factory"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, self.m_element.combo, helmod_tag.font.close})
    end
    if self.m_element.per_factory then
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.beacon-per-factory"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, self.m_element.per_factory, helmod_tag.font.close})
    end
    if self.m_element.per_factory_constant then
      table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_label.beacon-per-factory-constant"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, self.m_element.per_factory_constant, helmod_tag.font.close})
    end
    local fuel = prototype:getFluel()
    if fuel ~= nil then
      table.insert(tooltip, {"", "\n", string.format("[%s=%s]", fuel.type, fuel.name), " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName(fuel), helmod_tag.font.close, helmod_tag.color.close})
    end
  end
  return tooltip
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipEnergyConsumption
--
GuiTooltipEnergyConsumption = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipEnergyConsumption] create
--
function GuiTooltipEnergyConsumption:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local power = Format.formatNumberKilo(self.m_element.energy_total or self.m_element.power, "W")
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.energy-consumption"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, power, helmod_tag.font.close})
  end
  return tooltip
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipPollution
--
GuiTooltipPollution = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipPollution] create
--
function GuiTooltipPollution:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local total_pollution = Format.formatNumberElement(self.m_element.pollution_total)
    local total_flow = Format.formatNumberElement(self.m_element.pollution_total/((self.m_element.time or 1)/60))
    if self.m_element.limit_count ~= nil then
      local limit_flow = Format.formatNumberElement(self.m_element.limit_pollution/((self.m_element.time or 1)/60))
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
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipBuilding
--
GuiTooltipBuilding = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipBuilding] create
--
function GuiTooltipBuilding:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local block = self.m_element
    local overflow = false
    if block.summary ~= nil then
      -- factories
      for _, element in pairs(block.summary.factories) do
        if #tooltip < 19 then
          table.insert(tooltip, {"", "\n", string.format("[%s=%s]", element.type, element.name), " ", helmod_tag.font.default_bold, "x ", element.count, helmod_tag.font.close})
        else
          overflow = true
        end
      end

      -- beacons
      for _, element in pairs(block.summary.beacons) do
        if #tooltip < 19 then
          table.insert(tooltip, {"", "\n", string.format("[%s=%s]", element.type, element.name), " ", helmod_tag.font.default_bold, "x ", element.count, helmod_tag.font.close})
        else
          overflow = true
        end
      end

      for _, element in pairs(block.summary.modules) do
        if #tooltip < 19 then
          table.insert(tooltip, {"", "\n", string.format("[%s=%s]", element.type, element.name), " ", helmod_tag.font.default_bold, "x ", element.count, helmod_tag.font.close})
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
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipBlock
--
GuiTooltipBlock = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipBlock] create
--
function GuiTooltipBlock:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local quantity = self.m_element.count
    table.insert(tooltip, {"", "\n", "[img=helmod-tooltip-blank]", " ", helmod_tag.color.gold, {"helmod_common.quantity"}, ": ", helmod_tag.color.close, helmod_tag.font.default_bold, quantity, helmod_tag.font.close})
  end
  return tooltip
end

-------------------------------------------------------------------------------
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipModule
--
GuiTooltipModule = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipModule] create
--
function GuiTooltipModule:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    local module_prototype = ItemPrototype(self.m_element.name)
    local module = module_prototype:native()
    if module ~= nil then
      table.insert(tooltip, {"", "\n", string.format("[%s=%s]", self.m_element.type, self.m_element.name), " ", helmod_tag.color.gold, helmod_tag.font.default_bold, module_prototype:getLocalisedName(), helmod_tag.font.close, helmod_tag.color.close})
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
--
-- @function [parent=#GuiTooltip] constructor
-- @param #arg name
-- @return #GuiTooltipPriority
--
GuiTooltipPriority = newclass(GuiTooltip,function(base,...)
  GuiTooltip.init(base,...)
  base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
-- Create tooltip
--
-- @function [parent=#GuiTooltipModule] create
--
function GuiTooltipPriority:create()
  local tooltip = self._super.create(self)
  if self.m_element then
    for i,priority in pairs(self.m_element) do
      local module_prototype = ItemPrototype(priority.name)
      table.insert(tooltip, {"", "\n", string.format("[%s=%s]", "item", priority.name), " ", helmod_tag.font.default_bold, priority.value, " x ", helmod_tag.font.close, helmod_tag.color.gold, module_prototype:getLocalisedName(), helmod_tag.color.close})
    end
  end
  return tooltip
end
