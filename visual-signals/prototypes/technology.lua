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
    prerequisites = {"circuit-network", "lamp"},
    unit =
    {
      count = 200,
      ingredients = {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 15
    },
    order = "e-a-b"
  }
})
