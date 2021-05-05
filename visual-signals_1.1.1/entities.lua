local events = require("__flib__.event")
local tables = require("__flib__.table")

events.on_gui_opened(function(event)
    local player = game.players[event.player_index]
    if event.gui_type ~= defines.gui_type.entity then
        return
    end
    local entity = event.entity
    if entity.name == "gui-signal-display" then
        for _, visual_signal_entry in pairs(global.visual_signals) do
            if visual_signal_entry.entity == entity then
                player.print { "visual-signals.opened-entity-title", visual_signal_entry.title }
            end
        end
    end
end)

local function on_place_entity(event)
    local entity = event.created_entity
    local key = "vs-" .. entity.surface.index .. "_" .. entity.position.x .. "_" .. entity.position.y
    global.visual_signals[key] = {
        entity = entity,
        title = "Untitled"
    }
end

local function on_remove_entity(event)
    local entity = event.entity
    local visual_signals = tables.filter(global.visual_signals, function(v) return v.entity == entity end)
    for visual_signal_key, visual_signal_entry in pairs(visual_signals) do
        global.visual_signals[visual_signal_key] = nil
    end
    for gui_id, player_gui in pairs(global.guis) do
        local display_guis = tables.filter(player_gui.gui.displays, function(v, k) return visual_signals[k] end)
        for visual_signal_key, display_gui in pairs(display_guis) do
            display_gui.flow.destroy()
            player_gui.gui.displays[visual_signal_key] = nil
        end
    end
end

events.register({ defines.events.on_built_entity, defines.events.on_robot_built_entity }, on_place_entity,
    {
        { filter = "name", name = "gui-signal-display" }
    }
)

events.register({
    defines.events.on_entity_died,
    defines.events.on_player_mined_entity,
    defines.events.on_robot_mined_entity
}, on_remove_entity, {
    { filter = "name", name = "gui-signal-display" }
})
