local api = require "api"

api.add_plugin {
    id = "factory-search",
    name = { "mod-name.FactorySearch" },
    quick_button = {
        type = "button",
        caption = { "mod-name.FactorySearch" }
    },
    supported = function(info)
        if not remote.interfaces["factory-search"] then
            return false
        end
        return info.type == "fluid" or info.type == "item"
    end,
    on_quick_button = function(player, info)
        remote.call("factory-search", "search", player, info)
    end
}
