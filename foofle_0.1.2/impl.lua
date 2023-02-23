local tables = require("__flib__.table")

local plugins = {}
local impl = {}

function impl.find(info)
    return tables.filter(plugins, function(v)
        local supported = v.supported
        local type_of = type(supported)
        if type_of == "function" then
            return supported(info)
        else
            error("unsupported type of 'supported': " .. type_of)
        end
    end, true)
end

function impl.invoke(plugin_id, player, info)
    local plugin = plugins[plugin_id]
    plugin.on_quick_button(player, info)
end

function impl.add_plugin(plugin)
    if plugins[plugin.id] then
        error("plugin with id already added: " .. plugin.id)
    end
    plugins[plugin.id] = plugin
end

return impl