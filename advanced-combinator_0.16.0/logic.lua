local constants = require "constants"
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

local function range_check(value, entity)
  if value < -2147483648 or value > 2147483647 then
    entity.force.print("[Advanced Combinator] " .. common.worldAndPos(entity) ..
      " Warning: Tried to set value outside valid range (-2147483648..2147483647). Using fallback of -1")
    return -1
  end
  return value
end

local function find_entity(source, offset_x, offset_y)
  local position = source.position
  local surface = source.surface
  local found = surface.find_entities_filtered({position = {
    position.x + offset_x, position.y + offset_y
  }})
  return found and found[1] or nil
end

local function resolve_entity(entity, target)
  if target == "this" then
    return entity
  end
  if target == "top" then
    return find_entity(entity, 0, -1)
  end
  if target == "left" then
    return find_entity(entity, -1, 0)
  end
  if target == "right" then
    return find_entity(entity, 1, 0)
  end
  if target == "bottom" then
    return find_entity(entity, 0, 1)
  end
  error("Unable to resolve entity: " .. target)
end

local function item_from_network(wire_type)
  return function(params)
   local target = params[1]
   local signal_id = resolve_signalID(params[2])

   return function(ent)
     local resolved = resolve_entity(ent, target)
     if not resolved or not resolved.valid then
       return 0
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
  if not value then
    return 0
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
  ["entity-data"] = {
    "active",
    "destructible",
    "minable",
    "rotatable",
    "operable",
    "health",
    "supports_direction",
    "orientation",
    "amount",
    "initial_amount",
    "effectivity_modifier",
    "consumption_modifier",
    "friction_modifier",
    "speed",
    "selected_gun_index",
    "energy",
    "temperature",
    "time_to_live",
    "chain_signal_state",
    "crafting_progress",
    "bonus_progress",
    "rocket_parts",
    "damage_dealt",
    "kills",
    "electric_buffer_size",
    "electric_input_flow_limit",
    "electric_output_flow_limit",
    "electric_drain",
    "electric_emissions",
    "unit_number",
    "mining_progress",
    "bonus_mining_progress",
    "power_production",
    "power_usage",
    "request_slot_count",
    "filter_slot_count",
    "graphics_variation",
    "tree_color_index",
    "inserter_stack_size_override",
    "products_finished",
    "power_switch_state",
    "relative_turret_orientation",
    "remove_unfiltered_items",
    "character_corpse_player_index",
    "character_corpse_tick_of_death",
    "tick_of_last_attack",
    "tick_of_last_damage",
    "crafting_queue_size",
    "walking_state",
    "mining_state",
    "shooting_state",
    "picking_state",
    "repair_state",
    "driving",
    "cheat_mode",
    "character_crafting_speed_modifier",
    "character_mining_speed_modifier",
    "character_running_speed_modifier",
    "character_build_distance_bonus",
    "character_item_drop_distance_bonus",
    "character_reach_distance_bonus",
    "character_resource_reach_distance_bonus",
    "character_item_pickup_distance_bonus",
    "character_loot_pickup_distance_bonus",
    "quickbar_count_bonus",
    "character_inventory_slots_bonus",
    "character_logistic_slot_count_bonus",
    "character_trash_slot_count_bonus",
    "character_maximum_following_robot_count_bonus",
    "character_health_bonus",
    "build_distance",
    "drop_item_distance",
    "reach_distance",
    "item_pickup_distance",
    "loot_pickup_distance",
    "resource_reach_distance",
    "in_combat"
  },
  ["wire-color"] = { "green", "red" }
}

