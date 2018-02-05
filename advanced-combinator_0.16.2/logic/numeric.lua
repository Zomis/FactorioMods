return {
  add = {
    description = "Add two values together",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return logic.resolve(param1, entity, current) + logic.resolve(param2, entity, current)
      end
    end
  },
  sub = {
    description = "Subtract second value from first value",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return logic.resolve(param1, entity, current) - logic.resolve(param2, entity, current)
      end
    end
  },
  mult = {
    description = "Multiply two numbers",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return logic.resolve(param1, entity, current) * logic.resolve(param2, entity, current)
      end
    end
  },
  div = {
    description = "Divide first number by second number",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        local divby = logic.resolve(param2, entity, current)
        if divby == 0 then
          return 0
        end
        return logic.resolve(param1, entity, current) / divby
      end
    end
  },
  mod = {
    description = "Return the remainder of a division between two numbers",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        local divby = logic.resolve(param2, entity, current)
        if divby == 0 then
          return 0
        end
        return logic.resolve(param1, entity, current) % divby
      end
    end
  },
  abs = {
    description = "Absolute value of a number (change negative values to positive)",
    parameters = { "number" },
    result = "number",
    parse = function(params, logic)
      local param = params[1]
      return function(entity, current)
        return math.abs(logic.resolve(param, entity, current))
      end
    end
  },
  random = {
    description = "Get a random value from 1 to the upper value specified by the parameter (inclusive)",
    parameters = { "number" },
    result = "number",
    parse = function(params, logic)
      local param_upper = params[1]
      return function(entity, current)
        return math.random(logic.resolve(param_upper, entity, current))
      end
    end
  },
  const = {
    description = "A constant number",
    parameters = { "string-number" },
    result = "number",
    parse = function(params)
      local value = tonumber(params[1])
      return function() return value end
    end
  }
}
