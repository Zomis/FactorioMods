-- Paste picker.
--
-- When a paste would write more than one item signal, ask the player which ones
-- to paste: all of them, or a single item. The game's paste event cannot be
-- cancelled, so the paste is remembered and applied when a button is clicked.

local paste_to = require("paste_to")
local circuit_condition_types = require("circuit_condition_types")

local FRAME_NAME = "copy-paste-recipe-signals-paste-picker"
local ALL_SPRITE = "virtual-signal/signal-everything"

local function get_player(player_index)
    local player = game.get_player(player_index)
    if player and player.valid then
        return player
    end
    return nil
end

-- The item signals a paste can write.
local function item_signals(signals)
    local items = {}
    for _, signal in ipairs(signals) do
        local id = signal.signal
        if id and id.type == "item" and prototypes.item[id.name] then
            table.insert(items, signal)
        end
    end
    return items
end

-- Can this entity take item signals at all? Only these are worth asking about.
local function accepts_items(destination)
    local entity_type = destination.type
    local name = destination.name

    if entity_type == "logistic-container" then
        -- request slots live in requester and buffer chests
        local mode = destination.prototype.logistic_mode
        return mode == "requester" or mode == "buffer"
    end
    if name == "constant-combinator" or name == "ltn-combinator" then
        return true
    end
    if name == "stack-filter-inserter" or entity_type == "splitter" then
        return true
    end
    if name == "arithmetic-combinator" or name == "decider-combinator" then
        return true
    end
    return circuit_condition_types[entity_type] == true
end

local function pending_store()
    storage.paste_picker = storage.paste_picker or {}
    return storage.paste_picker
end

local function destroy_gui(player)
    if not player then
        return
    end
    local frame = player.gui.center[FRAME_NAME]
    if frame and frame.valid then
        frame.destroy()
    end
end

-- Forget the pending paste and close the picker.
local function clear(player_index)
    pending_store()[player_index] = nil
    destroy_gui(get_player(player_index))
end

-- Should the picker be shown for this paste?
local function should_prompt(destination, signals)
    if not accepts_items(destination) then
        return false
    end
    return table_size(item_signals(signals)) >= 2
end

local function add_item_button(flow, signal, index)
    local id = signal.signal
    local tooltip = { "copy-paste-recipe-signals-gui.paste-item-tooltip", { "item-name." .. id.name } }
    local sprite = "item/" .. id.name
    if helpers.is_valid_sprite_path(sprite) then
        flow.add {
            type = "sprite-button",
            sprite = sprite,
            tooltip = tooltip,
            tags = { cprs = "one", index = index },
            style = "slot_button"
        }
    else
        flow.add {
            type = "button",
            caption = { "item-name." .. id.name },
            tooltip = tooltip,
            tags = { cprs = "one", index = index }
        }
    end
end

local function build_gui(player, signals)
    local frame = player.gui.center.add {
        type = "frame",
        name = FRAME_NAME,
        direction = "vertical"
    }
    frame.add {
        type = "label",
        caption = { "copy-paste-recipe-signals-gui.paste-picker-title" }
    }
    local flow = frame.add {
        type = "flow",
        direction = "horizontal"
    }
    flow.add {
        type = "sprite-button",
        sprite = ALL_SPRITE,
        tooltip = { "copy-paste-recipe-signals-gui.paste-all-tooltip" },
        tags = { cprs = "all" },
        style = "slot_button"
    }
    for index, signal in ipairs(item_signals(signals)) do
        add_item_button(flow, signal, index)
    end
    frame.add {
        type = "button",
        caption = { "copy-paste-recipe-signals-gui.cancel" },
        tags = { cprs = "cancel" }
    }
end

-- Ask which of the copied items to paste. Returns true when the picker opened.
local function open(player_info, source, destination, signals)
    local player = player_info and player_info.player
    if not player or not player.valid then
        return false
    end
    local player_index = player.index
    clear(player_index)
    pending_store()[player_index] = {
        source = source,
        destination = destination,
        signals = signals
    }
    local ok, err = pcall(build_gui, player, signals)
    if not ok then
        -- A GUI problem must never crash the game or leave a pending paste.
        clear(player_index)
        log("copy-paste-recipe-signals: paste picker GUI error: " .. tostring(err))
        return false
    end
    return true
end

local function apply(player_index, chosen)
    local pending = pending_store()[player_index]
    pending_store()[player_index] = nil
    local player = get_player(player_index)
    destroy_gui(player)
    if not pending or not pending.destination or not pending.destination.valid then
        return
    end
    local player_info = {
        player = player,
        last_copy = {},
        settings = settings.get_player_settings(player_index)
    }
    local ok, paste_index = pcall(paste_to, pending.destination, chosen, player_info)
    if not ok then
        log("copy-paste-recipe-signals: paste picker error: " .. tostring(paste_index))
        if player then
            player.create_local_flying_text {
                text = "copy-paste-recipe-signals: paste error (see log)",
                create_at_cursor = true
            }
        end
        return
    end
    storage.player_info = storage.player_info or {}
    local info = storage.player_info[player_index] or {}
    info.last_copy = {
        from = pending.source,
        to = pending.destination,
        index = paste_index
    }
    storage.player_info[player_index] = info
end

-- Closes an open picker and forgets the pending paste, e.g. when a new paste
-- starts before the player has answered.
local function dismiss(player_index)
    clear(player_index)
end

script.on_event(defines.events.on_gui_click, function(event)
    local element = event.element
    if not element or not element.valid then
        return
    end
    local tags = element.tags
    if not tags or tags.cprs == nil then
        return
    end

    local player_index = event.player_index
    if tags.cprs == "cancel" then
        clear(player_index)
        return
    end

    local pending = pending_store()[player_index]
    local chosen
    if tags.cprs == "all" then
        chosen = pending and pending.signals
    else
        local signal = pending and item_signals(pending.signals)[tags.index]
        chosen = signal and { signal }
    end
    if not chosen then
        clear(player_index)
        return
    end
    apply(player_index, chosen)
end)

script.on_event(defines.events.on_player_left_game, function(event)
    clear(event.player_index)
end)

return {
    should_prompt = should_prompt,
    open = open,
    dismiss = dismiss,
    clear = clear,
    item_signals = item_signals
}
