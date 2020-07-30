local function expected_amount(product)
  local expected_amount = product.amount
  if not expected_amount then
      expected_amount = (product.amount_min + product.amount_max) / 2.0
  end
  local probability = product.probability or 1

  return expected_amount * probability
end

script.on_event(defines.events.on_entity_settings_pasted, function(event)
  if event.destination.valid and event.destination.name ~= "constant-combinator" then
    return
  end
  if event.source.valid and event.source.prototype.type == "assembling-machine" then
    local recipe = event.source.get_recipe()
    if not recipe then return end

    local behavior = event.destination.get_or_create_control_behavior()

    local signals = {}
    for _, ingredient in pairs(recipe.ingredients) do
      table.insert(signals, { signal = { type = ingredient.type, name = ingredient.name }, count = -ingredient.amount })
    end
    for _, product in pairs(recipe.products) do
      local expected = expected_amount(product)
      table.insert(signals, { signal = { type = product.type, name = product.name }, count = expected })
    end
    table.insert(signals, { signal = { type = "virtual", name = "signal-T" }, count = recipe.energy * 60 })
    table.insert(signals, { signal = { type = "virtual", name = "signal-S" }, count = recipe.energy })

    for index, signal in pairs(signals) do
      if behavior.signals_count >= index then
        behavior.set_signal(index, signal)
      end
    end
  end
end)
