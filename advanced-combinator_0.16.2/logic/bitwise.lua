return {
  ["bitwise-and"] = {
    description = "Bitwise AND",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return bit32.band(param1.func(entity, current), param2.func(entity, current))
      end
    end
  },
  ["bitwise-or"] = {
    description = "Bitwise OR",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return bit32.bor(param1.func(entity, current), param2.func(entity, current))
      end
    end
  },
  ["bitwise-xor"] = {
    description = "Bitwise XOR",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return bit32.bxor(param1.func(entity, current), param2.func(entity, current))
      end
    end
  },
  ["bitwise-not"] = {
    description = "Bitwise NOT",
    parameters = { "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      return function(entity, current)
        return bit32.bnot(param1.func(entity, current))
      end
    end
  }
}