local function set_signal(entity, current, index, signal_type, signal_value)
  if not signal_type then
    return
  end
  local max_range = constants[entity.name]
  if index < 0 or index > max_range then
    entity.force.print("[Advanced Combinator] Warning: " .. common.worldAndPos(entity) .. " tried to set value at index outside range 1.." .. max_range .. ": " .. index)
    return
  end
  signal_value = range_check(signal_value, entity)
  current[index] = { signal = signal_type, count = signal_value, index = index }
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
        local signal_id = resolve_signalID(param_signal)
        local index = param_index.func(entity, current)
        local value = param_number.func(entity, current)
        set_signal(entity, current, index, signal_id, value)
      end
    end
  },
  set_simple = {
    description = "At the index specified by the first parameter, set the signal of second parameter to the value returned by the third parameter",
    parameters = { "string-number", "string-signal", "number" },
    result = "command",
    parse = function(params)
      local param_index = tonumber(params[1])
      local param_signal = params[2]
      local param_number = params[3]
      return function(entity, current)
        local signal_id = resolve_signalID(param_signal)
        local value = param_number.func(entity, current)
        set_signal(entity, current, param_index, signal_id, value)
      end
    end
  },
  set_signal = {
    description = "At the index specified by the first parameter, set the signal and value of the second parameter",
    parameters = { "number", "signal?" },
    result = "command",
    parse = function(params)
      local param_index = params[1]
      local param_signal = params[2]
      return function(entity, current)
        local target_index = param_index.func(entity, current)
        local signal = param_signal.func(entity, current)
        if not signal then
          return
        end
        set_signal(entity, current, target_index, signal.signal, signal.count)
      end
    end
  },
  sum = {
    description = "Return the sum of an array of numbers",
    parameters = { "number-array" },
    result = "number",
    parse = function(params)
      local param_array = params[1]
      return function(entity, current)
        local sum = 0
        local array = param_array.func(entity, current)
        for _, v in ipairs(array) do
          sum = sum + v
        end
        return sum
      end
    end
  },
  max_signal = {
    description = "Return the maximum signal of an array of signals",
    parameters = { "signal-array" },
    result = "signal?",
    parse = function(params)
      local param_array = params[1]
      return function(entity, current)
        local max = nil
        local array = param_array.func(entity, current)
        for _, v in ipairs(array) do
          if not max or v.count > max.count then
            max = v
          end
        end
        return max
      end
    end
  },
  network = {
    description = "",
    parameters = { "entity", "wire-color" },
    result = "signal-array",
    parse = function(params, entity)
      local entity_target = params[1]
      local wire_color = params[2]
      local wire_type
      if wire_color == "red" then
        wire_type = defines.wire_type.red
      elseif wire_color == "green" then
        wire_type = defines.wire_type.green
      else
        error("Unknown wire type: " .. wire_color)
      end
      return function(ent)
        local resolved = resolve_entity(ent, entity_target)
        if not resolved or not resolved.valid then
          return 0
        end
        local network = resolved.get_circuit_network(wire_type)
        if not network then
          return 0
        end
        return network.signals
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
  signal = {
    description = "Create a signal from a type and a value",
    parameters = { "signal-type", "number" },
    result = "signal?",
    parse = function(params)
      local signal_type = params[1]
      local signal_value = params[2]
      return function(entity, current)
        return {
          signal = signal_type.func(entity, current),
          count = signal_value.func(entity, current)
        }
      end
    end
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
  value_of_signal = {
    description = "Get the value of a signal",
    parameters = { "signal?" },
    result = "number",
    parse = function(params)
      local param_signal = params[1]
      return function(entity, current)
        local signal = param_signal.func(entity, current)
        if not signal then
          return 0
        end
        return signal.count
      end
    end
  },
  type_of_signal = {
    description = "Get the type of a signal",
    parameters = { "signal?" },
    result = "signal-type",
    parse = function(params)
      local param_signal = params[1]
      return function(entity, current)
        local signal = param_signal.func(entity, current)
        if not signal then
          return nil
        end
        return signal.signal
      end
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
  entityData = {
    description = "Get data from an entity",
    parameters = { "entity", "entity-data" },
    result = "number",
    parse = function(params)
      local target = params[1]
      local param = params[2]
      return function(entity)
        local resolved = resolve_entity(entity, target)
        if not resolved or not resolved.valid then
          return 0
        end
        local status, result = pcall(function()
          return numeric(resolved[param])
        end)
        if not status then
          entity.force.print("[Advanced Combinator] " .. common.worldAndPos(entity) .. ": " .. result)
          return 0
        end
        return result
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
    elseif param_type == "signal?" and param_value == nil then
      -- nil is an acceptable value for "signal?" (but should it be allowed when parsing??)
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
