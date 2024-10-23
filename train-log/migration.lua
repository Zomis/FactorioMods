local mod_gui_button = require("gui/mod_gui_button")

local function add_mod_gui_buttons()
    for _, player in pairs(game.players) do
        if player.valid then
            mod_gui_button.add_mod_gui_button(player)
        end
    end
end

script.on_configuration_changed(function()
    add_mod_gui_buttons()
end)
