Format = require "core.Format"

print("value","=>round by helfima|round by i2um1|round by Ramarren") 
for val=1, 100 do
  value = val/100000
  print(value,"=>",Format.round3(value,2,1))	
end


