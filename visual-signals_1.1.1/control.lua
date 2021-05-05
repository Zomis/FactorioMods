local events = require("__flib__.event")
local gui2 = require("gui2")
local update_interval = 30
local big_gui = require("big_gui")

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

events.on_tick(function(event)
    if 0 == game.tick % update_interval then
        for gui_id, player_gui in pairs(global.guis) do
            local displays = player_gui.gui.displays
            if displays then
                for visual_signal_key, visual_signal_gui in pairs(displays) do
                    gui2.update(visual_signal_key, visual_signal_gui)
                end
            end
        end
    end
end)
