require "planner/plannerModel"
require "planner/plannerDialog"
require "planner/plannerResult"
require "planner/plannerSettings"
require "planner/plannerRecipeSelector"
require "planner/plannerRecipeEdition"
require "planner/plannerProductEdition"
require "planner/plannerResourceEdition"
require "planner/plannerPinTab"


PLANNER_COMMAND = "helmod_planner-command"

-------------------------------------------------------------------------------
-- Classe de player
--
-- @module PlannerController
--

PlannerController = setclass("HMPlannerController", ElementGui)

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlayerController] init
--
-- @param #PlayerController parent controller parent
--
function PlannerController.methods:init(parent)
	self.parent = parent
	self.controllers = {}
	self.modelFilename = "helmod-planner-model.data"
	self.model = PlannerModel:new(self)

	self.locate = "center"
	self.pinLocate = "left"
end

-------------------------------------------------------------------------------
-- Cleanup
--
-- @function [parent=#PlannerController] cleanController
--
-- @param #LuaPlayer player
--
function PlannerController.methods:cleanController(player)
	Logging:trace("PlannerController:cleanController(player)")
	if player.gui.left["helmod_planner_main"] ~= nil then
		player.gui.left["helmod_planner_main"].destroy()
	end
	if player.gui.center["helmod_planner_main"] ~= nil then
		player.gui.center["helmod_planner_main"].destroy()
	end
end

-------------------------------------------------------------------------------
-- Bind all controllers
--
-- @function [parent=#PlannerController] bindController
--
-- @param #LuaPlayer player
--
function PlannerController.methods:bindController(player)
	Logging:trace("PlannerController:bindController(player)")
	local parentGui = self.parent:getGui(player)
	if parentGui ~= nil then
		local guiButton = self:addGuiFrameH(parentGui, PLANNER_COMMAND, "helmod_frame_default")
		guiButton.add({type="button", name=PLANNER_COMMAND, tooltip=({PLANNER_COMMAND}), style="helmod_icon"})
	end
end

-------------------------------------------------------------------------------
-- On click event
--
-- @function [parent=#PlannerController] on_gui_click
--
-- @param event
--
function PlannerController.methods:on_gui_click(event)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:on_gui_click(event)
		end
	end

	if event.element.valid then
		if event.element.name == PLANNER_COMMAND then
			local player = game.players[event.player_index]
			self:main(player)
		end

		if event.element.name == self:classname().."=CLOSE" then
			local player = game.players[event.player_index]
			self:cleanController(player)
		end
	end
end


-------------------------------------------------------------------------------
-- On text changed event
--
-- @function [parent=#PlannerController] on_gui_text_changed
--
-- @param event
--
function PlannerController.methods:on_gui_text_changed(event)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:on_gui_click(event)
		end
	end
end

-------------------------------------------------------------------------------
-- Send event dialog
--
-- @function [parent=#PlannerController] send_event
--
-- @param #LuaPlayer player
-- @param #string classname controller name
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerController.methods:send_event(player, classname, action, item, item2, item3)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			if controller:classname() == classname then
				controller:send_event(player, nil, action, item, item2, item3)
			end
		end
	end
end

-------------------------------------------------------------------------------
-- Prepare main display
--
-- @function [parent=#PlannerController] main
--
-- @param #LuaPlayer player
--
function PlannerController.methods:main(player)
	Logging:trace("PlannerController:main(player)")
	local guiMain = player.gui[self.locate]
	if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
		guiMain["helmod_planner_main"].destroy()
	else
		-- main panel
		Logging:debug("Create main panel")
		local mainPanel = self:getMainPanel(player)
		-- info
		Logging:debug("Create info panel")
		local infoPanel = self:getInfoPanel(player)
		-- menu
		Logging:debug("Create menu panel")
		local settingsPanel = self:getMenuPanel(player)
		self:addGuiButton(settingsPanel, self:classname().."=CLOSE", nil, "helmod_button-default", ({"helmod_button.close"}))
		-- data
		Logging:debug("Create data panel")
		local dataPanel = self:getDataPanel(player)
		-- dialogue
		Logging:debug("Create dialog panel")
		local dialogPanel = self:getDialogPanel(player)

		-- menu

		self.controllers["result"] = PlannerResult:new(self)
		self.controllers["result"]:buildPanel(player)

		self.controllers["settings"] = PlannerSettings:new(self)
		self.controllers["settings"]:buildPanel(player)

		self.controllers["recipe-selector"] = PlannerRecipeSelector:new(self)

		self.controllers["recipe-edition"] = PlannerRecipeEdition:new(self)

		self.controllers["resource-edition"] = PlannerResourceEdition:new(self)

		self.controllers["product-edition"] = PlannerProductEdition:new(self)

		self.controllers["pin-tab"] = PlannerPinTab:new(self)

	end
end

-------------------------------------------------------------------------------
-- Get or create main panel
--
-- @function [parent=#PlannerController] getMainPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getMainPanel(player)
	local displaySize = self.parent:getGlobalSettings(player, "display_size")
	Logging:debug("PlannerController:getMainPanel():",displaySize)
	local guiMain = player.gui[self.locate]
	if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
		return guiMain["helmod_planner_main"]
	end
	return self:addGuiFlowH(guiMain, "helmod_planner_main", "helmod_flow_main_"..displaySize)
	--return self:addGuiFrameH(guiMain, "helmod_planner_main", "helmod_frame_main_"..displaySize)
end

-------------------------------------------------------------------------------
-- Get or create pin tab panel
--
-- @function [parent=#PlannerController] getPinTabPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getPinTabPanel(player)
	Logging:debug("PlannerController:getPinTabPanel():",displaySize)
	local guiMain = player.gui[self.pinLocate]
	if guiMain["helmod_planner_pin_tab"] ~= nil and guiMain["helmod_planner_pin_tab"].valid then
		return guiMain["helmod_planner_pin_tab"]
	end
	return self:addGuiFlowH(guiMain, "helmod_planner_pin_tab", "helmod_flow_resize_row_width")
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerController] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getInfoPanel(player)
	local mainPanel = self:getMainPanel(player)
	if mainPanel["helmod_planner_info"] ~= nil and mainPanel["helmod_planner_info"].valid then
		return mainPanel["helmod_planner_info"]
	end
	return self:addGuiFlowV(mainPanel, "helmod_planner_info", "helmod_flow_info")
end

-------------------------------------------------------------------------------
-- Get or create dialog panel
--
-- @function [parent=#PlannerController] getDialogPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getDialogPanel(player)
	local mainPanel = self:getMainPanel(player)
	if mainPanel["helmod_planner_dialog"] ~= nil and mainPanel["helmod_planner_dialog"].valid then
		return mainPanel["helmod_planner_dialog"]
	end
	return self:addGuiFlowH(mainPanel, "helmod_planner_dialog", "helmod_flow_dialog")
end

-------------------------------------------------------------------------------
-- Get or create menu panel
--
-- @function [parent=#PlannerController] getMenuPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getMenuPanel(player)
	local infoPanel = self:getInfoPanel(player)
	if infoPanel["helmod_planner_settings"] ~= nil and infoPanel["helmod_planner_settings"].valid then
		return infoPanel["helmod_planner_settings"]
	end
	return self:addGuiFrameH(infoPanel, "helmod_planner_settings", "helmod_frame_main_menu")
end

-------------------------------------------------------------------------------
-- Get or create data panel
--
-- @function [parent=#PlannerController] getDataPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getDataPanel(player)
	local displaySize = self.parent:getGlobalSettings(player, "display_size")
	local infoPanel = self:getInfoPanel(player)
	if infoPanel["helmod_planner_data"] ~= nil and infoPanel["helmod_planner_data"].valid then
		return infoPanel["helmod_planner_data"]
	end
	return self:addGuiFlowV(infoPanel, "helmod_planner_data", "helmod_flow_data_"..displaySize)
end

-------------------------------------------------------------------------------
-- Refresh display data
--
-- @function [parent=#PlannerController] refreshDisplayData
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerController.methods:refreshDisplayData(player, item, item2, item3)
	Logging:debug("PlannerController:refreshDisplayData():",player, item, item2, item3)
	self.controllers["result"]:update(player, item, item2, item3)
	if item == "other_speed_panel" then
		local globalSettings = self.parent:getGlobal(player, "settings")
		local controller = self.parent.controllers["speed-controller"]
		if globalSettings.other_speed_panel == true then
			controller:cleanController(player)
			controller:bindController(player)
		else
			controller:cleanController(player)
			game.speed = 1
		end
	end
end

-------------------------------------------------------------------------------
-- Refresh display
--
-- @function [parent=#PlannerController] refreshDisplay
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerController.methods:refreshDisplay(player, item, item2, item3)
	Logging:debug("PlannerController:refreshDisplayData():",player, item, item2, item3)
	self:main(player)
	self:main(player)
end
