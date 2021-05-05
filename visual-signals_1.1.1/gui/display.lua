local gui = require("__flib__.gui-beta")

local function find_prototype(type, name)
    if type == "item" then
        prototype = game.item_prototypes[name]
    elseif type == "fluid" then
        prototype = game.fluid_prototypes[name]
    elseif type == "virtual-signal" then
        prototype = game.virtual_signal_prototypes[name]
    end
    return prototype
end

local function update_slot_table(slot_table, circuit_network, i, delete)
    local children = slot_table.children
    if not circuit_network then
        if delete then
            local size = table_size(children)
            for j = i + 1, size do
                children[j].destroy()
            end
        end
        return i
    end
    if circuit_network and circuit_network.valid then
        for _, v in pairs(circuit_network.signals) do
            i = i + 1
            local type = v.signal.type
            local name = v.signal.name
            local prototype = find_prototype(type, name)
            local child = children[i]
            if child then
                child.sprite = type .. "/" .. name
                child.number = v.count
                child.tooltip = prototype.localised_name
            else
                slot_table.add {
                    type = "sprite-button",
                    style = "slot_button",
                    sprite = type .. "/" .. name,
                    number = v.count,
                    tooltip = prototype.localised_name
                }
            end
        end
    end
    return i
end

local function update(visual_signal_key, visual_signal_gui)
    local label = visual_signal_gui.label
    local slot_table = visual_signal_gui.slot_table
    local visual_signal_entry = global.visual_signals[visual_signal_key]
    local entity = visual_signal_entry.entity
    local circuit_red = entity.get_circuit_network(defines.wire_type.red)
    local circuit_green = entity.get_circuit_network(defines.wire_type.green)
    local i = update_slot_table(slot_table, circuit_red, 0)
    i = update_slot_table(slot_table, circuit_green, i)
    update_slot_table(slot_table, nil, i, true)
end

local function for_display(visual_signal_key)
    -- create GUI for an existing visual signal entity
    local visual_signal_entry = global.visual_signals[visual_signal_key]
    return {
        type = "flow",
        direction = "vertical",
        children = {
            {
                type = "label",
                ref = { "displays", visual_signal_key, "label" },
                caption = visual_signal_entry.title
            },
            {
                type = "frame",
                style = "slot_button_deep_frame",
                children = {
                    {
                        type = "scroll-pane",
                        style = "flib_naked_scroll_pane_no_padding",
                        --style_mods = {height = 200},
                        children = {
                            {
                                type = "table",
                                style = "slot_table",
                                -- style_mods = { width = 400 },
                                column_count = 10,
                                ref = { "displays", visual_signal_key, "slot_table" }
                            }
                        }
                    }
                }
            }
        }
    }
end

return {
    for_display = for_display,
    update = update
}
