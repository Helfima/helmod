local default_gui = data.raw["gui-style"].default

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
    filename = filename,
    priority = "extra-high-no-scale",
    align = "center",
    size = size,
    scale = scale,
    shift = shift,
    position = position,
    border = border.top
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

-------------------------------------------------------------------------------
-- Menu icon type
--
-- @function menuButtonIcon
--
-- @param #string name
-- @param #number icon_row
-- @param #table icon_col
-- @param #string suffix
-- @param #string font
-- @param #table hovered_font_color
--
function menuButtonIcon(name, icon_row, icon_col, size, suffix, font, hovered_font_color)
  local style_name = "helmod_button_"..name
  if suffix ~= nil then style_name = style_name.."_"..suffix end
  default_gui[style_name] = {
    type = "button_style",
    parent = "helmod_button_default",
    top_padding = 0,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    width = size,
    height = size,
    scalable = false,
    default_graphical_set = monolithIcon("__helmod__/graphics/icons/button.png", 32, 1, {0,0}, {x=(icon_col[1]-1)*32,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
    hovered_graphical_set = monolithIcon("__helmod__/graphics/icons/button.png", 32, 1, {0,0}, {x=(icon_col[2]-1)*32,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
    hovered_font_color = hovered_font_color,
    clicked_graphical_set = monolithIcon("__helmod__/graphics/icons/button.png", 32, 1, {0,0}, {x=(icon_col[3]-1)*32,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true),
    disabled_graphical_set = monolithIcon("__helmod__/graphics/icons/button.png", 32, 1, {0,0}, {x=(icon_col[4]-1)*32,y=(icon_row-1)*32}, {top=0,right=0,bottom=0,left=0}, true)
  }
  if font ~= nil then
    default_gui[style_name].font = font
  end
end

-------------------------------------------------------------------------------
-- Menu icons
--
-- @function menuButtonIcons
--
-- @param #string name
-- @param #number icon_row
-- @param #string font
--
function menuButtonIcons(name, icon_row, font)
  menuButtonIcon(name, icon_row, {1,2,1,1}, 32, nil, font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {1,2,1,1}, 24, "sm", font, {r=0, g=0, b=0})

  menuButtonIcon(name, icon_row, {3,2,1,1}, 32, "actived_red", font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {3,2,1,1}, 32, "sm_actived_red", font, {r=0, g=0, b=0})

  menuButtonIcon(name, icon_row, {1,3,1,1}, 32, "red", font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {1,3,1,1}, 24, "sm_red", font, {r=0, g=0, b=0})

  menuButtonIcon(name, icon_row, {4,5,4,4}, 32, "selected", font, {r=1, g=1, b=1})
  menuButtonIcon(name, icon_row, {4,5,4,4}, 24, "sm_selected", font, {r=1, g=1, b=1})

  menuButtonIcon(name, icon_row, {5,5,5,5}, 32, "selected_yellow", font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {5,5,5,5}, 24, "sm_selected_yellow", font, {r=0, g=0, b=0})

  menuButtonIcon(name, icon_row, {6,6,6,6}, 32, "selected_red", font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {6,6,6,6}, 24, "sm_selected_red", font, {r=0, g=0, b=0})

  menuButtonIcon(name, icon_row, {7,8,7,7}, 36, "flat2", font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {7,8,7,7}, 32, "flat", font, {r=0, g=0, b=0})
  menuButtonIcon(name, icon_row, {7,8,7,7}, 24, "sm_flat", font, {r=0, g=0, b=0})
end

-------------------------------------------------------------------------------
-- Style Textfield
--
-- @type Textfield
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Textfield] default
default_gui["helmod_textfield"] = {
  type = "textbox_style",
  parent = "search_textfield_with_fixed_width",
  minimal_width = 70,
  maximal_width = 70
}

-------------------------------------------------------------------------------
-- Style of calculator
--
-- @field [parent=#Textfield] calculator
default_gui["helmod_textfield_calculator"] = {
  type = "textbox_style",
  font = "helmod_font_calculator"
}

-------------------------------------------------------------------------------
-- Style Textbox
--
-- @type Textbox
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Textbox] default
default_gui["helmod_textbox_default"] = {
  type = "textbox_style",
  parent = "textbox",
  minimal_width = 300,
  maximal_width = 300,
  minimal_height = 300,
  maximal_height = 200
}


-------------------------------------------------------------------------------
-- Style Button
--
-- @type Button
--

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Button] default

local corner_size = {3, 3}
default_gui["helmod_button_default"] = {
  type = "button_style",
  font = "helmod_font_normal",
  default_font_color={r=1, g=1, b=1},
  align = "center",
  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2,
  height = 28,
  default_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 0}),
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 8}),
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 40}),
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 16}),
  pie_progress_color = {r=1, g=1, b=1}
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Button] selected

