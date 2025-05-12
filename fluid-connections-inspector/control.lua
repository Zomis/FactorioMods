local fluid_connections = require("fluid_connections")
local gui = require("gui")
local SHORTCUT_KEY = "fluid-connections-inspector"

function open_gui(player, entity)
    local results = fluid_connections(entity)
    if not results then
        return
    end
    if type(results) == "string" then
        if results == "multiple-fluidboxes" then
            game.print({ "fluid-connections-inspector.multiple-fluidboxes" })
        elseif results == "no-segment-id" then
            game.print({ "fluid-connections-inspector.no-segment-id" })
        end
        return
    end
    gui.open(player, results)
end

script.on_event(defines.events.on_lua_shortcut, function(event)
    if event.prototype_name ~= SHORTCUT_KEY then
        return
    end
    local player = game.players[event.player_index]
    player.set_shortcut_toggled(event.prototype_name, not player.is_shortcut_toggled(event.prototype_name))
end)

script.on_event(defines.events.on_gui_opened, function(event)
    if not event.entity then
        return
    end
    if not event.entity.fluidbox then
        return
    end

    local player = game.players[event.player_index]
    if not player.is_shortcut_toggled(SHORTCUT_KEY) then
        return
    end
    if event.gui_type == defines.gui_type.entity then
        if event.entity.type == "pipe" or event.entity.type == "pipe-to-ground" then
            open_gui(game.players[event.player_index], event.entity)
        end
    end
end)
