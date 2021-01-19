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

function default_glow(tint_value, scale_value)
  return
  {
    position = {200, 128},
    corner_size = 8,
    tint = tint_value,
    scale = scale_value,
    draw_type = "outer"
  }
end
default_dirt_color = {15, 7, 3, 100}
default_dirt = default_glow(default_dirt_color, 0.5)
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
function menuButtonIcon(name, icon_row, icon_col, size, suffix, font, default_font_color, hovered_font_color)
  local style_name = "helmod_button_"..name
  if suffix ~= nil then style_name = style_name.."_"..suffix end
  default_gui[style_name] = {
    type = "button_style",
    font = font or "helmod_font_normal",
    default_font_color=default_font_color,
    horizontal_align = "center",
    padding = -4,
    width = size,
    height = size,
    scalable = false,
    default_graphical_set = {base = {position = {x=icon_col[1],y=icon_row[1]}, border = 0, corner_size = 8, shadow = default_dirt}},
    hovered_graphical_set = {base = {position = {x=icon_col[2],y=icon_row[2]}, border = 0, corner_size = 8, shadow = default_dirt}},
    hovered_font_color = hovered_font_color,
    clicked_graphical_set = {base = {position = {x=icon_col[3],y=icon_row[3]}, border = 0, corner_size = 8, shadow = default_dirt}},
    disabled_graphical_set = {base = {position = {x=icon_col[4],y=icon_row[4]}, border = 0, corner_size = 8, shadow = default_dirt}},
    stretch_image_to_widget_size = false
  }
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
function menuButtonIcons(name, font)
  local font = "helmod_font_normal"
  local font_bold = "helmod_font_bold"
  local font_white = {r=1, g=1, b=1}
  local font_black = {r=0, g=0, b=0}
  local icon_row = function(default, hovered, clicked, disabled) 
    return {17 * (default - 1), 17 * (hovered - 1), 17 * (clicked - 1), 17 * (disabled - 1)}
  end
  local icon_col = function(default, hovered, clicked, disabled) 
    if default == nil then return {570,570,570,570} end
    return {17 * (default - 1), 17 * (hovered - 1), 17 * (clicked - 1), 386 + 17 * (disabled - 1)}
  end
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 32, "default", font, font_white, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 24, "sm_default", font, font_white, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 32, nil, font, font_white, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 24, "sm", font, font_white, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(2,3,4,1), 32, "selected", font, font_black, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(2,3,4,1), 24, "sm_selected", font, font_black, font_black)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,3,4,1), 32, "dark", font, font_white, font_black)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,3,4,1), 24, "sm_dark", font, font_white, font_black)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(3,3,4,1), 32, "dark_selected", font, font_white, font_black)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(3,3,4,1), 24, "sm_dark_selected", font, font_white, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 32, "bold", font_bold, font_black, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 24, "sm_bold", font_bold, font_black, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(2,3,4,1), 32, "bold_selected", font_bold, font_white, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(2,3,4,1), 24, "sm_bold_selected", font_bold, font_white, font_black)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,3,4,1), 32, "dark_bold", font_bold, font_white, font_black)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,3,4,1), 24, "sm_dark_bold", font_bold, font_white, font_black)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(3,3,4,1), 32, "dark_bold_selected", font_bold, font_white, font_black)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(3,3,4,1), 24, "sm_dark_bold_selected", font_bold, font_white, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,9,10,2), 32, "red", font, font_white, font_white)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,9,10,2), 24, "sm_red", font, font_white, font_white)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,9,10,2), 32, "dark_red", font, font_white, font_white)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,9,10,2), 24, "sm_dark_red", font, font_white, font_white)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(9,11,10,2), 32, "actived_red", font, font_white, font_white)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(9,11,10,2), 24, "sm_actived_red", font, font_white, font_white)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(11,9,10,2), 32, "selected_red", font, font_white, font_white)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(11,9,10,2), 24, "sm_selected_red", font, font_white, font_white)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,7,8,3), 32, "green", font, font_white, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,7,8,3), 24, "sm_green", font, font_white, font_black)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,7,8,3), 32, "dark_green", font, font_white, font_black)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,7,8,3), 24, "sm_dark_green", font, font_white, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(5,7,8,3), 32, "actived_green", font, font_black, font_black)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(5,7,8,3), 24, "sm_actived_green", font, font_black, font_black)

  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,7,8,3), 32, "selected_green", font, font_white, font_black)
  menuButtonIcon(name, icon_row(1,2,2,2), icon_col(1,7,8,3), 24, "sm_selected_green", font, font_white, font_black)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 32, "selected_yellow", font, font_white, font_white)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(1,3,4,1), 24, "sm_selected_yellow", font, font_white, font_white)

  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(), 36, "flat2", font, font_white, font_white)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(), 32, "flat", font, font_white, font_white)
  menuButtonIcon(name, icon_row(2,2,2,2), icon_col(), 24, "sm_flat", font, font_white, font_white)
