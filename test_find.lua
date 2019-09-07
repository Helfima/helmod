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
