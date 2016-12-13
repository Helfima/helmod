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
default_gui["helmod_icon"] = {
	type = "button_style",
	parent = "helmod_button-default",
	width = 32,
	height = 32,
	scalable = false,
	default_graphical_set = monolithIcon("__helmod__/graphics/icons/helmod_icon.png", 32, 1, {0,0}, {x=0,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__helmod__/graphics/icons/helmod_icon.png", 32, 1, {0,0}, {x=0,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__helmod__/graphics/icons/helmod_icon.png", 32, 1, {0,0}, {x=0,y=0}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__helmod__/graphics/icons/helmod_icon.png", 32, 1, {0,0}, {x=0,y=0}, {top=0,right=0,bottom=0,left=0}, true)
}

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

default_gui["helmod_xxl-select-button-icon-red"] = {
	type = "button_style",
	parent = "helmod_xxl-button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=36}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=36}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=36}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=36}, {top=0,right=0,bottom=0,left=0}, true)
}

default_gui["helmod_xxl-select-button-icon-yellow"] = {
	type = "button_style",
	parent = "helmod_xxl-button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=72}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=72}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=72}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=72}, {top=0,right=0,bottom=0,left=0}, true)
}

default_gui["helmod_xxl-select-button-icon-green"] = {
	type = "button_style",
	parent = "helmod_xxl-button-icon",
	default_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=108}, {top=0,right=0,bottom=0,left=0}, true),
	hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=148,y=108}, {top=0,right=0,bottom=0,left=0}, true),
	clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=184,y=108}, {top=0,right=0,bottom=0,left=0}, true),
	disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", 36, normal_icon_size/36, {0,0}, {x=111,y=108}, {top=0,right=0,bottom=0,left=0}, true)
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

-------------------------------------------------------------------------------
-- Style table
--
-- @type Table
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Table] default

default_gui["helmod_table_default"] = {
	type = "table_style",
	horizontal_spacing = 0,
	vertical_spacing = 0,
	top_padding = 0,
	right_padding = 0,
	bottom_padding = 0,
	left_padding = 0
}

