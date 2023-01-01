local selection_options = require("gui/selection_options")

local function open(player)
    player.cursor_stack.set_stack({ name = "foofle" })
    player.cursor_stack_temporary = true
end

local function on_dropped_item(event)
    if not event.entity or not event.entity.stack then
        return
    end
    if event.entity.stack.name == "foofle" then
        event.entity.stack.clear()
    end
end

local function clear_foofle_selector(player)
    local stack = player.cursor_stack
    if stack.valid_for_read and stack.name == "foofle" then
        stack.clear()
    end
end

local function on_player_selected_area(event)
    if event.item ~= "foofle" then
        return
    end
    local player = game.players[event.player_index]
    clear_foofle_selector(player)
    if next(event.entities) == nil then
        -- Check event.tiles, then check their prototypes, then check `items_to_place_this`
        -- https://lua-api.factorio.com/latest/LuaTilePrototype.html#LuaTilePrototype.items_to_place_this
        return
    end
    selection_options.show_entities(player, event.entities)
end

script.on_event(defines.events.on_player_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_alt_selected_area, on_player_selected_area)
script.on_event(defines.events.on_player_dropped_item, on_dropped_item)

return {
    open = open
}
