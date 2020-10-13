local SEARCH_NAME = "Signals"

local function check_networks(entity, signal_id, connection, results)
    -- TODO: Store the network_id, wire_type and the connected_circuit_count to show in results, and ONE entity - use a KEY
    local red
    local green
    if connection then
        red = entity.get_circuit_network(defines.wire_type.red, connection)
        green = entity.get_circuit_network(defines.wire_type.green, connection)
    else
        red = entity.get_circuit_network(defines.wire_type.red)
        green = entity.get_circuit_network(defines.wire_type.green)
    end
    if red and red.get_signal(signal_id) > 0 and not results[red.network_id] then
        results[red.network_id] = {
            entity = entity,
            wire_type = "red",
            network_id = red.network_id,
            connected_circuit_count = red.connected_circuit_count,
            signals = red.signals,
            location = entity.position,
            count = red.get_signal(signal_id)
        }
    end
    if green and green.get_signal(signal_id) > 0 and not results[green.network_id] then
        results[green.network_id] = {
            entity = entity,
            wire_type = "green",
            network_id = green.network_id,
            connected_circuit_count = green.connected_circuit_count,
            signals = green.signals,
            location = entity.position,
            count = green.get_signal(signal_id)
        }
    end
end

return {
    search_options = {
        signals = { SEARCH_NAME }
    },
    search_loops = {
        signals = {
            [SEARCH_NAME] = function(_, _, task_data)
                local player = game.get_player(task_data.player_index)
                return player.surface.find_entities_filtered {
                    force = player.force
                }
            end
        }
    },
    search_filters = {
        signals = {
            [SEARCH_NAME] = {
                function(player, search_params, item, results)
                    if not item.valid then return end
                    local circuit_connections = item.circuit_connection_definitions
                    if not circuit_connections or next(circuit_connections) == nil then
                        -- Apparently Factorio doesn't like checking circuit networks on entities without a circuit network,
                        -- such as boiler, generator, entity-ghost, and a lot of others
                        -- Use this check to skip the entities that don't have a circuit connection

                        -- TODO: To improve performance, the entity-types with/without a possible circuit connection can be stored in a lookup map.
                        --       This lookup map would probably reset whenever on_configuration_changed and set all entities to "unknown"?
                        return
                    end
                    -- TODO: Looking up the signal type and name in every iteration is inefficient
                    local signal_type = search_params.name:sub(1, search_params.name:find("_") - 1)
                    local signal_name = search_params.name:sub(search_params.name:find("_") + 1)
                    local signal_id = { type = signal_type, name = signal_name }
                    if item.type == "decider-combinator" or item.type == "arithmetic-combinator" then
                        check_networks(item, signal_id, defines.circuit_connector_id.combinator_input, results)
                        check_networks(item, signal_id, defines.circuit_connector_id.combinator_output, results)
                    else
                        check_networks(item, signal_id, nil, results)
                    end
                end
            }
        }
    }
}