-------------------------------------------------------------------------------
-- Style of factory modules
--
-- @field [parent=#Table] factory_modules

default_gui["helmod_factory_modules"] = {
	type = "table_style",
	parent = "helmod_table_default",
	minimal_width = 36
}

-------------------------------------------------------------------------------
-- Style of beacon modules
--
-- @field [parent=#Table] beacon_modules

default_gui["helmod_beacon_modules"] = {
	type = "table_style",
	parent = "helmod_table_default",
	minimal_width = 18
}

-------------------------------------------------------------------------------
-- Style of recipe modules
--
-- @field [parent=#Table] recipe_modules

default_gui["helmod_table_recipe_modules"] = {
	type = "table_style",
	parent = "table_style",
	minimal_height = 36
}

-------------------------------------------------------------------------------
-- Style of recipe selector
--
-- @field [parent=#Table] recipe_selector

default_gui["helmod_table_recipe_selector"] = {
	type = "table_style",
	horizontal_spacing = 2,
	vertical_spacing = 2,
	top_padding = 1,
	right_padding = 0,
	bottom_padding = 1,
	left_padding = 0
}

-------------------------------------------------------------------------------
-- Style label
--
-- @type Label
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] default

default_gui["helmod_label_default"] = {
	type = "label_style",
	parent = "label_style",
	top_padding = 2,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of title frame
--
-- @field [parent=#Label] title_frame

default_gui["helmod_label_title_frame"] = {
	type = "label_style",
	parent = "helmod_label_default",
	font = "helmod_font_title_frame"
}

-------------------------------------------------------------------------------
-- Style of time
--
-- @field [parent=#Label] time

default_gui["helmod_label_time"] = {
	type = "label_style",
	parent = "label_style",
	top_padding = 4,
	right_padding = 2,
	bottom_padding = 2,
	left_padding = 2
}

-------------------------------------------------------------------------------
-- Name of display
--
-- |--------------------------------------------------|
-- | Flow.main                                        |
-- | |-----------------------|----------------------| |
-- | | Flow.info             | Flow.dialog          | |
-- | | |-------------------| | |------------------| | |
-- | | | Frame.main_menu   | | | Frame.dialog     | | |
-- | | |-------------------| | |                  | | |
-- | | | Frame.data        | | |                  | | |
-- | | |                   | | |                  | | |
-- | | |                   | | |                  | | |
-- | | |                   | | |                  | | |
-- | | |-------------------| | |------------------| | |
-- | |-----------------------|----------------------| |
-- |--------------------------------------------------|
--

local width_info=492
local width_scroll=8
local width_block_info=290
local height_block_header = 400
local height_selector_header = 255

local width_1920 = math.ceil(1920*0.85) -- 1632
local height_1200 = math.ceil(1200*0.85) -- 1020
local width_1680 = math.ceil(1680*0.85) -- 1388
local height_1050 = math.ceil(1050*0.85) -- 893


-------------------------------------------------------------------------------
-- Style flow
--
-- @type Flow
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Flow] default

default_gui["helmod_flow_default"] = {
	type = "flow_style",
	parent = "flow_style",
	horizontal_spacing = 1,
	vertical_spacing = 1
}

-------------------------------------------------------------------------------
-- Style of main panel
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Flow] main_1920x1200

default_gui["helmod_flow_main_1920x1200"] = {
	type = "flow_style",
	parent = "helmod_flow_default",
	minimal_width = width_1920,
	minimal_height = height_1200
}

-------------------------------------------------------------------------------
-- Style of main panel
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Flow] main_1680x1050

default_gui["helmod_flow_main_1680x1050"] = {
  type = "flow_style",
  parent = "helmod_flow_default",
  minimal_width = width_1680,
  minimal_height = height_1050,
}
-------------------------------------------------------------------------------
-- Style of main panel
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Flow] main_1440x900

default_gui["helmod_flow_main_1440x900"] = {
  type = "frame_style",
  parent = "frame_style",
  minimal_width = 1224,
  minimal_height = 765,
}
-------------------------------------------------------------------------------
-- Style of full resize row panel
--
-- @field [parent=#Flow] full_resize_row

default_gui["helmod_flow_full_resize_row"] = {
	type = "flow_style",
	parent = "helmod_flow_default",
	resize_row_to_width = true,
	resize_to_row_height = true
}

-------------------------------------------------------------------------------
-- Style of resize row width panel
--
-- @field [parent=#Flow] resize_row_width

default_gui["helmod_flow_resize_row_width"] = {
	type = "flow_style",
	parent = "helmod_flow_default",
	resize_row_to_width = true
}

-------------------------------------------------------------------------------
-- Style of info panel
--
-- @field [parent=#Flow] info

default_gui["helmod_flow_info"] = {
	type = "flow_style",
	parent = "helmod_flow_resize_row_width"
}

-------------------------------------------------------------------------------
-- Style of dialog panel
--
-- @field [parent=#Flow] dialog

default_gui["helmod_flow_dialog"] = {
	type = "flow_style",
	parent = "helmod_flow_resize_row_width"
}

-------------------------------------------------------------------------------
-- Style of data panel
--
-- @field [parent=#Flow] data_1920x1200

default_gui["helmod_flow_data_1920x1200"] = {
	type = "flow_style",
	parent = "helmod_flow_resize_row_width",
	minimal_width = width_1920 - width_info,
	maximal_width = width_1920 - width_info,
	minimal_height = 600
}

-------------------------------------------------------------------------------
-- Style of data panel
--
-- @field [parent=#Flow] data_1680x1050

default_gui["helmod_flow_data_1680x1050"] = {
	type = "flow_style",
	parent = "helmod_flow_resize_row_width",
	minimal_width = width_1680 - width_info,
	maximal_width = width_1680 - width_info,
	minimal_height = 600
}

-------------------------------------------------------------------------------
-- Style of recipe selector
--
-- @field [parent=#Flow] recipe_selector

default_gui["helmod_flow_recipe_selector"] = {
	type = "flow_style",
	parent = "flow_style",
	horizontal_spacing = 0,
	vertical_spacing = 0
}

-------------------------------------------------------------------------------
-- Style frame
--
-- @type Frame
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Frame] default

default_gui["helmod_frame_default"] = {
	type = "frame_style",
	parent = "frame_style",
	
	-- marge interieure
	top_padding  = 2,
    right_padding = 2,
    bottom_padding = 2,
    left_padding = 2,
    
    -- padding title
    title_top_padding = 0,
    title_left_padding = 0,
    title_bottom_padding = 4,
    title_right_padding = 0,
	
	font = "helmod_font_title_frame",
	
	flow_style = {
		horizontal_spacing = 0,
		vertical_spacing = 0
	}
}

-------------------------------------------------------------------------------
-- Style of main panel (only testing)
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Frame] main_1920x1200

default_gui["helmod_frame_main_1920x1200"] = {
  type = "frame_style",
  parent = "frame_style",
  minimal_width = width_1920,
  minimal_height = height_1200,
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
    
  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 0,
  title_right_padding = 0
}

-------------------------------------------------------------------------------
-- Style of main panel (only testing)
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Frame] main_1680x1050

default_gui["helmod_frame_main_1680x1050"] = {
  type = "frame_style",
  parent = "frame_style",
  minimal_width = width_1680,
  minimal_height = height_1050,
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
    
  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 0,
  title_right_padding = 0
}

-------------------------------------------------------------------------------
-- Style of main panel
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Frame] main_1440x900

default_gui["helmod_frame_main_1440x900"] = {
  type = "frame_style",
  parent = "frame_style",
  minimal_width = 1224,
  minimal_height = 765,
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
    
  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 0,
  title_right_padding = 0
}

-------------------------------------------------------------------------------
-- Style of main panel (only testing)
-- @field [parent=#Frame] data_menu_1920x1200

default_gui["helmod_frame_data_menu_1920x1200"] = {
  type = "frame_style",
  parent = "frame_style",
  minimal_width = width_1920 - width_info,
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
}

-------------------------------------------------------------------------------
-- Style of main panel (only testing)
-- @field [parent=#Frame] data_menu_1680x1050

default_gui["helmod_frame_data_menu_1680x1050"] = {
  type = "frame_style",
  parent = "frame_style",
  minimal_width = width_1680 - width_info,
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
}

-------------------------------------------------------------------------------
-- Style of main menu panel
--
-- @field [parent=#Frame] main_menu
-- 

default_gui["helmod_frame_main_menu"] = {
	type = "frame_style",
	parent = "helmod_frame_default"
}

-------------------------------------------------------------------------------
-- Style of resize width row panel
--
-- @field [parent=#Frame] resize_row_width
-- 

default_gui["helmod_frame_resize_row_width"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	resize_row_to_width = true,
	flow_style = {
		resize_row_to_width = true,
		horizontal_spacing = 0,
		vertical_spacing = 0
	}
}

-------------------------------------------------------------------------------
-- Style of resize full row panel
--
-- @field [parent=#Frame] full_resize_row
-- 

default_gui["helmod_frame_full_resize_row"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	resize_row_to_width = true,
	resize_to_row_height = true,
	flow_style = {
		resize_row_to_width = true,
		resize_to_row_height = true,
		horizontal_spacing = 0,
		vertical_spacing = 0
	}
}

-------------------------------------------------------------------------------
-- Style of data panel
--
-- @field [parent=#Frame] data_1920x1200
-- 

default_gui["helmod_frame_data_1920x1200"] = {
	type = "frame_style",
	parent = "helmod_frame_resize_row_width",
	minimal_width = width_1920 - width_info,
	maximal_width = width_1920 - width_info
}

-------------------------------------------------------------------------------
-- Style of data panel
--
-- @field [parent=#Frame] data_1680x1050
-- 

default_gui["helmod_frame_data_1680x1050"] = {
	type = "frame_style",
	parent = "helmod_frame_resize_row_width",
	minimal_width = width_1680 - width_info,
	maximal_width = width_1680 - width_info
}

-------------------------------------------------------------------------------
-- Style of recipe modules panel
--
-- @field [parent=#Frame] recipe_modules
-- 

default_gui["helmod_frame_recipe_modules"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	minimal_width = 230,
	maximal_width = 230
}

-------------------------------------------------------------------------------
-- Style of recipe ingredients panel
--
-- @field [parent=#Frame] recipe_ingredients
-- 

default_gui["helmod_frame_recipe_ingredients"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	minimal_width = 230,
	maximal_width = 230,
	minimal_height = 76,
	maximal_height = 76
}

-------------------------------------------------------------------------------
-- Style of recipe products panel
--
-- @field [parent=#Frame] recipe_products
-- 

default_gui["helmod_frame_recipe_products"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	minimal_width = 230,
	maximal_width = 230,
	minimal_height = 77,
	maximal_height = 77
}

-------------------------------------------------------------------------------
-- Style of recipe info
--
-- @field [parent=#Frame] recipe_info
-- 

default_gui["helmod_frame_recipe_info"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	minimal_width = 230,
	maximal_width = 230
}

-------------------------------------------------------------------------------
-- Style of recipe factory panel
--
-- @field [parent=#Frame] recipe_factory
-- 

default_gui["helmod_frame_recipe_factory"] = {
	type = "frame_style",
	parent = "helmod_frame_default",
	minimal_width = 230,
	maximal_width = 230,
	minimal_height = 305,
	maximal_height = 305
}

-------------------------------------------------------------------------------
-- Style scroll
--
-- @type Scroll
--

-------------------------------------------------------------------------------
-- Style of block list
-- 
-- @field [parent=#Scroll] block_list_1920x1200

default_gui["helmod_scroll_block_list_1920x1200"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = width_1920 - width_info - width_scroll,
	maximal_width = width_1920 - width_info - width_scroll,
	minimal_height = height_1200 - height_block_header,
	maximal_height = height_1200 - height_block_header
}

-------------------------------------------------------------------------------
-- Style of block list
-- 
-- @field [parent=#Scroll] block_list_1680x1050

default_gui["helmod_scroll_block_list_1680x1050"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = width_1680 - width_info - width_scroll,
	maximal_width = width_1680 - width_info - width_scroll,
	minimal_height = height_1050 - height_block_header,
	maximal_height = height_1050 - height_block_header
}

-------------------------------------------------------------------------------
-- Style of block info
--
-- @field [parent=#Scroll] block_info

default_gui["helmod_scroll_block_info"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = width_block_info,
	maximal_width = width_block_info,
	minimal_height = 72,
	maximal_height = 150
}

-------------------------------------------------------------------------------
-- Style of block element
--
-- @field [parent=#Scroll] block_element_1920x1200

default_gui["helmod_scroll_block_element_1920x1200"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = width_1920 - width_info - width_block_info - width_scroll - 10,
	maximal_width = width_1920 - width_info - width_block_info - width_scroll - 10,
	minimal_height = 72,
	maximal_height = 72
}

-------------------------------------------------------------------------------
-- Style of block element
--
-- @field [parent=#Scroll] block_element_1680x1050

default_gui["helmod_scroll_block_element_1680x1050"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = width_1680 - width_info - width_block_info - width_scroll - 9,
	maximal_width = width_1680 - width_info - width_block_info - width_scroll - 9,
	minimal_height = 72,
	maximal_height = 72
}

-------------------------------------------------------------------------------
-- Style of recipe module list
--
-- @field [parent=#Scroll] recipe_module_list

default_gui["helmod_scroll_recipe_module_list"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 180,
	maximal_width = 180,
	minimal_height = 197,
	maximal_height = 197
}

-------------------------------------------------------------------------------
-- Style of recipe selector
--
-- @field [parent=#Scroll] recipe_selector_1920x1200

default_gui["helmod_scroll_recipe_selector_1920x1200"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 400,
	maximal_width = 400,
	minimal_height = height_1200 - height_selector_header,
	maximal_height = height_1200 - height_selector_header
}

-------------------------------------------------------------------------------
-- Style of recipe selector
--
-- @field [parent=#Scroll] recipe_selector_1680x1050

default_gui["helmod_scroll_recipe_selector_1680x1050"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 400,
	maximal_width = 400,
	minimal_height = height_1050 - height_selector_header,
	maximal_height = height_1050 - height_selector_header
}

-------------------------------------------------------------------------------
-- Style of recipe factories
--
-- @field [parent=#Scroll] recipe_factories

default_gui["helmod_scroll_recipe_factories"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 210,
	maximal_width = 210,
	minimal_height = 210,
	maximal_height = 210
}

-------------------------------------------------------------------------------
-- Style of recipe factory group
--
-- @field [parent=#Scroll] recipe_factory_group

default_gui["helmod_scroll_recipe_factory_group"] = {
	type = "scroll_pane_style",
	parent = "scroll_pane_style",
	minimal_width = 210,
	maximal_width = 210,
	minimal_height = 60,
	maximal_height = 60
}


-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

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
