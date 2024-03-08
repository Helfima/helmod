---@class LuaColor
---@field r uint value [0-255]
---@field g uint value [0-255]
---@field b uint value [0-255]
---@field a uint value [0-255]
---@field h uint value [0-360]
---@field s number  value [0-1]
---@field v number  value [0-1]

function math.clamp(value, min, max)
    if value > max then value = max end
    if value < min then value = min end
    return value;
end


local function hue(H)
    local x = math.abs(H * 6 - 3) - 1
    local y = 2 - math.abs(H * 6 - 2)
    local z = 2 - math.abs(H * 6 - 4)
    local vector = {
        x = math.clamp(x, 0 , 1),
        y = math.clamp(y, 0 , 1),
        z = math.clamp(z, 0 , 1)
    }
    return vector
end

---
---Description of the module.
---@class Color
local Color = {
    ---single-line comment
    classname = "HMColor"
}

---Create new LuaColor
---@param r uint
---@param g uint
---@param b uint
---@param a? uint
---@return LuaColor
function Color.new_color_int(r, g, b, a)
    local H,S,V = Color.RGB_to_HSV( r, g, b )
    return {
        r = r or 0,
        g = g or 0,
        b = b or 0,
        a = a or 255,
        h = H,
        s = S,
        v = V
    }
end

function Color.multiply(lua_color, factor)
    local r = math.clamp(lua_color.r * factor, 0 , 255)
    local g = math.clamp(lua_color.g * factor, 0 , 255)
    local b = math.clamp(lua_color.b * factor, 0 , 255)
    return Color.new_color_int(r, g, b)
end

---Get color from hex value
---@param html_string string
---@return LuaColor | nil
function Color.from_HTML(html_string)
    if html_string ~= nil then
        if string.len(html_string) == 7 then
            local r = tonumber(string.sub(html_string, 2, 3), 16)
            local g = tonumber(string.sub(html_string, 4, 5), 16)
            local b = tonumber(string.sub(html_string, 6, 7), 16)
            return Color.new_color_int(r, g, b)
        else
            local text1 = string.sub(html_string, 2, 2)
            local text2 = string.sub(html_string, 3, 3)
            local text3 = string.sub(html_string, 4, 4)
            local list = {}
            table.insert(list, "#")
            table.insert(list, text1)
            table.insert(list, text1)
            table.insert(list, text2)
            table.insert(list, text2)
            table.insert(list, text3)
            table.insert(list, text3)
            html_string = table.concat(list,"")
            return Color.from_HTML(html_string)
        end
    end
    return nil
end

function Color.to_HSV( lua_color )
    return Color.RGB_to_HSV( lua_color.r, lua_color.g, lua_color.b )
end

function Color.RGB_to_HSV( r, g, b )
	-- normalize values RGB
    local nr = r/255
    local ng = g/255
    local nb = b/255
     
    local Cmax = math.max(nr, ng, nb)
    local Cmin = math.min(nr, ng, nb)
    local delta = Cmax - Cmin

    -- Hue calculation
    local H = 0
    if delta ~= 0 then
        if Cmax == nr then
            H = 60 * (((ng-nb)/delta) % 6)
        elseif Cmax == ng then
            H = 60 * (((nb-nr)/delta) + 2)
        elseif Cmax == nb then
            H = 60 * (((nr-ng)/delta) + 4)
        end

    end

    -- Saturation calculation
    local S = 0
    if Cmax ~= 0 then
        S = delta/Cmax
    end

    -- Value calculation
    local V = Cmax
    
	return H,S,V
end

function Color.from_HSV(h, s, v)
    h = math.clamp(h, 0, 360)
    s = math.clamp(s, 0, 1)
    v = math.clamp(v, 0, 1)
    
    local C = v * s
    local X = C * (1 - math.abs((h / 60) % 2 - 1))
    local m = v - C
    
    local nr = 0
    local ng = 0
    local nb = 0

    if h >= 0 and h < 60 then
        nr = C
        ng = X
        nb = 0
    elseif h >= 60 and h < 120 then
        nr = X
        ng = C
        nb = 0
    elseif h >= 120 and h < 180 then
        nr = 0
        ng = C
        nb = X
    elseif h >= 180 and h < 240 then
        nr = 0
        ng = X
        nb = C
    elseif h >= 240 and h < 300 then
        nr = X
        ng = 0
        nb = C
    elseif h >= 300 and h < 360 then
        nr = C
        ng = 0
        nb = X
    end

    local r = (nr + m) * 255
    local g = (ng + m) * 255
    local b = (nb + m) * 255
    return Color.new_color_int(r, g, b)
end

function Color.to_HTML(lua_color)
    -- EXPLANATION:
    -- The integer form of RGB is 0xRRGGBB
    -- Hex for red is 0xRR0000
    -- Multiply red value by 0x10000(65536) to get 0xRR0000
    -- Hex for green is 0x00GG00
    -- Multiply green value by 0x100(256) to get 0x00GG00
    -- Blue value does not need multiplication.

    -- Final step is to add them together
    -- (r * 0x10000) + (g * 0x100) + b =
    -- 0xRR0000 +
    -- 0x00GG00 +
    -- 0x0000BB =
    -- 0xRRGGBB
    local rgb = (math.floor(lua_color.r) * 0x10000) + (math.floor(lua_color.g) * 0x100) + math.floor(lua_color.b)
    -- %06x format on 6 digits
    local html_value = string.format("%06x", rgb)
    return string.upper("#"..html_value)
end

return Color