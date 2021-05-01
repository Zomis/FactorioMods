function create_sprite_icon(name, size)
  return {
    type = "sprite",
    name = "train_log_" .. name,
    filename = "__train-log__/graphics/icons/material-design/" .. name .. ".png",
    priority = "medium",
    width = size or 24,
    height = size or 24
  }
end

data:extend {
  create_sprite_icon("crosshairs-gps"),
  create_sprite_icon("train"),
  create_sprite_icon("timer-outline"),
  create_sprite_icon("train-36-white", 36)
}

data:extend {
  {
      type = 'custom-input',
      name = 'train-log-open',
      key_sequence = 'CONTROL + H',
      enabled_while_spectating = true,
  },
}
