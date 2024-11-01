require("gui/handlers")

local train_log_gui = require("gui/main_gui")
require("train_log")
require("gui/mod_gui_button")
require("migration")
local flib_gui = require("__flib__.gui")
local foofle = require("foofle")

script.on_init(function()
    storage.guis = {}
    storage.history = {}
    storage.trains = {}
end)

script.on_event("train-log-open", function(event)
	train_log_gui.open_or_close_gui(game.players[event.player_index])
end)

script.on_event(defines.events.on_player_changed_surface, function(event)
    local player = game.players[event.player_index]
    train_log_gui.update_player_gui(player)
end)

script.on_load(function()
    foofle.on_load()
end)

flib_gui.handle_events()
