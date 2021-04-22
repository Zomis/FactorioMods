local gui_common = require("v2/gui/common")
local plugins_support = require("v2/plugins/plugins_support")

local empty_widget = { type = "empty-widget" }

local function circuit_network_name(circuit_network)
    if circuit_network.wire_type == defines.wire_type.red then
        return "red"
    end
    if circuit_network.wire_type == defines.wire_type.green then
        return "green"
    end
    return "unknown"
end

local function expected_amount(product)
    local expected = product.amount
    if not expected then
      expected = (product.amount_min + product.amount_max) / 2.0
    end
    local probability = product.probability or 1
    return expected * probability
end

local function sprite_button_type_name_amount(type, name, amount, color)
    local prototype = nil
    if type == "item" then
        prototype = game.item_prototypes[name]
    elseif type == "fluid" then
        prototype = game.fluid_prototypes[name]
    elseif type == "virtual-signal" then
        prototype = game.virtual_signal_prototypes[name]
    end
    return {
        type = "sprite-button",
        style = color and "flib_slot_button_" .. color or "flib_slot_button_default",
        sprite = type .. "/" .. name,
        number = amount,
        tooltip = prototype.localised_name
    }
end

local function signal_to_sprite_button(signal, color)
    local signal_type = signal.signal.type
    if signal_type == "virtual" then
        signal_type = "virtual-signal"
    end
    return sprite_button_type_name_amount(signal_type, signal.signal.name, signal.count, color)
end

local result_gui = {
    entity_icon = {
        requires = { "entity" },
        displays = {
            icon = function(data)
                if not data.entity then return empty_widget end
                if not data.entity.valid then return empty_widget end
                local signal = gui_common.signal_for_entity(data.entity)
                local prototype = data.entity.prototype
                return {
                    type = "sprite-button",
                    style = "slot_button",
                    sprite = "item/" .. signal.name,
                    tooltip = prototype.localised_name,
                }
            end
        }
    },
    circuit_networks = {
        requires = { "circuit_networks" },
        displays = {
            circuit_networks = function(data)
                if not data.circuit_networks then return empty_widget end
                local children = {}
                for _, v in pairs(data.circuit_networks) do
                    local color = circuit_network_name(v)
                    if v.signals then
                        for _, value in pairs(v.signals) do
                            table.insert(children, signal_to_sprite_button(value, color))
                        end
                    end
                end
                return {
                    type = "table",
                    style = "slot_table",
                    column_count = 8,
                    children = children
                }
            end
        },
    },
    recipe = {
        requires = { "recipe" },
        displays = {
            recipe = function(data)
                if not data.recipe then return empty_widget end
                local recipe = data.recipe
                if not recipe.valid then return empty_widget end
                return {
                    type = "flow", direction = "horizontal", children = {
                        {
                            type = "sprite-button",
                            sprite = "recipe/" .. recipe.name
                        },
                        {
                            type = "label",
                            caption = recipe.localised_name,
                            tooltip = recipe.name
                        }
                    }
                }
            end,
            ingredients = function(data)
                if not data.recipe then return empty_widget end
                local recipe = data.recipe
                if not recipe.valid then return empty_widget end

                local ingredients = {}
                for k, ingredient in ipairs(recipe.ingredients) do
                    ingredients[k] = sprite_button_type_name_amount(ingredient.type, ingredient.name, ingredient.amount)
                end
                return {
                    type = "table", style = "slot_table", column_count = 5, children = ingredients
                }
            end,
            time = function(data)
                if not data.recipe then return empty_widget end
                local recipe = data.recipe
                if not recipe.valid then return empty_widget end

                return {
                    type = "label",
                    caption = recipe.energy
                }
            end,
            products = function(data)
                if not data.recipe then return empty_widget end
                local recipe = data.recipe
                if not recipe.valid then return empty_widget end

                local products = {}
                for k, product in ipairs(recipe.products) do
                    products[k] = sprite_button_type_name_amount(product.type, product.name, expected_amount(product))
                end
                return {
                    type = "table", style = "slot_table", column_count = 5, children = products
                }
            end
        }
    },
    all_actions = {
        requires = { "entity" },
        header = function(search)
            return {
                type = "flow",
                direction = "horizontal",
                children = {
                    {
                        type = "button",
                        caption = {"search_engine.results-actions-show_alerts"},
                        actions = {
                            on_click = { type = "results_batch", action = "show_alerts", search_id = search.search_id }
                        }
                    },
                    {
                        type = "button",
                        caption = {"search_engine.results-actions-chart_tags"},
                        actions = {
                            on_click = { type = "results_batch", action = "chart_tags", search_id = search.search_id }
                        }
                    },
                    {
                        type = "button",
                        caption = {"search_engine.results-actions-send_messages"},
                        actions = {
                            on_click = {
                                type = "results_batch", action = "send_messages", search_id = search.search_id
                            }
                        }
                    },
                }
            }
        end
    },
    entity_actions = {
        requires = { "entity" },
        displays = {
            actions = function(_, data_keys)
                return {
                    type = "flow", direction = "horizontal", children = {
                        {
                            type = "button",
                            caption = {"search_engine.results-actions-goto"},
                            actions = {
                                on_click = { type = "result", action = "goto", data_keys = data_keys }
                            }
                        },
                        {
                            type = "button",
                            caption = {"search_engine.results-actions-send-message"},
                            actions = {
                                on_click = { type = "result", action = "print", data_keys = data_keys }
                            }
                        },
                        {
                            type = "button",
                            caption = {"search_engine.results-actions-chart-tag"},
                            actions = {
                                on_click = { type = "result", action = "chart_tag", data_keys = data_keys }
                            }
                        }
                    }
                }
            end
        }
    }
}

