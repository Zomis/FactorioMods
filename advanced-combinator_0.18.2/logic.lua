local constants = require "prototypes/constants"
local common = require "common"
local logic = {}
logic.logic = {}

function logic.resolve_signalID(type_and_name)
  local split = string.find(type_and_name, "/")
  if not split then
    return nil
  end
  local signal_type = string.sub(type_and_name, 1, split - 1)
  local signal_name = string.sub(type_and_name, split + 1)
  return { type = signal_type, name = signal_name }
end

function logic.range_check(value, entity)
  if value < -2147483648 or value > 2147483647 then
    entity.force.print("[Advanced Combinator] " .. common.worldAndPos(entity) ..
      " Warning: Tried to set value outside valid range (-2147483648..2147483647). Using fallback of -1")
    return -1
  end
  return value
end

function logic.find_entity(source, offset_x, offset_y)
  local position = source.position
  local surface = source.surface
  local found = surface.find_entities_filtered({position = {
    position.x + offset_x, position.y + offset_y
  }})
  return found and found[1] or nil
end

function logic.resolve_entity(entity, target)
  if target == "this" then
    return entity
  end
  if target == "top" then
    return logic.find_entity(entity, 0, -1)
  end
  if target == "left" then
    return logic.find_entity(entity, -1, 0)
  end
  if target == "right" then
    return logic.find_entity(entity, 1, 0)
  end
  if target == "bottom" then
    return logic.find_entity(entity, 0, 1)
  end
  error("Unable to resolve entity: " .. target)
end

function logic.numeric(value)
  if type(value) == "boolean" then
    if value then return 1 else return 0 end
  end
  if not value then
    return 0
  end
  return value
end

logic.enum_types = {
  ["compare-method"] = { "<", "<=", "=", ">=", ">", "≠" },
  ["game-data"] = {
    "tick", "speed"
    --, "players"--, active_mods?, connected_players, #item_prototypes?
  },
  ["surface-data"] = {
    "daytime", "darkness", "wind_speed", "wind_orientation", "wind_orientation_change",
    "ticks_per_day", "dusk", "dawn", "evening", "morning"
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

function logic.parse(data, params, entity)
  -- type check parameters
  for i, param_type in ipairs(data.parameters) do
    local param_value = params[i]
    if logic.enum_types[param_type] then
      local index_of = common.table_indexof(logic.enum_types[param_type], param_value)
      if not index_of then
        error("No such enum value '" .. param_value .. "' in type " .. param_type)
      end
    elseif param_type == "string-number" then
      if not tonumber(param_value) then
        error("'" .. param_value .. "' is not a number")
      end
    elseif param_type == "string-signal" then
      if game then
        local signal = logic.resolve_signalID(param_value)
        if not signal then
          error("No such signal: " .. tostring(param_value))
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
    elseif param_type ~= "string" and (param_type ~= "signal?" or param_value ~= nil) then
      -- nil is an acceptable value for "signal?" (but should it be allowed when parsing??)
      if type(param_value) ~= "table" then
        error("Unable to validate parameter value " .. tostring(param_value) .. " of expected type " .. param_type)
      end
      if game then
        common.out("No validation for type " .. param_type)
      end
    end
  end
  return data.parse(params, logic)
end

function logic.extend(logic_data)
  for name, data in pairs(logic_data) do
    if logic.logic[name] then
      error("Logic already contains function " .. name)
    end
    logic.logic[name] = data
  end
end

function logic.resolve(param, entity, current)
  local function_name = param.name
  local params = param.params
  local data = logic.logic[function_name]
  local func = data.parse(params, logic)
  return func(entity, current)
end

return logic
