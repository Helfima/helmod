-- model de donnees
--===========================
ModelRecipeIndex = 0
ModelRecipe = setclass("HMModelRecipe")
-- initialise
function ModelRecipe.methods:init(name, count)
	if count == nil then count = 1 end
	self.index = ModelRecipeIndex
	self.name = name
	self.count = count
	self.valid = true
	self.energy = 0.5
	self.ingredients = {}
	self.products = {}
	self.factory = ModelFactory:new()
	self.beacon = ModelBeacon:new()
	ModelRecipeIndex = ModelRecipeIndex + 1
end