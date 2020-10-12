local SEARCH_NAME = "Signals"

local function check_networks(entity, signal_id, connection)
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
    if red and red.get_signal(signal_id) > 0 then
        return {
            entity = entity,
            wire_type = "red",
            KEY = red.network_id,
            connected_circuit_count = red.connected_circuit_count,
            signals = red.signals,
            location = entity.position,
            owner = entity.last_user,
            count = red.get_signal(signal_id)
        }
    end
    if green and green.get_signal(signal_id) > 0 then
        return {
            entity = entity,
            wire_type = "green",
            KEY = green.network_id,
            connected_circuit_count = green.connected_circuit_count,
            signals = green.signals,
            location = entity.position,
            owner = entity.last_user,
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
                function(player, search_params, item)
                    local circuit_connections = item.circuit_connection_definitions
                    if not circuit_connections or next(circuit_connections) == nil then
                        -- Apparently Factorio doesn't like checking circuit networks on entities without a circuit network,
                        -- such as boiler, generator, entity-ghost, and a lot of others
                        -- Use this check to skip the entities that don't have a circuit connection

                        -- TODO: To improve performance, the entity-types with/without a possible circuit connection can be stored in a lookup map.
                        --       This lookup map would probably reset whenever on_configuration_changed and set all entities to "unknown"?
                        return
                    end
                    local signal_id = { type = "item", name = "solid-fuel" }
                    if item.type == "decider-combinator" or item.type == "arithmetic-combinator" then
                        return check_networks(item, signal_id, defines.circuit_connector_id.combinator_input) or
                                check_networks(item, signal_id, defines.circuit_connector_id.combinator_output)
                    else
                        return check_networks(item, signal_id)
                    end
                end
            }
        }
    }
}
