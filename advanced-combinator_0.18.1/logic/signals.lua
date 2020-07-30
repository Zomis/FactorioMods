local function sum(array_of_signals)
  local result = 0
  for _, v in ipairs(array_of_signals) do
    result = result + v.count
  end
  return result
end

local function item_from_network(wire_type)
  return function(params, logic)
   local target = params[1]
   local signal_id = logic.resolve_signalID(params[2])

   return function(ent)
     local resolved = logic.resolve_entity(ent, target)
     if not resolved or not resolved.valid then
       return 0
     end
     local network = resolved.get_circuit_network(wire_type)
     if not network then
       return 0
     end
     return network.get_signal(signal_id)
   end
 end
end

return {
  count = {
    description = "Return the number of values in an array of signals",
    parameters = { "signal-array" },
    result = "number",
    parse = function(params, logic)
      local param_array = params[1]
      return function(entity, current)
        local array = logic.resolve(param_array, entity, current)
        local count = #array
        return count
      end
    end
  },
  sum = {
    description = "Return the sum of the signal values in an array of signals",
    parameters = { "signal-array" },
    result = "number",
    parse = function(params, logic)
      local param_array = params[1]
      return function(entity, current)
        local array = logic.resolve(param_array, entity, current)
        return sum(array)
      end
    end
  },
  avg = {
    description = "Return the average value of an array of signals",
    parameters = { "signal-array" },
    result = "number",
    parse = function(params, logic)
      local param_array = params[1]
      return function(entity, current)
        local array = logic.resolve(param_array, entity, current)
        local count = #array
        local array_sum = sum(array)
        return array_sum / count
      end
    end
  },
  min_signal = {
    description = "Return the maximum signal of an array of signals",
    parameters = { "signal-array" },
    result = "signal?",
    parse = function(params, logic)
      local param_array = params[1]
      return function(entity, current)
        local min = nil
        local array = logic.resolve(param_array, entity, current)
        for _, v in ipairs(array) do
          if not min or v.count < min.count then
            min = v
          end
        end
        return min
      end
    end
  },
  max_signal = {
    description = "Return the maximum signal of an array of signals",
    parameters = { "signal-array" },
    result = "signal?",
    parse = function(params, logic)
      local param_array = params[1]
      return function(entity, current)
        local max = nil
        local array = logic.resolve(param_array, entity, current)
        for _, v in ipairs(array) do
          if not max or v.count > max.count then
            max = v
          end
        end
        return max
      end
    end
  },
  network = {
    description = "",
    parameters = { "entity", "wire-color" },
    result = "signal-array",
    parse = function(params, logic)
      local entity_target = params[1]
      local wire_color = params[2]
      local wire_type
      if wire_color == "red" then
        wire_type = defines.wire_type.red
      elseif wire_color == "green" then
        wire_type = defines.wire_type.green
      else
        error("Unknown wire type: " .. wire_color)
      end
      return function(ent)
        local resolved = logic.resolve_entity(ent, entity_target)
        if not resolved or not resolved.valid then
          return {}
        end
        local network = resolved.get_circuit_network(wire_type)
        if not network then
          return {}
        end
        return network.signals or {}
      end
    end
  },
  green = {
    description = "Return the value of a signal in the green circuit network of an entity",
    parameters = { "entity", "string-signal" },
    result = "number",
    parse = item_from_network(defines.wire_type.green)
  },
  red = {
    description = "Return the value of a signal in the red circuit network of an entity",
    parameters = { "entity", "string-signal" },
    result = "number",
    parse = item_from_network(defines.wire_type.red)
  },
  signal = {
    description = "Create a signal from a type and a value",
    parameters = { "signal-type", "number" },
    result = "signal?",
    parse = function(params, logic)
      local signal_type = params[1]
      local signal_value = params[2]
      return function(entity, current)
        return {
          signal = logic.resolve(signal_type, entity, current),
          count = logic.resolve(signal_value, entity, current)
        }
      end
    end
  },
  signal_type = {
    description = "A constant signal type",
    parameters = { "string-signal" },
    result = "signal-type",
    parse = function(params, logic)
      local value = logic.resolve_signalID(params[1])
      return function() return value end
    end
  },
  value_of_signal = {
    description = "Get the value of a signal",
    parameters = { "signal?" },
    result = "number",
    parse = function(params, logic)
      local param_signal = params[1]
      return function(entity, current)
        local signal = logic.resolve(param_signal, entity, current)
        if not signal then
          return 0
        end
        return signal.count
      end
    end
  },
  type_of_signal = {
    description = "Get the type of a signal",
    parameters = { "signal?" },
    result = "signal-type",
    parse = function(params, logic)
      local param_signal = params[1]
      return function(entity, current)
        local signal = logic.resolve(param_signal, entity, current)
        if not signal then
          return nil
        end
        return signal.signal
      end
    end
  }
}
