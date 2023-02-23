-- You need to declare a callback interface that Foofle can use
remote.add_interface("foofle-fnei-craft", {
    open_craft = function(_, info)
        remote.call("fnei", "show_recipe_for_prot", "craft", info.type, info.name)
    end,
    foofle_support = function(info)
        -- This function determines if we should show our integration button or not
        return info.type == "fluid" or info.type == "item"
    end
})
remote.add_interface("foofle-fnei-usage", {
    open_usage = function(_, info)
        remote.call("fnei", "show_recipe_for_prot", "usage", info.type, info.name)
    end,
    foofle_support = function(info)
        -- This function determines if we should show our integration button or not
        return info.type == "fluid" or info.type == "item"
    end
})

-- This method should be invoked from both `on_init` (when mod is started for the first time in a new or existing save)
-- and from `on_load` (when saved game is loaded which already contains the mod)
local function on_start()
    -- In order for us to use Foofle, the "foofle" remote interface must exist
    -- In order for us to use FNEI, the "fnei" remote interface must exist
    if remote.interfaces["foofle"] and remote.interfaces["fnei"] then
        remote.call("foofle", "add_integration", "foofle-fnei-craft", {
            button = {
                type = "button",
                caption = { "foofle-fnei.craft" },
                tooltip = { "foofle-fnei.craft" }
            },
            supported_check = "foofle_support",
            callback = "open_craft"
        })
        remote.call("foofle", "add_integration", "foofle-fnei-usage", {
            button = {
                type = "button",
                caption = { "foofle-fnei.usage" },
                tooltip = { "foofle-fnei.usage" }
            },
            supported_check = "foofle_support",
            callback = "open_usage"
        })
    end
end

return { on_start = on_start }
