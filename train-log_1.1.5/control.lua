local events = require("__flib__.event")

local train_log_gui = require("gui/main_gui")
require("train_log")
require("gui/mod_gui_button")
require("migration")
local foogle = require("foogle")

events.on_init(function()
    global.guis = {}
    global.history = {}
    global.trains = {}
end)

events.register("train-log-open", function(event)
	train_log_gui.open_or_close_gui(game.players[event.player_index])
end)

script.on_load(function()
    foogle.on_load()
end)
