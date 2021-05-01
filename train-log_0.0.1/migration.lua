local migration = require("__flib__.migration")

local migrations = {
    ["1.0.0"] = function()
        for _, player in pairs(game.players) do
            if player.valid then
                add_mod_gui_button(player)
            end
        end
    end
}

event.on_configuration_changed(function(e)
    if migration.on_config_changed(e, migrations) then
        -- this does return true or false, but we don't care about the result.
    end
end)
