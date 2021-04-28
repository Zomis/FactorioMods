function create_sprite_icon(name)
  return {
    type = "sprite",
    name = "train_log_" .. name,
    filename = "__train-log__/graphics/icons/material-design/" .. name .. ".png",
    priority = "medium",
    width = 24,
    height = 24
  }
end

data:extend {
  create_sprite_icon("crosshairs-gps"),
  create_sprite_icon("train"),
  create_sprite_icon("timer-outline")
}

data:extend {
  {
      type = 'custom-input',
      name = 'train-log-open',
      key_sequence = 'CONTROL + H',
      enabled_while_spectating = true,
  },
}
