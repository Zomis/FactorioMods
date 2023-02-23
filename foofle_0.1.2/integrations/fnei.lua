local api = require "api"

api.add_plugin {
    id = "fnei-craft",
    name = { "foofle-fnei.craft" },
    quick_button = {
        type = "button",
        caption = { "foofle-fnei.craft" },
        tooltip = { "foofle-fnei.craft" }
    },
    supported = function(info)
        return info.type == "fluid" or info.type == "item"
    end,
    on_quick_button = function(_, info)
        remote.call("fnei", "show_recipe_for_prot", "craft", info.type, info.name)
    end
}

api.add_plugin {
    id = "fnei-usage",
    name = { "foofle-fnei.usage" },
    quick_button = {
        type = "button",
        caption = { "foofle-fnei.usage" },
        tooltip = { "foofle-fnei.usage" }
    },
    supported = function(info)
        return info.type == "fluid" or info.type == "item"
    end,
    on_quick_button = function(_, info)
        remote.call("fnei", "show_recipe_for_prot", "usage", info.type, info.name)
    end
}
