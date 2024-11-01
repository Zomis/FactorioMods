local gui_handlers = require("gui/handlers")
local gui_utils = require("gui/gui_utils")
local flib_format = require("__flib__.format")
local gui = require("__flib__.gui")
local trains = require("__flib__.train")
local time_filter = require("filter-time")
local summary_gui = require("gui/summary")

gui_handlers.events_table = function(event)
    local action = event.element.tags
    if action.action_type == "open-train" then
        local train_id = action.train_id
        local train_data = storage.trains[train_id]
        local train = train_data.train
        trains.open_gui(event.player_index, train)
    end
    if action.action_type == "position" then
        local player = game.players[event.player_index]
--        player.zoom_to_world(action.position, 0.5)
        player.set_controller({
            type = defines.controllers.remote,
            position = action.position,
            surface = action.surface
        })
    end
end

local function events_row(train_data, children, summary, gui_id)
    local train_icon
    if train_data.train.valid and train_data.train.front_stock.valid then
        local prototype = train_data.train.front_stock.prototype
        train_icon = {
            type = "sprite-button",
            style = "slot_button",
            sprite = "item/" .. gui_utils.signal_for_entity(train_data.train.front_stock).name,
            number = train_data.train.id,
            tooltip = prototype.localised_name,
            handler = gui_handlers.events_table,
            tags = {
                action_type = "open-train",
                train_id = train_data.train.id
            }
        }
    else
        train_icon = {
            type = "sprite-button",
            sprite = "train_log_train",
            tooltip = {"train-log.train-removed"},
        }
    end

    local last_change = train_data.last_change
    local relative_time = game.tick - last_change
    local timestamp = {
        type = "label",
        tooltip = flib_format.time(last_change, true),
        caption = { "train-log.time-relative", flib_format.time(relative_time, true) }
    }

    local event_children = {}
    local last_station = nil
    for _, event in pairs(train_data.events) do
        --[[
        local delay = event.tick - last_change
        local delay_button = {
            type = "sprite-button",
            sprite = "train_log_timer-outline",
            tooltip = flib_format.time(last_change, true)
        }
        table.insert(event_children, delay_button)
        ]]--
        if event.state and false then
            table.insert(event_children, gui_utils.sprite_button_for_state(event.state))
        end
        if event.schedule and false then
            table.insert(event_children, {
                type = "sprite-button",
                sprite = "train_log_train",
                tooltip = {"train-log.schedule-change"}
            })
            if event.changed_by then
                table.insert(event_children, {
                    type = "sprite-button",
                    sprite = "train_log_train",
                    tooltip = {"train-log.schedule-changed-by", event.changed_by}
                })
            end
        end

        if event.station then
            last_station = event.station
            summary_gui.add_station_stop(event, summary)
            if event.station.valid then
                table.insert(event_children, {
                    type = "sprite-button",
                    sprite = "entity/" .. event.station.name,
                    tooltip = {"train-log.station-name", event.station.backer_name},
                    handler = gui_handlers.events_table,
                    tags = {
                        action_type = "position",
                        position = event.position,
                        surface = event.surface
                    }
                })
            else
                table.insert(event_children, {
                    type = "sprite-button",
                    sprite = "train_log_train",
                    tooltip = {"train-log.station-removed"},
                    handler = gui_handlers.events_table,
                    tags = {
                        action_type = "position",
                        position = event.position,
                        surface = event.surface
                    }
                })
            end
        elseif event.position then
            table.insert(event_children, {
                type = "sprite-button",
                sprite = "train_log_crosshairs-gps",
                tooltip = { "train-log.temporary-stop-at", event.position.x, event.position.y },
                handler = gui_handlers.events_table,
                tags = {
                    action_type = "position",
                    position = event.position,
                    surface = event.surface
                }
            })
        end

        if event.contents and false then -- This is not stored in any log event, just temporarily in train_data
            if event.contents.items then
                for name, count in pairs(event.contents.items) do
                    table.insert(event_children, gui_utils.sprite_button_type_name_amount("item", name, count, nil, gui_id))
                end
            end
            if event.contents.fluids then
                for name, count in pairs(event.contents.fluids) do
                    table.insert(event_children, gui_utils.sprite_button_type_name_amount("fluid", name, count, nil, gui_id))
                end
            end
        end
        if event.diff then
            summary_gui.add_diff(event, summary, last_station)
            for name, count in pairs(event.diff.items) do
                local color = count > 0 and "green" or "red"
                table.insert(event_children, gui_utils.sprite_button_type_name_amount("item", name, count, color, gui_id))
            end
            for name, count in pairs(event.diff.fluids) do
                local color = count > 0 and "green" or "red"
                table.insert(event_children, gui_utils.sprite_button_type_name_amount("fluid", name, count, color, gui_id))
            end
        end
        -- last_change = event.tick
    end

    if not next(event_children) then
        -- no events to display, no need to show row
        return
    end

    local event_flow = {
        type = "flow",
        direction = "horizontal",
        children = event_children
    }

    table.insert(children, train_icon)
    table.insert(children, timestamp)
    table.insert(children, event_flow)
