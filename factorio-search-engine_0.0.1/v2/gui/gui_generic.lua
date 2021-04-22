-- create mod_gui button top left
local function create_guis(player)
    mod_gui.get_button_flow(player).add {
        type = "button",
        style = mod_gui.button_style,
        caption = "Search",
        tags = {
            [script.mod_name] = {
            flib = {
                on_click = "open_search_window"
            }
        }
      }
    }
end

local function frame_action_button()
    return {
        type = "sprite-button",
        style = "frame_action_button",
        actions = {
            on_click = "close_window"
        }
    }
end

local function header()
    return {
        type = "flow", ref = {"titlebar", "flow"},
        children = {
            {type = "label", style = "frame_title", caption = {"search_engine.header"}, ignored_by_interaction = true},
            {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
            frame_action_button("close")
      }
    }
end

return {
    header = header
}
