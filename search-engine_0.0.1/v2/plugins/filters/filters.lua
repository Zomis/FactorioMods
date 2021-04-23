local gui = require("__flib__.gui-beta")

local function compare_options()
    return {
        type = "drop-down",
        items = { ">", ">=", "<", "<=", "=", "!=" },
        selected_index = 1,
        ref = {"comparison"}
    }
end

local function compare(value1, comparison, value2)
    local compare_type = comparison.items[comparison.selected_index]
    if compare_type == "<" then
        return value1 < value2
    elseif compare_type == "<=" then
        return value1 <= value2
    elseif compare_type == ">" then
        return value1 > value2
    elseif compare_type == ">=" then
        return value1 >= value2
    elseif compare_type == "=" then
        return value1 == value2
    elseif compare_type == "!=" then
        return value1 ~= value2
    end
end

local function recipe_produces(recipe, product_type, product_name)
    if recipe == nil then return false end
    if not recipe.valid then return false end
    for _, product in pairs(recipe.products) do
        if product.type == product_type and product.name == product_name then
            return true
        end
    end
    return false
end

local function recipe_consumes(recipe, product_type, product_name)
    if recipe == nil then return false end
    if not recipe.valid then return false end
    for _, ingredient in pairs(recipe.ingredients) do
        if ingredient.type == product_type and ingredient.name == product_name then
            return true
        end
    end
    return false
end

local function item_or_fluid_controls()
    return {
        {
            type = "flow", direction = "horizontal", children = {
                {
                    type = "choose-elem-button",
                    elem_type = "item",
                    ref = { "item" }
                },
                {
                    type = "choose-elem-button",
                    elem_type = "fluid",
                    ref = { "fluid" }
                }
            }
        }
    }
end

local function item_or_fluid_values(filter_gui)
    if filter_gui.item.elem_value then
        return { type = "item", name = filter_gui.item.elem_value }
    end
    if filter_gui.fluid.elem_value then
        return { type = "fluid", name = filter_gui.fluid.elem_value }
    end
    return nil
end

local filters = {
    circuit_networks = {
        requires = { "circuit_networks" },
        controls = function()
            return {
                {
                    type = "flow", direction = "horizontal", children = {
                        {
                            type = "choose-elem-button",
                            elem_type = "signal",
                            ref = {"signal_type"}
                        },
                        compare_options(),
                        {
                            type = "textfield",
                            text = "0",
                            numeric = true,
                            allow_negative = true,
                            ref = {"value"}
                        }
                    }
                }
            }
        end,
        filter = function(data, filter_gui)
            local match = false
            if not data.circuit_networks then
                return false
            end
            for _, v in pairs(data.circuit_networks) do
                if v.valid then
                    local value1 = v.get_signal(filter_gui.signal_type.elem_value)
                    local value2 = tonumber(filter_gui.value.text)
                    match = match or compare(value1, filter_gui.comparison, value2)
                end
            end
            return match
        end
    },
    contains = {
        requires = {},
        controls = item_or_fluid_controls,
        filter = function(data, filter_gui)
            local product = item_or_fluid_values(filter_gui)
            if data.entity then
                local entity = data.entity
                if not entity.valid then return false end
                if entity.type == "container" and product.type == "item" then
                    return entity.get_item_count(product.name) > 0
                end
                if entity.type == "storage-tank" and product.type == "fluid" then
                    return entity.get_fluid_count(product.name) > 0
                end
                return false
            end
            if data.recipe then
                local recipe = data.recipe
                local produced = recipe_produces(recipe, product.type, product.name)
                return produced or recipe_consumes(recipe, product.type, product.name)
            end
        end
    },
    has_ingredient = {
        requires = { "recipe" },
        controls = item_or_fluid_controls,
        filter = function(data, filter_gui)
            if not data.recipe then return false end
            if not data.recipe.valid then return false end
            local product = item_or_fluid_values(filter_gui)
            return recipe_consumes(data.recipe, product.type, product.name)
        end
    },
    has_product = {
        requires = { "recipe" },
        controls = item_or_fluid_controls,
        filter = function(data, filter_gui)
            if not data.recipe then return false end
            if not data.recipe.valid then return false end
            local product = item_or_fluid_values(filter_gui)
            return recipe_produces(data.recipe, product.type, product.name)
        end
    },
    recipe_has_anywhere = {
        requires = { "recipe" },
        controls = item_or_fluid_controls,
        filter = function(data, filter_gui)
            if not data.recipe then return false end
            if not data.recipe.valid then return false end
            local product = item_or_fluid_values(filter_gui)
            local produced = recipe_produces(data.recipe, product.type, product.name)
            return produced or recipe_consumes(data.recipe, product.type, product.name)
        end
    }
}

local function handle_action(action)
    local search_id = action.search_id
    local search = global.searches[search_id]
    if action.action == "add" then
        local filter_type = search.gui.filters.filter_type
        if filter_type.selected_index == 0 then
            return
        end
        local filter_id = filter_type.items[filter_type.selected_index]
        local parent = search.gui.filters.parent
        local filter_gui = gui.build(parent, filters[filter_id].controls())
        table.insert(search.filters, { filter_id = filter_id, gui = filter_gui })
    end
end

local function apply_filters(data, search)
    for _, search_filter in pairs(search.filters) do
        local filter = filters[search_filter.filter_id]
        if not filter.filter(data, search_filter.gui, search) then
            return false
        end
    end
    return true
end

local function filter_ids()
    local results = {}
    for k in pairs(filters) do
        table.insert(results, k)
    end
    return results
end

local function generic_controls(search_id)
    return {
        type = "flow", direction = "vertical", ref = { "filters", "parent" }, children = {
            {
                type = "flow", direction = "horizontal", children = {
                    {
                        type = "drop-down",
                        ref = { "filters", "filter_type" },
                        items = filter_ids()
                    },
                    {
                        type = "button",
                        caption = {"search_engine.filter-add"},
                        actions = {
                            on_click = { type = "filters", action = "add", search_id = search_id }
                        }
                    }
                }
            }
        }
    }
end

return {
    handle_action = handle_action,
    apply_filters = apply_filters,
    generic_controls = generic_controls
}