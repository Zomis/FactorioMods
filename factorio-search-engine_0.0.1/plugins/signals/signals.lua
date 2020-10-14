local search_utils = require "search_utils"
local tables = require "__flib__.table"
local gui = require "__flib__.gui"
local function add_to_table(results, type)
    return function(v, k)
        table.insert(results, { type = type, name = k, localised_name = v.localised_name })
    end
end

local plugin = {
    options_type = "signals",
    options_search = function(force, text)
        local filtered_items = tables.filter(game.item_prototypes, function(_, key) return search_utils.name_contains(key, text) end)
        local filtered_fluids = tables.filter(game.fluid_prototypes, function(_, key) return search_utils.name_contains(key, text) end)
        local filtered_signals = tables.filter(game.virtual_signal_prototypes, function(_, key) return search_utils.name_contains(key, text) end)

        local results = {}
        tables.for_each(filtered_items, add_to_table(results, "item"))
        tables.for_each(filtered_fluids, add_to_table(results, "fluid"))
        tables.for_each(filtered_signals, add_to_table(results, "virtual-signal"))
        return results
    end,
    options_render = function(context, results)
        for _, v in pairs(results) do
            local sprite_button = context.parent.add {
                type = "sprite-button",
                name = "signals_result__" .. v.type .. "_" .. v.name,
                style = "slot_button",
                sprite = v.type .. "/" .. v.name
            }
            sprite_button.tooltip = v.localised_name
        end
        gui.update_filters("small_search_window.choose_things.result_button", context.player.index, {"signals_result"}, "add")
    end
}

return plugin
