local gui = require("__flib__.gui")
local toolbar = require("gui/toolbar")
local events_table = require("gui/events_table")
local gui_handlers = require("gui/handlers")

local function header(gui_id)
    return {
        type = "flow",
        name = "titlebar",
        children = {
            {type = "label", style = "frame_title", caption = {"train-log.header"}, ignored_by_interaction = true},
            {type = "empty-widget", style = "flib_titlebar_drag_handle", ignored_by_interaction = true},
            {
                type = "sprite-button",
                style = "frame_action_button",
                sprite = "utility/close",
                hovered_sprite = "utility/close_black",
                clicked_sprite = "utility/close_black",
                handler = gui_handlers.close_window,
                tags = {
                    gui_id = gui_id
                }
            }
        }
    }
end

local function open_gui(player, parameter)
    local gui_id = "gui-" .. player.index .. "-" .. game.tick
    local gui_contents = {
        {
            type = "frame",
            direction = "vertical",
            name = "window",
            children = {
                header(gui_id),
                toolbar.create_toolbar(gui_id, parameter),
                {
                    type = "tabbed-pane",
                    ref = { "tabs", "pane" },
                    children = {
                        {
                            tab = {
                                type = "tab",
                                caption = { "train-log.tab-events" }
                            },
                            content = {
                                type = "flow",
                                direction = "vertical",
                                name = "tabs_events_contents"
                            }
                        },
                        {
                            tab = {
                                type = "tab",
                                caption = { "train-log.tab-summary" }
                            },
                            content = {
                                type = "flow",
                                direction = "vertical",
                                name = "tabs_summary_contents"
                            }
                        }
                    }
                },
            }
        }
    }
    local train_log_gui = gui.add(player.gui.screen, gui_contents)
    storage.guis[gui_id] = {
        gui_id = gui_id,
        gui = train_log_gui,
        player = player
    }
    train_log_gui.titlebar.drag_target = train_log_gui.window
    train_log_gui.window.force_auto_center()
    events_table.create_events_table(gui_id)
end

local function update_player_gui(player)
    local guis = storage.guis
    for gui_id, train_log_gui in pairs(guis) do
        if train_log_gui and train_log_gui.player == player then
            toolbar.refresh(gui_id)
        end
    end
end

local function destroy_gui(gui_id)
    local train_log_gui = storage.guis[gui_id]
    train_log_gui.gui.window.destroy()
    storage.guis[gui_id] = nil
end

local function open_or_close_gui(player, always_open)
    if always_open then
        -- open a new gui either way
        open_gui(player)
        return
    end

    -- close existing gui if one is open
    for gui_id, train_log_gui in pairs(storage.guis) do
        if train_log_gui.player == player then
            destroy_gui(gui_id)
            return
        end
    end

    -- no existing gui for player, open a new gui
    open_gui(player)
end

function gui_handlers.open_train_log(event)
    local player = game.players[event.player_index]
    open_or_close_gui(player, event.control or event.shift)
end

function gui_handlers.close_window(event)
    local gui_id = event.element.tags.gui_id
    destroy_gui(gui_id)
end

gui.add_handlers(gui_handlers, function(e, handler)
    handler(e)
end)

return {
    open_or_close_gui = open_or_close_gui,
    update_player_gui = update_player_gui,
    open = open_gui
}