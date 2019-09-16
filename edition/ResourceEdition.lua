require "edition.AbstractEdition"

-------------------------------------------------------------------------------
-- Class to build resource edition dialog
--
-- @module ResourceEdition
-- @extends #AbstractEdition
--

ResourceEdition = newclass(AbstractEdition)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#ResourceEdition] onInit
--
function ResourceEdition:onInit()
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
-- @param #LuaEvent event
--
function ResourceEdition:getObject(event)
	local model = Model.getModel()
	if  model.resources[event.item2] ~= nil then
		-- return resource
		return model.resources[event.item2]
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
-- @param #LuaEvent event
--
function ResourceEdition:updateHeader(event)
	Logging:debug(self.classname, "updateHeader()", event)
	self:updateObjectInfo(event)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#ResourceEdition] updateObjectInfo
--
-- @param #LuaEvent event
--
function ResourceEdition:updateObjectInfo(event)
	Logging:debug(self.classname, "updateObjectInfo()", event)
	local infoPanel = self:getObjectInfoPanel()
	local model = Model.getModel()
	local _resource = Player.getItemPrototype(event.item2)

	local model = Model.getModel()
	if  model.ingredients[event.item2] ~= nil then
		local resource = self:getObject(event)
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
