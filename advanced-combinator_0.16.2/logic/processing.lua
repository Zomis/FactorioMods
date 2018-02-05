return {
  current = {
    description = "A previously calculated value in the current iteration",
    parameters = { "string-number" },
    result = "number",
    parse = function(params)
      local index = tonumber(params[1])
      return function(_, current)
        if not current[index] then
          return 0
        end
        return current[index].count
      end
    end
  },
  previous = {
    description = "The calculated value of the last iteration",
    parameters = { "string-number" },
    result = "number",
    parse = function(params)
      local index = tonumber(params[1])
      return function(entity)
        return entity.get_control_behavior().get_signal(index).count
      end
    end
  }
}
