local guis = require("__flib__.gui")
local tables = require("__flib__.table")
local header = require("gui/header")
local circuit_networks = require("circuit_networks")


local function add_inventory(category, inventory)
    category.contents = category.contents or {}
    local contents = category.contents
    for item, count in pairs(inventory.get_contents()) do
        if not contents[item] then contents[item] = 0 end
        contents[item] = contents[item] + count
    end
end

local function add_fluids(category, entity)
    category.contents = category.contents or {}
    local contents = category.contents
    for fluid, count in pairs(entity.get_fluid_contents()) do
        if not contents[fluid] then contents[fluid] = 0 end
        contents[fluid] = contents[fluid] + count
    end
end

local function scan_entities(entities_to_scan)
    local categories = {
        entities = { category_name = "entities", contents = {}, content_type = "item" }
    }
    local entities = categories.entities.contents

    for _, entity in pairs(entities_to_scan) do
        if not entity.valid then goto continue end
        local items_placable = entity.prototype.items_to_place_this or {}
        for _, item in ipairs(items_placable) do
            local item_name = item.name or item
            if not entities[item_name] then entities[item_name] = 0 end
            entities[item_name] = entities[item_name] + 1
        end

        if entity.type == "character" then
            categories.character = categories.character or { category_name = "character-main", content_type = "item" }
            add_inventory(categories.character, entity.get_main_inventory())
        end
        if entity.type == "container" then
            categories.containers = categories.containers or { category_name = "containers", content_type = "item" }
            add_inventory(categories.containers, entity.get_inventory(defines.inventory.chest))
        end
        if entity.type == "storage-tank" then
            categories.storage_tanks = categories.storage_tanks or { category_name = "storage-tanks", content_type = "fluid" }
            add_fluids(categories.storage_tanks, entity)
        end
        if entity.type == "pipe" or entity.type == "pipe-to-ground" then
            categories.pipes = categories.pipes or { category_name = "pipes", content_type = "fluid" }
            add_fluids(categories.pipes, entity)
        end
        if entity.type == "assembling-machine" then
            categories.recipes = categories.recipes or { category_name = "recipes", recipes = {} }
            local recipe = entity.get_recipe()
            if recipe then
                table.insert(categories.recipes.recipes, { entity = entity, recipe = recipe })
            end
        end
        if entity.type == "furnace" then
            categories.recipes = categories.recipes or { category_name = "recipes", recipes = {} }
            local recipe = entity.get_recipe() or entity.previous_recipe
            if recipe then
                table.insert(categories.recipes.recipes, { entity = entity, recipe = recipe })
            end
        end
        if entity.type == "transport-belt" or entity.type == "underground-belt" or entity.type == "splitter" then
            categories.belts = categories.belts or { category_name = "belts", content_type = "item" }
            local transport_line_count = entity.get_max_transport_line_index()
            for i = 1, transport_line_count do
                add_inventory(categories.belts, entity.get_transport_line(i))
            end
        end
        ::continue::
    end

    return categories
end

local function create_sprite_button(type, name, value)
    local prototype = nil
    if not type then error("missing type") end
    if type == "item" then prototype = game.item_prototypes[name] end
    if type == "fluid" then prototype = game.fluid_prototypes[name] end
    if prototype == nil then error("could not create sprite button for prototype: " .. type .. "/" .. name) end
    local sprite = type .. "/" .. name
    return {
        type = "sprite-button",
        sprite = sprite,
        tooltip = prototype.localised_name,
        number = value,
        actions = {
            on_click = { action_type = "goto", type = type, name = name, sprite = sprite }
        }
    }
end

local function create_recipe_flow(recipe, entity)
    local actual_time = recipe.energy / entity.crafting_speed
    local flow_children = {
        {
            type = "sprite",
            sprite = "foofle_timer-outline",
            tooltip = actual_time
        }
    }
    for _, v in ipairs(recipe.ingredients) do
        table.insert(flow_children, create_sprite_button(v.type, v.name, v.amount + (v.catalyst_amount or 0)))
    end
    table.insert(flow_children, {
        type = "sprite",
        sprite = "foofle_arrow-right-bold"
    })
    for _, v in ipairs(recipe.products) do
        local avg_amount = (v.catalyst_amount or 0) + v.amount or ((v.amount_min + v.amount_max) * v.probability * 0.5)
        table.insert(flow_children, create_sprite_button(v.type, v.name, avg_amount))
    end
    return {
        type = "flow",
        direction = "horizontal",
        tooltip = recipe.localised_name,
        children = flow_children
    }
end

local function build_ui(groups)
    local results = {}

    for k, category in pairs(groups) do
        table.insert(results, {
            type = "label",
            caption = { "foofle.category-" .. category.category_name }
        })
        if category.contents then
            if not category.content_type then error("missing content_type from category " .. k) end
            table.insert(results, {
                type = "table",
                column_count = 10,
                children = tables.filter(tables.map(category.contents, function(v, k)
                    return create_sprite_button(category.content_type, k, v)
                end), function() return true end, true)
            })
        end
        if category.recipes then
            table.insert(results, {
                type = "table",
                column_count = 2,
                children = tables.filter(tables.map(category.recipes, function(v)
                    return create_recipe_flow(v.recipe, v.entity)
                end), function() return true end, true)
            })
        end
    end
    return results
end

local function show_entities(player, entities)
    -- Entities
    -- Contents (inventories, storage, belts, pipes)
    -- Settings (e.g. recipes, signals)
    -- Signals (active signals)
    local result_groups = scan_entities(entities)
    local gui = guis.build(player.gui.screen, {
        {
            type = "frame",
            direction = "vertical",
            ref = { "window" },
            children = {
                header({ "foofle.title-selection" }),
                {
                    type = "scroll-pane",
                    style = "flib_naked_scroll_pane_no_padding",
                    -- vertical_scroll_policy = "always",
                    -- style_mods = {width = 650, height = 400, padding = 6},
                    children = {
                        {
                            type = "flow",
                            direction = "vertical",
                            children = build_ui(result_groups)
                        },
                    }
                }
            }
        }
    })
    gui.titlebar.drag_target = gui.window
    gui.window.force_auto_center()
end

return {
    show_entities = show_entities
}