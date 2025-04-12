local tables = require("__flib__.table")
local popup = require("popup")
local circuit_condition_types = require("circuit_condition_types")

local function iterate(options, player_info)
    local options_count = table_size(options)
    local current_index = player_info.last_copy.index

    if current_index == nil then
        current_index = 1
--   Include empty after iterating through all once or not?
--      elseif current_index == options_count then
--        destination.set_filter(1, nil)
--        return
    else
        current_index = (current_index % options_count) + 1
    end
    return current_index, options[current_index]
end

local function paste_to_circuit_condition(destination, signals, player_info)
    local player_settings = player_info.settings
    if not player_settings["copy-paste-circuit-condition"].value then
        return nil
    end
    local behavior = destination.get_or_create_control_behavior()
    local previous_condition = behavior.circuit_condition.condition
    local index, next_value = iterate(signals, player_info)

    behavior.circuit_condition = {
        condition = {
            first_signal = next_value.signal, -- SignalID
            second_signal = previous_condition.second_signal,
            constant = previous_condition.constant,
            comparator = previous_condition.comparator
        }
    }
    popup.popup_circuit_condition(player_info, behavior.circuit_condition)
    return index
end

local function paste_to_inserter(destination, signals, player_info)
    local options = tables.filter(signals, function(v) return v.signal.type == "item" end, true) -- array[Signal]
    local options_count = table_size(options)
    if options_count == 0 then
        return
    end

    -- Not sure what feature is desired for regular filter inserters?
    if destination.name == "stack-filter-inserter" then
        local index, next_value = iterate(options, player_info)
        destination.set_filter(1, next_value and next_value.signal.name)
        return index
    end
end

local function paste_to_splitter(destination, signals, player_info)
    local options = tables.filter(signals, function(v) return v.signal.type == "item" end, true) -- array[Signal]
    local options_count = table_size(options)
    if options_count == 0 then
        return
    end
    player_info.player.print("Not supported yet - awaiting Factorio bugfix. Please yell at mod author if this message ever appears!")
end

local function paste_to_computing_combinator(destination, signals, player_info)
    local player_settings = player_info.settings
    local allow_arithmetic = player_settings["copy-paste-recipe-time-paste-product-arithmetic"].value
    local allow_decider = player_settings["copy-paste-recipe-time-paste-product-decider"].value

    if destination.name == "arithmetic-combinator" and allow_arithmetic then
        local behavior = destination.get_or_create_control_behavior()
        local previous = behavior.parameters
        local previous_out = previous.output_signal
        local previous_in = previous.first_signal

        local index, next_value = iterate(signals, player_info)
        local output_was_each = previous_out and previous_out.type == "virtual" and previous_out.name == "signal-each"
        if output_was_each or tables.deep_compare(previous_in, previous_out) then
            previous.output_signal = next_value.signal
        end
        if previous.second_signal and tables.deep_compare(previous_in, previous.second_signal) then
            previous.second_signal = next_value.signal
        end
        behavior.parameters = {
          first_signal = next_value.signal,
          second_signal = previous.second_signal,
          operation = previous.operation,
          second_constant = previous.second_constant,
          output_signal = previous.output_signal
        }
        return index
    elseif destination.name == "decider-combinator" and allow_decider then
        local behavior = destination.get_or_create_control_behavior()
        local previous = behavior.parameters
        local previous_out = previous.output_signal

        local index, next_value = iterate(signals, player_info)
        -- MORE COMBINATIONS MISSING
        local output_was_each = previous_out and previous_out.type == "virtual" and previous_out.name == "signal-each"
        if output_was_each or tables.deep_compare(previous.first_signal, previous_out) then
            previous.output_signal = next_value.signal
        end
        if output_was_each then
            previous_out.name = "signal-everything"
        end
        behavior.parameters = {
          first_signal = next_value.signal,
          second_signal = previous.second_signal,
          constant = previous.constant,
          comparator = previous.comparator,
          output_signal = previous.output_signal,
          copy_count_from_input = previous.copy_count_from_input
        }
        return index
    end
end

local function signal_to_filter(signal)
    return {
        value = {
            type = signal.signal.type,
            name = signal.signal.name,
            quality = signal.signal.quality,
        },
        min = signal.count,
    }
end

local function paste_to_logisitic_section(section, signals)
    -- change filters of section
    -- type, name, quality, comparator

    -- Need to clear everything first to avoid any potential conflicts
    local count = section.filters_count
    for index = 1, count do
        section.clear_slot(index)
    end

    local signalsStartIndex = 0
    for index, signal in pairs(signals) do
        section.set_slot(index + signalsStartIndex, signal_to_filter(signal))
    end

    return nil
end

local function paste_to_constant_combinator(destination, signals, player_info)
    local behavior = destination.get_or_create_control_behavior()

    if destination.name == "constant-combinator" or destination.name == "ltn-combinator" then
      -- The ltn-combinator has 28 signals, however the 14 first signals should
      -- be used for LTN specific signals, we try to preserve these so LTN configurations is not lost
      local signalsStartIndex = destination.name == "ltn-combinator" and (14) or 0

      -- loop through sections, check for section.is_manual and active
      for i, section in pairs(behavior.sections) do
        if section.is_manual and section.active then
          paste_to_logisitic_section(section, signals)
        end
      end
    end
end

return function(destination, signals, player_info)
    if destination.name == "constant-combinator" or destination.name == "ltn-combinator" then
        return paste_to_constant_combinator(destination, signals, player_info)
    end
    if (destination.name == "arithmetic-combinator") or (destination.name == "decider-combinator") then
        return paste_to_computing_combinator(destination, signals, player_info)
    end
    if destination.name == "stack-filter-inserter" then
        return paste_to_inserter(destination, signals, player_info)
    end
    if destination.type == "splitter" then
        return paste_to_splitter(destination, signals, player_info)
    end
    if circuit_condition_types[destination.type] then
        return paste_to_circuit_condition(destination, signals, player_info)
    end
end
