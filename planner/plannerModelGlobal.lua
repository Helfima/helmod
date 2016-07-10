-------------------------------------------------------------------------------
-- Classe model
--
-- @module ModelGlobal
--
ModelGlobal = setclass("HMModelGlobal")

-------------------------------------------------------------------------------
-- Initialize model
--
-- @function [parent=#ModelGlobal] init
--
function ModelGlobal.methods:init()
	self.factories = {}
	self.beacons = {}
	self.recipes = {}
end

-------------------------------------------------------------------------------
-- Get default beacon
--
-- @function [parent=#ModelGlobal] getBeacon
--
function ModelGlobal.methods:getBeacon(name)
	if self.beacons[name] == nil then
		self.beacons = helmod_defines.beacon
	end
	return self.beacons[name]
end

-------------------------------------------------------------------------------
-- Get default factory
--
-- @function [parent=#ModelGlobal] getFactory
--
function ModelGlobal.methods:getFactory(name)
	if self.factories[name] == nil then
		self.factories = helmod_defines.factory
	end
	return self.factories[name]
end

-------------------------------------------------------------------------------
-- Get a recipe
--
-- @function [parent=#ModelGlobal] getRecipe
--
-- @param #string key recipe name
--
function ModelGlobal.methods:getRecipe(key)
	if self.recipes[key] == nil then
		self.recipes[key] = {
			name = key,
			active = true,
			factory = nil,
			beacon = nil
		}
	end
	return self.recipes[key]
end

-------------------------------------------------------------------------------
-- Active/desactive a recipe
--
-- @function [parent=#ModelGlobal] setActiveRecipe
--
-- @param #string key recipe name
--
function ModelGlobal.methods:setActiveRecipe(key)
	local recipe = self:getRecipe(key)
	recipe.active = not(recipe.active)
end

-------------------------------------------------------------------------------
-- Check is active recipe
--
-- @function [parent=#ModelGlobal] isActiveRecipe
--
-- @param #string key recipe name
--
function ModelGlobal.methods:isActiveRecipe(key)
	if self.recipes[key] == nil then
		return true
	end
	return self.recipes[key].active
end

-------------------------------------------------------------------------------
-- Count disabled recipes
--
-- @function [parent=#ModelGlobal] countDisabledRecipes
--
-- @return #number
--
function ModelGlobal.methods:countDisabledRecipes()
	local count = 0
	for _ , recipe in pairs(self.recipes) do
		if recipe.active == false then
			count = count + 1
		end
	end
	return count
end


-------------------------------------------------------------------------------
-- Set a factory for recipe
--
-- @function [parent=#ModelGlobal] setFactoryRecipe
--
-- @param #string key recipe name
-- @param #string name factory name
--
function ModelGlobal.methods:setFactoryRecipe(key, name)
	local recipe = self:getRecipe(key)
	recipe.factory = name
end

-------------------------------------------------------------------------------
-- Get the factory of recipe
--
-- @function [parent=#ModelGlobal] getFactoryRecipe
--
-- @param #string key recipe name
--
function ModelGlobal.methods:getFactoryRecipe(key)
	if self.recipes[key] == nil then
		return nil
	end
	return self.recipes[key].factory
end

-------------------------------------------------------------------------------
-- Set a beacon for recipe
--
-- @function [parent=#ModelGlobal] setBeaconRecipe
--
-- @param #string key recipe name
-- @param #string name factory name
--
function ModelGlobal.methods:setBeaconRecipe(key, name)
	local recipe = self:getRecipe(key)
	recipe.beacon = name
end

-------------------------------------------------------------------------------
-- Get the beacon of recipe
--
-- @function [parent=#ModelGlobal] getBeaconRecipe
--
-- @param #string key recipe name
--
function ModelGlobal.methods:getBeaconRecipe(key)
	if self.recipes[key] == nil then
		return nil
	end
	return self.recipes[key].beacon
end


