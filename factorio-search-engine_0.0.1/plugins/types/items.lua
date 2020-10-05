local search_utils = require "search_utils"
local table = require "__flib__.table"
local gui = require "__flib__.gui"

local plugin = {
    options_type = "items",
    options_search = function(force, text)
        local filtered = table.filter(game.item_prototypes, function(_, key)
            return search_utils.name_contains(key, text)
        end)
        return table.map(filtered, function(_, key) return key end)
    end,
    options_render = function(context, results)
        for name in pairs(results) do
            local sprite_button = context.parent.add {
                type = "sprite-button",
                name = "result_slot_button__" .. name,
                style = "slot_button",
                sprite = "item/" .. name,
                number = count
            }
        end
    end
}

return plugin
