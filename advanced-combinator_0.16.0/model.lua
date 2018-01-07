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
    game.print("parsing " .. function_name .. " with parameters " .. parameters)

    local fnc = logic.logic[function_name]
    if not fnc then
      return { error = "No such function name: " .. function_name }
    end

    local params = {}
    for param in string.gmatch(parameters, "[^,]+") do
      game.print("Found param: " .. param)
      table.insert(params, param)
    end
    return fnc.parse(params, entity)
  end
end

local function parse(advanced_combinator, entity)
  local commands = {}
  local command_index = 1
  for command in string.gmatch(advanced_combinator.config, "[^\n]+") do
    -- table.insert(commands, command)
    -- a = const(20)

    local equalsIndex = string.find(command, " = ")
    if not equalsIndex then
      game.print("Parse error in " .. command)
      return
    end
    local result_signal = string.sub(command, 1, equalsIndex - 1)
    local signal = logic.resolve_signalID(result_signal)

    local result_value = string.sub(command, equalsIndex + 3)
    local result_function = parseCalculation(result_value, advanced_combinator, entity)
    local result_index = command_index
    local command_function = function(ent, result)
      local count = result_function(ent)
      table.insert(result, {signal = signal, count = count, index = result_index })
    end
    table.insert(commands, command_function)
    command_index = command_index + 1
    game.print("Parsed: " .. result_signal .. " = " .. result_value)
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
