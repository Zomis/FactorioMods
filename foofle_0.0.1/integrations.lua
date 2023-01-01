local tables = require("__flib__.table")

local integrations = {}

local function find(info)
    return tables.filter(integrations, function(v)
        return remote.call(v.mod_name, v.settings.supported_check, info)
    end, true)
end

local function invoke(integration, player, info)
    remote.call(integration.mod_name, integration.settings.callback, player, info)
end

remote.add_interface("foofle", {
    open = function(query)
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
        table.insert(integrations, {
            button = button,
            mod_name = mod_name,
            settings = settings,
        })
    end
})

return {
    find = find,
    invoke = invoke
}