default_gui["helmod_button_selected"] = {
  type = "button_style",
  font = "helmod_font_normal",
  default_font_color={r=1, g=1, b=1},
  align = "center",
  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2,
  height = 28,
  default_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 40}),
  hovered_font_color={r=1, g=1, b=1},
  hovered_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 40}),
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 40}),
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = compositionIcon("__core__/graphics/gui.png", corner_size, {0, 16}),
  pie_progress_color = {r=1, g=1, b=1}
}

local icon_corner_size = 1
-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] icon_default

default_gui["helmod_button_icon_default"] = {
  type = "button_style",
  parent = "helmod_button_default",
  default_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 3 - icon_corner_size}),
  hovered_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 11 - icon_corner_size}),
  clicked_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 43 - icon_corner_size}),
  disabled_graphical_set = compositionIcon("__core__/graphics/gui.png", {icon_corner_size, icon_corner_size}, {3 - icon_corner_size, 19 - icon_corner_size}),
}

menuButtonIcons("menu",1)
-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] icon

local icon_sm_size=16
local icon_sm_padding=1

local icon_m_size=24
local icon_m_padding=1

local icon_size=32
local icon_padding=2

local icon_xxl_size=64
local icon_xxl_padding=2

local monolith_size=36
local monolith_scale=1

local icon_offset_y=144

local style_list = {
  {suffix="",offset = 0},
  {suffix="_red",offset = 36},
  {suffix="_yellow",offset = 72},
  {suffix="_green",offset = 108}
}

default_gui["helmod_button_icon"] = {
  type = "button_style",
  parent = "helmod_button_icon_default",
  width = icon_size + 2*icon_padding,
  height = icon_size + 2*icon_padding,
  top_padding = icon_padding,
  right_padding = icon_padding,
  bottom_padding = icon_padding,
  left_padding = icon_padding,
  default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=60}, {top=0,right=0,bottom=0,left=0}, true),
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] slot

default_gui["helmod_button_slot"] = {
  type = "button_style",
  parent = "slot_button",
  width = icon_size + 2*icon_padding,
  height = icon_size + 2*icon_padding,
  top_padding = icon_padding,
  right_padding = icon_padding,
  bottom_padding = icon_padding,
  left_padding = icon_padding,
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] select_icon
for _,style in pairs(style_list) do
  default_gui["helmod_button_select_icon"..style.suffix] = {
    type = "button_style",
    parent = "helmod_button_icon",
    default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
  }
end

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] icon_xxl

default_gui["helmod_button_icon_xxl"] = {
  type = "button_style",
  parent = "helmod_button_icon_default",
  width = icon_xxl_size + 2*icon_xxl_padding,
  height = icon_xxl_size + 2*icon_xxl_padding,
  top_padding = icon_xxl_padding,
  right_padding = icon_xxl_padding,
  bottom_padding = icon_xxl_padding,
  left_padding = icon_xxl_padding,
  default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=60}, {top=0,right=0,bottom=0,left=0}, true),
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] select_icon_xxl

