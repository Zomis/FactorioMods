local copy_from = require "copy_from"
local paste_to = require "paste_to"

local function get_player_info(event)
  local player_index = event.player_index

  storage.player_info = storage.player_info or {}
  if not storage.player_info[player_index] then
    storage.player_info[player_index] = {
      last_copy = {
        from = nil,
        to = nil,
        index = nil
      }
    }
  end
  local player_info = storage.player_info[player_index]
  if event.source ~= player_info.last_copy.from or event.destination ~= player_info.last_copy.to then
    storage.player_info[player_index] = {
      last_copy = {
        from = nil,
        to = nil,
        index = nil
      }
    }
  end

  return {
    player = game.players[player_index],
    last_copy = storage.player_info[player_index].last_copy or {},
    settings = settings.get_player_settings(player_index)
  }
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
--  game.print("DO MAGIC!")
  if not event.destination.valid then
    return
  end
  if not event.source.valid then
    return
  end
--  game.print(event.source.name .. "/" .. event.source.type .. " --> " .. event.destination.name .. "/" .. event.destination.type)
  if event.destination.type == event.source.type then
    return
  end
  local player_info = get_player_info(event)
  local source_values = copy_from(event.source, player_info)
  -- source_values should be array[Signal]
  -- game.print(serpent.line(source_values))
  if not source_values or table_size(source_values) == 0 then
    -- Nothing to copy
    local source = event.source
    local entity = "[entity=" .. source.name .. "]"
    local gps = "[gps=" .. source.position.x .. "," .. source.position.y .. "," .. source.surface.name .. "]"
    player_info.player.print({ "copy-paste-action.copy-paste-nothing", entity, gps })
    return
  end
  local update_result = paste_to(event.destination, source_values, player_info)
  storage.player_info[event.player_index] = {
    last_copy = {
      from = event.source,
      to = event.destination,
      index = update_result
    }
  }
end)
