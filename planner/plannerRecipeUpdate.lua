-------------------------------------------------------------------------------
-- Classe to build recipe updater dialog
--
-- @module PlannerRecipeUpdate
-- @extends #PlannerDialog
--

PlannerRecipeUpdate = setclass("HMPlannerRecipeUpdate", PlannerDialog)

-------------------------------------------------------------------------------
-- On initialization
--
-- @function [parent=#PlannerRecipeUpdate] on_init
--
-- @param #PlannerController parent parent controller
--
function PlannerRecipeUpdate.methods:on_init(parent)
	self.panelCaption = "Recipe"
	self.player = self.parent.parent
	self.model = self.parent.model
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerRecipeUpdate] on_open
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerRecipeUpdate.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiRecipeLast == nil or self.guiRecipeLast ~= item then
		close = false
	end
	self.guiRecipeLast = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerRecipeUpdate] on_close
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:on_close(element, action, item, item2)
	self.guiRecipeLast = nil
	self:clearGuiInput()
end

-------------------------------------------------------------------------------
-- Clear all input fields
--
-- @function [parent=#PlannerRecipeUpdate] clearGuiInput
--
function PlannerRecipeUpdate.methods:clearGuiInput()
	if self.guiInputs ~= nil then
		for key, gui in pairs(self.guiInputs) do
			if self.guiInputs[key] ~= nil then
				if self.guiInputs[key].valid then self.guiInputs[key].destroy() end
				self.guiInputs[key] = nil;
			end
		end
		self.guiInputs = {}
	end
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerRecipeUpdate] after_open
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:after_open(element, action, item, item2)
	self.guiInfo = self:addGuiFlowV(self.gui, "info")
	self.guiProducts = self:addGuiFrameV(self.gui, "products", "helmod_recipe-table-frame", "Products")
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerRecipeUpdate] on_update
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:on_update(element, action, item, item2)
	self.recipe = self.model.recipes[item]
	if self.recipe ~= nil then
		self:updateInfo(element, action, item, item2)
		self:updateProducts(element, action, item, item2)
	end
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerRecipeUpdate] updateInfo
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:updateInfo(element, action, item, item2)
	for k,guiName in pairs(self.guiInfo.children_names) do
		self.guiInfo[guiName].destroy()
	end
	local guiTableHeader = self:addGuiTable(self.guiInfo,"table-header",2)
	self:addIconButton(guiTableHeader, "recipe", "recipe", self.recipe.name)
	self:addGuiLabel(guiTableHeader, "label", self.recipe.name)
end

-------------------------------------------------------------------------------
-- Update products information
--
-- @function [parent=#PlannerRecipeUpdate] updateProducts
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:updateProducts(element, action, item, item2)
	for k,guiName in pairs(self.guiProducts.children_names) do
		self.guiProducts[guiName].destroy()
	end
	local guiTable= self:addGuiTable(self.guiProducts, "table-products", 2)
	for key, product in pairs(self.recipe.products) do
		self:addIconButton(guiTable, "item_ID_", self.player:getItemIconType(product), product.name)
		self.guiInputs[product.name] = self:addGuiText(guiTable, product.name, product.count)
	end

	self:addGuiButton(self.gui, self:classname().."_recipe-update_ID_", self.recipe.name, "helmod_button-default", "Update")
	self:addGuiButton(self.gui, self:classname().."_recipe-remove_ID_", self.recipe.name, "helmod_button-default", "Delete")
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerRecipeUpdate] on_event
--
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:on_event(element, action, item, item2)
	Logging:debug("on_event:",action, item, item2)
	if action == "OPEN" then
	--element.state = true
	end

	if action == "recipe-update" then
		local products = {}
		for key, gui in pairs(self.guiInputs) do
			if self.guiInputs[key] ~= nil then
				local count = 0
				local tempCount=tonumber(self.guiInputs[key].text)
				if type(tempCount) == "number" then count = tempCount end
				products[key] = count
			end
		end

		self.model:updateInput(item, products)
		self.model:update()
		self.parent:refreshDisplayData()
		self:close()
	end

	if action == "recipe-remove" then
		self.model:removeInput(item)
		self.model:update()
		self.parent:refreshDisplayData()
		self:close()
	end
end
