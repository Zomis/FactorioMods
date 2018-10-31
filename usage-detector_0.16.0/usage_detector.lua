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

local function add_to_if_using(job, entities, target_list, ingredient_product)
  for _, entity in ipairs(entities) do
    local ingredient = is_using_product(entity, ingredient_product)
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

local function create_empty_job(player, job_name)
  local player_data = global.player_data[player.index] or { jobs = {} }
  global.player_data[player.index] = player_data
  player_data.jobs[job_name] = {
    current_thing = nil,
    current_furnaces = {},
    current_machines = {},
    results = {},
    running = false,
    started_at = 0,
    stopped_at = 0
  }
end

local function start(player, item_or_fluid, section_name)
  local player_data = global.player_data[player.index]
  create_empty_job(player, section_name)
  local job = player_data.jobs[section_name]
  job.current_thing = item_or_fluid
  job.running = true
  job.started_at = game.tick

  for _, surface in pairs(game.surfaces) do
    local furnaces = surface.find_entities_filtered({type = "furnace"})
    add_to_if_using(job, furnaces, job.current_furnaces, item_or_fluid)

    local assembling_machines = surface.find_entities_filtered({type = "assembling-machine"})
    add_to_if_using(job, assembling_machines, job.current_machines, item_or_fluid)
  end
end

local function check_progress(job, entity_data)
  if not entity_data.entity.valid then
    return
  end
  if not entity_data.recipe.valid then
    return
  end
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

local function stop(player, section_name)
  local job = global.player_data[player.index].jobs[section_name]
  job.running = false
  job.stopped_at = game.tick
end

return {
  start = start,
  create_empty_job = create_empty_job,
  onTick = tick,
  stop = stop
}
