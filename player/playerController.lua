require "speed.speedController"
require "planner.plannerController"

local data_entity = nil

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
function PlayerController.methods:init()
	self.prefix = "helmod_"
	-- list des controllers
	self.controllers = {}
	self.controllers["planner-controller"] = PlannerController:new(self)
	self.controllers["speed-controller"] = SpeedController:new(self)
end

-------------------------------------------------------------------------------
-- Bind all controllers
--
-- @function [parent=#PlayerController] bindController
--
-- @param #LuaPlayer player
--
function PlayerController.methods:bindController(player)
	Logging:debug("PlayerController:bindController(player)")
	-- reset GUI
	self:resetGui(player)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:cleanController(player)
			controller:bindController(player)
		end
	end
end

-------------------------------------------------------------------------------
-- Initialize gui
--
-- @function [parent=#PlayerController] resetGui
--
-- @param #LuaPlayer player
--
function PlayerController.methods:resetGui(player)
	Logging:debug("PlayerController:resetGui(player)")
	if player.gui.top["helmod_menu-main"] ~= nil then
		player.gui.top["helmod_menu-main"].destroy()
	end
	player.gui.top.add{type="flow", name="helmod_menu-main", direction="horizontal"}
end

-------------------------------------------------------------------------------
-- Get gui
--
-- @function [parent=#PlayerController] getGui
--
-- @param #LuaPlayer player
--
function PlayerController.methods:getGui(player)
	return player.gui.top["helmod_menu-main"]
end

-------------------------------------------------------------------------------
-- On click event
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
-- On text change event
--
-- @function [parent=#PlayerController] on_gui_text_changed
--
-- @param event
--
function PlayerController.methods:on_gui_text_changed(event)
	if self.controllers ~= nil then
		for r, controller in pairs(self.controllers) do
			controller:on_gui_text_changed(event)
		end
	end
end

-------------------------------------------------------------------------------
-- Return force's player
--
-- @function [parent=#PlayerController] getForce
--
-- @param #LuaPlayer player
--
-- @return #table force
--
function PlayerController.methods:getForce(player)
	if player == nil then Logging:error("PlayerController:getRecipes(player): player can not be nil") end
	return player.force
end

-------------------------------------------------------------------------------
-- Get global variable for player
--
-- @function [parent=#PlayerController] getGlobal
--
-- @param #LuaPlayer player
-- @param #string key
--
-- @return #table global
--
function PlayerController.methods:getGlobal(player, key)
	if global["HMModel"] == nil then
		global["HMModel"] = {}
	end
	if global["HMModel"][player.name] == nil then
		global["HMModel"][player.name] = {}
	end

	if global["HMModel"][player.name].settings == nil then
		self:initGlobalSettings(player)
	end

	if key ~= nil then
		if global["HMModel"][player.name][key] == nil then
			global["HMModel"][player.name][key] = {}
		end
		return global["HMModel"][player.name][key]
	end
	return global["HMModel"][player.name]
end

-------------------------------------------------------------------------------
-- Init global settings
--
-- @function [parent=#PlayerController] initGlobalSettings
--
-- @param #LuaPlayer player
--
function PlayerController.methods:initGlobalSettings(player)
	global["HMModel"][player.name].settings = self:getDefaultSettings()
end

-------------------------------------------------------------------------------
-- Get default settings
--
-- @function [parent=#PlayerController] getDefaultSettings
--
-- @param #LuaPlayer player
--
function PlayerController.methods:getDefaultSettings()
	return {
		display_size = "1680x1050",
		display_product_cols = 2,
		display_ingredient_cols = 2,
		display_data_col_name = false,
		display_data_col_id = false,
		display_data_col_index = false,
		display_data_col_level = false,
		display_data_col_weight = false,
		model_auto_compute = false,
		model_loop_limit = 1000,
		model_filter_factory = true,
		model_filter_beacon = true,
		other_speed_panel=false,
		real_name=false,
		filter_show_hidden=false
	}
end

-------------------------------------------------------------------------------
-- Get global gui
--
-- @function [parent=#PlayerController] getGlobalGui
--
-- @param #LuaPlayer player
--
function PlayerController.methods:getGlobalGui(player)
	return self:getGlobal(player, "gui")
end

-------------------------------------------------------------------------------
-- Get global settings
--
-- @function [parent=#PlayerController] getGlobalSettings
--
-- @param #LuaPlayer player
--
function PlayerController.methods:getGlobalSettings(player, property)
	local settings = self:getGlobal(player, "settings")
	if settings ~= nil and property ~= nil then
		local guiProperty = settings[property]
		if guiProperty == nil then
			guiProperty = self:getDefaultSettings()[property]
		end
		return guiProperty
	end
	return settings
end

-------------------------------------------------------------------------------
-- Get sorted style
--
-- @function [parent=#PlayerController] getSortedStyle
--
-- @param #LuaPlayer player
-- @param #string key
--
-- @return #string style
--
function PlayerController.methods:getSortedStyle(player, key)
	local globalGui = self:getGlobalGui(player)
	if globalGui.order == nil then globalGui.order = {name="index",ascendant="true"} end
	local style = "helmod_button-sorted-none"
	if globalGui.order.name == key and globalGui.order.ascendant then style = "helmod_button-sorted-up" end
	if globalGui.order.name == key and not(globalGui.order.ascendant) then style = "helmod_button-sorted-down" end
	return style
end

-------------------------------------------------------------------------------
-- Return recipes
--
-- @function [parent=#PlayerController] getRecipes
--
-- @param #LuaPlayer player
--
-- @return #table recipes
--
function PlayerController.methods:getRecipes(player)
	if player == nil then Logging:error("PlayerController:getRecipes(player): player can not be nil") end
	return self:getForce(player).recipes
end

-------------------------------------------------------------------------------
-- Return recipe groups
--
-- @function [parent=#PlayerController] getRecipeGroups
--
-- @param #LuaPlayer player
--
-- @return #table recipe groups
--
function PlayerController.methods:getRecipeGroups(player)
	-- recuperation des groupes avec les recipes
	local recipeGroups = {}
	for key, recipe in pairs(self:getRecipes(player)) do
		if recipe.group ~= nil then
			if recipeGroups[recipe.group.name] == nil then recipeGroups[recipe.group.name] = {} end
			table.insert(recipeGroups[recipe.group.name], recipe.name)
		end
	end
	return recipeGroups
end

-------------------------------------------------------------------------------
-- Return recipe subgroups
--
-- @function [parent=#PlayerController] getRecipeSubgroups
--
-- @param #LuaPlayer player
--
-- @return #table recipe subgroups
--
function PlayerController.methods:getRecipeSubgroups(player)
	-- recuperation des groupes avec les recipes
	local recipeSubgroups = {}
	for key, recipe in pairs(self:getRecipes(player)) do
		if recipe.subgroup ~= nil then
			if recipeSubgroups[recipe.subgroup.name] == nil then recipeSubgroups[recipe.subgroup.name] = {} end
			table.insert(recipeSubgroups[recipe.subgroup.name], recipe.name)
		end
	end
	return recipeSubgroups
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
		if check then
			groups[group.name] = group
		end
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
	local productions = {}
	for key, item in pairs(game.entity_prototypes) do
		if item.type ~= nil and helmod_defines.production_groups[item.type] ~= nil then
			productions[item.name] = item
		end
	end
	return productions
end

-------------------------------------------------------------------------------
-- Return list of productions
--
-- @function [parent=#PlayerController] getProductionsCrafting
--
-- @param #string category filter
--
-- @return #table list of productions
--
function PlayerController.methods:getProductionsCrafting(category)
	Logging:trace("PlayerController:getProductionsCrafting(category)", category)
	local productions = {}
	for key, item in pairs(game.entity_prototypes) do
		if item.type ~= nil then
			Logging:trace("PlayerController:getProductionsCrafting(category):item", item.name, item.type, item.group.name, item.subgroup.name)
			local check = false
			if category ~= nil then
				local categories = self:getItemProperty(item.name, "crafting_categories")
				if categories ~= nil then
					for c, value in pairs(categories) do
						if category == value then check = true end
					end
				end
			else
				if item.group ~= nil and item.group.name == "production" then
					check = true
				end
			end
			if check then
				productions[item.name] = item
			end
		end
	end
	return productions
end

-------------------------------------------------------------------------------
-- Return list of productions
--
-- @function [parent=#PlayerController] getProductionsRessource
--
-- @param #string category filter
--
-- @return #table list of productions
--
function PlayerController.methods:getProductionsRessource(category)
	Logging:trace("PlayerController:getProductionsRessource(category)", category)
	local productions = {}
	for key, item in pairs(game.entity_prototypes) do
		if item.type ~= nil then
			Logging:trace("PlayerController:getProductionsRessource(category):item", item.name, item.type, item.group.name, item.subgroup.name)
			local check = false
			if category ~= nil then
				local categories = self:getItemProperty(item.name, "resource_categories")
				if categories ~= nil then
					for c, value in pairs(categories) do
						if category == value then check = true end
					end
				end
			else
				if item.group ~= nil and item.group.name == "production" then
					check = true
				end
			end
			if check then
				productions[item.name] = item
			end
		end
	end
	return productions
end

-------------------------------------------------------------------------------
-- Return list of modules
--
-- @function [parent=#PlayerController] getModules
--
-- @return #table list of modules
--
function PlayerController.methods:getModules()
	-- recuperation des groupes
	local modules = {}
	for key, item in pairs(game.item_prototypes) do
		if item.type ~= nil and item.type == "module" then
			modules[item.name] = item
		end
	end
	return modules
end

-------------------------------------------------------------------------------
-- Return recipe
--
-- @function [parent=#PlayerController] getRecipe
--
-- @param #LuaPlayer player
-- @param #string recipe name
--
-- @return #LuaRecipe recipe
--
function PlayerController.methods:getRecipe(player, name)
	return self:getForce(player).recipes[name]
end

-------------------------------------------------------------------------------
-- Return list of recipes
--
-- @function [parent=#PlayerController] searchRecipe
--
-- @param #LuaPlayer player
-- @param #string recipe name
--
-- @return #table list of recipes
--
function PlayerController.methods:searchRecipe(player, name)
	local recipes = {}
	-- recherche dans les produits des recipes
	for key, recipe in pairs(self:getRecipes(player)) do
		for k, product in pairs(recipe.products) do
			if product.name == name then
				table.insert(recipes,recipe)
			end
		end
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
-- @param #LuaPlayer player
--
function PlayerController.methods:unlockRecipes(player)
	self:getForce(player).enable_all_recipes()
end

-------------------------------------------------------------------------------
-- Lock Recipes
--
-- @function [parent=#PlayerController] lockRecipes
--
-- @param #LuaPlayer player
--
function PlayerController.methods:lockRecipes(player)
	self:getForce(player).reset_recipes()
end

-------------------------------------------------------------------------------
-- Return icon type
--
-- @function [parent=#PlayerController] getIconType
--
-- @param #ModelRecipe element
--
-- @return #string recipe type
--
function PlayerController.methods:getIconType(element)
	local item = self:getItemPrototype(element.name)
	if item ~= nil then
		return "item"
	end
	local fluid = self:getFluidPrototype(element.name)
	if fluid ~= nil then
		return "fluid"
	end
	local entity = self:getEntityPrototype(element.name)
	if entity ~= nil then
		return "entity"
	end
	return "recipe"
end

-------------------------------------------------------------------------------
-- Return recipe type
--
-- @function [parent=#PlayerController] getRecipeIconType
--
-- @param #LuaPlayer player
-- @param #ModelRecipe recipe
--
-- @return #string recipe type
--
function PlayerController.methods:getRecipeIconType(player, recipe)
	local recipe = self:getRecipe(player, recipe.name)
	if recipe ~= nil then
		return "recipe"
	end
	return self:getIconType(recipe);
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

-------------------------------------------------------------------------------
-- Return module bonus (default return: bonus = 0 )
--
-- @function [parent=#PlayerController] getModuleBonus
--
-- @param #string module module name
-- @param #string effect effect name
--
-- @return #number
--
function PlayerController.methods:getModuleBonus(module, effect)
	local bonus = 0
	-- search module
	local module = self:getItemPrototype(module)
	if module ~= nil and module.module_effects[effect] ~= nil then
		bonus = module.module_effects[effect].bonus
	end
	return bonus
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#PlayerController] getLocalisedName
--
-- @param #LuaPlayer player
-- @param #table element factorio prototype
--
-- @return #string localised name
--
function PlayerController.methods:getLocalisedName(player, element)
	Logging:debug("PlayerController:getLocalisedName(player, element)", player, element)
	local globalSettings = self:getGlobal(player, "settings")
	if globalSettings.real_name == true then
		return element.name
	end
	local localisedName = element.name
	if element.type ~= nil then
		if element.type == 0 or element.type == "item" then
			local item = self:getItemPrototype(element.name)
			if item ~= nil then
				localisedName = item.localised_name
			end
		end
		if element.type == 1 or element.type == "fluid" then
			local item = self:getFluidPrototype(element.name)
			if item ~= nil then
				localisedName = item.localised_name
			end
		end
	end
	return localisedName
end

-------------------------------------------------------------------------------
-- Return localised name
--
-- @function [parent=#PlayerController] getRecipeLocalisedName
--
-- @param #LuaPlayer player
-- @param #table element factorio prototype
--
-- @return #string localised name
--
function PlayerController.methods:getRecipeLocalisedName(player, recipe)
	local globalSettings = self:getGlobal(player, "settings")
	local _recipe = self:getRecipe(player, recipe.name)
	if _recipe ~= nil and globalSettings.real_name ~= true then
		return _recipe.localised_name
	end
	return recipe.name
end

-------------------------------------------------------------------------------
-- Return item property
--
-- @function [parent=#PlayerController] getItemProperty
--
-- @param #string name
-- @param #string property
--
function PlayerController.methods:getItemProperty(name, property)
	Logging:trace("PlayerController:getItemProperty(name, property)", name, property)
	if data_entity == nil then
		data_entity = loadstring(game.entity_prototypes["data_entity"].order)()
		Logging:trace("PlayerController:getItemProperty(name, property):data_entity", data_entity)
	end
	if data_entity[name] then
		if property == "energy_usage" then
			if data_entity[name]["energy_usage"] ~= nil then
				local value = string.match(data_entity[name]["energy_usage"],"[0-9.]*",1)
				return tonumber(value)
			else
				return 0
			end
		elseif property == "module_slots" then
			if data_entity[name]["module_specification"] ~= nil then
				return tonumber(data_entity[name]["module_specification"]["module_slots"])
			else
				return 0
			end
		elseif property == "crafting_speed" then
			if data_entity[name]["crafting_speed"] ~= nil then
				return tonumber(data_entity[name]["crafting_speed"])
			else
				return 0
			end
		elseif property == "mining_speed" then
			if data_entity[name]["mining_speed"] ~= nil then
				return tonumber(data_entity[name]["mining_speed"])
			else
				return 0
			end
		elseif property == "mining_power" then
			if data_entity[name]["mining_power"] ~= nil then
				return tonumber(data_entity[name]["mining_power"])
			else
				return 0
			end
		else
			return data_entity[name][property]
		end
	end
	return nil
end





	



