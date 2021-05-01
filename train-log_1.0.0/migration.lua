local events = require("__flib__.event")
local migration = require("__flib__.migration")
local mod_gui_button = require("gui/mod_gui/button")

local migrations = {
    ["1.0.0"] = function()
        for _, player in pairs(game.players) do
            if player.valid then
                mod_gui_button.add_mod_gui_button(player)
            end
        end
    end
}

events.on_configuration_changed(function(e)
    -- this does return true or false, but we don't care about the result at this time.
    migration.on_config_changed(e, migrations)
end)
