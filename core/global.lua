-------------------------------------------------------------------------------
-- Use to iterate over a table.
-- Returns three values: the `next` function, the table `t`, and nil,
-- so that the construction :
-- 
--     for k,v in spairs(t) do *body* end
-- will iterate over all key-value pairs of table `t`.
-- 
--     for k,v in pairs(t, function(t,a,b) return t[b] > t[a] end) do *body* end
-- will iterate over all key-value pairs of table `t` with sorting function.
-- 
--     for k,v in pairs(t, function(t,a,b) return t[b].level > t[a].level end) do *body* end
-- will iterate over all key-value pairs of table `t` with sorting function.
-- 
-- @param #table t table to traverse.
-- @param #function order sort function.

function spairs(t, order)
	-- bypass
	if order == nil then return pairs(t) end
	-- collect the keys
	local keys = {}
	for k in pairs(t) do keys[#keys+1] = k end

	-- if order function given, sort by it by passing the table and keys a, b,
	-- otherwise just sort the keys
	pcall(function()
		table.sort(keys, function(a,b) return order(t, a, b) end)
	end)

	-- return the iterator function
	local i = 0
	return function()
		i = i + 1
		if keys[i] then
			return keys[i], t[keys[i]]
		end
	end
end

-------------------------------------------------------------------------------
-- Return first element of table
--
-- @function first
--
-- @param table
--
-- @return element
--
function first(t)
  for _,v in pairs(t) do
    return v
  end
end
-------------------------------------------------------------------------------
-- formula
--
-- @function formula
--
-- @param operation
--
function formula(operation)
  if operation == nil or operation == "" then return 0 end
  local allowed = false
  for i=1, string.len(operation) do
  	if not(string.find(operation,"[0-9.()/*-+%%^]+",i)) then
  	 error({code=1})
  	end
  end
  return load("return " .. operation)()
end

-------------------------------------------------------------------------------
-- binary to string
--
-- @function toBinStr
--
-- @param binary
--
function toBinStr(x)
  local ret=""
  while x~=1 and x~=0 do
    ret=tostring(x%2)..ret
    x=math.modf(x/2)
  end
  ret=tostring(x)..ret
  return ret
end


function compare_priority(a,b)
  if a == nil or b == nil then return false end
  for k,v in pairs(a) do
    if b[k] == nil then return false end
    if b[k].name ~= v.name or b[k].value ~= v.value then return false end
  end
  return true
end
