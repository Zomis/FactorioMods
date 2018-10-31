data.raw["gui-style"].default["usage_detector_scroll"] = {
    type = "scroll_pane_style",
    maximal_width = 400
}

data:extend({
  {
    type = "font",
    name = "usage_detector_font",
    from = "default",
    size = 12
  }
})

data.raw["gui-style"].default["usage_detector_small_button"] = {
    type = "button_style",
    width = 30,
    height = 30,
    font = "usage_detector_font"
}
