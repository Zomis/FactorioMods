local constants = require "prototypes/constants"
local common = require "common"

local function set_signal(logic, entity, current, index, signal_type, signal_value)
  if not signal_type then
    return
  end
  local max_range = constants[entity.name]
  if index <= 0 or index > max_range then
    entity.force.print("[Advanced Combinator] Warning: " .. common.worldAndPos(entity) .. " tried to set value at index outside range 1.." .. max_range .. ": " .. index)
    return
  end
  signal_value = logic.range_check(signal_value, entity)
  current[index] = { signal = signal_type, count = signal_value, index = index }
end

return {
  set = {
    description = "At the index specified by the first parameter, set the signal of second parameter to the value returned by the third parameter",
    parameters = { "number", "string-signal", "number" },
    result = "command",
    parse = function(params, logic)
      local param_index = params[1]
      local param_signal = params[2]
      local param_number = params[3]
      return function(entity, current)
        local signal_id = logic.resolve_signalID(param_signal)
        local index = logic.resolve(param_index, entity, current)
        local value = logic.resolve(param_number, entity, current)
        set_signal(logic, entity, current, index, signal_id, value)
      end
    end
  },
  set_simple = {
    description = "At the index specified by the first parameter, set the signal of second parameter to the value returned by the third parameter",
    parameters = { "string-number", "string-signal", "number" },
    result = "command",
    parse = function(params, logic)
      local param_index = tonumber(params[1])
      local param_signal = params[2]
      local param_number = params[3]
      return function(entity, current)
        local signal_id = logic.resolve_signalID(param_signal)
        local value = logic.resolve(param_number, entity, current)
        set_signal(logic, entity, current, param_index, signal_id, value)
      end
    end
  },
  set_signal = {
    description = "At the index specified by the first parameter, set the signal and value of the second parameter",
    parameters = { "number", "signal?" },
    result = "command",
    parse = function(params, logic)
      local param_index = params[1]
      local param_signal = params[2]
      return function(entity, current)
        local target_index = logic.resolve(param_index, entity, current)
        local signal = logic.resolve(param_signal, entity, current)
        if not signal then
          return
        end
        set_signal(logic, entity, current, target_index, signal.signal, signal.count)
      end
    end
  }
}
