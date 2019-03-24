data.raw["gui-style"].default["usage_detector_scroll"] = {
    type = "scroll_pane_style",
    minimal_width = 700,
    minimal_height = 400,
    maximal_height = 800
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
    width = 40,
    height = 35,
    font = "usage_detector_font"
}