for _,style in pairs(style_list) do
  default_gui["helmod_button_select_icon_xxl"..style.suffix] = {
    type = "button_style",
    parent = "helmod_button_icon_xxl",
    default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
  }
end

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] icon_m

default_gui["helmod_button_icon_m"] = {
  type = "button_style",
  parent = "helmod_button_icon_default",
  width = icon_m_size + 2*icon_m_padding,
  height = icon_m_size + 2*icon_m_padding,
  top_padding = icon_m_padding,
  right_padding = icon_m_padding,
  bottom_padding = icon_m_padding,
  left_padding = icon_m_padding,
  default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=60}, {top=0,right=0,bottom=0,left=0}, true),
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] slot_m

default_gui["helmod_button_slot_m"] = {
  type = "button_style",
  parent = "slot_button",
  width = icon_m_size + 2*icon_m_padding,
  height = icon_m_size + 2*icon_m_padding,
  top_padding = icon_m_padding,
  right_padding = icon_m_padding,
  bottom_padding = icon_m_padding,
  left_padding = icon_m_padding,
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] select_icon_m

for _,style in pairs(style_list) do
  default_gui["helmod_button_select_icon_m"..style.suffix] = {
    type = "button_style",
    parent = "helmod_button_icon_m",
    default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
  }
end

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] icon_sm

default_gui["helmod_button_icon_sm"] = {
  type = "button_style",
  parent = "helmod_button_icon_default",
  width = icon_sm_size + 2*icon_sm_padding,
  height = icon_sm_size + 2*icon_sm_padding,
  top_padding = icon_sm_padding,
  right_padding = icon_sm_padding,
  bottom_padding = icon_sm_padding,
  left_padding = icon_sm_padding,
  default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=60}, {top=0,right=0,bottom=0,left=0}, true),
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] slot_sm

default_gui["helmod_button_slot_sm"] = {
  type = "button_style",
  parent = "slot_button",
  width = icon_sm_size + 2*icon_sm_padding,
  height = icon_sm_size + 2*icon_sm_padding,
  top_padding = icon_sm_padding,
  right_padding = icon_sm_padding,
  bottom_padding = icon_sm_padding,
  left_padding = icon_sm_padding,
  scalable = false
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] select_icon_sm

for _,style in pairs(style_list) do
  default_gui["helmod_button_select_icon_sm"..style.suffix] = {
    type = "button_style",
    parent = "helmod_button_icon_sm",
    default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
    disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
  }
end

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] bold

default_gui["helmod_button_bold"] = {
  type = "button_style",
  parent = "helmod_button_default",
  font = "helmod_font_big_bold",

  minimal_width = 32,
  height = 32,

  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] bold_selected

default_gui["helmod_button_bold_selected"] = {
  type = "button_style",
  parent = "helmod_button_selected",
  font = "helmod_font_big_bold",

  minimal_width = 32,
  height = 32,

  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] calculator

default_gui["helmod_button_calculator"] = {
  type = "button_style",
  parent = "helmod_button_default",
  font = "helmod_font_calculator",

  minimal_width = 36,
  height = 36,

  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] small_bold

default_gui["helmod_button_small_bold"] = {
  type = "button_style",
  parent = "helmod_button_default",
  font = "helmod_font_normal_bold",

  minimal_width = 24,
  height = 24,

  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] small_bold_selected

default_gui["helmod_button_small_bold_selected"] = {
  type = "button_style",
  parent = "helmod_button_selected",
  font = "helmod_font_normal_bold",

  minimal_width = 24,
  height = 24,

  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] small_bold_start

