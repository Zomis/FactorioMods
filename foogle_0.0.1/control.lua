local main_gui = require("gui/main_gui")
local selector = require("selector")
local events = require("__flib__.event")
require("integrations")

events.on_lua_shortcut(function(event)
    -- Toolbar
    if event.prototype_name == "foogle" then
        selector.open(game.players[event.player_index])
    end
end)

events.register("foogle", function(event)
    -- Key shortcut
    selector.open(game.players[event.player_index])
end)
