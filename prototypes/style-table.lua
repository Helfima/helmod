local default_gui = data.raw["gui-style"].default

default_gui["helmod_table_default"] = {
  type = "table_style",
  horizontal_spacing = 2,
  vertical_spacing = 2,
  top_padding = 0,
  right_padding = 1,
  bottom_padding = 0,
  left_padding = 1,
  vertical_align = "top"
}

default_gui["helmod_table_border"] = {
  type = "table_style",
  parent = "helmod_table_default",
  border = border_image_set(),
}

default_gui["helmod_table_result"] = {
  type = "table_style",
  parent = "helmod_table_default",
  default_row_graphical_set =
  {
    type = "composition",
    filename = "__helmod__/graphics/gui.png",
    corner_size = {1, 1},
    position = {8, 32},
    opacity = 1
  },
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__helmod__/graphics/gui.png",
    corner_size = {1, 1},
    position = {0, 32},
    opacity = 1
  }
}

default_gui["helmod_table_element"] = {
  type = "table_style",
  parent = "helmod_table_default",
  horizontally_stretchable = "off"
}

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

default_gui["helmod_table_list"] = {
  type = "table_style",
  horizontal_spacing = 1,
  vertical_spacing = 1,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top",
  horizontally_stretchable = "off"
}

default_gui["helmod_table_tab"] = {
  type = "table_style",
  horizontal_spacing = 0,
  vertical_spacing = 0,
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
}

default_gui["helmod_table_rule"] = {
  type = "table_style",
  horizontal_spacing = 2,
  vertical_spacing = 2,
  top_padding = 0,
  right_padding = 10,
  bottom_padding = 0,
  left_padding = 0,
  vertical_align = "top"
}

default_gui["helmod_factory_modules"] = {
  type = "table_style",
  parent = "helmod_table_default",
  minimal_width = 36,
  vertical_spacing = 0,
}

default_gui["helmod_factory_info"] = {
  type = "table_style",
  parent = "helmod_table_default",
  left_padding = -5,
}

default_gui["helmod_beacon_modules"] = {
  type = "table_style",
  parent = "helmod_table_default",
  minimal_width = 18
}

default_gui["helmod_table_recipe_modules"] = {
  type = "table_style",
  parent = "table",
  minimal_height = 36
}

default_gui["helmod_table_recipe_selector"] = {
  type = "table_style",
  horizontal_spacing = 2,
  vertical_spacing = 2,
  top_padding = 1,
  right_padding = 0,
  bottom_padding = 1,
  left_padding = 0
}

default_gui["helmod_table-odd"] = {
  type = "table_style",
  -- default orange with alfa
  hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
  cell_padding = 1,
  vertical_align = "top",
  horizontal_spacing = 3,
  vertical_spacing = 2,
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__core__/graphics/gui.png",
    corner_size = {1, 1},
    position = {78, 18},
    opacity = 0.7
  }
}

default_gui["helmod_table-rule-odd"] = {
  type = "table_style",
  -- default orange with alfa
  hovered_row_color = {r=0.98, g=0.66, b=0.22, a=0.7},
  selected_row_color = default_orange_color,
  cell_padding = 1,
  vertical_align = "top",
  horizontal_spacing = 10,
  vertical_spacing = 2,
  odd_row_graphical_set =
  {
    type = "composition",
    filename = "__helmod__/graphics/gui.png",
    corner_size = {1, 1},
    position = {0, 32},
    opacity = 1
  }
}