default_gui["helmod_button_small_bold_start"] = {
  type = "button_style",
  parent = "helmod_button_default",
  font = "helmod_font_normal_bold",

  width = 24,
  height = 24,

  top_padding = 2,
  right_padding = 0,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of button
--
-- @field [parent=#Button] small_bold_middle

default_gui["helmod_button_small_bold_middle"] = {
  type = "button_style",
  parent = "helmod_button_default",
  font = "helmod_font_normal_bold",

  width = 24,
  height = 24,

  top_padding = 2,
  right_padding = 0,
  bottom_padding = 2,
  left_padding = 0
}

default_gui["helmod_button_small_bold_end"] = {
  type = "button_style",
  parent = "helmod_button_default",
  font = "helmod_font_normal_bold",

  width = 24,
  height = 24,

  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 0
}


-------------------------------------------------------------------------------
-- Style of tab
--
-- @field [parent=#Button] tab

default_gui["helmod_button_tab"] = {
  type = "button_style",
  font = "helmod_font_normal",
  default_font_color={r=1, g=1, b=1},
  align = "center",
  top_padding = 2,
  right_padding = 8,
  bottom_padding = 2,
  left_padding = 8,
  height = 28,
  default_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {16, 0}),
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {16, 8}),
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {16, 0}),
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {16, 0}),
  pie_progress_color = {r=1, g=1, b=1}
}


-------------------------------------------------------------------------------
-- Style of selected tab
--
-- @field [parent=#Button] tab_selected

default_gui["helmod_button_tab_selected"] = {
  type = "button_style",
  font = "helmod_font_normal",
  default_font_color={r=1, g=1, b=1},
  align = "center",
  top_padding = 2,
  right_padding = 8,
  bottom_padding = 2,
  left_padding = 8,
  height = 28,
  default_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {8, 0}),
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {8, 8}),
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {8, 0}),
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {8, 0}),
  pie_progress_color = {r=1, g=1, b=1}
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
  parent = "label",
  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] element

default_gui["helmod_label_element"] = {
  type = "label_style",
  parent = "label",
  font = "helmod_font_normal",
  top_padding = -3,
  right_padding = 2,
  bottom_padding = 0,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] element_m

default_gui["helmod_label_element_m"] = {
  type = "label_style",
  parent = "label",
  font = "helmod_font_medium_bold",
  top_padding = -2,
  right_padding = 2,
  bottom_padding = 0,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] element_sm

default_gui["helmod_label_element_sm"] = {
  type = "label_style",
  parent = "label",
  font = "helmod_font_small_bold",
  top_padding = -2,
  right_padding = 2,
  bottom_padding = -1,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help

default_gui["helmod_label_help"] = {
  type = "label_style",
  parent = "helmod_label_default",
  minimal_width = 380,
  maximal_width = 380,
  single_line = false
}

-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help_number

default_gui["helmod_label_help_number"] = {
  type = "label_style",
  parent = "helmod_label_default",
  left_padding = 10,
  align = "right",
  minimal_width = 30,
  single_line = false
}

-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help_text

default_gui["helmod_label_help_text"] = {
  type = "label_style",
  parent = "helmod_label_default",
  left_padding = 10,
  minimal_width = 350,
  maximal_width = 350,
  vertical_align = "top",
  single_line = false
}


-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help_title

default_gui["helmod_label_help_title"] = {
  type = "label_style",
  parent = "helmod_label_help",
  font = "helmod_font_title_frame"
}

-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help_normal

default_gui["helmod_label_help_normal"] = {
  type = "label_style",
  parent = "helmod_label_help",
  left_padding = 10
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] max_xx

for w=50, 600, 50 do
  default_gui["helmod_label_max_"..w] = {
    type = "label_style",
    parent = "helmod_label_default",
    right_padding = 0,
    left_padding = 0,
    maximal_width = w
  }
end

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
  parent = "label",
  top_padding = 4,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2
}

-------------------------------------------------------------------------------
-- Style of label
--
-- @field [parent=#Label] sm

default_gui["helmod_label_sm"] = {
  type = "label_style",
  font = "helmod_font_normal",
  align = "right",
  top_padding = 0,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 0
}

-------------------------------------------------------------------------------
-- Style of label
--
-- @field [parent=#Label] right

default_gui["helmod_label_right"] = {
  type = "label_style",
  font = "default",
  horizontal_align = "right"
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] right_xx

for w=20, 100, 10 do
  default_gui["helmod_label_right_"..w] = {
    type = "label_style",
    parent = "helmod_label_right",
    minimal_width = w
  }
end

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] row_right

default_gui["helmod_label_row_right"] = {
  type = "label_style",
  parent = "helmod_label_right",
  top_padding = 15
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] row_right_xx

for w=20, 100, 10 do
  default_gui["helmod_label_row_right_"..w] = {
    type = "label_style",
    parent = "helmod_label_row_right",
    minimal_width = w
  }
end

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] row2_right

