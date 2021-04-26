local empty_widget = { type = "empty-widget" }

local status_descriptions = {}
for status, number in pairs(defines.entity_status) do
    status_descriptions[number] = {"entity-status." .. status:gsub("_", "-")}
end

local entity_status = {
    [defines.entity_status.working] = "green",
    [defines.entity_status.normal] = "green",
    [defines.entity_status.no_power] = "red",
    [defines.entity_status.low_power] = "yellow",
    [defines.entity_status.no_fuel] = "red",
    [defines.entity_status.disabled_by_script] = "black",
    [defines.entity_status.marked_for_deconstruction] = "red",
    [defines.entity_status.no_recipe] = "red",
    [defines.entity_status.no_ingredients] = "red",
    [defines.entity_status.no_input_fluid] = "red",
    [defines.entity_status.fluid_ingredient_shortage] = "red",
    [defines.entity_status.full_output] = "blue",
    [defines.entity_status.item_ingredient_shortage] = "red"
}

local function sprite_button_for_status(status)
    if not status then return empty_widget end
    local color = entity_status[status] or nil
    if not color then return empty_widget end

    return {
        type = "flow",
        style = "flib_indicator_flow",
        children = {
            {
                type = "sprite",
                style = "flib_indicator",
                sprite = "flib_indicator_" .. color
            },
            {
                type = "label",
                caption = status_descriptions[status]
            }
        }
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