local events = require("__flib__.event")
local gui = require("__flib__.gui-beta")
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

gui.hook_events(function(e)
    local action = gui.read_action(e)
    if action then
        local type = action.type
        local name = action.action
        if type == "mod-gui" and name == "open" then
            big_gui.mod_gui(action, e)
        end
        if type == "gui" then
            local gui_id = action.gui_id
        end
    end
end)

events.on_tick(function(event)
    if 0 == game.tick % update_interval then
        for gui_id, player_gui in pairs(global.guis) do
            local displays = player_gui.gui.displays
            if displays then
                for visual_signal_key, visual_signal_gui in pairs(displays) do
                    display_gui.update(visual_signal_key, visual_signal_gui)
                end
            end
        end
    end
end)
