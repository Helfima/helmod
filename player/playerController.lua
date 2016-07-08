require "speed.speedController"
require "planner.plannerController"

PlayerController = setclass("HMPlayerController")

function PlayerController.methods:init(player)
	self.player = player
	self.gui = nil

	self.prefix = "helmod_"

	-- list des controllers
	self.controllers = {}
	self.controllers["speed-controller"] = SpeedController:new(self)
	self.controllers["planner-controller"] = PlannerController:new(self)


end

--===========================
function PlayerController.methods:bindController()
	self:resetGui()
	if self.gui == nil then
		self.gui = self.player.gui.top.add{type="flow", name="helmod_menu-main", direction="horizontal"}
		if self.controllers ~= nil then
			for r, controller in pairs(self.controllers) do
				controller:cleanController()
				controller:bindController()
			end
		end
	end
end

--===========================
function PlayerController.methods:resetGui()
	if self.gui ~= nil then
		self.gui.destroy()
	end
	if self.player.gui.top["helmod_menu-main"] ~= nil then
		self.player.gui.top["helmod_menu-main"].destroy()
	end
end

--===========================
function PlayerController.methods:on_gui_click(event)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:on_gui_click(event)
		end
	end
end

--===========================
function PlayerController.methods:getForce()
	return self.player.force
end

--===========================
function PlayerController.methods:getRecipes()
	return self:getForce().recipes
end

--===========================
function PlayerController.methods:getRecipeGroups()
	if self.recipeGroups ~= nil then return self.recipeGroups end
	-- recuperation des groupes avec les recipes
	self.recipeGroups = {}
	for key, recipe in pairs(self:getRecipes()) do
		if recipe.group ~= nil then
			if self.recipeGroups[recipe.group.name] == nil then self.recipeGroups[recipe.group.name] = {} end
			table.insert(self.recipeGroups[recipe.group.name], recipe.name)
		end
	end
	return self.recipeGroups
end

--===========================
function PlayerController.methods:getProductionGroups(category)
	if category == nil then return helmod_defines.production_groups end
	local groups = {}
	for k, group in pairs(helmod_defines.production_groups) do
		local check = false
		if group.categories ~= nil then
			for c, value in pairs(group.categories) do
				if category == value then check = true end
			end
		end
		if check then groups[group.name] = group end
	end
	return groups
end

--===========================
function PlayerController.methods:getProductions()
	if self.productions ~= nil then return self.productions end
	-- recuperation des groupes
	self.productions = {}
	for key, item in pairs(game.entity_prototypes) do
		if item.type ~= nil and helmod_defines.production_groups[item.type] ~= nil then
			self.productions[item.name] = item
		end
	end
	return self.productions
end

--===========================
function PlayerController.methods:getModules()
	if self.modules ~= nil then return self.modules end
	-- recuperation des groupes
	self.modules = {}
	for key, item in pairs(game.item_prototypes) do
		if item.type ~= nil and item.type == "module" then
			self.modules[item.name] = item
		end
	end
	return self.modules
end

--===========================
function PlayerController.methods:getRecipe(name)
	return self:getForce().recipes[name]
end

--===========================
function PlayerController.methods:searchRecipe(name)
	local recipes = {}
	-- le recipe porte le meme nom que l'item
	local recipe = self:getRecipe(name)
	-- recherche dans les produits des recipes
	if recipe == nil then
		for key, recipe in pairs(self:getRecipes()) do
			for k, product in pairs(recipe.products) do
				if product.name == name then
					recipes[recipe.name] = recipe
				end
			end
		end
	else
		recipes[recipe.name] = recipe
	end
	return recipes
end

--===========================
function PlayerController.methods:getEntityPrototype(name)
	return game.entity_prototypes[name]
end

--===========================
function PlayerController.methods:getItemPrototype(name)
	return game.item_prototypes[name]
end

--===========================
function PlayerController.methods:getFluidPrototype(name)
	--Logging:debug("getFluidPrototype:",name)
	return game.fluid_prototypes[name]
end

--===========================
function PlayerController.methods:unlockRecipes()
	self:getForce().enable_all_recipes()
end

--===========================
function PlayerController.methods:lockRecipes()
	self:getForce().reset_recipes()
end

--===========================
function PlayerController.methods:getRecipeIconType(recipe)
	local item = self:getItemPrototype(recipe.name)
	if item ~= nil then
		return "item"
	end
	local fluid = self:getFluidPrototype(recipe.name)
	if fluid ~= nil then
		return "fluid"
	else
		return "recipe"
	end
end

--===========================
function PlayerController.methods:getItemIconType(element)
	local item = self:getItemPrototype(element.name)
	if item ~= nil then
		return item.type
	end
	local fluid = self:getFluidPrototype(element.name)
	if fluid ~= nil then
		return "fluid"
	else
		return "item"
	end
end





