default_gui["helmod_label_row2_right"] = {
  type = "label_style",
  parent = "helmod_label_right",
  font = "helmod_font_normal",
  top_padding = 0,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 0
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] row2_right_xx

for w=20, 100, 10 do
  default_gui["helmod_label_row2_right_"..w] = {
    type = "label_style",
    parent = "helmod_label_row2_right",
    minimal_width = w
  }
end

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] row2_right_sm

default_gui["helmod_label_row2_right_sm"] = {
  type = "label_style",
  parent = "helmod_label_right",
  font = "helmod_font_small",
  top_padding = 0,
  right_padding = 1,
  bottom_padding = 0,
  left_padding = 0
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] row2_right_sm_xx

for w=20, 100, 10 do
  default_gui["helmod_label_row2_right_sm_"..w] = {
    type = "label_style",
    parent = "helmod_label_row2_right_sm",
    minimal_width = w
  }
end

-------------------------------------------------------------------------------
-- Style of label
--
-- @field [parent=#Label] icon

default_gui["helmod_label_icon"] = {
  type = "label_style",
  parent = "helmod_label_right",
  font = "helmod_font_icon",
  align = "right",
  top_padding = 0,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 0
}

-------------------------------------------------------------------------------
-- Style of label
--
-- @field [parent=#Label] icon_text_sm

default_gui["helmod_label_icon_text_sm"] = {
  type = "label_style",
  parent = "helmod_label_right",
  font = "helmod_font_icon_4",
  minimal_width = 45,
  top_padding = 18,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 0
}

-------------------------------------------------------------------------------
-- Style of label
--
-- @field [parent=#Label] icon_sm

default_gui["helmod_label_icon_sm"] = {
  type = "label_style",
  parent = "helmod_label_right",
  font = "helmod_font_icon_4",
  minimal_width = 45,
  top_padding = 10,
  right_padding = 1,
  bottom_padding = 1,
  left_padding = 0
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
  horizontal_spacing = 2,
  vertical_spacing = 2,
  cell_spacing = 4,
  top_padding = 0,
  right_padding = 1,
  bottom_padding = 0,
  left_padding = 1,
  vertical_align = "top"
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Table] element

default_gui["helmod_table_element"] = {
  type = "table_style",
  parent = "helmod_table_default",
  horizontally_stretchable = "off"
}

-------------------------------------------------------------------------------
-- Style of panel
--
-- @field [parent=#Table] panel

default_gui["helmod_table_panel"] = {
  type = "table_style",
  horizontal_spacing = 0,
  vertical_spacing = 0,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
}

-------------------------------------------------------------------------------
-- Style of list
--
-- @field [parent=#Table] list

default_gui["helmod_table_list"] = {
  type = "table_style",
  horizontal_spacing = 1,
  vertical_spacing = 1,
  cell_spacing = 1,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top",
  horizontally_stretchable = "off"
}

-------------------------------------------------------------------------------
-- Style of tab
--
-- @field [parent=#Table] tab

default_gui["helmod_table_tab"] = {
  type = "table_style",
  horizontal_spacing = 0,
  vertical_spacing = 0,
  cell_spacing = 0,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
}

-------------------------------------------------------------------------------
-- Style of rule
--
-- @field [parent=#Table] rule

default_gui["helmod_table_rule"] = {
  type = "table_style",
  horizontal_spacing = 2,
  vertical_spacing = 2,
  cell_spacing = 0,
  top_padding = 0,
  right_padding = 10,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
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
  parent = "table",
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
-- Style of recipe table
--
-- @field [parent=#Table] odd

default_gui["helmod_table-odd"] = {
  type = "table_style",
  -- default orange with alfa
  hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
  cell_padding = 1,
  vertical_align = "top",
  horizontal_spacing = 3,
  vertical_spacing = 2,
  horizontal_padding = 1,
  vertical_padding = 1,
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = {1, 1},
    position = {78, 18},
    opacity = 0.7
  }
}

-------------------------------------------------------------------------------
-- Style of recipe table
--
-- @field [parent=#Table] rule_odd

default_gui["helmod_table-rule-odd"] = {
  type = "table_style",
  -- default orange with alfa
  hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
  cell_padding = 1,
  vertical_align = "top",
  horizontal_spacing = 10,
  vertical_spacing = 2,
  horizontal_padding = 3,
  vertical_padding = 1,
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__helmod__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = {1, 1},
    position = {16, 56},
    opacity = 1
  }
}

-------------------------------------------------------------------------------
-- Style of help table
--
--  header_row_graphical_set
--  even_row_graphical_set
--  odd_row_graphical_set
--
-- @field [parent=#Table] help

default_gui["helmod_table-help"] = {
  type = "table_style",
  -- default orange with alfa
  hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
  cell_padding = 1,
  horizontal_spacing = 3,
  vertical_spacing = 2,
  horizontal_padding = 1,
  vertical_padding = 1,
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    priority = "extra-high-no-scale",
    corner_size = {1, 1},
    position = {78, 18},
    opacity = 0.4
  }
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

local width_info=480
local width_scroll=8
local width_block_info=290
local width_recipe_column=220
local height_block_header = 450
local height_selector_header = 350

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
  horizontal_spacing = 1,
  vertical_spacing = 1
}

-------------------------------------------------------------------------------
-- Style of horizontal
--
-- @field [parent=#Flow] horizontal

default_gui["helmod_flow_horizontal"] = {
  type = "horizontal_flow_style",
  horizontal_spacing = 0
}

-------------------------------------------------------------------------------
-- Style of vertical
--
-- @field [parent=#Flow] vertical

default_gui["helmod_flow_vertical"] = {
  type = "vertical_flow_style",
  vertical_spacing = 0
}

-------------------------------------------------------------------------------
-- Style frame
--
-- @type Frame
--

-------------------------------------------------------------------------------
-- Style of hidden
--
-- @field [parent=#Frame] hidden

default_gui["helmod_frame_hidden"] = {
  type = "frame_style",
  font_color = {r=1, g=1, b=1},
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 4,
  title_right_padding = 0,

  font = "helmod_font_title_frame",


  flow_style = {
    type = "flow_style",
    horizontal_spacing = 0,
    vertical_spacing = 0
  },
  horizontal_flow_style =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0,
  },

  vertical_flow_style =
  {
    type = "vertical_flow_style",
    vertical_spacing = 0
  },
  graphical_set =
  {
    type = "composition",
    filename = "__helmod__/graphics/gui.png",
    priority = "extra-high-no-scale",
    load_in_minimal_mode = true,
    corner_size = {1, 1},
    position = {0, 0}
  }
}
-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Frame] default

default_gui["helmod_frame_default"] = {
  type = "frame_style",
  font = "helmod_font_title_frame",
  font_color = {r=1, g=1, b=1},

  -- padding of the title area of the frame, when the frame title
  -- is empty, the area doesn't exist and these values are not used
  title_top_padding = 0,
  title_left_padding = 2,
  title_bottom_padding = 0,
  title_right_padding = 2,
  -- padding of the content area of the frame
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 4,
  left_padding = 0,
  graphical_set =
  {
    base = {position = {0, 0}, corner_size = 8},
    shadow = default_shadow
  },
  flow_style = { type = "flow_style" },
  horizontal_flow_style = { type = "horizontal_flow_style" },
  vertical_flow_style = { type = "vertical_flow_style"  },
  header_flow_style = { type = "horizontal_flow_style", vertical_align = "center", maximal_height = 24},
  header_filler_style =
  {
    type = "empty_widget_style",
    parent = "draggable_space_header",
    height = 24
  },
  use_header_filler = true,
  border = {}
}

function default_glow(tint_value, scale_value)
  return
    {
      position = {57,64},
      corner_size = 8,
      tint = tint_value,
      scale = scale_value,
      draw_type = "outer"
    }
end

default_shadow_color = {0, 0, 0, 0.35}
default_shadow = default_glow(default_shadow_color, 0.5)

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Frame] default

local panel_colors = {}
panel_colors["blue"] = {329,48}
panel_colors["blue2"] = {346,48}
panel_colors["green"] = {431,48}
for key,position in pairs(panel_colors) do
  default_gui["helmod_frame_color_"..key] = {
    type = "frame_style",
    parent = "helmod_frame_default",
    graphical_set =
    {
      base = {position = position, corner_size = 8, opacity = 0.75}

    }
  }
end

local style_element_list = {
  {suffix="yellow", x=0, y=16},
  {suffix="orange", x=0, y=24},
  {suffix="red", x=0, y=32},
  {suffix="green", x=0, y=40},
  {suffix="blue", x=0, y=48},
  {suffix="gray", x=0, y=56},
  {suffix="magenta", x=0, y=64},
  {suffix="none", x=0, y=72}
}
-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Frame] element
--

for _,style in pairs(style_element_list) do
  for i = 1, 3 do
    local style_name = table.concat({"helmod_frame_element",style.suffix,i},"_")
    local x = style.x + (i-1)*8
    local y = style.y

    default_gui[style_name] = {
      type = "frame_style",
      graphical_set = {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 1,
        position = {x,y}
      },
      top_padding  = 2,
      right_padding = 0,
      bottom_padding = 2,
      left_padding = 0,

      minimal_width = 80,
      horizontally_stretchable = "on",
      vertically_stretchable = "off"
    }
  end
end

-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Frame] element_m
--

for _,style in pairs(style_element_list) do
  for i = 1, 3 do
    local style_name = table.concat({"helmod_frame_element_m",style.suffix,i},"_")
    local x = style.x + (i-1)*8
    local y = style.y

    default_gui[style_name] = {
      type = "frame_style",
      graphical_set = {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 1,
        position = {x,y}
      },
      top_padding  = 2,
      right_padding = 0,
      bottom_padding = 2,
      left_padding = 0,

      minimal_width = 50,
      horizontally_stretchable = "on",
      vertically_stretchable = "off"
    }
  end
end

-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Frame] element_sm
--

for _,style in pairs(style_element_list) do
  for i = 1, 3 do
    local style_name = table.concat({"helmod_frame_element_sm",style.suffix,i},"_")
    local x = style.x + (i-1)*8
    local y = style.y

    default_gui[style_name] = {
      type = "frame_style",
      graphical_set = {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 1,
        position = {x,y}
      },
      top_padding  = 2,
      right_padding = 0,
      bottom_padding = 2,
      left_padding = 0,

      minimal_width = 30,
      horizontally_stretchable = "on",
      vertically_stretchable = "off"
    }
  end
end

-------------------------------------------------------------------------------
-- Style of product
--
-- @field [parent=#Frame] product
--

for _,style in pairs(style_element_list) do
  for i = 1, 3 do
    local style_name = table.concat({"helmod_frame_product",style.suffix,i},"_")
    local x = style.x + (i-1)*8
    local y = style.y

    default_gui[style_name] = {
      type = "frame_style",
      graphical_set = {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 1,
        position = {x,y}
      },
      top_padding  = 2,
      right_padding = 0,
      bottom_padding = 2,
      left_padding = 0,
      width = 50,
      horizontally_stretchable = "on",
      vertically_stretchable = "off"
    }
  end
end

-------------------------------------------------------------------------------
-- Style of colored frame
--
-- @field [parent=#Frame] color
--

for _,style in pairs(style_element_list) do
  for i = 1, 3 do
    local style_name = table.concat({"helmod_frame_colored",style.suffix,i},"_")
    local x = style.x + (i-1)*8
    local y = style.y

    default_gui[style_name] = {
      type = "frame_style",
      graphical_set = {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 1,
        position = {x,y}
      },
      top_padding  = 2,
      right_padding = 2,
      bottom_padding = 2,
      left_padding = 2,
      horizontally_stretchable = "on",
      vertically_stretchable = "on"
    }
  end
end

-------------------------------------------------------------------------------
-- Style of section panel
--
-- @field [parent=#Frame] section
--

default_gui["helmod_frame_section"] = {
  type = "frame_style",
  parent = "helmod_frame_default",
  graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {24, 8})
}

-------------------------------------------------------------------------------
-- Style of panel
--
-- @field [parent=#Frame] panel
--

default_gui["helmod_frame_panel"] = {
  type = "frame_style",
  parent = "helmod_frame_default",
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  horizontal_flow =
  {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
  },

  vertical_flow =
  {
    type = "vertical_flow_style",
    vertical_spacing = 0
  },
  use_header_filler = false
}

-------------------------------------------------------------------------------
-- Style of tab panel
-- minimal_width = screen width * 85%
-- minimal_height = screen height * 85%
-- @field [parent=#Frame] tab

default_gui["helmod_frame_tab"] = {
  type = "frame_style",
  parent = "frame",
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,

  -- padding title
  title_top_padding = 0,
  title_left_padding = 0,
  title_bottom_padding = 0,
  title_right_padding = 0,
  graphical_set = compositionIcon("__helmod__/graphics/gui.png", corner_size, {24, 0})
}

-------------------------------------------------------------------------------
-- Style of recipe info
--
-- @field [parent=#Frame] recipe_info
--

default_gui["helmod_frame_recipe_info"] = {
  type = "frame_style",
  parent = "helmod_frame_default",
  minimal_width = width_recipe_column,
  maximal_width = width_recipe_column
}

-------------------------------------------------------------------------------
-- Style scroll
--
-- @type Scroll
--

-------------------------------------------------------------------------------
-- Style of block info
--
-- @field [parent=#Scroll] block_info

default_gui["helmod_scroll_block_info"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_width = width_block_info,
  maximal_width = width_block_info
}

-------------------------------------------------------------------------------
-- Style of block element
--
-- @field [parent=#Scroll] block_element

default_gui["helmod_scroll_block_element"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_height = 36,
  maximal_height = 72
}

-------------------------------------------------------------------------------
-- Style of block pin tab
--
-- @field [parent=#Scroll] block_pin_tab

default_gui["helmod_scroll_block_pin_tab"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_width = 50,
  maximal_width = 450,
  minimal_height = 0,
  maximal_height = 500
}

-------------------------------------------------------------------------------
-- Style of recipe module list
--
-- @field [parent=#Scroll] recipe_module_list

default_gui["helmod_scroll_recipe_module_list"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_width = width_recipe_column - width_scroll,
  maximal_width = width_recipe_column - width_scroll,
  minimal_height = 197,
  maximal_height = 197
}

-------------------------------------------------------------------------------
-- Style of recipe selector
--
-- @field [parent=#Scroll] recipe_selector

default_gui["helmod_scroll_recipe_selector"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_width = 400,
  maximal_width = 400
}

-------------------------------------------------------------------------------
-- Style of recipe factories
--
-- @field [parent=#Scroll] recipe_factories

default_gui["helmod_scroll_recipe_factories"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  minimal_width = width_recipe_column - width_scroll,
  maximal_width = width_recipe_column - width_scroll,
  minimal_height = 270,
  maximal_height = 270
}

-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------

default_gui["helmod_button-sorted-none"] = {
  type = "button_style",
  parent = "button",
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
  parent = "button",
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
  parent = "button",
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
