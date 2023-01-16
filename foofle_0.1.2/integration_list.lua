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

return {
    integrations = integrations,
    find = find,
    invoke = invoke
}