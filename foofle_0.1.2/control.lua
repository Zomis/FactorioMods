require("gui/main_gui")
local selector = require("selector")
local events = require("__flib__.event")
local single = require("gui.single")
require("integration_interface")
require("foofle_integrations")

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

script.on_event("open-foofle", function(event)
    local player = game.players[event.player_index]
    if not event.selected_prototype then
        return
    end
    local prototype = event.selected_prototype
    if prototype.base_type == "item" or prototype.base_type == "fluid" then
        single.open({ type = prototype.base_type, name = prototype.name }, event)
    end
end)
