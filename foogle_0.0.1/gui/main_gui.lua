local guis = require("__flib__.gui")

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
        return
    end
    if action.type == "generic" then
        handle_action(action, event)
    elseif action.type == "???" then
    end
end)
