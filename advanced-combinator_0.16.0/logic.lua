local common = require "common"

local function resolve_signalID(type_and_name)
  local split = string.find(type_and_name, "/")
  if not split then
    return nil
  end
  local signal_type = string.sub(type_and_name, 1, split - 1)
  local signal_name = string.sub(type_and_name, split + 1)
  return { type = signal_type, name = signal_name }
end

local function resolve_entity(entity, target)
  if target == "this" then
    return entity
  end
  error("Unable to resolve entity: " .. target)
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

local enum_types = {
  ["game-data"] = {
    "tick", "speed"
    --, "players"--, active_mods?, connected_players, #item_prototypes?
  },
  ["surface-data"] = {
    "daytime", "darkness", "wind_speed", "wind_orientation", "wind_orientation_change", "ticks_per_day", "dusk", "dawn", "evening", "morning"
    -- "peaceful_mode", "freeze_daytime",
  },
  ["entity"] = { "this", "top", "left", "right", "bottom" },
  ["wire-color"] = { "green", "red" }
}

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
  signal_type = {
    description = "A constant signal type",
    parameters = { "string-signal" },
    result = "signal-type",
    parse = function(params)
      local value = resolve_signalID(params[1])
      return function() return value end
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
  },
  current = {
    description = "A previously calculated value in the current iteration",
    parameters = { "string-number" },
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
    parameters = { "string-number" },
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

local function parse(data, params, entity)
  -- type check parameters
  for i, param_type in ipairs(data.parameters) do
    local param_value = params[i]
    if enum_types[param_type] then
      local index_of = common.table_indexof(enum_types[param_type], param_value)
      if not index_of then
        error("No such enum value '" .. param_value .. "' in type " .. param_type)
      end
    elseif param_type == "string-number" then
      if not tonumber(param_value) then
        error("'" .. param_value .. "' is not a number")
      end
    elseif param_type == "string-signal" then
      if game then
        local signal = resolve_signalID(param_value)
        if not signal then
          error("No such signal: " .. param_value)
        end
        if signal.type == "fluid" then
          if not game.fluid_prototypes[signal.name] then
            error("No such signal: " .. param_value)
          end
        elseif signal.type == "item" then
          if not game.item_prototypes[signal.name] then
            error("No such signal: " .. param_value)
          end
        elseif signal.type == "virtual" then
          if not game.virtual_signal_prototypes[signal.name] then
            error("No such signal: " .. param_value)
          end
        else
          error("No such signal type: " .. param_value)
        end
      end
    else
      if type(param_value) ~= "table" then
        error("Unable to validate parameter " .. tostring(param_value) .. " of expected type " .. param_type)
      end
      if game then
        common.out("No validation for type " .. param_type)
      end
    end
  end
  return data.parse(params, entity)
end

return {
  logic = logic,
  resolve_signalID = resolve_signalID,
  enum_types = enum_types,
  parse = parse
}
