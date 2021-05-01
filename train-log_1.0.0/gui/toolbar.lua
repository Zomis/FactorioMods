local events_table = require("gui/events_table")
local time_filter = require("filter-time")
local train_log = require("train_log")

local function refresh(gui_id)
    events_table.create_events_table(gui_id)
    -- gui_contents.scroll_pane.scroll_to_bottom() -- Doesn't work. Perhaps needs to wait a tick?
end

local function handle_action(action, event)
    if action.action == "clear-older" then
        local train_log_gui = global.guis[action.gui_id]
        local older_than = game.tick - time_filter.ticks(train_log_gui.gui.filter.time_period.selected_index)
        local player = game.players[event.player_index]
        local force = player.force
        train_log.clear_older(event.player_index, older_than)
        force.print { "train-log.player-cleared-history", player.name }
    end
    if action.action == "refresh" then
        refresh(action.gui_id)
    end
    if action.action == "apply-filter" then
        local train_log_gui = global.guis[action.gui_id]
        local filter_guis = train_log_gui.gui.filter

        if action.filter == "item" then
            filter_guis.fluid.elem_value = nil
        elseif action.filter == "fluid" then
            filter_guis.item.elem_value = nil
        end
        refresh(action.gui_id)
    end
    if action.action == "clear-filter" then
        local train_log_gui = global.guis[action.gui_id]
        local filter_guis = train_log_gui.gui.filter
        filter_guis.station_name.text = ""
        filter_guis.item.elem_value = nil
        filter_guis.fluid.elem_value = nil
        refresh(action.gui_id)
    end
end

local function create_toolbar(gui_id)
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
                        ref = { "filter", "time_period" },
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
                                ref = { "filter", "station_name" },
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
                                tooltip = { "train-log.filter-item-tooltip" },
                                ref = { "filter", "item" },
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
                                tooltip = { "train-log.filter-fluid-tooltip" },
                                ref = { "filter", "fluid" },
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
