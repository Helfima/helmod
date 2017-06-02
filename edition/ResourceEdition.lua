require "edition.AbstractEdition"

-------------------------------------------------------------------------------
-- Class to build resource edition dialog
--
-- @module ResourceEdition
-- @extends #AbstractEdition
--

ResourceEdition = setclass("HMResourceEdition", AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ResourceEdition] on_init
--
-- @param #Controller parent parent controller
--
function ResourceEdition.methods:on_init(parent)
	self.panelCaption = ({"helmod_resource-edition-panel.title"})
	self.player = self.parent.player
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#ResourceEdition] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function ResourceEdition.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#ResourceEdition] on_open
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ResourceEdition.methods:on_open(player, event, action, item, item2, item3)
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
-- @function [parent=#ResourceEdition] on_close
--
-- @param #LuaPlayer player
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:on_close(player, event, action, item, item2, item3)
	local model = self.model:getModel(player)
	model.guiRecipeLast = nil
	model.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create resource info panel
--
-- @function [parent=#ResourceEdition] getObjectInfoPanel
--
-- @param #LuaPlayer player
--
function ResourceEdition.methods:getObjectInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameH(panel, "info", "helmod_frame_resize_row_width", ({"helmod_common.resource"}))
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#ResourceEdition] getObject
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:getObject(player, item, item2, item3)
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
-- @function [parent=#ResourceEdition] buildHeaderPanel
--
-- @param #LuaPlayer player
--
function ResourceEdition.methods:buildHeaderPanel(player)
	Logging:debug(self:classname(), "buildHeaderPanel():",player)
	self:getObjectInfoPanel(player)
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ResourceEdition] updateHeader
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:updateHeader(player, item, item2, item3)
	Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
	self:updateObjectInfo(player,item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ResourceEdition] updateObjectInfo
--
-- @param #LuaPlayer player
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:updateObjectInfo(player, item, item2, item3)
	Logging:debug(self:classname(), "updateObjectInfo():", item, item2, item3)
	local infoPanel = self:getObjectInfoPanel(player)
	local model = self.model:getModel(player)
	local default = self.model:getDefault(player)
	local _resource = self.player:getItemPrototype(item2)

	local model = self.model:getModel(player)
	if  model.ingredients[item2] ~= nil then
		local resource = self:getObject(player, item, item2, item3)
		Logging:debug(self:classname(), "updateResourceInfo():resource=",resource)
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
	end
end
