local function check_networks(entity, connection, results)
    local red = entity.get_circuit_network(defines.wire_type.red, connection)
    local green = entity.get_circuit_network(defines.wire_type.green, connection)
    if red then
        results.red = red
    end
    if green then
        results.green = green
    end
end

local function get_circuit_networks(entity)
    if not entity.valid then return nil end

    local circuit_connections = entity.circuit_connection_definitions
    if not circuit_connections or next(circuit_connections) == nil then
        -- Factorio doesn't like checking circuit networks on entities without a circuit network,
        -- such as boiler, generator, entity-ghost, and a lot of others
        -- Use this check to skip the entities that don't have a circuit connection
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

return {
    get_circuit_networks = get_circuit_networks
}