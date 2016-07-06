require "defines"

debug_level = -1  -- eventually change this in on_load() of the mod
local debug_player = nil

white = {r = 1, g = 1, b = 1}
red = {r = 1, g = 0.3, b = 0.3}
green = {r = 0, g = 1, b = 0}
blue = {r = 0, g = 0, b = 1}
yellow = {r = 1, g = 1, b = 0}
orange = {r = 1, g = 0.5, b = 0}

--------------------------------------------------------------------------------------
function debug( s, lvl )
	if debug_player == nil then
		if game.player then debug_player = game.player end
		end
	
	if debug_mem == nil then debug_mem = {} end
	
	if lvl == nil then lvl = debug_level end
	
	if (debug_level >= 0) and ((lvl >= debug_level) or (lvl == 0)) then 
		if debug_player then
			if #debug_mem > 0 then
				for _, m in pairs( debug_mem ) do
					debug_player.print(m)
				end
				debug_mem = {}
			end
			if s ~= nil then debug_player.print(s) end
		else
			table.insert( debug_mem, s )
		end
	end
end

--------------------------------------------------------------------------------------
function square_area( origin, radius )
	return {
		{x=origin.x - radius, y=origin.y - radius},
		{x=origin.x + radius, y=origin.y + radius}
	}
end

--------------------------------------------------------------------------------------
function min( val1, val2 )
	if val1 < val2 then
		return val1
	else
		return val2
	end
end

--------------------------------------------------------------------------------------
function max( val1, val2 )
	if val1 > val2 then
		return val1
	else
		return val2
	end
end

--------------------------------------------------------------------------------------
function iif( cond, val1, val2 )
	if cond then
		return val1
	else
		return val2
	end
end