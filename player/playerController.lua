require "speed.speedController"
require "planner.plannerController"

-------------------------------------------------------------------------------
-- Classe de player
--
-- @module PlayerController
--

PlayerController = setclass("HMPlayerController")

-------------------------------------------------------------------------------
-- Initialization
--
-- @function [parent=#PlayerController] init
--
-- @param #LuaPlayer player the player
--
function PlayerController.methods:init(player)
	self.player = player
	self.gui = nil

	self.prefix = "helmod_"

	-- list des controllers
	self.controllers = {}
	self.controllers["speed-controller"] = SpeedController:new(self)
	self.controllers["planner-controller"] = PlannerController:new(self)
end

-------------------------------------------------------------------------------
-- Bind all controllers
--
-- @function [parent=#PlayerController] bindController
--
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

-------------------------------------------------------------------------------
-- Initialize gui
--
-- @function [parent=#PlayerController] resetGui
--
function PlayerController.methods:resetGui()
	if self.gui ~= nil then
		self.gui.destroy()
	end
	if self.player.gui.top["helmod_menu-main"] ~= nil then
		self.player.gui.top["helmod_menu-main"].destroy()
	end
end

-------------------------------------------------------------------------------
-- Initialize gui
--
-- @function [parent=#PlayerController] on_gui_click
--
-- @param event
--
function PlayerController.methods:on_gui_click(event)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:on_gui_click(event)
		end
	end
end

-------------------------------------------------------------------------------
-- Return force's player
--
-- @function [parent=#PlayerController] getForce
--
-- @return #table force
--
function PlayerController.methods:getForce()
	return self.player.force
end

-------------------------------------------------------------------------------
-- Get global variable for player
--
-- @function [parent=#PlayerController] getGlobal
--
-- @param key
--
-- @return #table global
--
function PlayerController.methods:getGlobal(key)
	if global[self.player.name] == nil then
		global[self.player.name] = {}
	end
	if global[self.player.name]["HMModel"] == nil then
		global[self.player.name]["HMModel"] = {}
	end
	if global[self.player.name]["HMModel"][key] == nil then
		global[self.player.name]["HMModel"][key] = {}
	end
	if key ~= nil then
		return global[self.player.name]["HMModel"][key]
	end
	return global[self.player.name]["HMModel"]
end

-------------------------------------------------------------------------------
-- Return recipes
--
-- @function [parent=#PlayerController] getRecipes
--
-- @return #table recipes
--
function PlayerController.methods:getRecipes()
	return self:getForce().recipes
end

-------------------------------------------------------------------------------
-- Return recipe groups
--
-- @function [parent=#PlayerController] getRecipeGroups
--
-- @return #table recipe groups
--
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

-------------------------------------------------------------------------------
-- Return list of productions
--
-- @function [parent=#PlayerController] getProductionGroups
--
-- @param #string category filter
--
-- @return #table list of productions
--
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

-------------------------------------------------------------------------------
-- Return list of productions
--
-- @function [parent=#PlayerController] getProductions
--
-- @return #table list of productions
--
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

-------------------------------------------------------------------------------
-- Return list of modules
--
-- @function [parent=#PlayerController] getModules
--
-- @return #table list of modules
--
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

-------------------------------------------------------------------------------
-- Return recipe
--
-- @function [parent=#PlayerController] getRecipe
--
-- @param #string recipe name
--
-- @return #LuaRecipe recipe
--
function PlayerController.methods:getRecipe(name)
	return self:getForce().recipes[name]
end

-------------------------------------------------------------------------------
-- Return list of recipes
--
-- @function [parent=#PlayerController] searchRecipe
--
-- @param #string recipe name
--
-- @return #table list of recipes
--
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

-------------------------------------------------------------------------------
-- Return entity prototype
--
-- @function [parent=#PlayerController] getEntityPrototype
--
-- @param #string entity name
--
-- @return #LuaEntityPrototype entity prototype
--
function PlayerController.methods:getEntityPrototype(name)
	return game.entity_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return item prototype
--
-- @function [parent=#PlayerController] getItemPrototype
--
-- @param #string item name
--
-- @return #LuaItemPrototype item prototype
--
function PlayerController.methods:getItemPrototype(name)
	return game.item_prototypes[name]
end

-------------------------------------------------------------------------------
-- Return fluid prototype
--
-- @function [parent=#PlayerController] getFluidPrototype
--
-- @param #string fluid name
--
-- @return #LuaFluidPrototype fluid prototype
--
function PlayerController.methods:getFluidPrototype(name)
	--Logging:debug("getFluidPrototype:",name)
	return game.fluid_prototypes[name]
end

-------------------------------------------------------------------------------
-- Unlock Recipes
--
-- @function [parent=#PlayerController] unlockRecipes
--
function PlayerController.methods:unlockRecipes()
	self:getForce().enable_all_recipes()
end

-------------------------------------------------------------------------------
-- Lock Recipes
--
-- @function [parent=#PlayerController] lockRecipes
--
function PlayerController.methods:lockRecipes()
	self:getForce().reset_recipes()
end

-------------------------------------------------------------------------------
-- Return recipe type
--
-- @function [parent=#PlayerController] getRecipeIconType
--
-- @param #ModelRecipe recipe
--
-- @return #string recipe type
--
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

-------------------------------------------------------------------------------
-- Return item type
--
-- @function [parent=#PlayerController] getItemIconType
--
-- @param #table factorio prototype
--
-- @return #string item type
--
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
