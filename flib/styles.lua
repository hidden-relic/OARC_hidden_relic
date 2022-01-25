local data_util = require('flib.data-util')

--- Softmod custom flib style fix
-- @module styles
-- @usage local style = require('flib.styles')
--        gui_style = style["flib_selected_frame_action_button"]

local styles = {}
function styles.default_inner_glow(tint_value, scale_value)
    return {
        position = {183, 128},
        corner_size = 8,
        tint = tint_value,
        scale = scale_value,
        draw_type = "inner"
    }
end
function styles.default_glow(tint_value, scale_value)
    return {
        position = {200, 128},
        corner_size = 8,
        tint = tint_value,
        scale = scale_value,
        draw_type = "outer"
    }
end
function styles.top_glow(tint_value, scale_value) -- only top side
    return {
        top = {position = {208, 128}, size = {1, 8}},
        center = {position = {208, 136}, size = {1, 1}},
        tint = tint_value,
        scale = scale_value,
        draw_type = "outer"
    }
end

styles.default_dirt_color = {15, 7, 3, 100}
styles.hard_shadow_color = {0, 0, 0, 1}
styles.default_shadow_color = {0, 0, 0, 0.35}

styles.top_shadow = styles.top_glow(styles.default_shadow_color, 0.5)
styles.default_dirt = styles.default_glow(styles.default_dirt_color, 0.5)
styles.button_hovered_font_color = {}
styles.selected_hovered_font_color = styles.button_hovered_font_color
styles.selected_clicked_font_color = styles.button_hovered_font_color
styles.selected_font_color = styles.button_hovered_font_color

styles.selected_graphical_set = {
    base = {position = {225, 17}, corner_size = 8},
    shadow = styles.default_dirt
}
styles.selected_hovered_graphical_set = {
    base = {position = {369, 17}, corner_size = 8},
    shadow = styles.default_dirt
}
styles.selected_clicked_graphical_set = {
    base = {position = {352, 17}, corner_size = 8},
    shadow = styles.default_dirt
}

-- BUTTON STYLES
styles.flib_selected_frame_action_button = {
    default_font_color = styles.button_hovered_font_color,
    default_graphical_set = {
        base = {position = {225, 17}, corner_size = 8},
        shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}
    },
    hovered_font_color = styles.button_hovered_font_color,
    hovered_graphical_set = {
        base = {position = {369, 17}, corner_size = 8},
        shadow = {position = {440, 24}, corner_size = 8, draw_type = "outer"}
    }
}

styles.flib_selected_tool_button = {
    default_font_color = styles.selected_font_color,
    default_graphical_set = styles.selected_graphical_set,
    hovered_font_color = styles.selected_hovered_font_color,
    hovered_graphical_set = styles.selected_hovered_graphical_set,
    clicked_font_color = styles.selected_clicked_font_color,
    clicked_graphical_set = styles.selected_clicked_graphical_set
}

styles.flib_tool_button_light_green = {
    padding = 2,
    top_margin = 0
}

styles.flib_tool_button_dark_red = {
    default_graphical_set = {
        base = {
            filename = data_util.dark_red_button_tileset,
            position = {0, 0},
            corner_size = 8
        },
        shadow = styles.default_dirt
    },
    hovered_graphical_set = {
        base = {
            filename = data_util.dark_red_button_tileset,
            position = {17, 0},
            corner_size = 8
        },
        shadow = styles.default_dirt,
        glow = styles.default_glow({236, 130, 130, 127}, 0.5)
    },
    clicked_graphical_set = {
        base = {
            filename = data_util.dark_red_button_tileset,
            position = {34, 0},
            corner_size = 8
        },
        shadow = styles.default_dirt
    }
}

-- EMPTY-WIDGET STYLES

styles.flib_dialog_footer_drag_handle = {
    height = 32,
    horizontally_stretchable = "on"
}

styles.flib_dialog_footer_drag_handle_no_right = {
    right_margin = 0
}

styles.flib_dialog_titlebar_drag_handle = {
    right_margin = 0
}

styles.flib_horizontal_pusher = {
    horizontally_stretchable = "on"
}

styles.flib_titlebar_drag_handle = {
    left_margin = 4,
    right_margin = 4,
    height = 24,
    horizontally_stretchable = "on"
}

styles.flib_vertical_pusher = {
    vertically_stretchable = "on"
}

-- FLOW STYLES

styles.flib_indicator_flow = {
    vertical_align = "center"
}

styles.flib_titlebar_flow = {
    horizontal_spacing = 8
}

-- FRAME STYLE

styles.flib_shallow_frame_in_shallow_frame = {
    padding = 0,
    graphical_set = {
        base = {
            position = {85, 0},
            corner_size = 8,
            center = {position = {76, 8}, size = {1, 1}},
            draw_type = "outer"
        },
        shadow = styles.default_inner_shadow
    },
    vertical_flow_style = {vertical_spacing = 0}
}

-- IMAGE STYLES

styles.flib_indicator = {
    size = 16,
    stretch_image_to_widget_size = true
}

-- SCROLL-PANE STYLES

styles.flib_naked_scroll_pane = {
    extra_padding_when_activated = 0,
    padding = 12,
    graphical_set = {shadow = styles.default_inner_shadow}
}

styles.flib_naked_scroll_pane_under_tabs = {
    graphical_set = {
        base = {top = {position = {93, 0}, size = {1, 8}}, draw_type = "outer"},
        shadow = styles.default_inner_shadow
    }
}

styles.flib_naked_scroll_pane_no_padding = {
    padding = 0
}

styles.flib_shallow_scroll_pane = {
    padding = 0,
    graphical_set = {
        base = {position = {85, 0}, corner_size = 8, draw_type = "outer"},
        shadow = styles.default_inner_shadow
    }
}

-- TABBED PANE STYLES

styles.flib_tabbed_pane_with_no_padding = {
    tab_content_frame = {
        top_padding = 0,
        bottom_padding = 0,
        left_padding = 0,
        right_padding = 0,
        graphical_set = {
            base = {
                -- Same as tabbed_pane_graphical_set - but without bottom
                top = {position = {76, 0}, size = {1, 8}},
                center = {position = {76, 8}, size = {1, 1}}
            },
            shadow = styles.top_shadow
        }
    }
}

-- TEXTFIELD STYLES

styles.flib_widthless_textfield = {width = 0}

styles.flib_widthless_invalid_textfield = {
    width = 0
}

return styles