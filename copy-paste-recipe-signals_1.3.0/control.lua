local tables = require("__flib__.table")
local pastable_types = require "pastable_types"
local copy_from = require "copy_from"
local paste_to = require "paste_to"

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if not event.destination.valid then
    return
  end
  if not event.source.valid then
    return
  end
  local target_name = event.destination.name
  if not tables.find(pastable_types(), target_name) then
    return
  end
  if event.destination.type == event.source.type then
    return
  end

  local player_settings = settings.get_player_settings(event.player_index)
  local source_values = copy_from(event.source, player_settings)
  -- source_values should be array[Signal]
  -- game.print(serpent.line(source_values))
  local destination = paste_to(event.destination, source_values, player_settings, event)
end)
