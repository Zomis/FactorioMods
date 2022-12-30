local mod_gui_button = require("gui/mod_gui_button")

local migrations_table = {
    ["1.1.1"] = function()
        mod_gui_button.add_mod_gui_buttons()
    end
}

local function on_configuration_changed(event)
    if migration.on_config_changed(event, migrations_table) then
        -- place for generic migrations
    end
end

script.on_configuration_changed(function(event)
    on_configuration_changed(event)
end)
