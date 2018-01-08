local logic = require "logic"

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function worldAndPos(entity, key)
  return entity.surface.name .. txtpos(entity.position)
end



local function perform(advanced_combinator, runtime_combinator)
  runtime_combinator(advanced_combinator.entity)
end

local function parseCalculation(text, advanced_combinator, entity)
  local find = string.find(text, "%(")
  if find then
    local function_name = string.sub(text, 1, find - 1)
    local parameters = string.sub(text, find + 1, string.len(text) - 1)

    local fnc = logic.logic[function_name]
    if not fnc then
      return { error = "No such function name: " .. function_name }
    end

    local params = {}
    local unfinished_params = ""
    for param in string.gmatch(parameters, "[^,]+") do
      -- Count number of parenthesis to make nested functions work. A workaround because I am lazy and don't implement a real parser
      -- A trick to count number of occourences, see https://stackoverflow.com/a/11158158/1310566
      local actual_param = unfinished_params .. param
      local _, start_params = string.gsub(actual_param, "%(", "")
      local _, end_params = string.gsub(actual_param, "%)", "")

      if start_params == end_params then
        if start_params > 0 then
          -- We need to parse next level as well
          local param_function = parseCalculation(actual_param, advanced_combinator, entity)
          table.insert(params, param_function)
        else
          table.insert(params, actual_param)
        end
        unfinished_params = ""
      else
        unfinished_params = unfinished_params .. param .. ","
      end
    end
    return fnc.parse(params, entity)
  end
end

local function parse(advanced_combinator, entity)
  local commands = {}
  for command in string.gmatch(advanced_combinator.config, "[^\n]+") do
    -- table.insert(commands, command)
    -- a = const(20)

    local equalsIndex = string.find(command, " = ")
    if not equalsIndex then
      return { error = "Missing ' = ' in " .. command }
    end
    local colon = string.find(command, ":")
    if not colon then
      return { error = "Missing ':' in " .. command }
    end

    local target_index = tonumber(string.sub(command, 1, colon - 1))
    command = string.sub(command, colon + 1)
    equalsIndex = string.find(command, " = ")

    local result_signal = string.sub(command, 1, equalsIndex - 1)
    local signal = logic.resolve_signalID(result_signal)

    local result_value = string.sub(command, equalsIndex + 3)
    local result_function = parseCalculation(result_value, advanced_combinator, entity)
    if type(result_function) == "function" then
      local result_index = command_index
      local command_function = function(ent, result)
        local count = result_function(ent, result)
        result[target_index] = { signal = signal, count = count, index = target_index }
      end
      table.insert(commands, command_function)
    else -- type should be table
      return { error = result_function.error .. " when parsing command " .. command }
    end
  end

  return function(entity)
    local control = entity.get_control_behavior()
    local result = {}
    for _, command in ipairs(commands) do
      command(entity, result)
    end
    control.parameters = { parameters = result }
  end
end

return { perform = perform, parse = parse }
