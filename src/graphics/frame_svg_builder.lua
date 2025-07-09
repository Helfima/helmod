--- Icon builder use svg and inkscape
--- build=false skip to not rebuild Icon
--- paths = {{background},{foreground}}
--- -> put a list of path or polygon
--- -> for path {d="...",transform="rotate(-45.001 2.5 2.5)"} transform is optionnal
--- -> for polygon {p="...",transform="scale(0.5)"} transform is optionnal
--- at the end file you can change some parameter
--- -> for rebuild all change this at true: local force_build = false
--- -> for locate inkscape change: local inkscape = "E:\\Autre\\inkscape\\bin\\inkscape"

require("./core/global")
local Color = require("./core/Color")

local test = Color.from_HTML("#FFDDA0")
local h, s, v = Color.to_HSV(test)
local verif = Color.from_HSV(h, s, v)
local html = Color.to_HTML(test)
local stop=0
-------------------------------------------------------------------------------
--- builder functions
local function create_path(svg, x0, y0, color)
    local color1 = Color.from_HTML(color.value)
    local h, s, v = Color.to_HSV(color1)
    local path = string.format("<path d=\"M%s,%sh7v7h-7\" fill=\"%s\"/>", x0, y0, Color.to_HTML(color1))
    table.insert(svg, path)

    local color2 = Color.from_HSV(h, s, v * 0.6)
    --color2 = Color.multiply(color1, 0.52)
    local color_html2 = Color.to_HTML(color2)
    local path = string.format("<path d=\"M%s,%sh7v7h-7\" fill=\"%s\"/>", x0 + 8, y0, color_html2)
    table.insert(svg, path)

    local color3 = Color.from_HSV(h, s, v * 0.5)
    --color3 = Color.multiply(color2, 0.52)
    local color_html3 = Color.to_HTML(color3)
    local path = string.format("<path d=\"M%s,%sh7v7h-7\" fill=\"%s\"/>", x0 + 16, y0, color_html3)
    table.insert(svg, path)

    local color4 = Color.from_HSV(h, s, v * 0.4)
    --color4 = Color.multiply(color3, 0.52)
    local color_html4 = Color.to_HTML(color4)
    local path = string.format("<path d=\"M%s,%sh7v7h-7\" fill=\"%s\"/>", x0 + 24, y0, color_html4)
    table.insert(svg, path)
end

local function create_svg(colors)
    local height = #colors * 8
    local width = 32
    local svg = {}
    table.insert(svg, string.format("<svg viewBox=\"0 0 %s %s\" xmlns=\"http://www.w3.org/2000/svg\" xmlns:svg=\"http://www.w3.org/2000/svg\">", width, height))
    table.insert(svg, "<g>")

    for i, color in ipairs(colors) do
        create_path(svg, 0, i * 8 - 8, color)
    end

    table.insert(svg, "</g>")
    table.insert(svg, "</svg>")
    local text = table.concat(svg,"")
    return text
end

local function write_file(filename, content)
    local file = io.open(filename, "w+")
    file:write(content)
    file:close();
end

local function inkscape_command(inkscape, filename)
    local cmd = string.format("%s --export-type=\"png\" \"%s\"", inkscape, filename)
    os.execute(cmd)
end
-------------------------------------------------------------------------------
local force_build = false
local inkscape = "D:\\Autre\\inkscape\\bin\\inkscape"
local info = debug.getinfo(1)
local current_file=string.gsub(info.source, "/", "\\")
current_file=string.gsub(current_file, "@", "")
local current_dir = string.gsub(current_file, "^(.+\\)[^\\]+$", "%1");

---@see https://fr.wikipedia.org/wiki/Nuancier_de_Munsell
local munsell_colors = {}
table.insert(munsell_colors,{name="10Y", value="#f0ea00"})
table.insert(munsell_colors,{name="5GY", value="#b1d700"})
table.insert(munsell_colors,{name="10GY", value="#00ca24"})
table.insert(munsell_colors,{name="5G", value="#00a877"})
table.insert(munsell_colors,{name="10G", value="#00a78a"})
table.insert(munsell_colors,{name="5BG", value="#00a59c"})
table.insert(munsell_colors,{name="10BG", value="#00a3ac"})
table.insert(munsell_colors,{name="5B", value="#0093af"})
table.insert(munsell_colors,{name="10B", value="#0082b2"})
table.insert(munsell_colors,{name="5PB", value="#006ebf"})
table.insert(munsell_colors,{name="10PB", value="#7d00f8"})
table.insert(munsell_colors,{name="5P", value="#9f00c5"})
table.insert(munsell_colors,{name="10P", value="#b900a6"})
table.insert(munsell_colors,{name="5RP", value="#d00081"})
table.insert(munsell_colors,{name="10RP", value="#e20064"})
table.insert(munsell_colors,{name="5R", value="#f2003c"})
table.insert(munsell_colors,{name="10R", value="#f85900"})
table.insert(munsell_colors,{name="5YR", value="#f28800"})
table.insert(munsell_colors,{name="10YR", value="#f2ab00"})
table.insert(munsell_colors,{name="5Y", value="#efcc00"})

local colors = {}
-- gray
for j = 10, 100, 10 do
    local s = 0
    local v = j / 100
    local name = string.format("G%s", j)
    local lua_color = Color.from_HSV(0, s, v)
    local color = Color.to_HTML(lua_color)
    table.insert(colors,{name=name, value=color})
end

-- color
for i = 0, 359, 5 do
    local name = string.format("T%s", i)
    local lua_color = Color.from_HSV(i, 0.9, 1)
    local color = Color.to_HTML(lua_color)
    table.insert(colors,{name=name, value=color})
end

local choosed_colors = colors

local color_max = 10
local list = {}
for _, munsell_color in pairs(choosed_colors) do
    local name = munsell_color.name
    local color = munsell_color.value
    local lua_color = Color.from_HTML(color)
    for i = 0, color_max - 1, 1 do
        local factor = 1 - 0.075 * i
        local saturation = 0.8
        local new_lua_color = Color.from_HSV(lua_color.h, lua_color.s * saturation, lua_color.v * factor)
        local new_color = Color.to_HTML(new_lua_color)
        local entry = {name=name, value=new_color, index=i+1}
        table.insert(list,entry)
    end
end


-------------------------------------------------------------------------------
--- Image builder
local content = create_svg(list)
local path = string.format("%s\\frame.svg", current_dir)
write_file(path, content)
inkscape_command(inkscape, path)
os.remove(path)


-------------------------------------------------------------------------------
--- Defines builder
--- Put this result in defines.lua file
print("===== defines.lua =====")
local defines_builded = {}
table.insert(defines_builded, "defines.frame_colors = {}")
for _, color in pairs(choosed_colors) do
    local array = string.format("defines.frame_colors[\"%s\"] = {}", color.name)
    table.insert(defines_builded, array)
    for i = 0, color_max - 1, 1 do
        local name = string.format("%s_%s", color.name, i+1)
        local array = string.format("defines.frame_colors[\"%s\"][%s] = \"%s\"", color.name, i+1, name)
        table.insert(defines_builded, array)
    end
end
local path = string.format("%s..\\core\\defines_builded2.lua", current_dir)
local defines_content = table.concat(defines_builded,"\n")
write_file(path, defines_content)
