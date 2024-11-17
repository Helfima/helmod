-------------------------------------------------------------------------------
---Class to help to build GuiTooltip
---@class GuiTooltip : GuiElement
GuiTooltip = newclass(GuiElement, function(base, ...)
	GuiElement.init(base, ...)
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
---Append title line
---@param tooltip table
---@param element_type string
---@param element_name string
---@param element_label any
---@param element_quality? string
function GuiTooltip.appendLineTitle(tooltip, element_type, element_name, element_label, element_quality)
	local noQuality = true
	if Player.hasFeatureQuality() and element_quality ~= nil then
		local quality = Player.getQualityPrototype(element_quality)
		if quality ~= nil and quality.level > 0 then
			local localised_name = quality.localised_name
			local color = quality.color
			local color_tag = GuiElement.rgbColorTag(color)
			local element_sprite = GuiElement.getSpriteWithQuality(element_type, element_name, element_quality)
			table.insert(tooltip, { "", "\n", element_sprite, " ", helmod_tag.font.default_bold
				, helmod_tag.color.gold, element_label, helmod_tag.color.close
				, color_tag, " (", localised_name, ")", helmod_tag.color.close
				, helmod_tag.font.close
			})
			noQuality = false
		end
	end
	if noQuality then
		local element_sprite = GuiElement.getSprite(element_type, element_name, "[%s=%s]")
		table.insert(tooltip, { "", "\n", element_sprite, " ", helmod_tag.font.default_bold
			, helmod_tag.color.gold, element_label, helmod_tag.color.close
			, helmod_tag.font.close
		})
	end
end

-------------------------------------------------------------------------------
---Append title line
---@param tooltip table
---@param element_type string
---@param element_name string
---@param element_amount number
---@param element_label any
---@param element_quality? string
function GuiTooltip.appendLineQuantity(tooltip, element_type, element_name, element_amount, element_label, element_quality)
	local noQuality = true
	if Player.hasFeatureQuality() and element_quality ~= nil then
		local quality = Player.getQualityPrototype(element_quality)
		if quality ~= nil and quality.level > 0 then
			local localised_name = quality.localised_name
			local color = quality.color
			local color_tag = GuiElement.rgbColorTag(color)
			local element_sprite = GuiElement.getSpriteWithQuality(element_type, element_name, element_quality)
			table.insert(tooltip, { "", "\n", element_sprite, " "
				, helmod_tag.font.default_bold
				, helmod_tag.color.white, element_amount, helmod_tag.color.close
				, helmod_tag.font.close
				, " x ", helmod_tag.color.gold, element_label, helmod_tag.color.close
				, color_tag, " (", localised_name, ")", helmod_tag.color.close
			})
			noQuality = false
		end
	end
	if noQuality then
		local element_sprite = GuiElement.getSprite(element_type, element_name, "[%s=%s]")
		table.insert(tooltip, { "", "\n", element_sprite, " "
			, helmod_tag.font.default_bold
			, helmod_tag.color.white, element_amount, helmod_tag.color.close
			, helmod_tag.font.close
			, " x ", helmod_tag.color.gold, element_label, helmod_tag.color.close
		})
	end
end

-------------------------------------------------------------------------------
---Append title line
---@param tooltip table
---@param element_type string
---@param element_name string
---@param element_amount number
---@param element_label any
---@param element_quality? string
function GuiTooltip.appendLineSubQuantity(tooltip, element_type, element_name, element_amount, element_label, element_quality)
	local noQuality = true
	if Player.hasFeatureQuality() and element_quality ~= nil then
		local quality = Player.getQualityPrototype(element_quality)
		if quality ~= nil and quality.level > 0 then
			local localised_name = quality.localised_name
			local color = quality.color
			local color_tag = GuiElement.rgbColorTag(color)
			local element_sprite = GuiElement.getSpriteWithQuality(element_type, element_name, element_quality)
			table.insert(tooltip, { "", "\n", "[img=helmod-tooltip-blank]", " "
				, element_sprite
				, helmod_tag.font.default_bold
				, helmod_tag.color.white, " ", element_amount, helmod_tag.color.close
				, helmod_tag.font.close
				, " x ", helmod_tag.color.gold, element_label, helmod_tag.color.close
				, color_tag, " (", localised_name, ")", helmod_tag.color.close
			})
			noQuality = false
		end
	end
	if noQuality then
		local element_sprite = GuiElement.getSprite(element_type, element_name, "[%s=%s]")
		table.insert(tooltip, { "", "\n", "[img=helmod-tooltip-blank]", " "
			, element_sprite
			, helmod_tag.font.default_bold
			, helmod_tag.color.white, " ", element_amount, helmod_tag.color.close
			, helmod_tag.font.close
			, " x ", helmod_tag.color.gold, element_label, helmod_tag.color.close
		})
	end
end
-------------------------------------------------------------------------------
---Add tooltip line
---@param tooltip table
---@param icon string | nil
---@param label any
---@param value1 any
---@param value2? any
function GuiTooltip.appendLine(tooltip, icon, label, value1, value2)
	if icon == nil then
		icon = "[img=helmod-tooltip-blank]"
	end
	if value2 == nil then
		table.insert(tooltip, { "", "\n", icon, " "
			, helmod_tag.color.gold, label, ": ", helmod_tag.color.close
			, helmod_tag.font.default_bold, value1 or 0, helmod_tag.font.close
		})
	else
		table.insert(tooltip, { "", "\n", icon, " "
			, helmod_tag.color.gold, label, ": ", helmod_tag.color.close
			, helmod_tag.font.default_bold, value1 or 0, "/", value2, helmod_tag.font.close
		})
	end
end

-------------------------------------------------------------------------------
---Add control information
---@param tooltip table
---@param element table
function GuiTooltip:appendControlInfo(tooltip, element)
	if self.m_with_control_info ~= nil then
		local tooltip_section = { "" }
		table.insert(tooltip_section, { "", "\n", "----------------------" })
		table.insert(tooltip_section, { "", "\n", helmod_tag.font.default_bold, { "tooltip.info-control" }, helmod_tag.font.close })
		if self.m_with_control_info == "contraint" then
			table.insert(tooltip_section, { "", "\n", "[img=helmod-tooltip-blank]", " ", { "controls.contraint-plus" } })
			table.insert(tooltip_section, { "", "\n", "[img=helmod-tooltip-blank]", " ", { "controls.contraint-minus" } })
		end
		if self.m_with_control_info == "link-intermediate" then
			table.insert(tooltip_section, { "", "\n", "[img=helmod-tooltip-blank]", " ", { "controls.link-intermediate" } })
		end
		if self.m_with_control_info == "module-add" then
			table.insert(tooltip_section, { "", "\n", "[img=helmod-tooltip-blank]", " ", { "controls.module-add" } })
		end
		if self.m_with_control_info == "module-remove" then
			table.insert(tooltip_section, { "", "\n", "[img=helmod-tooltip-blank]", " ", { "controls.module-remove" } })
		end
		if self.m_with_control_info == "crafting-add" then
			table.insert(tooltip_section, { "", "\n", "[img=helmod-tooltip-blank]", " ", { "controls.crafting-add" } })
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
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.energy-consumption" }, limit_power, total_power)
		else
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.energy-consumption" }, total_power)
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
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.stack-size" }, stack_size)
		end

		local total_flow = Format.formatNumberElement(element.count / ((element.time or 1) / 60))
		if self.m_by_limit then
			local limit_flow = Format.formatNumberElement(element.count_limit / ((element.time or 1) / 60))
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.outflow-per-minute" }, limit_flow, total_flow)
		else
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.outflow-per-minute" }, total_flow)
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
		local energy = Format.formatNumberKilo(element.energy, "W") .." (" .. sign .. Format.formatPercent(element.effects.consumption) .. "%)"
		
		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.energy" }, energy)

		---speed
		local sign = ""
		if element.effects.speed > 0 then sign = "+" end
		local speed = Format.formatNumber(element.speed) .. " (" ..
		sign .. Format.formatPercent(element.effects.speed) .. "%)"

		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.speed" }, speed)

		---productivity
		local sign = ""
		if element.effects.productivity > 0 then sign = "+" end
		local productivity = sign .. Format.formatPercent(element.effects.productivity) .. "%"

		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.productivity" }, productivity)

		---quality
		if Player.hasFeatureQuality() then
			if element.effects.quality == nil then element.effects.quality = 0 end
			local sign = ""
			if element.effects.quality > 0 then sign = "+" end
			local quality = sign .. Format.formatPercent(element.effects.quality) .. "%"
			
			GuiTooltip.appendLine(tooltip, nil, { "helmod_label.quality" }, quality)
		end

		---pollution
		local pollution = Format.formatNumberElement((element.pollution or 0) * 60)
		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.pollution" }, pollution)
	end
end

-------------------------------------------------------------------------------
---Add logistic information
---@param tooltip table
---@param element table
function GuiTooltip.appendQuality(tooltip, element)
	if Player.hasFeatureQuality() and element.quality ~= nil then
		local quality = Player.getQualityPrototype(element.quality)
		if quality ~= nil and quality.level > 0 then
			local localised_name = quality.localised_name
			local color = quality.color
			local color_tag = GuiElement.rgbColorTag(color)
			table.insert(tooltip,
				{ "", "\n", string.format("[%s=%s]", "quality", element.quality), " ", helmod_tag.font.default_bold,
					color_tag, localised_name, helmod_tag.color.close, helmod_tag.font.close })
		end
	end
end

-------------------------------------------------------------------------------
---Add logistic information
---@param tooltip table
---@param element table
function GuiTooltip:appendLogistic(tooltip, element)
	if self.m_with_logistic == true then
		local tooltip_section = { "" }
		table.insert(tooltip_section, { "", "\n", "----------------------" })
		table.insert(tooltip_section,
			{ "", "\n", helmod_tag.font.default_bold, { "tooltip.info-logistic" }, helmod_tag.font.close })
		---solid logistic
		if element.type == 0 or element.type == "item" then
			for _, type in pairs({ "inserter", "belt", "container", "transport" }) do
				local item_logistic = Player.getDefaultItemLogistic(type)
				local item_prototype = Product(element)
				local total_value = item_prototype:countContainer(element.count, item_logistic, element.time)
				local formated_total_value = Format.formatNumberElement(total_value)
				local info = ""
				if type == "inserter" then
					info = { "", " (", { "helmod_common.capacity" }, string.format(":%s",
						EntityPrototype(item_logistic):getInserterCapacity()), ")" }
				end
				if self.m_by_limit then
					local limit_value = Format.formatNumberElement(item_prototype:countContainer(element.count_limit,
						item_logistic, element.time))
					table.insert(tooltip_section,
						{ "", "\n", string.format("[%s=%s]", "entity", item_logistic), " ", helmod_tag.font.default_bold,
							" x ", limit_value, "/", formated_total_value, helmod_tag.font.close, info })
				else
					table.insert(tooltip_section,
						{ "", "\n", string.format("[%s=%s]", "entity", item_logistic), " ", helmod_tag.font.default_bold,
							" x ", formated_total_value, helmod_tag.font.close, info })
				end
			end
		end
		---fluid logistic
		if element.type == 1 or element.type == "fluid" then
			for _, type in pairs({ "pipe", "container", "transport" }) do
				local fluid_logistic = Player.getDefaultFluidLogistic(type)
				local fluid_prototype = Product(element)
				local count = element.count
				if type == "pipe" then count = count / element.time end
				local total_value = fluid_prototype:countContainer(count, fluid_logistic, element.time)
				local formated_total_value = Format.formatNumberElement(total_value)
				if self.m_by_limit then
					local limit_count = element.count_limit
					if type == "pipe" then limit_count = limit_count / element.time end
					local limit_value = Format.formatNumberElement(fluid_prototype:countContainer(limit_count,
						fluid_logistic, element.time))
					table.insert(tooltip_section,
						{ "", "\n", string.format("[%s=%s]", "entity", fluid_logistic), " ", helmod_tag.font
							.default_bold, " x ", limit_value, "/", formated_total_value, helmod_tag.font.close })
				else
					table.insert(tooltip_section,
						{ "", "\n", string.format("[%s=%s]", "entity", fluid_logistic), " ", helmod_tag.font
							.default_bold, " x ", formated_total_value, helmod_tag.font.close })
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
				local value = Format.formatNumberKilo(item_prototype:getFuelValue() or 0, "J")
				GuiTooltip.appendLine(tooltip, nil, { "helmod_common.fuel-value" }, value)
			end
		end
		---fluid logistic
		if element.type == 1 or element.type == "fluid" then
			local fluid_prototype = FluidPrototype(element)
			if fluid_prototype:getHeatCapacity() > 0 then
				local value = (fluid_prototype:getHeatCapacity() or 0) .. "J"
				GuiTooltip.appendLine(tooltip, nil, { "helmod_common.heat-capacity" }, value)
			end
			if fluid_prototype:getFuelValue() > 0 then
				local value = Format.formatNumberKilo(fluid_prototype:getFuelValue() or 0, "J")
				GuiTooltip.appendLine(tooltip, nil, { "helmod_common.fuel-value" }, value)
			end
			if element.temperature then
				local value = (element.temperature or 0) .. "°c"
				GuiTooltip.appendLine(tooltip, nil, { "helmod_common.temperature" }, value)
			end
			if element.minimum_temperature and (element.minimum_temperature >= -1e300) then
				local value = (element.minimum_temperature or 0) .. "°c"
				GuiTooltip.appendLine(tooltip, nil, { "helmod_common.temperature-min" }, value)
			end
			if element.maximum_temperature and (element.maximum_temperature <= 1e300) then
				local value = (element.maximum_temperature or 0) .. "°c"
				GuiTooltip.appendLine(tooltip, nil, { "helmod_common.temperature-max" }, value)
			end
		end
	end
end

-------------------------------------------------------------------------------
---Add tooltip line
---@param tooltip table
---@param label any
---@param value any
function GuiTooltip.appendLineDebug(tooltip, label, value)
	local icon = "[img=developer]"
	table.insert(tooltip, { "", "\n", icon, " "
		, helmod_tag.color.white, label, ": ", helmod_tag.color.close
		, helmod_tag.font.default_bold, value or "nil", helmod_tag.font.close
	})
end

-------------------------------------------------------------------------------
---Add debug information
---@param tooltip table
---@param element table
function GuiTooltip:appendDebug(tooltip, element)
	---debug
	if User.getModGlobalSetting("debug_solver") == true then
		table.insert(tooltip, { "", "\n", "----------------------" })
		GuiTooltip.appendLineDebug(tooltip, "Id", element.id)
		GuiTooltip.appendLineDebug(tooltip, "Name", element.name)
		GuiTooltip.appendLineDebug(tooltip, "Type", element.type)
		GuiTooltip.appendLineDebug(tooltip, "State", element.state)
		GuiTooltip.appendLineDebug(tooltip, "Amount", element.amount)
		GuiTooltip.appendLineDebug(tooltip, "Count", element.count)
		GuiTooltip.appendLineDebug(tooltip, "Count limit", element.count_limit)
		GuiTooltip.appendLineDebug(tooltip, "Count deep", element.count_deep)
	end
end

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltip:create()
	local tooltip = { "" }
	if string.find(self.name[1], "edit[-]") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.edit)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "add[-]") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.add)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "remove[-]") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.remove)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "info[-]") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.info)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.white, helmod_tag.font.default_bold, self
				.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "set[-]default") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.favorite)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "apply[-]block") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.expand_right)
		table.insert(self.name, { self.options.tooltip })
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "apply[-]line") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.expand_right_group)
		table.insert(self.name, { self.options.tooltip })
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "module[-]clear") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.erase)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	elseif string.find(self.name[1], "pipette") then
		local sprite_name = GuiElement.getSprite(defines.sprite_tooltip.pipette)
		table.insert(tooltip,
			{ "", string.format("[img=%s]", sprite_name), " ", helmod_tag.color.yellow, helmod_tag.font.default_bold,
				self.name, helmod_tag.font.close, helmod_tag.color.close })
	else
		table.insert(tooltip,
			{ "", "[img=helmod-tooltip-blank]", " ", helmod_tag.font.default_bold, self.name, helmod_tag.font.close })
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipModel : GuiTooltip
GuiTooltipModel = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
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
		
		local element_label = Player.getLocalisedName({ type = type, name = first_block.name })
		GuiTooltip.appendLineTitle(tooltip, type, first_block.name, element_label)
		
		GuiTooltip.appendLine(tooltip, nil, { "helmod_result-panel.col-header-owner" }, element.owner)
		GuiTooltip.appendLine(tooltip, nil, { "helmod_common.group" }, element.group or "")
		
		if element.note ~= nil and element.note ~= "" then
			table.insert(tooltip, { "", "\n", "----------------------" })
			table.insert(tooltip, { "", "\n", helmod_tag.font.default_bold, { "helmod_common.note" }, helmod_tag.font
				.close })
			table.insert(tooltip, { "", "\n", element.note or "" })
		end
		self:appendDebug(tooltip, element.block_root)
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipRecipe : GuiTooltip
GuiTooltipRecipe = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
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

		local element_label = Player.getLocalisedName({ type = icon_type, name = icon_name })
		GuiTooltip.appendLineTitle(tooltip, icon_type, icon_name, element_label, self.m_element.quality)
		
		---quantity
		local total_count = Format.formatNumberElement(element.count)
		if self.m_by_limit then
			local limit_count = Format.formatNumberElement(element.count_limit)
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, limit_count, total_count)
		else
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, total_count)
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
---@class GuiTooltipElement : GuiTooltip
GuiTooltipElement = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
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

		local element_label = Player.getLocalisedName({ type = type, name = element.name })
		GuiTooltip.appendLineTitle(tooltip, type, element.name, element_label, element.quality)

		---quantity
		local total_count = Format.formatNumberElement(element.count)
		if self.m_by_limit then
			local limit_count = Format.formatNumberElement(element.count_limit)
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, limit_count, total_count)
		else
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, total_count)
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
---@class GuiTooltipEnergy : GuiTooltip
GuiTooltipEnergy = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
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

		table.insert(tooltip,
			{ "", "\n", element_icon, " ", helmod_tag.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName({ type =
			type, name = element.name }), helmod_tag.font.close, helmod_tag.color.close })
		---quantity
		local total_count = Format.formatNumberKilo(element.count, "J")
		if self.m_by_limit then
			local limit_count = Format.formatNumberElement(element.count_limit)
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, limit_count, total_count)
		else
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, total_count)
		end

		self:appendEnergyConsumption(tooltip, element);
		self:appendDebug(tooltip, element)
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipFactory : GuiTooltip
GuiTooltipFactory = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
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


