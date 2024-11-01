local gui_handlers = require("gui/handlers")

local function sprite_button_type_name_amount(type, name, amount, color, gui_id)
    local prototype = nil
    if type == "item" then
        prototype = prototypes.item[name]
    elseif type == "fluid" then
        prototype = prototypes.fluid[name]
    elseif type == "virtual-signal" then
        prototype = prototypes.virtual_signal[name]
    end
    local sprite = prototype and (type .. "/" .. name) or nil
    local tooltip = prototype and prototype.localised_name or (type .. "/" .. name)
    return {
        type = "sprite-button",
        style = color and "flib_slot_button_" .. color or "flib_slot_button_default",
        sprite = sprite,
        number = amount,
        handler = gui_handlers.toolbar,
        tags = {
            action_event = defines.events.on_gui_click,
            action_type = "filter",
            filter_type = type,
            filter_value = name,
            gui_id = gui_id
        },
        tooltip = tooltip
    }
end

local function sprite_button_for_state(state)
    local description = ""
    if state == defines.train_state.on_the_path	then
        description = { "train-log.train_state-on_the_path" }
    elseif state == defines.train_state.no_schedule then
        description = { "train-log.train_state-no_schedule" }
    elseif state == defines.train_state.no_path then
        description = { "train-log.train_state-no_path" }
    elseif state == defines.train_state.arrive_signal then
        description = { "train-log.train_state-arrive_signal" }
    elseif state == defines.train_state.wait_signal then
        description = { "train-log.train_state-wait_signal" }
    elseif state == defines.train_state.arrive_station then
        description = { "train-log.train_state-arrive_station" }
    elseif state == defines.train_state.wait_station then
        description = { "train-log.train_state-wait_station" }
    elseif state == defines.train_state.manual_control_stop then
        description = { "train-log.train_state-manual_control_stop" }
    elseif state == defines.train_state.manual_control then
        description = { "train-log.train_state-manual_control" }
    elseif state == defines.train_state.destination_full then
        description = { "train-log.train_state-destination_full" }
    end
    return {
        type = "sprite-button",
        style = "flib_slot_button_default",
        sprite = "item/iron-plate",
        number = state,
        tooltip = description
    }
end

local function signal_for_entity(entity)
    local empty_signal = { type = "virtual", name = "signal-0" }
    if not entity then return empty_signal end
    if not entity.valid then return empty_signal end

    local k, v = next(entity.prototype.items_to_place_this)
    if k then
        return { type = "item", name = v.name }
    end
    return empty_signal
end

return {
    sprite_button_type_name_amount = sprite_button_type_name_amount,
    sprite_button_for_state = sprite_button_for_state,
    signal_for_entity = signal_for_entity
}