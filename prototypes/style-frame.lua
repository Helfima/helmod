local default_gui = data.raw["gui-style"].default

-------------------------------------------------------------------------------
---Name of display
--
---|--------------------------------------------------|
---| Flow.main                                        |
---| |-----------------------|----------------------| |
---| | Flow.info             | Flow.dialog          | |
---| | |-------------------| | |------------------| | |
---| | | Frame.main_menu   | | | Frame.dialog     | | |
---| | |-------------------| | |                  | | |
---| | | Frame.data        | | |                  | | |
---| | |                   | | |                  | | |
---| | |                   | | |                  | | |
---| | |                   | | |                  | | |
---| | |-------------------| | |------------------| | |
---| |-----------------------|----------------------| |
---|--------------------------------------------------|
--

local width_scroll = 8
local width_block_info = 290
local width_recipe_column = 220

default_gui["helmod_frame"] = {
    type    = "frame_style",
    parent  = "frame",
    ---marge interieure
    padding = 4
}

default_gui["helmod_inside_frame"] = {
    type = "frame_style",
    parent = "inside_shallow_frame",
    ---marge interieure
    padding = 4
}

default_gui["helmod_deep_frame"] = {
    type = "frame_style",
    parent = "inside_deep_frame",
    ---marge interieure
    padding = 4
}

default_gui["helmod_scroll_pane"] = {
    type = "scroll_pane_style",
    parent = "scroll_pane",
    ---marge interieure
    padding = 4,
    extra_padding_when_activated = 0
}

default_gui["helmod_tabbed_frame"] = {
    type = "frame_style",
    parent = "inside_deep_frame",
    ---marge interieure
    top_padding = 4,
    right_padding = 0,
    left_padding = 0,
    bottom_padding = 0
}

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
        horizontally_stretchable = "on",
        left_padding = 4,
        right_padding = 4,
        horizontal_spacing = 0
    }
}

---OLD
default_gui["helmod_frame_header"] = {
    type           = "frame_style",
    parent         = "frame",
    ---marge interieure
    top_padding    = 0,
    right_padding  = 0,
    bottom_padding = 0,
    left_padding   = 0,
    graphical_set  =
    {
        base = { position = { 4, 4 }, corner_size = 4 }
    }
}

default_gui["helmod_frame_hidden"] = {
    type                  = "frame_style",
    ---marge interieure
    top_padding           = 0,
    right_padding         = 0,
    bottom_padding        = 0,
    left_padding          = 0,

    horizontal_flow_style =
    {
        type = "horizontal_flow_style",
        horizontal_spacing = 0,
    },

    vertical_flow_style   =
    {
        type = "vertical_flow_style",
        vertical_spacing = 0
    },
    graphical_set         =
    {
        type = "composition",
        filename = "__helmod__/graphics/gui.png",
        load_in_minimal_mode = true,
        corner_size = { 1, 1 },
        position = { 0, 0 }
    }
}

default_gui["helmod_frame_default"] = {
    type                  = "frame_style",
    ---padding of the content area of the frame
    top_padding           = 0,
    right_padding         = 0,
    bottom_padding        = 4,
    left_padding          = 0,
    graphical_set         =
    {
        base = { position = { 0, 0 }, corner_size = 8 },
        --shadow = default_shadow
    },
    horizontal_flow_style = { type = "horizontal_flow_style" },
    vertical_flow_style   = { type = "vertical_flow_style" },
    header_flow_style     = { type = "horizontal_flow_style", vertical_align = "center", maximal_height = 24 },
    header_filler_style   =
    {
        type = "empty_widget_style",
        parent = "draggable_space_header",
        height = 24
    },
    use_header_filler     = true,
    border                = {}
}

local panel_colors = {}
panel_colors["blue"] = { 329, 48 }
panel_colors["blue2"] = { 346, 48 }
panel_colors["green"] = { 431, 48 }
for key, position in pairs(panel_colors) do
    default_gui["helmod_frame_color_" .. key] = {
        type = "frame_style",
        parent = "helmod_frame_default",
        graphical_set =
        {
            base = { position = position, corner_size = 8, opacity = 0.75 }

        }
    }
end

local function frame_element(style_name, x, y, minimal_width, filename)
    default_gui[style_name] = {
        type                     = "frame_style",
        graphical_set            = {
            filename = filename,
            corner_size = 1,
            position = { x, y }
        },
        top_padding              = 2,
        right_padding            = 0,
        bottom_padding           = 2,
        left_padding             = 0,
        minimal_width            = minimal_width,
        horizontally_stretchable = "on",
        vertically_stretchable   = "off"
    }