-------------------------------------------------------------------------------
---Append factory informations
---@param tooltip table
---@param element table
function GuiTooltipFactory.AppendFactory(tooltip, element)
	local prototype = EntityPrototype(element)
	local type = "entity"

	GuiTooltip.appendLineTitle(tooltip, type, element.name, prototype:getLocalisedName(), element.quality)

	if element.combo then
		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.beacon-on-factory" }, element.combo)
	end
	if element.per_factory then
		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.beacon-per-factory" }, element.per_factory)
	end
	if element.per_factory_constant then
		GuiTooltip.appendLine(tooltip, nil, { "helmod_label.beacon-per-factory-constant" }, element.per_faper_factory_constantctory)
	end
	local fuel = prototype:getFluel()
	if fuel ~= nil then
		if fuel.temperature then
			table.insert(tooltip,
				{ "", "\n", string.format("[%s=%s] %s °C", fuel.type, fuel.name, fuel.temperature), " ", helmod_tag
					.color.gold, helmod_tag.font.default_bold, Player.getLocalisedName(fuel), helmod_tag.font.close,
					helmod_tag.color.close })
		else
			table.insert(tooltip,
				{ "", "\n", string.format("[%s=%s]", fuel.type, fuel.name), " ", helmod_tag.color.gold, helmod_tag.font
					.default_bold, Player.getLocalisedName(fuel), helmod_tag.font.close, helmod_tag.color.close })
		end
	end
	if element.module_priority then
		for _, module_priority in pairs(element.module_priority) do
			local type = "item"
			local module_prototype = ItemPrototype(module_priority.name)
			local module_priority_label = module_prototype:getLocalisedName()
			local amount = module_priority.amount or 0

			GuiTooltip.appendLineSubQuantity(tooltip, type, module_priority.name, amount, module_priority_label, module_priority.quality)
		end
	end
