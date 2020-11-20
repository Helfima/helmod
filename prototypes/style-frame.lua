local default_gui = data.raw["gui-style"].default

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

local width_scroll=8
local width_block_info=290
local width_recipe_column=220

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Frame] default

default_gui["helmod_frame"] = {
  type = "frame_style",
  parent = "frame",
  -- marge interieure
  padding  = 4
}

-------------------------------------------------------------------------------
-- Style of default
--
default_gui["helmod_inside_frame"] = {
  type = "frame_style",
  parent = "inside_shallow_frame",
  -- marge interieure
  padding = 4
}

-------------------------------------------------------------------------------
-- Style of default
--
default_gui["helmod_deep_frame"] = {
  type = "frame_style",
  parent = "inside_deep_frame",
  -- marge interieure
  padding = 4
}

-------------------------------------------------------------------------------
-- Style of default
--
default_gui["helmod_scroll_pane"] = {
  type = "scroll_pane_style",
  parent = "scroll_pane",
  -- marge interieure
  padding = 4,
  extra_padding_when_activated = 0
}

-------------------------------------------------------------------------------
-- Style of default
--
default_gui["helmod_tabbed_frame"] = {
  type = "frame_style",
  parent = "inside_deep_frame",
  -- marge interieure
  top_padding = 4,
  right_padding = 0,
  left_padding = 0,
  bottom_padding = 0
}

-------------------------------------------------------------------------------
-- Style of default
--
default_gui["helmod_tabbed_pane"] = {
  type = "tabbed_pane_style",
  parent = "tabbed_pane",
  tab_content_frame =
  {
    type = "frame_style",
    top_padding = 4,
    right_padding = 4,
    left_padding = 4,
    bottom_padding = 4,
    graphical_set = tabbed_pane_graphical_set
  },
  tab_container =
  {
    type = "horizontal_flow_style",
    horizontally_stretchable =  "on",
    left_padding = 4,
    right_padding = 4,
    horizontal_spacing = 0
  }
}

-- OLD
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Frame] default

default_gui["helmod_frame_header"] = {
  type = "frame_style",
  parent = "frame",
  -- marge interieure
  top_padding  = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  graphical_set =
  {
    base = {position = {4, 4}, corner_size = 4}
  }
}
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
    --shadow = default_shadow
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
local style_element_max = 7
-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Frame] element
--

for _,style in pairs(style_element_list) do
  for i = 1, style_element_max do
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
  for i = 1, style_element_max do
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
  for i = 1, style_element_max do
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
  for i = 1, style_element_max do
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
  for i = 1, style_element_max do
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