local gui = require "gui"

-- global.player_data: { player_index => ... }
--    each player has "jobs" which is a dictionary of gui_name("section0") => {
--      current_thing, current_furnaces, current_machines,
--      results, running(bool)
--    }

local function onInit()
  for _, player in pairs(game.players) do
    gui.setupGui(player)
  end
  global.player_data = {}
end

local function onPlayerJoined(event)
  local player = game.players[event.player_index]
  gui.setupGui(player)
end

script.on_init(onInit)

script.on_event(defines.events.on_tick, gui.onTick)
script.on_event(defines.events.on_player_joined_game, onPlayerJoined)