end

-------------------------------------------------------------------------------
---@class GuiTooltipBeacons : GuiTooltip
GuiTooltipBeacons = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipBeacons:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		for _, beacon in pairs(self.m_element) do
			local beacon_tooltip = { "" }
			table.insert(tooltip, beacon_tooltip)
			GuiTooltipFactory.AppendFactory(beacon_tooltip, beacon)
		end
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipEnergyConsumption : GuiTooltip
GuiTooltipEnergyConsumption = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipEnergyConsumption:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		local power = "0W"
		if self.m_by_limit then
			power = Format.formatNumberKilo(self.m_element.energy_total or self.m_element.power_limit, "W")
		else
			power = Format.formatNumberKilo(self.m_element.energy_total or self.m_element.power, "W")
		end
		GuiTooltip.appendLine(tooltip, nil, { "helmod_common.energy-consumption" }, power)
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipPollution : GuiTooltip
GuiTooltipPollution = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipPollution:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		local pollution = self.m_element.pollution or 0
		local pollution_limit = self.m_element.pollution_limit or 0
		local total_pollution = Format.formatNumberElement(pollution)
		local limit_pollution = Format.formatNumberElement(pollution_limit)
		local total_flow = Format.formatNumberElement(pollution / ((self.m_element.time or 1) / 60))
		if self.m_by_limit then
			local limit_flow = Format.formatNumberElement(pollution_limit / ((self.m_element.time or 1) / 60))
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.pollution" }, limit_pollution)
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.outflow-per-minute" }, limit_flow or 0, total_flow)
		else
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.pollution" }, total_pollution)
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.outflow-per-minute" }, total_flow)
		end
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipBuilding : GuiTooltip
GuiTooltipBuilding = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
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
					local amount = math.ceil(element.count)
					if self.m_by_limit then
						amount = math.ceil(element.count_limit)
					end
					local element_label = Player.getLocalisedName({ type = element.type, name = element.name })
					GuiTooltip.appendLineQuantity(tooltip, element.type, element.name, amount, element_label, element.quality)
				else
					overflow = true
				end
			end

			---beacons
			for _, element in pairs(block.summary.beacons) do
				if #tooltip < 19 then
					local amount = math.ceil(element.count)
					if self.m_by_limit then
						amount = math.ceil(element.count_limit)
					end
					local element_label = Player.getLocalisedName({ type = element.type, name = element.name })
					GuiTooltip.appendLineQuantity(tooltip, element.type, element.name, amount, element_label, element.quality)
				else
					overflow = true
				end
			end

			for _, element in pairs(block.summary.modules) do
				if #tooltip < 19 then
					local amount = math.ceil(element.count)
					if self.m_by_limit then
						amount = math.ceil(element.count_limit)
					end
					local element_label = Player.getLocalisedName({ type = element.type, name = element.name })
					GuiTooltip.appendLineQuantity(tooltip, element.type, element.name, amount, element_label, element.quality)
				else
					overflow = true
				end
			end
			if overflow then
				table.insert(tooltip, { "", "\n", "..." })
			end
		end
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipBlock : GuiTooltip
GuiTooltipBlock = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipBlock:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		local quantity = self.m_element.count or 0
		if self.m_by_limit then
			local quantity = self.m_element.count_limit or 0
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, quantity)
		else
			local quantity = self.m_element.count or 0
			GuiTooltip.appendLine(tooltip, nil, { "helmod_common.quantity" }, quantity)
		end
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipModule : GuiTooltip
GuiTooltipModule = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Add tooltip line
---@param tooltip table
---@param icon string | nil
---@param label any
---@param bonus number
function GuiTooltip.appendLineBonus(tooltip, icon, label, bonus)
	if icon == nil then
		icon = "[img=helmod-tooltip-blank]"
	end
	local bonus_positive = "+"
	if bonus <= 0 then bonus_positive = "" end
	if bonus ~= 0 then
		table.insert(tooltip, { "", "\n", icon, " "
			, helmod_tag.color.gold, label, ": ", helmod_tag.color.close
			, helmod_tag.font.default_bold, bonus_positive, Format.formatPercent(bonus) or 0, "%", helmod_tag.font.close
		})
	end
