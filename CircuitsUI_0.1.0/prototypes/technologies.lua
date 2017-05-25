data:extend({
{
    type = "technology",
    name = "atomic-bomb",
    icon = "__base__/graphics/technology/atomic-bomb.png",
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "atomic-bomb"
      }
    },
    prerequisites = {"nuclear-power", "military-4", "rocketry"},
    unit =
    {
      count = 5000,
      ingredients =
      {
        {"science-pack-1", 1},
        {"science-pack-2", 1},
        {"science-pack-3", 1},
        {"military-science-pack", 1},
        {"production-science-pack", 1},
        {"high-tech-science-pack", 1}
      },
      time = 45
    },
    order = "e-a-b"
  }
})
