local integration_list = require("integration_list")
local single = require("gui.single")

remote.add_interface("foofle", {
    open = function(query)
    end,
    open_single = function(player_index, info)
        single.open(info, { player_index = player_index })
    end,
    add_integration = function(mod_name, settings)
        if not settings.callback then
            error("settings must specify a callback function name")
        end
        if not settings.supported_check then
            error("settings must specify a supported_check function name")
        end
        local button = settings.button or {
            type = "button",
            caption = mod_name
        }
        settings.button = nil
        table.insert(integration_list.integrations, {
            button = button,
            mod_name = mod_name,
            settings = settings,
        })
    end
})
