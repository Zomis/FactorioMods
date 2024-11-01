local events_table = require("gui/events_table")
local time_filter = require("filter-time")
local train_log = require("train_log")

local function refresh(gui_id)
    events_table.create_events_table(gui_id)
    -- gui_contents.scroll_pane.scroll_to_bottom() -- Doesn't work. Perhaps needs to wait a tick?
end

local function handle_action(action, event)
    local train_log_gui = storage.guis[action.gui_id]
    if action.action == "clear-older" then
        local older_than = game.tick - time_filter.ticks(train_log_gui.gui.filter.time_period.selected_index)
        local player = game.players[event.player_index]
        local force = player.force
        train_log.clear_older(event.player_index, older_than)
        force.print { "train-log.player-cleared-history", player.name }
    end
    if action.action == "refresh" then
        refresh(action.gui_id)
    end
    if action.action == "filter" then
        local filter = action.filter
        if filter == "item" and prototypes.item[action.value] then
            train_log_gui.gui.filter.item.elem_value = action.value
            action.action = "apply-filter"
        end
        if filter == "fluid" and prototypes.fluid[action.value] then
            train_log_gui.gui.filter.fluid.elem_value = action.value
            action.action = "apply-filter"
        end
    end
    if action.action == "apply-filter" then
        local filter_guis = train_log_gui.gui.filter

        if action.filter == "item" then
            filter_guis.fluid.elem_value = nil
        elseif action.filter == "fluid" then
            filter_guis.item.elem_value = nil
        end
        refresh(action.gui_id)
    end
    if action.action == "clear-filter" then
        local filter_guis = train_log_gui.gui.filter
        filter_guis.station_name.text = ""
        filter_guis.item.elem_value = nil
        filter_guis.fluid.elem_value = nil
        refresh(action.gui_id)
    end
end

local function create_toolbar(gui_id, parameter)
    local filter_item = nil
    local filter_fluid = nil
    if parameter and parameter.type == "item" then
        filter_item = parameter.name
    end
    if parameter and parameter.type == "fluid" then
        filter_fluid = parameter.name
    end
    return {
        type = "flow",
        direction = "vertical",
        children = {
            {
                type = "flow",
                direction = "horizontal",
                children = {
                    {
                        type = "label",
                        caption = { "train-log.filter-time-period-label" }
                    },
                    {
                        type = "drop-down",
                        items = time_filter.time_period_items,
                        selected_index = time_filter.default_index,
                        name = "filter_time_period",
                        actions = {
                            on_selection_state_changed = { type = "toolbar", action = "refresh", gui_id = gui_id }
                        }
                    },
                    {
                        type = "button",
                        caption = { "train-log.refresh" },
                        tooltip = { "train-log.refresh" },
                        actions = {
                            on_click = { type = "toolbar", action = "refresh", gui_id = gui_id }
                        }
                    },
                    {
                        type = "button",
                        style = "red_button",
                        caption = { "train-log.clear-older" },
                        actions = {
                            on_click = { type = "toolbar", action = "clear-older", gui_id = gui_id }
                        }
                    }
                }
            },
            {
                type = "flow",
                direction = "horizontal",
                children = {
                    {
                        type = "flow",
                        direction = "vertical",
                        children = {
                            {
                                type = "label",
                                caption = { "train-log.filter-station-name" }
                            },
                            {
                                type = "textfield",
                                tooltip = { "train-log.filter-station-name" },
                                name = "filter_station_name",
                                actions = {
                                    on_confirmed = {
                                        type = "toolbar", action = "apply-filter", gui_id = gui_id,
                                        filter = "station_name"
                                    }
                                }
                            }
                        }
                    },
                    {
                        type = "flow",
                        direction = "horizontal",
                        children = {
                            {
                                type = "label",
                                caption = { "train-log.filter-item-label" }
                            },
                            {
                                type = "choose-elem-button",
                                elem_type = "item",
                                item = filter_item,
                                tooltip = { "train-log.filter-item-tooltip" },
                                name = "filter_item",
                                actions = {
                                    on_elem_changed = {
                                        type = "toolbar", action = "apply-filter", gui_id = gui_id,
                                        filter = "item"
                                    }
                                }
                            },
                            {
                                type = "label",
                                caption = { "train-log.filter-or-fluid-label" }
                            },
                            {
                                type = "choose-elem-button",
                                elem_type = "fluid",
                                fluid = filter_fluid,
                                tooltip = { "train-log.filter-fluid-tooltip" },
                                name = "filter_fluid",
                                actions = {
                                    on_elem_changed = {
                                        type = "toolbar", action = "apply-filter", gui_id = gui_id,
                                        filter = "fluid"
                                    }
                                }
                            },
                            {
                                type = "button",
                                caption = { "train-log.filter-clear" },
                                tooltip = { "train-log.filter-clear" },
                                actions = {
                                    on_click = { type = "toolbar", action = "clear-filter", gui_id = gui_id }
                                }
                            }
                        }
                    }
                }
            },
        }
    }
end

return {
    handle_action = handle_action,
    create_toolbar = create_toolbar
}