end
menuButtonIcons("menu")

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Button] default
default_gui["helmod_frame_button"] = {
  type = "button_style",
  parent = "frame_action_button",
  size = 32,
  padding = -4,
}
default_gui["helmod_frame_button_selected"] = {
  type = "button_style",
  parent = "helmod_frame_button",
  default_graphical_set =
  {
    base = {position = {17, 17}, corner_size = 8},
    shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}
  },
}
default_gui["helmod_frame_button_actived_red"] = {
  type = "button_style",
  parent = "helmod_frame_button",
  default_graphical_set =
  {
    base = {position = {136, 17}, corner_size = 8},
    shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}
  },
}
-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Button] default

local corner_size = {3, 3}
default_gui["helmod_button_default"] = {
  type = "button_style",
  font = "helmod_font_normal",
  default_font_color={r=1, g=1, b=1},
  horizontal_align = "center",
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
  pie_progress_color = {r=1, g=1, b=1},
  stretch_image_to_widget_size = true
}

local corner_size2 = {8, 8}
default_gui["helmod_button_help_menu"] = {
  type = "button_style",
  font = "helmod_font_bold",
  horizontal_align = "left",
  top_padding = 2,
  right_padding = 2,
  bottom_padding = 2,
  left_padding = 2,
  top_margin = 2,
  bottom_margin = 0,
  height = 28,
  default_font_color={r=255/255, g=230/255, b=192/255},
  default_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {0, 0}),
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {34, 17}),
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {51, 17}),
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {17, 17}),
  pie_progress_color = {r=1, g=1, b=1},
  horizontally_squashable = "on",
  horizontally_stretchable = "on"
}

default_gui["helmod_button_help_menu_selected"] = {
  type = "button_style",
  parent = "helmod_button_help_menu",
  font = "helmod_font_bold",
  default_font_color={r=0, g=0, b=0},
  default_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {51, 17}),
  hovered_font_color={r=0, g=0, b=0},
  hovered_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {34, 17}),
  clicked_font_color={r=1, g=1, b=1},
  clicked_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {51, 17}),
  disabled_font_color={r=0.5, g=0.5, b=0.5},
  disabled_graphical_set = compositionIcon("__core__/graphics/gui-new.png", corner_size2, {17, 17}),
}

default_gui["helmod_button_help_menu2"] = {
  type = "button_style",
  parent = "helmod_button_help_menu",
  font = "helmod_font_normal",
  default_font_color={r=1, g=1, b=1},
  top_margin = 0,
  left_padding = 20
}

default_gui["helmod_button_help_menu2_selected"] = {
  type = "button_style",
  parent = "helmod_button_help_menu_selected",
  top_margin = 0,
  left_padding = 20
}
-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Button] left

default_gui["helmod_button_left"] = {
  type = "button_style",
  parent = "helmod_button_default",
  horizontal_align = "left"
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
  {suffix="_green",offset = 108},
  {suffix="_flat"},
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
  if style.suffix == "_flat" then
    default_gui["helmod_button_select_icon"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=150}, {top=0,right=0,bottom=0,left=0}, true),
    }
  else
    default_gui["helmod_button_select_icon"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
    }
  end
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
  if style.suffix == "_flat" then
    default_gui["helmod_button_select_icon_xxl"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon_xxl",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=150}, {top=0,right=0,bottom=0,left=0}, true),
    }
  else
    default_gui["helmod_button_select_icon_xxl"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon_xxl",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
    }
  end
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
  if style.suffix == "_flat" then
    default_gui["helmod_button_select_icon_m"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon_m",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=150}, {top=0,right=0,bottom=0,left=0}, true),
    }
  else
    default_gui["helmod_button_select_icon_m"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon_m",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
    }
  end
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
  if style.suffix == "_flat" then
    default_gui["helmod_button_select_icon_sm"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon_sm",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=0,y=150}, {top=0,right=0,bottom=0,left=0}, true),
    }
  else
    default_gui["helmod_button_select_icon_sm"..style.suffix] = {
      type = "button_style",
      parent = "helmod_button_icon_sm",
      default_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      hovered_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=148,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      clicked_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=184,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true),
      disabled_graphical_set = monolithIcon("__core__/graphics/gui.png", monolith_size, monolith_scale, {0,0}, {x=111,y=icon_offset_y+style.offset}, {top=0,right=0,bottom=0,left=0}, true)
    }
  end
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