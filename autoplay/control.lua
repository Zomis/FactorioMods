-- TODO: Check if there's a multi-starting area plugin that allows multiple forces to start a range apart.
local GUI = require "gui"
require "data/factorio_data"

local function on_configuration_changed(data)
    for _, player in pairs(game.players) do
        GUI:create_gui(player)
    end
end

local function on_click(event)
    GUI:on_click(event)
end

local function on_console_command(event)
    GUI:autoplay_command(event)
end

--script.on_init(on_init)
script.on_configuration_changed(on_configuration_changed)
script.on_event(defines.events.on_console_command, on_console_command)
--script.on_event(defines.events.on_tick, onTick)
--script.on_event(defines.events.on_gui_checked_state_changed, onCheckboxClick)
script.on_event(defines.events.on_gui_click, on_click)
--script.on_load(on_load)
