local gui_handlers = require("gui/handlers")
local events_table = require("gui/events_table")
local time_filter = require("filter-time")
local train_log = require("train_log")

local function refresh(gui_id)
    events_table.create_events_table(gui_id)
    -- gui_contents.scroll_pane.scroll_to_bottom() -- Doesn't work. Perhaps needs to wait a tick?
end

gui_handlers.toolbar = function(event)
    local action = event.element.tags
    local action_type = action.action_type
    local train_log_gui = storage.guis[action.gui_id]
    if action.action_event and event.name ~= action.action_event then
        return
    end
    if action_type == "clear-older" then
        local older_than = game.tick - time_filter.ticks(train_log_gui.gui.filter.time_period.selected_index)
        local player = game.players[event.player_index]
        local force = player.force
        train_log.clear_older(event.player_index, older_than)
        force.print { "train-log.player-cleared-history", player.name }
    end
    if action_type == "refresh" then
        refresh(action.gui_id)
    end
    if action_type == "filter" then
        local filter_type = action.filter_type
        train_log_gui.gui.filter_item.elem_value = nil
        train_log_gui.gui.filter_fluid.elem_value = nil
        if filter_type == "item" and prototypes.item[action.filter_value] then
            train_log_gui.gui.filter_item.elem_value = action.filter_value
            action_type = "apply-filter"
        end
        if filter_type == "fluid" and prototypes.fluid[action.filter_value] then
            train_log_gui.gui.filter_fluid.elem_value = action.filter_value
            action_type = "apply-filter"
        end
    end
    if action_type == "apply-filter" then
        if action.filter_type == "item" then
            train_log_gui.gui.filter_fluid.elem_value = nil
        elseif action.filter_type == "fluid" then
            train_log_gui.gui.filter_item.elem_value = nil
        end
        refresh(action.gui_id)
    end
    if action_type == "clear-filter" then
        local g = train_log_gui.gui
        g.filter_station_name.text = ""
        g.filter_item.elem_value = nil
        g.filter_fluid.elem_value = nil
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
                        handler = gui_handlers.toolbar,
                        tags = {
                            action_type = "refresh",
                            action_event = defines.events.on_gui_selection_state_changed,
                            gui_id = gui_id
                        }
                    },
                    {
                        type = "button",
                        caption = { "train-log.refresh" },
                        tooltip = { "train-log.refresh" },
                        handler = gui_handlers.toolbar,
                        tags = {
                            action_type = "refresh",
                            action_event = defines.events.on_gui_click,
                            gui_id = gui_id
                        }
                    },
                    {
                        type = "button",
                        style = "red_button",
                        caption = { "train-log.clear-older" },
                        handler = gui_handlers.toolbar,
                        tags = {
                            action_type = "clear-older",
                            action_event = defines.events.on_gui_click,
                            gui_id = gui_id
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
                                handler = gui_handlers.toolbar,
                                tags = {
                                    action_type = "apply-filter",
                                    action_event = defines.events.on_gui_confirmed,
                                    gui_id = gui_id,
                                    filter = "station_name"
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
                                handler = gui_handlers.toolbar,
                                tags = {
                                    action_event = defines.events.on_gui_elem_changed,
                                    action_type = "apply-filter",
                                    gui_id = gui_id,
                                    filter = "item"
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
                                handler = gui_handlers.toolbar,
                                tags = {
                                    action_event = defines.events.on_gui_elem_changed,
                                    action_type = "apply-filter",
                                    gui_id = gui_id,
                                    filter = "fluid"
                                }
                            },
                            {
                                type = "button",
                                caption = { "train-log.filter-clear" },
                                tooltip = { "train-log.filter-clear" },
                                handler = gui_handlers.toolbar,
                                tags = {
                                    action_type = "clear-filter",
                                    action_event = defines.events.on_gui_click,
                                    gui_id = gui_id
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
    create_toolbar = create_toolbar
}
