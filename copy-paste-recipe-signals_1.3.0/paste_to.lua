local tables = require("__flib__.table")

local function paste_to_pump(destination, signals, player_settings)
    
end

local function paste_to_inserter(destination, signals, player_settings)
    local options = tables.filter(signals, function(v) return v.signal.type == "item" and v.signal.name ~= nil end, true) -- array[Signal]
    local options_count = table_size(options)
    if options_count == 0 then
        return
    end

    if destination.name == "stack-filter-inserter" then
        local current = destination.get_filter(1) -- type: string?
        local current_index = tables.find(tables.map(options, function(v) return v.signal.name end), current)
        if current_index == nil then
            current_index = 1
--   Include empty after iterating through all once or not?
--      elseif current_index == options_count then
--        destination.set_filter(1, nil)
--        return
        else
            current_index = (current_index % options_count) + 1
        end
        if current_index <= options_count then
            local option = options[current_index]
            if option then
                destination.set_filter(1, option.signal.name)
            else
                destination.set_filter(1, nil)
            end
        end
    end
end

local function paste_to_computing_combinator(destination, signals, player_settings)
    local allow_arithmetic = player_settings["copy-paste-recipe-time-paste-product-arithmetic"].value
    local allow_decider = player_settings["copy-paste-recipe-time-paste-product-decider"].value

    if destination.name == "arithmetic-combinator" and allow_arithmetic then
        local behavior = destination.get_or_create_control_behavior()
        local previous_parameters = behavior.parameters
  
        behavior.parameters = {
          first_signal = {
            type = recipe.products[1].type,
            name = recipe.products[1].name
          },
          second_signal = previous_parameters.second_signal,
          operation = previous_parameters.operation,
          second_constant = previous_parameters.second_constant,
          output_signal = previous_parameters.output_signal
        }
    elseif destination.name == "decider-combinator" and allow_decider then
        local behavior = destination.get_or_create_control_behavior()
        local previous_parameters = behavior.parameters
  
        behavior.parameters = {
          first_signal = {
            type = recipe.products[1].type,
            name = recipe.products[1].name
          },
          second_signal = previous_parameters.second_signal,
          constant = previous_parameters.constant,
          comparator = previous_parameters.comparator,
          output_signal = previous_parameters.output_signal,
          copy_count_from_input = previous_parameters.copy_count_from_input
        }
    end
end

local function paste_to_constant_combinator(destination, signals, player_settings, event)
    local behavior = destination.get_or_create_control_behavior()

    if destination.name == "constant-combinator" or destination.name == "ltn-combinator" then
      -- The ltn-combinator has 28 signals, however the 14 first signals should
      -- be used for LTN specific signals, we try to preserve these so LTN configurations is not lost
      local signalsStartIndex = destination.name == "ltn-combinator" and (14) or 0

      for index, signal in pairs(signals) do
        local setIndex = (index + signalsStartIndex)
        if behavior.signals_count >= setIndex then
          behavior.set_signal(setIndex, signal)
        end
      end

      local clearSignalsStartIndex = table_size(signals) + signalsStartIndex

      for index = clearSignalsStartIndex + 1, behavior.signals_count do
        behavior.set_signal(index, nil)
      end
    end
end

return function(destination, signals, player_settings, event)
    if destination.name == "constant-combinator" or destination.name == "ltn-combinator" then
        paste_to_constant_combinator(destination, signals, player_settings, event)
    end
    if destination.name == "pump" then
        paste_to_pump(destination, signals, player_settings)
    end
    if (destination.name == "arithmetic-combinator") or (destination.name == "decider-combinator") then
        paste_to_computing_combinator(destination, signals, player_settings)
    end
    if destination.name == "stack-filter-inserter" then
        paste_to_inserter(destination, signals, player_settings)
    end
end