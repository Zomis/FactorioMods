return {
  ["bitwise-and"] = {
    description = "Bitwise AND",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return bit32.band(logic.resolve(param1, entity, current), logic.resolve(param2, entity, current))
      end
    end
  },
  ["bitwise-or"] = {
    description = "Bitwise OR",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return bit32.bor(logic.resolve(param1, entity, current), logic.resolve(param2, entity, current))
      end
    end
  },
  ["bitwise-xor"] = {
    description = "Bitwise XOR",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return bit32.bxor(logic.resolve(param1, entity, current), logic.resolve(param2, entity, current))
      end
    end
  },
  ["bitwise-not"] = {
    description = "Bitwise NOT",
    parameters = { "number" },
    result = "number",
    parse = function(params, logic)
      local param1 = params[1]
      return function(entity, current)
        return bit32.bnot(logic.resolve(param1, entity, current))
      end
    end
  }
}
