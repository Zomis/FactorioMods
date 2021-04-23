local tables = require("__flib__/table")

local function is_supported(plugin, search)
    for _, v in pairs(plugin.requires) do
        if not search.provides[v] then return false end
    end
    return true
end

return function(plugins_table)
    return {
        enabled_plugins = function(search)
            return tables.filter(plugins_table, function(value)
                return is_supported(value, search)
            end)
        end,
        is_supported = is_supported,
        is_supported_key = function(plugin_id, search)
            return is_supported(plugins_table[plugin_id], search)
        end
    }
end
