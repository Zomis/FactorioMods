local tables = require("__flib__.table")
local copy_from = require "copy_from"
local paste_to = require "paste_to"

local function get_player_info(event)
  local player_index = event.player_index

  global.player_info = global.player_info or {}
  if not global.player_info[player_index] then
    global.player_info[player_index] = {
      last_copy = {
        from = nil,
        to = nil,
        index = nil
      }
    }
  end
  local player_info = global.player_info[player_index]
  if event.source ~= player_info.last_copy.from or event.destination ~= player_info.last_copy.to then
    global.player_info[player_index] = {
      last_copy = {
        from = nil,
        to = nil,
        index = nil
      }
    }
  end

  return {
    player = game.players[player_index],
    last_copy = global.player_info[player_index].last_copy or {},
    settings = settings.get_player_settings(player_index)
  }
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if not event.destination.valid then
    return
  end
  if not event.source.valid then
    return
  end
  local target_name = event.destination.name
  if event.destination.type == event.source.type then
    return
  end
  local player_info = get_player_info(event)
  local source_values = copy_from(event.source, player_info)
  -- source_values should be array[Signal]
  -- game.print(serpent.line(source_values))
  local update_result = paste_to(event.destination, source_values, player_info, event)
  global.player_info[event.player_index] = {
    last_copy = {
      from = event.source,
      to = event.destination,
      index = update_result
    }
  }
end)
