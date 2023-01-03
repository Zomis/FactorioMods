local guis = require("__flib__.gui")
local single = require("gui/single")
local integrations = require("integrations")
local auto_integration = require("auto_integration")

local function find_root(element)
    if element.parent and not element.parent.parent then
        return element
    end
    if element.parent then
        return find_root(element.parent)
    end
    return element
end

local function handle_action(action, event)
    if action.action == "close-window" then
        local root = find_root(event.element)
        root.destroy()
    end
end

guis.hook_events(function(event)
	local action = guis.read_action(event)
	if not action then
        auto_integration.on_event(event)
        return
    end
    if action.type == "generic" then
        handle_action(action, event)
    elseif action.action_type == "goto" then -- This event also passes another type parameter, therefore `action_type`
        single.open(action, event)
        local root = find_root(event.element)
        root.destroy()
    elseif action.type == "integration" then
        integrations.invoke(action.integration, game.players[event.player_index], action.info)
        local root = find_root(event.element)
        root.destroy()
    end
end)
