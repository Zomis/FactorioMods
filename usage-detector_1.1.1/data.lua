data.raw["gui-style"].default["usage_detector_scroll"] = {
    type = "scroll_pane_style",
    minimal_width = 700,
    minimal_height = 400,
    maximal_height = 800
}

local function create_sprite_icon(name, size)
  return {
    type = "sprite",
    name = "usage_detector_" .. name,
    filename = "__usage_detector__/graphics/icons/" .. name .. ".png",
    priority = "medium",
    width = size or 24,
    height = size or 24
  }
end

data:extend {
  create_sprite_icon("icon", 36)
}
