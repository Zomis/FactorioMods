data:extend({
    {
        type = "int-setting",
        name = "copy-paste-recipe-signals-ingredient-multiplier",
        setting_type = "runtime-per-user",
        order = "a",
        default_value = -1,
        minimum_value = -100000,
        maximum_value = 100000
    }
})
data:extend({
    {
        type = "int-setting",
        name = "copy-paste-recipe-signals-product-multiplier",
        setting_type = "runtime-per-user",
        order = "b",
        default_value = 1,
        minimum_value = -100000,
        maximum_value = 100000
    }
})
data:extend({
    {
        type = "bool-setting",
        name = "copy-paste-recipe-signals-include-ticks",
        setting_type = "runtime-per-user",
        order = "c",
        default_value = true
    }
})
data:extend({
    {
        type = "bool-setting",
        name = "copy-paste-recipe-signals-include-seconds",
        setting_type = "runtime-per-user",
        order = "d",
        default_value = true
    }
})
data:extend({
    {
        type = "bool-setting",
        name = "copy-paste-recipe-time-includes-modules",
        setting_type = "runtime-per-user",
        order = "d",
        default_value = false
    }
})
data:extend({
    {
        type = "bool-setting",
        name = "copy-paste-recipe-time-paste-product-arithmetic",
        setting_type = "runtime-per-user",
        order = "e",    
        default_value = true
    }
})
data:extend({
    {
        type = "bool-setting",
        name = "copy-paste-recipe-time-paste-product-decider",
        setting_type = "runtime-per-user",
        order = "f",
        default_value = true
    }
})
