local common = require "common"
local logic = require "logic"

local function perform(advanced_combinator, runtime_combinator)
  runtime_combinator.func(advanced_combinator.entity)
end

local function parseCalculation(text, advanced_combinator, entity)
  local find = string.find(text, "%(")
  if find then
    local function_name = string.sub(text, 1, find - 1)
    local parameters = string.sub(text, find + 1, string.len(text) - 1)

    local logic_data = logic.logic[function_name]
    if not logic_data then
      error("No such function name: " .. function_name)
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
    local func = logic.parse(logic_data, params, entity)
    return { name = function_name, params = params, func = func }
  end
  return error("No parenthesis found in " .. text)
end

local function parse(advanced_combinator, entity)
  local commands = {}
  for command in string.gmatch(advanced_combinator.config, "[^\n;]+") do
    local trimmed = common.trim(command)
    local parsed_command = parseCalculation(trimmed, advanced_combinator, entity)
    table.insert(commands, parsed_command)
  end

  local perform_function = function(ent)
    local control = entity.get_control_behavior()
    local result = {}
--    table.insert(result, {signal = { type = "virtual", name = "signal-A" }, count = 42, index = 1 })
--    table.insert(result, {signal = { type = "virtual", name = "signal-B" }, count = 21, index = 1 })
--    result[4] = {signal = { type = "virtual", name = "signal-B" }, count = 21, index = 4 }
    for _, command in ipairs(commands) do
      command.func(ent, result)
    end
    control.parameters = { parameters = result }
  end
  return { commands = commands, func = perform_function }
end

return { perform = perform, parse = parse }
