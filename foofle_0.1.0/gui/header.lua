local function header(caption)
    return {
        type = "flow",
        ref = {"titlebar"},
        children = {
            { type = "label", style = "frame_title", caption = caption, ignored_by_interaction = true },
            { type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true },
            {
                type = "sprite-button",
                style = "frame_action_button",
                sprite = "utility/close_white",
                hovered_sprite = "utility/close_black",
                clicked_sprite = "utility/close_black",
                actions = {
                    on_click = { type = "generic", action = "close-window" },
                }
            }
        }
    }
end

return header