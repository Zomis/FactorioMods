local function create_sprite_icon(name)
  return {
    type = "sprite",
    name = "search_engine_" .. name,
    filename = "__search-engine__/graphics/sprites/" .. name .. ".png",
    priority = "medium",
    width = 32,
    height = 32
  }
end

data:extend {
  create_sprite_icon("magnify")
}

data:extend {
  {
      type = 'custom-input',
      name = 'search-engine-open-search',
      key_sequence = 'CONTROL + F',
      enabled_while_spectating = true,
  },
}

data:extend {
  {
    type = "shortcut",
    name = "search-engine",
    localised_name = { "shortcut.search-engine" },
    order = "a",
    action = "lua",
    style = "blue",
    icon = {
      filename = "__search-engine__/graphics/icons/material-design/magnify.png",
      flags = {
        "icon"
      },
      priority = "extra-high-no-scale",
      scale = 1,
      size = 48
    },
  },
}
