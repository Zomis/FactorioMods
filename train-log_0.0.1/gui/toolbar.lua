local events_table = require("gui/events_table")
local tables = require("__flib__.table")

local function handle_action(action, event)
    if action.action == "refresh" then
        local gui_contents = events_table.create_events_table(action.gui_id)
        -- gui_contents.scroll_pane.scroll_to_bottom() -- Doesn't work. Perhaps needs to wait a tick?
    end
end

local time_period_items = {
    {
        time = 60*2,
        text = "train-log.time-2m"
    },
    {
        time = 60*15,
        text = "train-log.time-15m"
    },
    {
        time = 60*60*1,
        text = "train-log.time-1h"
    },
    {
        time = 60*60*3,
        text = "train-log.time-3h"
    },
    {
        time = 60*60*6,
        text = "train-log.time-6h"
    },
    {
        time = 60*60*12,
        text = "train-log.time-12h"
    },
    {
        time = 60*60*24,
        text = "train-log.time-24h"
    }
}
local time_period_default_index = 2

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
                        items = tables.map(time_period_items, function(v) return {v.text} end),
                        selected_index = time_period_default_index,
                        ref = { "filter", "time_period" },
                        actions = {
                            on_gui_selection_state_changed = { type = "toolbar", action = "refresh", gui_id = gui_id }
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
                            on_click = { type = "toolbar", action = "clear" }
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
                                    on_gui_text_changed = { type = "toolbar", action = "apply-filter", gui_id = gui_id }
                                }
                            }
                        }
                    },
                    {
                        type = "flow",
                        direction = "horizontal",
                        children = {
                            {
                                type = "choose-elem-button",
                                elem_type = "item",
                                tooltip = { "train-log.filter-item-tooltip" },
                                ref = { "filter", "item" },
                                actions = {
                                    on_gui_selection_state_changed = {
                                        type = "toolbar", action = "apply-filter", gui_id = gui_id,
                                        filter = "item"
                                    }
                                }
                            },
                            {
                                type = "choose-elem-button",
                                elem_type = "fluid",
                                tooltip = { "train-log.filter-fluid-tooltip" },
                                ref = { "filter", "fluid" },
                                actions = {
                                    on_gui_selection_state_changed = {
                                        type = "toolbar", action = "apply-filter", gui_id = gui_id,
                                        filter = "fluid"
                                    }
                                }
                            },
                            {
                                type = "sprite-button",
                                sprite = "train_log_backspace",
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
