data:extend{
  {
      type = 'custom-input',
      name = 'factorio-search-engine-open-search',
      key_sequence = 'CONTROL + F',
      enabled_while_spectating = true,
  },
}

data:extend({
  {
    type = "shortcut",
    name = "factorio-search-engine",
    localised_name = { "shortcut.factorio-search-engine" },
    order = "a",
    action = "lua",
    style = "blue",
    icon = {
      filename = "__factorio-search-engine__/graphics/icons/material-design/magnify.png",
      flags = {
        "icon"
      },
      priority = "extra-high-no-scale",
      scale = 1,
      size = 48
    },
  },
})
