local mod_gui = require("__core__.lualib.mod-gui")

local function create_mod_gui_button(player)
    -- Disabled for now, until button looks better (should be darker and should show magnifying glass)
    if true then return end

    local button_flow = mod_gui.get_button_flow(player)
    if button_flow.search_engine then
        return
    end
    button_flow.add {
        type = "button",
        name = "search_engine",
        style = mod_gui.button_style,
        sprite = "search_engine_magnify",
        tooltip = { "search_engine.search_engine" },
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
            frame_action_button()
        }
    }
end

return {
    create_mod_gui_button = create_mod_gui_button,
    header = header
}
