local event = require("__flib__.event")
local gui = require("__flib__.gui")
local Async = require "async"

event.on_init(function()
	gui.init()
	gui.build_lookup_tables()

	global.players = {}
	for i in pairs(game.players) do
		global.players[i] = {}
	end
end)

event.on_load(function()
	gui.build_lookup_tables()
end)

event.on_player_created(function(e)
	global.players[e.player_index] = global.players[e.player_index] or {}
end)
event.on_player_removed(function(e)
    global.players[e.player_index] = nil
    gui.remove_player_filters(e.player_index)
end)

require "gui/step_1_enter_text"
require "gui/step_2_choose_things"

gui.register_handlers()
event.on_tick(function (e) Async:on_tick(e) end)
