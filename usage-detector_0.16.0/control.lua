local gui = require "gui"

local function onInit()
  for _, player in pairs(game.players) do
    gui.setupGui(player)
  end
end

local function onPlayerJoined(event)
  local player = game.players[event.player_index]
  gui.setupGui(player)
end

script.on_init(onInit)

script.on_event(defines.events.on_tick, gui.onTick)
script.on_event(defines.events.on_gui_click, gui.onClick)
script.on_event(defines.events.on_player_joined_game, onPlayerJoined)
