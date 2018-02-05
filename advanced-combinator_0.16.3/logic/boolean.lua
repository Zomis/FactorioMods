local function compare(first_value, compare_method, second_value)
  if compare_method == "=" then
    return first_value == second_value
  elseif compare_method == "<=" then
    return first_value <= second_value
  elseif compare_method == "<" then
    return first_value < second_value
  elseif compare_method == ">=" then
    return first_value >= second_value
  elseif compare_method == ">" then
    return first_value > second_value
  elseif compare_method == "≠" then
    return first_value ~= second_value
  end
  error("Not a valid compare method: " .. compare_method)
end

return {
  compare = {
    description = "Compare two numbers",
    parameters = { "number", "compare-method", "number" },
    result = "boolean",
    parse = function(params, logic)
      local first = params[1]
      local compare_method = params[2]
      local second = params[3]
      return function(entity, current)
        local first_value = logic.resolve(first, entity, current)
        local second_value = logic.resolve(second, entity, current)
        return compare(first_value, compare_method, second_value)
      end
    end
  },
  boolean_to_number = {
    description = "Convert a boolean to a number. 1 == true and 0 == false",
    parameters = { "boolean" },
    result = "number",
    parse = function(params, logic)
      local value = params[1]
      return function(entity, current)
        local bool = logic.resolve(value, entity, current)
        return bool and 1 or 0
      end
    end
  },
  ["if"] = {
    description = "Perform a command if condition is true",
    parameters = { "boolean", "command" },
    result = "command",
    parse = function(params, logic)
      local param_condition = params[1]
      local param_command = params[2]
      return function(entity, current)
        local condition = logic.resolve(param_condition, entity, current)
        if condition then
          return logic.resolve(param_command, entity, current)
        end
      end
    end
  }
}
