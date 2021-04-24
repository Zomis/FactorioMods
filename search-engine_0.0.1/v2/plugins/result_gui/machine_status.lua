local empty_widget = { type = "empty-widget" }

local entity_status = {
    [defines.entity_status.working] = { description = "working", signal = "signal-green" },
    [defines.entity_status.normal] = { description = "normal", signal = "signal-green" },
    [defines.entity_status.no_power] = { description = "no_power", signal = "signal-red" },
    [defines.entity_status.low_power] = { description = "low_power", signal = "signal-yellow" },
    [defines.entity_status.no_fuel] = { description = "no_fuel", signal = "signal-red" },
    [defines.entity_status.disabled_by_script] = { description = "disabled_by_script", signal = "signal-black" },
    [defines.entity_status.marked_for_deconstruction] = { description = "marked_for_deconstruction", signal = "signal-red" },
    [defines.entity_status.no_recipe] = { description = "no_recipe", signal = "signal-red" },
    [defines.entity_status.no_ingredients] = { description = "no_ingredients", signal = "signal-red" },
    [defines.entity_status.no_input_fluid] = { description = "no_input_fluid", signal = "signal-red" },
    [defines.entity_status.fluid_ingredient_shortage] = { description = "fluid_ingredient_shortage", signal = "signal-red" },
    [defines.entity_status.full_output] = { description = "full_output", signal = "signal-blue" },
    [defines.entity_status.item_ingredient_shortage] = { description = "item_ingredient_shortage", signal = "signal-red" }
}

local function sprite_button_for_status(status)
    if not status then return empty_widget end
    local entry = entity_status[status] or nil
    if not entry then return empty_widget end
    return {
        type = "sprite-button",
        style = "slot_button",
        sprite = "virtual-signal/" .. entry.signal,
        tooltip = { "search_engine_" .. entry.description }
    }
end

return {
    requires = { "entity" },
    displays = {
        machine_status = function(data)
            if not data.entity then return empty_widget end
            if not data.entity.valid then return empty_widget end
            local status = data.entity.status
            if not status then return empty_widget end
            return sprite_button_for_status(status)
        end
    }
}