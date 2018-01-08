local function resolve_signalID(type_and_name)
  local split = string.find(type_and_name, "/")
  local signal_type = string.sub(type_and_name, 1, split - 1)
  local signal_name = string.sub(type_and_name, split + 1)
  return { type = signal_type, name = signal_name }
end

local function resolve_entity(entity, target)
  if target == "this" then
    return entity
  end
  return { error = "Unable to resolve: " .. target }
end

local function item_from_network(wire_type)
  return function(params, entity)
   local target = params[1]
   local signal_id = resolve_signalID(params[2])
   local resolved = resolve_entity(entity, target)

   return function()
     if not resolved.valid then
       -- invalidate this, it needs to be reparsed, or removed if there is no such entity at all
       return { error = "Invalid target entity" }
     end
     local network = resolved.get_circuit_network(wire_type)
     if not network then
       return 0
     end
     return network.get_signal(signal_id)
   end
 end
end

local logic = {
  add = {
    description = "Add two values together",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return param1.func(entity, current) + param2.func(entity, current)
      end
    end
  },
  sub = {
    description = "Subtract second value from first value",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return param1.func(entity, current) - param2.func(entity, current)
      end
    end
  },
  mult = {
    description = "Multiply two numbers",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return param1.func(entity, current) * param2.func(entity, current)
      end
    end
  },
  div = {
    description = "Divide first number by second number",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return param1.func(entity, current) / param2.func(entity, current)
      end
    end
  },
  mod = {
    description = "Return the remainder of a division between two numbers",
    parameters = { "number", "number" },
    result = "number",
    parse = function(params)
      local param1 = params[1]
      local param2 = params[2]
      return function(entity, current)
        return param1.func(entity, current) % param2.func(entity, current)
      end
    end
  },
  sum = {
    description = "",
    parameters = { "array" },
    result = "number",
    parse = function()
    end
  },
  network = {
    description = "",
    parameters = { "entity", "wire-color" },
    result = "array",
    parse = function(params, entity)
      local resolved = resolve_entity(entity, target)

      local wire_color = params[2]
      local wire_type
      if wire_color == "red" then
        wire_type = defines.wire_type.red
      elseif wire_color == "green" then
        wire_type = defines.wire_type.green
      else
        return { error = "Unknown wire color: " .. wire_color }
      end
      return function()
        -- to be implemented
      end
    end
  },
  green = {
    description = "Return the value of a signal in the green circuit network of an entity",
    parameters = { "entity", "signal-id" },
    result = "number",
    parse = item_from_network(defines.wire_type.green)
  },
  red = {
    description = "Return the value of a signal in the red circuit network of an entity",
    parameters = { "entity", "signal-id" },
    result = "number",
    parse = item_from_network(defines.wire_type.red)
  },
  const = {
    description = "A constant value",
    parameters = { "string" },
    result = "number",
    parse = function(params)
      local value = tonumber(params[1])
      return function() return value end
    end
  },
  current = {
    description = "A previously calculated value in the current iteration",
    parameters = { "string" },
    result = "number",
    parse = function(params)
      local index = tonumber(params[1])
      return function(entity, current)
        if not current[index] then
          return 0
        end
        return current[index].count
      end
    end
  },
  previous = {
    description = "The calculated value of the last iteration",
    parameters = { "string" },
    result = "number",
    parse = function(params)
      local index = tonumber(params[1])
      return function(entity, current)
        return entity.get_control_behavior().get_signal(index).count
      end
    end
  },
  gameData = {
    description = "Get data from current game",
    parameters = { "game-data" },
    result = "number",
    parse = function(params)
      local param = params[1]
      return function(entity, current)
        return game[param]
      end
    end
  },
  surfaceData = {
    description = "Get data from current surface",
    parameters = { "surface-data" },
    result = "number",
    parse = function(params)
      local param = params[1]
      return function(entity, current)
        return entity.surface[param]
      end
    end
  },
  array = {
    description = "",
    parameters = { "number" },
    varargs = true,
    result = "array",
    parse = function()
    end
  }



}


return { logic = logic, resolve_signalID = resolve_signalID }
