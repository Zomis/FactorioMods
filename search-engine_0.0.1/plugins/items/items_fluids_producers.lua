local PRODUCERS = "Producers"

local function expected_amount(product)
    local expected = product.amount
    if not expected then
      expected = (product.amount_min + product.amount_max) / 2.0
    end
    local probability = product.probability or 1
  
    return expected * probability
end

local function recipe_produces(recipe, product_type, product_name)
    if recipe == nil then return false end
    for _, product in pairs(recipe.products) do
        if product.type == product_type and product.name == product_name then
            return expected_amount(product)
        end
    end
    return false
end

return {
    search_options = {
        items = { PRODUCERS },
        fluids = { PRODUCERS }
    },
    search_loops = {
        items = {
            [PRODUCERS] = function(_, _, task_data)
                local player = game.get_player(task_data.player_index)
                return player.surface.find_entities_filtered {
                    type = { "assembling-machine", "furnace" },
                    force = player.force
                }
            end
        },
        fluids = {
            [PRODUCERS] = function(_, _, task_data)
                local player = game.get_player(task_data.player_index)
                return player.surface.find_entities_filtered {
                    type = "assembling-machine",
                    force = player.force
                }
            end
        }
    },
    search_filters = {
        items = {
            [PRODUCERS] = {
                function(player, search_params, item, results)
                    if not item.valid then return end

                    local recipe = nil
                    if item.type == "assembling-machine" then
                        recipe = item.get_recipe()
                    end
                    if item.type == "furnace" then
                        recipe = item.previous_recipe
                    end

                    local amount = recipe_produces(recipe, "item", search_params.name)
                    if amount ~= false then
                        table.insert(results, {
                            entity = item,
                            location = item.position,
                            owner = item.last_user,
                            count = amount
                        })
                    end
                end
            }
        },
        fluids = {
            [PRODUCERS] = {
                function(player, search_params, item, results)
                    if not item.valid then return end
                    if item.type == "assembling-machine" then
                        local amount = recipe_produces(item.get_recipe(), "fluid", search_params.name)
                        if amount ~= false then
                            table.insert(results, {
                                entity = item,
                                location = item.position,
                                owner = item.last_user,
                                count = amount
                            })
                        end
                    end
                end
            }
        }
    }
    -- game.print(tostring(#game.player.surface.find_entities_filtered { type="transport-belt", force=game.player.force }))
}
