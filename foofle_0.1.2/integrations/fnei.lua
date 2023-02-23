local api = require "api"

local function fnei_supported(info)
    if not remote.interfaces["fnei"] then
        return false
    end
    return info.type == "fluid" or info.type == "item"
end

api.add_plugin {
    id = "fnei-craft",
    name = { "foofle-fnei.craft" },
    quick_button = {
        type = "button",
        caption = { "foofle-fnei.craft" },
        tooltip = { "foofle-fnei.craft" }
    },
    supported = fnei_supported,
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
    supported = fnei_supported,
    on_quick_button = function(_, info)
        remote.call("fnei", "show_recipe_for_prot", "usage", info.type, info.name)
    end
}
