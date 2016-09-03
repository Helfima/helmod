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

function monolithIcon(filename, size, scale, shift, position, border, stretch)
	return {
		type = "monolith",
		top_monolith_border = border.top,
		right_monolith_border = border.right,
		bottom_monolith_border = border.bottom,
		left_monolith_border = border.left,
		monolith_image = sprite(filename, size, scale, shift, position),
		stretch_monolith_image_to_size = stretch
	}
end

function compositionIcon(filename, corner_size, position)
	return {
		type = "composition",
		filename = filename,
		priority = "extra-high-no-scale",
		corner_size = corner_size,
		position = position
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
local corner_size = {3, 3}
local default_gui = data.raw["gui-style"].default
default_gui["helmod_button-default"] = {
	type = "button_style",
	font = "helmod_font-normal",
	default_font_color={r=1, g=1, b=1},
	align = "center",
	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2,
	default_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 0}),
	hovered_font_color={r=1, g=1, b=1},
	hovered_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 8}),
	clicked_font_color={r=1, g=1, b=1},
	clicked_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 40}),
	disabled_font_color={r=0.5, g=0.5, b=0.5},
	disabled_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 16}),
	pie_progress_color = {r=1, g=1, b=1}
}

local icon_corner_size = 0
default_gui["helmod_button-icon-default"] = {
	type = "button_style",
	parent = "helmod_button-default",
	default_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 3 - icon_corner_size}),
	hovered_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 11 - icon_corner_size}),
	clicked_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 43 - icon_corner_size}),
	disabled_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 19 - icon_corner_size}),
}

local normal_icon_size=36
default_gui["helmod_button-icon"] = {
	type = "button_style",
	parent = "helmod_button-icon-default",
	width = normal_icon_size,
	height = normal_icon_size,

	scalable = false,
}

default_gui["helmod_select-button-icon"] = {
	type = "button_style",
	parent = "helmod_button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}, {top=0,right=0,bottom=0,left=0}, true)
}

default_gui["helmod_select-button-icon-red"] = {
	type = "button_style",
	parent = "helmod_button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=36}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=36}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=36}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=36}, {top=0,right=0,bottom=0,left=0}, true)
}

default_gui["helmod_select-button-icon-yellow"] = {
	type = "button_style",
	parent = "helmod_button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=72}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=72}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=72}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=72}, {top=0,right=0,bottom=0,left=0}, true)
}

default_gui["helmod_select-button-icon-green"] = {
	type = "button_style",
	parent = "helmod_button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=108}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=108}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=108}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=108}, {top=0,right=0,bottom=0,left=0}, true)
}

local xxl_icon_size=68
default_gui["helmod_xxl-button-icon"] = {
	type = "button_style",
	parent = "helmod_button-icon-default",
	width = xxl_icon_size,
	height = xxl_icon_size,

	scalable = false,
}

default_gui["helmod_xxl-select-button-icon"] = {
	type = "button_style",
	parent = "helmod_xxl-button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}, {top=0,right=0,bottom=0,left=0}, true)
}

local sm_icon_size=18
default_gui["helmod_sm-button-icon"] = {
	type = "button_style",
	parent = "helmod_button-icon-default",
	width = sm_icon_size,
	height = sm_icon_size,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	scalable = false,
}

default_gui["helmod_sm-select-button-icon"] = {
	type = "button_style",
	parent = "helmod_sm-button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=0}, {top=0,right=0,bottom=0,left=0}, true)
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
	top_padding = 4,
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

default_gui["helmod_textfield"] = {
	type = "textfield_style",
	parent = "textfield_style",
	minimal_width = 70,
	maximal_width = 70
}

default_gui["helmod_label-right"] = {
	type = "label_style",
	font = "default",
	align = "right"
}

default_gui["helmod_label-right-20"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 20
}

default_gui["helmod_label-right-30"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 30
}

default_gui["helmod_label-right-40"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 40
}

default_gui["helmod_label-right-50"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 50
}

default_gui["helmod_label-right-60"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 60
}

default_gui["helmod_label-right-70"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 70
}

default_gui["helmod_label-right-80"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 80
}

default_gui["helmod_label-right-90"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 90
}

default_gui["helmod_label-right-100"] = {
	type = "label_style",
	font = "default",
	align = "right",
	minimal_width = 100
}

default_gui["helmod_menu_frame_style"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 940,
	resize_row_to_width = true
}


default_gui["helmod_page-result-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	minimal_width = 500
}

default_gui["helmod_module-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	minimal_width = 25,
	horizontal_spacing = 0,
	vertical_spacing = 0,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0

}

default_gui["helmod_table"] = {
	type = "table_style",
	horizontal_spacing = 0,
	vertical_spacing = 0,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0
}

default_gui["helmod_table-odd"] = {
	type = "table_style",
	-- default orange with alfa
	hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
	cell_padding = 1,
	horizontal_spacing = 10,
	vertical_spacing = 2,
	horizontal_padding = 1,
	vertical_padding = 1,
	odd_row_graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {0, 0},
		position = {78, 18},
		opacity = 0.7
	}
}
default_gui["helmod_factory-modules"] = {
	type = "table_style",
	parent = "helmod_table",
	minimal_width = 36
}

