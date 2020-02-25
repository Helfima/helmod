local value = string.find("pure-natural-gas","pure-natural-gas",1,true)
print(value)


local gameDay = {day=12500,dust=5000,night=2500,dawn=2500}
local dark_time = (gameDay.dust/2 + gameDay.night + gameDay.dawn / 2 )
print(dark_time/60)