end

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipModule:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		local module_prototype = ItemPrototype(self.m_element.name)
		local module = module_prototype:native()
		if module ~= nil then
			GuiTooltip.appendLineTitle(tooltip, "item", self.m_element.name, module_prototype:getLocalisedName(), self.m_element.quality)

			local module_effects = Player.getModuleEffects(self.m_element)
			local bonus_consumption = module_effects.consumption
			local bonus_speed = module_effects.speed
			local bonus_productivity = module_effects.productivity
			local bonus_pollution = module_effects.pollution
			local bonus_quality = module_effects.quality

			GuiTooltip.appendLineBonus(tooltip, nil, { "description.consumption-bonus" }, bonus_consumption)
			GuiTooltip.appendLineBonus(tooltip, nil, { "description.speed-bonus" }, bonus_speed)
			GuiTooltip.appendLineBonus(tooltip, nil, { "description.productivity-bonus" }, bonus_productivity)
			GuiTooltip.appendLineBonus(tooltip, nil, { "description.quality-bonus" }, bonus_quality)
			GuiTooltip.appendLineBonus(tooltip, nil, { "description.pollution-bonus" }, bonus_pollution)

			self:appendControlInfo(tooltip, self.m_element.name);
		end
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipPriority : GuiTooltip
GuiTooltipPriority = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipPriority:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		for i, priority in pairs(self.m_element) do
			local type = "item"
			local module_prototype = ItemPrototype(priority.name)
			local module_priority_label = module_prototype:getLocalisedName()
			local amount = priority.amount or 0

			GuiTooltip.appendLineQuantity(tooltip, type, priority.name, amount, module_priority_label, priority.quality)
		end
	end
	return tooltip
