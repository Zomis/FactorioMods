local event = require("__flib__.event")
local gui_generic = require("v2/gui/gui_generic")

event.on_init(function()
	global.searches = {}
	for _, player in pairs(game.players) do
		gui_generic.create_mod_gui_button(player)
	end
end)

event.on_player_created(function(e)
	local player = game.players[e.player_index]
	gui_generic.create_mod_gui_button(player)
end)

require "v2/main"

--event.on_tick(function (e) Async:on_tick(e) end)
