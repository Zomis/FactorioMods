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

local function numeric(value)
  if type(value) == "boolean" then
    if value then return 1 else return 0 end
  end
  return value
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
  ["force-data"] = {
    "manual_mining_speed_modifier", "manual_crafting_speed_modifier",
    "laboratory_speed_modifier", "laboratory_productivity_bonus",
    "worker_robots_speed_modifier", "worker_robots_battery_modifier",
    "worker_robots_storage_bonus", "research_progress",
    "inserter_stack_size_bonus", "stack_inserter_capacity_bonus",
    "character_logistic_slot_count", "character_trash_slot_count",
    "quickbar_count", "maximum_following_robot_count", "following_robots_lifetime_modifier",
    "ghost_time_to_live",
    -- players
    "ai_controllable",
    "item_production_statistics", "fluid_production_statistics",
    "kill_count_statistics", "entity_build_count_statistics",
    "character_running_speed_modifier", "artillery_range_modifier",
    "character_build_distance_bonus", "character_item_drop_distance_bonus",
    "character_reach_distance_bonus", "character_resource_reach_distance_bonus",
    "character_item_pickup_distance_bonus", "character_loot_pickup_distance_bonus",
    "character_inventory_slots_bonus", "deconstruction_time_to_live",
    "character_health_bonus", "max_successful_attemps_per_tick_per_construction_queue",
    "max_failed_attempts_per_tick_per_construction_queue", "auto_character_trash_slots",
    "zoom_to_world_enabled", "zoom_to_world_ghost_building_enabled",
    "zoom_to_world_blueprint_enabled", "zoom_to_world_deconstruction_planner_enabled",
    "zoom_to_world_selection_tool_enabled", "rockets_launched",
    -- items_launched
    -- connected_players
    "mining_drill_productivity_bonus", "train_braking_force_bonus",
    "evolution_factor", "friendly_fire", "share_chart"
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
        local divby = param2.func(entity, current)
        if divby == 0 then
          return 0
        end
        return param1.func(entity, current) / divby
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
        local divby = param2.func(entity, current)
        if divby == 0 then
          return 0
        end
        return param1.func(entity, current) % divby
      end
    end
  },
  set = {
    description = "At the index specified by the first parameter, set the signal of second parameter to the value returned by the third parameter",
    parameters = { "number", "string-signal", "number" },
    result = "command",
    parse = function(params)
      local param_index = params[1]
      local param_signal = params[2]
      local param_number = params[3]
      return function(entity, current)
        local target_index = param_index.func(entity, current)
        local signal_id = resolve_signalID(param_signal)
        -- local signal = param_signal.func(entity, current)
        local count = param_number.func(entity, current)
        current[target_index] = { signal = signal_id, count = count, index = target_index }
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
      local resolved = resolve_entity(entity, params[1])

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
  },
  gameData = {
    description = "Get data from current game",
    parameters = { "game-data" },
    result = "number",
    parse = function(params)
      local param = params[1]
      return function()
        return numeric(game[param])
      end
    end
  },
  surfaceData = {
    description = "Get data from current surface",
    parameters = { "surface-data" },
    result = "number",
    parse = function(params)
      local param = params[1]
      return function(entity)
        return numeric(entity.surface[param])
      end
    end
  },
  forceData = {
    description = "Get data from the force owning this Advanced Combinator",
    parameters = { "force-data" },
    result = "number",
    parse = function(params)
      local param = params[1]
      return function(entity)
        return numeric(entity.force[param])
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
