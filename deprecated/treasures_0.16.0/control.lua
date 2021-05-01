-- Load array of possible Treasures once
-- When exploring new chunk, generate number - compare with global config for treasure probability
-- Calculate distance from start
-- Pick treasure: Sum up the frequency of treasures, after checking for minimumDistance and distanceFrequencyBonus, generate random number based on frequency
-- For each item in treasure:
  -- Random number, check probability
  -- Random number between min and max
  -- Multiply by multiplier
  -- Add item to treasure

-- FUTURE: Add guarded treasures (enemy laser turrets or similar)
-- FUTURE: Add random buildings/factories placed in the world (both friendly and enemy)

local treasureConfig = require "treasure-config"

local PROBABILITY_OF_TREASURE = 0.1

local function out(txt)
  local debug = true
  if debug then
    game.print(txt)
  end
end

local function txtpos(pos)
  return "{" .. pos["x"] .. ", " .. pos["y"] .."}"
end

local function chooseTreasure(possible_treasures, distance, generator)
  local sum = 0
  for _, treasure in ipairs(possible_treasures) do
    if distance >= treasure.minimumDistance then
      local treasureScore = treasure.frequency
      if treasure.distanceFrequencyBonus then
        treasureScore = treasureScore + treasure.distanceFrequencyBonus * distance
      end
      if treasureScore > 0 then
        sum = sum + treasureScore
        out("Sum is now " .. sum .. " after adding " .. treasure.name)
      end
    end
  end

  local chosenValue = generator() * sum
  out("Chosen value is " .. chosenValue .. " where sum was " .. sum .. " and distance " .. distance)

  for _, treasure in ipairs(possible_treasures) do
    if distance >= treasure.minimumDistance then
      local treasureScore = treasure.frequency
      if treasure.distanceFrequencyBonus then
        treasureScore = treasureScore + treasure.distanceFrequencyBonus * distance
      end
      if treasureScore > 0 then
        out("Decreasing " .. chosenValue .. "with " .. treasureScore)
        chosenValue = chosenValue - treasureScore
      end
      if chosenValue < 0 then
        out("Chosen treasure is " .. treasure.name)
        return treasure
      end
    end
  end
  return nil
end

local function chooseItems(treasure, generator)
  local chosen = {}
  for _, itemConfig in ipairs(treasure.items) do
    local add = not itemConfig.probability or generator() < itemConfig.probability
    if add then
      local multiplier = itemConfig.multiplier or 1
      local count = generator(itemConfig.min, itemConfig.max) * multiplier
      table.insert(chosen, { name = itemConfig.name, count = count })
    end
  end
  return chosen
end

local function placeTreasure(values)
  local chest = values.surface.create_entity({ name = values.container, position = values.position, force = values.force })
  local inv = chest.get_inventory(defines.inventory.chest)

  for _, item in ipairs(values.items) do
    out("placed " .. item.count .. " " .. item.name .. " at " .. txtpos(values.position))
    inv.insert(item)
  end
  return chest
end

local function treasure(surface, force, position)
  local placeable = surface.can_place_entity({ name = "iron-chest", position = position, force = force })
  if not placeable then
    -- out("Not placeable at " .. txtpos(position))
    return false
  end

  local allTreasures = treasureConfig.possible_treasures()
  local distanceFromStart = math.sqrt(position.x * position.x + position.y * position.y)
  game.print("Distance from start is " .. distanceFromStart)

  local chosenTreasure = chooseTreasure(allTreasures, distanceFromStart, global.generator)
  if not chosenTreasure then
    game.print("[Treasures] No treasure chosen at " .. txtpos(position) .. ", is the config working properly?")
    return
  end
  local chosenItems = chooseItems(chosenTreasure, global.generator)
  placeTreasure({ container = "iron-chest", treasure = chosenTreasure, surface = surface, items = chosenItems,
    position = position, force = force })
end

local function onChunkGenerated(event)
  if event.surface.name ~= "nauvis" then
    return
  end

  -- Forces existing by default are "player", "enemy", "neutral"
  local force_name = "player"
  local chosen_force = game.forces[force_name]
  if not chosen_force then
    game.print("[Treasures] Unable to place treasure: There is no force named '" .. force_name .. "'")
    return
  end

  if global.generator() >= PROBABILITY_OF_TREASURE then
    -- out("Bad luck, no treasure at " .. txtpos(event.area.left_top) .. "/" .. txtpos(event.area.right_bottom))
    return
  end

  for i = 1, 5 do
    local x = global.generator(event.area.left_top.x, event.area.right_bottom.x) + 0.5
    local y = global.generator(event.area.left_top.y, event.area.right_bottom.y) + 0.5
    x = (event.area.right_bottom.x - event.area.left_top.x) / 2 + event.area.left_top.x
    y = (event.area.right_bottom.y - event.area.left_top.y) / 2 + event.area.left_top.y
    local placed = treasure(event.surface, chosen_force, { x=x, y=y })
    if placed then
      return
    end
  end
  out("No treasure in chunk " .. txtpos(event.area.left_top) .. " to " .. txtpos(event.area.right_bottom))
end

script.on_init(function(event)
  global.generator = game.create_random_generator()
end)
script.on_event(defines.events.on_chunk_generated, onChunkGenerated)
-- on_sector_scanned
