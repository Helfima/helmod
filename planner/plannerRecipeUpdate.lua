PlannerRecipeUpdate = setclass("HMPlannerRecipeUpdate", PlannerDialog)

function PlannerRecipeUpdate.methods:on_init(parent)
	self.panelCaption = "Recipe"
	self.player = self.parent.parent
	self.model = self.parent.model
end

--===========================
function PlannerRecipeUpdate.methods:on_open(element, action, item, item2)
	local close = true
	if self.guiRecipeLast == nil or self.guiRecipeLast ~= item then
		close = false
	end
	self.guiRecipeLast = item
	return close
end

--===========================
function PlannerRecipeUpdate.methods:on_close(element, action, item, item2)
	self.guiRecipeLast = nil
	self:clearGuiInput()
end

--===========================
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

--===========================
function PlannerRecipeUpdate.methods:after_open(element, action, item, item2)
	local recipe = self.model.input[item]
	self:clearGuiInput()
	if recipe ~= nil then
		self:addIconButton(self.gui, "item_ID_", self.player:getRecipeIconType(recipe), recipe.name)
		local guiProductTable= self:addGuiTable(self.gui, "table", 2)
		for key, product in pairs(recipe.products) do
			Logging:debug("product:",product)
			self:addIconButton(guiProductTable, "item_ID_", self.player:getItemIconType(product), product.name)
			self.guiInputs[product.name] = self:addGuiText(guiProductTable, product.name, product.count)
		end
		self:addGuiButton(self.gui, self:classname().."_recipe-update_ID_", recipe.name, "helmod_button-default", "Update")
		self:addGuiButton(self.gui, self:classname().."_recipe-remove_ID_", recipe.name, "helmod_button-default", "Delete")
	end
end

--===========================
function PlannerRecipeUpdate.methods:on_update(element, action, item, item2)
end

--===========================
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


































