data:extend({
  {
    type = "technology",
    name = "advanced-combinator",
    icon = "__advanced-combinator__/graphics/icons/constant-combinator.png",
    icon_size = 32,
    effects =
    {
      {
        type = "unlock-recipe",
        recipe = "advanced-combinator"
      }
    },
    prerequisites = {"circuit-network"},
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
