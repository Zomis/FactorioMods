local mod_gui = require("__core__.lualib.mod-gui")
local gui = require("__flib__.gui-beta")

local function add_mod_gui_button(player)
    mod_gui.get_button_flow(player).add {
        type = "sprite-button",
        style = "slot_button", --mod_gui.button_style, -- or "slot_button" ?
        sprite = "item/gui-signal-display",
        tags = {
            [script.mod_name] = {
                flib = {
                    on_click = { type = "mod-gui", action = "open" }
                }
            }
        },
        tooltip = { "visual-signals.mod-gui-tooltip" }
    }
end

return {
    add_mod_gui_button = add_mod_gui_button
}
