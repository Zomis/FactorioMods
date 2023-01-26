local function expected_amount(product)
  local expected = product.amount
  if not expected then
    expected = (product.amount_min + product.amount_max) / 2.0
  end
  local probability = product.probability or 1

  return expected * probability
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if event.destination.valid and event.destination.name ~= "constant-combinator" and
      event.destination.name ~= "ltn-combinator" and event.destination.name ~= "arithmetic-combinator" and event.destination.name ~= "decider-combinator" then
    return
  end
  if not event.source.valid then
    return
  end
  if event.source.prototype.type == "assembling-machine" or event.source.prototype.type == "furnace" then
    local player_settings = settings.get_player_settings(event.player_index)
    local ingredients_multiplier = player_settings["copy-paste-recipe-signals-ingredient-multiplier"].value
    local products_multiplier = player_settings["copy-paste-recipe-signals-product-multiplier"].value
    local add_ticks = player_settings["copy-paste-recipe-signals-include-ticks"].value
    local add_seconds = player_settings["copy-paste-recipe-signals-include-seconds"].value
    local time_includes_modules = player_settings["copy-paste-recipe-time-includes-modules"].value
    local allow_arithmetic = player_settings["copy-paste-recipe-time-paste-product-arithmetic"].value
    local allow_decider = player_settings["copy-paste-recipe-time-paste-product-decider"].value

    local recipe = event.source.get_recipe()
    if not recipe and event.source.prototype.type == "furnace" then
      recipe = event.source.previous_recipe
    end
    if not recipe then return end
    local behavior = event.destination.get_or_create_control_behavior()

    if event.destination.name == "arithmetic-combinator" and allow_arithmetic then
      local previous_parameters = behavior.parameters

      behavior.parameters = {
        first_signal = {
          type = recipe.products[1].type,
          name = recipe.products[1].name
        },
        second_signal = previous_parameters.second_signal,
        operation = previous_parameters.operation,
        second_constant = previous_parameters.second_constant,
        output_signal = previous_parameters.output_signal
      }
    elseif event.destination.name == "decider-combinator" and allow_decider then
      local previous_parameters = behavior.parameters

      behavior.parameters = {
        first_signal = {
          type = recipe.products[1].type,
          name = recipe.products[1].name
        },
        second_signal = previous_parameters.second_signal,
        constant = previous_parameters.constant,
        comparator = previous_parameters.comparator,
        output_signal = previous_parameters.output_signal,
        copy_count_from_input = previous_parameters.copy_count_from_input
      }
    elseif event.destination.name == "constant-combinator" or event.destination.name == "ltn-combinator" then
      local signals = {}
      if ingredients_multiplier ~= 0 then
        for _, ingredient in pairs(recipe.ingredients) do
          table.insert(signals, {
            signal = {
              type = ingredient.type,
              name = ingredient.name
            },
            count = ingredient.amount * ingredients_multiplier
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
            count = expected * products_multiplier
          })
        end
      end
      local speed_adjustment = time_includes_modules and event.source.crafting_speed or 1
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

      -- The ltn-combinator has 28 signals, however the 14 first signals should
      -- be used for LTN specific signals, we try to preserve these so LTN configurations is not lost
      local signalsStartIndex = event.destination.name == "ltn-combinator" and (14) or 0

      for index, signal in pairs(signals) do
        local setIndex = (index + signalsStartIndex)
        if behavior.signals_count >= setIndex then
          behavior.set_signal(setIndex, signal)

        end
      end

      local clearSignalsStartIndex = table_size(signals) + signalsStartIndex

      for index = clearSignalsStartIndex + 1, behavior.signals_count do
        behavior.set_signal(index, nil)
      end
    end
  end
end)