end

-------------------------------------------------------------------------------
---@class GuiTooltipPriorities : GuiTooltip
GuiTooltipPriorities = newclass(GuiTooltip, function(base, ...)
	GuiTooltip.init(base, ...)
	base.classname = "HMGuiTooltip"
end)

-------------------------------------------------------------------------------
---Create tooltip
---@return table
function GuiTooltipPriorities:create()
	local tooltip = self._super.create(self)
	if self.m_element then
		for i, factory in pairs(self.m_element) do
			GuiTooltipPriorities.appendPriority(tooltip, factory)
		end
	end
	return tooltip
end

function GuiTooltipPriorities.appendPriority(tooltip, element)
	local type = "entity"
	local prototype = EntityPrototype(element)

	local element_label = prototype:getLocalisedName()
	GuiTooltip.appendLineTitle(tooltip, type, element.name, element_label, element.quality)

	if element.module_priority then
		for _, module_priority in pairs(element.module_priority) do
			local type = "item"
			local module_prototype = ItemPrototype(module_priority.name)
			local module_priority_label = module_prototype:getLocalisedName()
			local amount = module_priority.amount or 0

			GuiTooltip.appendLineSubQuantity(tooltip, type, module_priority.name, amount, module_priority_label, module_priority.quality)
		end
	end
end
