local default_gui = data.raw["gui-style"].default

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
-- Style of default
--
-- @field [parent=#Textfield] default
default_gui["helmod_textfield_filter"] = {
  type = "textbox_style",
  parent = "search_textfield_with_fixed_width",
  minimal_width = 200,
  maximal_width = 200
}

-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Textfield] element
default_gui["helmod_textfield_element"] = {
  type = "textbox_style",
  parent = "search_textfield_with_fixed_width",
  font = "helmod_font_normal",
  minimal_width = 50,
  maximal_width = 50
}

-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Textfield] element
default_gui["helmod_textfield_element_green"] = {
  type = "textbox_style",
  parent = "helmod_textfield_element",
  default_background =
      {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 3,
        position = {8, 80},
        scale = 1
      },
      active_background =
      {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 3,
        position = {0, 80},
        scale = 1
      }
}

-------------------------------------------------------------------------------
-- Style of element
--
-- @field [parent=#Textfield] element
default_gui["helmod_textfield_element_red"] = {
  type = "textbox_style",
  parent = "helmod_textfield_element",
  default_background =
      {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 3,
        position = {8, 88},
        scale = 1
      },
      active_background =
      {
        filename = "__helmod__/graphics/gui.png",
        corner_size = 3,
        position = {0, 88},
        scale = 1
      }
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
-- @field [parent=#Label] default

default_gui["helmod_label_header"] = {
  type = "label_style",
  parent = "label",
  font = "helmod_font_header",
  top_padding = 0,
  right_padding = 0,
  bottom_padding = 0,
  left_padding = 0,
  font_color = {245/255, 219/255, 194/255}
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
-- @field [parent=#Label] element

default_gui["helmod_label_element_black"] = {
  type = "label_style",
  parent = "helmod_label_element",
  font_color = {0, 0, 0}
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] element

default_gui["helmod_label_overlay"] = {
  type = "label_style",
  parent = "helmod_label_element",
  font = "helmod_font_medium_bold_border"
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
-- @field [parent=#Label] element

default_gui["helmod_label_element_black_m"] = {
  type = "label_style",
  parent = "helmod_label_element_m",
  font_color = {0, 0, 0}
}

-------------------------------------------------------------------------------
-- Style of default
--
-- @field [parent=#Label] element

default_gui["helmod_label_overlay_m"] = {
  type = "label_style",
  parent = "helmod_label_element_m",
  font = "helmod_font_small_bold_border"
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
  single_line = false,
  horizontally_squashable = "on",
  horizontally_stretchable = "on"
}

-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help_text

default_gui["helmod_label_help_text"] = {
  type = "label_style",
  parent = "helmod_label_default",
  left_padding = 10,
  single_line = false,
  horizontally_squashable = "on",
  horizontally_stretchable = "on"
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
-- @field [parent=#Label] help_title

default_gui["helmod_label_help_menu_1"] = {
  type = "label_style",
  parent = "helmod_label_help",
  font = "helmod_font_title_frame",
  hovered_font_color = {1, 0.74, 0.40},
  clicked_font_color = {0.98, 0.66, 0.22},
  top_padding = 2,
  bottom_padding = 0
}

default_gui["helmod_label_help_menu_1_selected"] = {
  type = "label_style",
  parent = "helmod_label_help_menu_1",
  font_color = {0.98, 0.66, 0.22}
}

-------------------------------------------------------------------------------
-- Style of text
--
-- @field [parent=#Label] help_normal

default_gui["helmod_label_help_menu_2"] = {
  type = "label_style",
  parent = "helmod_label_help",
  hovered_font_color = {1, 0.74, 0.40},
  clicked_font_color = {0.98, 0.66, 0.22},
  left_padding = 10,
  top_padding = 0,
  bottom_padding = 0
}

default_gui["helmod_label_help_menu_2_selected"] = {
  type = "label_style",
  parent = "helmod_label_help_menu_2",
  font_color = {0.98, 0.66, 0.22}
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
