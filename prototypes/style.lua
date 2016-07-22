--
-- @see https://forums.factorio.com/viewtopic.php?f=28&t=24292
--

function sprite(filename, size, scale, shift, position)
	return {
		filename = filename,
		priority = "extra-high-no-scale",
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


local default_gui = data.raw["gui-style"].default
local normal_icon_size=36
default_gui["helmod_button-icon"] = {
	type = "button_style",
	parent = "button_style",
	width = normal_icon_size,
	height = normal_icon_size,
	
	scalable = false,
	
	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2,
}

default_gui["helmod_select-button-icon"] = {
	type = "button_style",
	parent = "helmod_button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=0}),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=0}),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0})
}

local xxl_icon_size=68
default_gui["helmod_xxl-button-icon"] = {
	type = "button_style",
	parent = "button_style",
	width = xxl_icon_size,
	height = xxl_icon_size,
	
	scalable = false,
	
	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2,
}

default_gui["helmod_xxl-select-button-icon"] = {
	type = "button_style",
	parent = "helmod_xxl-button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=0}),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=0}),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0})
}


default_gui["helmod_button-default"] = {
	type = "button_style",
	font = "helmod_font-normal",
	default_font_color={r=1, g=1, b=1},
	align = "center",
	top_padding = 5,
	right_padding = 5,
	bottom_padding = 5,
	left_padding = 5,
	minimal_width = 24,
	minimal_height = 24,
	default_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	hovered_font_color={r=1, g=1, b=1},
	hovered_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 8}
	},
	clicked_font_color={r=1, g=1, b=1},
	clicked_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 16}
	},
	disabled_font_color={r=0.5, g=0.5, b=0.5},
	disabled_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {0, 0}
	},
	pie_progress_color = {r=1, g=1, b=1}
}

default_gui["helmod_button-small-bold"] = {
	type = "button_style",
	parent = "helmod_button-default",
	font = "helmod_font-normal-bold",

	minimal_width = 24,
	height = 24,

	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2
}

default_gui["helmod_page-label"] = {
	type = "label_style",
      parent = "label_style",
	top_padding = 6,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2
}


      
default_gui["helmod_button-small-bold-start"] = {
	type = "button_style",
	parent = "helmod_button-default",
	font = "helmod_font-normal-bold",

	width = 24,
	height = 24,

	top_padding = 2,
	right_padding = 0,
	bottom_padding = 2,
	left_padding = 2
}

default_gui["helmod_button-small-bold-middle"] = {
	type = "button_style",
	parent = "helmod_button-default",
	font = "helmod_font-normal-bold",

	width = 24,
	height = 24,

	top_padding = 2,
	right_padding = 0,
	bottom_padding = 2,
	left_padding = 0
}

default_gui["helmod_button-small-bold-end"] = {
	type = "button_style",
	parent = "helmod_button-default",
	font = "helmod_font-normal-bold",

	width = 24,
	height = 24,

	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 0
}

default_gui["helmod_frame_style"] = {
	type = "frame_style",
	parent = "outer_frame_style",
	flow_style=
	{
		maximal_height = 500
	}
}

default_gui["helmod_menu_frame_style"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 600,
	resize_row_to_width = true
}


default_gui["helmod_page-result-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	minimal_width = 500
}

default_gui["helmod_result"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 600,
	minimal_height = 500
}

default_gui["helmod_align-right-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	align = "right"
}

default_gui["helmod_summary-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 150
}

default_gui["helmod_module-table-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 300
}

default_gui["helmod_recipe-table-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 150
}