default_gui["helmod_beacon-modules"] = {
	type = "table_style",
	parent = "helmod_table",
	minimal_width = 18
}

default_gui["helmod_recipe-modules"] = {
	type = "table_style",
	parent = "table_style",
	minimal_height = 36
}

default_gui["helmod_result"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 800,
	minimal_height = 500,
	flow_style = {
		horizontal_spacing = 0,
		vertical_spacing = 0
	}
}

default_gui["helmod_main-flow"] = {
	type = "flow_style",
	parent = "flow_style"
}

default_gui["helmod_result-menu-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	minimal_width = 800,
	horizontal_spacing = 0,
	vertical_spacing = 0,
	resize_row_to_width = true
}

default_gui["helmod_align-right-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	align = "right"
}

default_gui["helmod_block-item-section-frame1"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 465,
	maximal_width = 465
}

default_gui["helmod_block-item-scroll1"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 438,
	maximal_width = 438,
	minimal_height = 36,
	maximal_height = 72
}

default_gui["helmod_block-item-section-frame2"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 940,
	maximal_width = 940
}

default_gui["helmod_block-item-scroll2"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 918,
	maximal_width = 918,
	minimal_height = 36,
	maximal_height = 72
}

default_gui["helmod_block-list-section-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 940,
	maximal_width = 940
}

default_gui["helmod_block-list-scroll"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 918,
	maximal_width = 918,
	minimal_height = 516,
	maximal_height = 516
}

default_gui["helmod_block-input-section-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 630
}

default_gui["helmod_recipe-section-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 630
}

default_gui["helmod_recipe-cell-frame"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 230,
	maximal_width = 230
}

default_gui["helmod_recipe-cell-frame1"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 230,
	maximal_width = 230
}

default_gui["helmod_recipe-cell-frame2"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 200,
	maximal_width = 200
}

default_gui["helmod_recipe-cell-frame3"] = {
	type = "frame_style",
	parent = "frame_style",
	minimal_width = 200,
	maximal_width = 200
}

default_gui["helmod_recipe-cell-scroll"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 210,
	maximal_width = 210,
	minimal_height = 60,
	maximal_height = 60
}

default_gui["helmod_recipe-cell-scroll1"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 210,
	maximal_width = 210,
	minimal_height = 210,
	maximal_height = 210
}

default_gui["helmod_recipe-cell-scroll3"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 180,
	maximal_width = 180,
	minimal_height = 145,
	maximal_height = 145
}

default_gui["helmod_recipe-cell-flow"] = {
	type = "flow_style",
	parent = "flow_style",
	manimal_width = 230
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

default_gui["helmod_button-sorted-none"] = {
	type = "button_style",
	parent = "button_style",
	scalable = false,
	width = 22,
	height = 22,
	top_padding = 1,
	right_padding = 1,
	bottom_padding = 1,
	left_padding = 1,
	default_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 1, {0,0}, {x=0,y=0}, {top=1,right=1,bottom=1,left=1}, false),
	hovered_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 1, {0,0}, {x=72,y=0}, {top=1,right=1,bottom=1,left=1}, false),
	clicked_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 1, {0,0}, {x=0,y=0}, {top=1,right=1,bottom=1,left=1}, false)
}

default_gui["helmod_button-sorted-down"] = {
	type = "button_style",
	parent = "button_style",
	scalable = false,
	width = 22,
	height = 22,
	top_padding = 1,
	right_padding = 1,
	bottom_padding = 1,
	left_padding = 1,
	default_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 22/24, {0,0}, {x=48,y=0}, {top=1,right=1,bottom=1,left=1}, false),
	hovered_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 22/24, {0,0}, {x=24,y=0}, {top=1,right=1,bottom=1,left=1}, false),
	clicked_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 22/24, {0,0}, {x=72,y=0}, {top=1,right=1,bottom=1,left=1}, false)
}

default_gui["helmod_button-sorted-up"] = {
	type = "button_style",
	parent = "button_style",
	scalable = false,
	width = 22,
	height = 22,
	top_padding = 1,
	right_padding = 1,
	bottom_padding = 1,
	left_padding = 1,
	default_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 1, {0,0}, {x=24,y=0}, {top=1,right=1,bottom=1,left=1}, false),
	hovered_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 1, {0,0}, {x=48,y=0}, {top=1,right=1,bottom=1,left=1}, false),
	clicked_graphical_set = monolithIcon("__helmod__/graphics/switch-quickbar.png", 24, 1, {0,0}, {x=72,y=0}, {top=1,right=1,bottom=1,left=1}, false)
}
