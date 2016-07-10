local type_excluded = {}
type_excluded["ambient-sound"] = true
type_excluded["arrow"] = true
type_excluded["corpse"] = true
type_excluded["damage-type"] = true
type_excluded["decorative"] = true
type_excluded["entity-ghost"] = true
type_excluded["explosion"] = true
type_excluded["font"] = true
type_excluded["gate"] = true
type_excluded["gui-style"] = true
type_excluded["leaf-particle"] = true
type_excluded["map-settings"] = true
type_excluded["noise-layer"] = true
type_excluded["particle"] = true
type_excluded["particle-source"] = true
type_excluded["player"] = true
type_excluded["player-port"] = true
type_excluded["smoke"] = true
type_excluded["technology"] = true
type_excluded["tile"] = true
type_excluded["tile-ghost"] = true
type_excluded["tree"] = true
type_excluded["virtual-signal"] = true

-- 1. loop types
-- 2. find "item" kind of type by checking stack_size
-- 3. create icon style for every "item"
-- 0.12.1 support for fluid icons => take icon from all fluid types.


--
-- @see https://forums.factorio.com/viewtopic.php?f=28&t=24292
--

function sprite(filename, size, scale, shift, position)
	return {
		filename = filename,
		priority = "extra-high-no-scale",
		--priority = "extra-high",
		align = "center",
		width = size,
		height = size,
		scale = scale,
		shift = shift,
		x = position.x,
		y = position.y
	}
end

function spriteIcon(filename, size, scale, shift, position)
	return {
		type = "sprite",
		sprite = sprite(filename, size, scale, shift, position)
	}
end

function monolithIcon(filename, size, scale, shift, position)
	return {
		type = "monolith",
		monolith_image = sprite(filename, size, scale, shift, position)
	}
end

--
-- @see https://forums.factorio.com/viewtopic.php?f=28&t=24294
--
function layeredIcon (filename, size, scale, shift, position)
	return {
		type = "layered",
		layers = {
			{ -- the border and background are a composition
				type = "composition",
				filename = "__core__/graphics/gui.png",
				corner_size = {3, 3},
				position = {0, 0}
			},
			{
				type = "monolith",
				monolith_image = sprite(filename, size, scale, shift, position)
			}
		}
	}
end

--
-- @see https://forums.factorio.com/viewtopic.php?f=34&t=24007
--

local function addCheckboxStyleX32(name,icon,iconSize)
	local iconSize = 32
	local size = iconSize
	local offset = 10
	data.raw["gui-style"].default[name] = {
		type = "checkbox_style",
		parent = "checkbox_style",
		width = iconSize,
		height = iconSize,

		default_background = sprite("__core__/graphics/gui.png", 36, size/18, {10,0}, {x=111,y=0}),
		hovered_background = sprite("__core__/graphics/gui.png", 36, size/18, {10,0}, {x=148,y=0}),
		clicked_background = sprite("__core__/graphics/gui.png", 36, size/18, {10,0}, {x=184,y=0}),
		disabled_background = sprite("__core__/graphics/gui.png", 36, size/18, {10,0}, {x=111,y=0}),
		checked = sprite(icon, iconSize, 0.7, {3,0}, {x=0,y=0})
	}
end

local function addCheckboxStyleX64(name,icon,iconSize)
	local iconSize = 64
	local size = iconSize + 4
	data.raw["gui-style"].default[name] = {
		type = "checkbox_style",
		parent = "checkbox_style",
		width = iconSize,
		height = iconSize,

		default_background = sprite("__core__/graphics/gui.png", 36, size/18, {30,2}, {x=111,y=0}),
		hovered_background = sprite("__core__/graphics/gui.png", 36, size/18, {30,0}, {x=148,y=0}),
		clicked_background = sprite("__core__/graphics/gui.png", 36, size/18, {30,0}, {x=184,y=0}),
		disabled_background = sprite("__core__/graphics/gui.png", 36, size/18, {30,0}, {x=111,y=0}),
		checked = sprite(icon, size, 0.7, {30, 0}, {x=0,y=0})
	}
end

local function addButtonStyleX32(name,icon)
	local iconSize = 32
	data.raw["gui-style"].default[name] =
		{
			type = "button_style",
			parent = "helmod_button-default",
			font = "helmod_font-icon",
			align = "right",
			top_padding = 0,
			right_padding = 0,
			bottom_padding = 0,
			left_padding = 0,
			
			scalable = false,
			
			width = iconSize,
			height = iconSize,
			default_graphical_set = monolithIcon(icon, iconSize, 1, {0,0}, {x=0,y=0}),
			hovered_graphical_set = monolithIcon(icon, iconSize, 1, {0,0}, {x=0,y=0}),
			clicked_graphical_set = monolithIcon(icon, iconSize, 1, {0,0}, {x=0,y=0}),
			disabled_graphical_set = monolithIcon(icon, iconSize, 1, {0,0}, {x=0,y=0})
		}
end

for name, icon in pairs(helmod_icons) do
	addButtonStyleX32("helmod_button_item_"..name, icon)
	addCheckboxStyleX32("helmod_checkbox_item_"..name, icon)
end

local noicontypes = {}
local matchtypes = {}

for typename, sometype in pairs(data.raw) do
	--local _, object = next(sometype)
	--if object.stack_size or typename == "fluid" then
	if type_excluded[typename] ~= true then
		for name, item in pairs(sometype) do
			if item.icon then
				if matchtypes[name] == nil then
					matchtypes[name] = typename
				end

				addButtonStyleX32("helmod_button_"..typename.."_"..name, item.icon)
				addCheckboxStyleX32("helmod_checkbox_"..typename.."_"..name, item.icon)
				if typename == "item-group" then
					addCheckboxStyleX64("helmod_checkbox_"..typename.."_"..name, item.icon)
				end
			elseif item.result ~= nil then
				noicontypes[name]={type=typename, result=item.result}
			elseif item.results ~= nil then
				local _, result = next(item.results)
				noicontypes[name]={type=typename, result=result.name}
			end
		end
	end
end

for name, sometype in pairs(noicontypes) do
	local typename = matchtypes[sometype.result]
	if typename ~= nil then
		local item = data.raw[typename][sometype.result]
		if item ~= nil and item.icon ~= nil then
			--if sometype.result == "repair-pack" then error(name..":"..sometype.result.."/"..item.icon) end
			addButtonStyleX32("helmod_button_"..sometype.type.."_"..name, item.icon)
			addCheckboxStyleX32("helmod_checkbox_"..sometype.type.."_"..name, item.icon)
		end
	end

end
