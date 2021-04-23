local loop_plugins = {
    entities = {
        provides = "entity",
        controls = function()
            return {
                {
                    type = "drop-down",
                    ref = { "entity_type" },
                    items = {
                        "container", "storage-tank",
                        "any-machine", "assembling-machine", "furnace",
                        "constant-combinator", "programmable-speaker",
                        "lamp", "radar",
                        "vehicle"
                    },
                    selected_index = 1
                }
                -- TODO: generic component for name search: text input
                  -- (contains / starts with / exact match / fuzzy search, default to fuzzy here)
                  -- fuzzy: https://codereview.stackexchange.com/questions/111957/vc-as-in-vancouver-or-valencia
            }
        end,
        func = function(search)
            -- TODO: Support ghosts somehow? Especially showing what kind of ghost it is
            search.params.force = search.player.force
            local drop_down = search.gui_loop_params.entity_type
            search.params.type = drop_down.items[drop_down.selected_index]
            if search.params.type == "any-machine" then
                search.params.type = {"assembling-machine","furnace"}
            elseif search.params.type == "vehicle" then
                search.params.type = {"car","tank","spidertron"}
            end
            return search.player.surface.find_entities_filtered(search.params)
        end
    },
    recipes = {
        provides = "recipe",
        controls = function()
            return {
                -- enabled, containing ingredient/product/anywhere
            }
        end,
        func = function()
            -- TODO: Use LuaGameScript.get_filtered_recipe_prototypes
            return game.recipe_prototypes
        end
    }
}

local function gui_elements()
    local r = {}
    for k, v in pairs(loop_plugins) do
        table.insert(r, {
            type = "button",
            caption = k,
            tags = { loop_id = k, provides = v.provides }
        })
    end
    return r
end

local function create_loop(loop_id, search)
    return loop_plugins[loop_id].func(search)
end

local function provides(loop_id)
    return loop_plugins[loop_id].provides
end

local function controls(loop_id, search)
    return loop_plugins[loop_id].controls(search)
end

return {
    controls = controls,
    gui_elements = gui_elements,
    provides = provides,
    create_loop = create_loop
}
