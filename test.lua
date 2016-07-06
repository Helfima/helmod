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