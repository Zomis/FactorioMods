local events = require("__flib__.event")

local train_log_gui = require("gui/main_gui")
require("train_log")
require("gui/mod_gui_button")
require("migration")

events.on_init(function()
    global.guis = {}
    global.history = {}
    global.trains = {}
end)

events.register("train-log-open", function(event)
	train_log_gui.open(game.players[event.player_index])
end)
