data.raw["gui-style"].default["what_is_missing_scroll"] = {
    type = "scroll_pane_style",
    maximal_width = 400
}

data:extend({
  {
    type = "font",
    name = "what_is_missing_font",
    from = "default",
    size = 12
  }
})

data.raw["gui-style"].default["what_is_missing_small_button"] = {
    type = "button_style",
    width = 30,
    height = 30,
    font = "what_is_missing_font"
}
