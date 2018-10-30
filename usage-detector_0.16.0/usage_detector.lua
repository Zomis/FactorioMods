--current_machines = {} -- table of: entity + recipe + count

-- TODO: Player-specific. Multiplayer support.

-- Potential improvement: "How is Iron used?"
-- a lot probably goes to iron gear wheel, but how is those gears then used?
-- production for transport belts for example uses a lot of gears.
-- likewise for production for military science packs.
-- Saying "I want to know about Iron, and gears" would be nice
-- and then "I want to summarize the results for all transport belts"

local function is_using_product(entity, product)
  local recipe = entity.get_recipe()
  if entity.type == "furnace" and recipe == nil then
      recipe = entity.previous_recipe
  end
  if not recipe then
    return nil
  end

  for _, ingredient in ipairs(recipe.ingredients) do
    if ingredient.type == product.type and ingredient.name == product.name then
      return { recipe = recipe, amount = ingredient.amount }
    end
  end
  return nil
end

local function add_to_if_using(job, entities, target_list, ingredient)
  for _, entity in ipairs(entities) do
    local ingredient = is_using_product(entity, ingredient)
    if ingredient then
      table.insert(target_list, { entity = entity, recipe = ingredient.recipe,
          amount = ingredient.amount,
          count = 0, last_progress = entity.crafting_progress })
      if not job.results[ingredient.recipe.name] then
        job.results[ingredient.recipe.name] = {
          recipe = ingredient.recipe,
          amount = ingredient.amount,
          count = 0,
          machine_count = 0
        }
      end
      job.results[ingredient.recipe.name].machine_count = job.results[ingredient.recipe.name].machine_count + 1
    end
  end
end

local function start(player, item_or_fluid, section_name)
  local player_data = global.player_data[player.index] or { jobs = {} }
  global.player_data[player.index] = player_data
  player_data.jobs[section_name] = player_data.jobs[section_name] or {
    current_thing = item_or_fluid,
    current_furnaces = {},
    current_machines = {},
    results = {},
    running = true,
    started_at = game.tick,
    stopped_at = game.tick
  }
  local job = player_data.jobs[section_name]

  for _, surface in pairs(game.surfaces) do
    local furnaces = surface.find_entities_filtered({type = "furnace"})
    add_to_if_using(job, furnaces, job.current_furnaces, item_or_fluid)

    local assembling_machines = surface.find_entities_filtered({type = "assembling-machine"})
    add_to_if_using(job, assembling_machines, job.current_machines, item_or_fluid)
  end
  player.print("Started checking usage for " .. item_or_fluid.type .. " " .. item_or_fluid.name)
end

local function check_progress(job, entity_data)
  local progress = entity_data.entity.crafting_progress
  local last_progress = entity_data.last_progress
  if progress < last_progress and progress > 0 then
    entity_data.count = entity_data.count + 1
    job.results[entity_data.recipe.name].count = job.results[entity_data.recipe.name].count + 1
  end
  entity_data.last_progress = progress
end

local function tick(job)
  if not job.running then
    return
  end
  for _, furnace in ipairs(job.current_furnaces) do
    check_progress(job, furnace)
  end
  for _, machine in ipairs(job.current_machines) do
    check_progress(job, machine)
  end
end

local function summarize_results(target_list, entity_data)
  local key = entity_data.recipe.name
  local used = entity_data.amount * entity_data.count
  if not target_list[key] then
    target_list[key] = { recipe = entity_data.recipe, amount = entity_data.amount, count = 0, machine_count = 0 }
  end
  target_list[key].count = target_list[key].count + entity_data.count
  target_list[key].machine_count = target_list[key].machine_count + 1
end

local function print_result(result)
  local name = result.recipe.name
  local amount = result.amount
  local count = result.count
  local sum = amount * count
  local machine_count = result.machine_count
  game.print("Recipe " .. name .. " used " .. amount .. " * " .. count .. " times using a total of " .. sum .. " in " .. machine_count .. " machines.")
end

local function stop(player, section_name)
  local results = {}
  local job = global.player_data[player.index].jobs[section_name]
  job.running = false
  job.stopped_at = game.tick
  for _, furnace in ipairs(job.current_furnaces) do
    summarize_results(results, furnace)
  end
  for _, machine in ipairs(job.current_machines) do
    summarize_results(results, machine)
  end

  for recipe_name, result in pairs(results) do
    print_result(result)
  end
  current_thing = nil
end

return {
  start = start,
  onTick = tick,
  stop = stop
}
