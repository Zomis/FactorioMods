local tables = require("__flib__.table")
local circuit_condition_types = require("circuit_condition_types")

local function expected_amount(product)
    local expected = product.amount
    if not expected then
      expected = (product.amount_min + product.amount_max) / 2.0
    end
    local probability = product.probability or 1

    return expected * probability
end

local function get_recipe_signals(source, player_info)
  local player_settings = player_info.settings
  local ingredients_multiplier = player_settings["copy-paste-recipe-signals-ingredient-multiplier"].value
  local products_multiplier = player_settings["copy-paste-recipe-signals-product-multiplier"].value
  local add_ticks = player_settings["copy-paste-recipe-signals-include-ticks"].value
  local add_seconds = player_settings["copy-paste-recipe-signals-include-seconds"].value
  local time_includes_modules = player_settings["copy-paste-recipe-time-includes-modules"].value
  local item_count_as_request_chest = player_settings["copy-paste-recipe-copy-item-count-as-request-chest"].value

  local recipe = source.get_recipe()
  if not recipe and source.prototype.type == "furnace" then
    recipe = source.previous_recipe
  end
  if not recipe then
      return {}
  end
  local speed_adjustment = time_includes_modules and source.crafting_speed or 1

  -- Calculation of the ingredients/products multiplier
  -- for the function of simulating copying to the request chest
  -- https://wiki.factorio.com/Copy_and_paste#Entity_settings
  local product_per30s_multiplier = 1
  if item_count_as_request_chest then
      product_per30s_multiplier = (30 * source.crafting_speed) / recipe.energy
  end

  local signals = {}
  if ingredients_multiplier ~= 0 then
    for _, ingredient in pairs(recipe.ingredients) do
      table.insert(signals, {
        signal = {
          type = ingredient.type,
          name = ingredient.name
        },
        -- in vanilla factorio, the copy-pasting feature cannot copy less than the amount of the ingredient
        -- (this also prevents items equal to 0)
        count = math.max(ingredient.amount * product_per30s_multiplier, ingredient.amount) * ingredients_multiplier
      })
    end
  end
  if products_multiplier ~= 0 then
    for _, product in pairs(recipe.products) do
      local expected = expected_amount(product)
      table.insert(signals, {
        signal = {
          type = product.type,
          name = product.name
        },
        --same as in the ingredient
        count = math.max(expected * product_per30s_multiplier, expected) * products_multiplier
      })
    end
  end
  if add_ticks then
    table.insert(signals, {
      signal = { type = "virtual", name = "signal-T" },
      count = recipe.energy * 60 / speed_adjustment
    })
  end
  if add_seconds then
    table.insert(signals, {
      signal = { type = "virtual", name = "signal-S" },
      count = recipe.energy / speed_adjustment
    })
  end
  return signals
end

local function merge_output(signals)
  local function signal_string_id(signal)
    return signal.signal.type .. "//" .. signal.signal.name .. "//" .. tostring(signal.signal.quality)
  end

  -- Returns: Array of "signals", each signal has: { signal = { type, name, quality }, count = 42 }
  local seen = {}
  local results = {}
  local result_index = 1
  for _, signal in pairs(signals) do
    local string_id = signal_string_id(signal)
    if seen[string_id] then
      -- Add to existing
      local index = seen[string_id]
      results[index].count = results[index].count + signal.count
    else
      results[result_index] = signal
      seen[string_id] = result_index
    end
    result_index = result_index + 1
  end
  return results
end

return function(source, player_info)
  -- Returns: Array of "signals", each signal has: { signal = { type, name, quality }, count = 42 }

  local source_type = source.prototype.type
  local results = {}
  if source_type == "assembling-machine" or source_type == "furnace" then
    results = get_recipe_signals(source, player_info)
  end

  local function add_signal_id(signal_id)
    table.insert(results, { signal = signal_id, count = 1 })
  end
  local function add_item(item_with_quality, value)
    local name = item_with_quality.name
    local quality = item_with_quality.quality
    if not prototypes.item[name] then
      error("Wrong item values: " .. tostring(name) .. "; " .. tostring(value))
    end
    table.insert(results, { signal = { type = "item", name = name, quality = quality }, count = value or 1 })
  end
  local function add_fluid(name, value)
    table.insert(results, { signal = { type = "fluid", name = name, quality = "normal" }, count = value or 1 })
  end
  local function add_logistic_filter(logistic_filter)
    table.insert(results, {
      signal = logistic_filter.value,
      count = logistic_filter.min
    })
  end
  local function add_logistic_section(logistic_section)
    for _, v in pairs(logistic_section.filters) do
      add_logistic_filter(v)
    end
  end


  if source_type == "constant-combinator" then
    for _, v in pairs(source.get_or_create_control_behavior().sections) do
      add_logistic_section(v)
    end
  end
  if source_type == "transport-belt" or source_type == "underground-belt" or source_type == "splitter" then
    -- items on belt
    local transport_lines = source.get_max_transport_line_index()
    for i = 1, transport_lines do
      local line = source.get_transport_line(i)
      for _, item_with_quality_counts in pairs(line.get_contents()) do
        add_item(item_with_quality_counts, item_with_quality_counts.count)
      end
    end
  end
  if source_type == "inserter" then
    -- items in inserter, items in filter
    if source.held_stack.count > 0 then
      add_item(source.held_stack.name, source.held_stack.count)
    end

    local filter_slot_count = source.filter_slot_count
    for i = 1, filter_slot_count do
      add_item(source.get_filter(i))
    end
  end

  -- circuit condition
  local source_behavior = source.get_control_behavior()
  if source_behavior then
    if circuit_condition_types[source.type] then
      add_signal_id(source_behavior.circuit_condition.condition.first_signal)
    end
  end

  if source_type == "storage-tank" or source_type == "pipe" or source_type == "pipe-to-ground" then
    local fluids = source.get_fluid_contents()
    for fluid, value in pairs(fluids) do
      add_fluid(fluid, value)
    end
  end
  if source_type == "container" then
    local items = source.get_inventory(defines.inventory.chest).get_contents()
    for _, value in pairs(items) do
      table.insert(results, {
        signal = {
          type = "item",
          name = value.name,
          quality = value.quality
        },
        count = value.count
      })
    end
  end
  results = tables.filter(results, function(v) return v.signal.name ~= nil end, true)
  results = merge_output(results)
  return results
end
