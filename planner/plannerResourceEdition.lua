require "planner/plannerAbstractEdition"

-------------------------------------------------------------------------------
-- Classe to build resource edition dialog
--
-- @module PlannerResourceEdition
-- @extends #PlannerDialog
--

PlannerResourceEdition = setclass("HMPlannerResourceEdition", PlannerAbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerResourceEdition] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerResourceEdition.methods:on_init(parent)
	self.panelCaption = ({"helmod_resource-edition-panel.title"})
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#PlannerResourceEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerResourceEdition.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerResourceEdition] on_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerResourceEdition.methods:on_open(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	local close = true
	model.moduleListRefresh = false
	if model.guiRecipeLast == nil or model.guiRecipeLast ~= item..item2 then
		close = false
		model.factoryGroupSelected = nil
		model.beaconGroupSelected = nil
		model.moduleListRefresh = true
	end
	model.guiRecipeLast = item..item2
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerResourceEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResourceEdition.methods:on_close(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	model.guiRecipeLast = nil
	model.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create resource info panel
--
-- @function [parent=#PlannerResourceEdition] getObjectInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerResourceEdition.methods:getObjectInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameH(panel, "info", "helmod_frame_resize_row_width", ({"helmod_common.resource"}))
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#PlannerResourceEdition] getObject
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResourceEdition.methods:getObject(player, element, action, item, item2, item3)
	local model = self.model:getModel(player)
	if  model.resources[item2] ~= nil then
		-- return resource
		return model.resources[item2]
	end
	return nil
end

-------------------------------------------------------------------------------
-- Build header panel
--
-- @function [parent=#PlannerResourceEdition] buildHeaderPanel
--
-- @param #LuaPlayer player
--
function PlannerResourceEdition.methods:buildHeaderPanel(player)
	Logging:debug("PlannerResourceEdition:buildHeaderPanel():",player)
	self:getObjectInfoPanel(player)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#PlannerResourceEdition] updateHeader
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResourceEdition.methods:updateHeader(player, element, action, item, item2, item3)
	Logging:debug("PlannerResourceEdition:updateHeader():",player, element, action, item, item2, item3)
	self:updateObjectInfo(player, element, action, item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerResourceEdition] updateObjectInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function PlannerResourceEdition.methods:updateObjectInfo(player, element, action, item, item2, item3)
	Logging:debug("PlannerResourceEdition:updateObjectInfo():",player, element, action, item, item2, item3)
	local infoPanel = self:getObjectInfoPanel(player)
	local model = self.model:getModel(player)
	local default = self.model:getDefault(player)
	local _resource = self.player:getItemPrototype(item2)

	local model = self.model:getModel(player)
	if  model.ingredients[item2] ~= nil then
		local resource = self:getObject(player, element, action, item, item2, item3)
		Logging:debug("PlannerResourceEdition:updateResourceInfo():resource=",resource)
		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local tablePanel = self:addGuiTable(infoPanel,"table-input",2)
		self:addGuiButtonSprite(tablePanel, "item", self.player:getIconType(resource), resource.name)
		if _resource == nil then
			self:addGuiLabel(tablePanel, "label", resource.name)
		else
			self:addGuiLabel(tablePanel, "label", _resource.localised_name)
		end


--		self:addGuiLabel(tablePanel, "label-production", ({"helmod_common.production"}))
--		self:addGuiText(tablePanel, "production", resource.production, "helmod_textfield")
--
--		self:addGuiButton(tablePanel, self:classname().."=object-update=ID=resource=", resource.name, "helmod_button-default", ({"helmod_button.update"}))		--
	end
end
