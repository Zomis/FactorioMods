local function signal_text(signal_id)
    local signal_type = signal_id.type
    if signal_type == "virtual" then signal_type = "virtual-signal" end
    return "[" .. signal_type .. "=" .. signal_id.name .. "]"
end

local function popup_circuit_condition(player_info, circuit_condition)
    local cond = circuit_condition.condition
    local second_signal = cond.second_signal and signal_text(cond.second_signal) or cond.constant

    player_info.player.create_local_flying_text {
        text = {
            "copy-paste-action.copy-paste-recipe-signals-popup",
            signal_text(cond.first_signal),
            cond.comparator,
            second_signal
        },
        create_at_cursor = true
    }
end

return {
    popup_circuit_condition = popup_circuit_condition,
}