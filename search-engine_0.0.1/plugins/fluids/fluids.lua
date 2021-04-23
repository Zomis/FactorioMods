local search_utils = require "search_utils"
local table = require "__flib__.table"
local gui = require "__flib__.gui"

local plugin = {
    options_type = "fluids",
    options_search = function(force, text)
        local filtered = table.filter(game.fluid_prototypes, function(_, key)
            return search_utils.name_contains(key, text)
        end)
        return table.map(filtered, function(_, key) return key end)
    end,
    options_render = function(context, results)
        for name in pairs(results) do
            local sprite_button = context.parent.add {
                type = "sprite-button",
                name = "fluids_result__" .. name,
                style = "slot_button",
                sprite = "fluid/" .. name
            }
            sprite_button.tooltip = game.fluid_prototypes[name].localised_name
        end
        gui.update_filters("small_search_window.choose_things.result_button", context.player.index, {"fluids_result"}, "add")
    end
}

return plugin
