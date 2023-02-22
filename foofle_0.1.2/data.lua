local function create_sprite_icon(name, size)
    return {
        type = "sprite",
        name = "foofle_" .. name,
        filename = "__foofle__/graphics/icons/" .. name .. ".png",
        priority = "medium",
        width = size,
        height = size
    }
end
  
data:extend {
    create_sprite_icon("arrow-right-bold", 24),
    create_sprite_icon("timer-outline", 24),
}

data:extend {
    {
        type = 'custom-input',
        name = 'foofle',
        key_sequence = 'CONTROL + SHIFT + S',
        enabled_while_spectating = true,
    },
    {
        type = "shortcut",
        name = "foofle",
        localised_name = { "shortcut.foofle" },
        order = "a",
        action = "lua",
        style = "blue",
        icon = {
            filename = "__foofle__/graphics/icons/icon.png",
            flags = {
                "icon"
            },
            priority = "extra-high-no-scale",
            scale = 1,
            size = 36
        },
    },
    {
        type = "selection-tool",
        name = "foofle",
        icon = "__foofle__/graphics/icons/icon.png",
        icon_size = 36,
        flags = { "only-in-cursor" },
        subgroup = "tool",
        order = "selection",
        stack_size = 1,
        stackable = false,
        selection_color = { r = 0, g = 1, b = 0 },
        alt_selection_color = { r = 0, g = 0, b = 1 },
        selection_mode = {"any-entity"},
        alt_selection_mode = {"any-entity"},
        selection_cursor_box_type = "pair",
        alt_selection_cursor_box_type = "pair"
    },
    {
        type = "custom-input",
        name = "open-foofle",
        key_sequence = "CONTROL + SHIFT + mouse-button-1",
        consuming = "none",
        include_selected_prototype = true,
        order = "a"
    }
}
