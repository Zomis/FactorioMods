local single = require("gui.single")
local api = require("api")

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
        local button = settings.quick_button or settings.button or {
            type = "button",
            caption = mod_name
        }
        local supported_check = settings.supported_check
        settings.button = nil
        settings.quick_button = nil
        api.add_plugin {
            id = "mod-" .. mod_name,
            name = { "mod-name." .. mod_name },
            quick_button = button,
            on_quick_button = function(player, info)
                remote.call(mod_name, settings.callback, player, info)
            end,
            supported = function(info)
                return remote.call(mod_name, supported_check, info)
            end
        }
    end
})
