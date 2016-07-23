-------------------------------------------------------------------------------
-- Classe to build settings panel
--
-- @module PlannerResult
-- @extends #ElementGui
--

PlannerSettings = setclass("HMPlannerSettings", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlannerSettings] init
--
-- @param #PlannerController parent parent controller
--
function PlannerSettings.methods:init(parent)
	self.parent = parent
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerResult] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerSettings.methods:getParentPanel(player)
	return self.parent:getSettingsPanel(player)
end

-------------------------------------------------------------------------------
-- Get or create time panel
--
-- @function [parent=#PlannerResult] getTimePanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:getTimePanel(player)
	local parentPanel = self:getParentPanel(player)
	if parentPanel["time"] ~= nil and parentPanel["time"].valid then
		return parentPanel["time"]
	end
	return self:addGuiFlowH(parentPanel, "time")
end

-------------------------------------------------------------------------------
-- Build the parent panel
--
-- @function [parent=#PlannerSettings] buildPanel
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:buildPanel(player)
	Logging:debug("PlannerSettings:buildPanel():",player)

	local model = self.model:getModel(player)

	local parentPanel = self:getParentPanel(player)

	if parentPanel ~= nil then
		self:getTimePanel(player)

		self:update(player)
	end
end

-------------------------------------------------------------------------------
-- On gui click
--
-- @function [parent=#PlannerSettings] on_gui_click
--
-- @param #table event
-- @param #string label displayed text
--
function PlannerSettings.methods:on_gui_click(event)
	Logging:debug("PlannerResult:on_gui_click():",event)
	if event.element.valid and string.find(event.element.name, self:classname()) then
		local player = game.players[event.player_index]

		local patternAction = self:classname().."=([^=]*)"
		local patternItem = self:classname()..".*=ID=([^=]*)"
		local patternRecipe = self:classname()..".*=ID=[^=]*=([^=]*)"
		local action = string.match(event.element.name,patternAction,1)
		local item = string.match(event.element.name,patternItem,1)
		local item2 = string.match(event.element.name,patternRecipe,1)

		self:on_event(player, event.element, action, item, item2)
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerSettings] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerSettings.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerSettings:on_event():",player, element, action, item, item2)
	local model = self.model:getModel(player)

	if action == "change-time" then
		model.time = tonumber(item)
		self.model:update(player)
		self:update(player)
		self.parent:refreshDisplayData(player)
	end
end

-------------------------------------------------------------------------------
-- Update
--
-- @function [parent=#PlannerSettings] update
--
-- @param #LuaPlayer player
--
function PlannerSettings.methods:update(player)
	Logging:debug("PlannerResult:update():", player)
	local model = self.model:getModel(player)
	local timePanel = self:getTimePanel(player)

	for k,guiName in pairs(timePanel.children_names) do
		timePanel[guiName].destroy()
	end

	self:addGuiLabel(timePanel, self:classname().."=base-time", "Base time:", "helmod_page-label")

	local times = {
		{ value = 60, name = "1m"},
		{ value = 300, name = "5m"},
		{ value = 600, name = "10m"},
		{ value = 1800, name = "30m"},
		{ value = 3600, name = "1h"}
	}
	for _,time in pairs(times) do
		if model.time == time.value then
			self:addGuiLabel(timePanel, self:classname().."=change-time="..time.value, time.name, "helmod_page-label")
		else
			self:addGuiButton(timePanel, self:classname().."=change-time=ID=", time.value, "helmod_button-default", time.name)
		end
	end
end