end

local function matches_filter(result, filters, player)
    if result.last_change < filters.time_period then
        return false
    end

    local matches_item = filters.item == nil
    local matches_fluid = filters.fluid == nil
    local matches_station = filters.station_name == ""
    local matches_surface = not filters.current_surface
    if matches_item and matches_fluid and matches_station and matches_surface then
        return true
    end
    for _, event in pairs(result.events) do
        if not matches_item and event.contents then
            matches_item = event.contents[filters.item]
        end
        if not matches_fluid and event.fluids then
            matches_fluid = event.fluids[filters.fluid]
        end
        if not matches_station and event.station then
            local station_name = event.station.valid and event.station.backer_name or ""
            if station_name:lower():find(filters.station_name, 1, true) then
                matches_station = true
            end
        end
        if not matches_surface and event.surface then
            matches_surface = player.surface.name == event.surface
        end
        if matches_item and matches_fluid and matches_station and matches_surface then
            return true
        end
    end
    return false
end

local function iterate_backwards_iterator(tbl, i)
    i = i - 1
    if i ~= 0 then
        return i, tbl[i]
    end
end
local function iterate_backwards(tbl)
    return iterate_backwards_iterator, tbl, table_size(tbl) + 1
end

local function create_result_guis(results, filters, columns, gui_id)
    local children = {}
    local summary = summary_gui.create_new_summary()
    for _, column in pairs(columns) do
        table.insert(children, {
            type = "label",
            caption = { "train-log.table-header-" .. column }
        })
    end
    local train_log_gui = storage.guis[gui_id]
    local player = train_log_gui.player

    for _, result in iterate_backwards(results) do
        if matches_filter(result, filters, player) then
            events_row(result, children, summary, gui_id)
        end
    end
    return children, summary
end

local function create_events_table(gui_id)
    -- Loop through train datas, start with oldest (easier to move newest to the end)
    -- Loop through all the histories first and then check current, sort by the tick of last entry
    local train_log_gui = storage.guis[gui_id]
    local histories = {}
    local train_datas = storage.trains
    for _, history in pairs(storage.history) do
        if history.force_index == train_log_gui.player.force.index then
            table.insert(histories, history)
        end
    end
    for _, train_data in pairs(train_datas) do
        if train_data.force_index == train_log_gui.player.force.index then
            table.insert(histories, train_data)
        end
    end

    table.sort(histories, function(a, b) return a.last_change < b.last_change end)

    local filters = {
        item = train_log_gui.gui.filter_item.elem_value,
        fluid = train_log_gui.gui.filter_fluid.elem_value,
        current_surface = train_log_gui.gui.filter_current_surface.state,
        station_name = train_log_gui.gui.filter_station_name.text:lower(),
        time_period = game.tick - time_filter.ticks(train_log_gui.gui.filter_time_period.selected_index)
    }

    local children_guis, summary = create_result_guis(histories, filters, { "train", "timestamp", "events" }, gui_id)
    train_log_gui.gui.tabs_events_contents.clear()
    train_log_gui.gui.tabs_summary_contents.clear()

    gui.add(train_log_gui.gui.tabs_summary_contents, {
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
--            name = "scroll_pane",
            vertical_scroll_policy = "always",
            style_mods = {width = 650, height = 400, padding = 6},
            children = {
                {
                    type = "flow",
                    direction = "vertical",
                    children = summary_gui.create_gui(summary, gui_id)
                }
            }
        }
    })

    return gui.add(train_log_gui.gui.tabs_events_contents, {
        {
            type = "scroll-pane",
            style = "flib_naked_scroll_pane_no_padding",
--            name = "scroll_pane",
            vertical_scroll_policy = "always",
            style_mods = {width = 650, height = 400, padding = 6},
            children = {
                {
                    type = "table",
                    name = "events_table",
                    column_count = 3,
                    children = children_guis
                }
            }
        }
    })
end

return {
    create_events_table = create_events_table
}
