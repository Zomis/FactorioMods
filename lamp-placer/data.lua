data:extend({
  {
    type = "selection-tool",
    select = {
      mode = { "any-tile" },
      border_color = { r = 0, g = 1, b = 0 },
      cursor_box_type = "pair",
    },
    alt_select = {
      mode = { "any-entity" },
      border_color = { r = 0, g = 0, b = 1 },
      cursor_box_type = "pair",
    },
    name = "lamp-placer",
    icon = "__lamp-placer__/graphics/lamp-placer.png",
    icon_size = 32,
    flags = {},
    subgroup = "tool",
    order = "c[automated-construction]-b[deconstruction-planner]",
    stack_size = 1,
    stackable = false,
  }
})
