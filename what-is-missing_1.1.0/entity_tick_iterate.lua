local Async = require "async"

local function out(txt)
  local debug = true
  if debug then
    game.print(txt)
  end
end

-- local function checkMachine ?
-- local function onFinished ?
-- for proper loading/saving of tasks

local function start_scanning(force, perform)
  if not force.valid then
    return
  end
  -- loop surfaces, entity_types, entities
  local surfaces = Async:loop_func("surface", function()
    local surface_list = {}
    for _, surface in pairs(game.surfaces) do table.insert(surface_list, surface) end
    return surface_list
  end)
  local single_force = Async:loop_values("force", { force })
  local entity_types = Async:loop_values("entity_type", { "assembling-machine", "furnace" })
  local entities = Async:loop_func("entity", function(loop_values)
    local entity_list = loop_values.surface.find_entities_filtered({type = loop_values.entity_type, force = loop_values.force})
    --game.print(" size " .. table_size(entit) .. serpent.line(loop_values))
    return entity_list
  end)

  -- game.print("Starting " .. force.name .. game.tick)
  local async_task = Async:perform_once({ force = force }, { single_force, surfaces, entity_types, entities })
  global.force_tasks[force.name] = async_task
end

local function scan_once(force, perform)
  if not force.valid then
    return
  end
  -- loop surfaces, entity_types, entities
  local surfaces = Async:loop_func("surface")
  local single_force = Async:loop_values("force", { force })
  local entity_types = Async:loop_values("entity_type", { "assembling-machine", "furnace" })
  local entities = Async:loop_func("entity")

--  game.print("Scan once " .. force.name .. game.tick)
  Async:perform_once({ force = force, once = true }, { single_force, surfaces, entity_types, entities })
end

local function check_iterate_tasks(perform)
  if true then return end -- TODO: The below should no longer be needed, clean it up.
  if not global.force_tasks then
    global.force_tasks = {}
  end

  for _, force in pairs(game.forces) do
    if not global.force_tasks[force.name] then
      -- game.print("No task for force " .. force.name)
      start_scanning(force, perform)
    end
  end
end

--function on_force_created(event)
--  start_scanning()
--end
--script.on_event(defines.events.on_force_created, on_force_created)

return {
  start_scanning = start_scanning,
  scan_once = scan_once,
  check_iterate_tasks = check_iterate_tasks
}
