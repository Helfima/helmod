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
-- Get the parent panel
--
-- @function [parent=#PlannerRecipeUpdate] getParentPanel
--
-- @param #LuaPlayer player
--
-- @return #LuaGuiElement
--
function PlannerRecipeUpdate.methods:getParentPanel(player)
	return self.parent:getDialogPanel(player)
end

-------------------------------------------------------------------------------
-- On open
--
-- @function [parent=#PlannerRecipeUpdate] on_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
-- @return #boolean if true the next call close dialog
--
function PlannerRecipeUpdate.methods:on_open(player, element, action, item, item2)
	local model = self.model:getModel(player)
	local close = true
	if model.guiRecipeLast == nil or model.guiRecipeLast ~= item then
		close = false
	end
	model.guiRecipeLast = item
	return close
end

-------------------------------------------------------------------------------
-- On close dialog
--
-- @function [parent=#PlannerRecipeUpdate] on_close
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:on_close(player, element, action, item, item2)
	local model = self.model:getModel(player)
	model.guiRecipeLast = nil
end

-------------------------------------------------------------------------------
-- Get or create info panel
--
-- @function [parent=#PlannerRecipeUpdate] getInfoPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeUpdate.methods:getInfoPanel(player)
	local panel = self:getPanel(player)
	if panel["info"] ~= nil and panel["info"].valid then
		return panel["info"]
	end
	return self:addGuiFrameV(panel, "info", "helmod_module-table-frame")
end

-------------------------------------------------------------------------------
-- Get or create products panel
--
-- @function [parent=#PlannerRecipeUpdate] getProductsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeUpdate.methods:getProductsPanel(player)
	local panel = self:getPanel(player)
	if panel["products"] ~= nil and panel["products"].valid then
		return panel["products"]
	end
	return self:addGuiFrameV(panel, "products", "helmod_module-table-frame", "Products")
end

-------------------------------------------------------------------------------
-- Get or create buttons panel
--
-- @function [parent=#PlannerRecipeUpdate] getButtonsPanel
--
-- @param #LuaPlayer player
--
function PlannerRecipeUpdate.methods:getButtonsPanel(player)
	local panel = self:getPanel(player)
	if panel["buttons"] ~= nil and panel["buttons"].valid then
		return panel["buttons"]
	end
	return self:addGuiFlowH(panel, "buttons")
end

-------------------------------------------------------------------------------
-- After open
--
-- @function [parent=#PlannerRecipeUpdate] after_open
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:after_open(player, element, action, item, item2)
	self:getInfoPanel(player)
	self:getProductsPanel(player)
end

-------------------------------------------------------------------------------
-- On update
--
-- @function [parent=#PlannerRecipeUpdate] on_update
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:on_update(player, element, action, item, item2)
	self:updateInfo(player, element, action, item, item2)
	self:updateProducts(player, element, action, item, item2)
end

-------------------------------------------------------------------------------
-- Update information
--
-- @function [parent=#PlannerRecipeUpdate] updateInfo
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:updateInfo(player, element, action, item, item2)
	Logging:debug("PlannerRecipeUpdate:updateInfo():",player, element, action, item, item2)
	local infoPanel = self:getInfoPanel(player)
	local model = self.model:getModel(player)
	local recipe = model.recipes[item]

	if recipe ~= nil then

		for k,guiName in pairs(infoPanel.children_names) do
			infoPanel[guiName].destroy()
		end

		local headerPanel = self:addGuiTable(infoPanel,"table-header",2)
		self:addIconButton(headerPanel, "recipe", "recipe", recipe.name)
		self:addGuiLabel(headerPanel, "label", recipe.name)
	end
end

-------------------------------------------------------------------------------
-- Update products information
--
-- @function [parent=#PlannerRecipeUpdate] updateProducts
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:updateProducts(player, element, action, item, item2)
	Logging:debug("PlannerRecipeUpdate:updateProducts():",player, element, action, item, item2)
	local panel = self:getPanel(player)
	local productsPanel = self:getProductsPanel(player)
	local buttonsPanel = self:getButtonsPanel(player)
	local model = self.model:getModel(player)
	local recipe = model.recipes[item]

	if recipe ~= nil then

		for k,guiName in pairs(productsPanel.children_names) do
			productsPanel[guiName].destroy()
		end

		local inputPanel= self:addGuiTable(productsPanel, "table-products", 2)
		for key, product in pairs(recipe.products) do
			self:addIconButton(inputPanel, "item=ID=", self.player:getItemIconType(product), product.name)
			self:addGuiText(inputPanel, product.name, product.count)
		end

		for k,guiName in pairs(buttonsPanel.children_names) do
			buttonsPanel[guiName].destroy()
		end

		self:addGuiButton(buttonsPanel, self:classname().."=recipe-update=ID=", recipe.name, "helmod_button-default", "Update")
		self:addGuiButton(buttonsPanel, self:classname().."=recipe-remove=ID=", recipe.name, "helmod_button-default", "Delete")
	end
end

-------------------------------------------------------------------------------
-- On event
--
-- @function [parent=#PlannerRecipeUpdate] on_event
--
-- @param #LuaPlayer player
-- @param #LuaGuiElement element button
-- @param #string action action name
-- @param #string item first item name
-- @param #string item second item name
--
function PlannerRecipeUpdate.methods:on_event(player, element, action, item, item2)
	Logging:debug("PlannerRecipeUpdate:on_event():",player, element, action, item, item2)

	if action == "recipe-update" then
		local products = {}

		local model = self.model:getModel(player)
		local recipe = model.recipes[item]

		if recipe ~= nil then
			local inputPanel = self:getProductsPanel(player)["table-products"]
			
			for key, product in pairs(recipe.products) do
				if inputPanel[product.name] ~= nil then
					products[product.name] = self:getInputNumber(inputPanel[product.name])
				end
			end

			self.model:updateInput(player, item, products)
			self.model:update(player)
			self.parent:refreshDisplayData(player)
			self:close(player)
		end
	end

	if action == "recipe-remove" then
		self.model:removeInput(player, item)
		self.model:update(player)
		self.parent:refreshDisplayData(player)
		self:close(player)
	end
end
