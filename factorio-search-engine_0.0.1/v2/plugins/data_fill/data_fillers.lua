local plugins_support = require("v2/plugins/plugins_support")

local function check_networks(entity, connection, results)
    local red
    local green
    if connection then
        red = entity.get_circuit_network(defines.wire_type.red, connection)
        green = entity.get_circuit_network(defines.wire_type.green, connection)
    else
        red = entity.get_circuit_network(defines.wire_type.red)
        green = entity.get_circuit_network(defines.wire_type.green)
    end

    if red then
        results.red = red
    end
    if green then
        results.green = green
    end
end

local data_fillers = {
    position = {
        requires = { "entity" },
        provides = {
            position = function(data)
                if data.entity and data.entity.valid then
                    return data.entity.position
                end
                return nil
            end
        }
    },
    recipe = {
        requires = { "entity" },
        provides = {
            recipe = function(data)
                local entity = data.entity
                if not entity then return nil end
                if not entity.valid then return nil end
                if entity.type == "assembling-machine" then
                    return entity.get_recipe()
                elseif entity.type == "furnace" then
                    return entity.get_recipe() or entity.previous_recipe
                end
            end
        }
    },
    circuit_networks = {
        requires = { "entity" },
        provides = {
            circuit_networks = function(data)
                local entity = data.entity
                if not entity.valid then return nil end

                local circuit_connections = entity.circuit_connection_definitions
                if not circuit_connections or next(circuit_connections) == nil then
                    -- Apparently Factorio doesn't like checking circuit networks on entities without a circuit network,
                    -- such as boiler, generator, entity-ghost, and a lot of others
                    -- Use this check to skip the entities that don't have a circuit connection

                    -- TODO: For performance, store entity-types with/without possible circuit connection in a map.
                    --   Reset lookup map whenever on_configuration_changed and set all entities to "unknown"?
                    return nil
                end

                local results = {}
                if entity.type == "decider-combinator" or entity.type == "arithmetic-combinator" then
                    check_networks(entity, defines.circuit_connector_id.combinator_input, results)
                    check_networks(entity, defines.circuit_connector_id.combinator_output, results)
                else
                    check_networks(entity, nil, results)
                end
                return results
            end
        }
    }
}

local function data_fill(data_filler_id, data)
    for k, provide_function in pairs(data_fillers[data_filler_id].provides) do
        data[k] = provide_function(data)
    end
end

local function provides(data_filler_id)
    return data_fillers[data_filler_id].provides
end

return {
    plugins_support = plugins_support(data_fillers),
    provides = provides,
    data_fill = data_fill
}
