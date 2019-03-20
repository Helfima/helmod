
local text = "HMMainTab=product-edition=ID=block_1"

local pattern = "([^=]*)=?([^=]*)=?[^=]*=?([^=]*)=?([^=]*)=?([^=]*)"
local classname, action, item1, item2, item3 = string.match(text,pattern)
print(classname)
print(action)
print(item1)
print(item2)
print(item3=="")

local a={1}
print(rawlen(a))
