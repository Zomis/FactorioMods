--- Location view gui

data.raw["gui-style"].default["lv_location_view"] =
{
    type = "button_style",
    parent = "button_style",
    width = 100,
    height = 100,
    top_padding = 65,
    right_padding = 0,
    bottom_padding = 0,
    left_padding = 0,
    font = "font-mb",
    default_font_color = {r=0.98, g=0.66, b=0.22},
    default_graphical_set =
    {
        type = "monolith",
        monolith_image =
        {
            filename = "location.png",
            priority = "extra-high-no-scale",
            width = 100,
            height = 100,
            x = 0
        }
    },
    hovered_graphical_set =
    {
        type = "monolith",
        monolith_image =
        {
            filename = "location-hover.png",
            priority = "extra-high-no-scale",
            width = 100,
            height = 100,
            x = 0
        }
    },
    clicked_graphical_set =
    {
        type = "monolith",
        monolith_image =
        {
            filename = "location-hover.png",
            width = 100,
            height = 100,
            x = 0
        }
    }
}
