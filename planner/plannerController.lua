require "planner/plannerModel"
require "planner/plannerDialog"
require "planner/plannerData"
require "planner/plannerSettings"
require "planner/plannerRecipeSelector"
require "planner/plannerRecipeEdition"
require "planner/plannerProductEdition"
require "planner/plannerResourceEdition"
require "planner/plannerEnergyEdition"
require "planner/plannerPinPanel"


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
	Logging:debug("HMPlannerController", "init(parent):global=", global)
	self.parent = parent
	self.controllers = {}
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
	Logging:trace("HMPlannerController", "cleanController(player)")
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
	Logging:trace("HMPlannerController", "bindController(player)")
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
	Logging:debug("HMPlannerController", "on_gui_click(event)")
	if event.element.valid then
		if event.element.name == PLANNER_COMMAND then
			local player = game.players[event.player_index]
			self:main(player)
		end

		if event.element.name == self:classname().."=CLOSE" then
			local player = game.players[event.player_index]
			self:cleanController(player)
		end
		self:parse_event(event)
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
  self:parse_event(event)
end

-------------------------------------------------------------------------------
-- On hotkey event
--
-- @function [parent=#PlannerController] on_gui_hotkey
--
-- @param event
--
function PlannerController.methods:on_gui_hotkey(event)
  self:parse_event(event)
end

-------------------------------------------------------------------------------
-- Parse event
--
-- @function [parent=#PlannerController] parse_event
--
-- @param event
--
function PlannerController.methods:parse_event(event)
	Logging:trace("HMPlannerController", "parse_event(event)")
	-- hotkey action
	if self.controllers ~= nil and event.element == nil then
      Logging:debug("HMPlannerController", "parse_event(event): hotkey=", event.name)
      local player = game.players[event.player_index]
      if event.name == "helmod-open-close" then
        self:main(player)
      end
      if event.name == "helmod-settings-open" then
        self:send_event(player, "HMPlannerSettings", "OPEN")
      end
      if event.name == "helmod-settings-display-next" then
        local globalSettings = self.parent:getGlobal(player, "settings")
        local display_size = self.parent:getGlobalSettings(player,"display_size")
        local i = 1
        while helmod_display_sizes[i] and helmod_display_sizes[i] ~= display_size do
          i = i + 1
        end
        if #helmod_display_sizes > i then
          globalSettings["display_size"] = helmod_display_sizes[i+1]
        else
          globalSettings["display_size"] = helmod_display_sizes[1]
        end
        
        -- refresh
        self:main(player)
        self:main(player)
        
        Logging:debug("HMPlannerController", "parse_event(event): display_size=", display_size, #helmod_display_sizes, i, globalSettings[display_size])
      end
	end
	-- button action
	if self.controllers ~= nil and event.element ~= nil and event.element.valid then
		local eventController = nil
		for _, controller in pairs(self.controllers) do
			if string.find(event.element.name, controller:classname()) then
				eventController = controller
			end
		end
		if eventController ~= nil then
			local player = game.players[event.player_index]
			local patternAction = eventController:classname().."=([^=]*)"
			local patternItem = eventController:classname()..".*=ID=([^=]*)"
			local patternItem2 = eventController:classname()..".*=ID=[^=]*=([^=]*)"
			local patternItem3 = eventController:classname()..".*=ID=[^=]*=[^=]*=([^=]*)"
			local action = string.match(event.element.name,patternAction,1)
			local item = string.match(event.element.name,patternItem,1)
			local item2 = string.match(event.element.name,patternItem2,1)
			local item3 = string.match(event.element.name,patternItem3,1)
			eventController:send_event(player, event.element, action, item, item2, item3)
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
	Logging:debug("HMPlannerController", "send_event(player, classname, action, item, item2, item3)", player, classname, action, item, item2, item3)
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
	Logging:trace("HMPlannerController", "main(player)")
	local guiMain = player.gui[self.locate]
	if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
		guiMain["helmod_planner_main"].destroy()
	else
		-- main panel
		Logging:debug("HMPlannerController", "Create main panel")
		local mainPanel = self:getMainPanel(player)
		-- menu
		Logging:debug("HMPlannerController", "Create menu panel")
		local menuPanel = self:getMenuPanel(player)
		local actionPanel = self:addGuiFrameV(menuPanel, "settings", "helmod_frame_default")
		self:addGuiButton(actionPanel, self:classname().."=CLOSE", nil, "helmod_button_icon_cancel", nil, ({"helmod_button.close"}))
		self:addGuiButton(actionPanel, "HMPlannerSettings=OPEN", nil, "helmod_button_icon_options", nil, ({"helmod_button.options"}))
		-- info
		Logging:debug("HMPlannerController", "Create info panel")
		local infoPanel = self:getInfoPanel(player)
		-- data
		Logging:debug("HMPlannerController", "Create data panel")
		local dataPanel = self:getDataPanel(player)
		-- dialogue
		Logging:debug("HMPlannerController", "Create dialog panel")
		local dialogPanel = self:getDialogPanel(player)

		-- menu

		self.controllers["data"] = PlannerData:new(self)
		self.controllers["data"]:buildPanel(player)

		self.controllers["settings"] = PlannerSettings:new(self)

		self.controllers["recipe-selector"] = PlannerRecipeSelector:new(self)

		self.controllers["recipe-edition"] = PlannerRecipeEdition:new(self)

		self.controllers["resource-edition"] = PlannerResourceEdition:new(self)

    self.controllers["product-edition"] = PlannerProductEdition:new(self)

    self.controllers["energy-edition"] = PlannerEnergyEdition:new(self)

    self.controllers["pin-panel"] = PlannerPinPanel:new(self)


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
	Logging:debug("HMPlannerController", "getMainPanel(player):",player)
	local guiMain = player.gui[self.locate]
	if guiMain["helmod_planner_main"] ~= nil and guiMain["helmod_planner_main"].valid then
		return guiMain["helmod_planner_main"]
	end
	local panel = self:addGuiFlowH(guiMain, "helmod_planner_main", "helmod_flow_resize_row_width")
	--local panel = self:addGuiFrameH(guiMain, "helmod_planner_main", "helmod_frame_main")
  self.parent:setStyle(player, panel, "main", "minimal_width")
  self.parent:setStyle(player, panel, "main", "minimal_height")
	return panel
end

-------------------------------------------------------------------------------
-- Get or create pin tab panel
--
-- @function [parent=#PlannerController] getPinTabPanel
--
-- @param #LuaPlayer player
--
function PlannerController.methods:getPinTabPanel(player)
	Logging:debug("HMPlannerController", "getPinTabPanel(player):",player)
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
	local menuPanel = self:getMainPanel(player)
	if menuPanel["helmod_planner_settings"] ~= nil and menuPanel["helmod_planner_settings"].valid then
		return menuPanel["helmod_planner_settings"]
	end
	return self:addGuiFlowV(menuPanel, "helmod_planner_settings", "helmod_flow_left_menu")
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
	local panel = self:addGuiFlowV(infoPanel, "helmod_planner_data", "helmod_flow_resize_row_width")
	self.parent:setStyle(player, panel, "data", "minimal_width")
  self.parent:setStyle(player, panel, "data", "maximal_width")
  return panel
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
	Logging:debug("HMPlannerController", "refreshDisplayData():",player, item, item2, item3)
	self.controllers["data"]:update(player, item, item2, item3)
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
	Logging:debug("HMPlannerController", "refreshDisplay():",player, item, item2, item3)
	self:main(player)
	self:main(player)
end
