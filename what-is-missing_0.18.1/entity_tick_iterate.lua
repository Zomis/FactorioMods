local Async = require "async"
local scan_delay = 3600

local function out(txt)
  local debug = true
  if debug then
    game.print(txt)
  end
end

-- local function checkMachine ?
-- local function onFinished ?
-- for proper loading/saving of tasks

function start_scanning(force, perform)
--  if true then return end
  if not force.valid then
    return
  end
  -- loop surfaces, entity_types, entities
  local surfaces = Async:loop_func("surface", function()
    local surface_list = {}
    for _, surface in pairs(game.surfaces) do table.insert(surface_list, surface) end
    return surface_list
  end)
  local entity_types = Async:loop_values("entity_type", { "assembling-machine", "furnace" })
  local entities = Async:loop_func("entity", function(loop_values)
    return loop_values.surface.find_entities_filtered({type = loop_values.entity_type, force = force})
  end)

  local i = 0
  local iterate_perform = function(values)
    perform(values.entity)
  end

  -- Start task and automatically renew it after it expires
  local on_finished = function(task)
    game.print("ON FINISHED " .. game.tick)
    game.print("Sleeping " .. force.name .. game.tick)
    global.force_tasks[task.force.name] = Async:delayed(scan_delay, function() start_scanning(task.force, perform) end)
  end
  game.print("Starting " .. force.name .. game.tick)
  local async_task = Async:perform_once({ surfaces, entity_types, entities }, iterate_perform, on_finished)
  async_task.force = force
  global.force_tasks[force.name] = async_task
end

function check_iterate_tasks(perform)
  if not global.force_tasks then
    global.force_tasks = {}
  end

  for _, force in pairs(game.forces) do
    if not global.force_tasks[force.name] then
      game.print("No task for force " .. force.name)
      start_scanning(force, perform)
    end
  end
end

--function on_force_created(event)
--  start_scanning()
--end
--script.on_event(defines.events.on_force_created, on_force_created)