local function handle_action(action, event)
    if action.type == "result" then
        local player = game.players[event.player_index]
        local search = global.searches[action.data_keys.search_id]
        local data = search.results[action.data_keys.data_index]
        if action.action == "goto" then
            -- player.open_map(data.position, 0.5)
            if not data.position then return end
            player.zoom_to_world(data.position, 0.5)
        end
        if action.action == "chart_tag" then
            if not data.entity then return end
            if not data.entity.valid then return end
            player.force.add_chart_tag(player.surface, {
                position = data.entity.position, icon = gui_common.signal_for_entity(data.entity)
            })
        end
        if action.action == "print" then
            if not data.entity then return end
            if not data.entity.valid then return end
            player.print(
              "[entity=" .. data.entity.name .. "] @ " ..
              "[gps=" .. data.entity.position.x .. "," .. data.entity.position.y .. "]"
            )
        end
    elseif action.type == "results_batch" then
        local search = global.searches[action.search_id]
        local player = search.player
        if action.action == "send_messages" then
            for _, data in pairs(search.results) do
                if not data.entity then return end
                if not data.entity.valid then return end
                player.print(
                    "[entity=" .. data.entity.name .. "] @ " ..
                    "[gps=" .. data.entity.position.x .. "," .. data.entity.position.y .. "]"
                )
            end
        end
        if action.action == "chart_tags" then
            for _, data in pairs(search.results) do
                if not data.entity then return end
                if not data.entity.valid then return end
                player.force.add_chart_tag(player.surface, {
                    position = data.entity.position, icon = gui_common.signal_for_entity(data.entity)
                })
            end
        end
        if action.action == "show_alerts" then
            for _, data in pairs(search.results) do
                if not data.entity then return end
                if not data.entity.valid then return end
                player.add_custom_alert(data.entity, gui_common.signal_for_entity(data.entity), {"result_alert"}, true)
            end
        end
    end
end

local function columns(plugins)
    local found = {}
    local results = {}
    for _, plugin in pairs(plugins) do
        if plugin.displays then
            for display_key in pairs(plugin.displays) do
                if not found[display_key] then
                    table.insert(results, display_key)
                end
                found[display_key] = true
            end
        end
    end
    return results
end

local function process_result(data, data_index, search, plugins, children)
    local data_keys = {
        search_id = search.search_id,
        data_index = data_index
    }
    for _, plugin in pairs(plugins) do
        if plugin.displays then
            for _, display in pairs(plugin.displays) do
                table.insert(children, display(data, data_keys))
            end
        end
    end
end

local function create_header(search, plugins)
    local children = {}
    for _, plugin in pairs(plugins) do
        if plugin.header then
            table.insert(children, plugin.header(search))
        end
    end
    return children
end

return {
    handle_action = handle_action,
    create_header = create_header,
    columns = columns,
    process_result = process_result,
    plugins_support = plugins_support(result_gui)
}
