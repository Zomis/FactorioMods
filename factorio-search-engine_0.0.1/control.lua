local event = require("__flib__.event")

event.on_init(function()
	global.searches = {}
	global.players = {}
	for i in pairs(game.players) do
		global.players[i] = {}
	end
end)

event.on_player_created(function(e)
	global.players[e.player_index] = global.players[e.player_index] or {}
end)
event.on_player_removed(function(e)
    global.players[e.player_index] = nil
end)

require "v2/main"

--event.on_tick(function (e) Async:on_tick(e) end)
