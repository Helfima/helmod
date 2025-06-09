-------------------------------------------------------------------------------
---Class to build product edition dialog
---@class LogisticEdition : FormModel
LogisticEdition = newclass(Form)

-------------------------------------------------------------------------------
---On initialization
function LogisticEdition:onInit()
	self.panelCaption = ({ "helmod_panel.logistic-edition" })
	self.panel_close_before_main = true
end

-------------------------------------------------------------------------------
---On Style
---@param styles table
---@param width_main number
---@param height_main number
function LogisticEdition:onStyle(styles, width_main, height_main)
	styles.flow_panel = {
		minimal_height = 100,
		maximal_height = height_main,
	}
end

-------------------------------------------------------------------------------
---On Bind Dispatcher
function LogisticEdition:onBind()
	Dispatcher:bind("on_gui_refresh", self, self.update)
end

-------------------------------------------------------------------------------
---On update
---@param event LuaEvent
function LogisticEdition:onUpdate(event)
	self:updateItemsLogistic(event)
end

-------------------------------------------------------------------------------
---Update items logistic
---@param event LuaEvent
function LogisticEdition:updateItemsLogistic(event)
	local flow_panel, content_panel, menu_panel = self:getPanel()
	content_panel.clear()

	local logistic_quality = User.getParameter("logistic_quality") or "normal"

	if Player.hasFeatureQuality() then
		local quality_panel = GuiElement.addQualitySelector(content_panel, logistic_quality, self.classname, "quality-select", event.item1)
		quality_panel.style.bottom_margin = 5
	end

	local number_column = User.getPreferenceSetting("preference_number_column")
	local container_panel = self:getScrollPanel("information")

	if event.item1 == "item" then
		local type = User.getParameter("logistic_row_item") or "belt"
		local type_table_panel = GuiElement.add(container_panel, GuiTable(string.format("%s-selector-table", type)):column(number_column))

		local item_logistic = Player.getDefaultItemLogistic(type)
		for key, entity in pairs(Player.getItemsLogistic(type)) do
			local color = nil
			if entity.name == item_logistic.name then color = "green" end
			local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "items-logistic-select", type):choose_with_quality("entity", entity.name, logistic_quality):color(color))
			button.locked = true
		end
	end
	if event.item1 == "fluid" then
		local type = User.getParameter("logistic_row_fluid") or "pipe"
		local type_table_panel = GuiElement.add(container_panel, GuiTable(string.format("%s-selector-table", type)):column(number_column))

		local fluid_logistic = Player.getDefaultFluidLogistic(type)
		for key, entity in pairs(Player.getFluidsLogistic(type)) do
			local color = nil
			if entity.name == fluid_logistic.name then color = "green" end
			local button = GuiElement.add(type_table_panel, GuiButtonSelectSprite(self.classname, "fluids-logistic-select", type):choose_with_quality("entity", entity.name, logistic_quality):color(color))
			button.locked = true
		end
	end
end

-------------------------------------------------------------------------------
---On event
---@param event LuaEvent
function LogisticEdition:onEvent(event)
	local logistic_quality = User.getParameter("logistic_quality") or "normal"

	if event.action == "items-logistic-select" then
		local element = Model.newElement("entity", event.item2, logistic_quality)
		User.setParameter(string.format("items_logistic_%s", event.item1), element)
		self:close()
		Controller:send("on_gui_refresh", event)
	end

	if event.action == "fluids-logistic-select" then
		local element = Model.newElement("entity", event.item2, logistic_quality)
		User.setParameter(string.format("fluids_logistic_%s", event.item1), element)
		self:close()
		Controller:send("on_gui_refresh", event)
	end

	if event.action == "quality-select" then
		local logistic_quality = event.item2
		if event.item1 == "item" then
			local type = User.getParameter("logistic_row_item") or "belt"
			local item_logistic = Player.getDefaultItemLogistic(type)
			local element = Model.newElement("entity", item_logistic.name, logistic_quality)
			User.setParameter(string.format("items_logistic_%s", type), element)
		end
		if event.item1 == "fluid" then
			local type = User.getParameter("logistic_row_fluid") or "pipe"
			local fluid_logistic = Player.getDefaultFluidLogistic(type)
			local element = Model.newElement("entity", fluid_logistic.name, logistic_quality)
			User.setParameter(string.format("fluids_logistic_%s", type), element)
		end
		Controller:send("on_gui_refresh", event, "HMProductionPanel")
		User.setParameter("logistic_quality", logistic_quality)
		self:updateItemsLogistic(event)
	end
end
