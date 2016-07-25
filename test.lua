require "core.class"

--===========================

cAnimal=setclass("Animal")

function cAnimal.methods:init(action, cutename)
	self.superaction = action
	self.supercutename = cutename
end

--==========================

cTiger=setclass("Tiger", cAnimal)

function cTiger.methods:init(cutename)
	self:init_super("HUNT (Tiger)", "Zoo Animal (Tiger)")
	self.action = "ROAR FOR ME!!"
	self.cutename = cutename
end

--==========================

Tiger1 = cAnimal:new("HUNT", "Zoo Animal")
Tiger2 = cTiger:new("Mr Grumpy")
Tiger3 = cTiger:new("Mr Hungry")

print("CLASSNAME FOR TIGER1 = ", Tiger1:classname())
print("CLASSNAME FOR TIGER2 = ", Tiger2:classname())
print("CLASSNAME FOR TIGER3 = ", Tiger3:classname())
print("===============")
print("SUPER ACTION",Tiger1.superaction)
print("SUPER CUTENAME",Tiger1.supercutename)
print("ACTION        ",Tiger1.action)
print("CUTENAME",Tiger1.cutename)
print("===============")
print("SUPER ACTION",Tiger2.superaction)
print("SUPER CUTENAME",Tiger2.supercutename)
print("ACTION        ",Tiger2.action)
print("CUTENAME",Tiger2.cutename)
print("===============")
print("SUPER ACTION",Tiger3.superaction)
print("SUPER CUTENAME",Tiger3.supercutename)
print("ACTION        ",Tiger3.action)
print("CUTENAME",Tiger3.cutename)

model = {}
model.recipes = {}
model.recipes["steel-plate"] = {name = "steel-plate", level = 3, index = 1}
model.recipes["low-density-structure"] = {name = "low-density-structure", level = 2, index = 2}
model.recipes["rocket-part"] = {name = "rocket-part", level = 1, index = 3}

function spairs(t, order)
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	if order then
		table.sort(keys, function(a,b) return order(t, a, b) end)
	else
		table.sort(keys)
	end

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

for k, recipe in spairs(model.recipes, function(t,a,b) return t[b].level > t[a].level end) do
	print("===============")
	print("recipe.name",recipe.name)
	print("recipe.level",recipe.level)
end
