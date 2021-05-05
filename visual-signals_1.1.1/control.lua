local events = require("__flib__.event")
local gui = require("__flib__.gui-beta")
local tables = require("__flib__.table")

local update_interval = 30

local window_gui = require("gui/window")
local big_gui = require("gui/big_gui")
local display_gui = require("gui/display")

--[[
global:
    visual_signals:
        ["entity-" .. surface.name .. "_" .. x .. "_" .. y] = { entity, title }
    guis:
        [gui_id] = {
          player = player,
          gui = gui (has sub-flows which has a tag for the key in visual_signals table)
        }
]]--

require("migration")
require("entities")

gui.hook_events(function(e)
    local action = gui.read_action(e)
    if action then
        local type = action.type
        local name = action.action
        if type == "mod-gui" or type == "big-gui" then
            big_gui.handle_action(action, e)
        end
        if type == "generic" and name == "close" then
            local element = e.element
            while element.parent and element.parent.parent do
                element = element.parent
            end
            element.destroy()
        end
        if type == "gui" then
            local gui_id = action.gui_id
        end
    end
end)

events.on_tick(function(event)
    if 0 == game.tick % update_interval then
        local guis = global.guis
        if not guis then
            return
        end
        for gui_id, player_gui in pairs(guis) do
            local displays = player_gui.gui.displays
            if displays then
                for visual_signal_key, visual_signal_gui in pairs(displays) do
                    display_gui.update(visual_signal_key, visual_signal_gui)
                end
            end
        end
    end
end)

events.on_player_changed_force(function(event)
    local player = game.players[event.player_index]
    local player_guis = tables.filter(global.guis, function(v) return v.player == player end)

    for gui_id in pairs(player_guis) do
        window_gui.destroy(gui_id)
    end
end)
