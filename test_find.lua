local operation = 10

function numberToBinStr(x)
  ret=""
  while x~=1 and x~=0 do
    ret=tostring(x%2)..ret
    x=math.modf(x/2)
  end
  ret=tostring(x)..ret
  return ret
end

print(string.format("%s",numberToBinStr(operation)))

local v1,v2,v3 = string.match("0.9.3", "([0-9]+)[.]([0-9]+)[.]([0-9]+)")

print(string.format("%s",numberToBinStr(operation)))