local CONTAINERS = "Containers"

return {
    search_options = {
        items = { CONTAINERS }
    },
    search_loops = {
        function(player, query)
        end
    },
    create_task = function(player, query)
        -- TODO: Start by checking matching item prototypes
        return player.surface.find_entities_filtered {
            type = "container", -- TODO: Add other inventories as well (furnace, assembling-machine...)
            force = player.force
        }
    end,
    step = function(task, item)
        local inventory = item.get_output_inventory()
        if not inventory then return nil end
        for k in inventory.get_contents() do
            if string.find(k, task.text) then
                return {
                    entity = item.entity,
                    location = item.entity.position,
                    owner = item.last_user
                }
            end
        end
    end,
    result = function()
    end
}
