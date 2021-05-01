local mod_gui = require("__core__.lualib.mod-gui")
local events = require("__flib__.event")

local function add_mod_gui_button(player)
    local flow = mod_gui.get_button_flow(player)
    if flow.train_log then
        return
    end
    flow.add {
        type = "sprite-button",
        name = "train_log",
        style = "slot_button",
        sprite = "train_log_train-36-white",
        tags = {
            [script.mod_name] = {
                flib = {
                    on_click = { type = "generic", action = "open-train-log" }
                }
            }
        },
        tooltip = { "train-log.mod-gui-tooltip" }
    }
end

events.on_player_joined_game(function(event)
    local player = game.players[event.player_index]
    add_mod_gui_button(player)
end)

return {
    add_mod_gui_button = add_mod_gui_button
}
