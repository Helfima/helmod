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
-- @function [parent=#ResourceEdition] onInit
--
-- @param #Controller parent parent controller
--
function ResourceEdition.methods:onInit(parent)
	self.panelCaption = ({"helmod_resource-edition-panel.title"})
end

-------------------------------------------------------------------------------
-- Get the parent panel
--
-- @function [parent=#ResourceEdition] getParentPanel
--
-- @return #LuaGuiElement
--
function ResourceEdition.methods:getParentPanel()
	return self.parent:getDialogPanel()
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#ResourceEdition] onOpen
--
-- @param #LuaEvent event
-- @param #string action action name
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
-- @return #boolean if true the next call close dialog
--
function ResourceEdition.methods:onOpen(event, action, item, item2, item3)
	local model = Model.getModel()
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
-- @function [parent=#ResourceEdition] onClose
--
function ResourceEdition.methods:onClose()
	local model = Model.getModel()
	model.guiRecipeLast = nil
	model.moduleListRefresh = false
end

-------------------------------------------------------------------------------
-- Get or create resource info panel
--
-- @function [parent=#ResourceEdition] getObjectInfoPanel
--
function ResourceEdition.methods:getObjectInfoPanel()
	local panel = self:getPanel()
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return ElementGui.addGuiFrameH(panel, "info", helmod_frame_style.panel, ({"helmod_common.resource"}))
end

-------------------------------------------------------------------------------
-- Get object
--
-- @function [parent=#ResourceEdition] getObject
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:getObject(item, item2, item3)
	local model = Model.getModel()
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
function ResourceEdition.methods:buildHeaderPanel()
	Logging:debug(self:classname(), "buildHeaderPanel()")
	self:getObjectInfoPanel()
end

-------------------------------------------------------------------------------
-- Update header
--
-- @function [parent=#ResourceEdition] updateHeader
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:updateHeader(item, item2, item3)
	Logging:debug(self:classname(), "updateHeader():", item, item2, item3)
	self:updateObjectInfo(item, item2, item3)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ResourceEdition] updateObjectInfo
--
-- @param #string item first item name
-- @param #string item2 second item name
-- @param #string item3 third item name
--
function ResourceEdition.methods:updateObjectInfo(item, item2, item3)
	Logging:debug(self:classname(), "updateObjectInfo():", item, item2, item3)
	local infoPanel = self:getObjectInfoPanel()
	local model = Model.getModel()
	local _resource = Player.getItemPrototype(item2)

	local model = Model.getModel()
	if  model.ingredients[item2] ~= nil then
		local resource = self:getObject(item, item2, item3)
		Logging:debug(self:classname(), "updateResourceInfo():resource=",resource)
		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local tablePanel = ElementGui.addGuiTable(infoPanel,"table-input",2)
		ElementGui.addGuiButtonSprite(tablePanel, "item", Player.getIconType(resource), resource.name)
		if _resource == nil then
			ElementGui.addGuiLabel(tablePanel, "label", resource.name)
		else
			ElementGui.addGuiLabel(tablePanel, "label", _resource.localised_name)
		end
	end
end
