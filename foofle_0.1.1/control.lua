require("gui/main_gui")
local selector = require("selector")
local events = require("__flib__.event")
require("integration_interface")
local integration_fnei = require("integrations/fnei")

events.on_lua_shortcut(function(event)
    -- Toolbar
    if event.prototype_name == "foofle" then
        selector.open(game.players[event.player_index])
    end
end)

events.register("foofle", function(event)
    -- Key shortcut
    selector.open(game.players[event.player_index])
end)

script.on_init(function()
    integration_fnei.on_start()
end)
script.on_load(function()
    integration_fnei.on_start()
end)
