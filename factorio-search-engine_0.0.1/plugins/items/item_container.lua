local CONTAINERS = "Containers"

return {
    search_options = {
        items = { CONTAINERS }
    },
    search_loops = {
        items = {
            [CONTAINERS] = function(_, _, task_data)
                local player = game.get_player(task_data.player_index)
                return player.surface.find_entities_filtered {
                    type = "container",
                    force = player.force
                }
            end
        }
    },
    search_filters = {
        items = {
            [CONTAINERS] = {
                function(player, search_params, item)
                    local inventory = item.get_inventory(defines.inventory.chest)
                    if not inventory then return nil end
                    for k, v in pairs(inventory.get_contents()) do
                        if k == search_params.name then
                            return {
                                entity = item,
                                location = item.position,
                                owner = item.last_user,
                                count = v
                            }
                        end
                    end
                end
            }
        }
    }
    -- game.print(tostring(#game.player.surface.find_entities_filtered { type="transport-belt", force=game.player.force }))
}
