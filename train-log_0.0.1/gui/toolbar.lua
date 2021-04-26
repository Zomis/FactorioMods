local events_table = require("gui/events_table")

local function handle_action(action, event)
    if action.action == "refresh" then
        local gui_contents = events_table.create_events_table(action.gui_id)
        -- gui_contents.scroll_pane.scroll_to_bottom() -- Doesn't work. Perhaps needs to wait a tick?
    end
end

local function create_toolbar(gui_id)
    return {
        type = "flow",
        direction = "horizontal",
        children = {
            {
                type = "button",
                caption = { "train-log.refresh" },
                actions = {
                    on_click = { type = "toolbar", action = "refresh", gui_id = gui_id }
                }
            },
            {
                type = "button",
                caption = { "train-log.clear-history" },
                actions = {
                    on_click = { type = "toolbar", action = "clear" }
                }
            },
            {
                type = "textfield",
                caption = { "train-log.name-filter" },
                actions = {
                    on_gui_text_changed = { type = "toolbar", action = "apply-filter", gui_id = gui_id }
                }
            },
            {
                type = "choose-elem-button",
                elem_type = "item",
                tooltip = { "train-log.item-filter-tooltip" },
                actions = {
                    on_gui_selection_state_changed = { type = "toolbar", action = "apply-filter", gui_id = gui_id }
                }
            },
            {
                type = "choose-elem-button",
                elem_type = "fluid",
                tooltip = { "train-log.fluid-filter-tooltip" },
                actions = {
                    on_gui_selection_state_changed = { type = "toolbar", action = "apply-filter", gui_id = gui_id }
                }
            },
            {
                type = "button",
                caption = { "train-log.clear-filters" },
                actions = {
                    on_click = { type = "toolbar", action = "clear-filter", gui_id = gui_id }
                }
            }
        }
    }
end

return {
    handle_action = handle_action,
    create_toolbar = create_toolbar
}