end

local style_element_suffixes = {
    "yellow",
    "orange",
    "red",
    "green",
    "blue",
    "gray",
    "magenta",
    "silver",
    "gold",
    "brown"
}
local style_element_list = {}

for index, value in ipairs(style_element_suffixes) do
    local element = { suffix = value, x = 0, y = 40 + index * 8 - 8 }
    table.insert(style_element_list, element)
end

local style_element_max = 7


for _, style in pairs(style_element_list) do
    for i = 1, style_element_max do
        local x = style.x + (i - 1) * 8
        local y = style.y

        local style_name = nil
        style_name = table.concat({ "helmod_frame_element_w80", style.suffix, i }, "_")
        frame_element(style_name, x, y, 80, "__helmod__/graphics/gui.png")

        style_name = table.concat({ "helmod_frame_element_w50", style.suffix, i }, "_")
        frame_element(style_name, x, y, 50, "__helmod__/graphics/gui.png")

        style_name = table.concat({ "helmod_frame_element_w30", style.suffix, i }, "_")
        frame_element(style_name, x, y, 30, "__helmod__/graphics/gui.png")
    end
end

local frame_y = 0
for _, frame_color in pairs(defines.frame_colors) do
    for _, value in ipairs(frame_color) do
        for i = 1, 4 do
            local x = (i - 1) * 8
            local y = frame_y * 8

            local style_name = nil
            style_name = table.concat({ "helmod_frame_element_w80", value, i }, "_")
            frame_element(style_name, x, y, 80, "__helmod__/graphics/frame.png")
    
            style_name = table.concat({ "helmod_frame_element_w50", value, i }, "_")
            frame_element(style_name, x, y, 50, "__helmod__/graphics/frame.png")
    
            style_name = table.concat({ "helmod_frame_element_w30", value, i }, "_")
            frame_element(style_name, x, y, 30, "__helmod__/graphics/frame.png")
        end
        frame_y = frame_y + 1
    end
end

for _, style in pairs(style_element_list) do
    for i = 1, style_element_max do
        local style_name = table.concat({ "helmod_frame_colored", style.suffix, i }, "_")
        local x = style.x + (i - 1) * 8
        local y = style.y

        default_gui[style_name] = {
            type                     = "frame_style",
            graphical_set            = {
                filename = "__helmod__/graphics/gui.png",
                corner_size = 1,
                position = { x, y }
            },
            top_padding              = 2,
            right_padding            = 2,
            bottom_padding           = 2,
            left_padding             = 2,
            horizontally_stretchable = "on",
            vertically_stretchable   = "on"
        }
    end
end

default_gui["helmod_frame_panel"] = {
    type              = "frame_style",
    parent            = "helmod_frame_default",
    top_padding       = 0,
    right_padding     = 0,
    bottom_padding    = 0,
    left_padding      = 0,
    use_header_filler = false
}

default_gui["helmod_frame_recipe_info"] = {
    type = "frame_style",
    parent = "helmod_frame_default",
    minimal_width = width_recipe_column,
    maximal_width = width_recipe_column
}

default_gui["helmod_flow_default"] = {
    type = "flow_style",
    horizontal_spacing = 1,
    vertical_spacing = 1
}

default_gui["helmod_flow_horizontal"] = {
    type = "horizontal_flow_style",
    horizontal_spacing = 0
}

default_gui["helmod_flow_vertical"] = {
    type = "vertical_flow_style",
    vertical_spacing = 0
}

local style_branch_list = {
    { suffix = "branch",    x = 32, y = 0 },
    { suffix = "branch_end", x = 40, y = 0 },
    { suffix = "branch_next", x = 48, y = 0 }
}
local style_branch_max = 7

for _, style in pairs(style_branch_list) do
    local style_name = table.concat({ "helmod_frame", style.suffix }, "_")
    local x = style.x
    local y = style.y

    default_gui[style_name] = {
        type                     = "frame_style",
        graphical_set            = {
            filename = "__helmod__/graphics/gui.png",
            corner_size = 2,
            position = { x, y }
        },
        top_padding              = 0,
        right_padding            = 0,
        bottom_padding           = 0,
        left_padding             = 0,

        width                    = 16,
        height                   = 16,
        horizontally_stretchable = "off",
        vertically_stretchable   = "off"
    }
end

