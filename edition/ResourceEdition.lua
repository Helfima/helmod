require "edition.AbstractEdition"

-------------------------------------------------------------------------------
-- Class to build resource edition dialog
--
-- @module ResourceEdition
-- @extends #AbstractEdition
--

ResourceEdition = class(AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ResourceEdition] onInit
--
-- @param #Controller parent parent controller
--
function ResourceEdition:onInit(parent)
	self.panelCaption = ({"helmod_resource-edition-panel.title"})
	self.parameterLast = string.format("%s_%s",self.classname,"last")
end

-------------------------------------------------------------------------------
-- Get or create resource info panel
--
-- @function [parent=#ResourceEdition] getObjectInfoPanel
--
function ResourceEdition:getObjectInfoPanel()
	local flow_panel, content_panel, menu_panel = self:getPanel()
	if content_panel["info"] ~= nil and content_panel["info"].valid then
		return content_panel["info"]
	end
	return ElementGui.addGuiFrameH(content_panel, "info", helmod_frame_style.panel, ({"helmod_common.resource"}))
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
function ResourceEdition:getObject(item, item2, item3)
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
function ResourceEdition:buildHeaderPanel()
	Logging:debug(self.classname, "buildHeaderPanel()")
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
function ResourceEdition:updateHeader(item, item2, item3)
	Logging:debug(self.classname, "updateHeader():", item, item2, item3)
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
function ResourceEdition:updateObjectInfo(item, item2, item3)
	Logging:debug(self.classname, "updateObjectInfo():", item, item2, item3)
	local infoPanel = self:getObjectInfoPanel()
	local model = Model.getModel()
	local _resource = Player.getItemPrototype(item2)

	local model = Model.getModel()
	if  model.ingredients[item2] ~= nil then
		local resource = self:getObject(item, item2, item3)
		Logging:debug(self.classname, "updateResourceInfo():resource=",resource)
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
