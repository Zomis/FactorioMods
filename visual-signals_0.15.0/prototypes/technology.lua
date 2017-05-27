data:extend({
  {
    type = "technology",
    name = "visual-signals",
    icon = "__visual-signals__/graphics/icons/constant-combinator.png",
    icon_size = 32,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "gui-signal-display"
      }
    },
    prerequisites = {"advanced-electronics-2", "circuit-network", "optics"},
    unit =
    {
      count = 5,
      ingredients = {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"production-science-pack", 2},
        {"high-tech-science-pack", 2}
      },
      time = 60
    },
    order = "e-a-b"
  }
})
