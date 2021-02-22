local CONTAINERS = "Containers"

return {
    search_options = {
        fluids = { CONTAINERS }
    },
    search_loops = {
        fluids = {
            [CONTAINERS] = function(_, _, task_data)
                local player = game.get_player(task_data.player_index)
                return player.surface.find_entities_filtered {
                    type = "storage-tank",
                    force = player.force
                }
            end
        }
    },
    search_filters = {
        fluids = {
            [CONTAINERS] = {
                function(player, search_params, item, results)
                    if not item.valid then return end
                    local amount = item.get_fluid_count(search_params.name)
                    if amount <= 0 then return nil end
                    table.insert(results, {
                        entity = item,
                        location = item.position,
                        owner = item.last_user,
                        count = amount
                    })
                end
            }
        }
    }
    -- game.print(tostring(#game.player.surface.find_entities_filtered { type="transport-belt", force=game.player.force }))
}
